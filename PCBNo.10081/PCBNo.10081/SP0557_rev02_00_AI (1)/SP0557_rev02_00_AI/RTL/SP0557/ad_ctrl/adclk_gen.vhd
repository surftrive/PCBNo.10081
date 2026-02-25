-------------------------------------------------
--File Name : adclk_gen.vhd
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adclk_gen is
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		ADSCLK	: out	std_logic;
		RISE	: out	std_logic;
		FALL	: out	std_logic
	);
end adclk_gen;

architecture RTL of adclk_gen is

signal count : std_logic_vector(2 downto 0);

begin

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			count	<= "000";
			RISE	<= '0';
			FALL	<= '0';
			ADSCLK	<= '0';
		elsif (CLK'event and CLK = '1') then
			count	<= count + 1;
			ADSCLK	<= count(2);

			if (count = "011") then
				RISE	<= '1';
			else
				RISE	<= '0';
			end if;
			
			if (count = "111") then
				FALL	<= '1';
			else
				FALL	<= '0';
			end if;
		end if;
	end process;

end RTL;
