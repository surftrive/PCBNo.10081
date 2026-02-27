// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.13.0.56.2
// Netlist written on Fri Dec 06 08:39:46 2024
//
// Verilog Description of module pll_gen
//

module pll_gen (CLKI, RST, CLKOP, CLKOS, CLKOS2, CLKOS3, LOCK) /* synthesis NGD_DRC_MASK=1 */ ;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(12[8:15])
    input CLKI;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(14[9:13])
    input RST;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(15[9:12])
    output CLKOP;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(16[9:14])
    output CLKOS;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(17[9:14])
    output CLKOS2;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(18[9:15])
    output CLKOS3;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(19[9:15])
    output LOCK;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(20[9:13])
    
    wire CLKI /* synthesis is_clock=1 */ ;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(14[9:13])
    wire CLKOP /* synthesis is_clock=1 */ ;   // c:/work/pcbno.10082/rtl/ipcore/pll_gen/pll_gen.vhd(16[9:14])
    
    wire scuba_vlo, VCC_net;
    
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    EHXPLLL PLLInst_0 (.CLKI(CLKI), .CLKFB(CLKOP), .PHASESEL0(scuba_vlo), 
            .PHASESEL1(scuba_vlo), .PHASEDIR(scuba_vlo), .PHASESTEP(scuba_vlo), 
            .PHASELOADREG(scuba_vlo), .STDBY(scuba_vlo), .PLLWAKESYNC(scuba_vlo), 
            .RST(RST), .ENCLKOP(scuba_vlo), .ENCLKOS(scuba_vlo), .ENCLKOS2(scuba_vlo), 
            .ENCLKOS3(scuba_vlo), .CLKOP(CLKOP), .CLKOS(CLKOS), .CLKOS2(CLKOS2), 
            .CLKOS3(CLKOS3), .LOCK(LOCK)) /* synthesis syn_black_box=true, FREQUENCY_PIN_CLKOS3="10.000000", FREQUENCY_PIN_CLKOS2="20.000000", FREQUENCY_PIN_CLKOS="100.000000", FREQUENCY_PIN_CLKOP="100.000000", FREQUENCY_PIN_CLKI="20.000000", ICP_CURRENT="5", LPF_RESISTOR="16", syn_instantiated=1 */ ;
    defparam PLLInst_0.CLKI_DIV = 1;
    defparam PLLInst_0.CLKFB_DIV = 5;
    defparam PLLInst_0.CLKOP_DIV = 6;
    defparam PLLInst_0.CLKOS_DIV = 6;
    defparam PLLInst_0.CLKOS2_DIV = 30;
    defparam PLLInst_0.CLKOS3_DIV = 60;
    defparam PLLInst_0.CLKOP_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS2_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOS3_ENABLE = "ENABLED";
    defparam PLLInst_0.CLKOP_CPHASE = 5;
    defparam PLLInst_0.CLKOS_CPHASE = 6;
    defparam PLLInst_0.CLKOS2_CPHASE = 29;
    defparam PLLInst_0.CLKOS3_CPHASE = 59;
    defparam PLLInst_0.CLKOP_FPHASE = 0;
    defparam PLLInst_0.CLKOS_FPHASE = 4;
    defparam PLLInst_0.CLKOS2_FPHASE = 0;
    defparam PLLInst_0.CLKOS3_FPHASE = 0;
    defparam PLLInst_0.FEEDBK_PATH = "CLKOP";
    defparam PLLInst_0.CLKOP_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOP_TRIM_DELAY = 0;
    defparam PLLInst_0.CLKOS_TRIM_POL = "FALLING";
    defparam PLLInst_0.CLKOS_TRIM_DELAY = 0;
    defparam PLLInst_0.OUTDIVIDER_MUXA = "DIVA";
    defparam PLLInst_0.OUTDIVIDER_MUXB = "DIVB";
    defparam PLLInst_0.OUTDIVIDER_MUXC = "DIVC";
    defparam PLLInst_0.OUTDIVIDER_MUXD = "DIVD";
    defparam PLLInst_0.PLL_LOCK_MODE = 0;
    defparam PLLInst_0.PLL_LOCK_DELAY = 200;
    defparam PLLInst_0.STDBY_ENABLE = "DISABLED";
    defparam PLLInst_0.REFIN_RESET = "DISABLED";
    defparam PLLInst_0.SYNC_ENABLE = "DISABLED";
    defparam PLLInst_0.INT_LOCK_STICKY = "ENABLED";
    defparam PLLInst_0.DPHASE_SOURCE = "DISABLED";
    defparam PLLInst_0.PLLRST_ENA = "ENABLED";
    defparam PLLInst_0.INTFB_WAKE = "DISABLED";
    GSR GSR_INST (.GSR(VCC_net));
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VHI i88 (.Z(VCC_net));
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

