--************************************************
-- tab size = 4
--************************************************
--Project	: SP-50
--Function	: Serial Peripheral Interface (SPI) (Master/全二重)
--			  SCLK_freq = CE_freq/2
--			  Mode 0 == {CPOL,CPHA}={0,0} == {CKP,CKE}={0,1}  Idle時SCLK=0、立ち下がりシフト、立ち上がりラッチ。ラッチしてからシフト
--			  Mode 1 == {CPOL,CPHA}={0,1} == {CKP,CKE}={0,0}  Idle時SCLK=0、立ち上がりシフト、立ち下がりラッチ。シフトしてからラッチ
--			  Mode 2 == {CPOL,CPHA}={1,0} == {CKP,CKE}={1,1}  Idle時SCLK=1、立ち上がりシフト、立ち下がりラッチ。ラッチしてからシフト
--			  Mode 3 == {CPOL,CPHA}={1,1} == {CKP,CKE}={1,0}  Idle時SCLK=1、立ち下がりシフト、立ち上がりラッチ。シフトしてからラッチ
--			  CPOL, CKP : idleのときのSCLKレベル。0: Low,  1:High
--			  CPHA      : SCLKのどちらのエッジでシフトするか。0: CPOLに戻る時シフト  1: CPOLと逆になる時シフト
--			  CKE       : SCLKのどちらのエッジでラッチするか。0: CPOLに戻る時ラッチ  1: CPOLと逆になる時ラッチ
----------------------------------------
-- Rev.	Date		Designer	Desc.
-- 0	2014/04/14	M.Tanaka	New
-- 1.0	2015/01/16	M.Tanaka
--			: tCSH=0ns確保のため、SCSb出力を1CLK遅らせるよう変更
--				function上はSCLK↓とs_CS変化タイミングは同時だが、遅延差未考慮だったため
--			: SCSbアサート前後のSCLK挿入切り替え信号(MODE2)追加
-- 1.1	2015/03/24	M.Tanaka
--			: s_SCLK_oeのアサートタイミングを修正するため、st_ckoe、st_shiftを変更
--				上記ステートからの遷移と同時だったが、s_SCLK_base立ち下がりと同時にs_SCLK_oeがアサートされると、
--				ヒゲ発生の危険性があるため
----------
-- 1.1	2019/11/18	M.Tanaka
--	SLAT and nSLD is added for GSIO
--************************************************

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use IEEE.std_logic_arith.all;

entity SPI_master2 is
	generic (
		g_DatSize		: integer := 8		-- Data size
	);
	port (
		RESETb		: in	std_logic;	-- async reset (act.L)
		CLR			: in	std_logic;	-- sync clear except internal SCLK and MODE (act.H)
		CLK			: in	std_logic;	-- clock
		CE			: in	std_logic;	-- clock enable : 1pulse/1period (act.H). SCLK_freq = CE_freq/2.
		DI			: in	std_logic_vector( g_DatSize-1 downto 0 );	-- parallel data (to slave)
		DO			: out	std_logic_vector( g_DatSize-1 downto 0 );	-- parallel data (from slave)
		START		: in	std_logic;	-- shift start (act.H)
		BUSY		: out	std_logic;	-- not idle
		MODE		: in	std_logic_vector( 1 downto 0 ) := "00";	-- SPI mode
		MODE2		: in	std_logic := '0';	-- assert one SCLK before/after SCSb
		SCSb		: out	std_logic;	-- SPI Chip select
		SCLK		: out	std_logic;	-- SPI shift clock
		MISO		: in	std_logic;	-- SPI shift data (master in slabe out)
		MOSI		: out	std_logic;	-- SPI shift data (master out slabe in)
		SLAT		: out	std_logic;
		nSLD		: out	std_logic
	);
end SPI_master2;

