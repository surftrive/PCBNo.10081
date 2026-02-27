----------------------------------------------------------------------------------------------------
--File Name	: enc_top.vhd																					
--Project	: S124M(S3IO)
--Date		: 2025.05.13
--Ver		: 00_00
--Doc		: New Release
--			: S124M PCB No.10084
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------
--Date	 	:
--Ver		:
--Doc		:
--Changed by 
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	
library WORK ;
	use WORK.w_pack.all;

------------------------entity----------------------------------------------------------------------
entity enc_top is																						
	port(
		-- Local Bus --
		CLK		 	: in	std_logic;	 					-- Clock 20MHZ
		LRSTb		: in	std_logic;	 					-- Local Reset (active Low)
		-- Encoder
		ENC_A		: in	std_logic;						-- Encorder A
		ENC_B		: in	std_logic;						-- Encorder B
		ENC_EN		: in	std_logic;						-- EncCount Enable
		ENCDATA		: out	std_logic_vector(15 downto 0);	-- Enc count data
		ENCLMT_EN	: in	std_logic;						-- ENCLMT Enable
		ENCLMT_TH	: in	std_logic_vector( 7 downto 0); 	-- ENCLMT Threshold
		ENC_INV		: in	std_logic;						-- enc invert
		ENC_LMT_OUT	: out	std_logic;						-- enc error limit out
		ENC_LMT_DET : out	std_logic;						-- enc error limit register out
		ENC_ST		: in	std_logic;						-- state of STM 0:stop 1:operate
		ENC_EXT		: in	std_logic_vector( 2 downto 0);	-- extension mode of STM
		ENC_DIR		: in	std_logic;						-- rotate direction of STM
		ENC_STM_PLS	: in	std_logic						-- stm pulse signal
	);
end enc_top;					
---------------architecture-------------------------------------------------------------------------
architecture RTL of enc_top is																								
-------------- constant ----------------------------------------------------------------------------

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal	s_ENCA				: std_logic;
signal	s_ENCB				: std_logic;
signal	s_ENCCNTUP			: std_logic; 
signal	s_ENCCNTDWN			: std_logic;
Signal	s_ENC_CNT_UP_ST		: std_logic;	
Signal	s_ENC_CNT_DWN_ST	: std_logic;

---------------component----------------------------------------------------------------------------
component encoder_2bit
	port(
		CLK			: in std_logic;							-- Clock 20MHZ
		LRSTb		: in std_logic;							-- Local Reset (active Low)
		ENCPHASE_A	: in std_logic;							-- Encoder Phase A
		ENCPHASE_B	: in std_logic;							-- Encoder Phase B
		ENC_EN		: in std_logic;							-- Enable
		ENCDATA		: out std_logic_vector(15 downto 0);	-- Encoder Count DATA
		CNT_UP		: out std_logic;
		CNT_DWN	 	: out std_logic
	);
end component;

component enc_lmt
	port(
		CLK			: in std_logic;						-- Clock 20MHz
		LRSTb		: in std_logic;						-- Local Reset	(active Low)
		ENCLMT_EN	: in std_logic;						-- Enable
		LMT_LGC	 	: in std_logic;					 	-- select signal of logic value for limit out 0:negative 1:positive
		STM_ST		: in std_logic;					 	-- state of STM 0:stop 1:operate
		ENC_TH		: in std_logic_vector(7 downto 0);	-- threshold of error of enc to pls
		EXT_MODE	: in std_logic_vector(2 downto 0);	-- extension mode of STM
		DIR			: in std_logic;					 	-- rotate direction of STM
		CNT_UP		: in std_logic;						-- signal of count up for enc
		CNT_DWN		: in std_logic;						-- signal of count down for enc
		STM_PLS		: in std_logic;						-- stm pulse signal
		LMT_OUT		: out std_logic;					-- enc error limit out
		LMT_REG_OUT : out std_logic						-- enc error limit register out
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin
	
	s_ENCA				<= ENC_A		when (ENC_INV = '0')		else ENC_B;	
	s_ENCB				<= ENC_B		when (ENC_INV = '0')		else ENC_A;
	s_ENC_CNT_UP_ST		<= s_ENCCNTUP	when (ENC_INV = '0')		else s_ENCCNTDWN; 
	s_ENC_CNT_DWN_ST	<= s_ENCCNTDWN	when (ENC_INV = '0')		else s_ENCCNTUP;

	encoder_inst : encoder_2bit port map (			
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		ENCPHASE_A	=> s_ENCA,
		ENCPHASE_B	=> s_ENCB,
		ENC_EN		=> ENC_EN,
		ENCDATA		=> ENCDATA,
		CNT_UP		=> s_ENCCNTUP,
		CNT_DWN		=> s_ENCCNTDWN
	);

	U_enc_lmt	:	 enc_lmt
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		ENCLMT_EN	=> ENCLMT_EN,
		LMT_LGC		=> '1',
		STM_ST		=> ENC_ST,
		ENC_TH		=> ENCLMT_TH,
		EXT_MODE	=> ENC_EXT,
		DIR			=> ENC_DIR,
		CNT_UP		=> s_ENC_CNT_UP_ST,
		CNT_DWN		=> s_ENC_CNT_DWN_ST,
		STM_PLS		=> ENC_STM_PLS,
		LMT_OUT		=> ENC_LMT_OUT,
		LMT_REG_OUT	=> ENC_LMT_DET
	);
	
end RTL;
