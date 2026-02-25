-------------------------------------------------
--File Name : ppmc_reg.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/04/18
--Ver       : 0.01
--Doc       : Correction of a bug
--Changed by Jun Inagaki
-------------------------------------
--Date      : 2005/09/08
--Ver       : 2.00
--Doc       : Pulse zero stop Inhibit
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      :2005/09/15
--Ver       :5.00
--Doc       :Delete ENB and PWM
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
--			:  [UPDELAY] is deleted.
--Changed by J.I
-------------------------------------------------
--Date      :2010/07/12
--Ver       :8.00
--Doc       :Added outside_slow
--			:Added CTRL2_register
--Changed by Yuuki Takao
-------------------------------------------------
--Date      :2020/01/31
--Ver       :8.01
--Doc       :Added PULSE_REG output port for comparing Encoder count
--           (not changed function)
-- **caution** Set "VHDL2008" when compiling.
--Changed by Y.Aoki
------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_reg_S118M is
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
        STRT_STP  : out std_logic
        );
end ppmc_reg_S118M;

architecture RTL of ppmc_reg_S118M is

component ppmc_u_step_ext is
    port (
        CLK             : in    std_logic;
        nRST            : in    std_logic;
        SSEL            : in    std_logic;
        MSEL            : in    std_logic_vector(3 downto 1);
        INIT_REG_IN     : in    std_logic_vector(7 downto 0);
        POUT_IN         : in    std_logic;
        M               : out   std_logic_vector(3 downto 1);
        POUT            : out   std_logic
    );
end component;

component ppmc_plsgen is
  port (
        acc_enb         : in std_logic;
        acc_reg         : in std_logic_vector(15 downto 0 );
        clk             : in std_logic;
        div_mode        : in std_logic;
        high_reg        : in std_logic_vector(15 downto 0 );
        low_reg         : in std_logic_vector(15 downto 0 );
        pls_ld          : in std_logic;
        pulse_reg       : in std_logic_vector(15 downto 0 );
        rst             : in std_logic;
        pre_reg         : in std_logic_vector( 7 downto 0 );
        slow_reg        : in std_logic_vector(15 downto 0 );
        start_stop      : in std_logic;
        up_down         : in std_logic;
        pulse_clk       : in std_logic;
        outside_slow	: in std_logic;
		speed_out       : out std_logic_vector(15 downto 0 );
        pulse_cnt       : out std_logic_vector(15 downto 0 );
        pulse_out       : out std_logic;
        pulse_out_edge  : out std_logic;
        slow            : out std_logic;
        stop            : out std_logic
        );
end component;

component ppmc_enblr_S118M is
    port(
		nMRST			: in std_logic;							-- power on reset or CPU reset(active Low)
		CLK				: in std_logic;							-- Clock 20MHZ
        KCLK        	: in std_logic;                             -- 1khz clock
		ENB_START		: in std_logic;							-- enb start pulse
		P_STOP			: in std_logic;							-- pulse stop
		DOWNDELAY		: in std_logic_vector(7 downto 0);		--
		CURRENT_DOWN	: out std_logic;						--
		START_STOP		: out std_logic							-- start_stop
		);
end component;

