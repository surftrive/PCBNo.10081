-------------------------------------------------------------
--File Name : SLVADR_CNV.vhd
--Project   :
--
--Date      : 2004/09/08
--Ver       : 0.01
--Doc       : New Release
--Designed by Jun Inagaki
-------------------------------------------------------------
--Date      :
--Ver       :
--Doc       :
--Changed by
-------------------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------
entity slvadr_cnv is
    port(
        CLK         : in  std_logic;                    -- Clock 20MHZ
        nRST        : in  std_logic;                    -- Local Reset (active Low)
        DEC_IN      : in  std_logic_vector(7 downto 0) := "00000000";   --
        HEX_OUT     : out std_logic_vector(7 downto 0)      --
        );
end slvadr_cnv;
----------------------architecture---------------------------
architecture RTL of slvadr_cnv is
---------------component-------------------------------------
---------------type------------------------------------------
---------------signal----------------------------------------
signal  s_HEX_OUT   : std_logic_vector(7 downto 0);     --
signal  s_DEC_H_FLAG    : std_logic;        --
signal  s_DEC_L_FLAG    : std_logic;        --
signal  S3      : std_logic_vector(7 downto 0);     --
-- Prevent pruning and constant optimization of address bits
attribute syn_keep : boolean;
attribute syn_keep of s_HEX_OUT : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of s_HEX_OUT : signal is true;
---------------constant--------------------------------------
---------------begin-----------------------------------------
begin
    HEX_OUT <= s_HEX_OUT;
    s_DEC_H_FLAG <= '1' when DEC_IN(7 downto 4) > "0011" else
                    '0';

    s_DEC_L_FLAG <= '1' when DEC_IN(3 downto 0) > "1001" else
                    '0';

    S3 <= ("000" & DEC_IN(5 downto 4) & "000")+("00000" & DEC_IN(5 downto 4) & '0')+ ('0' & DEC_IN(3 downto 0));

--------------process-----------------------------------------
process(CLK,nRST) begin
    if (nRST = '0') then
        s_HEX_OUT <= (others => '0');
    elsif(CLK'event and CLK='1')then
        if s_DEC_H_FLAG = '1' or s_DEC_L_FLAG = '1' then
            s_HEX_OUT <= "11111111";
        else
            if S3 > "00011111" then
                s_HEX_OUT <= "11111111";
            else
                s_HEX_OUT <= S3;
            end if;
        end if;
    end if;
end process;
--------------------------------------------------------------
end RTL;