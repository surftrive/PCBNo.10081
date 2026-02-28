-------------------------------------------------
--File Name : slv_ctrl_top.vhd
--Project   : S3IO
--
--Date      : 2003/12/11
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2004/05/19
--Ver       : 2.00
--Doc       : Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity slv_ctrl_top is
    port(
        RSTb        : in std_logic;     -- System Reset (active Low)
        CLK1        : in std_logic;     -- Clock 10MHz
        SLVADR      : in std_logic_vector(7 downto 0);  -- Slave Address
        RX_EMPTY    : in std_logic;     -- RX FIFO Empty
        RX_DATA     : in std_logic_vector(7 downto 0);  -- RX Data
        RX_RDENB    : out std_logic;    -- RX Read Enable
        TX_FULL     : in std_logic;     -- TX FIFO Full
        TX_DATA     : out std_logic_vector(7 downto 0); -- TX Data
        TX_WRENB    : out std_logic;    -- TX Write Enable
        RX_ERR      : in std_logic;     -- RX K-code Error
        CRC_ERR     : in std_logic;     -- RX CRC Error
        TX_START    : out std_logic;    -- TX Start Signal
        PACK_END    : in std_logic;     -- Packet End Signal
        -- Local BUS --
        NSb         : out std_logic_vector(15 downto 0);-- Node Select
        ND_0        : in std_logic_vector(7 downto 0);  -- Node0 data bus
        ND_1        : in std_logic_vector(7 downto 0);  -- Node1 data bus
        ND_2        : in std_logic_vector(7 downto 0);  -- Node2 data bus
        ND_3        : in std_logic_vector(7 downto 0);  -- Node3 data bus
        ND_4        : in std_logic_vector(7 downto 0);  -- Node4 data bus
        ND_5        : in std_logic_vector(7 downto 0);  -- Node5 data bus
        ND_6        : in std_logic_vector(7 downto 0);  -- Node6 data bus
        ND_7        : in std_logic_vector(7 downto 0);  -- Node7 data bus
        ND_8        : in std_logic_vector(7 downto 0);  -- Node8 data bus
        ND_9        : in std_logic_vector(7 downto 0);  -- Node9 data bus
        ND_10       : in std_logic_vector(7 downto 0);  -- Node10 data bus
        ND_11       : in std_logic_vector(7 downto 0);  -- Node11 data bus
        ND_12       : in std_logic_vector(7 downto 0);  -- Node12 data bus
        ND_13       : in std_logic_vector(7 downto 0);  -- Node13 data bus
        ND_14       : in std_logic_vector(7 downto 0);  -- Node14 data bus
        ND_15       : in std_logic_vector(7 downto 0);  -- Node15 data bus
        LA          : out std_logic_vector(11 downto 0);-- Local Address bus
        LDI         : out std_logic_vector(7 downto 0); -- Local data bus
        IDSb        : out std_logic;    -- ID Select (active Low)
        LGSb        : out std_logic;    -- LOG Select (active Low)
        LRDb        : out std_logic;    -- Local Read (active Low)
        LWEb        : out std_logic;    -- Local Write (active Low)
        LATCH       : out std_logic;    -- Latch Signal (active High)
        LOAD        : out std_logic;    -- Load Signal (active High)
        LRSTb       : out std_logic     -- Local Reset (active Low)
        );
end slv_ctrl_top;

architecture RTL of slv_ctrl_top is

signal NODE     : std_logic_vector(3 downto 0);
signal BC       : std_logic;
signal RX_F     : std_logic;
signal BANK     : std_logic_vector(6 downto 0);
signal LA_RX    : std_logic_vector(4 downto 0);
signal LA_TX    : std_logic_vector(4 downto 0);
signal LDO      : std_logic_vector(7 downto 0);
signal CMD      : std_logic_vector(7 downto 0);
signal ADR1     : std_logic_vector(7 downto 0);
signal ADR2     : std_logic_vector(7 downto 0);

signal ndsel    : std_logic_vector(15 downto 0);
signal reset    : std_logic;
signal start    : std_logic;