component ppmc_dec
    port(
        LA              : in std_logic_vector(4 downto 0);      -- local address
        REGSEL          : in std_logic;                         -- register select

        SEL_INI         : out std_logic;                        -- initialize register select(active High)
        SEL_COM         : out std_logic;                        -- command register select(active High)
        SEL_PLS_L       : out std_logic;                        -- pulse register(L) select(active High)
        SEL_PLS_H       : out std_logic;                        -- pulse register(H) select(active High)
        SEL_HIGH_L      : out std_logic;                        -- high freqency register(L) select(active High)
        SEL_HIGH_H      : out std_logic;                        -- high freqency register(H) select(active High)
        SEL_LOW_L       : out std_logic;                        -- low freqency register(L) select(active High)
        SEL_LOW_H       : out std_logic;                        -- low freqency register(H) select(active High)
        SEL_ACC_L       : out std_logic;                        -- acc rate register(L) select(active High)
        SEL_ACC_H       : out std_logic;                        -- acc rate register(H) select(active High)
        SEL_SLOW_L      : out std_logic;                        -- slow down register(L) select(active High)
        SEL_SLOW_H      : out std_logic;                        -- slow down register(H) select(active High)
        SEL_L_MASK      : out std_logic;                        -- limit mask register select(active High)
        SEL_L_MON       : out std_logic;                        -- limit monitor register select(active High)
        SEL_STATUS      : out std_logic;                        -- status register select(active High)
        SEL_PRE         : out std_logic;                        -- pre-pulses register select(active High)
        SEL_MORE_L      : out std_logic;                        -- more-pulse register select(active High)
		SEL_MORE_H		: out std_logic;                        -- more-pulse register select(active High)
        SEL_DOWNDELAY   : out std_logic;                        -- CURRENT DOWN Delay Register select(active High)
		SEL_CTRL2		: out std_logic;                        -- MANNUAL SLOWDOWN Register select(active High)					--Added by Y.Takao
        SEL_MP_A        : out std_logic;                        -- multipurpose I/O register select(active High)
        SEL_MP_B        : out std_logic                         -- multipurpose I/O register select(active High)
        );
end component;

component ppmc_rgstr
    port(
        LRSTb               : in std_logic;                             -- local reset  (active Low)
        nMRST               : in std_logic;                             -- software reset   (active Low)
        CLK                 : in std_logic;                             -- Internal Clock 20MHz
        LDI                 : in std_logic_vector( 7 downto 0);         -- data bus
        LWEb                : in std_logic;                             -- local write signal   (active Low)
        LRDb                : in std_logic;                             -- read signal          (active Low)
        LOAD_L              : in std_logic;                             -- load signal          (active Low)
        LATCH_L             : in std_logic;                             -- lat signal           (active Low)
        SEL_INI             : in std_logic;                             -- initialize register select(active High)
        SEL_COM             : in std_logic;                             -- command register select(active High)
        SEL_PLS_L           : in std_logic;                             -- pulse register(L) select(active High)
        SEL_PLS_H           : in std_logic;                             -- pulse register(H) select(active High)
        SEL_HIGH_L          : in std_logic;                             -- high freqency register(L) select(active High)
        SEL_HIGH_H          : in std_logic;                             -- high freqency register(H) select(active High)
        SEL_LOW_L           : in std_logic;                             -- low freqency register(L) select(active High)
        SEL_LOW_H           : in std_logic;                             -- low freqency register(H) select(active High)
        SEL_ACC_L           : in std_logic;                             -- acc rate register(L) select(active High)
        SEL_ACC_H           : in std_logic;                             -- acc rate register(H) select(active High)
        SEL_SLOW_L          : in std_logic;                             -- slow down register(L) select(active High)
        SEL_SLOW_H          : in std_logic;                             -- slow down register(H) select(active High)
        SEL_L_MASK          : in std_logic;                             -- limit mask register select(active High)
        SEL_L_MON           : in std_logic;                             -- limit monitor register select(active High)
	    SEL_STATUS          : in std_logic;                             -- Status register select(active High)
        SEL_PRE             : in std_logic;                             -- pre-pulses register select(active High)
        SEL_MORE_L          : in std_logic;                             -- more-pulse register select(active High)
        SEL_MORE_H          : in std_logic;                             -- more-pulse register select(active High)		
        SEL_DOWNDELAY       : in std_logic;                             -- CURRENT DOWN Delay Register select(active High)
        SEL_CTRL2			: in std_logic;                             -- MANNUAL SLOWDOWN Register select(active High)			--Added by Y.Takao
		SEL_MP_A            : in std_logic;                             -- multipurpose I/O register select(active High)
        SEL_MP_B            : in std_logic;                             -- multipurpose I/O register select(active High)
        LCW                 : in std_logic;                             -- Limit lcw
        LCCW                : in std_logic;                             -- Limit lccw
        START_STOP          : in std_logic;                             -- start_stop
        STATUS              : in std_logic_vector( 7 downto 0);         -- Status in
        PULSE               : in std_logic_vector(15 downto 0);         -- pulse_cnt
        MPI                 : in std_logic_vector( 7 downto 0);         -- Multipurpose register
        COMMAND_HIT         : in std_logic;                             -- coommand hit

        COMMAND_CNG         : out std_logic;                            -- coommand change flag
        INIT_REG            : out std_logic_vector( 7 downto 0);        -- initialize_register
        COMMAND_REG         : out std_logic_vector( 7 downto 0);        -- command register
        PULSE_REG           : out std_logic_vector(15 downto 0);        -- pulse register
        HIGH_FREQ_REG       : out std_logic_vector(15 downto 0);        -- high freqency register
        LOW_FREQ_REG        : out std_logic_vector(15 downto 0);        -- low freqency register
        ACC_RATE_REG        : out std_logic_vector(15 downto 0);        -- acc rate register
        SLOW_DOWN_REG       : out std_logic_vector(15 downto 0);        -- slow down register
        LIMIT_MASK_REG      : out std_logic_vector( 7 downto 0);        -- limit mask register
        LIMIT_MONITOR_REG   : out std_logic_vector( 7 downto 0);        -- limit monitor register
        PRE_PLS_REG         : out std_logic_vector( 7 downto 0);        -- pre pulse register
        MORE_PLS_REG        : out std_logic_vector( 15 downto 0);        -- more pulse register
        MPO_A               : out std_logic_vector( 7 downto 0);        -- Multipurpose register
        MPO_B               : out std_logic_vector( 7 downto 0);        -- Multipurpose register
        DOWNDELAY_REG       : out std_logic_vector( 7 downto 0);        -- CURRENT DOWN Delay Register
		CTRL2_REG			: out std_logic_vector( 7 downto 0);        -- MANNUAL SLOWDOWN Delay Register							--Added by Y.Takao
        REGDO               : out std_logic_vector( 7 downto 0)         -- Local data bus
        );
