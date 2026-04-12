-------------------------------------------------
--File Name : enc5b_6b.vhd
--Project   : S3IO
--
--Date      : 2007/12/18
--Ver       : 0.00
--Doc       : New Release
--Designed by Takemune Oshikawa
-------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity enc5b_6b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(4 downto 0);   --EDCBA
        DATAOUT     : out std_logic_vector(5 downto 0);  --iedcba
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=positive
        VALID6B     : out std_logic
    );
end enc5b_6b;

architecture RTL of enc5b_6b is

begin

    process(CLK,RSTb)
    begin
        if(RSTb='0') then
            DATAOUT <= (others=>'0');
            RD_OUT <= '0';
            VALID6B <= '0';
        elsif(CLK'event and CLK='1') then
            if(ENB='1') then
                case DATAIN is

                    when "00000" =>     --D.0
                        if(RD_IN='0') then
                            DATAOUT <= "111001";
                        else
                            DATAOUT <= "000110";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "00001" =>     --D.1
                        if(RD_IN='0') then
                            DATAOUT <= "101110";
                        else
                            DATAOUT <= "010001";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "00010" =>     --D.2
                        if(RD_IN='0') then
                            DATAOUT <= "101101";
                        else
                            DATAOUT <= "010010";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "00011" =>     --D.3
                        DATAOUT <= "100011";
                        RD_OUT <= RD_IN;

                    when "00100" =>     --D.4
                        if(RD_IN='0') then
                            DATAOUT <= "101011";
                        else
                            DATAOUT <= "010100";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "00101" =>     --D.5
                        DATAOUT <= "100101";
                        RD_OUT <= RD_IN;

                    when "00110" =>     --D.6
                        DATAOUT <= "100110";
                        RD_OUT <= RD_IN;

                    when "00111" =>     --D.7
                        if(RD_IN='0') then
                            DATAOUT <= "000111";
                        else
                            DATAOUT <= "111000";
                        end if;
                        RD_OUT <= RD_IN;

                    when "01000" =>     --D.8
                        if(RD_IN='0') then
                            DATAOUT <= "100111";
                        else
                            DATAOUT <= "011000";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "01001" =>     --D.9
                        DATAOUT <= "101001";
                        RD_OUT <= RD_IN;

                    when "01010" =>     --D.10
                        DATAOUT <= "101010";
                        RD_OUT <= RD_IN;

                    when "01011" =>     --D.11
                        DATAOUT <= "001011";
                        RD_OUT <= RD_IN;

                    when "01100" =>     --D.12
                        DATAOUT <= "101100";
                        RD_OUT <= RD_IN;

                    when "01101" =>     --D.13
                        DATAOUT <= "001101";
                        RD_OUT <= RD_IN;

                    when "01110" =>     --D.14
                        DATAOUT <= "001110";
                        RD_OUT <= RD_IN;

                    when "01111" =>     --D.15
                        if(RD_IN='0') then
                            DATAOUT <= "111010";
                        else
                            DATAOUT <= "000101";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "10000" =>     --D.16
                        if(RD_IN='0') then
                            DATAOUT <= "110110";
                        else
                            DATAOUT <= "001001";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "10001" =>     --D.17
                        DATAOUT <= "110001";
                        RD_OUT <= RD_IN;

                    when "10010" =>     --D.18
                        DATAOUT <= "110010";
                        RD_OUT <= RD_IN;

                    when "10011" =>     --D.19
                        DATAOUT <= "010011";
                        RD_OUT <= RD_IN;

                    when "10100" =>     --D.20
                        DATAOUT <= "110100";
                        RD_OUT <= RD_IN;

                    when "10101" =>     --D.21
                        DATAOUT <= "010101";
                        RD_OUT <= RD_IN;

                    when "10110" =>     --D.22
                        DATAOUT <= "010110";
                        RD_OUT <= RD_IN;

                    when "10111" =>     --D.23
                        if(RD_IN='0') then
                            DATAOUT <= "010111";
                        else
                            DATAOUT <= "101000";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "11000" =>     --D.24
                        if(RD_IN='0') then
                            DATAOUT <= "110011";
                        else
                            DATAOUT <= "001100";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "11001" =>     --D.25
                        DATAOUT <= "011001";
                        RD_OUT <= RD_IN;

                    when "11010" =>     --D.26
                        DATAOUT <= "011010";
                        RD_OUT <= RD_IN;

                    when "11011" =>     --D.27
                        if(RD_IN='0') then
                            DATAOUT <= "011011";
                        else
                            DATAOUT <= "100100";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "11100" =>     --D.28
                        DATAOUT <= "011100";
                        RD_OUT <= RD_IN;

                    when "11101" =>     --D.29
                        if(RD_IN='0') then
                            DATAOUT <= "011101";
                        else
                            DATAOUT <= "100010";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "11110" =>     --D.30
                        if(RD_IN='0') then
                            DATAOUT <= "011110";
                        else
                            DATAOUT <= "100001";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "11111" =>     --D.31
                        if(RD_IN='0') then
                            DATAOUT <= "110101";
                        else
                            DATAOUT <= "001010";
                        end if;
                        RD_OUT <= not RD_IN;
                    when others =>
                        DATAOUT <= (others=>'0');
                        RD_OUT <= '0';
                end case;
                VALID6B <= '1';

            else
                if(RD_IN='0') then
                    DATAOUT <= "111100";
                else
                    DATAOUT <= "000011";
                end if;
                RD_OUT <= not RD_IN;

                if(IDLE_INS='1') then
                    VALID6B <= '1';
                else
                    VALID6B <= '0';
                end if;

            end if;
        end if;
    end process;

end RTL;