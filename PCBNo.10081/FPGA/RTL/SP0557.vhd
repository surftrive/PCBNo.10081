----------------------------------------------------------------------------------------------------
--File Name	: SP0557.vhd
--Project	: S127M(S3IO)
--Date		: 2026.01.28
--Ver		: 02_00
--Doc		: New Release
--			: S127M PCB No.10081
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

library WORK ;
	use WORK.w_pack.all;

------------------------entity----------------------------------------------------------------------
entity SP0557 is
	port(
		-- System --
		CLK20M			: in	std_logic;								-- Slave Clock 20MHZ
		PORb			: in	std_logic;								-- Power On Reset
		-- Slave Address --
		SLVADR			: in	std_logic_vector( 7 downto 0);			-- Slave Address
		-- S3IO Interface --
		UP_CLK			: in	std_logic;								-- up link CLK port(+)
		UP_RXD			: in	std_logic;								-- up link RX port(+)
		UP_TXD			: out	std_logic;								-- up link TX port(+)
		-- Serial to Parallel(SN74AHC595)
		S2P_SCK			: out	std_logic;
		S2P_RCK			: out	std_logic;
		S2P_nOE			: out	std_logic;
		S2P_nCLR		: out	std_logic;
		S2P_SDO			: out	std_logic;
		-- Parallel to Serial(SN74LV165)
		P2S_SCK			: out	std_logic;
		P2S_SLD			: out	std_logic;
		P2S_SDI			: in	std_logic;
		-- DAC(DAC43608)
		STMVREF_SCL		: inout	std_logic;
		STMVREF_SDA		: inout	std_logic;
		-- ADC(ADC128S022)
		ADC_nCS			: out	std_logic;								-- SPI Chip Select
		ADC_SCK			: out	std_logic;								-- SPI CLOCK
		ADC_MOSI		: out	std_logic;								-- SPI Sirial DATA OUT
		ADC_MISO		: in	std_logic;								-- SPI Sirial DATA In
		-- LED SERCH BOARD
		LEDSH_RESETb	: out	std_logic;
		LEDSH_SCK		: out	std_logic;
		LEDSH_nCS		: out	std_logic;
		LEDSH_MOSI		: out	std_logic;
		LEDSH_MISO		: in	std_logic;
		-- LED LIGHT BOARD
		LEDDRV_LE		: out	std_logic;
		LEDDRV_OEb		: out	std_logic;
		LEDDRV_CLK		: out	std_logic;
		LEDDRV_SD		: out	std_logic;
		DPM_CSb			: out	std_logic;
		DPM_CLK			: out	std_logic;
		DPM_SD			: out	std_logic;
		-- STM Drive
		STM_PCK			: out	std_logic_vector(c_STM_CH downto 1);
		-- Parallel IO
		STM_LCW			: in	std_logic_vector(c_STM_CH downto 1);	-- 
		STM_LCCW		: in	std_logic_vector(c_STM_CH downto 1);	-- 
		PLS_SNS			: in	std_logic_vector(c_PLS_CH downto 1);	-- 
		PTLEDb			: out	std_logic_vector(c_PLS_CH downto 1);	-- 
		ENC_A			: in	std_logic_vector(c_ENC_CH downto 1);	-- 
		ENC_B			: in	std_logic_vector(c_ENC_CH downto 1);	-- 
		ACTb			: out	std_logic_vector(c_ACT_CH downto 1);	-- 
		PUMPb			: out	std_logic_vector(c_PUM_CH downto 1)	--
	);
end SP0557;
---------------architecture-------------------------------------------------------------------------
architecture RTL of SP0557 is
-------------- constant ----------------------------------------------------------------------------
constant	c_ALL				: std_logic_vector(c_STM_CH downto 1)		:= (others => '1');

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_PLL_CLK20M		: std_logic;

signal		s_NSb				: std_logic_vector(15 downto 0)				:= (others => '0');
signal		sa_ND				: ta_DA8(15 downto 0)						:= (others => (others => '0'));
signal		s_LA				: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_LDI				: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_IDSb				: std_logic;
signal		s_LGSb				: std_logic;
signal		s_LRDb				: std_logic;
signal		s_LWEb				: std_logic;
signal		s_LATCH				: std_logic;
signal		s_LOAD				: std_logic;
signal		s_LRSTb				: std_logic;

signal		s_CLK500k			: std_logic;
signal		s_CKEN5M			: std_logic;
signal		s_CKEN500k			: std_logic;
signal		s_CKEN1k			: std_logic;

signal		s_PW_SV_EN			: std_logic;
signal		s_PW_PUMP_EN		: std_logic;
signal		s_PW_PLS_EN			: std_logic;
signal		s_PW_LMT_EN			: std_logic;
signal		s_PW_ENC_EN			: std_logic;
signal		s_PW_SNS_EN			: std_logic;
signal		s_PW_SNSLED_EN		: std_logic;
signal		s_PW_PLSSNS_EN		: std_logic;
signal		s_PW_LEDSH_EN		: std_logic;
signal		s_PW_LEDLT_EN		: std_logic;
signal		s_EFUSE_EN			: std_logic_vector(15 downto 0)				:= (others => '0');

signal		s_SNS				: std_logic_vector(16 downto 1);
signal		s_STM_nFAULT		: std_logic_vector(16 downto 1)				:= (others => '0');
signal		s_EFUSE_nFLT		: std_logic_vector(16 downto 1)				:= (others => '0');
signal		s_PW_SV_nFLT		: std_logic;
signal		s_PW_PUMP_nFLT		: std_logic;
signal		s_PW_PLS_nFLT		: std_logic;
signal		s_PW_LMT_nFLT		: std_logic;
signal		s_PW_ENC_nFLT		: std_logic;
signal		s_PW_SNS_nFLT		: std_logic;
signal		s_PW_SNSLED_nFLT	: std_logic;
signal		s_PW_PLSSNS_nFLT	: std_logic;
signal		s_PW_LEDSH_nFLT		: std_logic;
signal		s_PW_LEDLT5V_nFLT	: std_logic;
signal		s_PW_LEDLT3R3V_nFLT	: std_logic;

signal		s_mode_com			: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_mode_out			: std_logic_vector( 7 downto 0)				:= (others => '0');

signal		s_STMDIR			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		s_STM_POUT			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		sa_LIMIT_LOGIC		: ta_DA2(c_STM_CH downto 1)					:= (others => (others => '0'));
signal		s_MORE_INH_CW		: std_logic_vector(c_STM_CH downto 1 )		:= (others => '0');
signal		s_MORE_INH_CCW		: std_logic_vector(c_STM_CH downto 1 )		:= (others => '0');
signal		s_STM_STOP			: std_logic_vector(c_STM_CH downto 1)		:= (others => '0');
signal		sa_STM_MPO_A		: ta_DA8(c_STM_CH downto 1);
signal		sa_STM_MPO_B		: ta_DA8(c_STM_CH downto 1);
signal		sa_STM_M			: ta_DA3(c_STM_CH downto 1);
signal		s_STM_ENB			: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');
signal		s_STM_nSLP			: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');	