end component;

component ppmc_ctrl is
    port(
        LRSTb           : in std_logic;                             -- power on reset or CPU reset(active Low)
        CLK             : in std_logic;                             -- Clock 20MHz
        LATCH_L         : in std_logic;                             -- latch signal
        COMMAND_REG     : in std_logic_vector( 7 downto 0);         -- command reg
        LIMIT_MASK_REG  : in std_logic_vector( 7 downto 0);         -- limit mask reg
        PULSE_CNT       : in std_logic_vector(15 downto 0);         -- command reg
        SPEED           : in std_logic_vector(15 downto 0);         --
        HIGH_FREQ_REG   : in std_logic_vector(15 downto 0);         -- high freq reg
        LOW_FREQ_REG    : in std_logic_vector(15 downto 0);         -- low freq reg
        PULSE_REG       : in std_logic_vector(15 downto 0);         -- pulse reg
        ACC_RATE_REG    : in std_logic_vector(15 downto 0);         -- acc rate reg
        SLOW_DOWN_REG   : in std_logic_vector(15 downto 0);         -- slow down reg
        PRE_PLS_REG     : in std_logic_vector( 7 downto 0);         -- pre pulse reg
        MORE_PLS_REG    : in std_logic_vector( 15 downto 0);         -- more pulse reg
        EC              : in std_logic_vector( 1 downto 0);         -- error_code
        STOP_F          : in std_logic;                             -- stop flag
        HIGH_LOW_F      : in std_logic;                             -- high_low flag
        CONST_F         : in std_logic;                             -- const flag
        L_CONST_F       : in std_logic;                             -- l const flag
        SLOW            : in std_logic;                             -- slow flag
        LCW             : in std_logic;                             -- limit lcw
        LCCW            : in std_logic;                             -- limit lccw
        MORE_INH_CW     : in std_logic; -- More Drive Inhibit CW
        MORE_INH_CCW    : in std_logic; -- More Drive Inhibit CCW
        STOP            : in std_logic;                             -- stop signal
        PULSE_OUT       : in std_logic;     -- toku chng 2004.01.16 -- pulse out
        PULSE_OUT_EDGE  : in std_logic;                             -- pulse out edge
        START_STOP      : in std_logic;                             -- start_stop
        COMMAND_CNG     : in std_logic;                             -- command change signal
        PLS0_STOP_INH   : in std_logic; -- Pulse zero stop Inhibit

        COMMAND_HIT     : out std_logic;                            -- command_hit
        COMMAND         : out std_logic_vector( 3 downto 0);        -- command
        STATUS          : out std_logic_vector( 7 downto 0);        -- status
        STATE_OUT       : out std_logic_vector( 3 downto 0);        -- state out
        HIGH_REG        : out std_logic_vector(15 downto 0);        -- high reg out
        LOW_REG         : out std_logic_vector(15 downto 0);        -- low reg out
        ACC_REG         : out std_logic_vector(15 downto 0);        -- acc reg out
        SLOW_REG        : out std_logic_vector(15 downto 0);        -- slow reg out
        LIMIT_MASK      : out std_logic_vector( 7 downto 0);        -- limit mask reg out
        PRE_REG         : out std_logic_vector( 7 downto 0);        -- pre pulse register
        DIR             : out std_logic;                            -- '0'= CW  ,'1'= CCW
        ACC_ENB_OUT     : out std_logic;                            -- acc_enb
        UP_DOWN_OUT     : out std_logic;                            -- up_dwon cont
        PLS_LD          : out std_logic;                            -- pls_ld signal
        ENB_START       : out std_logic;                            -- pls_ld signal
        P_STOP          : out std_logic;                            -- pulse stop signal
        nSRESET         : out std_logic                              -- software reset
        );
