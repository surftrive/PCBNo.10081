----------------------------------------------------------------------------------------------------
--File Name	: SP0565.vhd
--Project	: S127M(S3IO)
--Date		: 2026.03.17
--Ver		: 00_00
--Doc		: New Release
--			: S127M PCB No.10089
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

library WORK ;
	use WORK.w_pack.all;

------------------------entity----------------------------------------------------------------------
entity SP0565 is
	port(
		-- System --
		CLK20M			: in	std_logic; 								-- Slave Clock 20MHZ
		PORb			: in	std_logic; 								-- Power On Reset
		-- Slave Address --
		SLVADR			: in	std_logic_vector( 7 downto 0);			-- Slave Address
		-- S3IO Interface --
		UP_CLK			: in	std_logic; 								-- up link CLK port(+)
		UP_RXD			: in	std_logic; 								-- up link RX port(+)
		UP_TXD			: out	std_logic; 								-- up link TX port(+)
		SLV_ER			: out	std_logic; 								-- Sleave Error alm
		-- eFuse
		PW_PLS_ON		: out	std_logic;								-- '1' = P12V_PLS/D5V_PLSSNS ON
		PW_SV_ON		: out	std_logic;								-- '1' = P12V_SV ON
		PW_PUMP_ON		: out	std_logic;								-- '1' = P12V_PUMP ON
		PW_LMT_ON		: out	std_logic;								-- '1' = D5V_LMT ON
		PW_SNSLED_ON	: out	std_logic;								-- '1' = D5V_SNSLED ON
		nFLT_PLS		: in	std_logic; 								--
		nFLT_PLSSNS		: in	std_logic; 								--
		nFLT_SV			: in	std_logic; 								--
		nFLT_PUMP		: in	std_logic; 								--
		nFLT_LMT		: in	std_logic; 								--
		nFLT_SNSLED		: in	std_logic; 								--
		-- STM
		STM_PCK			: out	std_logic_vector(c_STM_CH downto 1);	-- STM Drive Pulse
		STM_nSLP		: out	std_logic;								--
		STM_EN			: out	std_logic;								--
		STM_DIR			: out	std_logic;								--
		STM_M0S			: out	std_logic;								--
		STM_M0Z			: out	std_logic;								--
		STM_M1			: out	std_logic;								--
		STM_SYNCb		: out	std_logic;								--
		STM_SCLK		: out	std_logic;								--
		STM_MOSI		: out	std_logic;								--
		STM_nFAULT		: in	std_logic_vector(c_STM_CH downto 1);
		-- PLT
		PLT_EN			: out	std_logic;								--
		PLT_ON			: out	std_logic;								--
		PLT_SYNCb		: out	std_logic;								--
		PLT_SCLK		: out	std_logic;								--
		PLT_MOSI		: out	std_logic;								--
		nFLT_PLT		: in	std_logic; 								--
		-- Thermistor(ADC128S022) IF
		ADC_nCS			: out	std_logic;								-- SPI Chip Select
		ADC_SCK			: out	std_logic;								-- SPI CLOCK
		ADC_MOSI		: out	std_logic;								-- SPI Sirial DATA OUT
		ADC_MISO		: in	std_logic;								-- SPI Sirial DATA In
		-- Parallel IO
		STM_LCW			: in	std_logic_vector(c_STM_CH downto 1);	-- 
		STM_LCCW		: in	std_logic_vector(c_STM_CH downto 1);	-- 
		SNS				: in	std_logic_vector(c_SNS_CH downto 1);	-- 
		PLS_SNS			: in	std_logic_vector(c_PLS_CH downto 1);	-- 
		PTLEDb			: out	std_logic_vector(c_PLS_CH downto 1);	-- 
		ENC_A			: in	std_logic_vector(c_ENC_CH downto 1);	-- 
		ENC_B			: in	std_logic_vector(c_ENC_CH downto 1);	-- 
		ACTb			: out	std_logic_vector(c_ACT_CH downto 1);	--
		PUMPb			: out	std_logic_vector(c_PUM_CH downto 1);	--
		FAN_SNS			: in	std_logic_vector(c_FAN_CH downto 1);	--
		FAN_ON			: out	std_logic_vector(c_FAN_CH downto 1)		-- 
	);
end SP0565;
---------------architecture-------------------------------------------------------------------------
architecture RTL of SP0565 is
-------------- constant ----------------------------------------------------------------------------
constant	c_ALL				: std_logic_vector(c_STM_CH downto 1)		:= (others => '1');
constant	c_cur_2x			: std_logic_vector(c_STM_CH downto 1)		:= (others => '1');	-- 各モータポートの電流Data変換フラグ '1'=DRV8424 / '0'=DRV8452
constant	cn_M0Z				: natural := 2 ;
constant	cn_M0S				: natural := 1 ;
constant	cn_M1S				: natural := 0 ;
constant	ca_STM_M			: ta_DA3( 0 to 7 ) := (	--	(M0Z, M0S, M1S)
	0		=>	B"00_0"	-- full-NC	{MODE0, MODE1}={0, 0}
,	1		=>	B"01_0"	-- half-NC	{MODE0, MODE1}={1, 0}
,	2		=>	B"10_0"	-- 1/2		{MODE0, MODE1}={Z, 0}
,	3		=>	B"00_1"	-- 1/4		{MODE0, MODE1}={0, 1}
,	4		=>	B"01_1"	-- 1/8		{MODE0, MODE1}={1, 1}
,	5		=>	B"10_1"	-- 1/16		{MODE0, MODE1}={Z, 1}
,	others	=>	B"00_0"
) ;
constant	c_PLSLED_WIDTH		: integer 									:= 8;

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_PLL_CLK20M		: std_logic;

signal		s_NSb				: std_logic_vector(15 downto 0)				:= (others => '0');
signal		sa_ND				: ta_DA8(15 downto 0)						:= (others => (others => '0'));
signal		s_LA				: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_LDI				: std_logic_vector(7 downto 0)				:= (others => '0');
signal		s_IDSb				: std_logic;
signal		s_LGSb				: std_logic;
signal		s_LRDb				: std_logic;
signal		s_LWEb				: std_logic;
signal		s_LATCH				: std_logic;
signal		s_LOAD				: std_logic;
signal		s_LRSTb				: std_logic;

signal		s_CKEN500k			: std_logic;
signal		s_CKEN100k			: std_logic;
signal		s_CKEN1k			: std_logic;

signal		s_EFUSE_EN			: std_logic_vector(7 downto 0)				:= (others => '0');
signal		s_EFUSE_nFLT		: std_logic_vector(7 downto 0)				:= (others => '0');
signal		s_STM_nFAULT		: std_logic_vector(7 downto 0)				:= (others => '0');