signal		sa_STM_Cur			: ta_DA8( c_STM_CH downto 1 )				:= (others => (others => '0'));

signal		s_PRES01_DATA		: std_logic_vector(15 downto 0)				:= (others => '0');
signal		s_PRES02_DATA		: std_logic_vector(15 downto 0)				:= (others => '0');

signal		s_LEDLT_CTRL		: std_logic_vector( 7 downto 0)				:= (others => '0');
signal		s_LED_I_SET			: std_logic_vector( 7 downto 0)				:= (others => '0');

signal		s_ENC_EN			: std_logic_vector(16 downto 1)				:= (others => '0');
signal		s_ENCPHASE			: std_logic_vector(31 downto 0)				:= (others => '0');
signal		sa_ENCDATA			: ta_DA16(c_ENC_CH downto 1)				:= (others => (others => '0'));
signal		s_ENCLMT_EN			: std_logic_vector(16 downto 1)				:= (others => '0');
signal		sa_ENCLMT_TH		: ta_DA8(c_ENC_CH downto 1)					:= (others => (others => '0'));
signal		s_ENC_INV			: std_logic_vector(16 downto 1)				:= (others => '0');
signal		s_ENC_LMT_DET		: std_logic_vector(16 downto 1)				:= (others => '0');
signal		s_ENC_MODE			: std_logic_vector( 7 downto 0)				:= (others => '0');

signal		s_STM_LMT			: std_logic_vector(31 downto 0)				:= (others => '0');
signal		s_ACT_ONb			: std_logic_vector( 7 downto 0)				:= "11001111";
signal		s_PLS_SNS			: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_PLSLED_EN			: std_logic_vector(11 downto 0)				:= (others => '0');
signal		s_PLSLEDb			: std_logic_vector(11 downto 0)				:= (others => '0');

---------------component----------------------------------------------------------------------------
-- Slave
component slv_com_top
	port(
		-- System --
		CLKSLV				: in	std_logic;						-- Internal Clock 20MHZ
		CLKBASE				: in	std_logic;						-- Communication Clock 20MHZ
		CLKBASEOUT			: out	std_logic;						-- Communication Clock 20MHZ Out
		RSTb				: in	std_logic;						-- System Reset (active Low)
		-- S3IO Interface --
		UPLINK_Ip			: in	std_logic;						-- up link RX port(+)
		UPLINK_Op			: out	std_logic;						-- up link TX port(+)
		LVCLK_Ip			: in	std_logic;						-- up link CLK port(+)
		UPRX				: out	std_logic;						-- up link RX LED (active Low)
		UPTX				: out	std_logic;						-- up link TX LED (active Low)
		-- Slave Address --
		SLVADR				: in	std_logic_vector( 7 downto 0);	-- Slave Address
		-- Local BUS --
		NSb					: out	std_logic_vector(15 downto 0);	-- Node Select
		ND_0				: in	std_logic_vector( 7 downto 0);	-- Node0 data bus
		ND_1				: in	std_logic_vector( 7 downto 0);	-- Node1 data bus
		ND_2				: in	std_logic_vector( 7 downto 0);	-- Node2 data bus
		ND_3				: in	std_logic_vector( 7 downto 0);	-- Node3 data bus
		ND_4				: in	std_logic_vector( 7 downto 0);	-- Node4 data bus
		ND_5				: in	std_logic_vector( 7 downto 0);	-- Node5 data bus
		ND_6				: in	std_logic_vector( 7 downto 0);	-- Node6 data bus
		ND_7				: in	std_logic_vector( 7 downto 0);	-- Node7 data bus
		ND_8				: in	std_logic_vector( 7 downto 0);	-- Node8 data bus
		ND_9				: in	std_logic_vector( 7 downto 0);	-- Node9 data bus
		ND_10				: in	std_logic_vector( 7 downto 0);	-- Node10 data bus
		ND_11				: in	std_logic_vector( 7 downto 0);	-- Node11 data bus
		ND_12				: in	std_logic_vector( 7 downto 0);	-- Node12 data bus
		ND_13				: in	std_logic_vector( 7 downto 0);	-- Node13 data bus
		ND_14				: in	std_logic_vector( 7 downto 0);	-- Node14 data bus
		ND_15				: in	std_logic_vector( 7 downto 0);	-- Node15 data bus
		LA					: out	std_logic_vector(11 downto 0);	-- Local Address bus
		LDI					: out	std_logic_vector( 7 downto 0);	-- Local data bus
		IDSb				: out	std_logic;						-- ID Select (active Low)
		LGSb				: out	std_logic;						-- LOG Select (active Low)
		LRDb				: out	std_logic;						-- Local Read (active Low)
		LWEb				: out	std_logic;						-- Local Write (active Low)
		LATCH				: out	std_logic;						-- Latch Signal (active High)
		LOAD				: out	std_logic;						-- Load Signal (active High)
		LRSTb				: out	std_logic;						-- Local Reset (active Low)
		-- for TEST --
		CLK_RSTb_OUT		: out	std_logic;						-- SLV RESET
		CLKCOM_OUT			: out	std_logic;						-- PLL Output Clock(100MHz)
		LOCKED				: out	std_logic						-- PLL locked signal
	);
end component;

-- CLK generate
component slv_clk_gen
	port(
		RSTb				: in	std_logic;		-- power on reset
		CLK_BASE_20M		: in	std_logic;		-- Clock 20MHZ

		CLK500k				: out	std_logic;		-- Clock 500kHz
		CLK_EN_1k			: out	std_logic;		-- Clock ENABLE 1k
		CLK_EN_500k			: out	std_logic;		-- Clock ENABLE 500k
		CLK_EN_5M			: out	std_logic		-- Clock ENABLE 5M
	);
end component;