end component;

-- [OPTIMIZATION] ppmc_phgen component declaration removed: S1-S4 outputs unused (all 'open' at top level)
-- component ppmc_phgen
--     port(
--         nMRST           : in std_logic;
--         CLK             : in std_logic;
--         PULSE_OUT_EDGE  : in std_logic;
--         STOP            : in std_logic;
--         INIT_REG        : in std_logic_vector( 7 downto 0);
--         DIR             : in std_logic;
--         S1              : out std_logic;
--         S2              : out std_logic;
--         S3              : out std_logic;
--         S4              : out std_logic
--         );
-- end component;

component ppmc_cmdchk is
    port(
        CLK             : in std_logic;                             -- Clock 20MHz
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
        SPEED           : in std_logic_vector(15 downto 0);         --

        EC              : out std_logic_vector( 1 downto 0);        -- error code
        STOP_F          : out std_logic;                            -- stop flag
        HIGH_LOW_F      : out std_logic;                            -- high_low flag
        CONST_F         : out std_logic;                            -- const flag
        L_CONST_F       : out std_logic                             -- l const flag
        );
end component;

    signal nSRESET          : std_logic;
    signal nMRST            : std_logic;

    signal SEL_INI          : std_logic;
    signal SEL_COM          : std_logic;
    signal SEL_PLS_L        : std_logic;
    signal SEL_PLS_H        : std_logic;
    signal SEL_HIGH_L       : std_logic;
    signal SEL_HIGH_H       : std_logic;
    signal SEL_LOW_L        : std_logic;
    signal SEL_LOW_H        : std_logic;
    signal SEL_ACC_L        : std_logic;
    signal SEL_ACC_H        : std_logic;
    signal SEL_SLOW_L       : std_logic;
    signal SEL_SLOW_H       : std_logic;
    signal SEL_L_MASK       : std_logic;
    signal SEL_L_MON        : std_logic;
    signal SEL_STATUS       : std_logic;
    signal SEL_PRE          : std_logic;
    signal SEL_MORE_L       : std_logic;
    signal SEL_MORE_H       : std_logic;	
    signal SEL_DOWNDELAY    : std_logic;
	signal SEL_CTRL2		: std_logic;																--Added by Y.Takao
    signal SEL_MP_A         : std_logic;
    signal SEL_MP_B         : std_logic;

    signal INIT_REG         : std_logic_vector( 7 downto 0);
    signal COMMAND_REG      : std_logic_vector( 7 downto 0);
    signal PULSE_REG        : std_logic_vector(15 downto 0);
    signal HIGH_FREQ_REG    : std_logic_vector(15 downto 0);
    signal LOW_FREQ_REG     : std_logic_vector(15 downto 0);
    signal ACC_RATE_REG     : std_logic_vector(15 downto 0);
    signal SLOW_DOWN_REG    : std_logic_vector(15 downto 0);
    signal LIMIT_MASK_REG   : std_logic_vector( 7 downto 0);
    signal PRE_PLS_REG      : std_logic_vector( 7 downto 0);
    signal MORE_PLS_REG     : std_logic_vector( 15 downto 0);

    signal STATUS           : std_logic_vector( 7 downto 0);
    signal PULSE_CNT        : std_logic_vector(15 downto 0);
    signal COMMAND_CNG      : std_logic;
    signal COMMAND_HIT      : std_logic;
    signal COMMAND          : std_logic_vector( 3 downto 0);
    signal STATE            : std_logic_vector( 3 downto 0);
    signal EC               : std_logic_vector( 1 downto 0);

    signal STOP_F           : std_logic;
    signal HIGH_LOW_F       : std_logic;
    signal CONST_F          : std_logic;
    signal L_CONST_F        : std_logic;

    signal ENB_START        : std_logic;
    signal P_STOP           : std_logic;
    signal START_STOP       : std_logic;

    signal ACC_REG          : std_logic_vector(15 downto 0);
    signal SLOW_REG         : std_logic_vector(15 downto 0);
    signal HIGH_REG         : std_logic_vector(15 downto 0);
    signal LOW_REG          : std_logic_vector(15 downto 0);
    signal PRE_REG          : std_logic_vector( 7 downto 0);

    signal PLS_LD           : std_logic;
    signal UP_DOWN          : std_logic;
    signal ACC_ENB          : std_logic;
    signal SPEED            : std_logic_vector(15 downto 0);
    signal SLOW             : std_logic;
    signal STOP             : std_logic;
    signal PULSE_OUT_EDGE   : std_logic;
    signal DIRECTION        : std_logic;
    signal pulse_out        : std_logic;
    signal pulse_out_b      : std_logic;
    signal DOWNDELAY_REG    : std_logic_vector( 7 downto 0);
	signal CTRL2_REG		: std_logic_vector( 7 downto 0);		--Added by Y.Takao
    signal s_MPO_A     		: std_logic_vector(7 downto 0);         -- pararell data output A
    signal s_MPO_B     		: std_logic_vector(7 downto 0);         -- pararell data output B



