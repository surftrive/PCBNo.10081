





--
-- Verific VHDL Description of module IPcore
--

library ieee ;
use ieee.std_logic_1164.all ;

entity IPcore is
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
    
end entity IPcore; -- sbp_module=true 

architecture IPcore of IPcore is 
    component dcfifo_rx_b1 is
        port (Data: in std_logic_vector(10 downto 0);
            Q: out std_logic_vector(10 downto 0);
            Empty: out std_logic;
            Full: out std_logic;
            RPReset: in std_logic;
            RdClock: in std_logic;
            RdEn: in std_logic;
            Reset: in std_logic;
            WrClock: in std_logic;
            WrEn: in std_logic
        );
        
    end component dcfifo_rx_b1; -- not_need_bbox=true 
    
    
    component dcfifo_rx_b2 is
        port (Data: in std_logic_vector(7 downto 0);
            Q: out std_logic_vector(7 downto 0);
            Empty: out std_logic;
            Full: out std_logic;
            RPReset: in std_logic;
            RdClock: in std_logic;
            RdEn: in std_logic;
            Reset: in std_logic;
            WrClock: in std_logic;
            WrEn: in std_logic
        );
        
    end component dcfifo_rx_b2; -- not_need_bbox=true 
    
    
    component dcfifo_tx_b1 is
        port (Data: in std_logic_vector(7 downto 0);
            Q: out std_logic_vector(7 downto 0);
            Empty: out std_logic;
            Full: out std_logic;
            RPReset: in std_logic;
            RdClock: in std_logic;
            RdEn: in std_logic;
            Reset: in std_logic;
            WrClock: in std_logic;
            WrEn: in std_logic
        );
        
    end component dcfifo_tx_b1; -- not_need_bbox=true 
    
    
    component dcfifo_tx_b2 is
        port (Data: in std_logic_vector(9 downto 0);
            Q: out std_logic_vector(9 downto 0);
            Empty: out std_logic;
            Full: out std_logic;
            RPReset: in std_logic;
            RdClock: in std_logic;
            RdEn: in std_logic;
            Reset: in std_logic;
            WrClock: in std_logic;
            WrEn: in std_logic
        );
        
    end component dcfifo_tx_b2; -- not_need_bbox=true 
    
    
    component pll_gen is
        port (CLKI: in std_logic;
            CLKOP: out std_logic;
            CLKOS: out std_logic;
            CLKOS2: out std_logic;
            CLKOS3: out std_logic;
            LOCK: out std_logic;
            RST: in std_logic
        );
        
    end component pll_gen; -- not_need_bbox=true 
    
    
    
