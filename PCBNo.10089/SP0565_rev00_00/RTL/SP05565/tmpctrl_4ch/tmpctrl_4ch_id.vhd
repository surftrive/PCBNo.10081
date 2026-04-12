-------------------------------------------------
--File Name : tmpctrl_4ch_id.vhd
--Project   : 4ch Temperature Controller
--
--Date      : 2003/07/13
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/15
--Ver       : 4.00
--Doc       :
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tmpctrl_4ch_id is
    port (
        IDSEL :in  std_logic;
        LRDb  :in  std_logic;
        LA    :in  std_logic_vector(4 downto 0);
        IDDO  :out std_logic_vector(7 downto 0)
        );
end tmpctrl_4ch_id;

architecture RTL of tmpctrl_4ch_id is

    signal comp :std_logic_vector(6 downto 0);

begin

    comp <= (IDSEL & LRDb & LA(4 downto 0));

--===
--TEMPCTRL_4CH_Ver_4_00
--54 45 4D 50 43 54 52 4C
--5F 34 43 48 5F 56 65 72
--5F 34 5F 30 30 20 20 20
--20 20 20 20 20 20 20 20
--===

    process (comp) begin
        case (comp) is
            when "1000000" => IDDO <= "01010100"; --54 'T'
            when "1000001" => IDDO <= "01000101"; --45 'E'
            when "1000010" => IDDO <= "01001101"; --4D 'M'
            when "1000011" => IDDO <= "01010000"; --50 'P'
            when "1000100" => IDDO <= "01000011"; --43 'C'
            when "1000101" => IDDO <= "01010100"; --54 'T'
            when "1000110" => IDDO <= "01010010"; --52 'R'
            when "1000111" => IDDO <= "01001100"; --4C 'L'
            when "1001000" => IDDO <= "01011111"; --5F '_'
            when "1001001" => IDDO <= "00110100"; --34 '4'
            when "1001010" => IDDO <= "01000011"; --43 'C'
            when "1001011" => IDDO <= "01001000"; --48 'H'
            when "1001100" => IDDO <= "01011111"; --5F '_'
            when "1001101" => IDDO <= "01010110"; --56 'V'
            when "1001110" => IDDO <= "01100101"; --65 'e'
            when "1001111" => IDDO <= "01110010"; --72 'r'
            when "1010000" => IDDO <= "01011111"; --5F '_'
            when "1010001" => IDDO <= "00110100"; --34 '4'
            when "1010010" => IDDO <= "01011111"; --5F '_'
            when "1010011" => IDDO <= "00110000"; --30 '0'
            when "1010100" => IDDO <= "00110000"; --30 '0'
            when "1010101" => IDDO <= "00100000"; --20 ' '
            when "1010110" => IDDO <= "00100000"; --20 ' '
            when "1010111" => IDDO <= "00100000"; --20 ' '
            when "1011000" => IDDO <= "00100000"; --20 ' '
            when "1011001" => IDDO <= "00100000"; --20 ' '
            when "1011010" => IDDO <= "00100000"; --20 ' '
            when "1011011" => IDDO <= "00100000"; --20 ' '
            when "1011100" => IDDO <= "00100000"; --20 ' '
            when "1011101" => IDDO <= "00100000"; --20 ' '
            when "1011110" => IDDO <= "00100000"; --20 ' '
            when "1011111" => IDDO <= "00100000"; --20 ' '
            when others    => IDDO <= (others =>'0');
        end case;
    end process;
end RTL;
