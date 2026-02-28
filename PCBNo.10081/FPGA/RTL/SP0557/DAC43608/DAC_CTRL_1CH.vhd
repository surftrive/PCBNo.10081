-------------------------------------------------
--File Name : DAC_CTRL_1CH.vhd
--Project	: C166M
--
--Date		: 2012/12/17
--Ver		: 0.00
--Doc		: New Release for  M41T62
--Designed by INAGAKI JUN
-------------------------------------
--Date		: 2022/12/09
--Ver		: 0.01
--Doc		: Prescaler LSB value is changed to feed by generic
--Designed by
-------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------
entity DAC_CTRL_1CH is
	generic (
		g_PrescaleL	: std_logic_vector( 7 downto 0 )	-- SCL freq Prescaler LSB
--			:= X"4F"	-- 100kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] * 2 - 1"
--			:= X"27"	-- 200kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] - 1"
			:= X"13"	-- 400kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] / 2 - 1"
	) ;
	port (
		CLK			: in	std_logic ;	-- clock 40MHz
		LRSTb		: in	std_logic ;	-- local reset

		ch_slave	: in	std_logic_vector( 4 downto 0 ) ;	-- [4:2] ch, [1:0]slave sel
		DATA		: in	std_logic_vector( 7 downto 0 ) ;	-- DAC data
		TRIGGER		: in	std_logic ;	-- statemachine start trigger (Act.H)
		COMP_FLAG	: out	std_logic ;	-- send end (Act.H pulse)
	-- WISHBONE interface signals
		WB_ADR_I	: out	std_logic_vector( 2 downto 0 ) ;
		WB_DAT_I	: out	std_logic_vector( 7 downto 0 ) ;
		WB_DAT_O	: in	std_logic_vector( 7 downto 0 ) ;	-- bits [5:2,0] unused; 8-bit WISHBONE bus width required by I2C core interface
		WB_WE_I		: out	std_logic ;
		WB_STB_I	: out	std_logic ;
		WB_CYC_I	: out	std_logic ;
		WB_ACK_O	: in	std_logic ;
		WB_INTA_O	: in	std_logic
	) ;

end DAC_CTRL_1CH ;

----------------------architecture---------------------------
architecture RTL of DAC_CTRL_1CH is

---------------type------------------------------------------
type STATE is (
				stIDLE,

				stWRALL0,stWRALL1,stWRALL2,stWRALL3,
				stWRALL4,stWRALL5,stWRALL6,stWRALL7,stWRALL8,stWRALL9,
				stWRALL10,stWRALL11,stWRALL12,stWRALL13,stWRALL14,stWRALL15,
				stWRALL16,stWRALL17,stWRALL18,stWRALL19,stWRALL20,
				stWRALL22,stWRALL23,stWRALL24,stWRALL25,stWRALL26,stWRALL27,stWRALL28,stWRALL29,
				stWRALL31,stWRALL32,stWRALL33,stWRALL34,stWRALL35,stWRALL36,stWRALL37,stWRALL38,

				stPOWUP0,stPOWUP1,stPOWUP2,stPOWUP3,
				stPOWUP4,stPOWUP5,stPOWUP6,stPOWUP7,stPOWUP8,stPOWUP9,
				stPOWUP10,stPOWUP11,stPOWUP12,stPOWUP13,stPOWUP14,stPOWUP15,
				stPOWUP16,stPOWUP17,stPOWUP18,stPOWUP19,stPOWUP20,
				stPOWUP22,stPOWUP23,stPOWUP24,stPOWUP25,stPOWUP26,stPOWUP27,stPOWUP28,stPOWUP29,
				stPOWUP31,stPOWUP32,stPOWUP33,stPOWUP34,stPOWUP35,stPOWUP36,stPOWUP37,stPOWUP38,

				stINI1,stINI2,stINI3,stINI4,stINI5,
				stINI6,stINI7,stINI8,stINI9,stINI10,
				stINI11,stINI12,stINI13,stINI14,stINI15,

				stSTOP1,stSTOP2,stSTOP3,stSTOP4,stSTOP5

				);

---------------signal----------------------------------------
signal st			: STATE;

signal s_wb_adr_i		: std_logic_vector(2 downto 0);
signal s_wb_dat_i		: std_logic_vector(7 downto 0);

signal s_wb_we_i		: std_logic;
signal s_wb_stb_i		: std_logic;

