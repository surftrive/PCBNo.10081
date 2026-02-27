-------------------------------------------------
--File Name : gpio_op_reg.vhd
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

entity gpio_op_reg is
	port(
		CLK			: in std_logic;								-- clock 20MHz
		LRSTb		: in std_logic;								-- local reset
		LDI			: in std_logic_vector(7 downto 0);			-- local data in
		REGSEL		: in std_logic;								-- regster select
		LWEb		: in std_logic;								-- local write enable
		LATCH_L		: in std_logic;								-- local latch
		GPO			: out std_logic_vector(7 downto 0)			-- regster data out
		);
end gpio_op_reg;

architecture RTL of gpio_op_reg is

	signal WRITEENB		: std_logic;
	signal REG			: std_logic_vector(7 downto 0);

begin

	WRITEENB	<= REGSEL and (not LWEb);


	process (CLK, LRSTb)
	begin
		if (LRSTb = '0') then
			REG <= (others => '0');
			GPO <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (WRITEENB = '1') then
				REG <= LDI;
			end if;
			if (LATCH_L = '1') then
				GPO <= REG;
			end if;
		end if;
	end process;

end RTL;
