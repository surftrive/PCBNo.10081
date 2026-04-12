----------------------------------------------------------------------------------------------------
--File Name	: DAC081S101_top.vhd																					
--Project	: S124M(S3IO)
--Date		: 2025.11.25
--Ver		: 00_00
--Doc		: New Release
--			: S124M PCB No.10089
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
entity DAC081S101_top is																						
	port(
		CLK			: in	std_logic;						-- 20MHz CLK
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		P_DATA		: in	std_logic_vector(7 downto 0);	-- DATA
		SCLK		: out	std_logic;						-- OUTPUT to DAC(2.5MHz)
		SYNC		: out	std_logic;						-- OUTPUT to DAC
		DO			: out	std_logic						-- OUTPUT to DAC
	);
end DAC081S101_top;					
---------------architecture-------------------------------------------------------------------------
architecture RTL of DAC081S101_top is																								
-------------- constant ----------------------------------------------------------------------------

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_P_DATA_1d	: std_logic_vector(7 downto 0);
signal		s_DA_SEND		: std_logic;

---------------component----------------------------------------------------------------------------
component log_ca_DAC_ctrl
	port(
		CLK			: in	std_logic;						-- 20MHz CLK
		LRSTb		: in	std_logic;						-- Local Reset (active Low)
		P_DATA		: in	std_logic_vector(7 downto 0);	-- DATA
		DA_SEND		: in	std_logic;						-- Data Send Trigger
		SCLK		: out	std_logic;						-- OUTPUT to DAC(2.5MHz)
		SYNC		: out	std_logic;						-- OUTPUT to DAC
		DO			: out	std_logic						-- OUTPUT to DAC
	);
end component;

-------------------- begin -------------------------------------------------------------------------
begin
-- DAC TX start trig generate
	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_P_DATA_1d <= (others =>'0');
		elsif(CLK'event and CLK='1') then
			s_P_DATA_1d <= P_DATA;
		end if;
	end process;

	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_DA_SEND <= '0';
		elsif(CLK'event and CLK='1') then
			if s_P_DATA_1d = P_DATA then
				s_DA_SEND <= '0';
			else
				s_DA_SEND <= '1';
			end if;
		end if;
	end process;

-- DAC081S101CIMK I/F
	log_ca_DAC_ctrl_inst: log_ca_DAC_ctrl PORT MAP (
		CLK				=> CLK,
		LRSTb			=> LRSTb,
		P_DATA			=> P_DATA,
		DA_SEND			=> s_DA_SEND,
		SCLK			=> SCLK,
		SYNC			=> SYNC,
		DO				=> DO
	);


end RTL;