architecture RTL of SPI_master2 is	--**********************

	constant c_MSB		: integer := g_DatSize-1;
	signal	s_CLR_in	: std_logic;
	signal	s_CLR		: std_logic;

	type	ty_STA	is (
		st_idle,	-- idle
		st_ckoe,	-- SCLK output enable
		st_load,	-- data latch before 1st SCLK
		st_shift,	-- data shift
		st_ncs		-- negate CS
	);

	signal	s_sta		: ty_STA;							-- state
	signal	s_shift_reg	: std_logic_vector( c_MSB downto 0 );	-- shift data (MOSI)
	signal	s_latch_reg	: std_logic;					-- MISO latch
	signal	s_cnt		: integer range 0 to c_MSB+1;		-- shift counter
	signal	s_cnt_low	: std_logic;	-- s_cnt < c_MSB

	signal	s_START		: std_logic;
	signal	s_START_R	: std_logic;
	signal	s_BUSY		: std_logic;
	signal	s_BUSY_D	: std_logic;
	signal	s_BUSY_OUT	: std_logic;
	signal	s_MODE		: std_logic_vector( 1 downto 0 );
	alias	a_CPOL		: std_logic is s_MODE(1);
	alias	a_CPHA		: std_logic is s_MODE(0);

	signal	s_CS		: std_logic;
	signal	s_CS_d		: std_logic;
	signal	s_SCLK		: std_logic;
	signal	s_MISO		: std_logic;
	signal	s_MOSI		: std_logic;

	signal	s_SCLK_base	: std_logic;	-- SCLK、動作タイミング
	signal	s_SCLK_oe	: std_logic;	-- SCLK出力イネーブル
	signal	s_sckr		: std_logic;	-- SCLK rise
	signal	s_sckf		: std_logic;	-- SCLK fall
	signal	s_shift_tmg	: std_logic;	-- シフトタイミング
	signal	s_shift_cnd	: std_logic;	-- シフト条件
	signal	s_shift_en	: std_logic;	-- シフトイネーブル
	signal	s_latch_tmg	: std_logic;	-- ラッチタイミング
	signal	s_latch_cnd	: std_logic;	-- ラッチ条件
	signal	s_latch_en	: std_logic;	-- ラッチイネーブル

begin	--**************************************************

	-- I/O (ゲート、極性) ------------------------
	DO		<=     s_shift_reg;

	BUSY	<=     s_BUSY_OUT;

	SCSb	<= not s_CS_d;

	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_CS_d	<= '0';
		elsif ( rising_edge(CLK) ) then
			s_CS_d	<= s_CS;
		end if;
	end process;

	SCLK	<=     s_SCLK		when ( a_CPOL = '0' )
		else   not s_SCLK;

	s_SCLK	<=     s_SCLK_base	when ( s_SCLK_oe = '1' )
			else   '0';

	s_MISO	<=     MISO;

	MOSI	<=     s_MOSI;

	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			SLAT	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( s_sta = st_ncs ) then
				if ( s_sckr = '1' ) then
					SLAT	<= '1';
				elsif ( s_sckf = '1' ) then
					SLAT	<= '0';
				end if;
			else
				SLAT	<= '0';
			end if;
		end if;
	end process;

	nSLD	<=		not s_SCLK_base	when ( s_sta = st_ckoe )
			else	'1';

	-- クリア ------------------------------------
	proc_CLR :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_CLR_in	<= '0';
			s_CLR		<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( s_CLR_in = '0' ) then
				s_CLR_in	<= CLR;
			elsif ( s_CLR = '1' ) then
				s_CLR_in	<= CLR;
			end if;
			if ( s_sckf = '1' ) then
				s_CLR		<= s_CLR_in;
			elsif ( s_CLR = '1' ) then
				s_CLR		<= CLR;
			end if;
		end if;
	end process proc_CLR;


	-- シフトクロック 兼 動作タイミング ----------
	proc_SCLK :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_SCLK_base	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( CE = '1' ) then
				s_SCLK_base	<= not s_SCLK_base;
			end if;
		end if;
	end process proc_SCLK;

	s_sckr	<= CE and ( not s_SCLK_base );	-- rise edge
	s_sckf	<= CE and s_SCLK_base;			-- fall edge

	-- STARTするまで保持 -------------------------
	proc_START :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_START	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( s_CLR = '1' ) then
				s_START	<= '0';
			elsif ( ( s_BUSY_D = '1' ) and ( s_BUSY = '0' ) ) then	-- when BUSY is negated
				s_START	<= '0';
			elsif ( s_START = '0' ) then
				s_START	<= START;
			end if;
		end if;
	end process proc_START;

	s_START_R	<= ( not s_START ) and START;	-- detect assert


	-- 処理中フラグ -----------------------------
	s_BUSY_OUT	<= s_BUSY or s_START;

	s_BUSY	<=     '0'		when ( s_sta = st_idle )
			else   '1';

	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_BUSY_D	<= '0';
		elsif ( rising_edge(CLK) ) then
			s_BUSY_D	<= s_BUSY;
		end if;
	end process;


	-- MODE動作中保持 ----------------------------
	proc_MODE :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_MODE	<= ( others => '0' );
		elsif ( rising_edge(CLK) ) then
			if ( s_BUSY_OUT = '0' ) then
				s_MODE	<= MODE;
			end if;
		end if;
	end process proc_MODE;


	-- シフトレジスタとカウント ------------------
	proc_shift :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_shift_reg	<= ( others => '0' );
			s_cnt		<= 0;
		elsif ( rising_edge(CLK) ) then
			if ( s_CLR = '1' ) then
				s_shift_reg	<= ( others => '0' );
				s_cnt		<= 0;
			elsif ( s_START_R = '1' ) then
				s_shift_reg	<= DI;
				s_cnt		<= 0;
			elsif ( s_shift_en = '1' ) then
				s_shift_reg	<= s_shift_reg( c_MSB-1 downto 0 ) & s_latch_reg;
				s_cnt		<= s_cnt + 1;
			end if;
		end if;
	end process proc_shift;

	s_MOSI	<= s_shift_reg(c_MSB);
	s_cnt_low	<= '1'	when ( s_cnt < c_MSB )
		else	   '0';


	-- MISOラッチ --------------------------------
	proc_latch :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_latch_reg	<= '0';
		elsif ( rising_edge(CLK) ) then

			if ( s_CLR = '1' ) then
				s_latch_reg	<= '0';
			elsif ( s_latch_en = '1' ) then
				s_latch_reg	<= s_MISO;
			end if;

		end if;
	end process proc_latch;


	-- state machine -----------------------------
	proc_state :
	process ( CLK, RESETb )
	begin
		if ( RESETb = '0' ) then
			s_sta		<= st_idle;
			s_CS		<= '0';
			s_SCLK_oe	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( s_CLR = '1' ) then
				s_sta		<= st_idle;
				s_CS		<= '0';
				s_SCLK_oe	<= '0';
			else
				case ( s_sta ) is
					when st_idle =>
						if ( s_sckr = '1' ) then
							if ( s_START = '1' ) then
								s_sta		<= st_ckoe;
								s_CS		<= '0';