-- Serial to Parallel(SN74AHC595) & Parallel to Serial(SN74LV165)
component sp_conv is
	port(
		-- Local Bus --
		CLK					: in	std_logic;	 -- Clock 20MHZ
		LRSTb				: in	std_logic;	 -- Local Reset (active Low)
		-- cken --
		CKEN5M				: in	std_logic;
		-- parallel in	--
		STM_M				: in	ta_DA3(c_STM_CH downto 1);
		STM_DIR				: in	std_logic_vector(c_STM_CH downto 1);
		STM_ENB				: in	std_logic_vector(c_STM_CH downto 1);
		STM_nSLP			: in	std_logic_vector(c_STM_CH downto 1);
		PW_SV_EN			: in	std_logic;
		PW_PUMP_EN			: in	std_logic;
		PW_PLS_EN			: in	std_logic;
		PW_LMT_EN			: in	std_logic;
		PW_ENC_EN			: in	std_logic;
		PW_SNS_EN			: in	std_logic;
		PW_SNSLED_EN		: in	std_logic;
		PW_PLSSNS_EN		: in	std_logic;
		PW_LEDSH_EN			: in	std_logic;
		PW_LEDLT_EN			: in	std_logic;
		-- parallel out	--
		SNS					: out	std_logic_vector(c_SNS_CH downto 1);
		STM_nFAULT			: out	std_logic_vector(c_STM_CH downto 1);
		PW_SV_nFLT			: out	std_logic;
		PW_PUMP_nFLT		: out	std_logic;
		PW_PLS_nFLT			: out	std_logic;
		PW_LMT_nFLT			: out	std_logic;
		PW_ENC_nFLT			: out	std_logic;
		PW_SNS_nFLT			: out	std_logic;
		PW_SNSLED_nFLT		: out	std_logic;
		PW_PLSSNS_nFLT		: out	std_logic;
		PW_LEDSH_nFLT		: out	std_logic;
		PW_LEDLT5V_nFLT		: out	std_logic;
		PW_LEDLT3R3V_nFLT	: out	std_logic;
		-- Serial to Parallel(SN74AHC595)
		S2P_SCK				: out	std_logic;
		S2P_RCK				: out	std_logic;
		S2P_nOE				: out	std_logic;
		S2P_nCLR			: out	std_logic;
		S2P_SDO				: out	std_logic;
		-- Parallel to Serial(SN74LV165)
		P2S_SCK				: out	std_logic;
		P2S_SLD				: out	std_logic;
		P2S_SDI				: in	std_logic
	);
end component;

-- eFuse Enable Control
component EFUSE_CTRL
	port(
		CLK					: in	std_logic;	 -- Clock 20MHZ
		LRSTb				: in	std_logic;	 -- Local Reset (active Low)

		MODE_COM			: in	std_logic_vector( 3 downto 0);
		MODE_OUT			: out	std_logic_vector( 3 downto 0);

		PW_SV_EN			: out	std_logic;
		PW_PUMP_EN			: out	std_logic;
		PW_PLS_EN			: out	std_logic;
		PW_LMT_EN			: out	std_logic;
		PW_ENC_EN			: out	std_logic;
		PW_SNS_EN			: out	std_logic;
		PW_SNSLED_EN		: out	std_logic;
		PW_PLSSNS_EN		: out	std_logic;
		PW_LEDSH_EN			: out	std_logic;
		PW_LEDLT_EN			: out	std_logic
	);
end component;

-- DAC(DAC43608)
component DAC43608_top
	generic (
		g_InitValue			: std_logic_vector( 7 downto 0 )	:= X"00" ;	-- (CTRL_32CH) Initial value
		g_PrescaleL			: std_logic_vector( 7 downto 0 )	:= X"09"	-- (DAC_CTRL_1CH) SCL freq Prescaler LSB
				-- 400kbps @ CLK=20MHz	-- Maybe feeding "clock freq [MHz] / 2 - 1"
	) ;
	port (
		CLK					: in	std_logic ;
		LRSTb				: in	std_logic ;
		-- SEND DATA
		DA_SEND_DATA		: ta_DA8(c_STM_CH downto 1);
		-- I2C
		SCL					: inout	std_logic ;
		SDA					: inout	std_logic
	) ;
end component ;

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

-- LED SERCH BOARD

