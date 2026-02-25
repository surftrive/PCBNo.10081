-------------------------------------------------
--File Name : slaveid_top.vhd
--Project   : S3IO
--
--Date      : 2008/03/07
--Ver       : 0.00
--Doc       : New Release
--Designed by
-------------------------------------
--Date      :
--Ver       :
--Doc       :
--Changed by
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity slaveid_top is
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
        GPI_31      : in std_logic_vector(7 downto 0)
        );
end slaveid_top;

architecture RTL of slaveid_top is

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

component slaveid_id
    port(
        LA          : in std_logic_vector(4 downto 0);          -- local address
        IDSEL       : in std_logic;                             -- ID select
        LRDb        : in std_logic;                             -- local data read signal

        IDDO        : out std_logic_vector( 7 downto 0)         -- local data output
        );
end component;

    signal READ_COMP    : std_logic_vector( 6 downto 0);
    --signal LATCH_L      : std_logic;
    --signal LOAD_L       : std_logic;
    signal REGSEL       : std_logic;
    signal IDSEL        : std_logic;
    --signal LOGSEL       : std_logic;
    signal REGDO        : std_logic_vector( 7 downto 0);
    signal IDDO         : std_logic_vector( 7 downto 0);


begin
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
        LATCH_L     => open,
        LOAD_L      => open
        );


fc_sel_inst : fc_sel port map(
        NSb         => NSb,
        IDDO        => IDDO,
        LOGDO       => "00000000",
        REGDO       => REGDO,

        LDO         => LDO
        );

slaveid_id_inst : slaveid_id port map(
        LA          => LA(4 downto 0),
        IDSEL       => IDSEL,
        LRDb        => LRDb,
        IDDO        => IDDO
        );



    READ_COMP <= (REGSEL & LRDb & LA(4 downto 0));

    process(READ_COMP,
			GPI_0,GPI_1,GPI_2,GPI_3,
			GPI_4,GPI_5,GPI_6,GPI_7,
			GPI_8,GPI_9,GPI_10,GPI_11,
			GPI_12,GPI_13,GPI_14,GPI_15,
			GPI_16,GPI_17,GPI_18,GPI_19,
			GPI_20,GPI_21,GPI_22,GPI_23,
			GPI_24,GPI_25,GPI_26,GPI_27,
			GPI_28,GPI_29,GPI_30,GPI_31) begin
        case (READ_COMP) is
            when "1000000" => REGDO <= GPI_0;
            when "1000001" => REGDO <= GPI_1;
            when "1000010" => REGDO <= GPI_2;
            when "1000011" => REGDO <= GPI_3;
            when "1000100" => REGDO <= GPI_4;
            when "1000101" => REGDO <= GPI_5;
            when "1000110" => REGDO <= GPI_6;
            when "1000111" => REGDO <= GPI_7;
            when "1001000" => REGDO <= GPI_8;
            when "1001001" => REGDO <= GPI_9;
            when "1001010" => REGDO <= GPI_10;
            when "1001011" => REGDO <= GPI_11;
            when "1001100" => REGDO <= GPI_12;
            when "1001101" => REGDO <= GPI_13;
            when "1001110" => REGDO <= GPI_14;
            when "1001111" => REGDO <= GPI_15;
            when "1010000" => REGDO <= GPI_16;
            when "1010001" => REGDO <= GPI_17;
            when "1010010" => REGDO <= GPI_18;
            when "1010011" => REGDO <= GPI_19;
            when "1010100" => REGDO <= GPI_20;
            when "1010101" => REGDO <= GPI_21;
            when "1010110" => REGDO <= GPI_22;
            when "1010111" => REGDO <= GPI_23;
            when "1011000" => REGDO <= GPI_24;
            when "1011001" => REGDO <= GPI_25;
            when "1011010" => REGDO <= GPI_26;
            when "1011011" => REGDO <= GPI_27;
            when "1011100" => REGDO <= GPI_28;
            when "1011101" => REGDO <= GPI_29;
            when "1011110" => REGDO <= GPI_30;
            when "1011111" => REGDO <= GPI_31;
            when others => REGDO <= (others =>'0');
        end case;
    end process;


end RTL;