signal		sa_STM_Cur			: ta_DA8( c_STM_CH downto 1 )				:= (others => (others => '0'));	-- ソフトから書き込まれる電流設定値データ
signal		sa_STM_Cur_o		: ta_DA8( c_STM_CH downto 1 )				:= (others => (others => '0'));	-- DACに出力する電流設定値データ

signal		s_THM01_DATA		: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_THM02_DATA		: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_PRES01_DATA		: std_logic_vector(15 downto 0)				:= (others => '0');
signal		s_PRES02_DATA		: std_logic_vector(15 downto 0)				:= (others => '0');

signal		s_STMDIR			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		s_STM_POUT			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		s_MORE_INH_CW		: std_logic_vector(c_STM_CH downto 1 )		:= (others => '0');
signal		s_MORE_INH_CCW		: std_logic_vector(c_STM_CH downto 1 )		:= (others => '0');
signal		s_STM_STOP			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		sa_STM_MPO_A		: ta_DA8(c_STM_CH downto 1);
signal		sa_STM_MPO_B		: ta_DA8(c_STM_CH downto 1);
signal		sa_STM_M			: ta_DA3(c_STM_CH downto 1);
signal		s_STM_ENB			: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');
signal		s_STM_nSLP			: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');
signal		s_STM_M				: std_logic_vector( 2 downto 0);

signal		s_STM_LMT			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_ACT_ONb			: std_logic_vector( 7 downto 0)				:= "11001111";
signal		s_PLS_SNS_I			: std_logic_vector((c_PLSLED_WIDTH -1) downto 0)	:= (others => '0');
signal		s_PLS_SNS_LT		: std_logic_vector((c_PLSLED_WIDTH -1) downto 0)	:= (others => '0');
signal		s_PLSLED_EN			: std_logic_vector((c_PLSLED_WIDTH -1) downto 0)	:= (others => '0');
signal		s_PLSLEDb			: std_logic_vector((c_PLSLED_WIDTH -1) downto 0)	:= (others => '0');
signal		s_FAN_SNS			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_FAN_ON			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_SNS				: std_logic_vector( 7 downto 0)				:= (others => '0');

signal		s_ENC_EN			: std_logic_vector( 8 downto 1)				:= (others => '0');
signal		s_ENCPHASE			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		sa_ENCDATA			: ta_DA16(c_ENC_CH downto 1)				:= (others => (others => '0'));
signal		s_ENCLMT_EN			: std_logic_vector( 8 downto 1)				:= (others => '0');
signal		sa_ENCLMT_TH		: ta_DA8(c_ENC_CH downto 1)					:= (others => (others => '0'));
signal		s_ENC_INV			: std_logic_vector( 8 downto 1)				:= (others => '0');
signal		s_ENC_LMT_DET		: std_logic_vector( 8 downto 1)				:= (others => '0');
signal		s_ENC_MODE			: std_logic_vector( 7 downto 0)				:= (others => '0');

signal		s_TERM				: std_logic;
signal		s_CH0TC_ENB			: std_logic;
signal		s_NUM				: std_logic_vector(2 downto 0);
signal		s_NEG				: std_logic;
signal		s_ENB				: std_logic;
signal		s_PDATA				: std_logic_vector(9 downto 0);
signal		s_DASEND			: std_logic;
signal		s_SYNC				: std_logic_vector(4 downto 0);

signal		s_SLVADR_L			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_SLVADR_U			: std_logic_vector( 7 downto 0)				:= (others => '0');

---------------component----------------------------------------------------------------------------
-- Slave
component slv_com_top
	port(
		-- System --
		CLKSLV			: in	std_logic;						-- Internal Clock 20MHZ
		CLKBASE			: in	std_logic;						-- Communication Clock 20MHZ
		CLKBASEOUT		: out	std_logic;						-- Communication Clock 20MHZ Out
		RSTb			: in	std_logic;						-- System Reset (active Low)
		-- S3IO Interface --
		UPLINK_Ip		: in	std_logic;						-- up link RX port(+)
		UPLINK_Op		: out	std_logic;						-- up link TX port(+)
		LVCLK_Ip		: in	std_logic;						-- up link CLK port(+)
		UPRX			: out	std_logic;						-- up link RX LED (active Low)
		UPTX			: out	std_logic;						-- up link TX LED (active Low)
		-- Slave Address --
		SLVADR			: in	std_logic_vector( 7 downto 0);	-- Slave Address
		-- Local BUS --
		NSb				: out	std_logic_vector(15 downto 0);	-- Node Select
		ND_0			: in	std_logic_vector( 7 downto 0);	-- Node0 data bus
		ND_1			: in	std_logic_vector( 7 downto 0);	-- Node1 data bus
		ND_2			: in	std_logic_vector( 7 downto 0);	-- Node2 data bus
		ND_3			: in	std_logic_vector( 7 downto 0);	-- Node3 data bus
		ND_4			: in	std_logic_vector( 7 downto 0);	-- Node4 data bus
		ND_5			: in	std_logic_vector( 7 downto 0);	-- Node5 data bus
		ND_6			: in	std_logic_vector( 7 downto 0);	-- Node6 data bus
		ND_7			: in	std_logic_vector( 7 downto 0);	-- Node7 data bus
		ND_8			: in	std_logic_vector( 7 downto 0);	-- Node8 data bus
		ND_9			: in	std_logic_vector( 7 downto 0);	-- Node9 data bus
		ND_10			: in	std_logic_vector( 7 downto 0);	-- Node10 data bus
		ND_11			: in	std_logic_vector( 7 downto 0);	-- Node11 data bus
		ND_12			: in	std_logic_vector( 7 downto 0);	-- Node12 data bus
		ND_13			: in	std_logic_vector( 7 downto 0);	-- Node13 data bus
		ND_14			: in	std_logic_vector( 7 downto 0);	-- Node14 data bus
		ND_15			: in	std_logic_vector( 7 downto 0);	-- Node15 data bus
		LA				: out	std_logic_vector(11 downto 0);	-- Local Address bus
		LDI				: out	std_logic_vector( 7 downto 0);	-- Local data bus
		IDSb			: out	std_logic;						-- ID Select (active Low)
		LGSb			: out	std_logic;						-- LOG Select (active Low)
		LRDb			: out	std_logic;						-- Local Read (active Low)
		LWEb			: out	std_logic;						-- Local Write (active Low)
		LATCH			: out	std_logic;						-- Latch Signal (active High)
		LOAD			: out	std_logic;						-- Load Signal (active High)
		LRSTb			: out	std_logic;						-- Local Reset (active Low)
		-- for TEST --
		CLK_RSTb_OUT	: out	std_logic;						-- SLV RESET
		CLKCOM_OUT		: out	std_logic;						-- PLL Output Clock(100MHz)
		LOCKED			: out	std_logic						-- PLL locked signal
	);