-- LED LIGHT BOARD(TLC5916 & AD8402)
component LEDLT_TOP
	port(
		CLK				: in	std_logic; 								-- Slave Clock 20MHZ
		LRSTb			: in	std_logic; 								-- Power On Reset
		CKEN1k			: in	std_logic;
		CLK500k			: in	std_logic;
		CKEN500k		: in	std_logic;
		CKEN5M			: in	std_logic;
		
		LEDPTN_NO		: in	std_logic_vector( 3 downto 0);
		LED_I_SET		: in	std_logic_vector( 7 downto 0);
		LEDLT_ON		: in	std_logic;
		
		LEDDRV_LE		: out	std_logic;
		LEDDRV_OEb		: out	std_logic;
		LEDDRV_CLK		: out	std_logic;
		LEDDRV_SD		: out	std_logic;
		DPM_CSb			: out	std_logic;
		DPM_CLK			: out	std_logic;
		DPM_SD			: out	std_logic
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
component pls_sens
	generic (
		CH : integer := c_PLS_CH	-- Number of pulse sensor channels
	);
	port(
		CLK			: in	std_logic;								-- Clock 20MHZ
		LRSTb		: in	std_logic;								-- Local Reset (active Low)
		CKEN1k		: in	std_logic;								-- Clock Enable 1k
		PLSPD		: in	std_logic_vector((CH - 1) downto 0);	-- Phot Diode
		PLSPDLT		: out	std_logic_vector((CH - 1) downto 0);	-- Phot Diode Latched
		PLSLEDb		: out	std_logic_vector((CH - 1) downto 0)	-- Pulse LED -- toku chng 2004.01.10
	);
end component;

-- GPIO
component gpio_top
	port(
		-- Local Bus --
		CLK					: in	std_logic;						-- Clock 20MHZ
		LA					: in	std_logic_vector(4 downto 0);	-- Local Address bus
		NSb					: in	std_logic;						-- Node Select (active Low)
		IDSb				: in	std_logic;						-- ID Select (active Low)
		LGSb				: in	std_logic;						-- Log Memory Select (active Low)
		LDI					: in	std_logic_vector(7 downto 0);	-- Local data bus (IN)
		LDO					: out	std_logic_vector(7 downto 0);	-- Local data bus (OUT)
		LRDb				: in	std_logic;						-- Local Read (active Low)
		LWEb				: in	std_logic;						-- Local Write (active Low)
		LATCH				: in	std_logic;						-- Latch Signal (active High)
		LOAD				: in	std_logic;						-- Load Signal (active High)
		LRSTb				: in	std_logic;						-- Local Reset (active Low)
		LATCH_OUT			: out	std_logic;						-- Decoded Latch Signal
		LOAD_OUT			: out	std_logic;						-- Decoded Load Signal
		-- GPIO --
		GPI_0				: in	std_logic_vector(7 downto 0);
		GPI_1				: in	std_logic_vector(7 downto 0);
		GPI_2				: in	std_logic_vector(7 downto 0);
		GPI_3				: in	std_logic_vector(7 downto 0);
		GPI_4				: in	std_logic_vector(7 downto 0);
		GPI_5				: in	std_logic_vector(7 downto 0);
		GPI_6				: in	std_logic_vector(7 downto 0);
		GPI_7				: in	std_logic_vector(7 downto 0);
		GPI_8				: in	std_logic_vector(7 downto 0);
		GPI_9				: in	std_logic_vector(7 downto 0);
		GPI_10				: in	std_logic_vector(7 downto 0);
		GPI_11				: in	std_logic_vector(7 downto 0);
		GPI_12				: in	std_logic_vector(7 downto 0);
		GPI_13				: in	std_logic_vector(7 downto 0);
		GPI_14				: in	std_logic_vector(7 downto 0);
		GPI_15				: in	std_logic_vector(7 downto 0);
		GPI_16				: in	std_logic_vector(7 downto 0);
		GPI_17				: in	std_logic_vector(7 downto 0);
		GPI_18				: in	std_logic_vector(7 downto 0);
		GPI_19				: in	std_logic_vector(7 downto 0);
		GPI_20				: in	std_logic_vector(7 downto 0);
		GPI_21				: in	std_logic_vector(7 downto 0);
		GPI_22				: in	std_logic_vector(7 downto 0);
		GPI_23				: in	std_logic_vector(7 downto 0);
		GPI_24				: in	std_logic_vector(7 downto 0);
		GPI_25				: in	std_logic_vector(7 downto 0);
		GPI_26				: in	std_logic_vector(7 downto 0);
		GPI_27				: in	std_logic_vector(7 downto 0);
		GPI_28				: in	std_logic_vector(7 downto 0);
		GPI_29				: in	std_logic_vector(7 downto 0);
		GPI_30				: in	std_logic_vector(7 downto 0);
		GPI_31				: in	std_logic_vector(7 downto 0);
		GPO_0				: out	std_logic_vector(7 downto 0);
		GPO_1				: out	std_logic_vector(7 downto 0);
		GPO_2				: out	std_logic_vector(7 downto 0);
		GPO_3				: out	std_logic_vector(7 downto 0);
		GPO_4				: out	std_logic_vector(7 downto 0);
		GPO_5				: out	std_logic_vector(7 downto 0);
		GPO_6				: out	std_logic_vector(7 downto 0);
		GPO_7				: out	std_logic_vector(7 downto 0);
		GPO_8				: out	std_logic_vector(7 downto 0);
		GPO_9				: out	std_logic_vector(7 downto 0);
		GPO_10				: out	std_logic_vector(7 downto 0);
		GPO_11				: out	std_logic_vector(7 downto 0);
		GPO_12				: out	std_logic_vector(7 downto 0);
		GPO_13				: out	std_logic_vector(7 downto 0);
		GPO_14				: out	std_logic_vector(7 downto 0);
		GPO_15				: out	std_logic_vector(7 downto 0);
		GPO_16				: out	std_logic_vector(7 downto 0);
		GPO_17				: out	std_logic_vector(7 downto 0);
		GPO_18				: out	std_logic_vector(7 downto 0);
		GPO_19				: out	std_logic_vector(7 downto 0);
		GPO_20				: out	std_logic_vector(7 downto 0);
		GPO_21				: out	std_logic_vector(7 downto 0);
		GPO_22				: out	std_logic_vector(7 downto 0);
		GPO_23				: out	std_logic_vector(7 downto 0);
		GPO_24				: out	std_logic_vector(7 downto 0);
		GPO_25				: out	std_logic_vector(7 downto 0);
		GPO_26				: out	std_logic_vector(7 downto 0);
		GPO_27				: out	std_logic_vector(7 downto 0);
		GPO_28				: out	std_logic_vector(7 downto 0);
		GPO_29				: out	std_logic_vector(7 downto 0);
		GPO_30				: out	std_logic_vector(7 downto 0);
		GPO_31				: out	std_logic_vector(7 downto 0)
	);
end component;

--compact ppmc
component ppmc_top_S118M
	port(
		-- Local Bus --
		CLK					: in	std_logic;						-- Clock 20MHZ
		LA					: in	std_logic_vector(4 downto 0);	-- Local Address bus
		NSb					: in	std_logic;						-- Node Select (active Low)
		IDSb				: in	std_logic;						-- ID Select (active Low)
		LGSb				: in	std_logic;						-- Log Memory Select (active Low)
		LDI					: in	std_logic_vector(7 downto 0);	-- Local data bus (IN)
		LDO					: out	std_logic_vector(7 downto 0);	-- Local data bus (OUT)
		LRDb				: in	std_logic;						-- Local Read (active Low)
		LWEb				: in	std_logic;						-- Local Write (active Low)
		LATCH				: in	std_logic;						-- Latch Signal (active High)
		LOAD				: in	std_logic;						-- Load Signal (active High)
		LRSTb				: in	std_logic;						-- Local Reset (active Low)
		-- PPMC --
		MCLK				: in	std_logic;						-- Clock 500kHZ
		KCLK				: in	std_logic;						-- Clock 1kHZ
		POUT				: out	std_logic;						-- Pulse Out
		DIR					: out	std_logic;						-- direction 	0:CW	1:CCW
		CURRENT_DOWN		: out	std_logic;						-- CURRENT_DOWN 0:UP	1:DOWN
		S1					: out	std_logic;						-- Phase A
		S2					: out	std_logic;						-- Phase B
		S3					: out	std_logic;						-- Phase A/
		S4					: out	std_logic;						-- Phase B/
		LCW					: in	std_logic;						-- CW Limit
		LCCW				: in	std_logic;						-- CCW Limit
		MORE_INH_CW			: in	std_logic;						-- More Drive Inhibit CW
		MORE_INH_CCW		: in	std_logic;						-- More Drive Inhibit CCW
		PLS0_STOP_INH		: in	std_logic;						-- Pulse zero stop Inhibit
		MPI					: in	std_logic_vector(7 downto 0);	-- pararell data input
		MPO_A				: out	std_logic_vector(7 downto 0);	-- pararell data output
		MPO_B				: out	std_logic_vector(7 downto 0);	-- pararell data output
		SSEL				: in	std_logic;						--
		MSEL				: in	std_logic_vector(3 downto 1);	--
		M					: out	std_logic_vector(3 downto 1);	--
		LIMIT_LOGIC			: out	std_logic_vector(1 downto 0);
		START_STOP			: out	std_logic
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin

	STM_GEN :
	for index in	1 to c_STM_CH generate
		s_STM_LMT(2 * (index - 1))		<= STM_LCW(index);
		s_STM_LMT(2 * (index - 1) + 1)	<= STM_LCCW(index);
		s_STM_ENB(index)				<= sa_STM_MPO_A(index)(0);
		s_STM_nSLP(index)				<= sa_STM_MPO_A(index)(1);
	end generate STM_GEN;

	s_EFUSE_nFLT( 1)	<= s_PW_SV_nFLT;
	s_EFUSE_nFLT( 2)	<= s_PW_PUMP_nFLT;
	s_EFUSE_nFLT( 3)	<= s_PW_PLS_nFLT;
	s_EFUSE_nFLT( 4)	<= s_PW_LMT_nFLT;
	s_EFUSE_nFLT( 5)	<= s_PW_ENC_nFLT;
	s_EFUSE_nFLT( 6)	<= s_PW_SNS_nFLT;
	s_EFUSE_nFLT( 7)	<= s_PW_SNSLED_nFLT;
	s_EFUSE_nFLT( 8)	<= s_PW_PLSSNS_nFLT;
	s_EFUSE_nFLT( 9)	<= s_PW_LEDSH_nFLT;
	s_EFUSE_nFLT(10)	<= s_PW_LEDLT5V_nFLT;
	s_EFUSE_nFLT(11)	<= s_PW_LEDLT3R3V_nFLT;
	s_EFUSE_nFLT(16 downto 12)	<= (others => '0');

	ACTb	<= s_ACT_ONb(5 downto 0);
	PUMPb	<= s_ACT_ONb(7 downto 6);

	STM_PCK <= s_STM_POUT;
	PTLEDb	<= s_PLSLEDb((c_PLS_CH - 1) downto 0) or  (not( s_PLSLED_EN((c_PLS_CH - 1) downto 0) ));

-- LED SERCH BOARD (not implemented, drive safe default values)
	LEDSH_RESETb	<= '1';		-- hold in non-reset state
	LEDSH_SCK		<= '0';
	LEDSH_nCS		<= '1';		-- chip select inactive
	LEDSH_MOSI		<= '0';

-- Node 15 not used, tie to zero to avoid undriven signal
	sa_ND(15) <= (others => '0');

-- Slave ---------------------------------------------------------------------
	slv_com_top_inst: slv_com_top port map (
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

-- clk enable generate ---------------------------------------------------------------------
	CLK_gen_inst : slv_clk_gen port map (
		RSTb			=> s_LRSTb,
		CLK_BASE_20M	=> s_PLL_CLK20M,

		CLK500k			=> s_CLK500k,
		CLK_EN_1k		=> s_CKEN1k,
		CLK_EN_500k		=> s_CKEN500k,
		CLK_EN_5M		=> s_CKEN5M
	);

-- sirial to parallel / parallel to sirial ---------------------------------------------------------------------
	sp_conv_inst : sp_conv port map (
		-- Local Bus --
		CLK					=> s_PLL_CLK20M,
		LRSTb				=> s_LRSTb,
		-- cken --
		CKEN5M				=> s_CKEN5M,
		-- parallel in	--
		STM_M				=> sa_STM_M,
		STM_DIR				=> s_STMDIR,
		STM_ENB				=> s_STM_ENB,
		STM_nSLP			=> (others => '1'),
		PW_SV_EN			=> s_PW_SV_EN,
		PW_PUMP_EN			=> s_PW_PUMP_EN,
		PW_PLS_EN			=> s_PW_PLS_EN,
		PW_LMT_EN			=> s_PW_LMT_EN,
		PW_ENC_EN			=> s_PW_ENC_EN,
		PW_SNS_EN			=> s_PW_SNS_EN,
		PW_SNSLED_EN		=> s_PW_SNSLED_EN,
		PW_PLSSNS_EN		=> s_PW_PLS_EN,
		PW_LEDSH_EN			=> s_PW_LEDSH_EN,
		PW_LEDLT_EN			=> s_PW_LEDLT_EN,
		-- parallel out	--
		SNS					=> s_SNS(c_SNS_CH downto 1),
		STM_nFAULT			=> s_STM_nFAULT(c_STM_CH downto 1),
		PW_SV_nFLT			=> s_PW_SV_nFLT,
		PW_PUMP_nFLT		=> s_PW_PUMP_nFLT,
		PW_PLS_nFLT			=> s_PW_PLS_nFLT,
		PW_LMT_nFLT			=> s_PW_LMT_nFLT,
		PW_ENC_nFLT			=> s_PW_ENC_nFLT,
		PW_SNS_nFLT			=> s_PW_SNS_nFLT,
		PW_SNSLED_nFLT		=> s_PW_SNSLED_nFLT,
		PW_PLSSNS_nFLT		=> s_PW_PLSSNS_nFLT,
		PW_LEDSH_nFLT		=> s_PW_LEDSH_nFLT,
		PW_LEDLT5V_nFLT		=> s_PW_LEDLT5V_nFLT,
		PW_LEDLT3R3V_nFLT	=> s_PW_LEDLT3R3V_nFLT,
		-- Serial to Parallel(SN74AHC595)
		S2P_SCK				=> S2P_SCK,
		S2P_RCK				=> S2P_RCK,
		S2P_nOE				=> S2P_nOE
		,
		S2P_nCLR			=> S2P_nCLR,
		S2P_SDO				=> S2P_SDO,
		-- Parallel to Serial(SN74LV165)
		P2S_SCK				=> P2S_SCK,
		P2S_SLD				=> P2S_SLD,
		P2S_SDI				=> P2S_SDI
	);
-- eFuse Enable Control
	EFUSE_CTRL_inst : EFUSE_CTRL port map (
		CLK				=> s_PLL_CLK20M,
		LRSTb			=> s_LRSTb,

		MODE_COM		=> s_mode_com( 3 downto 0),
		MODE_OUT		=> s_mode_out( 3 downto 0),

		PW_SV_EN		=> s_PW_SV_EN,
		PW_PUMP_EN		=> s_PW_PUMP_EN,
		PW_PLS_EN		=> s_PW_PLS_EN,
		PW_LMT_EN		=> s_PW_LMT_EN,
		PW_ENC_EN		=> s_PW_ENC_EN,
		PW_SNS_EN		=> s_PW_SNS_EN,
		PW_SNSLED_EN	=> s_PW_SNSLED_EN,
		PW_PLSSNS_EN	=> s_PW_PLSSNS_EN,
		PW_LEDSH_EN		=> s_PW_LEDSH_EN,
		PW_LEDLT_EN		=> s_PW_LEDLT_EN
	);

-- DAC43608 ---------------------------------------------------------------------
	U_DAC43608_top : DAC43608_top
	generic map (
		g_PrescaleL		=>	X"09"	-- 400kbps @ CLK=20MHz
	)
	port map (
		CLK				=> s_PLL_CLK20M,
		LRSTb			=> s_LRSTb,
		-- SEND DATA
		DA_SEND_DATA	=> sa_STM_CUR,
		-- I2C
		SCL				=> STMVREF_SCL,
		SDA				=> STMVREF_SDA
	) ;

-- ADC control ---------------------------------------------------------------------
	ADC_CONT : ad_ctrl port map(
		CLK			=> s_PLL_CLK20M,
		LRSTb		=> s_LRSTb,

		ADDATA01	=> s_PRES01_DATA(11 downto 0),
		ADDATA02	=> s_PRES02_DATA(11 downto 0),
		ADDATA03	=> open,
		ADDATA04	=> open,
		ADDATA05	=> open,
		ADDATA06	=> open,
		ADDATA07	=> open,
		ADDATA08	=> open,

		ADC_nCS		=> ADC_nCS,
		ADC_SCK		=> ADC_SCK,
		ADC_SDO		=> ADC_MOSI,
		ADC_SDI		=> ADC_MISO	
	);

-- LED LIGHT BOARD(TLC5916 & AD8402)
	LEDLT : LEDLT_TOP port map(
		CLK				=> s_PLL_CLK20M,
		LRSTb			=> s_LRSTb,
		CKEN1k			=> s_CKEN1k,
		CLK500k			=> s_CLK500k,
		CKEN500k		=> s_CKEN500k,
		CKEN5M			=> s_CKEN5M,
		
		LEDPTN_NO		=> s_LEDLT_CTRL(3 downto 0),
		LED_I_SET		=> s_LED_I_SET,
		LEDLT_ON		=> s_LEDLT_CTRL(7),
		
		LEDDRV_LE		=> LEDDRV_LE,
		LEDDRV_OEb		=> LEDDRV_OEb,
		LEDDRV_CLK		=> LEDDRV_CLK,
		LEDDRV_SD		=> LEDDRV_SD,
		DPM_CSb			=> DPM_CSb,
		DPM_CLK			=> DPM_CLK,
		DPM_SD			=> DPM_SD
	);

-- Encorder count & limit ---------------------------------------------------------------------
	ENC_inst : enc_func_top port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
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
		ENC_LMT_DET		=> s_ENC_LMT_DET(c_ENC_CH downto 1),
		ENCPHASE		=> s_ENCPHASE((2 * c_ENC_CH - 1) downto 0),
		--ppmc I/F
		STM_STOP		=> s_STM_STOP,
		STM_M			=> sa_STM_M,
		STMDIR			=> s_STMDIR,
		STM_POUT		=> s_STM_POUT,
		MORE_INH_CW		=> s_MORE_INH_CW,
		MORE_INH_CCW	=> s_MORE_INH_CCW
	);

-- PLS SNS
	pls_sens_inst : pls_sens 
	generic map (
		CH => c_PLS_CH
	)
	port map (
		CLK			=> s_PLL_CLK20M,
		LRSTb		=> s_LRSTb,
		CKEN1k		=> s_CKEN1k,
		PLSPD		=> PLS_SNS,
		PLSPDLT		=> s_PLS_SNS((c_PLS_CH - 1) downto 0),
		PLSLEDb		=> s_PLSLEDb((c_PLS_CH - 1) downto 0)
	);

-- Node 0 ---------------------------------------------------------------------
	stm01 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK			=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb					=> s_NSb(0),
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
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(1),
		START_STOP		=> s_STM_STOP(1)
	);

-- Node 1 ---------------------------------------------------------------------
	stm02 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(1),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(1),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(2),
		DIR				=> s_STMDIR(2),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(2),
		LCCW			=> STM_LCCW(2),
		MORE_INH_CW		=> s_MORE_INH_CW(2),
		MORE_INH_CCW	=> s_MORE_INH_CCW(2),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(2) & STM_LCW(2) & "00000",
		MPO_A			=> sa_STM_MPO_A(2),
		MPO_B			=> sa_STM_MPO_B(2),
		SSEL			=> sa_STM_MPO_A(2)(2),
		MSEL			=> sa_STM_MPO_B(2)(2 downto 0),
		M				=> sa_STM_M(2),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(2),
		START_STOP		=> s_STM_STOP(2)
	);

