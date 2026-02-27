-------------------------------------------------
--File Name : gpio_top.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/20
--Ver       : 3.00
--Doc       : Output Decoded Latch Signal and Load Signal
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity gpio_top is
    port(
        -- Local Bus --
        CLK         : in std_logic;     -- Clock 20MHZ
        LA          : in std_logic_vector(4 downto 0);  -- Local Address bus
        NSb         : in std_logic;     -- Node Select (active Low)
        IDSb        : in std_logic;     -- ID Select (active Low)
        LGSb        : in std_logic;     -- Log Memory Select (active Low)
        LDI         : in std_logic_vector(7 downto 0);  -- Local data bus (IN)
        LDO         : out std_logic_vector(7 downto 0); -- Local data bus (OUT)
        LRDb        : in std_logic;     -- Local Read (active Low)
        LWEb        : in std_logic;     -- Local Write (active Low)
        LATCH       : in std_logic;     -- Latch Signal (active High)
        LOAD        : in std_logic;     -- Load Signal (active High)
        LRSTb       : in std_logic;     -- Local Reset (active Low)

        LATCH_OUT   : out std_logic;    -- Decoded Latch Signal
        LOAD_OUT    : out std_logic;    -- Decoded Load Signal

        -- GPIO --
        GPI_0       : in std_logic_vector(7 downto 0);
        GPI_1       : in std_logic_vector(7 downto 0);
        GPI_2       : in std_logic_vector(7 downto 0);
        GPI_3       : in std_logic_vector(7 downto 0);
        GPI_4       : in std_logic_vector(7 downto 0);
        GPI_5       : in std_logic_vector(7 downto 0);
        GPI_6       : in std_logic_vector(7 downto 0);
        GPI_7       : in std_logic_vector(7 downto 0);
        GPI_8       : in std_logic_vector(7 downto 0);
        GPI_9       : in std_logic_vector(7 downto 0);
        GPI_10      : in std_logic_vector(7 downto 0);
        GPI_11      : in std_logic_vector(7 downto 0);
        GPI_12      : in std_logic_vector(7 downto 0);
        GPI_13      : in std_logic_vector(7 downto 0);
        GPI_14      : in std_logic_vector(7 downto 0);
        GPI_15      : in std_logic_vector(7 downto 0);
        GPI_16      : in std_logic_vector(7 downto 0);
        GPI_17      : in std_logic_vector(7 downto 0);
        GPI_18      : in std_logic_vector(7 downto 0);
        GPI_19      : in std_logic_vector(7 downto 0);
        GPI_20      : in std_logic_vector(7 downto 0);
        GPI_21      : in std_logic_vector(7 downto 0);
        GPI_22      : in std_logic_vector(7 downto 0);
        GPI_23      : in std_logic_vector(7 downto 0);
        GPI_24      : in std_logic_vector(7 downto 0);
        GPI_25      : in std_logic_vector(7 downto 0);
        GPI_26      : in std_logic_vector(7 downto 0);
        GPI_27      : in std_logic_vector(7 downto 0);
        GPI_28      : in std_logic_vector(7 downto 0);
        GPI_29      : in std_logic_vector(7 downto 0);
        GPI_30      : in std_logic_vector(7 downto 0);
        GPI_31      : in std_logic_vector(7 downto 0);
        GPO_0       : out std_logic_vector(7 downto 0);
        GPO_1       : out std_logic_vector(7 downto 0);
        GPO_2       : out std_logic_vector(7 downto 0);
        GPO_3       : out std_logic_vector(7 downto 0);
        GPO_4       : out std_logic_vector(7 downto 0);
        GPO_5       : out std_logic_vector(7 downto 0);
        GPO_6       : out std_logic_vector(7 downto 0);
        GPO_7       : out std_logic_vector(7 downto 0);
        GPO_8       : out std_logic_vector(7 downto 0);
        GPO_9       : out std_logic_vector(7 downto 0);
        GPO_10      : out std_logic_vector(7 downto 0);
        GPO_11      : out std_logic_vector(7 downto 0);
        GPO_12      : out std_logic_vector(7 downto 0);
        GPO_13      : out std_logic_vector(7 downto 0);
        GPO_14      : out std_logic_vector(7 downto 0);
        GPO_15      : out std_logic_vector(7 downto 0);
        GPO_16      : out std_logic_vector(7 downto 0);
        GPO_17      : out std_logic_vector(7 downto 0);
        GPO_18      : out std_logic_vector(7 downto 0);
        GPO_19      : out std_logic_vector(7 downto 0);
        GPO_20      : out std_logic_vector(7 downto 0);
        GPO_21      : out std_logic_vector(7 downto 0);
        GPO_22      : out std_logic_vector(7 downto 0);
        GPO_23      : out std_logic_vector(7 downto 0);
        GPO_24      : out std_logic_vector(7 downto 0);
        GPO_25      : out std_logic_vector(7 downto 0);
        GPO_26      : out std_logic_vector(7 downto 0);
        GPO_27      : out std_logic_vector(7 downto 0);
        GPO_28      : out std_logic_vector(7 downto 0);
        GPO_29      : out std_logic_vector(7 downto 0);
        GPO_30      : out std_logic_vector(7 downto 0);
        GPO_31      : out std_logic_vector(7 downto 0)
        );
