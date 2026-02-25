--------------------------------------------------
-- tab size = 4
--------------------------------------------------
--Project	: SP-50
--Function	: AD8402  control
--			{CMND_BUSY, AD8402_BUSY} = {0,0}	未動作
--			{CMND_BUSY, AD8402_BUSY} = {1,0}	START後、未送信or送信完了
--			{CMND_BUSY, AD8402_BUSY} = {1,1}	送信中
--			{CMND_BUSY, AD8402_BUSY} = {0,1}	イリーガル(途中でSTART=0になった)
----------------------------------------
-- Rev.	Date		Designer	Desc.
-- 0	2014/04/14	M.Tanaka	New
-- 0	2014/01/16	M.Tanaka	SP-50 proto1用に変更
--			: s_CE(1MHz 25/1000)とs_SCK(1MHz 1/2)の関係が、SP0388Dのclkgen_SP0388の
--			  CLK_1us_PLSとCLK_1usのタイミングと同じになるように修正
--			  s_SCK立ち上がりの1CLK後にs_CEが1パルスHigh
--			  外部への出力AD8402_SCKはs_SCKを反転
-- 0	2021/12/22 S.Matsuda CMND_FIN added
--------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use ieee.std_logic_arith.all;

entity AD8402_CTRL is
	port (
		RST_n		: in	std_logic;	-- reset (act.L)
		CLK			: in	std_logic;	-- clock
		CE			: in	std_logic;	-- clock enable : 1pulse/1period (act.H) SCLK_freq = CE_freq/2.
		CH1			: in	std_logic_vector(7 downto 0);	-- TX data (ch1)
		CH2			: in	std_logic_vector(7 downto 0);	-- TX data (ch2)
		START		: in	std_logic;	-- process start (act.H)
		CMND_BUSY	: out	std_logic;	-- command statemachine not idle
		CMND_FIN		: out	std_logic;	-- 送信後ステートがFIN
		AD8402_BUSY	: out	std_logic;	-- ad8402 statemachine not idle
		AD8402_CS_n	: out	std_logic;	-- SPI Chip select
		AD8402_SCK	: out	std_logic;	-- SPI shift clock
		AD8402_SDO	: out	std_logic	-- serial data (to slave)

	);
end AD8402_CTRL;

architecture RTL of AD8402_CTRL is	--**************************

	component ad8402	-- START=1で2ch連続送信開始
	port (
		RESETb		: in	std_logic ;	-- 同期リセット(act.L)：非同期ではないので注意
		CLK_IN		: in	std_logic ;	-- システムクロック
		CLK1us_PLS	: in	std_logic ;	-- 1 pulse / 1us (act.H) ステートマシン動作タイミング
		START		: in	std_logic ;	-- 送信開始(act.H)。idle時のみ評価する
		POTD1		: in	std_logic_vector(7 downto 0) ;	-- ch1データ。BUSY中は変更しないこと
		POTD2		: in	std_logic_vector(7 downto 0) ;	-- ch2データ。BUSY中は変更しないこと
		CS			: out	std_logic;	-- デバイスへのチップセレクト(act.L)
		SDI			: out	std_logic;	-- シリアル出力。「相手のSDI」
		BUSY		: out	std_logic;	-- 送信後ステートとIdleステート以外
		NEXT_ST		: out	std_logic	-- 送信後のステートでCLK1us_PLS 1サイクル分High。SP0388では未使用
	);
	end component;

	-- state machine
	type	ty_STA	is (
		st_idle,	-- idle
		st_wait1,	-- wait until ad8402_BUSY='1'
		st_wait2,	-- wait until ad8402_BUSY='0'
		st_fin		-- wait until START='0'
	);

	signal	s_sta		: ty_STA;

	signal	s_CE		: std_logic;
	signal	s_START1	: std_logic;
	signal	s_START2	: std_logic;
	signal	s_START_PLS	: std_logic;
	signal	s_CMND_BUSY	: std_logic;
	signal	s_CMND_FIN	: std_logic;


	signal	s_SCK_a			: std_logic;
	signal	s_SCK			: std_logic;
	signal	s_SCKOE_n		: std_logic;

	signal	s_ad8402_CS_n	: std_logic;
	signal	s_ad8402_SDO	: std_logic;
	signal	s_ad8402_BUSY	: std_logic;

