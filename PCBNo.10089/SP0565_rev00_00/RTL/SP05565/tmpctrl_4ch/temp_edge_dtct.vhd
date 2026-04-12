-------------------------------------------------
--File Name : temp_edge_dtct.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
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

entity temp_edge_dtct is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 CH0CLHTb :in std_logic;
			 CH1CLHTb :in std_logic;
			 CH2CLHTb :in std_logic;
			 CH3CLHTb :in std_logic;
			 CHANGE :out std_logic_vector(3 downto 0));
end temp_edge_dtct;

architecture RTL of temp_edge_dtct is

signal CLHTb : std_logic_vector(3 downto 0);
signal CLHTbD : std_logic_vector(3 downto 0);

begin

	CLHTb <= CH3CLHTb & CH2CLHTb & CH1CLHTb & CH0CLHTb;
	CHANGE <= CLHTb xor CLHTbD;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CLHTbD <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			CLHTbD <= CLHTb;
		end if;
	end process;

end RTL;