end component;

-- CLK generate
component slv_clk_gen
	port(
		RSTb				: in	std_logic;		-- power on reset
		CLK_BASE_20M		: in	std_logic;		-- Clock 20MHZ

		CLK500k				: out	std_logic;		-- Clock 500kHz
		CLK_EN_1k			: out	std_logic;		-- Clock ENABLE 1k
		CLK_EN_100k		: out	std_logic;		-- Clock ENABLE 100k
		CLK_EN_500k			: out	std_logic;		-- Clock ENABLE 500k
		CLK_EN_5M			: out	std_logic		-- Clock ENABLE 5M
	);
end component;

-- DAC(DAC081S101)
component DAC081S101_top
	port(
		CLK			: in	std_logic;						-- 20MHz CLK
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		P_DATA		: in	std_logic_vector(7 downto 0);	-- DATA
		SCLK		: out	std_logic;						-- OUTPUT to DAC(2.5MHz)
		SYNC		: out	std_logic;						-- OUTPUT to DAC
		DO			: out	std_logic						-- OUTPUT to DAC
	);
end component;

-- ADC(ADC128S022)
component ad_ctrl is
	port(
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;

		ADDATA01 	: out	std_logic_vector (11 downto 0);	-- AD Data #1
		ADDATA02 	: out	std_logic_vector (11 downto 0);	-- AD Data #2
		ADDATA03 	: out	std_logic_vector (11 downto 0);	-- AD Data #3
		ADDATA04 	: out	std_logic_vector (11 downto 0);	-- AD Data #4
		ADDATA05 	: out	std_logic_vector (11 downto 0);	-- AD Data #5
		ADDATA06 	: out	std_logic_vector (11 downto 0);	-- AD Data #6
		ADDATA07 	: out	std_logic_vector (11 downto 0);	-- AD Data #7
		ADDATA08 	: out	std_logic_vector (11 downto 0);	-- AD Data #8
		
		ADC_nCS 	: out	std_logic;	-- ADC(ADC128S022) Chip Select
		ADC_SCK 	: out	std_logic;	-- ADC(ADC128S022) Clock
		ADC_SDO 	: out	std_logic;	-- ADC(ADC128S022) Serial Data Output (MOSI)
		ADC_SDI 	: in	std_logic		-- ADC(ADC128S022) Serial Data Input (MISO)
	);
end component;

-- ENC count & limit
component enc_func_top
	port(
		-- Local Bus --
		CLK		 		: in	std_logic;	 					-- Clock 20MHZ
		LRSTb			: in	std_logic;	 					-- Local Reset (active Low)
		-- Encoder
		ENC_A			: in	std_logic_vector(c_ENC_CH downto 1); 
		ENC_B			: in	std_logic_vector(c_ENC_CH downto 1);
		-- GPIO I/F
		ENC_EN			: in	std_logic_vector(c_ENC_CH downto 1);
		ENCDATA			: out	ta_DA16(c_ENC_CH downto 1);				-- Enc count data
		ENCLMT_EN		: in	std_logic_vector(c_ENC_CH downto 1);	-- ENCLMT Enable
		ENCLMT_TH		: in	ta_DA8(c_ENC_CH downto 1); 				-- ENCLMT Threshold
		ENC_INV			: in	std_logic_vector(c_ENC_CH downto 1);	-- enc invert
		ENC_MODE		: in	std_logic_vector(1 downto 0);
		ENC_LMT_DET 	: out	std_logic_vector(c_ENC_CH downto 1);	-- enc error limit register out
		ENCPHASE		: out	std_logic_vector((2 * c_ENC_CH - 1) downto 0);
		--ppmc I/F
		STM_STOP		: in	std_logic_vector(c_ENC_CH downto 1);	-- state of STM 0:stop 1:operate
		STM_M			: in	ta_DA3(c_STM_CH downto 1);				-- extension mode of STM
		STMDIR			: in	std_logic_vector(c_STM_CH downto 1);	-- rotate direction of STM
		STM_POUT		: in	std_logic_vector(c_STM_CH downto 1);	-- stm pulse signal
		MORE_INH_CW		: out	std_logic_vector(c_STM_CH downto 1);
		MORE_INH_CCW	: out	std_logic_vector(c_STM_CH downto 1)
	);
end component;

-- Pulse sens I/O
component pulse_sens
	generic(
		gLEN	: integer := 8								-- num of LED (>=2)
	);
	port(
		nRST	: in	std_logic;							-- Local Reset			(active Low)
		CLK		: in	std_logic;							-- Clock
		CKEN	: in	std_logic;							-- Clock Enable 100kHz		(Active High 1clk)
		LED_O	: out	std_logic_vector(gLEN-1 downto 0);	-- IR-LED Pulse output		(Active Low)
		LED_EN	: in	std_logic_vector(gLEN-1 downto 0);	-- Pulse Enable			(Active High)
		SNS_I	: in	std_logic_vector(gLEN-1 downto 0);	-- Sensor Signal In		(Active High)
		SNS_LT	: out	std_logic_vector(gLEN-1 downto 0);	-- Sensor Signal out(Latched)	(Active High)
		TEST	: out	std_logic_vector(gLEN-1 downto 0)	-- for debug
	);
end component;

-- Peltier Linear Control
component linear_signal_ctrl
	port(
		CLK			: in std_logic;											-- Clock 20MHZ
		LRSTb		: in std_logic;											-- Local Reset (active Low)
		TERM		: in std_logic;											-- CLK210ms/8
		NUM			: in std_logic_vector(2 downto 0);						-- Number of Pulse (1/8-8/8)
		NEG         : in std_logic;											-- Negative signal of subtract value (Measure - target)
		ENB			: in std_logic;											-- Enable signal of temp ctrl
		START		: in std_logic;											-- Start signal of temp ctrl from IPU
		D1			: in std_logic_vector(9 downto 0)	:= "1011011010";	-- DATA1 : 730 (4.55V)
		D2			: in std_logic_vector(9 downto 0)	:= "0011110000";	-- DATA2 : 240 (7V)
		D3			: in std_logic_vector(9 downto 0)	:= "0010001110";	-- DATA3 : 142 (9.5V)
		D4			: in std_logic_vector(9 downto 0)	:= "0001100100";	-- DATA4 : 100 (12V)
		D5			: in std_logic_vector(9 downto 0)	:= "0001001101";	-- DATA5 :  77 (14.5V)
		D6			: in std_logic_vector(9 downto 0)	:= "0000111110";	-- DATA6 :  62 (17V)
		D7			: in std_logic_vector(9 downto 0)	:= "0000110100";	-- DATA7 :  52 (19.4V)
		D8			: in std_logic_vector(9 downto 0)	:= "0000101100";	-- DATA8 :  44 (22V)
		DC_ENB		: out std_logic;										-- Enable DC-DC converter
		EF_ENB		: out std_logic;										-- Enable e-FUSE (Drive peltier)
		P_DATA		: out std_logic_vector(9 downto 0);						-- Data for Digital potentiometer
		DA_SEND     : out std_logic											-- Data Send Trigger
	);
