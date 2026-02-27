-------------------------------------------------
--File Name : ad_ctrl.vhd
--Project	: S127M
--
--Date		: 2025/10/28
--Ver		: 0.00
--Doc		: ADC128S022 Controller
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

------------------------entity----------------------------------------------------------------------
entity ad_ctrl is
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;

		ADDATA01 : out std_logic_vector (11 downto 0);	-- AD Data #1
		ADDATA02 : out std_logic_vector (11 downto 0);	-- AD Data #2
		ADDATA03 : out std_logic_vector (11 downto 0);	-- AD Data #3
		ADDATA04 : out std_logic_vector (11 downto 0);	-- AD Data #4
		ADDATA05 : out std_logic_vector (11 downto 0);	-- AD Data #5
		ADDATA06 : out std_logic_vector (11 downto 0);	-- AD Data #6
		ADDATA07 : out std_logic_vector (11 downto 0);	-- AD Data #7
		ADDATA08 : out std_logic_vector (11 downto 0);	-- AD Data #8
		
		ADC_nCS : out std_logic;	-- ADC(ADC128S022) Chip Select
		ADC_SCK : out std_logic;	-- ADC(ADC128S022) Clock
		ADC_SDO : out std_logic;	-- ADC(ADC128S022) Serial Data Output (MOSI)
		ADC_SDI : in  std_logic		-- ADC(ADC128S022) Serial Data Input (MISO)
	);
end ad_ctrl;

---------------architecture-------------------------------------------------------------------------
architecture RTL of ad_ctrl is
-------------- constant ----------------------------------------------------------------------------

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal	s_RISE		: std_logic;
signal	s_FALL		: std_logic;
signal	s_RDEN		: std_logic;
signal	s_WREN		: std_logic;
signal	s_CH		: std_logic_vector(2 downto 0);
signal	s_AD_DATA	: std_logic_vector (11 downto 0);

---------------component----------------------------------------------------------------------------
component adclk_gen
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		ADSCLK	: out	std_logic;
		RISE	: out	std_logic;
		FALL	: out	std_logic
	);
end component;

component adif_seq
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		FALL	: in	std_logic;
		ADCSb	: out	std_logic;
		ADDI	: out	std_logic;
		RDEN	: out	std_logic;
		WREN	: out	std_logic;
		CH		: out	std_logic_vector(2 downto 0)
	);
end component;

component shiftreg12bit
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		RISE	: in	std_logic;
		ADC_SDI	: in	std_logic;
		AD_DATA	: out	std_logic_vector(11 downto 0);
		RDEN	: in	std_logic
	);
end component;

component adc_reg
	Port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;

		WREN		: in	std_logic;
		CH			: in	std_logic_vector( 2 downto 0);
		AD_DATA		: in	std_logic_vector(11 downto 0);

		ADDATA01 	: out	std_logic_vector (11 downto 0);	-- AD Data #1
		ADDATA02 	: out	std_logic_vector (11 downto 0);	-- AD Data #2
		ADDATA03 	: out	std_logic_vector (11 downto 0);	-- AD Data #3
		ADDATA04 	: out	std_logic_vector (11 downto 0);	-- AD Data #4
		ADDATA05 	: out	std_logic_vector (11 downto 0);	-- AD Data #5
		ADDATA06 	: out	std_logic_vector (11 downto 0);	-- AD Data #6
		ADDATA07 	: out	std_logic_vector (11 downto 0);	-- AD Data #7
		ADDATA08 	: out	std_logic_vector (11 downto 0)	-- AD Data #8
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin
	adclk_gen_inst: adclk_gen port map(
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		ADSCLK	=> ADC_SCK,
		RISE	=> s_RISE,
		FALL	=> s_FALL
	);

	adif_seq_inst: adif_seq port map(
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		FALL	=> s_FALL,
		ADCSb	=> ADC_nCS,
		ADDI	=> ADC_SDO,
		RDEN	=> s_RDEN,
		WREN	=> s_WREN,
		CH		=> s_CH
	);

	shiftreg12bit_inst: shiftreg12bit port map(
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		RISE	=> s_RISE,
		ADC_SDI	=> ADC_SDI,
		AD_DATA	=> s_AD_DATA,
		RDEN	=> s_RDEN
	);

	adc_reg_inst: adc_reg port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,

		WREN		=> s_WREN,
		CH			=> s_CH,
		AD_DATA		=> s_AD_DATA,

		ADDATA01 	=> ADDATA01,
		ADDATA02 	=> ADDATA02,
		ADDATA03 	=> ADDATA03,
		ADDATA04 	=> ADDATA04,
		ADDATA05 	=> ADDATA05,
		ADDATA06 	=> ADDATA06,
		ADDATA07 	=> ADDATA07,
		ADDATA08 	=> ADDATA08
	);

end RTL;