signal s_prpty	: std_logic_vector(7 downto 0);
-- Prevent pruning and constant optimization of priority bits
attribute syn_keep : boolean;
attribute syn_keep of s_prpty : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of s_prpty : signal is true;

component slv_tx_ctrl
    port(
        LRSTb       : in std_logic;                             -- local reset
        CLK1        : in std_logic;                             -- Clock 10MHZ
        TX_FULL     : in std_logic;                             -- fifo full flag(active high)
        TX_START    : in std_logic;                             -- start signal
        LDO         : in std_logic_vector( 7 downto 0);         -- local data
        PRPTY       : in std_logic_vector( 7 downto 0);         -- prpty data
        CMD         : in std_logic_vector( 7 downto 0);         -- cmd data
        ADR1        : in std_logic_vector( 7 downto 0);         -- adr1 data
        ADR2        : in std_logic_vector( 7 downto 0);         -- dar2 data
        SLVADR      : in std_logic_vector( 7 downto 0);         -- slave address

        TX_D        : out std_logic_vector( 7 downto 0);        -- fifo write data
        TX_WRENB    : out std_logic;                            -- fifo write enb(active High)
        LRDb        : out std_logic;                            -- local data read(active Low)
        LA_TX       : out std_logic_vector( 4 downto 0)         -- local address(memory address)
        );
end component;

component slv_rx_ctrl
    port(
        nRESET      : in std_logic;                             -- power on reset or CPU reset(active Low)
        CLK1        : in std_logic;                             -- Clock 10MHZ
        RX_EMPTY    : in std_logic;
        RX_D        : in std_logic_vector( 7 downto 0);         -- fifo read data
        RX_ERR      : in std_logic;
        CRC_ERR     : in std_logic;
        PACK_END    : in std_logic;                             -- Packet End Signal

        LDI         : out std_logic_vector( 7 downto 0);        -- local data
        CMD         : out std_logic_vector( 7 downto 0);        -- CMD
        ADR1        : out std_logic_vector( 7 downto 0);        -- ADR1
        ADR2        : out std_logic_vector( 7 downto 0);        -- ADR2
        PRPTY       : out std_logic_vector( 7 downto 0);        -- PRPTY
        NODE        : out std_logic_vector( 3 downto 0);        -- NODE
        BC          : out std_logic;                            -- bload cast
        RX_RDENB    : out std_logic;                            -- fifo read enb(active High)
        LRSTb       : out std_logic;                            -- local reset signal(active Low)
        TX_START    : out std_logic;
        LWEb        : out std_logic;                            -- local write signal(active Low)
        LGSb        : out std_logic;                            -- Logger Select(active Low)
        IDSb        : out std_logic;                            -- ID select(active Low)
        LOAD        : out std_logic;                            -- load signal(active high)
        LATCH       : out std_logic;                            -- latch signal(active high)
        BANK        : out std_logic_vector( 6 downto 0);        -- bank
        LA_RX       : out std_logic_vector( 4 downto 0);        -- local address(memory address)
        RX_F        : out std_logic                             -- now recieve(active High)end component;
        );
end component;


component node_sel
    port(
        NODE        : in std_logic_vector( 3 downto 0);     -- NODE
        BC          : in std_logic;                         -- blode cast

        nNS         : out std_logic_vector( 15 downto 0)    -- node select out

        );
end component;

component adr_sel
    port(
        LA_RX       : in std_logic_vector( 4 downto 0);         -- rx local address
        LA_TX       : in std_logic_vector( 4 downto 0);         -- tx local address
        RX_F        : in std_logic;                             -- rx flag
        BANK        : in std_logic_vector( 6 downto 0);         -- logger bank

        LA          : out std_logic_vector(11 downto 0)         -- local address
        );
end component;

