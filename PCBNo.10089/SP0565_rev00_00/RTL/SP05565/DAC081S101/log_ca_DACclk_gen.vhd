-------------------------------------------------------------
--File Name : log_ca_DACclk_gen.vhd
--Project   : DAC_CONTROL IP
--
--Date      : 2009/03/18
--Ver       : 0.00
--Doc       : DAC081S101 Controller
--Designed by JUN.INAGAKI
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
entity log_ca_DACclk_gen is
    port (
        CLK     :in std_logic;	-- 20MHz CLK
        LRSTb   :in std_logic;	-- Local Reset (active Low)
        SCLK    :out std_logic;	-- 2.5MHz
        RISE    :out std_logic	-- 2.5MHz One Shot RISE Pulse
    );
end log_ca_DACclk_gen;
----------------------architecture---------------------------
architecture RTL of log_ca_DACclk_gen is
---------------component-------------------------------------
---------------type-------------------------------------------
---------------constant---------------------------------------
constant c_Terminal : std_logic_vector(2 downto 0) :="100";
---------------signal-----------------------------------------
signal s_count : std_logic_vector(2 downto 0);
signal s_DACLK : std_logic;
---------------begin------------------------------------------
begin

    SCLK <= s_DACLK;

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            s_count <= (others =>'0');
            RISE <= '0';
            s_DACLK <= '0';
        elsif (CLK'event and CLK = '1') then
            s_count <= s_count + 1;
            s_DACLK <= s_count(2) ;
            if (s_count = c_Terminal) then
                RISE <= '1';
            else
                RISE <= '0';
            end if;
        end if;
    end process;

end RTL;