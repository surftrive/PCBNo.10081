--VHDL instantiation template

component IPcore is
    port (TXEN_A: in std_logic_vector(9 downto 0);
        dcfifo_rx_b1_Data: in std_logic_vector(10 downto 0);
        dcfifo_rx_b1_Q: out std_logic_vector(10 downto 0);
        dcfifo_rx_b2_Data: in std_logic_vector(7 downto 0);
        dcfifo_rx_b2_Q: out std_logic_vector(7 downto 0);
        dcfifo_tx_b1_Data: in std_logic_vector(7 downto 0);
        dcfifo_tx_b1_Q: out std_logic_vector(7 downto 0);
        dcfifo_tx_b2_Q: out std_logic_vector(9 downto 0);
        CLK1: in std_logic;
        CLK2: in std_logic;
        CLK_BASE_20M: in std_logic;
        CLK_PLL_100M: out std_logic;
        CLK_PLL_100M_90: out std_logic;
        CLK_PLL_10M: out std_logic;
        CLK_PLL_20M: out std_logic;
        Empty: out std_logic;
        Full: out std_logic;
        LOCKED: out std_logic;
        RPReset: in std_logic;
        TXCF_RDREQ: in std_logic;
        TXCF_WRREQ: in std_logic;
        dcfifo_rx_b1_Empty: out std_logic;
        dcfifo_rx_b1_Full: out std_logic;
        dcfifo_rx_b1_RPReset: in std_logic;
        dcfifo_rx_b1_RdClock: in std_logic;
        dcfifo_rx_b1_RdEn: in std_logic;
        dcfifo_rx_b1_Reset: in std_logic;
        dcfifo_rx_b1_WrClock: in std_logic;
        dcfifo_rx_b1_WrEn: in std_logic;
        dcfifo_rx_b2_Empty: out std_logic;
        dcfifo_rx_b2_Full: out std_logic;
        dcfifo_rx_b2_RPReset: in std_logic;
        dcfifo_rx_b2_RdClock: in std_logic;
        dcfifo_rx_b2_RdEn: in std_logic;
        dcfifo_rx_b2_Reset: in std_logic;
        dcfifo_rx_b2_WrClock: in std_logic;
        dcfifo_rx_b2_WrEn: in std_logic;
        dcfifo_tx_b1_Empty: out std_logic;
        dcfifo_tx_b1_Full: out std_logic;
        dcfifo_tx_b1_RPReset: in std_logic;
        dcfifo_tx_b1_RdClock: in std_logic;
        dcfifo_tx_b1_RdEn: in std_logic;
        dcfifo_tx_b1_Reset: in std_logic;
        dcfifo_tx_b1_WrClock: in std_logic;
        dcfifo_tx_b1_WrEn: in std_logic;
        reseth: in std_logic;
        s_RSTb: in std_logic
    );
    
end component IPcore; -- sbp_module=true 
_inst: IPcore port map (TXEN_A => __,dcfifo_tx_b2_Q => __,CLK1 => __,CLK2 => __,
            Empty => __,Full => __,RPReset => __,TXCF_RDREQ => __,TXCF_WRREQ => __,
            reseth => __,dcfifo_rx_b1_Data => __,dcfifo_rx_b1_Q => __,dcfifo_rx_b1_Empty => __,
            dcfifo_rx_b1_Full => __,dcfifo_rx_b1_RPReset => __,dcfifo_rx_b1_RdClock => __,
            dcfifo_rx_b1_RdEn => __,dcfifo_rx_b1_Reset => __,dcfifo_rx_b1_WrClock => __,
            dcfifo_rx_b1_WrEn => __,dcfifo_rx_b2_Data => __,dcfifo_rx_b2_Q => __,
            dcfifo_rx_b2_Empty => __,dcfifo_rx_b2_Full => __,dcfifo_rx_b2_RPReset => __,
            dcfifo_rx_b2_RdClock => __,dcfifo_rx_b2_RdEn => __,dcfifo_rx_b2_Reset => __,
            dcfifo_rx_b2_WrClock => __,dcfifo_rx_b2_WrEn => __,dcfifo_tx_b1_Data => __,
            dcfifo_tx_b1_Q => __,dcfifo_tx_b1_Empty => __,dcfifo_tx_b1_Full => __,
            dcfifo_tx_b1_RPReset => __,dcfifo_tx_b1_RdClock => __,dcfifo_tx_b1_RdEn => __,
            dcfifo_tx_b1_Reset => __,dcfifo_tx_b1_WrClock => __,dcfifo_tx_b1_WrEn => __,
            CLK_BASE_20M => __,CLK_PLL_100M => __,CLK_PLL_100M_90 => __,CLK_PLL_10M => __,
            CLK_PLL_20M => __,LOCKED => __,s_RSTb => __);
