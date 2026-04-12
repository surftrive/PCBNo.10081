-------------------------------------------------
--File Name : temp_dlysel.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/22
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2010/12/24
--Ver		: 3.00
--Doc		: [100V MODE] Duty 4/8
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_dlysel is
	port ( DLY :in std_logic_vector(1 downto 0);
			 PLS0D :in std_logic;
			 PLS2D :in std_logic;
			 PLS4D :in std_logic;
			 PLS6D :in std_logic;
			 PLSOhf :out std_logic;
			 PLSO :out std_logic);
end temp_dlysel;

architecture RTL of temp_dlysel is

begin

	process (DLY, PLS0D,	PLS2D, PLS4D, PLS6D) begin
		case DLY is
			when "00" =>	PLSO	<= PLS0D;
							PLSOhf	<= PLS4D;
			when "01" =>	PLSO	<= PLS2D;
							PLSOhf	<= PLS6D;
			when "10" =>	PLSO	<= PLS4D;
							PLSOhf	<= PLS0D;
			when "11" =>	PLSO	<= PLS6D;
							PLSOhf	<= PLS2D;
			when others =>	PLSO	<= '0';
							PLSOhf	<= '0';
		end case;
	end process;

end RTL;
