-------------------------------------------------
--File Name : temp_plssel.vhd
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
--Date		: 2010/12/25
--Ver		: 4.00
--Doc		: [100V MODE] Duty 4/8 -> */8
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity temp_plssel is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 PLS :in std_logic_vector(7 downto 0);
			 NUM :in std_logic_vector(2 downto 0);
			 NEG :in std_logic;
			 LIMIT :in std_logic;
			 IDLING	: in std_logic;
			 IDLM :in std_logic_vector(7 downto 0);
			 PLS0D :out std_logic;
			 TERM :in std_logic);
end temp_plssel;

architecture RTL of temp_plssel is

begin
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			PLS0D <= '0';
		elsif (CLK'event and CLK = '1') then
			if (TERM = '1') then
				if (NEG = '1') then
					PLS0D <= '0';
--				if (NEG = '1') and (IDLING = '0') then
--					PLS0D <= '0';
--				elsif (IDLING = '1') then
--					case IDLM(6 downto 4) is
--					when "000" => PLS0D <= PLS(0);
--					when "001" => PLS0D <= PLS(1);
--					when "010" => PLS0D <= PLS(2);
--					when "011" => PLS0D <= PLS(3);
--					when "100" => PLS0D <= PLS(4);
--					when "101" => PLS0D <= PLS(5);
--					when "110" => PLS0D <= PLS(6);
--					when "111" => PLS0D <= PLS(7);
--					when others  => PLS0D <= PLS(0);
--					end case;
				else
					if LIMIT = '0' then					--
						PLS0D <= PLS(conv_integer(NUM));--
					else								--
						--PLS0D <= PLS(conv_integer('0' & NUM(1 downto 0)));
						if IDLM(2 downto 0) < NUM then
							PLS0D <= PLS(conv_integer(IDLM(2 downto 0)));
						else
							PLS0D <= PLS(conv_integer(NUM));--
						end if;
					end if;								--
				end if;
			end if;
		end if;
	end process;

end RTL;
