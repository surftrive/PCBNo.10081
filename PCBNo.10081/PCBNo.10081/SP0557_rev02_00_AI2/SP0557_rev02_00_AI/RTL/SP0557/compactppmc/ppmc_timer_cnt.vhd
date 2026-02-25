------------------------------------------------
--File Name : ppmc_timer_cnt.vhd
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

entity ppmc_timer_cnt is
	port (
		clk			: in std_logic;
		rst			: in std_logic;
		pulse_clk	: in std_logic;
		speed		: in std_logic_vector(15 downto 0 );
		tm_clr		: in std_logic;
		pout		: out std_logic;
		pulse_out	: out std_logic;
		div_mode	: in std_logic
		);
end ppmc_timer_cnt;


architecture RTL of ppmc_timer_cnt is

	constant FULL : std_logic_vector(18 downto 0 ) := "1111010000100100000";
	constant HALF : std_logic_vector(18 downto 0 ) := "0111101000010010000";
	signal reg : std_logic_vector(18 downto 0 );

begin
	Start:process (rst, clk, tm_clr, pulse_clk, reg, speed, div_mode)
	begin	  -- process
		if rst = '1' then
			reg <= (others=>'0');
			pout <= '0';
		elsif clk'event and clk = '1' then
			if tm_clr = '1' then
				reg <= (others=>'0');
				pout <= '0';
			elsif pulse_clk = '1' then
				if reg > speed then
					reg <= reg - speed;
					pout <= '0';
				elsif div_mode = '1' then
					reg <= reg + (FULL - speed);
					pout <= '1';
				else
					reg <= FULL ;
					pout <= '1';
				end if;
			else
				reg <= reg;						-- toku add 2004.01.13
				pout <= '0';
			end if;
		end if;
	end process;

	pulse_out <= '0' when reg < HALF else '1';

end RTL;
