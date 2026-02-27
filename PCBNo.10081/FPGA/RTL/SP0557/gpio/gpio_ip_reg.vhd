-------------------------------------------------
--File Name : gpio_ip_reg.vhd
--Project	: S3IO
--
--Date		: 2003/12/12
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity gpio_ip_reg is
	port(
		CLK			: in std_logic;								-- clock 20MHz
		LRSTb		: in std_logic;								-- local reset
		REGSEL		: in std_logic;								-- regster select
		LRDb		: in std_logic;								-- local read enable
		LOAD_L		: in std_logic;								-- local load
		REGDO		: out std_logic_vector(7 downto 0);			-- regster data out
		GPI			: in std_logic_vector(7 downto 0)
		);
end gpio_ip_reg;

architecture RTL of gpio_ip_reg is

	signal READENB		: std_logic;
	signal REG1			: std_logic_vector( 7 downto 0);
	signal REG2			: std_logic_vector( 7 downto 0);

-- Prevent combinational reduction of REG1 (input sampling register)
attribute syn_preserve : boolean;
attribute syn_preserve of REG1 : signal is true;

begin

	READENB		<= REGSEL and (not LRDb);
	REGDO		<= REG2 when READENB='1' else (others => '0');

	process (CLK, LRSTb)
	begin
		if (LRSTb = '0') then
			REG1 <= (others => '0');
			REG2 <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			REG1 <= GPI;
			if (LOAD_L = '1') then
				REG2 <= REG1;
			end if;
		end if;
	end process;

end RTL;
