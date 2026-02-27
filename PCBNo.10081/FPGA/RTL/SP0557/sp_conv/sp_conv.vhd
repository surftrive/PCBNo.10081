----------------------------------------------------------------------------------------------------
--File Name	: sp_conv.vhd																					
--Project	: S127M(S3IO)
--Date		: 2025.10.29
--Ver		: 00_00
--Doc		: New Release
--			: S127M PCB No.10081
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------
--Date     	:
--Ver       :
--Doc		:
--Changed by 
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	
library WORK ;
	use WORK.w_pack.all;

------------------------entity----------------------------------------------------------------------
entity sp_conv is																						
	port(
		-- Local Bus --
        CLK         		: in	std_logic;     -- Clock 20MHZ
        LRSTb       		: in	std_logic;     -- Local Reset (active Low)
		-- cken --
		CKEN5M				: in	std_logic;
		-- parallel in --
		STM_M				: in	ta_DA3(c_STM_CH downto 1);
		STM_DIR				: in	std_logic_vector( c_STM_CH downto 1 );
		STM_ENB				: in	std_logic_vector( c_STM_CH downto 1 );
		STM_nSLP			: in	std_logic_vector( c_STM_CH downto 1 );
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
		-- parallel out --
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
end sp_conv;					
---------------architecture-------------------------------------------------------------------------
architecture RTL of sp_conv is																								
-------------- constant ----------------------------------------------------------------------------
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

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_SerTxData		: std_logic_vector(c_MOSILen downto 1)	:= (others => '0');
signal		s_SerRxData		: std_logic_vector(c_MISOLen downto 1)	:= (others => '0');
signal		s_SCK			: std_logic;

signal		sa_STM_MOSI		: ta_DA8( c_STM_CH downto 1 )				:= (others => (others => '0'));
signal		s_STM_ENB		: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');	-- STM Excitation Enable
signal		s_STM_DIRb		: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');	-- 
signal		s_STM_nSLP		: std_logic_vector( c_STM_CH downto 1 )		:= (others => '0');	-- nSLEEP for DRV8424 (0:Norm, 1:Sleep)
signal		sa_STM_Mode		: ta_DA3( c_STM_CH downto 1 )				:= (others => (others => '0'));	-- STM Mode Select
signal		sa_STM_M		: ta_DA3( c_STM_CH downto 1 )				:= (others => (others => '0'));	-- STM Mode conversion for DRV8424

---------------component----------------------------------------------------------------------------
component SIO_ctrl2
	generic (
		g_MISOLen		: natural := c_MISOLen;						-- num of IN data bits
		g_MOSILen		: natural := c_MOSILen						-- num of OUT data bits
	) ;
	port (
		nRESET			: in	std_logic ;								-- power on reset (active Low)
		CLK40M			: in	std_logic ;								-- Internal Clock 40MHz
		-- Clock Enable
		CE_SIO			: in	std_logic ;								-- for SPI 5MHz(200ns)
		-- Serial Control
		SPI_START		: in	std_logic := '1' ;	-- start
		SPI_UPDATE		: out	std_logic ;								-- SPI_RDATA update timing pulse
		SPI_BUSY		: out	std_logic ;
		SPI_SENDING		: out	std_logic ;
		-- Parallel data
		SPI_SDATA		: in	std_logic_vector(g_MOSILen downto 1 ) ;	-- send data (SV data)
		SPI_RDATA		: out	std_logic_vector(g_MISOLen downto 1 ) ;	-- received data (SNS data)
		-- Serial I/F (in:74x165  out:74x595)
		SIO_SCLK		: out	std_logic ;
		SIO_SLAT		: out	std_logic ;
		SIO_nSGE		: out	std_logic ;
		SIO_nSLD		: out	std_logic ;
		SIO_MOSI		: out	std_logic ;
		SIO_MISO		: in	std_logic
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin

	SIO_inst1 : SIO_ctrl2
	generic map (
		g_MISOLen	=> c_MISOLen,		-- natural
		g_MOSILen	=> c_MOSILen		-- natural
	)
	port map (
		nRESET		=>	LRSTb,			-- in
		CLK40M		=>	CLK,			-- in
	-- Clock Enable
		CE_SIO		=>	CKEN5M,			-- in
	-- Serial Control
		SPI_START	=> '1' ,
		SPI_UPDATE	=>	open,			-- out
		SPI_BUSY	=>	open,			-- out
		SPI_SENDING	=>	open,			-- out
	-- Parallel data
		SPI_SDATA	=>	s_SerTxData,	-- in
		SPI_RDATA	=>	s_SerRxData,	-- out
	-- Serial I/F (in:74x165  out:74x595)
		SIO_SCLK	=>	s_SCK,			-- out
		SIO_SLAT	=>	S2P_RCK,		-- out
		SIO_nSGE	=>	S2P_nOE,		-- out
		SIO_nSLD	=>	P2S_SLD,		-- out
		SIO_MOSI	=>	S2P_SDO,		-- out
		SIO_MISO	=>	P2S_SDI			-- in
	) ;

	S2P_nCLR	<= '1';
	S2P_SCK		<= s_SCK;
	P2S_SCK		<= s_SCK;

-- TX data
	s_SerTxData(114)	<= PW_LEDLT_EN;
	s_SerTxData(113)	<= PW_LEDSH_EN;
	s_SerTxData(112)	<= PW_PLSSNS_EN;
	s_SerTxData(111)	<= PW_SNSLED_EN;
	s_SerTxData(110)	<= PW_SNS_EN;
	s_SerTxData(109)	<= PW_ENC_EN;
	s_SerTxData(108)	<= PW_LMT_EN;
	s_SerTxData(107)	<= PW_PLS_EN;
	s_SerTxData(106)	<= PW_PUMP_EN;
	s_SerTxData(105)	<= PW_SV_EN;

	con_set :
	for index in 1 to c_STM_CH generate
		s_SerTxData( ( index * 8 ) downto ( ( index - 1 ) * 8 + 1 ) )	<=	sa_STM_MOSI(index);

		sa_STM_MOSI(index) <= (
			0	=>	s_STM_nSLP(index)			-- nSLEEP
		,	1	=>	s_STM_ENB (index)			-- ENABLE
		,	2	=>	s_STM_DIRb(index)			-- DIR (H:CW)
		,	3	=>	sa_STM_M  (index)(cn_M1S)	-- M1S
		,	4	=>	sa_STM_M  (index)(cn_M0Z)	-- M0Z
		,	5	=>	sa_STM_M  (index)(cn_M0S)	-- M0S
		,	6	=>	'0'							-- N.C.
		,	7	=>	'0'							-- N.C.
		) ;
		
		s_STM_ENB (index)	<= STM_ENB(index);
		s_STM_nSLP(index)	<= STM_nSLP(index);
		sa_STM_Mode (index)	<= STM_M(index);
		sa_STM_M(index)		<=	ca_STM_M( conv_integer( sa_STM_Mode (index) ) ) ;
	end generate con_set ;

	con_dir_1 :
	for index in 1 to 4 generate
		s_STM_DIRb(index)	<=	not(STM_DIR(index));
	end generate con_dir_1 ;

	con_dir_2 :
	for index in 5 to c_STM_CH generate
		s_STM_DIRb(index)	<=	STM_DIR(index);
	end generate con_dir_2 ;

-- RX data
	STM_nFAULT			<= s_SerRxData(13 downto 1);
	PW_SV_nFLT			<= s_SerRxData(14);
	PW_PUMP_nFLT		<= s_SerRxData(15);
	PW_PLS_nFLT			<= s_SerRxData(16);
	PW_LMT_nFLT			<= s_SerRxData(17);
	PW_ENC_nFLT			<= s_SerRxData(18);
	PW_SNS_nFLT			<= s_SerRxData(19);
	PW_SNSLED_nFLT		<= s_SerRxData(20);
	PW_PLSSNS_nFLT		<= s_SerRxData(21);
	PW_LEDSH_nFLT		<= s_SerRxData(22);
	PW_LEDLT5V_nFLT		<= s_SerRxData(23);
	PW_LEDLT3R3V_nFLT	<= s_SerRxData(24);
	SNS					<= s_SerRxData(40 downto 25);

end RTL;