component nd_sel
    port(
        NSb     : in std_logic_vector(15 downto 0); -- Node Select
        ND_0    : in std_logic_vector(7 downto 0);  -- Node0 data bus
        ND_1    : in std_logic_vector(7 downto 0);  -- Node1 data bus
        ND_2    : in std_logic_vector(7 downto 0);  -- Node2 data bus
        ND_3    : in std_logic_vector(7 downto 0);  -- Node3 data bus
        ND_4    : in std_logic_vector(7 downto 0);  -- Node4 data bus
        ND_5    : in std_logic_vector(7 downto 0);  -- Node5 data bus
        ND_6    : in std_logic_vector(7 downto 0);  -- Node6 data bus
        ND_7    : in std_logic_vector(7 downto 0);  -- Node7 data bus
        ND_8    : in std_logic_vector(7 downto 0);  -- Node8 data bus
        ND_9    : in std_logic_vector(7 downto 0);  -- Node9 data bus
        ND_10   : in std_logic_vector(7 downto 0);  -- Node10 data bus
        ND_11   : in std_logic_vector(7 downto 0);  -- Node11 data bus
        ND_12   : in std_logic_vector(7 downto 0);  -- Node12 data bus
        ND_13   : in std_logic_vector(7 downto 0);  -- Node13 data bus
        ND_14   : in std_logic_vector(7 downto 0);  -- Node14 data bus
        ND_15   : in std_logic_vector(7 downto 0);  -- Node15 data bus

        LDO     : out std_logic_vector(7 downto 0)  -- Local Data BUS
        );
end component;

begin

    LRSTb       <= reset;
    TX_START    <= start;
    NSb         <= ndsel;

--******** Error Code Generator *******--
	process (RSTb, CLK1) begin
		if (RSTb ='0') then
			s_prpty <= (others => '0');
		elsif (CLK1'event and CLK1 = '1') then
			if (RX_ERR = '1') then
				s_prpty <= "00001000";
			elsif (CRC_ERR = '1') then
				s_prpty <= "00001001";
			else
				s_prpty <= (others => '0');
			end if;
		end if;
	end process;
	
--****************************************--
--**         component port assign      **--
--****************************************--

slv_tx_ctrl_inst : slv_tx_ctrl port map(
        LRSTb       => reset,
        CLK1        => CLK1,
        TX_FULL     => TX_FULL,
        TX_START    => start,
        LDO         => LDO,
        PRPTY       => s_prpty,
        CMD         => CMD,
        ADR1        => ADR1,
        ADR2        => ADR2,
        SLVADR      => SLVADR,

        TX_D        => TX_DATA,
        TX_WRENB    => TX_WRENB,
        LRDb        => LRDb,
        LA_TX       => LA_TX
        );

slv_rx_ctrl_inst : slv_rx_ctrl port map(
        nRESET      => RSTb,
        CLK1        => CLK1,
        RX_EMPTY    => RX_EMPTY,
        RX_D        => RX_DATA,
        RX_ERR      => RX_ERR,
        CRC_ERR     => CRC_ERR,
        PACK_END    => PACK_END,    -- Packet End Signal

        LDI         => LDI,
        CMD         => CMD,
        ADR1        => ADR1,
        ADR2        => ADR2,
        PRPTY       => open,
        NODE        => NODE,
        BC          => BC,
        RX_RDENB    => RX_RDENB,
        LRSTb       => reset,
        TX_START    => start,
        LWEb        => LWEb,
        LGSb        => LGSb,
        IDSb        => IDSb,
        LOAD        => LOAD,
        LATCH       => LATCH,
        BANK        => BANK,
        LA_RX       => LA_RX,
        RX_F        => RX_F
        );

node_sel_inst :  node_sel port map(
        NODE        => NODE,
        BC          => BC,

        nNS         => ndsel
        );

adr_sel_inst : adr_sel port map (
        LA_RX       => la_rx,
        LA_TX       => la_tx,
        RX_F        => rx_f,
        BANK        => BANK,

        LA          => LA
        );

nd_sel_inst : nd_sel port map (
        NSb     => ndsel,
        ND_0    => ND_0,
        ND_1    => ND_1,
        ND_2    => ND_2,
        ND_3    => ND_3,
        ND_4    => ND_4,
        ND_5    => ND_5,
        ND_6    => ND_6,
        ND_7    => ND_7,
        ND_8    => ND_8,
        ND_9    => ND_9,
        ND_10   => ND_10,
        ND_11   => ND_11,
        ND_12   => ND_12,
        ND_13   => ND_13,
        ND_14   => ND_14,
        ND_15   => ND_15,

        LDO     => LDO
        );

end RTL;