end component;

-- Digital Potentiometer(AD5270)
component ad5270_5271_ctrl
	port(
		CLK			: in	std_logic;						-- 20MHz CLK
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		DATA0		: in	std_logic_vector(9 downto 0);	-- DATA0
		DATA1		: in	std_logic_vector(9 downto 0);	-- DATA1
		DATA2		: in	std_logic_vector(9 downto 0);	-- DATA2
		DATA3		: in	std_logic_vector(9 downto 0);	-- DATA3
		DATA4		: in	std_logic_vector(9 downto 0);	-- DATA4
		DA_SEND		: in	std_logic_vector(4 downto 0);	-- Data Send Trigger
		SCLK		: out	std_logic;						-- Serial clock (Fall edge enable)
		SYNC		: out	std_logic_vector(4 downto 0);	-- Chip select (active Low)
		DO			: out	std_logic						-- Serial Data Output
	);
end component;

-- GPIO
component gpio_top
	port(
		-- Local Bus --
		CLK			: in	std_logic;						-- Clock 20MHZ
		LA			: in	std_logic_vector(4 downto 0);	-- Local Address bus
		NSb			: in	std_logic;						-- Node Select (active Low)
		IDSb		: in	std_logic;						-- ID Select (active Low)
		LGSb		: in	std_logic;						-- Log Memory Select (active Low)
		LDI			: in	std_logic_vector(7 downto 0);	-- Local data bus (IN)
		LDO			: out	std_logic_vector(7 downto 0);	-- Local data bus (OUT)
		LRDb		: in	std_logic;						-- Local Read (active Low)
		LWEb		: in	std_logic;						-- Local Write (active Low)
		LATCH		: in	std_logic;						-- Latch Signal (active High)
		LOAD		: in	std_logic;						-- Load Signal (active High)
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		LATCH_OUT	: out	std_logic;						-- Decoded Latch Signal
		LOAD_OUT	: out	std_logic;						-- Decoded Load Signal
		-- GPIO --
		GPI_0		: in	std_logic_vector(7 downto 0);
		GPI_1		: in	std_logic_vector(7 downto 0);
		GPI_2		: in	std_logic_vector(7 downto 0);
		GPI_3		: in	std_logic_vector(7 downto 0);
		GPI_4		: in	std_logic_vector(7 downto 0);
		GPI_5		: in	std_logic_vector(7 downto 0);
		GPI_6		: in	std_logic_vector(7 downto 0);
		GPI_7		: in	std_logic_vector(7 downto 0);
		GPI_8		: in	std_logic_vector(7 downto 0);
		GPI_9		: in	std_logic_vector(7 downto 0);
		GPI_10		: in	std_logic_vector(7 downto 0);
		GPI_11		: in	std_logic_vector(7 downto 0);
		GPI_12		: in	std_logic_vector(7 downto 0);
		GPI_13		: in	std_logic_vector(7 downto 0);
		GPI_14		: in	std_logic_vector(7 downto 0);
		GPI_15		: in	std_logic_vector(7 downto 0);
		GPI_16		: in	std_logic_vector(7 downto 0);
		GPI_17		: in	std_logic_vector(7 downto 0);
		GPI_18		: in	std_logic_vector(7 downto 0);
		GPI_19		: in	std_logic_vector(7 downto 0);
		GPI_20		: in	std_logic_vector(7 downto 0);
		GPI_21		: in	std_logic_vector(7 downto 0);
		GPI_22		: in	std_logic_vector(7 downto 0);
		GPI_23		: in	std_logic_vector(7 downto 0);
		GPI_24		: in	std_logic_vector(7 downto 0);
		GPI_25		: in	std_logic_vector(7 downto 0);
		GPI_26		: in	std_logic_vector(7 downto 0);
		GPI_27		: in	std_logic_vector(7 downto 0);
		GPI_28		: in	std_logic_vector(7 downto 0);
		GPI_29		: in	std_logic_vector(7 downto 0);
		GPI_30		: in	std_logic_vector(7 downto 0);
		GPI_31		: in	std_logic_vector(7 downto 0);
		GPO_0		: out	std_logic_vector(7 downto 0);
		GPO_1		: out	std_logic_vector(7 downto 0);
		GPO_2		: out	std_logic_vector(7 downto 0);
		GPO_3		: out	std_logic_vector(7 downto 0);
		GPO_4		: out	std_logic_vector(7 downto 0);
		GPO_5		: out	std_logic_vector(7 downto 0);
		GPO_6		: out	std_logic_vector(7 downto 0);
		GPO_7		: out	std_logic_vector(7 downto 0);
		GPO_8		: out	std_logic_vector(7 downto 0);
		GPO_9		: out	std_logic_vector(7 downto 0);
		GPO_10		: out	std_logic_vector(7 downto 0);
		GPO_11		: out	std_logic_vector(7 downto 0);
		GPO_12		: out	std_logic_vector(7 downto 0);
		GPO_13		: out	std_logic_vector(7 downto 0);
		GPO_14		: out	std_logic_vector(7 downto 0);
		GPO_15		: out	std_logic_vector(7 downto 0);
		GPO_16		: out	std_logic_vector(7 downto 0);
		GPO_17		: out	std_logic_vector(7 downto 0);
		GPO_18		: out	std_logic_vector(7 downto 0);
		GPO_19		: out	std_logic_vector(7 downto 0);
		GPO_20		: out	std_logic_vector(7 downto 0);
		GPO_21		: out	std_logic_vector(7 downto 0);
		GPO_22		: out	std_logic_vector(7 downto 0);
		GPO_23		: out	std_logic_vector(7 downto 0);
		GPO_24		: out	std_logic_vector(7 downto 0);
		GPO_25		: out	std_logic_vector(7 downto 0);
		GPO_26		: out	std_logic_vector(7 downto 0);
		GPO_27		: out	std_logic_vector(7 downto 0);
		GPO_28		: out	std_logic_vector(7 downto 0);
		GPO_29		: out	std_logic_vector(7 downto 0);
		GPO_30		: out	std_logic_vector(7 downto 0);
		GPO_31		: out	std_logic_vector(7 downto 0)
	);
