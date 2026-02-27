-------------------------------------------------
--File Name : ppmc_cmdchk.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/08
--Ver       : 1.00
--Doc       : Pulse zero stop Inhibit
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      : 2005/09/15
--Ver       : 5.00
--Doc       : Delete checking "PLS SETTING = 0"
--Changed by Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_cmdchk is
    port(
        CLK             : in std_logic;                             -- Clock 20MHZ
        nMRST           : in std_logic;                             -- power on reset(Active Low)
        UP_DOWN         : in std_logic;         -- toku add 2004.03.17
        ACC_ENB         : in std_logic;                             --
        COMMAND_HIT     : in std_logic;                             -- command check timing(Active High)
        STATE           : in std_logic_vector( 3 downto 0);
        COMMAND         : in std_logic_vector( 3 downto 0);
        LOW_FREQ        : in std_logic_vector(15 downto 0);
        HIGH_FREQ       : in std_logic_vector(15 downto 0);
        PULSE_REG       : in std_logic_vector(15 downto 0);
        HIGH_FREQ_REG   : in std_logic_vector(15 downto 0);         -- high freqency register
        LOW_FREQ_REG    : in std_logic_vector(15 downto 0);         -- low freqency register
        SPEED           : in std_logic_vector(15 downto 0);

        EC              : out std_logic_vector( 1 downto 0);        -- error code
        STOP_F          : out std_logic;                            -- stop flag
        HIGH_LOW_F      : out std_logic;                            -- high_low flag
        CONST_F         : out std_logic;                            -- const flag
        L_CONST_F       : out std_logic                             -- l const flag
        );
end ppmc_cmdchk;

architecture RTL of ppmc_cmdchk is


    constant IDLE           : std_logic_vector( 3 downto 0) :="0001";
    constant C_STOP         : std_logic_vector( 3 downto 0) :="0000";
    constant C_HIGH_LOW     : std_logic_vector( 3 downto 0) :="0010";
    constant C_CONST        : std_logic_vector( 3 downto 0) :="0011";
    constant C_L_CONST      : std_logic_vector( 3 downto 0) :="0100";
    constant EC_NONE        : std_logic_vector( 1 downto 0) :="00";
    constant EC_PRMT        : std_logic_vector( 1 downto 0) :="01";
    constant EC_IRGL        : std_logic_vector( 1 downto 0) :="10";
    constant EC_BUSY        : std_logic_vector( 1 downto 0) :="11";
    constant FREQZERO       : std_logic_vector(15 downto 0) := (others => '0');
    constant PLSZERO        : std_logic_vector(15 downto 0) := (others => '0');
    signal stop             : std_logic;
    signal high_low         : std_logic;
    signal const            : std_logic;
    signal l_const          : std_logic;
    signal error_code       : std_logic_vector( 1 downto 0);

begin

-- output assign
    STOP_F       <= stop;
    HIGH_LOW_F   <= high_low;
    CONST_F      <= const;
    L_CONST_F    <= l_const;
    EC           <= error_code;


-- command check
    process(nMRST, CLK)
    begin
        if(nMRST= '0')  then
            stop        <= '0';
            high_low    <= '0';
            const       <= '0';
            l_const     <= '0';
            error_code  <= EC_NONE;
        elsif(CLK'event and CLK='1') then
            if(command_hit ='1') then

                if(command = C_STOP) then
                    if(STATE=IDLE) then
                        error_code  <= EC_BUSY;
                        stop        <= '0';
                    else
                        error_code  <= EC_NONE;
                        stop        <= '1';
                    end if;

                elsif(command = C_HIGH_LOW) then
                    if(STATE=IDLE) then
                        if(LOW_FREQ_REG = FREQZERO
                           or HIGH_FREQ_REG = FREQZERO
                           or (LOW_FREQ_REG > HIGH_FREQ_REG)) then
                            error_code  <= EC_PRMT;
                            high_low    <= '0';
                        else
                            error_code  <= EC_NONE;
                            high_low    <= '1';
                        end if;
                    else
                        error_code  <= EC_BUSY;
                        high_low    <= '0';
                    end if;

                elsif(command = C_CONST) then
                    if(STATE=IDLE) then
                        if(LOW_FREQ_REG = FREQZERO) then
                            error_code  <= EC_PRMT;
                            const       <= '0';
                        else
                            error_code  <= EC_NONE;
                            const       <= '1';
                        end if;
                    else
                        error_code  <= EC_BUSY;
                        const       <= '0';
                    end if;

                elsif(command = C_L_CONST) then
                    if(STATE=IDLE) then
                        if(LOW_FREQ_REG = FREQZERO) then
                            error_code  <= EC_PRMT;
                            l_const     <= '0';
                        else
                            error_code  <= EC_NONE;
                            l_const     <= '1';
                        end if;
                    else
                        error_code  <= EC_BUSY;
                        l_const     <= '1';
                    end if;

                else
                    error_code  <= EC_IRGL;
                    stop        <= '0';
                    high_low    <= '0';
                    const       <= '0';
                    l_const     <= '0';
                end if;
            else
                error_code  <= error_code;
                stop        <= '0';
                high_low    <= '0';
                const       <= '0';
                l_const     <= '0';
            end if;
        end if;
    end process;

end RTL;
