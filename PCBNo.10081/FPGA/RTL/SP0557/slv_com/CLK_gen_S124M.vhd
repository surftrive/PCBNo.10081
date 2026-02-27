------------------------------------
--File Name : CLK_gen_S124M.vhd
--Project	: S124M
--Devise	: ECP5(Lattice)
--Date		: 2024/10/28
--Ver		: 0.00
--Doc		: New Release
--Designed by Kentaro Tsurumi
-------------------------------------


library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use IEEE.NUMERIC_STD.ALL;

entity CLK_gen_S124M is
	port(
		RSTb			: in	std_logic;		-- power on reset
		CLK_BASE_20M	: in	std_logic;		-- Clock 20MHZ

		CLK_PLL_10M		: out	std_logic;		-- Clock 10MHZ PLL synchronization
		CLK_PLL_20M		: out	std_logic;		-- Clock 20MHZ PLL synchronization
		CLK_PLL_100M	: out	std_logic;		-- Clock 100MHZ PLL synchronization
		CLK_PLL_100M_90	: out	std_logic;		-- Clock 100MHZ PLL synchronization 90shift
		LOCKED			: out	std_logic		-- PLL locked signal

		);
end CLK_gen_S124M;

architecture RTL of CLK_gen_S124M is

---------------constant-----------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal s_RST : std_logic;

component pll_gen
	PORT
	(
		CLKI	: in	std_logic;
		RST		: in	std_logic;

		CLKOP	: out	std_logic;		-- CLocK 100MHz
		CLKOS	: out	std_logic;		-- CLocK 100MHz 90 shift
		CLKOS2	: out	std_logic;		-- CLocK 20MHz
		CLKOS3	: out	std_logic;		-- CLocK 10MHz
		LOCK	: out	std_logic
	);
end component;

begin

	s_RST <= not RSTb;

PLL_inst : pll_gen PORT MAP
	(
		CLKI		=> CLK_BASE_20M,
		RST		 	=> s_RST,

		CLKOP		=> CLK_PLL_100M,
		CLKOS		=> CLK_PLL_100M_90,
		CLKOS2		=> CLK_PLL_20M,
		CLKOS3		=> CLK_PLL_10M,
		LOCK		=> LOCKED
	);

end RTL ;