begin


LIMIT_LOGIC <= LIMIT_MASK_REG(6 downto 5);--2004/08/27 INAGAKI
STRT_STP <= START_STOP; -- 2020/3/2 Add Y.Aoki

--****************************************--
--**         component port assign      **--
--****************************************--

 nMRST <= not (not LRSTb or not nSRESET);
 DIR <= DIRECTION;
 POUT <= pulse_out;
 MPO_A <= s_MPO_A;
 MPO_B <= s_MPO_B;

inst_ppmc_u_step_ext : ppmc_u_step_ext
    port map(
        CLK             => CLK,
        nRST            => nMRST,
        SSEL            => SSEL,
        MSEL            => MSEL,
        INIT_REG_IN     => INIT_REG,
        POUT_IN         => pulse_out_b,
        M               => M,
        POUT            => pulse_out
    );



inst_ppmc_plsgen : ppmc_plsgen
  port map(
        acc_enb         => ACC_ENB,
        acc_reg         => ACC_REG,
        clk             => CLK,
        div_mode        => '1',
        high_reg        => HIGH_REG,
        low_reg         => LOW_REG,
        pls_ld          => PLS_LD,
        pulse_reg       => PULSE_REG,   -- toku chng 2004.03.17
        rst             => not nMRST,
        slow_reg        => SLOW_REG,
        pre_reg         => PRE_REG,
        start_stop      => START_STOP,
        up_down         => UP_DOWN,
        pulse_clk       => MCLK,
		outside_slow	=> CTRL2_REG(0) and (LCW nand LCCW),			--Added by Y.Takao
		speed_out       => SPEED,
        pulse_cnt       => PULSE_CNT,
        pulse_out       => pulse_out_b,   -- toku chng 2004.01.13
        pulse_out_edge  => PULSE_OUT_EDGE,
        slow            => SLOW,
        stop            => STOP
        );

