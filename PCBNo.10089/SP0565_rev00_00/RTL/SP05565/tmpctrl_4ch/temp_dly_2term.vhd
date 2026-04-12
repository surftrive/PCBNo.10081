-------------------------------------------------
--File Name : temp_dly_2term.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/22
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
use IEEE.STD_LOGIC_1164.ALL;

entity temp_dly_2term is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 PLS :in std_logic;
			 TERM :in std_logic;
			 PLSDD :out std_logic);
end temp_dly_2term;

architecture RTL of temp_dly_2term is

signal PLSD : std_logic;
signal preg : std_logic;

begin

	PLSDD <= preg;

	process(CLK, LRSTb) begin
		if (LRSTb = '0') then
			PLSD <= '0';
			preg <= '0';
		elsif (CLK'event and CLK = '1') then
			if (TERM = '1') then
				PLSD <= PLS;
				preg <= PLSD;
			end if;
		end if;
	end process;

end RTL;