end component;

--compact ppmc
component ppmc_top_S118M
	port(
		-- Local Bus --
		CLK				: in	std_logic;						-- Clock 20MHZ
		LA				: in	std_logic_vector(4 downto 0);	-- Local Address bus
		NSb				: in	std_logic;						-- Node Select (active Low)
		IDSb			: in	std_logic;						-- ID Select (active Low)
		LGSb			: in	std_logic;						-- Log Memory Select (active Low)
		LDI				: in	std_logic_vector(7 downto 0);	-- Local data bus (IN)
		LDO				: out	std_logic_vector(7 downto 0);	-- Local data bus (OUT)
		LRDb			: in	std_logic;						-- Local Read (active Low)
		LWEb			: in	std_logic;						-- Local Write (active Low)
		LATCH			: in	std_logic;						-- Latch Signal (active High)
		LOAD			: in	std_logic;						-- Load Signal (active High)
		LRSTb			: in	std_logic;						-- Local Reset (active Low)
		-- PPMC --
		MCLK			: in	std_logic;						-- Clock 500kHZ
		KCLK			: in	std_logic;						-- Clock 1kHZ
		POUT			: out	std_logic;						-- Pulse Out
		DIR				: out	std_logic;						-- direction 	0:CW	1:CCW
		CURRENT_DOWN	: out	std_logic;						-- CURRENT_DOWN 0:UP	1:DOWN
		S1				: out	std_logic;						-- Phase A
		S2				: out	std_logic;						-- Phase B
		S3				: out	std_logic;						-- Phase A/
		S4				: out	std_logic;						-- Phase B/
		LCW				: in	std_logic;						-- CW Limit
		LCCW			: in	std_logic;						-- CCW Limit
		MORE_INH_CW		: in	std_logic;						-- More Drive Inhibit CW
		MORE_INH_CCW	: in	std_logic;						-- More Drive Inhibit CCW
		PLS0_STOP_INH	: in	std_logic;						-- Pulse zero stop Inhibit
		MPI				: in	std_logic_vector(7 downto 0);	-- pararell data input
		MPO_A			: out	std_logic_vector(7 downto 0);	-- pararell data output
		MPO_B			: out	std_logic_vector(7 downto 0);	-- pararell data output
		SSEL			: in	std_logic;						--
		MSEL			: in	std_logic_vector(3 downto 1);	--
		M				: out	std_logic_vector(3 downto 1);	--
		LIMIT_LOGIC		: out	std_logic_vector(1 downto 0);
		START_STOP		: out	std_logic
	);
end component;