end gpio_top;

architecture RTL of gpio_top is

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
        LATCH_L     : out std_logic;                                -- local latch signal(Active High)
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

component gpio_id
    port(
        LA          : in std_logic_vector(4 downto 0);          -- local address
        IDSEL       : in std_logic;                             -- ID select
        LRDb        : in std_logic;                             -- local data read signal

        IDDO        : out std_logic_vector( 7 downto 0)         -- local data output
        );
end component;

component gpio_reg is
    port(
        CLK         : in std_logic;                             -- clock 20MHz
        LRSTb       : in std_logic;                             -- local reset
        LDI         : in std_logic_vector(7 downto 0);          -- local data in
        LA          : in std_logic_vector(4 downto 0);          -- local address
        REGSEL      : in std_logic;                             -- regster select
        LWEb        : in std_logic;                             -- local write enable
        LRDb        : in std_logic;                             -- local read enable
        LATCH_L     : in std_logic;                             -- local latch
        LOAD_L      : in std_logic;                             -- local load
        REGDO       : out std_logic_vector(7 downto 0);         -- regster data out

        -- GPIO --
        GPI_0       : in std_logic_vector(7 downto 0);
        GPI_1       : in std_logic_vector(7 downto 0);
        GPI_2       : in std_logic_vector(7 downto 0);
        GPI_3       : in std_logic_vector(7 downto 0);
        GPI_4       : in std_logic_vector(7 downto 0);
        GPI_5       : in std_logic_vector(7 downto 0);
        GPI_6       : in std_logic_vector(7 downto 0);
        GPI_7       : in std_logic_vector(7 downto 0);
        GPI_8       : in std_logic_vector(7 downto 0);
        GPI_9       : in std_logic_vector(7 downto 0);
        GPI_10      : in std_logic_vector(7 downto 0);
        GPI_11      : in std_logic_vector(7 downto 0);
        GPI_12      : in std_logic_vector(7 downto 0);
        GPI_13      : in std_logic_vector(7 downto 0);
        GPI_14      : in std_logic_vector(7 downto 0);
        GPI_15      : in std_logic_vector(7 downto 0);
        GPI_16      : in std_logic_vector(7 downto 0);
        GPI_17      : in std_logic_vector(7 downto 0);
        GPI_18      : in std_logic_vector(7 downto 0);
        GPI_19      : in std_logic_vector(7 downto 0);
        GPI_20      : in std_logic_vector(7 downto 0);
        GPI_21      : in std_logic_vector(7 downto 0);
        GPI_22      : in std_logic_vector(7 downto 0);
        GPI_23      : in std_logic_vector(7 downto 0);
        GPI_24      : in std_logic_vector(7 downto 0);
        GPI_25      : in std_logic_vector(7 downto 0);
        GPI_26      : in std_logic_vector(7 downto 0);
        GPI_27      : in std_logic_vector(7 downto 0);
        GPI_28      : in std_logic_vector(7 downto 0);
        GPI_29      : in std_logic_vector(7 downto 0);
        GPI_30      : in std_logic_vector(7 downto 0);
        GPI_31      : in std_logic_vector(7 downto 0);
        GPO_0       : out std_logic_vector(7 downto 0);
        GPO_1       : out std_logic_vector(7 downto 0);
        GPO_2       : out std_logic_vector(7 downto 0);
        GPO_3       : out std_logic_vector(7 downto 0);
        GPO_4       : out std_logic_vector(7 downto 0);
        GPO_5       : out std_logic_vector(7 downto 0);
        GPO_6       : out std_logic_vector(7 downto 0);
        GPO_7       : out std_logic_vector(7 downto 0);
        GPO_8       : out std_logic_vector(7 downto 0);
        GPO_9       : out std_logic_vector(7 downto 0);
        GPO_10      : out std_logic_vector(7 downto 0);
        GPO_11      : out std_logic_vector(7 downto 0);
        GPO_12      : out std_logic_vector(7 downto 0);
        GPO_13      : out std_logic_vector(7 downto 0);
        GPO_14      : out std_logic_vector(7 downto 0);
        GPO_15      : out std_logic_vector(7 downto 0);
        GPO_16      : out std_logic_vector(7 downto 0);
        GPO_17      : out std_logic_vector(7 downto 0);
        GPO_18      : out std_logic_vector(7 downto 0);
        GPO_19      : out std_logic_vector(7 downto 0);
        GPO_20      : out std_logic_vector(7 downto 0);
        GPO_21      : out std_logic_vector(7 downto 0);
        GPO_22      : out std_logic_vector(7 downto 0);
        GPO_23      : out std_logic_vector(7 downto 0);
        GPO_24      : out std_logic_vector(7 downto 0);
        GPO_25      : out std_logic_vector(7 downto 0);
        GPO_26      : out std_logic_vector(7 downto 0);
        GPO_27      : out std_logic_vector(7 downto 0);
        GPO_28      : out std_logic_vector(7 downto 0);
        GPO_29      : out std_logic_vector(7 downto 0);
        GPO_30      : out std_logic_vector(7 downto 0);
        GPO_31      : out std_logic_vector(7 downto 0)
        );