-- Node 2 ---------------------------------------------------------------------
	stm03 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(2),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(2),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(3),
		DIR				=> s_STMDIR(3),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(3),
		LCCW			=> STM_LCCW(3),
		MORE_INH_CW		=> s_MORE_INH_CW(3),
		MORE_INH_CCW	=> s_MORE_INH_CCW(3),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(3) & STM_LCW(3) & "00000",
		MPO_A			=> sa_STM_MPO_A(3),
		MPO_B			=> sa_STM_MPO_B(3),
		SSEL			=> sa_STM_MPO_A(3)(2),
		MSEL			=> sa_STM_MPO_B(3)(2 downto 0),
		M				=> sa_STM_M(3),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(3),
		START_STOP		=> s_STM_STOP(3)
	);

-- Node 3 ---------------------------------------------------------------------
	stm04 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(3),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(3),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(4),
		DIR				=> s_STMDIR(4),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(4),
		LCCW			=> STM_LCCW(4),
		MORE_INH_CW		=> s_MORE_INH_CW(4),
		MORE_INH_CCW	=> s_MORE_INH_CCW(4),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(4) & STM_LCW(4) & "00000",
		MPO_A			=> sa_STM_MPO_A(4),
		MPO_B			=> sa_STM_MPO_B(4),
		SSEL			=> sa_STM_MPO_A(4)(2),
		MSEL			=> sa_STM_MPO_B(4)(2 downto 0),
		M				=> sa_STM_M(4),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(4),
		START_STOP		=> s_STM_STOP(4)
	);

