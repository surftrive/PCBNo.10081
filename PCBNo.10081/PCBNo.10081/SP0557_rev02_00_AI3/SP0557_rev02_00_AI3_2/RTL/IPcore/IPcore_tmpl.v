//Verilog instantiation template

IPcore _inst (.TXEN_A(), .dcfifo_tx_b2_Q(), .CLK1(), .CLK2(), .Empty(), 
       .Full(), .RPReset(), .TXCF_RDREQ(), .TXCF_WRREQ(), .reseth(), 
       .dcfifo_rx_b1_Data(), .dcfifo_rx_b1_Q(), .dcfifo_rx_b1_Empty(), 
       .dcfifo_rx_b1_Full(), .dcfifo_rx_b1_RPReset(), .dcfifo_rx_b1_RdClock(), 
       .dcfifo_rx_b1_RdEn(), .dcfifo_rx_b1_Reset(), .dcfifo_rx_b1_WrClock(), 
       .dcfifo_rx_b1_WrEn(), .dcfifo_rx_b2_Data(), .dcfifo_rx_b2_Q(), 
       .dcfifo_rx_b2_Empty(), .dcfifo_rx_b2_Full(), .dcfifo_rx_b2_RPReset(), 
       .dcfifo_rx_b2_RdClock(), .dcfifo_rx_b2_RdEn(), .dcfifo_rx_b2_Reset(), 
       .dcfifo_rx_b2_WrClock(), .dcfifo_rx_b2_WrEn(), .dcfifo_tx_b1_Data(), 
       .dcfifo_tx_b1_Q(), .dcfifo_tx_b1_Empty(), .dcfifo_tx_b1_Full(), 
       .dcfifo_tx_b1_RPReset(), .dcfifo_tx_b1_RdClock(), .dcfifo_tx_b1_RdEn(), 
       .dcfifo_tx_b1_Reset(), .dcfifo_tx_b1_WrClock(), .dcfifo_tx_b1_WrEn(), 
       .CLK_BASE_20M(), .CLK_PLL_100M(), .CLK_PLL_100M_90(), .CLK_PLL_10M(), 
       .CLK_PLL_20M(), .LOCKED(), .s_RSTb());