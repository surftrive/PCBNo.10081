-------------------------------------------------
--File Name : ppmc_plsgen.vhd
--Project   : S3IO
--
--Date      : 2002/10/11
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      :2010/02/22
--Ver       :1.00
--Doc       :Changed
--Changed by Yuuki Takao
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;

entity ppmc_plsgen is
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
        slow_reg        : in std_logic_vector(15 downto 0 );
        pre_reg         : in std_logic_vector( 7 downto 0 );
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
end ppmc_plsgen;


architecture RTL of ppmc_plsgen is

    signal acc_pulse    : std_logic;
    signal pout         : std_logic;
    signal speed        : std_logic_vector(15 downto 0 );
    signal tm_clr       : std_logic;
    signal predrv_now   : std_logic;

    component ppmc_acc_tim_gen
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            acc_reg     : in std_logic_vector(15 downto 0 );
            acc_enb     : in std_logic;
            acc_pulse   : out std_logic
            );
    end component;

    component ppmc_speed_cnt
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            acc_pulse   : in std_logic;
            high_reg    : in std_logic_vector(15 downto 0 );
            low_reg     : in std_logic_vector(15 downto 0 );
            up_down     : in std_logic;
            start_stop  : in std_logic;
            predrv_now  : in std_logic;
            speed       : out std_logic_vector(15 downto 0 );
            tm_clr      : out std_logic
            );
    end component;

    component ppmc_timer_cnt
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            pulse_clk   : in std_logic;
            speed       : in std_logic_vector(15 downto 0 );
            tm_clr      : in std_logic;
            pout        : out std_logic;
            pulse_out   : out std_logic;
            div_mode    : in std_logic
            );
    end component;

    component ppmc_pls_cnt
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            pout        : in std_logic;
            pulse_reg   : in std_logic_vector(15 downto 0 );
            pre_reg     : in std_logic_vector( 7 downto 0 );
            pls_ld      : in std_logic;
            pulse_cnt   : out std_logic_vector(15 downto 0 );
            slow_reg    : in std_logic_vector(15 downto 0 );
			low_reg     : in std_logic_vector(15 downto 0 );			--Added by Y.Takao
			speed		: in std_logic_vector(15 downto 0 );			--Added by Y.Takao
			outside_slow: in std_logic;									--Added by Y.Takao
            slow        : out std_logic;
            stop        : out std_logic;
            predrv_now  : out std_logic
            );
    end component;

begin
    speed_out       <= speed;
    pulse_out_edge  <= pout;

    ppmc_acc_tim_gen_inst: ppmc_acc_tim_gen
        port map (
            clk         => clk,
            rst         => rst,
            acc_reg     => acc_reg(15 downto 0),
            acc_enb     => acc_enb,
            acc_pulse   => acc_pulse
            );

    ppmc_speed_cnt_inst: ppmc_speed_cnt
        port map (
            clk         => clk,
            rst         => rst,
            acc_pulse   => acc_pulse,
            high_reg    => high_reg(15 downto 0),
            low_reg     => low_reg(15 downto 0),
            up_down     => up_down,
            start_stop  => start_stop,
            speed       => speed(15 downto 0),
            tm_clr      => tm_clr,
            predrv_now  => predrv_now
            );

    ppmc_timer_cnt_inst: ppmc_timer_cnt
        port map (
            clk         => clk,
            rst         => rst,
            pulse_clk   => pulse_clk,
            speed       => speed(15 downto 0),
            tm_clr      => tm_clr,
            pout        => pout,
            pulse_out   => pulse_out,
            div_mode    => div_mode
            );

    ppmc_pls_cnt_inst: ppmc_pls_cnt
        port map (
            clk         => clk,
            rst         => rst,
            pout        => pout,
            pulse_reg   => pulse_reg(15 downto 0),
            pre_reg     => pre_reg,
            pls_ld      => pls_ld,
            pulse_cnt   => pulse_cnt(15 downto 0),
            slow_reg    => slow_reg(15 downto 0),
			low_reg     => low_reg(15 downto 0),		--Added by Y.Takao
			speed       => speed(15 downto 0),			--Added by Y.Takao
			outside_slow=> outside_slow,				--Added by Y.Takao
            slow        => slow,
            stop        => stop,
            predrv_now  => predrv_now
            );

end RTL;
