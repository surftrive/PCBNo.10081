-------------------------------------------------
--File Name : temp_plsdrv.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2003/07/22
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/08
--Ver       :
--Doc       : Add CLPORHTP
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      : 2005/09/15
--Ver       : 4.00
--Doc       : Delete Logic Settings
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_plsdrv is
    port (
        CLK         : in std_logic;
        LRSTb       : in std_logic;
        TERM        : in std_logic;
        PLSO        : in std_logic;
        COOL        : in std_logic;
        ENB         : in std_logic;
        CLON        : out std_logic;
        CLP         : out std_logic;
        HTON        : out std_logic;
        HTP         : out std_logic;
        CLPORHTP    : out std_logic
    );
end temp_plsdrv;

architecture RTL of temp_plsdrv is

signal pls : std_logic;
signal tcreg : std_logic;
signal plsreg : std_logic;
signal enbreg : std_logic;
signal enbregd : std_logic;
signal en : std_logic;
signal clenb : std_logic;
signal htenb : std_logic;

begin

    pls <= PLSO;
    en <= enbregd and enbreg;
    clenb <= en and COOL;
    htenb <= en and not (COOL);
    CLON <= tcreg when clenb = '1' else '0';
    CLP <= plsreg when clenb = '1' else '0';
    HTON <= tcreg when htenb = '1' else '0';
    HTP <= plsreg when htenb = '1' else '0';
    CLPORHTP <= plsreg when en = '1' else '0';

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            enbreg <= '0';
            enbregd <= '0';
            plsreg <= '0';
            tcreg <= '0';
        elsif (CLK'event and CLK = '1') then
            if (ENB = '0') then
                enbreg <= '0';
            elsif (TERM = '1') then
                enbreg <= '1';
                enbregd <= enbreg;
                plsreg <= pls;
                tcreg <= '1';
            end if;
        end if;
    end process;

end RTL;
