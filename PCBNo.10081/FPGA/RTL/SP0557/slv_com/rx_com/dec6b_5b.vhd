-------------------------------------------------
--File Name : dec6b_5b.vhd
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

entity dec6b_5b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_DEL    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(5 downto 0);   --iedcba
        DATAOUT     : out std_logic_vector(4 downto 0);  --EDCBA
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=pogitive
        VALID5B     : out std_logic;
        KERR5B      : out std_logic;
        KOUT5B      : out std_logic
    );
end dec6b_5b;

architecture RTL of dec6b_5b is

signal ERR_NEG : std_logic;
signal ERR_POS : std_logic;

-- Prevent merging of DATAOUT register with input register (8b10b decode pipeline)
attribute syn_preserve : boolean;
attribute syn_preserve of DATAOUT : signal is true;

begin

	ERR_NEG <= '1' when DATAIN="000000" or DATAIN="000001" or DATAIN="000010" or
						DATAIN="000100" or DATAIN="001000" or DATAIN="010000" or
						DATAIN="100000" or DATAIN="110000" else '0';
	ERR_POS <= '1' when DATAIN="001111" or DATAIN="011111" or DATAIN="101111" or
						DATAIN="110111" or DATAIN="111011" or DATAIN="111101" or
						DATAIN="111110" or DATAIN="111111" else '0';

    process(CLK,RSTb)
    begin
        if(RSTb='0') then
            DATAOUT <= (others=>'0');
            RD_OUT <= '0';
            VALID5B <= '0';
            KERR5B <= '0';
            KOUT5B <= '0';
        elsif(CLK'event and CLK='1') then
            if(ENB='1') then
                case DATAIN is

                    when "000110" =>     --D.0 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "00000";                        
                        KOUT5B <= '0';                        

                    when "111001" =>     --D.0 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "00000"; 
                        KOUT5B <= '0';

                    when "010001" =>     --D.1 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "00001";
                        KOUT5B <= '0';

                    when "101110" =>     --D.1 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "00001";
                        KOUT5B <= '0';

                    when "010010" =>     --D.2 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "00010";
                        KOUT5B <= '0';

                    when "101101" =>     --D.2 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "00010";
                        KOUT5B <= '0';

                    when "100011" =>     --D.3
                        KERR5B <= '0';
                        DATAOUT <= "00011";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "010100" =>     --D.4 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "00100";
                        KOUT5B <= '0';

                    when "101011" =>     --D.4 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "00100";
                        KOUT5B <= '0';

                    when "100101" =>     --D.5
                        KERR5B <= '0';
                        DATAOUT <= "00101";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "100110" =>     --D.6
                        KERR5B <= '0';
                        DATAOUT <= "00110";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "000111" =>     --D.7 neg
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
                        end if;
                        DATAOUT <= "00111";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';

                    when "111000" =>     --D.7 pog
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
                        end if;
                        DATAOUT <= "00111";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';

                    when "011000" =>     --D.8 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "01000";
                        KOUT5B <= '0';

                    when "100111" =>     --D.8 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "01000";
                        KOUT5B <= '0';

                    when "101001" =>     --D.9
                        KERR5B <= '0';
                        DATAOUT <= "01001";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "101010" =>     --D.10
                        KERR5B <= '0';
                        DATAOUT <= "01010";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "001011" =>     --D.11
                        KERR5B <= '0';
                        DATAOUT <= "01011";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "101100" =>     --D.12
                        KERR5B <= '0';
                        DATAOUT <= "01100";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "001101" =>     --D.13
                        KERR5B <= '0';
                        DATAOUT <= "01101";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "001110" =>     --D.14
                        KERR5B <= '0';
                        DATAOUT <= "01110";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "000101" =>     --D.15 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "01111";
                        KOUT5B <= '0';

                    when "111010" =>     --D.15 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "01111";
                        KOUT5B <= '0';

                    when "110110" =>     --D.16 neg
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "10000";
                        KOUT5B <= '0';

                    when "001001" =>     --D.16 pog
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "10000";
                        KOUT5B <= '0';

                    when "110001" =>     --D.17
                        KERR5B <= '0';
                        DATAOUT <= "10001";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "110010" =>     --D.18
                        KERR5B <= '0';
                        DATAOUT <= "10010";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "010011" =>     --D.19
                        KERR5B <= '0';
                        DATAOUT <= "10011";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "110100" =>     --D.20
                        KERR5B <= '0';
                        DATAOUT <= "10100";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "010101" =>     --D.21
                        KERR5B <= '0';
                        DATAOUT <= "10101";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "010110" =>     --D.22
                        KERR5B <= '0';
                        DATAOUT <= "10110";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "101000" =>     --D.23 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "10111";
                        KOUT5B <= '0';

                    when "010111" =>     --D.23 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "10111";
                        KOUT5B <= '0';

                    when "001100" =>     --D.24 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "11000";
                        KOUT5B <= '0';

                    when "110011" =>     --D.24 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "11000";
                        KOUT5B <= '0';

                    when "011001" =>     --D.25
                        KERR5B <= '0';
                        DATAOUT <= "11001";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "011010" =>     --D.26
                        KERR5B <= '0';
                        DATAOUT <= "11010";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "100100" =>     --D.27 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "11011";
                        KOUT5B <= '0';

                    when "011011" =>     --D.27 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "11011";
                        KOUT5B <= '0';

                    when "011100" =>     --D.28
                        KERR5B <= '0';
                        DATAOUT <= "11100";
                        RD_OUT <= RD_IN;
                        KOUT5B <= '0';
                        VALID5B <= '1';

                    when "000011" =>     --K.28 neg                        
                        KOUT5B <= '1';						
						VALID5B <= '1';
						DATAOUT <= "11100";
                        if(IDLE_DEL='1') then
                            VALID5B <= '0';
                        else                            
							VALID5B <= '1';
                        end if;
						if(RD_IN='0') then
							RD_OUT <= RD_IN;
							KERR5B <= '1';
						else
							RD_OUT <= not RD_IN;
							KERR5B <= '0';
						end if;

                    when "111100" =>     --K.28 pog                        
                        KOUT5B <= '1';
						KERR5B <= '0';
						DATAOUT <= "11100"; 
                        if(IDLE_DEL='1') then
                            VALID5B <= '0';
                        else                                                      
							VALID5B <= '1';
                        end if;
						if(RD_IN='0') then								
							RD_OUT <= not RD_IN;
							KERR5B <= '0';
						else
							RD_OUT <= RD_IN;
							KERR5B <= '1';
						end if;

                    when "011101" =>     --D.29 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "11101";
                        KOUT5B <= '0';

                    when "100010" =>     --D.29 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "11101";
                        KOUT5B <= '0';

                    when "011110" =>     --D.30 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "11110";
                        KOUT5B <= '0';                       

                    when "100001" =>     --D.30 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "11110";
                        KOUT5B <= '0';                       

                    when "110101" =>     --D.31 pog
                        if(RD_IN='0') then
                            KERR5B <= '0';
							 VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        else
                            KERR5B <= '1';
							 VALID5B <= '0';
							RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "11111";
                        KOUT5B <= '0';

                    when "001010" =>     --D.31 neg
                        if(RD_IN='0') then
                            KERR5B <= '1';
							VALID5B <= '0';
							RD_OUT <= RD_IN;
                        else
                            KERR5B <= '0';
							VALID5B <= '1';
							RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "11111";
                        KOUT5B <= '0';
									
                    when others =>
                        KERR5B <= '1';
                        DATAOUT <= (others=>'0');
                        KOUT5B <= '1';
                        VALID5B <= '0';
						if(ERR_NEG='1')then
							RD_OUT <= '0';
						elsif(ERR_POS='1') then
							RD_OUT <= '1';
						else
							RD_OUT <= RD_IN;
						end if;
                end case;

            end if;
        end if;
    end process;

end RTL;