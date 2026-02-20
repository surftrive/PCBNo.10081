-------------------------------------------------
--File Name : gpio_id.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/20
--Ver       : 3.00
--Doc       : Update its Version
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity gpio_id is
    port(
        LA          : in std_logic_vector(4 downto 0);          -- local address
        IDSEL       : in std_logic;                             -- ID select
        LRDb        : in std_logic;                             -- local data read signal

        IDDO        : out std_logic_vector( 7 downto 0)         -- local data output
        );
end gpio_id;


architecture RTL of gpio_id is

    signal READ_COMP    : std_logic_vector( 6 downto 0);

begin

    READ_COMP <= (IDSEL & LRDb & LA(4 downto 0));

    process(READ_COMP) begin
        case (READ_COMP) is
            when "1000000"=> IDDO <= "01000111";        --47
            when "1000001"=> IDDO <= "01010000";        --50
            when "1000010"=> IDDO <= "01001001";        --49
            when "1000011"=> IDDO <= "01001111";        --4F
            when "1000100"=> IDDO <= "01011111";        --5F
            when "1000101"=> IDDO <= "01010110";        --56
            when "1000110"=> IDDO <= "01100101";        --65
            when "1000111"=> IDDO <= "01110010";        --72
            when "1001000"=> IDDO <= "01011111";        --5F
            when "1001001"=> IDDO <= "00110011";        --33
            when "1001010"=> IDDO <= "00101110";        --2E
            when "1001011"=> IDDO <= "00110000";        --30
            when "1001100"=> IDDO <= "00110000";        --30
            when "1001101"=> IDDO <= "00100000";        --20
            when "1001110"=> IDDO <= "00100000";        --20
            when "1001111"=> IDDO <= "00100000";        --20
            when "1010000"=> IDDO <= "00100000";        --20
            when "1010001"=> IDDO <= "00100000";        --20
            when "1010010"=> IDDO <= "00100000";        --20
            when "1010011"=> IDDO <= "00100000";        --20
            when "1010100"=> IDDO <= "00100000";        --20
            when "1010101"=> IDDO <= "00100000";        --20
            when "1010110"=> IDDO <= "00100000";        --20
            when "1010111"=> IDDO <= "00100000";        --20
            when "1011000"=> IDDO <= "00100000";        --20
            when "1011001"=> IDDO <= "00100000";        --20
            when "1011010"=> IDDO <= "00100000";        --20
            when "1011011"=> IDDO <= "00100000";        --20
            when "1011100"=> IDDO <= "00100000";        --20
            when "1011101"=> IDDO <= "00100000";        --20
            when "1011110"=> IDDO <= "00100000";        --20
            when "1011111"=> IDDO <= "00100000";        --20
            when others => IDDO <= (others =>'0');
        end case;
    end process;

end RTL;