begin	--**************************************************

-- I/O ---------------------------------
	CMND_BUSY	<=	s_CMND_BUSY;

	AD8402_BUSY	<=	s_ad8402_BUSY;

	AD8402_CS_n	<=	s_ad8402_CS_n;

	AD8402_SCK	<=	(not s_SCK)	when ( s_SCKOE_n = '0' )
			else	'0';

	AD8402_SDO	<=	s_ad8402_SDO;

	CMND_FIN	<=	s_CMND_FIN;

-- clock enable ------------------------
--	s_CE		<=	CE and s_SCK;


-- SCK ---------------------------------
	process ( CLK, RST_n )
	begin
		if ( RST_n = '0') then
			s_SCK	<= '0';
			s_SCK_a	<= '0';
			s_CE	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( CE = '1' ) then
				s_SCK	<= not s_SCK;
			end if;
			s_SCK_a	<= s_SCK;
			s_CE	<= s_SCK and (not s_SCK_a);
		end if;
	end process;


-- SCK出力イネーブル -------------------
--	process ( CLK, RST_n )
--	begin
--		if ( RST_n = '0') then
--			s_SCKOE_n	<= '0';
--		elsif ( rising_edge(CLK) ) then
			s_SCKOE_n	<= s_ad8402_CS_n;
--		end if;
--	end process;


-- START エッジ検出 --------------------
	process ( CLK, RST_n )
	begin
		if ( RST_n = '0') then
			s_START1	<= '0';
			s_START2	<= '0';
		elsif ( rising_edge(CLK) ) then
			if ( s_CE = '1' ) then
				s_START1	<= START;
				s_START2	<= s_START1;
			end if;
		end if;
	end process;

	s_START_PLS	<=	s_START1 and ( not s_START2 );	-- rising edge


-- ad8402 control ----------------------
	U_ad8402 : ad8402
	port map (
		RESETb		=> RST_n,
		CLK_IN		=> CLK,
		CLK1us_PLS	=> s_CE,
		START		=> s_START_PLS,
		POTD1		=> CH1,
		POTD2		=> CH2,
		CS			=> s_ad8402_CS_n,
		SDI			=> s_ad8402_SDO,
		BUSY		=> s_ad8402_BUSY,
		NEXT_ST		=> open
	);


-- state machine -----------------------
	proc_state :
	process ( CLK, RST_n )
	begin
		if ( RST_n = '0' ) then
			s_sta	<= st_idle;
		elsif ( rising_edge(CLK) ) then
			case s_sta is
				when st_idle =>	------------------
					if ( ( START = '1' ) and ( s_START_PLS = '1' ) ) then
						s_sta	<= st_wait1;
					else
						s_sta	<= st_idle;
					end if;
				when st_wait1 =>	--------------
					if ( START = '1' ) then
						if ( s_ad8402_BUSY = '1' ) then
							s_sta	<= st_wait2;
						else
							s_sta	<= st_wait1;
						end if;
					else
						s_sta	<= st_idle;
					end if;
				when st_wait2 =>	--------------
					if ( START = '1' ) then
						if ( s_ad8402_BUSY = '0' ) then
							s_sta	<= st_fin;
						else
							s_sta	<= st_wait2;
						end if;
					else
						s_sta	<= st_idle;
					end if;
				when st_fin =>	------------------
					if ( START = '1' ) then
						s_sta	<= st_fin;
					else
						s_sta	<= st_idle;
					end if;
				when others =>	------------------
						s_sta	<= st_idle;
			end case;
		end if;
	end process proc_state;

	s_CMND_BUSY	<=	'0'	when ( s_sta = st_idle )
			else	'1';

	s_CMND_FIN	<=	'1'	when ( s_sta = st_fin )
			else	'0';

end RTL ;
