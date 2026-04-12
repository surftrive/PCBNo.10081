-------------------------------------------------
--File Name : ppmc_phgen.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/06/17
--Ver       : 3.00
--Doc       : [null] of [STATE others] is deleted.
--          : [STATE S_INIT] is added.
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------
--Date      :2005/09/15
--Ver       :5.00
--Doc       :Fixed the logic of phase_out
--Changed by Kazutoshi Tokunaga
-------------------------------------------------


library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_phgen is
    port(
        nMRST           : in std_logic;                             -- power on reset or CPU reset(active Low)
        CLK             : in std_logic;                             -- Clock 20MHZ
        PULSE_OUT_EDGE  : in std_logic;                             -- pulse in edge
        STOP            : in std_logic;                             -- stop pulse
        INIT_REG        : in std_logic_vector( 7 downto 0);         -- init_reg
        DIR             : in std_logic;                             -- dir

        S1              : out std_logic;
        S2              : out std_logic;
        S3              : out std_logic;
        S4              : out std_logic
        );
end ppmc_phgen;


architecture RTL of ppmc_phgen is


    signal STATE    : std_logic_vector(7 downto 0);
    constant P1     : std_logic_vector(7 downto 0)  :="00000001";
    constant P2     : std_logic_vector(7 downto 0)  :="00000010";
    constant P3     : std_logic_vector(7 downto 0)  :="00000100";
    constant P4     : std_logic_vector(7 downto 0)  :="00001000";
    constant P5     : std_logic_vector(7 downto 0)  :="00010000";
    constant P6     : std_logic_vector(7 downto 0)  :="00100000";
    constant P7     : std_logic_vector(7 downto 0)  :="01000000";
    constant P8     : std_logic_vector(7 downto 0)  :="10000000";

    constant ST1    : std_logic_vector(3 downto 0)  :="0001";
    constant ST2    : std_logic_vector(3 downto 0)  :="0011";
    constant ST3    : std_logic_vector(3 downto 0)  :="0010";
    constant ST4    : std_logic_vector(3 downto 0)  :="0110";
    constant ST5    : std_logic_vector(3 downto 0)  :="0100";
    constant ST6    : std_logic_vector(3 downto 0)  :="1100";
    constant ST7    : std_logic_vector(3 downto 0)  :="1000";
    constant ST8    : std_logic_vector(3 downto 0)  :="1001";

    signal pulse        : std_logic;
    signal SOUT         : std_logic_vector(3 downto 0);

begin

    S1 <= SOUT(0);
    S2 <= SOUT(1);
    S3 <= SOUT(2);
    S4 <= SOUT(3);

-- pulse in
    pulse <= pulse_out_edge;

-- State Machine

    process(nMRST, CLK)
    begin
        if(nMRST= '0')  then
            SOUT    <= (others => '0');
            STATE   <= P2;

        elsif(CLK'event and CLK='1') then
            case STATE is

                when P1 =>
                    SOUT    <= ST1;
                    if(INIT_REG(6)='0') then
                        STATE   <= P2;
                    elsif(STOP='1') then
                        STATE   <= P1;
                    elsif(pulse='0') then
                        STATE   <= P1;
                    elsif(DIR='0') then
                        STATE   <= P2;
                    else
                        STATE   <= P8;
                    end if;

                when P2 =>
                    SOUT    <= ST2;
                    if(STOP='1') then
                        STATE   <= P2;
                    elsif(pulse='0') then
                        STATE   <= P2;
                    elsif(DIR='0') then
                        if(INIT_REG(6)='1') then
                            STATE   <= P3;
                        else
                            STATE   <= P4;
                        end if;
                    else
                        if(INIT_REG(6)='1') then
                            STATE   <= P1;
                        else
                            STATE   <= P8;
                        end if;
                    end if;

                when P3 =>
                    SOUT    <= ST3;
                    if(INIT_REG(6)='0') then
                        STATE   <= P4;
                    elsif(STOP='1') then
                        STATE   <= P3;
                    elsif(pulse='0') then
                        STATE   <= P3;
                    elsif(DIR='0') then
                        STATE   <= P4;
                    else
                        STATE   <= P2;
                    end if;

                when P4 =>
                    SOUT    <= ST4;
                    if(STOP='1') then
                        STATE   <= P4;
                    elsif(pulse='0') then
                        STATE   <= P4;
                    elsif(DIR='0') then
                        if(INIT_REG(6)='1') then
                            STATE   <= P5;
                        else
                            STATE   <= P6;
                        end if;
                    else
                        if(INIT_REG(6)='1') then
                            STATE   <= P3;
                        else
                            STATE   <= P2;
                        end if;
                    end if;

                when P5 =>
                    SOUT    <= ST5;
                    if(INIT_REG(6)='0') then
                        STATE   <= P6;
                    elsif(STOP='1') then
                        STATE   <= P5;
                    elsif(pulse='0') then
                        STATE   <= P5;
                    elsif(DIR='0') then
                        STATE   <= P6;
                    else
                        STATE   <= P4;
                    end if;

                when P6 =>
                    SOUT    <= ST6;
                    if(STOP='1') then
                        STATE   <= P6;
                    elsif(pulse='0') then
                        STATE   <= P6;
                    elsif(DIR='0') then
                        if(INIT_REG(6)='1') then
                            STATE   <= P7;
                        else
                            STATE   <= P8;
                        end if;
                    else
                        if(INIT_REG(6)='1') then
                            STATE   <= P5;
                        else
                            STATE   <= P4;
                        end if;
                    end if;

                when P7 =>
                    SOUT    <= ST7;
                    if(INIT_REG(6)='0') then
                        STATE   <= P8;
                    elsif(STOP='1') then
                        STATE   <= P7;
                    elsif(pulse='0') then
                        STATE   <= P7;
                    elsif(DIR='0') then
                        STATE   <= P8;
                    else
                        STATE   <= P6;
                    end if;

                when P8 =>
                    SOUT    <= ST8;
                    if(STOP='1') then
                        STATE   <= P8;
                    elsif(pulse='0') then
                        STATE   <= P8;
                    elsif(DIR='0') then
                        if(INIT_REG(6)='1') then
                            STATE   <= P1;
                        else
                            STATE   <= P2;
                        end if;
                    else
                        if(INIT_REG(6)='1') then
                            STATE   <= P7;
                        else
                            STATE   <= P6;
                        end if;
                    end if;

                when others =>
                    SOUT    <= (others => '0');
                    STATE   <= P2;
            end case;
        end if;
    end process;

end RTL;
