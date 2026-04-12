-------------------------------------------------
--File Name : temp_ctst_reg.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2003/07/18
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/15
--Ver       : 4.00
--Doc       : Delete Logic Settings
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2010/12/24
--Ver		: 5.00
--Doc		: [100V MODE] Duty 4/8
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_ctst_reg is
    port ( CLK :in std_logic;
             LRSTb :in std_logic;
             SEL :in std_logic_vector(3 downto 0);
             LRDb :in std_logic;
             LWEb :in std_logic;
             LATCH_L :in std_logic;
             LOAD_L :in std_logic;
             LDI :in std_logic_vector(7 downto 0);
             CTSTDO :out std_logic_vector(7 downto 0);
             CUT :in std_logic_vector(3 downto 0);
			 LIMIT :out std_logic_vector(3 downto 0);
			 IDLING :out std_logic_vector(3 downto 0);
             CH0CLHTb :out std_logic;
             CH0TC_ENB :out std_logic;
             CH1CLHTb :out std_logic;
             CH1TC_ENB :out std_logic;
             CH2CLHTb :out std_logic;
             CH2TC_ENB :out std_logic;
             CH3CLHTb :out std_logic;
             CH3TC_ENB :out std_logic);
end temp_ctst_reg;

architecture RTL of temp_ctst_reg is

    signal WRP : std_logic_vector(3 downto 0);
    signal RDSEL : std_logic_vector(3 downto 0);
    signal CH0CSDO :std_logic_vector(7 downto 0);
    signal CH1CSDO :std_logic_vector(7 downto 0);
    signal CH2CSDO :std_logic_vector(7 downto 0);
    signal CH3CSDO :std_logic_vector(7 downto 0);
    signal CH0CTSTDO :std_logic_vector(7 downto 0);
    signal CH1CTSTDO :std_logic_vector(7 downto 0);
    signal CH2CTSTDO :std_logic_vector(7 downto 0);
    signal CH3CTSTDO :std_logic_vector(7 downto 0);
    signal ch0ctreg :std_logic_vector(7 downto 0);
    signal ch1ctreg :std_logic_vector(7 downto 0);
    signal ch2ctreg :std_logic_vector(7 downto 0);
    signal ch3ctreg :std_logic_vector(7 downto 0);
    signal ch0streg :std_logic;
    signal ch1streg :std_logic;
    signal ch2streg :std_logic;
    signal ch3streg :std_logic;
    signal ch0ctlatch :std_logic_vector(7 downto 0);
    signal ch1ctlatch :std_logic_vector(7 downto 0);
    signal ch2ctlatch :std_logic_vector(7 downto 0);
    signal ch3ctlatch :std_logic_vector(7 downto 0);

begin

    WRP <= SEL when LWEb = '0' else (others => '0');
    RDSEL <= SEL when LRDb = '0' else (others => '0');

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            ch0ctreg <= (others => '0');
            ch1ctreg <= (others => '0');
            ch2ctreg <= (others => '0');
            ch3ctreg <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (WRP(0) = '1' ) then
                ch0ctreg <= LDI;
            end if;
            if (WRP(1) = '1' ) then
                ch1ctreg <= LDI;
            end if;
            if (WRP(2) = '1' ) then
                ch2ctreg <= LDI;
            end if;
            if (WRP(3) = '1' ) then
                ch3ctreg <= LDI;
            end if;
        end if;
    end process;

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            ch0streg <= '0';
            ch1streg <= '0';
            ch2streg <= '0';
            ch3streg <= '0';
        elsif (CLK'event and CLK = '1') then
            if (LOAD_L = '1' ) then
                ch0streg <= CUT(0);
                ch1streg <= CUT(1);
                ch2streg <= CUT(2);
                ch3streg <= CUT(3);
            end if;
        end if;
    end process;

    CH0CSDO <= ch0streg & ch0ctreg(6 downto 0);
    CH1CSDO <= ch1streg & ch1ctreg(6 downto 0);
    CH2CSDO <= ch2streg & ch2ctreg(6 downto 0);
    CH3CSDO <= ch3streg & ch3ctreg(6 downto 0);

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            ch0ctlatch <= (others => '0');
            ch1ctlatch <= (others => '0');
            ch2ctlatch <= (others => '0');
            ch3ctlatch <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (LATCH_L = '1') then
                ch0ctlatch <= ch0ctreg;
                ch1ctlatch <= ch1ctreg;
                ch2ctlatch <= ch2ctreg;
                ch3ctlatch <= ch3ctreg;
            end if;
        end if;
    end process;

    CH0CLHTb   <= ch0ctlatch(1);
    CH0TC_ENB  <= ch0ctlatch(0);
    CH1CLHTb   <= ch1ctlatch(1);
    CH1TC_ENB  <= ch1ctlatch(0);
    CH2CLHTb   <= ch2ctlatch(1);
    CH2TC_ENB  <= ch2ctlatch(0);
    CH3CLHTb   <= ch3ctlatch(1);
    CH3TC_ENB  <= ch3ctlatch(0);

	LIMIT(0)	<= ch0ctlatch(4);
	LIMIT(1)	<= ch1ctlatch(4);
	LIMIT(2)	<= ch2ctlatch(4);
	LIMIT(3)	<= ch3ctlatch(4);
	IDLING(0)	<= ch0ctlatch(5);
	IDLING(1)	<= ch1ctlatch(5);
	IDLING(2)	<= ch2ctlatch(5);
	IDLING(3)	<= ch3ctlatch(5);


    CH0CTSTDO <= CH0CSDO when RDSEL(0) = '1' else (others => '0');
    CH1CTSTDO <= CH1CSDO when RDSEL(1) = '1' else (others => '0');
    CH2CTSTDO <= CH2CSDO when RDSEL(2) = '1' else (others => '0');
    CH3CTSTDO <= CH3CSDO when RDSEL(3) = '1' else (others => '0');

    CTSTDO <= CH0CTSTDO or CH1CTSTDO or CH2CTSTDO or CH3CTSTDO;

end RTL;