inst_ppmc_dec : ppmc_dec
    port map(
        LA              => LA,
        REGSEL          => REGSEL,

        SEL_INI         => SEL_INI,
        SEL_COM         => SEL_COM,
        SEL_PLS_L       => SEL_PLS_L,
        SEL_PLS_H       => SEL_PLS_H,
        SEL_HIGH_L      => SEL_HIGH_L,
        SEL_HIGH_H      => SEL_HIGH_H,
        SEL_LOW_L       => SEL_LOW_L,
        SEL_LOW_H       => SEL_LOW_H,
        SEL_ACC_L       => SEL_ACC_L,
        SEL_ACC_H       => SEL_ACC_H,
        SEL_SLOW_L      => SEL_SLOW_L,
        SEL_SLOW_H      => SEL_SLOW_H,
        SEL_L_MASK      => SEL_L_MASK,
        SEL_L_MON       => SEL_L_MON,
        SEL_STATUS      => SEL_STATUS,
        SEL_PRE         => SEL_PRE,
        SEL_MORE_L      => SEL_MORE_L,
		SEL_MORE_H      => SEL_MORE_H,
        SEL_DOWNDELAY   => SEL_DOWNDELAY,
		SEL_CTRL2		=> SEL_CTRL2,		--Added by Y.Takao
        SEL_MP_A        => SEL_MP_A,
        SEL_MP_B        => SEL_MP_B
        );

inst_ppmc_rgstr : ppmc_rgstr
    port map(
        LRSTb               => LRSTb,
        nMRST               => nMRST,
        CLK                 => CLK,
        LDI                 => LDI,
        REGDO               => REGDO,
        LWEb                => LWEb,
        LATCH_L             => LATCH_L,
        LRDb                => LRDb,
        LOAD_L              => LOAD_L,
        SEL_INI             => SEL_INI,
        SEL_COM             => SEL_COM,
        SEL_PLS_L           => SEL_PLS_L,
        SEL_PLS_H           => SEL_PLS_H,
        SEL_HIGH_L          => SEL_HIGH_L,
        SEL_HIGH_H          => SEL_HIGH_H,
        SEL_LOW_L           => SEL_LOW_L,
        SEL_LOW_H           => SEL_LOW_H,
        SEL_ACC_L           => SEL_ACC_L,
        SEL_ACC_H           => SEL_ACC_H,
        SEL_SLOW_L          => SEL_SLOW_L,
        SEL_SLOW_H          => SEL_SLOW_H,
        SEL_L_MASK          => SEL_L_MASK,
        SEL_L_MON           => SEL_L_MON,
        SEL_STATUS          => SEL_STATUS,
        SEL_PRE             => SEL_PRE,
        SEL_MORE_L          => SEL_MORE_L,
		SEL_MORE_H			=> SEL_MORE_H,
        SEL_DOWNDELAY       => SEL_DOWNDELAY,
		SEL_CTRL2			=> SEL_CTRL2,			--Added by Y.Takao
        SEL_MP_A            => SEL_MP_A,
        SEL_MP_B            => SEL_MP_B,
        INIT_REG            => INIT_REG,
        COMMAND_REG         => COMMAND_REG,
        PULSE_REG           => PULSE_REG,
        HIGH_FREQ_REG       => HIGH_FREQ_REG,
        LOW_FREQ_REG        => LOW_FREQ_REG,
        ACC_RATE_REG        => ACC_RATE_REG,
        SLOW_DOWN_REG       => SLOW_DOWN_REG,
        LIMIT_MASK_REG      => LIMIT_MASK_REG,
        PRE_PLS_REG         => PRE_PLS_REG,
        MORE_PLS_REG        => MORE_PLS_REG,
        START_STOP          => START_STOP,
        COMMAND_CNG         => COMMAND_CNG,
        COMMAND_HIT         => COMMAND_HIT,
        STATUS              => STATUS,
        PULSE               => PULSE_CNT,
       	LCW					=> LCW or CTRL2_REG(0) ,			--Changed by Y.Takao
		LCCW				=> LCCW or CTRL2_REG(0),			--Changed by Y.Takao
		--LCW             	=> LCW,
        --LCCW            	=> LCCW,
        MPI                 => MPI,
        MPO_A               => s_MPO_A,
        MPO_B               => s_MPO_B,
        DOWNDELAY_REG       => DOWNDELAY_REG,
		CTRL2_REG			=> CTRL2_REG									--Added by Y.Takao
        );

