-------------------------------------------------
--File Name : ppmc_top.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2003/10/26
--Ver       : 4.00
--Doc       : [1/16step] is set to 1/2.
--Changed by Jun Inagaki
-------------------------------------
--Date      : 2005/09/15
--Ver       : 5.00
--Doc       : Pulse zero stop Inhibit
--          : Debug STATE machine [Illegal STATE]
--          : [LCW&LCCW] is synchronized with a clock.
--          : Delete PWM and ENB
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      :2008/09/24
--Ver       :6.00
--Doc       :Added CURRENT_DOWN
--Changed by J.I
-------------------------------------------------
--Date      :2008/12/18
--Ver       :7.00
--Doc       :[CURRENT_DOWN] is simplified
--Changed by J.I
-------------------------------------------------
--Date      :2008/02/22
--Ver       :8.00
--Doc       :Added Mannual Slow_down signal
--Changed by Yuuki Takao
------------------------------------------------
--Date      :2020/01/31
--Ver       :8.01
--Doc       :Added PULSE_REG output port for comparing Encoder count
--           Added extension contorol for constant voltage STM
--Changed by Y.Aoki
------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_top_S118M is
    port(
        CLK         : in std_logic;                             -- Clock 20MHZ
        LA          : in std_logic_vector(4 downto 0);          -- local address
        NSb         : in std_logic;                             -- node select
        IDSb        : in std_logic;                             -- ID select
        LGSb        : in std_logic;                             -- ID select
        LDI         : in std_logic_vector( 7 downto 0);         -- local data input
        LDO         : out std_logic_vector( 7 downto 0);        -- local data output
        LRDb        : in std_logic;                             -- local data read signal
        LWEb        : in std_logic;                             -- local data write enable signal
        LATCH       : in std_logic;                             -- latch signal
        LOAD        : in std_logic;                             -- load signal
        LRSTb       : in std_logic;                             -- power on reset or CPU reset(active Low)

        MCLK        : in std_logic;                             -- 500khz clock
        KCLK        : in std_logic;                             -- 1khz clock
        POUT        : out std_logic;                            -- Pulse Out
        DIR         : out std_logic;                            -- direction    0:CW  1:CCW
        CURRENT_DOWN: out std_logic;                            -- CURRENT_DOWN 0:UP  1:DOWN
        S1          : out std_logic;                            -- phase output1
        S2          : out std_logic;                            -- phase output2
        S3          : out std_logic;                            -- phase output3
        S4          : out std_logic;                            -- phase output4
        LCW         : in std_logic;                             -- lcw limit
        LCCW        : in std_logic;                             -- lccw limit
        MORE_INH_CW : in std_logic; -- More Drive Inhibit CW
        MORE_INH_CCW: in std_logic; -- More Drive Inhibit CCW
        PLS0_STOP_INH   : in std_logic; -- Pulse zero stop Inhibit
        MPI         : in std_logic_vector(7 downto 0);          -- pararell data input
        MPO_A       : out std_logic_vector(7 downto 0);         -- pararell data output A
        MPO_B       : out std_logic_vector(7 downto 0);         -- pararell data output B

        SSEL        : in  std_logic;
        MSEL        : in  std_logic_vector(3 downto 1);
        M           : out std_logic_vector(3 downto 1);
        LIMIT_LOGIC : out std_logic_vector(1 downto 0);
        START_STOP  : out std_logic
        );
end ppmc_top_S118M;

architecture RTL of ppmc_top_S118M is

signal  s_S1 : std_logic;
signal  s_S2 : std_logic;
signal  s_S3 : std_logic;
signal  s_S4 : std_logic;

component fc_dec
    port(
        NSb         : in std_logic;                             -- node select
        IDSb        : in std_logic;                             -- ID select
        LGSb        : in std_logic;                             -- logger select
        LATCH       : in std_logic;                             -- latch signal
        LOAD        : in std_logic;                             -- load signal

        REGSEL      : out std_logic;                            -- register select(Active High)
        IDSEL       : out std_logic;                            -- id select(Active High)
        LOGSEL      : out std_logic;                            -- log select(Active High)
        LATCH_L     : out std_logic;                            -- local latch signal(Active High)
        LOAD_L      : out std_logic                             -- local load signal(Active High)
        );
end component;

component fc_sel
    port(
        NSb         : in std_logic;                             -- node select
        IDDO        : in std_logic_vector(7 downto 0);          -- ID data bus
        LOGDO       : in std_logic_vector(7 downto 0);          -- LOG data bus
        REGDO       : in std_logic_vector(7 downto 0);          -- regster data bus

        LDO         : out std_logic_vector(7 downto 0)          -- local data out
        );
end component;

component ppmc_id
    port(
        IDSEL       : in std_logic;                             -- ID select
        LRDb        : in std_logic;                             -- local data read signal
        LA          : in std_logic_vector(4 downto 0);          -- local address

        IDDO        : out std_logic_vector( 7 downto 0)         -- local data output
        );
end component;