-- Node 4 ---------------------------------------------------------------------
	stm05 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(4),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(4),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(5),
		DIR				=> s_STMDIR(5),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(5),
		LCCW			=> STM_LCCW(5),
		MORE_INH_CW		=> s_MORE_INH_CW(5),
		MORE_INH_CCW	=> s_MORE_INH_CCW(5),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(5) & STM_LCW(5) & "00000",
		MPO_A			=> sa_STM_MPO_A(5),
		MPO_B			=> sa_STM_MPO_B(5),
		SSEL			=> sa_STM_MPO_A(5)(2),
		MSEL			=> sa_STM_MPO_B(5)(2 downto 0),
		M				=> sa_STM_M(5),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(5),
		START_STOP		=> s_STM_STOP(5)
	);

-- Node 5 ---------------------------------------------------------------------
	stm06 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(5),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(5),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(6),
		DIR				=> s_STMDIR(6),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(6),
		LCCW			=> STM_LCCW(6),
		MORE_INH_CW		=> s_MORE_INH_CW(6),
		MORE_INH_CCW	=> s_MORE_INH_CCW(6),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(6) & STM_LCW(6) & "00000",
		MPO_A			=> sa_STM_MPO_A(6),
		MPO_B			=> sa_STM_MPO_B(6),
		SSEL			=> sa_STM_MPO_A(6)(2),
		MSEL			=> sa_STM_MPO_B(6)(2 downto 0),
		M				=> sa_STM_M(6),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(6),
		START_STOP		=> s_STM_STOP(6)
	);

-- Node 6 ---------------------------------------------------------------------
	stm07 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(6),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(6),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(7),
		DIR				=> s_STMDIR(7),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(7),
		LCCW			=> STM_LCCW(7),
		MORE_INH_CW		=> s_MORE_INH_CW(7),
		MORE_INH_CCW	=> s_MORE_INH_CCW(7),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(7) & STM_LCW(7) & "00000",
		MPO_A			=> sa_STM_MPO_A(7),
		MPO_B			=> sa_STM_MPO_B(7),
		SSEL			=> sa_STM_MPO_A(7)(2),
		MSEL			=> sa_STM_MPO_B(7)(2 downto 0),
		M				=> sa_STM_M(7),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(7),
		START_STOP		=> s_STM_STOP(7)
	);