--								s_SCLK_oe	<= '1';
								s_SCLK_oe	<= MODE2;
							end if;
						end if;
					when st_ckoe =>	-- このステートに入る時までにs_MODE、s_shift_regが確定
						if ( s_sckf = '1' ) then
							if (a_CPHA='0') then
								s_sta		<= st_shift;
								s_CS		<= '1';
								s_SCLK_oe	<= s_SCLK_oe;
							else
								s_sta		<= st_load;
								s_CS		<= '1';
								s_SCLK_oe	<= s_SCLK_oe;
							end if;
						end if;
					when st_load =>
						if ( s_sckr = '1' ) then
							s_sta		<= st_shift;
						end if;
							s_CS		<= '1';
							s_SCLK_oe	<= '1';
					when st_shift =>
						if ( s_cnt_low = '1' ) then
							s_sta		<= st_shift;
							s_CS		<= '1';
							s_SCLK_oe	<= '1';
						elsif ( s_sckf = '1' ) then
							s_sta		<= st_ncs;
							s_CS		<= '0';
--							s_SCLK_oe	<= '1';
							s_SCLK_oe	<= MODE2;
						end if;
					when st_ncs	=>
						if ( s_sckf = '1' ) then
							s_sta		<= st_idle;
							s_CS		<= '0';
							s_SCLK_oe	<= '0';
						end if;
					when others	=>	-- illegal state
							s_sta		<= st_idle;
							s_CS		<= '0';
							s_SCLK_oe	<= '0';
				end case;
			end if;
		end if;
	end process proc_state;

	-- シフト実行条件
	s_shift_cnd	<=   '1'	when   ( s_sta = st_shift )
			else     '1'	when ( ( s_sta = st_ncs   ) and ( a_CPHA = '1' ) )
			else     '0';

	s_shift_tmg	<= s_sckf	when ( a_CPHA = '0' )
			else   s_sckr;

	s_shift_en	<= s_shift_tmg and s_shift_cnd;

	-- MISOラッチ実行条件
	s_latch_cnd	<=   '1'	when ( s_sta = st_shift )
			else     '0';

	s_latch_tmg	<= s_sckr	when ( a_CPHA = '0' )
			else   s_sckf;

	s_latch_en	<= s_latch_tmg and s_latch_cnd;


end RTL ;
