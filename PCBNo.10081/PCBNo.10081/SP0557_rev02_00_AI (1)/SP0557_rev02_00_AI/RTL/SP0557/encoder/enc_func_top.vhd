----------------------------------------------------------------------------------------------------
--File Name	: enc_func_top.vhd																					
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
entity enc_func_top is																						
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
end enc_func_top;					
---------------architecture-------------------------------------------------------------------------
architecture RTL of enc_func_top is																								
-------------- constant ----------------------------------------------------------------------------

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		P_STM_ENC			: STM_ENC_TYPE;
signal		P_ENC_STM			: ENC_STM_TYPE;
signal		s_ENC_ST			: std_logic_vector(c_ENC_CH downto 1)		:= (others => '0');
signal		sa_ENC_EXT			: ta_DA3(c_ENC_CH downto 1)					:= (others => (others => '0'));
signal		s_ENC_DIR			: std_logic_vector(c_ENC_CH downto 1)		:= (others => '0');
signal		s_ENC_STM_PLS		: std_logic_vector(c_ENC_CH downto 1)		:= (others => '0');
signal		s_ENC_LMT_OUT		: std_logic_vector(c_ENC_CH downto 1)		:= (others => '0');

---------------component----------------------------------------------------------------------------
component enc_top
	port(
		CLK					: in	std_logic;	 					-- Clock 20MHZ
		LRSTb				: in	std_logic;	 					-- Local Reset (active Low)
		-- Encoder
		ENC_A				: in	std_logic;						-- Encorder A
		ENC_B				: in	std_logic;						-- Encorder B
		ENC_EN				: in	std_logic;						-- EncCount Enable
		ENCDATA				: out	std_logic_vector(15 downto 0);	-- Enc count data
		ENCLMT_EN			: in	std_logic;						-- ENCLMT Enable
		ENCLMT_TH			: in	std_logic_vector( 7 downto 0); 	-- ENCLMT Threshold
		ENC_INV				: in	std_logic;						-- enc invert
		ENC_LMT_OUT			: out	std_logic;						-- enc error limit out
		ENC_LMT_DET 		: out	std_logic;						-- enc error limit register out
		ENC_ST				: in	std_logic;						-- state of STM 0:stop 1:operate
		ENC_EXT				: in	std_logic_vector( 2 downto 0);	-- extension mode of STM
		ENC_DIR				: in	std_logic;						-- rotate direction of STM
		ENC_STM_PLS			: in	std_logic						-- stm pulse signal
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin
	
	enc_func :
	for index in 1 to c_ENC_CH generate
		enc_top_inst : enc_top port map (							
			CLK			=> CLK,
			LRSTb		=> LRSTb,
			
			ENC_A		=> ENC_A(index),
			ENC_B		=> ENC_B(index),
			ENC_EN		=> ENC_EN(index),
			ENCDATA		=> ENCDATA(index),

			ENCLMT_EN	=> ENCLMT_EN(index),
			ENCLMT_TH	=> ENCLMT_TH(index), 
			ENC_INV		=> ENC_INV(index),
			ENC_LMT_OUT	=> s_ENC_LMT_OUT(index),
			ENC_LMT_DET => ENC_LMT_DET(index),
			ENC_ST		=> s_ENC_ST(index),
			ENC_EXT		=> sa_ENC_EXT(index),
			ENC_DIR		=> s_ENC_DIR(index),
			ENC_STM_PLS	=> s_ENC_STM_PLS(index)
		);

		ENCPHASE(2 * (index - 1))			<= ENC_A(index);
		ENCPHASE(2 * (index - 1) + 1)		<= ENC_B(index);

		P_ENC_STM(index)		<= C_ENC_STM(index)(0) when (ENC_MODE = "00") else C_ENC_STM(index)(1) when (ENC_MODE = "01") else C_ENC_STM(index)(2) when (ENC_MODE = "10") else C_ENC_STM(index)(3);
		s_ENC_ST(index)			<= '0'		when (P_ENC_STM(index) = 0 )	else STM_STOP(P_ENC_STM(index));
		sa_ENC_EXT(index)		<= "000"	when (P_ENC_STM(index) = 0 )	else STM_M(P_ENC_STM(index));
		s_ENC_DIR(index)		<= '0'		when (P_ENC_STM(index) = 0 )	else STMDIR(P_ENC_STM(index));
		s_ENC_STM_PLS(index)	<= '0'		when (P_ENC_STM(index) = 0 )	else STM_POUT(P_ENC_STM(index));

		P_STM_ENC(index)	<= C_STM_ENC(index)(0) when (ENC_MODE = "00") else C_STM_ENC(index)(1) when (ENC_MODE = "01") else C_STM_ENC(index)(2) when (ENC_MODE = "10") else C_STM_ENC(index)(3);
		MORE_INH_CW(index)	<= '0' when (P_STM_ENC(index) = 0 ) else s_ENC_LMT_OUT(P_STM_ENC(index));
		MORE_INH_CCW(index)	<= '0' when (P_STM_ENC(index) = 0 ) else s_ENC_LMT_OUT(P_STM_ENC(index));
	end generate enc_func;
	
end RTL;