inst_ppmc_enblr :ppmc_enblr_S118M
    port map(
        nMRST           => nMRST,
        CLK             => CLK,
		KCLK			=> KCLK,
        ENB_START       => ENB_START,
        P_STOP          => P_STOP,
        DOWNDELAY       => DOWNDELAY_REG,
        CURRENT_DOWN    => CURRENT_DOWN,
        START_STOP      => START_STOP
        );

-- [OPTIMIZATION] ppmc_phgen removed: S1-S4 outputs are unused (connected to 'open' at top level for all 13 instances)
-- Savings: 12 FF (8-bit STATE + 4-bit SOUT) + ~20 LUT per instance x 13 = 156 FF + 260 LUT
S1 <= '0';
S2 <= '0';
S3 <= '0';
S4 <= '0';

inst_ppmc_ctrl : ppmc_ctrl
    port map(
        LRSTb           => LRSTb,
        CLK             => CLK,
        LATCH_L         => LATCH_L,
        COMMAND_REG     => COMMAND_REG,
        LIMIT_MASK_REG  => LIMIT_MASK_REG,
        PULSE_CNT       => PULSE_CNT,
        SPEED           => SPEED,
        HIGH_FREQ_REG   => HIGH_FREQ_REG,
        LOW_FREQ_REG    => LOW_FREQ_REG,
        PULSE_REG       => PULSE_REG,
        ACC_RATE_REG    => ACC_RATE_REG,
        SLOW_DOWN_REG   => SLOW_DOWN_REG,
        PRE_PLS_REG     => PRE_PLS_REG,
        MORE_PLS_REG    => MORE_PLS_REG,
        EC              => EC,
        STOP_F          => STOP_F,
        HIGH_LOW_F      => HIGH_LOW_F,
        CONST_F         => CONST_F,
        L_CONST_F       => L_CONST_F,
        SLOW            => SLOW,
        LCW					=> LCW or CTRL2_REG(0) ,				--Changed by Y.Takao
		LCCW				=> LCCW or CTRL2_REG(0),				--Changed by Y.Takao
		--LCW             => LCW,
        --LCCW            => LCCW,
        MORE_INH_CW     => MORE_INH_CW,
        MORE_INH_CCW    => MORE_INH_CCW,
        STOP            => STOP,
        PULSE_OUT       => pulse_out_b,   --inagaki 2005.04.18 ,toku chng 2004.01.16
        pulse_out_edge  => PULSE_OUT_EDGE,
        START_STOP      => START_STOP,
        COMMAND_CNG     => COMMAND_CNG,
        PLS0_STOP_INH   => PLS0_STOP_INH,

        COMMAND_HIT     => COMMAND_HIT,
        COMMAND         => COMMAND,
        STATUS          => STATUS,
        STATE_OUT       => STATE,
        HIGH_REG        => HIGH_REG,
        LOW_REG         => LOW_REG,
        ACC_REG         => ACC_REG,
        SLOW_REG        => SLOW_REG,
        PRE_REG         => PRE_REG,

        DIR             => DIRECTION,
        ACC_ENB_OUT     => ACC_ENB,
        UP_DOWN_OUT     => UP_DOWN,
        PLS_LD          => PLS_LD,
        ENB_START       => ENB_START,
        P_STOP          => P_STOP,
        nSRESET         => nSRESET
        );

inst_ppmc_cmdchk : ppmc_cmdchk
    port map(
        CLK             => CLK,
        nMRST           => nMRST,
        UP_DOWN         => UP_DOWN,     -- toku add 2004.03.17
        ACC_ENB         => ACC_ENB,
        COMMAND_HIT     => COMMAND_HIT,
        STATE           => STATE,
        COMMAND         => COMMAND,
        HIGH_FREQ       => HIGH_REG,
        LOW_FREQ        => LOW_REG,
        PULSE_REG       => PULSE_REG,   -- toku chng 2004.03.17
        HIGH_FREQ_REG   => HIGH_FREQ_REG,
        LOW_FREQ_REG    => LOW_FREQ_REG,
        SPEED           => SPEED,

        EC              => EC,
        STOP_F          => STOP_F,
        HIGH_LOW_F      => HIGH_LOW_F,
        CONST_F         => CONST_F,
        L_CONST_F       => L_CONST_F
    );

end RTL;
