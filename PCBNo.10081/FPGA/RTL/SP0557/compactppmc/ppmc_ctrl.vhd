-------------------------------------------------
--File Name : ppmc_ctrl.vhd
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
--			: Debug STATE machine [Illegal STATE]
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      : 2020/08/20
--Ver       : 1.01
--Doc       : change limit mask of MORE_INH_CW/CCW
--			    : to use MORE_INH_CW/CCW for encoder limit in S118M/S120M.
--          : delete limit mask contorol of MORE_INH_CW/CCW.
--Changed by Y.Aoki
-------------------------------------------------
--Date      : 2021/07/29
--Ver       : 1.02
--Doc		: ppmc_pls_cntのカウンタへのpulse_reg値ロードを同期化するため、step_zero条件にs_pls_ld='0'を追加
--			    =>IDLEから各ステートへ遷移した直後のstep_zero判定をしないようにする
--			  「stop_code<="XX";」(不定)を「stop_code<=(others=>'-');」(don't care)に修正
--Changed by Y.Aoki
-------------------------------------------------


library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_ctrl is
    port(
        CLK             : in std_logic;                             -- Clock 20MHZ
        LRSTb           : in std_logic;                             -- power on reset or CPU reset(active Low)
        nSRESET         : out std_logic;                            -- software reset
        COMMAND_REG     : in std_logic_vector( 7 downto 0);         -- command reg (bits [6:4] unused; 8-bit register map bus width)
        PULSE_REG       : in std_logic_vector(15 downto 0);         -- pulse reg
        HIGH_FREQ_REG   : in std_logic_vector(15 downto 0);         -- high freq reg
        LOW_FREQ_REG    : in std_logic_vector(15 downto 0);         -- low freq reg
        ACC_RATE_REG    : in std_logic_vector(15 downto 0);         -- acc rate reg
        SLOW_DOWN_REG   : in std_logic_vector(15 downto 0);         -- slow down reg
        LIMIT_MASK_REG  : in std_logic_vector( 7 downto 0);         -- limit mask reg
        PRE_PLS_REG     : in std_logic_vector( 7 downto 0);         -- Pre Pulse reg
        MORE_PLS_REG    : in std_logic_vector( 15 downto 0);         -- More Pulse reg
        LATCH_L         : in std_logic;                             -- LATCH signal
        COMMAND_CNG     : in std_logic;                             -- command change signal
        COMMAND_HIT     : out std_logic;                            -- command_hit
        STATUS          : out std_logic_vector( 7 downto 0);        -- status
        LCW             : in std_logic;                             -- limit lcw
        LCCW            : in std_logic;                             -- limit lccw
        MORE_INH_CW     : in std_logic; -- More Drive Inhibit CW
        MORE_INH_CCW    : in std_logic; -- More Drive Inhibit CCW

        PLS0_STOP_INH   : in std_logic; -- Pulse zero stop Inhibit

        ENB_START       : out std_logic;                            -- pls_ld signal
        P_STOP          : out std_logic;                            -- pulse stop signal
        START_STOP      : in std_logic;                             -- start_stop
        DIR             : out std_logic;                            -- '0'= CW  ,'1'= CCW
        STOP            : in std_logic;                             -- stop signal
        PULSE_OUT       : in std_logic;                             -- pulse out
        pulse_out_edge  : in std_logic;                             -- pulse out edge
        LIMIT_MASK      : out std_logic_vector( 7 downto 0);        -- limit mask reg out
        HIGH_REG        : out std_logic_vector(15 downto 0);        -- high reg out
        LOW_REG         : out std_logic_vector(15 downto 0);        -- low reg out
        ACC_REG         : out std_logic_vector(15 downto 0);        -- acc reg out
        SLOW_REG        : out std_logic_vector(15 downto 0);        -- slow reg out
        PRE_REG         : out std_logic_vector( 7 downto 0);         -- Pre Pulse reg
        PLS_LD          : out std_logic;                            -- pls_ld signal
        UP_DOWN_OUT     : out std_logic;                            -- up_dwon cont
        ACC_ENB_OUT     : out std_logic;                            -- acc_enb
        SLOW            : in std_logic;                             -- slow flag
        PULSE_CNT       : in std_logic_vector(15 downto 0);         -- command reg
        SPEED           : in std_logic_vector(15 downto 0);         --
        COMMAND         : out std_logic_vector( 3 downto 0);        -- command
        STATE_OUT       : out std_logic_vector( 3 downto 0);        -- state out
        EC              : in std_logic_vector( 1 downto 0);         -- error_code
        STOP_F          : in std_logic;                             -- stop flag
        HIGH_LOW_F      : in std_logic;                             -- high_low flag
        CONST_F         : in std_logic;                             -- const flag
        L_CONST_F       : in std_logic                              -- l const flag
        );
end ppmc_ctrl;



architecture RTL of ppmc_ctrl is


    signal STATE            : std_logic_vector( 3 downto 0);
    constant IDLE           : std_logic_vector( 3 downto 0) :="0001";
    constant S_HIGH_LOW     : std_logic_vector( 3 downto 0) :="0010";
    constant S_CONST        : std_logic_vector( 3 downto 0) :="0100";
    constant S_L_CONST      : std_logic_vector( 3 downto 0) :="1000";

    --signal lim_f            : std_logic;
    signal limit_lcw        : std_logic;
    signal limit_lccw       : std_logic;
    signal limit_cond       : std_logic;

    signal stop_sig         : std_logic;
    signal step_zero        : std_logic;
	signal stop_cond		: std_logic;

    signal low_speed        : std_logic;
    signal high_speed       : std_logic;
    signal dir_o            : std_logic;
    signal dir_pre          : std_logic;
    signal acc_enb          : std_logic;
    signal up_down          : std_logic;

    signal stop_code        : std_logic_vector( 1 downto 0);
    signal high_reg_o       : std_logic_vector(15 downto 0);
    signal low_reg_o        : std_logic_vector(15 downto 0);
    signal acc_reg_o        : std_logic_vector(15 downto 0);
    signal slow_reg_o       : std_logic_vector(15 downto 0);
    signal limit_mask_o     : std_logic_vector( 7 downto 0);
    signal pre_reg_o        : std_logic_vector( 7 downto 0);
    signal more_reg_o       : std_logic_vector( 15 downto 0);

    signal more_cnt         : std_logic_vector( 15 downto 0);
    signal more_flg         : std_logic;
    signal s_more_inh_cw    : std_logic;
    signal s_more_inh_ccw   : std_logic;

    signal s_pls_ld         : std_logic;

-- Prevent register sharing of s_pls_ld and ENB_START (separate timing functions)
attribute syn_preserve : boolean;
attribute syn_preserve of s_pls_ld  : signal is true;
attribute syn_preserve of ENB_START : signal is true;

begin

    STATE_OUT   <= STATE;
    DIR         <= dir_o;
    ACC_ENB_OUT <= acc_enb;
    UP_DOWN_OUT <= up_down;
    HIGH_REG    <= high_reg_o;
    LOW_REG     <= low_reg_o;
    ACC_REG     <= acc_reg_o;
    SLOW_REG    <= slow_reg_o;
    LIMIT_MASK  <= limit_mask_o;
    PRE_REG     <= pre_reg_o;

    PLS_LD      <= s_pls_ld;

-- command reg ,command_err check
    process(LRSTb, CLK)
    begin
        if(LRSTb= '0')  then
            dir_pre <= '0';
            COMMAND     <= (others=>'0');
            COMMAND_HIT <= '0';
            nSRESET     <= '0';
        elsif(CLK'event and CLK='1') then
            if(COMMAND_CNG='1' and LATCH_L='1') then
                dir_pre     <= COMMAND_REG(7);
                COMMAND     <= COMMAND_REG(3 downto 0);
                command_hit <= '1';
                if(COMMAND_REG(3 downto 0)="1111") then
                    nSRESET     <='0';
                else
                    nSRESET     <='1';
                end if;
            else
                dir_pre <= dir_pre;
                COMMAND     <= (others=>'0');
                command_hit <= '0';
                nSRESET     <= '1';
            end if;
        end if;
    end process;

--error
        STATUS <= (SLOW & stop_code & low_speed & high_speed & START_STOP & EC);

-- limitter
    limit_lcw   <= (not limit_mask_o(5)  xor LCW) and limit_mask_o(1);--limit_lcw H:検出、L：
    limit_lccw  <= (not limit_mask_o(6)  xor LCCW) and limit_mask_o(2);
--    s_more_inh_cw  <= MORE_INH_CW  and limit_mask_o(1);
--    s_more_inh_ccw <= MORE_INH_CCW and limit_mask_o(2);
    s_more_inh_cw  <= MORE_INH_CW;  --change for S118M,S120M 2020/08/20
    s_more_inh_ccw <= MORE_INH_CCW; --change for S118M,S120M 2020/08/20


-- State move conditions
    process(LRSTb, CLK)
    begin
        if(LRSTb= '0')  then
            more_cnt    <= (others => '0');
            limit_cond <= '0';
            more_flg <= '0';
        elsif(CLK'event and CLK='1') then
            if (STATE = IDLE) then
                more_cnt    <= (others => '0');
                limit_cond <= '0';
                more_flg <= '0';
            elsif (limit_cond = '1') then
                more_cnt    <= (others => '0');
                limit_cond <= '1';
                more_flg <= '0';
            elsif ((((not dir_o) and s_more_inh_cw) or (dir_o and s_more_inh_ccw))= '1') then
                more_cnt    <= (others => '0');
                limit_cond <= '1';
                more_flg <= '0';
            elsif (more_flg = '1') then
                if ((more_cnt >= more_reg_o) and (PULSE_OUT = '0')) then
                    more_cnt    <= (others => '0');
                    limit_cond <= '1';
                    more_flg <= '0';
                elsif (pulse_out_edge = '1') then
                    more_cnt    <= more_cnt + '1';
                    limit_cond <= '0';
                    more_flg <= '1';
                else
                    more_cnt    <= more_cnt;
                    limit_cond <= '0';
                    more_flg <= '1';
                end if;
            elsif ((((not dir_o) and limit_lcw) or (dir_o and limit_lccw))= '1') then
                more_cnt    <= (others => '0');
                limit_cond <= '0';
                more_flg <= '1';
            else
                more_cnt    <= (others => '0');
                limit_cond <= '0';
                more_flg <= '0';
            end if;
        end if;
    end process;

    process(LRSTb, CLK)
    begin
        if(LRSTb= '0')  then
            low_speed <= '0';
            high_speed <= '0';
        elsif(CLK'event and CLK='1') then
            if (SPEED=low_reg_o) then
                low_speed <= '1';
                high_speed <= '0';
            elsif (SPEED=high_reg_o) then
                low_speed <= '0';
                high_speed <= '1';
            else
                low_speed <= '0';
                high_speed <= '0';
            end if;
        end if;
    end process;

    stop_sig <= STOP and (not PULSE_OUT);
    step_zero <= '1' when ((STOP = '0') and (PULSE_CNT = "0000000000000000") and s_pls_ld='0')
            else '0';
    stop_cond <= (step_zero or stop_sig) when (PLS0_STOP_INH = '0')
            else '0';

--    process(LRSTb, CLK)
--    begin
--        if(LRSTb= '0')  then
--            step_zero <= '0';
--            stop_sig <= '0';
--            stop_cond <= '0';
--        elsif(CLK'event and CLK='1') then
--            stop_sig <= STOP and (not PULSE_OUT);
--            if ((STOP = '0') and (PULSE_CNT = "0000000000000000")) then
--                step_zero <= '1';
--            else
--                step_zero <= '0';
--            end if;
--            if (PLS0_STOP_INH = '0') then
--                stop_cond <= (step_zero or stop_sig);
--            else
--                stop_cond <= '0';
--            end if;
--        end if;
--    end process;

-- State Machine

    process(LRSTb, CLK)
    begin
        if(LRSTb= '0')  then
            --lim_f       <= '0';
            acc_enb     <= '0';
            ENB_START   <= '0';
            up_down     <= '1';
            s_pls_ld      <= '0';
            P_STOP      <= '1';
            dir_o       <= '0';
            stop_code   <= "11";
            high_reg_o  <= (others => '0');
            low_reg_o   <= (others => '0');
            acc_reg_o   <= (others => '0');
            slow_reg_o  <= (others => '0');
            limit_mask_o  <= (others => '0');
            pre_reg_o   <= (others => '0');
            more_reg_o  <= (others => '0');
            STATE       <= IDLE;

        elsif(CLK'event and CLK='1') then
            limit_mask_o <= LIMIT_MASK_REG;

            case STATE is

                when IDLE =>
                    high_reg_o  <= HIGH_FREQ_REG;
                    low_reg_o   <= LOW_FREQ_REG;
                    acc_reg_o   <= ACC_RATE_REG;
                    dir_o       <= dir_pre;
                    slow_reg_o  <= SLOW_DOWN_REG;
                    pre_reg_o   <= PRE_PLS_REG;
                    more_reg_o  <= MORE_PLS_REG;

                    if(HIGH_LOW_F='1') then
                        s_pls_ld      <= '1';
                        up_down     <= '1';
                        acc_enb     <= '1';
                        ENB_START   <= '1';
                        P_STOP      <= '0';
                        stop_code   <= "XX";
                        STATE       <= S_HIGH_LOW;
                    elsif(CONST_F='1') then
                        s_pls_ld      <= '1';
                        up_down     <= '1';
                        acc_enb     <= '0';
                        ENB_START   <= '1';
                        P_STOP      <= '0';
                        stop_code   <= "XX";
                        STATE       <= S_CONST;
                    elsif(L_CONST_F='1') then
                        s_pls_ld      <= '1';
                        up_down     <= '1';
                        acc_enb     <= '0';
                        ENB_START   <= '1';
                        P_STOP      <= '0';
                        stop_code   <= "XX";
                        STATE       <= S_L_CONST;
                    else
                        --lim_f       <= '0';
                        s_pls_ld      <= '0';
                        acc_enb     <= '0';
                        up_down     <= '0';
                        ENB_START   <= '0';
                        P_STOP      <= '1';
                        stop_code   <= stop_code;
                        STATE       <= IDLE;
                    end if;

                when S_HIGH_LOW =>
                    ENB_START   <= '0';
                    s_pls_ld      <= '0';
                    dir_o       <= dir_o;
                    if(STOP_F='1') then                                             -- stop command
                        stop_code   <= "10";
                        STATE       <= IDLE;
                    elsif(stop_cond='1') then                        -- stop signal = 0
                        stop_code   <= "00";
                        STATE       <= IDLE;
                    elsif(limit_cond='1') then      -- limit
                        stop_code   <= "01";
                        STATE       <= IDLE;
                    elsif((SLOW='1') and (PLS0_STOP_INH = '0')) then
                        if(low_speed = '1') then
                            up_down     <= '0';
                            acc_enb     <= '0';
                            stop_code   <= "XX";
                            STATE       <= S_HIGH_LOW;
                        else
                            up_down     <= '0';
                            acc_enb     <= '1';
                            stop_code   <= "XX";
                            STATE       <= S_HIGH_LOW;
                        end if;
                    elsif(high_speed = '1') then
                        up_down     <= '0';
                        acc_enb     <= '0';
                        STATE       <= S_HIGH_LOW;
                    else
                        stop_code   <= "XX";
                        STATE       <= S_HIGH_LOW;
                    end if;

                when S_CONST =>
                    ENB_START   <= '0';
                    s_pls_ld      <= '0';
                    dir_o       <= dir_o;
                    if(STOP_F = '1') then                         -- stop command
                        stop_code   <= "10";
                        STATE       <= IDLE;
                    elsif(stop_cond='1') then                        -- stop signal = 0
                        stop_code   <= "00";
                        STATE       <= IDLE;
                    elsif(limit_cond='1') then      -- limit
                        stop_code   <= "01";
                        STATE       <= IDLE;
                    else
                        acc_enb     <= '0';
                        stop_code   <= "XX";
                        STATE       <= S_CONST;
                    end if;

                when S_L_CONST =>
                    ENB_START   <= '0';
                    s_pls_ld      <= '0';
                    dir_o       <= dir_o;
                    if(STOP_F = '1') then                         -- stop command
                        stop_code   <= "10";
                        STATE       <= IDLE;
                    elsif(limit_cond='1') then      -- limit
                        stop_code   <= "01";
                        STATE       <= IDLE;
                    else
                        acc_enb     <= '0';
                        stop_code   <= "XX";
                        STATE       <= S_L_CONST;
                    end if;

                when others =>
                        dir_o       <= dir_o;
                        stop_code   <= "11";
                        STATE       <= IDLE;
                        more_cnt    <= more_cnt;
            end case;
        end if;
    end process;

end RTL;