begin
    dcfifo_rx_b1_inst: component dcfifo_rx_b1 port map (Data(10)=>dcfifo_rx_b1_Data(10),
            Data(9)=>dcfifo_rx_b1_Data(9),Data(8)=>dcfifo_rx_b1_Data(8),Data(7)=>dcfifo_rx_b1_Data(7),
            Data(6)=>dcfifo_rx_b1_Data(6),Data(5)=>dcfifo_rx_b1_Data(5),Data(4)=>dcfifo_rx_b1_Data(4),
            Data(3)=>dcfifo_rx_b1_Data(3),Data(2)=>dcfifo_rx_b1_Data(2),Data(1)=>dcfifo_rx_b1_Data(1),
            Data(0)=>dcfifo_rx_b1_Data(0),Q(10)=>dcfifo_rx_b1_Q(10),Q(9)=>dcfifo_rx_b1_Q(9),
            Q(8)=>dcfifo_rx_b1_Q(8),Q(7)=>dcfifo_rx_b1_Q(7),Q(6)=>dcfifo_rx_b1_Q(6),
            Q(5)=>dcfifo_rx_b1_Q(5),Q(4)=>dcfifo_rx_b1_Q(4),Q(3)=>dcfifo_rx_b1_Q(3),
            Q(2)=>dcfifo_rx_b1_Q(2),Q(1)=>dcfifo_rx_b1_Q(1),Q(0)=>dcfifo_rx_b1_Q(0),
            Empty=>dcfifo_rx_b1_Empty,Full=>dcfifo_rx_b1_Full,RPReset=>dcfifo_rx_b1_RPReset,
            RdClock=>dcfifo_rx_b1_RdClock,RdEn=>dcfifo_rx_b1_RdEn,Reset=>dcfifo_rx_b1_Reset,
            WrClock=>dcfifo_rx_b1_WrClock,WrEn=>dcfifo_rx_b1_WrEn);
    dcfifo_rx_b2_inst: component dcfifo_rx_b2 port map (Data(7)=>dcfifo_rx_b2_Data(7),
            Data(6)=>dcfifo_rx_b2_Data(6),Data(5)=>dcfifo_rx_b2_Data(5),Data(4)=>dcfifo_rx_b2_Data(4),
            Data(3)=>dcfifo_rx_b2_Data(3),Data(2)=>dcfifo_rx_b2_Data(2),Data(1)=>dcfifo_rx_b2_Data(1),
            Data(0)=>dcfifo_rx_b2_Data(0),Q(7)=>dcfifo_rx_b2_Q(7),Q(6)=>dcfifo_rx_b2_Q(6),
            Q(5)=>dcfifo_rx_b2_Q(5),Q(4)=>dcfifo_rx_b2_Q(4),Q(3)=>dcfifo_rx_b2_Q(3),
            Q(2)=>dcfifo_rx_b2_Q(2),Q(1)=>dcfifo_rx_b2_Q(1),Q(0)=>dcfifo_rx_b2_Q(0),
            Empty=>dcfifo_rx_b2_Empty,Full=>dcfifo_rx_b2_Full,RPReset=>dcfifo_rx_b2_RPReset,
            RdClock=>dcfifo_rx_b2_RdClock,RdEn=>dcfifo_rx_b2_RdEn,Reset=>dcfifo_rx_b2_Reset,
            WrClock=>dcfifo_rx_b2_WrClock,WrEn=>dcfifo_rx_b2_WrEn);
    dcfifo_tx_b1_inst: component dcfifo_tx_b1 port map (Data(7)=>dcfifo_tx_b1_Data(7),
            Data(6)=>dcfifo_tx_b1_Data(6),Data(5)=>dcfifo_tx_b1_Data(5),Data(4)=>dcfifo_tx_b1_Data(4),
            Data(3)=>dcfifo_tx_b1_Data(3),Data(2)=>dcfifo_tx_b1_Data(2),Data(1)=>dcfifo_tx_b1_Data(1),
            Data(0)=>dcfifo_tx_b1_Data(0),Q(7)=>dcfifo_tx_b1_Q(7),Q(6)=>dcfifo_tx_b1_Q(6),
            Q(5)=>dcfifo_tx_b1_Q(5),Q(4)=>dcfifo_tx_b1_Q(4),Q(3)=>dcfifo_tx_b1_Q(3),
            Q(2)=>dcfifo_tx_b1_Q(2),Q(1)=>dcfifo_tx_b1_Q(1),Q(0)=>dcfifo_tx_b1_Q(0),
            Empty=>dcfifo_tx_b1_Empty,Full=>dcfifo_tx_b1_Full,RPReset=>dcfifo_tx_b1_RPReset,
            RdClock=>dcfifo_tx_b1_RdClock,RdEn=>dcfifo_tx_b1_RdEn,Reset=>dcfifo_tx_b1_Reset,
            WrClock=>dcfifo_tx_b1_WrClock,WrEn=>dcfifo_tx_b1_WrEn);
    dcfifo_tx_b2_inst: component dcfifo_tx_b2 port map (Data(9)=>TXEN_A(9),
            Data(8)=>TXEN_A(8),Data(7)=>TXEN_A(7),Data(6)=>TXEN_A(6),Data(5)=>TXEN_A(5),
            Data(4)=>TXEN_A(4),Data(3)=>TXEN_A(3),Data(2)=>TXEN_A(2),Data(1)=>TXEN_A(1),
            Data(0)=>TXEN_A(0),Q(9)=>dcfifo_tx_b2_Q(9),Q(8)=>dcfifo_tx_b2_Q(8),
            Q(7)=>dcfifo_tx_b2_Q(7),Q(6)=>dcfifo_tx_b2_Q(6),Q(5)=>dcfifo_tx_b2_Q(5),
            Q(4)=>dcfifo_tx_b2_Q(4),Q(3)=>dcfifo_tx_b2_Q(3),Q(2)=>dcfifo_tx_b2_Q(2),
            Q(1)=>dcfifo_tx_b2_Q(1),Q(0)=>dcfifo_tx_b2_Q(0),Empty=>Empty,
            Full=>Full,RPReset=>RPReset,RdClock=>CLK2,RdEn=>TXCF_RDREQ,Reset=>reseth,
            WrClock=>CLK1,WrEn=>TXCF_WRREQ);
    pll_gen_inst: component pll_gen port map (CLKI=>CLK_BASE_20M,CLKOP=>CLK_PLL_100M,
            CLKOS=>CLK_PLL_100M_90,CLKOS2=>CLK_PLL_20M,CLKOS3=>CLK_PLL_10M,
            LOCK=>LOCKED,RST=>s_RSTb);
    
end architecture IPcore; -- sbp_module=true 

