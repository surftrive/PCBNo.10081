-------------------------------------------------
--File Name : ppmc_acc_tim_gen.vhd
--Project	: S3IO
--
--Date		: 2002/10/11
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

entity ppmc_acc_tim_gen is
	port (
		clk			: in std_logic;
		rst			: in std_logic;
		acc_reg		: in std_logic_vector(15 downto 0 );
		acc_enb		: in std_logic;
		acc_pulse	: out std_logic
		);
end ppmc_acc_tim_gen;

architecture RTL of ppmc_acc_tim_gen is

	signal reg : std_logic_vector(15 downto 0 );

begin
	Start:process (rst, acc_enb, clk, reg, acc_reg)
	begin	  -- process
		if rst = '1' then
			reg<=(others=>'0');
			acc_pulse <= '0';
		elsif acc_enb = '0' then
			reg<=(others=>'0');
			acc_pulse <= '0';
		elsif clk'event and clk = '1' then
			if reg = acc_reg then
				acc_pulse <= '1';
				reg <= (others=>'0');
			else
				acc_pulse <= '0';
				reg <= reg + '1';
			end if;
		end if;
	end process;

end RTL;