--TMPCTRL
component tmpctrl_4ch_top_S127M
	port(
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		NSb			: in	std_logic;
		IDSb		: in	std_logic;
		LGSb		: in	std_logic;
		LATCH		: in	std_logic;
		LOAD		: in	std_logic;
		LA			: in	std_logic_vector( 4 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LDI			: in	std_logic_vector( 7 downto 0);
		LDO			: out	std_logic_vector( 7 downto 0);
		CKEN1k		: in	std_logic;
		TEMP0_DATA	: in	std_logic_vector(11 downto 0);
		TEMP1_DATA	: in	std_logic_vector(11 downto 0);
		TEMP2_DATA	: in	std_logic_vector(11 downto 0);
		TEMP3_DATA	: in	std_logic_vector(11 downto 0);
		CLON		: out	std_logic_vector( 3 downto 0);
		CLP			: out	std_logic_vector( 3 downto 0);
		HTON		: out	std_logic_vector( 3 downto 0);
		HTP			: out	std_logic_vector( 3 downto 0);
		CLPORHTPhf	: out	std_logic_vector( 3 downto 0);
		CLPORHTP	: out	std_logic_vector( 3 downto 0);
		TERM		: out	std_logic;						-- Terminal Signal
		CH0TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH0
		CH1TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH1
		CH2TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH2
		CH3TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH3
		NUM		 	: out	std_logic_vector(2 downto 0);	-- Number of Pulse (1/8-8/8)
		NEG		 	: out	std_logic;						-- Negative signal of subtract value (Measure - target)
		ENB		 	: out	std_logic						-- Enable signal of temp ctrl
	);
end component;

component slaveid_top
	port(
		-- Local Bus --
		CLK			: in	std_logic;						-- Clock 20MHZ
		LA			: in	std_logic_vector(4 downto 0);	-- Local Address bus
		NSb			: in	std_logic;						-- Node Select (active Low)
		IDSb		: in	std_logic;						-- ID Select (active Low)
		LGSb		: in	std_logic;						-- Log Memory Select (active Low)
		LDI			: in	std_logic_vector(7 downto 0);	-- Local data bus (IN)
		LDO			: out	std_logic_vector(7 downto 0);	-- Local data bus (OUT)
		LRDb		: in	std_logic;						-- Local Read (active Low)
		LWEb		: in	std_logic;						-- Local Write (active Low)
		LATCH		: in	std_logic;						-- Latch Signal (active High)
		LOAD		: in	std_logic;						-- Load Signal (active High)
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		-- GPIO --
		GPI_0		: in	std_logic_vector(7 downto 0);
		GPI_1		: in	std_logic_vector(7 downto 0);
		GPI_2		: in	std_logic_vector(7 downto 0);
		GPI_3		: in	std_logic_vector(7 downto 0);
		GPI_4		: in	std_logic_vector(7 downto 0);
		GPI_5		: in	std_logic_vector(7 downto 0);
		GPI_6		: in	std_logic_vector(7 downto 0);
		GPI_7		: in	std_logic_vector(7 downto 0);
		GPI_8		: in	std_logic_vector(7 downto 0);
		GPI_9		: in	std_logic_vector(7 downto 0);
		GPI_10		: in	std_logic_vector(7 downto 0);
		GPI_11		: in	std_logic_vector(7 downto 0);
		GPI_12		: in	std_logic_vector(7 downto 0);
		GPI_13		: in	std_logic_vector(7 downto 0);
		GPI_14		: in	std_logic_vector(7 downto 0);
		GPI_15		: in	std_logic_vector(7 downto 0);
		GPI_16		: in	std_logic_vector(7 downto 0);
		GPI_17		: in	std_logic_vector(7 downto 0);
		GPI_18		: in	std_logic_vector(7 downto 0);
		GPI_19		: in	std_logic_vector(7 downto 0);
		GPI_20		: in	std_logic_vector(7 downto 0);
		GPI_21		: in	std_logic_vector(7 downto 0);
		GPI_22		: in	std_logic_vector(7 downto 0);
		GPI_23		: in	std_logic_vector(7 downto 0);
		GPI_24		: in	std_logic_vector(7 downto 0);
		GPI_25		: in	std_logic_vector(7 downto 0);
		GPI_26		: in	std_logic_vector(7 downto 0);
		GPI_27		: in	std_logic_vector(7 downto 0);
		GPI_28		: in	std_logic_vector(7 downto 0);
		GPI_29		: in	std_logic_vector(7 downto 0);
		GPI_30		: in	std_logic_vector(7 downto 0);
		GPI_31		: in	std_logic_vector(7 downto 0)
	);
end component;

-------------------- begin	-------------------------------------------------------------------------
begin

	s_SLVADR_L	<= "0011" & SLVADR(7 downto 4);
	s_SLVADR_U	<= "0011" & SLVADR(3 downto 0);

	PW_PLS_ON		<= s_EFUSE_EN(0);
	PW_SV_ON		<= s_EFUSE_EN(1);
	PW_PUMP_ON		<= s_EFUSE_EN(2);
	PW_LMT_ON		<= s_EFUSE_EN(3);
	PW_SNSLED_ON	<= s_EFUSE_EN(4);

	s_EFUSE_nFLT(0)	<= nFLT_PLS;
	s_EFUSE_nFLT(1)	<= nFLT_PLSSNS;
	s_EFUSE_nFLT(2)	<= nFLT_SV;
	s_EFUSE_nFLT(3)	<= nFLT_PUMP;
	s_EFUSE_nFLT(4)	<= nFLT_LMT;
	s_EFUSE_nFLT(5)	<= nFLT_SNSLED;
	s_EFUSE_nFLT(6)	<= nFLT_PLT;

	s_STM_nFAULT(0) <= STM_nFAULT(1);

	STM_GEN : for index in	1 to c_STM_CH generate
		s_STM_LMT(2 * (index - 1))		<= STM_LCW(index);
		s_STM_LMT(2 * (index - 1) + 1)	<= STM_LCCW(index);
		s_STM_ENB(index)				<= sa_STM_MPO_A(index)(0);
		s_STM_nSLP(index)				<= sa_STM_MPO_A(index)(1);
	end generate STM_GEN;

	STM_CUR : for index in 1 to c_STM_CH generate
		sa_STM_Cur_o(index) <=	X"FF"								when (c_cur_2x(index) = '1' and sa_STM_Cur(index) > X"7F" ) else
								sa_STM_Cur(index)(6 downto 0) & '0'	when (c_cur_2x(index) = '1') 								else
								sa_STM_Cur(index);
	end generate STM_CUR;

	s_STM_M		<= ca_STM_M( conv_integer( sa_STM_M(1) ) ) ;
	
	STM_PCK		<= s_STM_POUT;
	STM_nSLP	<= s_STM_nSLP(1);
	STM_EN		<= s_STM_ENB(1);
	STM_DIR		<= s_STMDIR(1);
	STM_M0S		<= s_STM_M(cn_M0S);
	STM_M0Z		<= s_STM_M(cn_M0Z);
	STM_M1		<= s_STM_M(cn_M1S);

	ACTb	<= s_ACT_ONb(5 downto 0);
	PUMPb	<= s_ACT_ONb(7 downto 6);

	PTLEDb	<= not( s_PLSLEDb((c_PLS_CH - 1) downto 0) );

	s_SNS((c_SNS_CH - 1) downto 0)		<= SNS;
	s_PLS_SNS_I((c_PLS_CH-1) downto 0)	<= not(PLS_SNS);
	s_FAN_SNS((c_FAN_CH - 1) downto 0)	<= FAN_SNS;
	
	FAN_ON	<= s_FAN_ON((c_FAN_CH - 1) downto 0);

	PLT_SYNCb	<= s_SYNC(0);

-- Slave ---------------------------------------------------------------------
	slv_com: slv_com_top port map (
		-- System --
		CLKSLV			=> CLK20M,
		CLKBASE 		=> UP_CLK,
		CLKBASEOUT		=> s_PLL_CLK20M,
		RSTb			=> PORb,
		-- S3IO Interface --
		UPLINK_Ip		=> UP_RXD,
		UPLINK_Op		=> UP_TXD,
		LVCLK_Ip		=> s_PLL_CLK20M,
		UPRX			=> open,
		UPTX			=> open,
		-- Slave Address --
		SLVADR			=> SLVADR,
		-- Local BUS --
		NSb				=> s_NSb,
		ND_0			=> sa_ND( 0),
		ND_1			=> sa_ND( 1),
		ND_2			=> sa_ND( 2),
		ND_3			=> sa_ND( 3),
		ND_4			=> sa_ND( 4),
		ND_5			=> sa_ND( 5),
		ND_6			=> sa_ND( 6),
		ND_7			=> sa_ND( 7),
		ND_8			=> sa_ND( 8),
		ND_9			=> sa_ND( 9),
		ND_10			=> sa_ND(10),
		ND_11			=> sa_ND(11),
		ND_12			=> sa_ND(12),
		ND_13			=> sa_ND(13),
		ND_14			=> sa_ND(14),
		ND_15			=> sa_ND(15),
		LA				=> s_LA,
		LDI				=> s_LDI,
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- for TEST --
		CLK_RSTb_OUT	=> open,
		CLKCOM_OUT		=> open,
		LOCKED			=> open
	);

-- clk generate ---------------------------------------------------------------------
	CLK_gen_inst : slv_clk_gen port map (
		RSTb			=> s_LRSTb,
		CLK_BASE_20M	=> s_PLL_CLK20M,

		CLK500k			=> open,
		CLK_EN_1k		=> s_CKEN1k,
		CLK_EN_100k		=> s_CKEN100k,
		CLK_EN_500k		=> s_CKEN500k,
		CLK_EN_5M		=> open
	);

-- DAC081S101 ---------------------------------------------------------------------
	DAC081S101_inst: DAC081S101_top PORT MAP (
		CLK				=> s_PLL_CLK20M,
		LRSTb			=> s_LRSTb,
		P_DATA			=> sa_STM_CUR_o(1),
		SCLK			=> STM_SCLK,
		SYNC			=> STM_SYNCb,
		DO				=> STM_MOSI
	);

-- ADC control ---------------------------------------------------------------------
	ADC_CONT : ad_ctrl port map(
		CLK			=> s_PLL_CLK20M,
		LRSTb		=> s_LRSTb,

		ADDATA01	=> s_THM01_DATA,
		ADDATA02	=> s_THM02_DATA,
		ADDATA03	=> s_PRES01_DATA(11 downto 0),
		ADDATA04	=> s_PRES02_DATA(11 downto 0),
		ADDATA05	=> open,
		ADDATA06	=> open,
		ADDATA07	=> open,
		ADDATA08	=> open,

		ADC_nCS		=> ADC_nCS,
		ADC_SCK		=> ADC_SCK,
		ADC_SDO		=> ADC_MOSI,
		ADC_SDI		=> ADC_MISO	
	);

-- Encorder count & limit ---------------------------------------------------------------------
	ENC_inst : enc_func_top port map (
		-- Local Bus --
		CLK		 		=> s_PLL_CLK20M,
		LRSTb			=> s_LRSTb,
		-- Encoder
		ENC_A			=> ENC_A,
		ENC_B			=> ENC_B,
		-- GPIO I/F
		ENC_EN			=> s_ENC_EN(c_ENC_CH downto 1),
		ENCDATA			=> sa_ENCDATA,
		ENCLMT_EN		=> s_ENCLMT_EN(c_ENC_CH downto 1),
		ENCLMT_TH		=> sa_ENCLMT_TH,
		ENC_INV			=> s_ENC_INV(c_ENC_CH downto 1),
		ENC_MODE		=> s_ENC_MODE(1 downto 0),
		ENC_LMT_DET 	=> s_ENC_LMT_DET(c_ENC_CH downto 1),
		ENCPHASE		=> s_ENCPHASE((2 * c_ENC_CH - 1) downto 0),
		--ppmc I/F
		STM_STOP		=> s_STM_STOP,
		STM_M			=> sa_STM_M,
		STMDIR			=> s_STMDIR,
		STM_POUT		=> s_STM_POUT,
		MORE_INH_CW		=> s_MORE_INH_CW,
		MORE_INH_CCW	=> s_MORE_INH_CCW
	);

-- PLS SNS ---------------------------------------------------------------------
	pulse_sensor :pulse_sens
	generic map(
		gLEN	=>	c_PLSLED_WIDTH		-- num of LED (>=2)
	)
	port map(
		nRST		=> s_LRSTb,
		CLK			=> s_PLL_CLK20M,
		CKEN		=> s_CKEN100k,
		LED_O		=> s_PLSLEDb,
		LED_EN		=> s_PLSLED_EN,		-- IN Pulse Emission enable
		SNS_I		=> s_PLS_SNS_I,
		SNS_LT		=> s_PLS_SNS_LT
	);

-- Peltier Linear Control ---------------------------------------------------------------------
	linear_signal_ctrl_inst_ch0 : linear_signal_ctrl port map(
		CLK			=> s_PLL_CLK20M,
		LRSTb		=> s_LRSTb,

		TERM		=> s_TERM,
		NUM			=> s_NUM,
		NEG			=> s_NEG,
		ENB			=> s_ENB,
		START		=> s_CH0TC_ENB,
		D1			=> "0101001010",		-- 330 (6V)
		D2			=> "0011110000",		-- 240 (7V)
		D3			=> "0010001110",		-- 142 (9.5V)
		D4			=> "0001100100",		-- 100 (12V)
		D5			=> "0001001101",		--  77 (14.5V)
		D6			=> "0000111110",		--  62 (17V)
		D7			=> "0000110100",		--  52 (19.4V)
		D8			=> "0000101100",		--  44 (22V)
		DC_ENB		=> PLT_EN,
		EF_ENB		=> PLT_ON,
		P_DATA		=> s_PDATA,
		DA_SEND		=> s_DASEND
	);

-- Digital Potentiometer(AD5270) ---------------------------------------------------------------------
	ad5270_5271_ctrl_inst_ch0 : ad5270_5271_ctrl port map(
		CLK			=> s_PLL_CLK20M,
		LRSTb		=> s_LRSTb,
		DATA0		=> s_PDATA,
		DATA1		=> (others => '0'),
		DATA2		=> (others => '0'),
		DATA3		=> (others => '0'),
		DATA4		=> (others => '0'),
		DA_SEND		=> "0000" & s_DASEND,
		SCLK		=> PLT_SCLK,
		SYNC		=> s_SYNC,
		DO			=> PLT_MOSI
	);
	
-- Node 0 ---------------------------------------------------------------------
	stm01 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(0),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(0),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(1),
		DIR				=> s_STMDIR(1),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(1),
		LCCW			=> STM_LCCW(1),
		MORE_INH_CW		=> s_MORE_INH_CW(1),
		MORE_INH_CCW	=> s_MORE_INH_CCW(1),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(1) & STM_LCW(1) & "00000",
		MPO_A			=> sa_STM_MPO_A(1),
		MPO_B			=> sa_STM_MPO_B(1),
		SSEL			=> sa_STM_MPO_A(1)(2),
		MSEL			=> sa_STM_MPO_B(1)(2 downto 0),
		M				=> sa_STM_M(1),
		LIMIT_LOGIC		=> open,
		START_STOP		=> s_STM_STOP(1)
	);
	