-- Node 7 ---------------------------------------------------------------------
	stm08 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(7),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(7),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(8),
		DIR				=> s_STMDIR(8),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(8),
		LCCW			=> STM_LCCW(8),
		MORE_INH_CW		=> s_MORE_INH_CW(8),
		MORE_INH_CCW	=> s_MORE_INH_CCW(8),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(8) & STM_LCW(8) & "00000",
		MPO_A			=> sa_STM_MPO_A(8),
		MPO_B			=> sa_STM_MPO_B(8),
		SSEL			=> sa_STM_MPO_A(8)(2),
		MSEL			=> sa_STM_MPO_B(8)(2 downto 0),
		M				=> sa_STM_M(8),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(8),
		START_STOP		=> s_STM_STOP(8)
	);

-- Node 8 ---------------------------------------------------------------------
	stm09 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(8),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(8),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(9),
		DIR				=> s_STMDIR(9),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(9),
		LCCW			=> STM_LCCW(9),
		MORE_INH_CW		=> s_MORE_INH_CW(9),
		MORE_INH_CCW	=> s_MORE_INH_CCW(9),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(9) & STM_LCW(9) & "00000",
		MPO_A			=> sa_STM_MPO_A(9),
		MPO_B			=> sa_STM_MPO_B(9),
		SSEL			=> sa_STM_MPO_A(9)(2),
		MSEL			=> sa_STM_MPO_B(9)(2 downto 0),
		M				=> sa_STM_M(9),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(9),
		START_STOP		=> s_STM_STOP(9)
	);

-- Node 9 ---------------------------------------------------------------------
	stm10 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(9),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(9),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(10),
		DIR				=> s_STMDIR(10),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(10),
		LCCW			=> STM_LCCW(10),
		MORE_INH_CW		=> s_MORE_INH_CW(10),
		MORE_INH_CCW	=> s_MORE_INH_CCW(10),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(10) & STM_LCW(10) & "00000",
		MPO_A			=> sa_STM_MPO_A(10),
		MPO_B			=> sa_STM_MPO_B(10),
		SSEL			=> sa_STM_MPO_A(10)(2),
		MSEL			=> sa_STM_MPO_B(10)(2 downto 0),
		M				=> sa_STM_M(10),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(10),
		START_STOP		=> s_STM_STOP(10)
	);
	
-- Node 10 ---------------------------------------------------------------------
	stm11 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(10),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(10),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(11),
		DIR				=> s_STMDIR(11),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(11),
		LCCW			=> STM_LCCW(11),
		MORE_INH_CW		=> s_MORE_INH_CW(11),
		MORE_INH_CCW	=> s_MORE_INH_CCW(11),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(11) & STM_LCW(11) & "00000",
		MPO_A			=> sa_STM_MPO_A(11),
		MPO_B			=> sa_STM_MPO_B(11),
		SSEL			=> sa_STM_MPO_A(11)(2),
		MSEL			=> sa_STM_MPO_B(11)(2 downto 0),
		M				=> sa_STM_M(11),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(11),
		START_STOP		=> s_STM_STOP(11)
	);

-- Node 11 ---------------------------------------------------------------------
	stm12 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(11),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(11),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(12),
		DIR				=> s_STMDIR(12),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(12),
		LCCW			=> STM_LCCW(12),
		MORE_INH_CW		=> s_MORE_INH_CW(12),
		MORE_INH_CCW	=> s_MORE_INH_CCW(12),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(12) & STM_LCW(12) & "00000",
		MPO_A			=> sa_STM_MPO_A(12),
		MPO_B			=> sa_STM_MPO_B(12),
		SSEL			=> sa_STM_MPO_A(12)(2),
		MSEL			=> sa_STM_MPO_B(12)(2 downto 0),
		M				=> sa_STM_M(12),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(12),
		START_STOP		=> s_STM_STOP(12)
	);

-- Node 12 ---------------------------------------------------------------------
	stm13 : ppmc_top_S118M port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(12),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(12),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		-- PPMC --
		MCLK			=> s_CKEN500k,
		KCLK			=> s_CKEN1k,
		POUT			=> s_STM_POUT(13),
		DIR				=> s_STMDIR(13),
		CURRENT_DOWN	=> open,
		S1				=> open,
		S2				=> open,
		S3				=> open,
		S4				=> open,
		LCW				=> STM_LCW(13),
		LCCW			=> STM_LCCW(13),
		MORE_INH_CW		=> s_MORE_INH_CW(13),
		MORE_INH_CCW	=> s_MORE_INH_CCW(13),
		PLS0_STOP_INH	=> '0',
		MPI				=> '0' & STM_LCCW(13) & STM_LCW(13) & "00000",
		MPO_A			=> sa_STM_MPO_A(13),
		MPO_B			=> sa_STM_MPO_B(13),
		SSEL			=> sa_STM_MPO_A(13)(2),
		MSEL			=> sa_STM_MPO_B(13)(2 downto 0),
		M				=> sa_STM_M(13),
		LIMIT_LOGIC		=> sa_LIMIT_LOGIC(13),
		START_STOP		=> s_STM_STOP(13)
	);

