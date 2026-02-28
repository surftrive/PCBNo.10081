-------------------------------------------------
--File Name : dec4b_3b.vhd
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

entity dec4b_3b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_DEL    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(9 downto 0);   --jhgfiedcba (bits [1:0] unused by 4b/3b decoder; 10-bit bus width required by 8b10b protocol)
        DATAOUT     : out std_logic_vector(2 downto 0);  --HGF
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=pogitive
        VALID3B     : out std_logic;
        KERR3B      : out std_logic;
        KOUT3B      : out std_logic
    );
end dec4b_3b;

architecture RTL of dec4b_3b is
-- Consume unused input port bits to suppress CL246 (10-bit bus width required by 8b10b protocol)
signal s_unused_datain : std_logic;
attribute syn_keep : boolean;
attribute syn_keep of s_unused_datain : signal is true;
begin
    s_unused_datain <= DATAIN(1) or DATAIN(0);

    process(CLK,RSTb)
    begin
        if(RSTb='0') then
            DATAOUT <= (others=>'0');
            RD_OUT <= '0';
            VALID3B <= '0';
            KERR3B <= '0';
            KOUT3B <= '0';
        elsif(CLK'event and CLK='0') then
            if(ENB='1') then
                case DATAIN(9 downto 6) is

                    when "0010" =>     --D.x.0 neg
                        if(RD_IN='0') then
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        else
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        end if;
                        DATAOUT <= "000";
                        KOUT3B <= '0';

                    when "1101" =>     --D.x.0 pog
                        if(RD_IN='0') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "000";
                        KOUT3B <= '0';

                    when "1001" =>     --D.x.1
                        KERR3B <= '0';
                        RD_OUT <= RD_IN;
                        KOUT3B <= '0';
                        VALID3B <= '1';
                        if(DATAIN(5 downto 2)="0000" and DATAIN(8)/=DATAIN(9)) then
                            DATAOUT <= "110";
                        else
                            DATAOUT <= "001";
                        end if;

                    when "1010" =>     --D.x.2 or K.28.5
                        KERR3B <= '0';
                        RD_OUT <= RD_IN;
                        if(DATAIN(5 downto 2)="0000" and DATAIN(8)/=DATAIN(9)) then
                            if(IDLE_DEL='1') then
                                VALID3B <= '0';
                            else
                                VALID3B <= '1';
                            end if;
                            DATAOUT <= "101";
                            KOUT3B <= '1';
                        else
                            DATAOUT <= "010";
                            VALID3B <= '1';
                            KOUT3B <= '0';
                        end if;

                    when "0011" =>     --D.x.3 pog
                        if(RD_IN='0') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                        end if;
                        DATAOUT <= "011";
                        RD_OUT <= RD_IN;
                        KOUT3B <= '0';

                    when "1100" =>     --D.x.3 neg
                        if(RD_IN='1') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                        end if;
                        DATAOUT <= "011";
                        RD_OUT <= RD_IN;
                        KOUT3B <= '0';

                    when "0100" =>     --D.x.4 neg
                        if(RD_IN='1') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "100";
                        KOUT3B <= '0';

                    when "1011" =>     --D.x.4 pog
                        if(RD_IN='0') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "100";
                        KOUT3B <= '0';

                    when "0101" =>     --D.x.5 or K.28.5
                        RD_OUT <= RD_IN;
                        if(DATAIN(5 downto 2)="0000" and DATAIN(8)/=DATAIN(9)) then
                            KERR3B <= '1';
                            DATAOUT <= "010";
                            VALID3B <= '0';
                            KOUT3B <= '1';
                        else
                            if(IDLE_DEL='1') then
                                VALID3B <= '0';
                                KOUT3B <= '1';
                            else
                                VALID3B <= '1';
                                KOUT3B <= '0';
                            end if;
                            DATAOUT <= "101";
                            KERR3B <= '0';
                        end if;

                    when "0110" =>     --D.x.6 or K.28.1
                        RD_OUT <= RD_IN;
                        if(DATAIN(5 downto 2)="0000" and DATAIN(9)/=DATAIN(8))then
                            DATAOUT <= "001";
                            VALID3B <= '0';
                            KOUT3B <= '1';
                            KERR3B <= '1';
                        else
                            DATAOUT <= "110";
                            VALID3B <= '1';
                            KOUT3B <= '0';
                            KERR3B <= '0';
                        end if;

                    when "0111" =>     --D.x.7 pog
                        if(RD_IN='0') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "111";
                        KOUT3B <= '0';

                    when "1000" =>     --D.x.7 neg
                        if(RD_IN='1') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "111";
                        KOUT3B <= '0';

                    when "1110" =>     --D.x.7 pog
                        if(RD_IN='0') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "111";
                        KOUT3B <= '0';

                    when "0001" =>     --D.x.7 neg
                        if(RD_IN='1') then
                            KERR3B <= '0';
                            VALID3B <= '1';
                            RD_OUT <= not RD_IN;
                        else
                            KERR3B <= '1';
                            VALID3B <= '0';
                            RD_OUT <= RD_IN;
                        end if;
                        DATAOUT <= "111";
                        KOUT3B <= '0';

                    when others =>
                        KERR3B <= '1';
                        DATAOUT <= "000";
                        RD_OUT <= '0';
                        KOUT3B <= '1';
                        VALID3B <= '0';
                end case;

            end if;
        end if;
    end process;

end RTL;