end component;

    signal LATCH_L      : std_logic;
    signal LOAD_L       : std_logic;
    signal REGSEL       : std_logic;
    signal IDSEL        : std_logic;
    --signal LOGSEL       : std_logic;
    signal REGDO        : std_logic_vector( 7 downto 0);
    signal IDDO         : std_logic_vector( 7 downto 0);

begin

    LATCH_OUT <= LATCH_L;
    LOAD_OUT  <= LOAD_L;

--****************************************--
--**         component port assign      **--
--****************************************--

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

gpio_id_inst : gpio_id port map(
        LA          => LA(4 downto 0),
        IDSEL       => IDSEL,
        LRDb        => LRDb,
        IDDO        => IDDO
        );

gpio_reg_inst : gpio_reg port map(
        CLK         => CLK,
        LRSTb       => LRSTb,
        LDI         => LDI,
        LA          => LA,
        REGSEL      => REGSEL,
        LWEb        => LWEb,
        LRDb        => LRDb,
        LATCH_L     => LATCH_L,
        LOAD_L      => LOAD_L,
        REGDO       => REGDO,

        -- GPIO --
        GPI_0       => GPI_0,
        GPI_1       => GPI_1,
        GPI_2       => GPI_2,
        GPI_3       => GPI_3,
        GPI_4       => GPI_4,
        GPI_5       => GPI_5,
        GPI_6       => GPI_6,
        GPI_7       => GPI_7,
        GPI_8       => GPI_8,
        GPI_9       => GPI_9,
        GPI_10      => GPI_10,
        GPI_11      => GPI_11,
        GPI_12      => GPI_12,
        GPI_13      => GPI_13,
        GPI_14      => GPI_14,
        GPI_15      => GPI_15,
        GPI_16      => GPI_16,
        GPI_17      => GPI_17,
        GPI_18      => GPI_18,
        GPI_19      => GPI_19,
        GPI_20      => GPI_20,
        GPI_21      => GPI_21,
        GPI_22      => GPI_22,
        GPI_23      => GPI_23,
        GPI_24      => GPI_24,
        GPI_25      => GPI_25,
        GPI_26      => GPI_26,
        GPI_27      => GPI_27,
        GPI_28      => GPI_28,
        GPI_29      => GPI_29,
        GPI_30      => GPI_30,
        GPI_31      => GPI_31,
        GPO_0       => GPO_0,
        GPO_1       => GPO_1,
        GPO_2       => GPO_2,
        GPO_3       => GPO_3,
        GPO_4       => GPO_4,
        GPO_5       => GPO_5,
        GPO_6       => GPO_6,
        GPO_7       => GPO_7,
        GPO_8       => GPO_8,
        GPO_9       => GPO_9,
        GPO_10      => GPO_10,
        GPO_11      => GPO_11,
        GPO_12      => GPO_12,
        GPO_13      => GPO_13,
        GPO_14      => GPO_14,
        GPO_15      => GPO_15,
        GPO_16      => GPO_16,
        GPO_17      => GPO_17,
        GPO_18      => GPO_18,
        GPO_19      => GPO_19,
        GPO_20      => GPO_20,
        GPO_21      => GPO_21,
        GPO_22      => GPO_22,
        GPO_23      => GPO_23,
        GPO_24      => GPO_24,
        GPO_25      => GPO_25,
        GPO_26      => GPO_26,
        GPO_27      => GPO_27,
        GPO_28      => GPO_28,
        GPO_29      => GPO_29,
        GPO_30      => GPO_30,
        GPO_31      => GPO_31
        );

end RTL;