signal s_wb_ack_o		: std_logic;
signal s_INI			: std_logic;		--s_INI=1の時,初期化済み--
-- Consume unused WISHBONE data bits to suppress CL246/CL247 (8-bit bus width required by I2C core)
signal s_unused_wbdat	: std_logic;
attribute syn_keep : boolean;
attribute syn_keep of s_unused_wbdat : signal is true;

begin
	s_unused_wbdat <= WB_DAT_O(5) or WB_DAT_O(4) or WB_DAT_O(3) or WB_DAT_O(2) or WB_DAT_O(0);

	-----------------------------------------------------------------
	-----------------------------------------------------------------
		wb_adr_i	<= s_wb_adr_i;		--:out	std_logic_vector(2 downto 0);
		wb_dat_i	<= s_wb_dat_i;		--:out	std_logic_vector(7 downto 0);

		wb_we_i		<= s_wb_we_i;  		--:out std_logic;
		wb_stb_i	<= s_wb_stb_i;		--:out	std_logic;
		wb_cyc_i	<= s_wb_stb_i;

		s_wb_ack_o	<= WB_ACK_O;		--:in	 std_logic;


	process (CLK, LRSTb) begin
		if (LRSTb = '0') then

			st <= stIDLE;

			s_INI			<=	'0';
			s_wb_adr_i	<=	(others => '0');	--:out	std_logic_vector(2 downto 0);
			s_wb_dat_i	<=	(others => '0');	--:out	std_logic_vector(7 downto 0);
			s_wb_we_i	<=	'0';				--:out	std_logic;
			s_wb_stb_i	<=	'0';				--:out	std_logic;
			COMP_FLAG		<=	'0';

		elsif (CLK'event and CLK='1') then
			case st is
				when stIDLE =>
					s_wb_adr_i	<=	(others => '0');
					s_wb_dat_i	<=	(others => '0');
					s_wb_we_i	<=	'0';
					s_wb_stb_i	<=	'0';
					COMP_FLAG			<=	'0';

					--初期化ステート--
					if(s_INI = '0') then
						s_INI 		<= '1';
						st 			<= stINI1;

					--書き込みステート--
					elsif(trigger = '1')then
						st 			<= stWRALL1;

					else
						s_INI		<= s_INI;				--
						st			<= stIDLE;
					end if;
				--

			--============================================================
			-- I2C-Master coreの初期化 Initialization					==
			--============================================================
				when stINI1 =>						--I2C core enable bit.
					s_wb_adr_i	<=	"010";			-- I2C Control Set
					s_wb_dat_i	<=	"00000000";		-- 00h	turn off I2C core
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';

					st			<=	stINI2;

				when stINI2 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
					s_wb_we_i	<=	s_wb_we_i;
					s_wb_stb_i	<=	'1';			-- stb ON
										--
					st			<=	stINI3;
				when stINI3 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
											--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<=	stINI4;
					else
						s_wb_we_i	<=	s_wb_we_i;
						s_wb_stb_i	<=	s_wb_stb_i;
						st			<=	stINI3;
					end if;-----------------------------------------------------------

				when stINI4 =>						--								--
					s_wb_adr_i	<=	"100";			--Command Resister				--
					s_wb_dat_i	<=	"00000001";		-- 01h	clearn any pening IRQ	--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--
					st			<=	stINI5;
					--
				when stINI5 =>														--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					s_wb_we_i	<=	s_wb_we_i;										--
					s_wb_stb_i	<=	'1';			-- stb ON						--
											--
					st			<=	stINI6;

				when stINI6 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
											--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<=	stINI7;
					else
						s_wb_we_i	<=	s_wb_we_i;
						s_wb_stb_i	<=	s_wb_stb_i;
						st			<=	stINI6;
					end if;-----------------------------------------------------------
				when stINI7 =>
					s_wb_adr_i	<=	"000";			-- I2C Mode Set
					--s_wb_dat_i	<=	"01001111";	-- 004Fh (L) 100kbps
					--s_wb_dat_i	<=	"00100111";	-- 0027h (L) 200kbps
					--s_wb_dat_i	<=	"00010011";	-- 0013h (L) 400kbps
					s_wb_dat_i	<=	g_PrescaleL ;
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';
											--
					st			<=	stINI8;
				when stINI8 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
					s_wb_we_i	<=	s_wb_we_i;
					s_wb_stb_i	<=	'1';			-- stb ON
											--
					st			<=	stINI9;
				when stINI9 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
											--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<=	stINI10;
					else
						s_wb_we_i	<=	s_wb_we_i;
						s_wb_stb_i	<=	'1';
						st			<=	stINI9;
					end if;-----------------------------------------------------------

				when stINI10 =>
					s_wb_adr_i	<=	"001";			-- I2C Mode Set
					s_wb_dat_i	<=	"00000000";		-- 0013h (H) 400kbps
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';
										--
					st			<=	stINI11;
				when stINI11 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
					s_wb_we_i	<=	s_wb_we_i;
					s_wb_stb_i	<=	'1';			-- stb ON
											--
					st			<=	stINI12;
				when stINI12 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
											--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stINI13;
					else
						s_wb_we_i	<=	s_wb_we_i;
						s_wb_stb_i	<=	'1';
						st			<=	stINI12;
					end if;-----------------------------------------------------------
				when stINI13 =>						--I2C core enable bit.
					s_wb_adr_i	<=	"010";			-- I2C Control Set
					s_wb_dat_i	<=	"10000000";		-- 80h	turn on I2C core
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';
											--
					st			<=	stINI14;
				when stINI14 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
					s_wb_we_i	<=	s_wb_we_i;
					s_wb_stb_i	<=	'1';			-- stb ON
										--
					st			<=	stINI15;

				when stINI15 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
											--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<=	stPOWUP1;
					else
						s_wb_we_i	<=	s_wb_we_i;
						s_wb_stb_i	<=	s_wb_stb_i;
						st			<=	stINI15;
					end if;

				--write data part--
				--デバイスコンフィグレジスタONに--

				--slave adress--
				when stPOWUP1 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	"10001110";		--ブロードキャストアドレス					--
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';

					st			<= stPOWUP2;


				when stPOWUP2 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP3;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP2;
					end if;						--

				--CTR adress set
				--STA & WR bit set
				when stPOWUP3 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"10010000"; --   STA & WR set							--

					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stPOWUP4;

				--ack confirm
				when stPOWUP4 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP5;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP4;
					end if;

				when stPOWUP5 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stPOWUP6;										--R
				when stPOWUP6 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stPOWUP7;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stPOWUP6;									--R
					end if;															--R

				when stPOWUP7 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP11;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP7;												--R
					end if;-----------------------------------------------------------R


					--comand adress set--
				when stPOWUP11 =>				-- Write address Transmit ------------
					s_wb_adr_i	<=	"011";		--Transmit Resister					--								--
					s_wb_dat_i	<=	"00000001";		--DEVICE＿CONFIG--						--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--								--
					st			<= stPOWUP12;										--

				when stPOWUP12 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stPOWUP13;									--
					else															--
						s_wb_we_i	<=	'1';										--
						s_wb_stb_i	<=	'1';										--
						st			<= stPOWUP12;									--
					end if;															--

				when stPOWUP13 =>				-- WriteToSlave						--
					s_wb_adr_i	<=	"100";		--Command Resister					--
					s_wb_dat_i	<=	"00010000";	--10h WR							--
					s_wb_we_i	<=	'1';		--WR								--
					s_wb_stb_i	<=	'0';											--
					st			<= stPOWUP14;										--

				when stPOWUP14 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stPOWUP17;									--
					else															--
						s_wb_we_i	<= '1';											--
						s_wb_stb_i	<= '1';											--
						st			<= stPOWUP14;									--
					end if;															--

				when stPOWUP17 =>													--
					s_wb_adr_i	<=	"100";		--Status Resister					--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					s_wb_we_i	<=	'0';		--RD								--
					s_wb_stb_i	<=	'0';											--
					st			<= stPOWUP18;										--

				when stPOWUP18 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stPOWUP19;									--
					else															--
						s_wb_we_i	<=	s_wb_we_i;										--
						s_wb_stb_i	<=	'1';										--
						st			<= stPOWUP18;									--
					end if;															--

				when stPOWUP19 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP22;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP19;												--R
					end if;-----------------------------------------------------------R

				--MSDB set--
				when stPOWUP22 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	"00000000";		--tranmit adress 0x03					--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';

					st			<= stPOWUP23;


				when stPOWUP23 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP24;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP23;
					end if;						--

				when stPOWUP24 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"00010000"; --   STA & WR set							--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stPOWUP25;

				--ack confirm
				when stPOWUP25 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
																	--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP26;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP25;
					end if;

				when stPOWUP26 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stPOWUP27;										--R

				when stPOWUP27 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stPOWUP28;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stPOWUP27;									--R
					end if;															--R

				when stPOWUP28 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP31;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stPOWUP28;										    --R
					end if;															--R

				--LSDB set--
				when stPOWUP31 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	"00000000";		--tranmit adress 0x03					--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';

					st			<= stPOWUP32;


				when stPOWUP32 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP33;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP32;
					end if;						--

				when stPOWUP33 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"00010000"; --   STA & WR set							--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stPOWUP34;

				--ack confirm
				when stPOWUP34 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stPOWUP35;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stPOWUP34;
					end if;

				when stPOWUP35 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stPOWUP36;										--R

				when stPOWUP36 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stPOWUP37;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stPOWUP36;									--R
					end if;					--R

				when stPOWUP37 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					--ステータスレジスタの7bit目がACK信号なので、それを読む--
					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stSTOP1;												--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stPOWUP37;												--R
					end if;-----------------------------------------------------------R

				--write data part--

				--slave adress--
				when stWRALL1 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	"10010" & ch_slave(1 downto 0) & "0";		--tranmit adress 0x03					--
					s_wb_we_i	<=	'1';
					s_wb_stb_i	<=	'0';

					st			<= stWRALL2;


				when stWRALL2 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL3;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL2;
					end if;						--

				--CTR adress set
				--STA & WR bit set
				when stWRALL3 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"10010000"; --   STA & WR set							--
					--s_wb_dat_i	<=	"00010000"; --   STA & WR set							--リピートスタートを解除--

					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stWRALL4;

				--ack confirm
				when stWRALL4 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL5;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL4;
					end if;

				when stWRALL5 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stWRALL6;										--R
				when stWRALL6 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stWRALL7;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stWRALL6;									--R
					end if;															--R

				when stWRALL7 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL8;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL7;												--R
					end if;-----------------------------------------------------------R


				when stWRALL8 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					if wb_dat_o(7) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL11;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL8;												--R
					end if;-----------------------------------------------------------R

					--comand adress set--
				when stWRALL11 =>				-- Write address Transmit ------------
					s_wb_adr_i	<=	"011";		--Transmit Resister					--								--
					s_wb_dat_i	<=	"00001"& ch_slave(4 downto 2);								--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--								--
					st			<= stWRALL12;										--

				when stWRALL12 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stWRALL13;									--
					else															--
						s_wb_we_i	<=	'1';										--
						s_wb_stb_i	<=	'1';										--
						st			<= stWRALL12;									--
					end if;															--

				when stWRALL13 =>				-- WriteToSlave						--
					s_wb_adr_i	<=	"100";		--Command Resister					--
					s_wb_dat_i	<=	"00010000";	--10h WR							--
					s_wb_we_i	<=	'1';		--WR								--
					s_wb_stb_i	<=	'0';											--
					st			<= stWRALL14;										--

				when stWRALL14 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stWRALL17;									--
					else															--
						s_wb_we_i	<= '1';											--
						s_wb_stb_i	<= '1';											--
						st			<= stWRALL14;									--
					end if;															--

				when stWRALL17 =>													--
					s_wb_adr_i	<=	"100";		--Status Resister					--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					s_wb_we_i	<=	'0';		--RD								--
					s_wb_stb_i	<=	'0';											--
					st			<= stWRALL18;										--

				when stWRALL18 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--
						s_wb_we_i	<=	'0';										--
						s_wb_stb_i	<=	'0';										--
						st			<= stWRALL19;									--
					else															--
						s_wb_we_i	<=	s_wb_we_i;										--
						s_wb_stb_i	<=	'1';										--
						st			<= stWRALL18;									--
					end if;															--

				when stWRALL19 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL20;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL19;												--R
					end if;-----------------------------------------------------------R

				when stWRALL20 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--

					if wb_dat_o(7) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL22;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL20;												--R
					end if;-----------------------------------------------------------R

				--MSDB set--
				when stWRALL22 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	"0000" & data(7 downto 4);		--tranmit adress 0x03					--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';

					st			<= stWRALL23;


				when stWRALL23 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL24;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL23;
					end if;						--

				when stWRALL24 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"00010000"; --   STA & WR set							--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stWRALL25;

				--ack confirm
				when stWRALL25 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;
																	--
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL26;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL25;
					end if;

				when stWRALL26 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stWRALL27;										--R

				when stWRALL27 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stWRALL28;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stWRALL27;									--R
					end if;															--R

				when stWRALL28 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL29;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL28;										    --R
					end if;															--R

				when stWRALL29 =>													--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--

					if wb_dat_o(7) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL31;											--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st <= stWRALL29;												--R
					end if;-----------------------------------------------------------R

				--LSDB set--
				when stWRALL31 =>
					s_wb_adr_i	<=	"011";
					s_wb_dat_i	<=	data(3 downto 0) & "0000";		--tranmit adress 0x03					--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';

					st			<= stWRALL32;


				when stWRALL32 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL33;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL32;
					end if;						--

				when stWRALL33 =>				-- 	  CTR address Transmit ------------
					s_wb_adr_i	<=	"100";---------- Command Resister					--
					s_wb_dat_i	<=	"00010000"; --   STA & WR set							--
					s_wb_we_i	<=	'1';											--
					s_wb_stb_i	<=	'0';											--									--
					st			<= stWRALL34;

				--ack confirm
				when stWRALL34 =>
					s_wb_adr_i	<=	s_wb_adr_i;
					s_wb_dat_i	<=	s_wb_dat_i;

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS
						s_wb_we_i	<=	'0';
						s_wb_stb_i	<=	'0';
						st			<= stWRALL35;
					else
						s_wb_we_i	<=	'1';
						s_wb_stb_i	<=	'1';
						st			<=	stWRALL34;
					end if;

				when stWRALL35 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;					--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R
					st			<= stWRALL36;										--R

				when stWRALL36 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;						--R
					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stWRALL37;									--R
					else															--R
						s_wb_we_i	<=	s_wb_we_i;									--R
						s_wb_stb_i	<= '1';											--R
						st			<= stWRALL36;									--R
					end if;					--R

				when stWRALL37 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					--ステータスレジスタの7bit目がACK信号なので、それを読む--
					if wb_dat_o(1) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stWRALL38;												--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stWRALL37;												--R
					end if;-----------------------------------------------------------R

				when stWRALL38 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;		--R

					--ステータスレジスタの7bit目がACK信号なので、それを読む--
					if wb_dat_o(7) = '0' then		-- TIP Transfer in progress		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stSTOP1;												--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R

						st <= stWRALL38;												--R
					end if;-----------------------------------------------------------R


				--Stop condition ---------------------R
				when stSTOP1 =>
					s_wb_adr_i	<=	"100";		--Command Resister					--R
					s_wb_dat_i	<=	"01000000";	--40h Stop condition				--R
					s_wb_we_i	<=	'1';		--WR								--R
					s_wb_stb_i	<=	'0';											--R

					st <= stSTOP2;
					--R
				when stSTOP2 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;										--R

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stSTOP3;									--R
					else															--R
						s_wb_we_i	<=	'1';										--R
						s_wb_stb_i	<=	'1';										--R
						st			<= stSTOP2;									--R
					end if;
					--R
				when stSTOP3 =>													--R
					s_wb_adr_i	<=	"100";		-- I2C Status Resister				--R
					s_wb_dat_i	<=	s_wb_dat_i;										--R
					s_wb_we_i	<=	'0';		--RD								--R
					s_wb_stb_i	<=	'0';											--R

					st <= stSTOP4;
					--R

				when stSTOP4 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;										--R

					if s_wb_ack_o = '1' then		-- ACK from WISHBONE_BUS		--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'0';										--R
						st			<= stSTOP5;									--R
					else															--R
						s_wb_we_i	<=	'0';										--R
						s_wb_stb_i	<=	'1';										--R
						st			<= stSTOP4;									--R
					end if;
					--R

				when stSTOP5 =>													--R
					s_wb_adr_i	<=	s_wb_adr_i;										--R
					s_wb_dat_i	<=	s_wb_dat_i;										--R
					s_wb_we_i	<=	s_wb_we_i;										--R
					s_wb_stb_i	<=	s_wb_stb_i;										--R
					if wb_dat_o(6) = '0' then	-- STOP signal detected(bus busy)	--R

						COMP_FLAG <= '1';

						st <= stIDLE;

					else															--R
						st <= stSTOP5;												--R
					end if;															--R



				when others  =>														--
					s_wb_adr_i	<=	s_wb_adr_i;										--
					s_wb_dat_i	<=	s_wb_dat_i;										--
					s_wb_we_i	<=	'0';											--
					s_wb_stb_i	<=	'0';											--

					st  		<= stIDLE;

				end case;
		end if;

end process;

end RTL;