-- Node 13 ---------------------------------------------------------------------
	gpio01 : gpio_top port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(13),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(13),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		LATCH_OUT		=> open,
		LOAD_OUT		=> open,
		-- GPIO --
		GPI_0			=> s_ENCPHASE( 7 downto  0),
		GPI_1			=> s_ENCPHASE(15 downto  8),
		GPI_2			=> s_ENCPHASE(23 downto 16),
		GPI_3			=> s_ENCPHASE(31 downto 24),
		GPI_4			=> sa_ENCDATA( 1)( 7 downto 0),
		GPI_5			=> sa_ENCDATA( 1)(15 downto 8),
		GPI_6			=> sa_ENCDATA( 2)( 7 downto 0),
		GPI_7			=> sa_ENCDATA( 2)(15 downto 8),
		GPI_8			=> sa_ENCDATA( 3)( 7 downto 0),
		GPI_9			=> sa_ENCDATA( 3)(15 downto 8),
		GPI_10			=> sa_ENCDATA( 4)( 7 downto 0),
		GPI_11			=> sa_ENCDATA( 4)(15 downto 8),
		GPI_12			=> sa_ENCDATA( 5)( 7 downto 0),
		GPI_13			=> sa_ENCDATA( 5)(15 downto 8),
		GPI_14			=> sa_ENCDATA( 6)( 7 downto 0),
		GPI_15			=> sa_ENCDATA( 6)(15 downto 8),
		GPI_16			=> sa_ENCDATA( 7)( 7 downto 0),
		GPI_17			=> sa_ENCDATA( 7)(15 downto 8),
		GPI_18			=> sa_ENCDATA( 8)( 7 downto 0),
		GPI_19			=> sa_ENCDATA( 8)(15 downto 8),
		GPI_20			=> sa_ENCDATA( 9)( 7 downto 0),
		GPI_21			=> sa_ENCDATA( 9)(15 downto 8),
		GPI_22			=> sa_ENCDATA(10)( 7 downto 0),
		GPI_23			=> sa_ENCDATA(10)(15 downto 8),
		GPI_24			=> sa_ENCDATA(11)( 7 downto 0),
		GPI_25			=> sa_ENCDATA(11)(15 downto 8),
		GPI_26			=> sa_ENCDATA(12)( 7 downto 0),
		GPI_27			=> sa_ENCDATA(12)(15 downto 8),
		GPI_28			=> sa_ENCDATA(13)( 7 downto 0),
		GPI_29			=> sa_ENCDATA(13)(15 downto 8),
		GPI_30			=> s_ENC_LMT_DET( 8 downto 1),
		GPI_31			=> s_ENC_LMT_DET(16 downto 9),

		GPO_0			=> s_ENC_MODE,
		GPO_1			=> s_ENC_EN( 8 downto 1),
		GPO_2			=> s_ENC_EN(16 downto 9),
		GPO_3			=> s_ENCLMT_EN( 8 downto 1),
		GPO_4			=> s_ENCLMT_EN(16 downto 9),
		GPO_5			=> s_ENC_INV( 8 downto 1),
		GPO_6			=> s_ENC_INV(16 downto 9),
		GPO_7			=> sa_ENCLMT_TH( 1),
		GPO_8			=> sa_ENCLMT_TH( 2),
		GPO_9			=> sa_ENCLMT_TH( 3),
		GPO_10			=> sa_ENCLMT_TH( 4),
		GPO_11			=> sa_ENCLMT_TH( 5),
		GPO_12			=> sa_ENCLMT_TH( 6),
		GPO_13			=> sa_ENCLMT_TH( 7),
		GPO_14			=> sa_ENCLMT_TH( 8),
		GPO_15			=> sa_ENCLMT_TH( 9),
		GPO_16			=> sa_ENCLMT_TH(10),
		GPO_17			=> sa_ENCLMT_TH(11),
		GPO_18			=> sa_ENCLMT_TH(12),
		GPO_19			=> sa_ENCLMT_TH(13),
		GPO_20			=> OPEN,
		GPO_21			=> OPEN,
		GPO_22			=> OPEN,
		GPO_23			=> OPEN,
		GPO_24			=> OPEN,
		GPO_25			=> OPEN,
		GPO_26			=> OPEN,
		GPO_27			=> OPEN,
		GPO_28			=> OPEN,
		GPO_29			=> OPEN,
		GPO_30			=> OPEN,
		GPO_31			=> OPEN
	);

-- Node 14 ---------------------------------------------------------------------
	gpio02 : gpio_top port map (
		-- Local Bus --
		CLK				=> s_PLL_CLK20M,
		LA				=> s_LA(4 downto 0),
		NSb				=> s_NSb(14),
		IDSb			=> s_IDSb,
		LGSb			=> s_LGSb,
		LDI				=> s_LDI,
		LDO				=> sa_ND(14),
		LRDb			=> s_LRDb,
		LWEb			=> s_LWEb,
		LATCH			=> s_LATCH,
		LOAD			=> s_LOAD,
		LRSTb			=> s_LRSTb,
		LATCH_OUT		=> open,
		LOAD_OUT		=> open,
		-- GPIO --
		GPI_0			=> s_SNS( 8 downto 1),
		GPI_1			=> s_SNS(16 downto 9),
		GPI_2			=> s_PLS_SNS( 7 downto 0),
		GPI_3			=> s_STM_LMT( 7 downto 0),
		GPI_4			=> s_STM_LMT(15 downto 8),
		GPI_5			=> s_STM_LMT(23 downto 16),
		GPI_6			=> s_STM_LMT(31 downto 24),
		GPI_7			=> s_PRES01_DATA( 7 downto 0),
		GPI_8			=> s_PRES01_DATA(15 downto 8),
		GPI_9			=> s_PRES02_DATA( 7 downto 0),
		GPI_10			=> s_PRES02_DATA(15 downto 8),
		GPI_11			=> s_STM_nFAULT( 8 downto 1),
		GPI_12			=> s_STM_nFAULT(16 downto 9),
		GPI_13			=> s_EFUSE_nFLT( 8 downto 1),
		GPI_14			=> s_EFUSE_nFLT(16 downto 9),
		GPI_15			=> oct0,
		GPI_16			=> oct0,
		GPI_17			=> s_mode_out,
		GPI_18			=> oct0,
		GPI_19			=> oct0,
		GPI_20			=> oct0,
		GPI_21			=> oct0,
		GPI_22			=> oct0,
		GPI_23			=> oct0,
		GPI_24			=> oct0,
		GPI_25			=> oct0,
		GPI_26			=> oct0,
		GPI_27			=> oct0,
		GPI_28			=> oct0,
		GPI_29			=> oct0,
		GPI_30			=> oct0,
		GPI_31			=> oct0,

		GPO_0			=> sa_STM_CUR( 1),
		GPO_1			=> sa_STM_CUR( 2),
		GPO_2			=> sa_STM_CUR( 3),
		GPO_3			=> sa_STM_CUR( 4),
		GPO_4			=> sa_STM_CUR( 5),
		GPO_5			=> sa_STM_CUR( 6),
		GPO_6			=> sa_STM_CUR( 7),
		GPO_7			=> sa_STM_CUR( 8),
		GPO_8			=> sa_STM_CUR( 9),
		GPO_9			=> sa_STM_CUR(10),
		GPO_10			=> sa_STM_CUR(11),
		GPO_11			=> sa_STM_CUR(12),
		GPO_12			=> sa_STM_CUR(13),
		GPO_13			=> s_ACT_ONb,
		GPO_14			=> s_PLSLED_EN( 7 downto 0),
		GPO_15			=> s_LEDLT_CTRL,
		GPO_16			=> s_LED_I_SET,
		GPO_17			=> s_EFUSE_EN( 7 downto 0),
		GPO_18			=> s_EFUSE_EN(15 downto 8),
		GPO_19			=> s_mode_com,
		GPO_20			=> OPEN,
		GPO_21			=> OPEN,
		GPO_22			=> OPEN,
		GPO_23			=> OPEN,
		GPO_24			=> OPEN,
		GPO_25			=> OPEN,
		GPO_26			=> OPEN,
		GPO_27			=> OPEN,
		GPO_28			=> OPEN,
		GPO_29			=> OPEN,
		GPO_30			=> OPEN,
		GPO_31			=> OPEN
	);
	
end RTL;