-- Node 1 ---------------------------------------------------------------------
	gpio01 : gpio_top port map (
		-- Local Bus --
		CLK			=> s_PLL_CLK20M,
		LA			=> s_LA(4 downto 0),
		NSb			=> s_NSb(1),
		IDSb		=> s_IDSb,
		LGSb		=> s_LGSb,
		LDI			=> s_LDI,
		LDO			=> sa_ND(1),
		LRDb		=> s_LRDb,
		LWEb		=> s_LWEb,
		LATCH		=> s_LATCH,
		LOAD		=> s_LOAD,
		LRSTb		=> s_LRSTb,
		LATCH_OUT	=> OPEN,
		LOAD_OUT	=> OPEN,
		-- GPIO --
		GPI_0		=> s_SNS,
		GPI_1		=> s_PLS_SNS_LT( 7 downto 0),
		GPI_2		=> s_STM_LMT,
		GPI_3		=> s_FAN_SNS,
		GPI_4		=> s_PRES01_DATA( 7 downto 0),
		GPI_5		=> s_PRES01_DATA(15 downto 8),
		GPI_6		=> s_PRES02_DATA( 7 downto 0),
		GPI_7		=> s_PRES02_DATA(15 downto 8),
		GPI_8		=> s_ENCPHASE( 7 downto 0),
		GPI_9		=> sa_ENCDATA(1)( 7 downto 0),
		GPI_10		=> sa_ENCDATA(1)(15 downto 8),
		GPI_11		=> s_ENC_LMT_DET,
		GPI_12		=> s_EFUSE_nFLT,
		GPI_13		=> s_STM_nFAULT,
		GPI_14		=> oct0,
		GPI_15		=> oct0,
		GPI_16		=> s_ACT_ONb,
		GPI_17		=> s_PLSLED_EN( 7 downto 0),
		GPI_18		=> s_FAN_ON,
		GPI_19		=> s_ENC_EN,
		GPI_20		=> s_ENCLMT_EN,
		GPI_21		=> s_ENC_INV,
		GPI_22		=> sa_ENCLMT_TH(1),
		GPI_23		=> s_ENC_MODE,
		GPI_24		=> sa_STM_CUR(1),
		GPI_25		=> s_EFUSE_EN,
		GPI_26		=> oct0,
		GPI_27		=> oct0,
		GPI_28		=> oct0,
		GPI_29		=> oct0,
		GPI_30		=> oct0,
		GPI_31		=> oct0,

		GPO_0		=> OPEN,
		GPO_1		=> OPEN,
		GPO_2		=> OPEN,
		GPO_3		=> OPEN,
		GPO_4		=> OPEN,
		GPO_5		=> OPEN,
		GPO_6		=> OPEN,
		GPO_7		=> OPEN,
		GPO_8		=> OPEN,
		GPO_9		=> OPEN,
		GPO_10		=> OPEN,
		GPO_11		=> OPEN,
		GPO_12		=> OPEN,
		GPO_13		=> OPEN,
		GPO_14		=> OPEN,
		GPO_15		=> OPEN,
		GPO_16		=> s_ACT_ONb,
		GPO_17		=> s_PLSLED_EN( 7 downto 0),
		GPO_18		=> s_FAN_ON,
		GPO_19		=> s_ENC_EN,
		GPO_20		=> s_ENCLMT_EN,
		GPO_21		=> s_ENC_INV,
		GPO_22		=> sa_ENCLMT_TH(1),
		GPO_23		=> s_ENC_MODE,
		GPO_24		=> sa_STM_CUR(1),
		GPO_25		=> s_EFUSE_EN,
		GPO_26		=> OPEN,
		GPO_27		=> OPEN,
		GPO_28		=> OPEN,
		GPO_29		=> OPEN,
		GPO_30		=> OPEN,
		GPO_31		=> OPEN
	);
	