component ppmc_reg_S118M
    port(
        LRSTb       : in std_logic;                             -- local reset
        CLK         : in std_logic;                             -- clock 20MHz
        LA          : in std_logic_vector(4 downto 0);          -- local address
        LDI         : in std_logic_vector(7 downto 0);          -- local data
        REGDO       : out std_logic_vector( 7 downto 0);        -- local data output
        REGSEL      : in std_logic;                             -- regster select
        LWEb        : in std_logic;                             -- local write enable
        LATCH_L     : in std_logic;                             -- local latch signal
        LRDb        : in std_logic;                             -- local read enable
        LOAD_L      : in std_logic;                             -- local load signal

        MCLK        : in std_logic;                             -- mclock 500kHz
        KCLK        : in std_logic;                             -- 1khz clock
        LCW         : in std_logic;                             --
        LCCW        : in std_logic;                             --
        MORE_INH_CW : in std_logic; -- More Drive Inhibit CW
        MORE_INH_CCW: in std_logic; -- More Drive Inhibit CCW
        PLS0_STOP_INH   : in std_logic; -- Pulse zero stop Inhibit
        MPI         : in std_logic_vector(7 downto 0);          -- pararell input
        MPO_A       : out std_logic_vector(7 downto 0);         -- pararell data output A
        MPO_B       : out std_logic_vector(7 downto 0);         -- pararell data output B
        S1          : out std_logic;                            -- phase output1
        S2          : out std_logic;                            -- phase output2
        S3          : out std_logic;                            -- phase output3
        S4          : out std_logic;                            -- phase output4
        POUT        : out std_logic;                            -- Pulse Out
        DIR         : out std_logic;                            -- direction    0:CW  1:CCW
        CURRENT_DOWN: out std_logic;                            -- CURRENT_DOWN 0:UP  1:DOWN

        SSEL        : in  std_logic;
        MSEL        : in  std_logic_vector(3 downto 1);
        M           : out std_logic_vector(3 downto 1);
        LIMIT_LOGIC : out std_logic_vector(1 downto 0);
        STRT_STP    : out std_logic
        );
end component;

    signal REGSEL   : std_logic;
    signal IDSEL    : std_logic;
    --signal LOGSEL   : std_logic;
    signal LATCH_L  : std_logic;
    signal LOAD_L   : std_logic;
    signal IDDO     : std_logic_vector(7 downto 0);
    signal REGDO    : std_logic_vector(7 downto 0);
    signal s_LCW    : std_logic;
    signal s_LCCW   : std_logic;
    signal s_MPO_A  : std_logic_vector(7 downto 0);

begin
--------------process-----------------------------------------
--
  MPO_A <= s_MPO_A;
  S1 <= s_S1 and s_MPO_A(0);
  S2 <= s_S2 and s_MPO_A(0);
  S3 <= s_S3 and s_MPO_A(0);
  S4 <= s_S4 and s_MPO_A(0);

--[LCW&LCCW] is synchronized with a clock.
process (CLK, LRSTb) begin
    if (LRSTb = '0') then
        s_LCW   <= '0';
        s_LCCW  <= '0';
    elsif (CLK'event and CLK='1') then
        if LCW = '1' then
            s_LCW <= '1';
        else
            s_LCW <= '0';
        end if;
        if LCCW = '1' then
            s_LCCW <= '1';
        else
            s_LCCW <= '0';
        end if;
    end if;
end process;

fc_dec_inst : fc_dec port map(
        NSb         => NSb,
        IDSb        => IDSb,
        LGSb        => LGSb,
        LATCH       => LATCH,
        LOAD        => LOAD,

        REGSEL      => REGSEL,
        IDSEL       => IDSEL,
        LOGSEL      => open,
        LATCH_L     => LATCH_L,
        LOAD_L      => LOAD_L
        );


fc_sel_inst : fc_sel port map(
        NSb         => NSb,
        IDDO        => IDDO,
        LOGDO       => "00000000",
        REGDO       => REGDO,

        LDO         => LDO
        );

ppmc_id_inst :ppmc_id
    port map(
        IDSEL   => IDSEL,
        LRDb    => LRDb,
        LA      => LA,

        IDDO    => IDDO
        );

ppmc_reg_S118M_inst : ppmc_reg_S118M port map(
        LRSTb       => LRSTb,
        CLK         => CLK,
        LA          => LA,
        LDI         => LDI,
        REGDO       => REGDO,
        REGSEL      => REGSEL,
        LWEb        => LWEb,
        LATCH_L     => LATCH_L,
        LRDb        => LRDb,
        LOAD_L      => LOAD_L,

        MCLK        => MCLK,
        KCLK        => KCLK,
        LCW         => s_LCW,
        LCCW        => s_LCCW,
        MORE_INH_CW => MORE_INH_CW,
        MORE_INH_CCW=> MORE_INH_CCW,
        PLS0_STOP_INH => PLS0_STOP_INH,
        MPI         => MPI,
        MPO_A       => s_MPO_A,
        MPO_B       => MPO_B,
        S1          => s_S1,
        S2          => s_S2,
        S3          => s_S3,
        S4          => s_S4,
        POUT        => POUT,
        DIR         => DIR,
        CURRENT_DOWN=> CURRENT_DOWN,

        SSEL        => SSEL,
        MSEL        => MSEL,
        M           => M,
        LIMIT_LOGIC => LIMIT_LOGIC,
        STRT_STP    => START_STOP    -- 2020/3/2 add output(S118M)
        );

end RTL;
