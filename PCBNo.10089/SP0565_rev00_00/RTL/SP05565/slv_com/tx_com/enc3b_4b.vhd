-------------------------------------------------
--File Name : enc3b_4b.vhd
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

entity enc3b_4b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(2 downto 0);   --HGF
        DATA_ie     : in std_logic_vector(1 downto 0);   --ie
        DATAOUT     : out std_logic_vector(3 downto 0);  --jhgf
        RD_OUT      : out std_logic;                     -- '0' -> RD=negative, '1' -> RD=positive
        VALID4B     : out std_logic
    );
end enc3b_4b;

architecture RTL of enc3b_4b is

begin

   process(CLK,RSTb)
    begin
        if(RSTb='0') then
            DATAOUT <= (others=>'0');
            RD_OUT <= '0';
            VALID4B <= '0';
        elsif(CLK'event and CLK='0') then
            if(ENB='1') then
                case DATAIN is

                    when "000" =>     --Dx.0
                        if(RD_IN='0') then
                            DATAOUT <= "1101";
                        else
                            DATAOUT <= "0010";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "001" =>     --Dx.1
                        DATAOUT <= "1001";
                        RD_OUT <= RD_IN;

                    when "010" =>     --Dx.2
                        DATAOUT <= "1010";
                        RD_OUT <= RD_IN;

                    when "011" =>     --Dx.3
                        if(RD_IN='0') then
                            DATAOUT <= "0011";
                        else
                            DATAOUT <= "1100";
                        end if;
                        RD_OUT <= RD_IN;

                    when "100" =>     --Dx.4
                        if(RD_IN='0') then
                            DATAOUT <= "1011";
                        else
                            DATAOUT <= "0100";
                        end if;
                        RD_OUT <= not RD_IN;

                    when "101" =>     --Dx.5
                        DATAOUT <= "0101";
                        RD_OUT <= RD_IN;

                    when "110" =>     --Dx.6
                        DATAOUT <= "0110";
                        RD_OUT <= RD_IN;

                    when "111" =>     --Dx.7
                        if(RD_IN='0') then
                            if(DATA_ie="11") then
                                DATAOUT <= "1110";
                            else
                                DATAOUT <= "0111";
                            end if;
                        else
                            if(DATA_ie="00") then
                                DATAOUT <= "0001";
                            else
                                DATAOUT <= "1000";
                            end if;
                        end if;
                        RD_OUT <= not RD_IN;
                    when others =>
                        DATAOUT <= (others=>'0');
                        RD_OUT <= '0';
                end case;
                VALID4B <= '1';
            else
                if(RD_IN='0') then
                    DATAOUT <= "1010";
                else
                    DATAOUT <= "0101";
                end if;

                if(IDLE_INS='1') then
                    VALID4B <= '1';
                else
                    VALID4B <= '0';
                end if;
                RD_OUT <= RD_IN;

            end if;
        end if;
    end process;

end RTL;