-- Node 2 --------------------------------------------------------------------
	tmpctrl_4ch : tmpctrl_4ch_top_S127M port map (
		CLK			=> s_PLL_CLK20M,
		LA			=> s_LA(4 downto 0),
		NSb			=> s_NSb(2),
		IDSb		=> s_IDSb,
		LGSb		=> s_LGSb,
		LDI			=> s_LDI,
		LDO			=> sa_ND(2),
		LRDb		=> s_LRDb,
		LWEb		=> s_LWEb,
		LATCH		=> s_LATCH,
		LOAD		=> s_LOAD,
		LRSTb		=> s_LRSTb,

		CKEN1k		=> s_CKEN1k,

		TEMP0_DATA	=> s_THM01_DATA,
		TEMP1_DATA	=> s_THM02_DATA,
		TEMP2_DATA	=> (others => '0'),
		TEMP3_DATA	=> (others => '0'),

		CLON		=> open,
		CLP			=> open,
		HTON		=> open,
		HTP			=> open,
		CLPORHTPhf	=> open,
		CLPORHTP	=> open,

		TERM		=> s_TERM,
		CH0TC_ENB	=> s_CH0TC_ENB,
		CH1TC_ENB	=> open,
		CH2TC_ENB	=> open,
		CH3TC_ENB	=> open,
		NUM			=> s_NUM,
		NEG			=> s_NEG,
		ENB			=> s_ENB
	);
	
-- Node 3 to 14 ---------------------------------------------------------------------
	-- reserved
	sa_ND( 14 downto 3) <= (others => (others => '0'));

-- Node 15 --------------------------------------------------------------------
	node15 : slaveid_top port map (
		-- Local Bus --
		CLK			=> s_PLL_CLK20M,
		LA			=> s_LA(4 downto 0),
		NSb			=> s_NSb(15),
		IDSb		=> s_IDSb,
		LGSb		=> s_LGSb,
		LDI			=> s_LDI,
		LDO			=> sa_ND(15),
		LRDb		=> s_LRDb,
		LWEb		=> s_LWEb,
		LATCH		=> s_LATCH,
		LOAD		=> s_LOAD,
		LRSTb		=> s_LRSTb,
		-- GPIO --
		GPI_0		=> X"49", 				-- ASCII_code	I
		GPI_1		=> X"44",				-- ASCII_code	D
		GPI_2		=> s_SLVADR_U, 			-- Slave ADR Upper
		GPI_3		=> s_SLVADR_L, 			-- Slave ADR Lower
		GPI_4		=> X"4E",				-- ASCII_code	N
		GPI_5		=> X"4F",				-- ASCII_code	O
		GPI_6		=> X"2E",				-- ASCII_code	.
		GPI_7		=> X"31",				-- ASCII_code	1
		GPI_8		=> X"30",				-- ASCII_code	0
		GPI_9		=> X"30",				-- ASCII_code	0
		GPI_10		=> X"38",				-- ASCII_code	8
		GPI_11		=> X"39",				-- ASCII_code	9
		GPI_12		=> X"5F",				-- ASCII_code	_
		GPI_13		=> X"53",				-- ASCII_code	S
		GPI_14		=> X"50",				-- ASCII_code	P
		GPI_15		=> X"30",				-- ASCII_code	0
		GPI_16		=> X"35",				-- ASCII_code	5
		GPI_17		=> X"36",				-- ASCII_code	6
		GPI_18		=> X"35",				-- ASCII_code	5
		GPI_19		=> X"5F",				-- ASCII_code	_
		GPI_20		=> X"56",				-- ASCII_code	V
		GPI_21		=> X"30",				-- ASCII_code	0
		GPI_22		=> X"30",				-- ASCII_code	0
		GPI_23		=> X"5F",				-- ASCII_code	_
		GPI_24		=> X"30",				-- ASCII_code	0
		GPI_25		=> X"30",				-- ASCII_code	0
		GPI_26		=> X"20",				-- ASCII_code
		GPI_27		=> X"20",				-- ASCII_code
		GPI_28		=> X"20",				-- ASCII_code
		GPI_29		=> X"20",				-- ASCII_code
		GPI_30		=> X"20",				-- ASCII_code
		GPI_31		=> X"20"				-- ASCII_code
	);

end RTL;
