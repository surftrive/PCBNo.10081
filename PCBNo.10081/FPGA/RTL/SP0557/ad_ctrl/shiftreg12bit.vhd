-------------------------------------------------
--File Name : shiftreg12bit.vhd
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

entity shiftreg12bit is
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		RISE	: in	std_logic;
		ADC_SDI	: in	std_logic;
		AD_DATA	: out	std_logic_vector(11 downto 0);
		RDEN	: in	std_logic
	);
end shiftreg12bit;

architecture RTL of shiftreg12bit is

signal	reg	: std_logic_vector(11 downto 0);

begin

	AD_DATA <= reg;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			reg <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (RISE = '1') then
				if (RDEN ='1') then
					reg <= reg(10 downto 0) & ADC_SDI;
				end if;
			end if;
		end if;
	end process;

end RTL;
