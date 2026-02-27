// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.13.0.56.2
// Netlist written on Fri Nov 22 14:30:40 2024
//
// Verilog Description of module dcfifo_tx_b2
//

module dcfifo_tx_b2 (Data, WrClock, RdClock, WrEn, RdEn, Reset, 
            RPReset, Q, Empty, Full) /* synthesis NGD_DRC_MASK=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(12[8:20])
    input [9:0]Data;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(14[9:13])
    input WrClock;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(15[9:16])
    input RdClock;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(16[9:16])
    input WrEn;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(17[9:13])
    input RdEn;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(18[9:13])
    input Reset;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(19[9:14])
    input RPReset;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(20[9:16])
    output [9:0]Q;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(21[9:10])
    output Empty;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(22[9:14])
    output Full;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(23[9:13])
    
    wire WrClock /* synthesis is_clock=1, SET_AS_NETWORK=WrClock */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(15[9:16])
    wire RdClock /* synthesis is_clock=1, SET_AS_NETWORK=RdClock */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(16[9:16])
    
    wire invout_1, invout_0, w_gdata_0, w_gdata_1, w_gdata_2, w_gdata_3, 
        w_gdata_4, w_gdata_5, wptr_0, wptr_1, wptr_2, wptr_3, wptr_4, 
        wptr_5, wptr_6, r_gdata_0, r_gdata_1, r_gdata_2, r_gdata_3, 
        r_gdata_4, r_gdata_5, rptr_0, rptr_1, rptr_2, rptr_3, rptr_4, 
        rptr_5, rptr_6, w_gcount_0, w_gcount_1, w_gcount_2, w_gcount_3, 
        w_gcount_4, w_gcount_5, w_gcount_6, r_gcount_0, r_gcount_1, 
        r_gcount_2, r_gcount_3, r_gcount_4, r_gcount_5, r_gcount_6, 
        w_gcount_r20, w_gcount_r0, w_gcount_r21, w_gcount_r1, w_gcount_r22, 
        w_gcount_r2, w_gcount_r23, w_gcount_r3, w_gcount_r24, w_gcount_r4, 
        w_gcount_r25, w_gcount_r5, w_gcount_r26, w_gcount_r6, r_gcount_w20, 
        r_gcount_w0, r_gcount_w21, r_gcount_w1, r_gcount_w22, r_gcount_w2, 
        r_gcount_w23, r_gcount_w3, r_gcount_w24, r_gcount_w4, r_gcount_w25, 
        r_gcount_w5, r_gcount_w26, r_gcount_w6, rRst, iwcount_0, iwcount_1, 
        w_gctr_ci, iwcount_2, iwcount_3, co0, iwcount_4, iwcount_5, 
        co1, iwcount_6, co2, wcount_6, ircount_0, ircount_1, r_gctr_ci, 
        ircount_2, ircount_3, co0_1, ircount_4, ircount_5, co1_1, 
        ircount_6, co2_1, rcount_6, rden_i, cmp_ci, wcount_r0, wcount_r1, 
        rcount_0, rcount_1, co0_2, wcount_r2, w_g2b_xor_cluster_0, 
        rcount_2, rcount_3, co1_2, wcount_r4, wcount_r5, rcount_4, 
        rcount_5, co2_2, empty_cmp_clr, empty_cmp_set, empty_d, empty_d_c, 
        wren_i, cmp_ci_1, rcount_w0, rcount_w1, wcount_0, wcount_1, 
        co0_3, rcount_w2, r_g2b_xor_cluster_0, wcount_2, wcount_3, 
        co1_3, rcount_w4, rcount_w5, wcount_4, wcount_5, co2_3, 
        full_cmp_clr, full_cmp_set, full_d, scuba_vhi, scuba_vlo, 
        full_d_c;
    
    AND2 AND2_t14 (.A(WrEn), .B(invout_1), .Z(wren_i)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(256[15:19])
    PUR PUR_INST (.PUR(scuba_vhi));
    defparam PUR_INST.RST_PULSE = 1;
    FD1P3DX FF_70 (.D(iwcount_1), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(433[12:19])
    defparam FF_70.GSR = "ENABLED";
    FD1P3DX FF_69 (.D(iwcount_2), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(437[12:19])
    defparam FF_69.GSR = "ENABLED";
    FD1P3DX FF_68 (.D(iwcount_3), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(441[12:19])
    defparam FF_68.GSR = "ENABLED";
    FD1P3DX FF_67 (.D(iwcount_4), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(445[12:19])
    defparam FF_67.GSR = "ENABLED";
    FD1P3DX FF_66 (.D(iwcount_5), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(449[12:19])
    defparam FF_66.GSR = "ENABLED";
    FD1P3DX FF_65 (.D(iwcount_6), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wcount_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(453[12:19])
    defparam FF_65.GSR = "ENABLED";
    FD1P3DX FF_64 (.D(w_gdata_0), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(457[12:19])
    defparam FF_64.GSR = "ENABLED";
    FD1P3DX FF_63 (.D(w_gdata_1), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(461[12:19])
    defparam FF_63.GSR = "ENABLED";
    FD1P3DX FF_62 (.D(w_gdata_2), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(465[12:19])
    defparam FF_62.GSR = "ENABLED";
    FD1P3DX FF_61 (.D(w_gdata_3), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(469[12:19])
    defparam FF_61.GSR = "ENABLED";
    FD1P3DX FF_60 (.D(w_gdata_4), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(473[12:19])
    defparam FF_60.GSR = "ENABLED";
    FD1P3DX FF_59 (.D(w_gdata_5), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(477[12:19])
    defparam FF_59.GSR = "ENABLED";
    FD1P3DX FF_58 (.D(wcount_6), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(w_gcount_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(481[12:19])
    defparam FF_58.GSR = "ENABLED";
    FD1P3DX FF_57 (.D(wcount_0), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(485[12:19])
    defparam FF_57.GSR = "ENABLED";
    FD1P3DX FF_56 (.D(wcount_1), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(489[12:19])
    defparam FF_56.GSR = "ENABLED";
    FD1P3DX FF_55 (.D(wcount_2), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(493[12:19])
    defparam FF_55.GSR = "ENABLED";
    FD1P3DX FF_54 (.D(wcount_3), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(497[12:19])
    defparam FF_54.GSR = "ENABLED";
    FD1P3DX FF_53 (.D(wcount_4), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(501[12:19])
    defparam FF_53.GSR = "ENABLED";
    FD1P3DX FF_52 (.D(wcount_5), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(505[12:19])
    defparam FF_52.GSR = "ENABLED";
    FD1P3DX FF_51 (.D(wcount_6), .SP(wren_i), .CK(WrClock), .CD(Reset), 
            .Q(wptr_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(509[12:19])
    defparam FF_51.GSR = "ENABLED";
    FD1P3BX FF_50 (.D(ircount_0), .SP(rden_i), .CK(RdClock), .PD(rRst), 
            .Q(rcount_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(513[12:19])
    defparam FF_50.GSR = "ENABLED";
    FD1P3DX FF_49 (.D(ircount_1), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(517[12:19])
    defparam FF_49.GSR = "ENABLED";
    FD1P3DX FF_48 (.D(ircount_2), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(521[12:19])
    defparam FF_48.GSR = "ENABLED";
    FD1P3DX FF_47 (.D(ircount_3), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(525[12:19])
    defparam FF_47.GSR = "ENABLED";
    FD1P3DX FF_46 (.D(ircount_4), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(529[12:19])
    defparam FF_46.GSR = "ENABLED";
    FD1P3DX FF_45 (.D(ircount_5), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(533[12:19])
    defparam FF_45.GSR = "ENABLED";
    FD1P3DX FF_44 (.D(ircount_6), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rcount_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(537[12:19])
    defparam FF_44.GSR = "ENABLED";
    FD1P3DX FF_43 (.D(r_gdata_0), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(541[12:19])
    defparam FF_43.GSR = "ENABLED";
    FD1P3DX FF_42 (.D(r_gdata_1), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(545[12:19])
    defparam FF_42.GSR = "ENABLED";
    FD1P3DX FF_41 (.D(r_gdata_2), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(549[12:19])
    defparam FF_41.GSR = "ENABLED";
    FD1P3DX FF_40 (.D(r_gdata_3), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(553[12:19])
    defparam FF_40.GSR = "ENABLED";
    FD1P3DX FF_39 (.D(r_gdata_4), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(557[12:19])
    defparam FF_39.GSR = "ENABLED";
    FD1P3DX FF_38 (.D(r_gdata_5), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(561[12:19])
    defparam FF_38.GSR = "ENABLED";
    FD1P3DX FF_37 (.D(rcount_6), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(r_gcount_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(565[12:19])
    defparam FF_37.GSR = "ENABLED";
    FD1P3DX FF_36 (.D(rcount_0), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(569[12:19])
    defparam FF_36.GSR = "ENABLED";
    FD1P3DX FF_35 (.D(rcount_1), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(573[12:19])
    defparam FF_35.GSR = "ENABLED";
    FD1P3DX FF_34 (.D(rcount_2), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(577[12:19])
    defparam FF_34.GSR = "ENABLED";
    FD1P3DX FF_33 (.D(rcount_3), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(581[12:19])
    defparam FF_33.GSR = "ENABLED";
    FD1P3DX FF_32 (.D(rcount_4), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(585[12:19])
    defparam FF_32.GSR = "ENABLED";
    FD1P3DX FF_31 (.D(rcount_5), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(589[12:19])
    defparam FF_31.GSR = "ENABLED";
    FD1P3DX FF_30 (.D(rcount_6), .SP(rden_i), .CK(RdClock), .CD(rRst), 
            .Q(rptr_6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(593[12:19])
    defparam FF_30.GSR = "ENABLED";
    FD1S3DX FF_29 (.D(w_gcount_0), .CK(RdClock), .CD(Reset), .Q(w_gcount_r0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(597[12:19])
    defparam FF_29.GSR = "ENABLED";
    FD1S3DX FF_28 (.D(w_gcount_1), .CK(RdClock), .CD(Reset), .Q(w_gcount_r1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(600[12:19])
    defparam FF_28.GSR = "ENABLED";
    FD1S3DX FF_27 (.D(w_gcount_2), .CK(RdClock), .CD(Reset), .Q(w_gcount_r2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(603[12:19])
    defparam FF_27.GSR = "ENABLED";
    FD1S3DX FF_26 (.D(w_gcount_3), .CK(RdClock), .CD(Reset), .Q(w_gcount_r3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(606[12:19])
    defparam FF_26.GSR = "ENABLED";
    FD1S3DX FF_25 (.D(w_gcount_4), .CK(RdClock), .CD(Reset), .Q(w_gcount_r4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(609[12:19])
    defparam FF_25.GSR = "ENABLED";
    FD1S3DX FF_24 (.D(w_gcount_5), .CK(RdClock), .CD(Reset), .Q(w_gcount_r5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(612[12:19])
    defparam FF_24.GSR = "ENABLED";
    FD1S3DX FF_23 (.D(w_gcount_6), .CK(RdClock), .CD(Reset), .Q(w_gcount_r6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(615[12:19])
    defparam FF_23.GSR = "ENABLED";
    FD1S3DX FF_22 (.D(r_gcount_0), .CK(WrClock), .CD(rRst), .Q(r_gcount_w0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(618[12:19])
    defparam FF_22.GSR = "ENABLED";
    FD1S3DX FF_21 (.D(r_gcount_1), .CK(WrClock), .CD(rRst), .Q(r_gcount_w1)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(621[12:19])
    defparam FF_21.GSR = "ENABLED";
    FD1S3DX FF_20 (.D(r_gcount_2), .CK(WrClock), .CD(rRst), .Q(r_gcount_w2)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(624[12:19])
    defparam FF_20.GSR = "ENABLED";
    FD1S3DX FF_19 (.D(r_gcount_3), .CK(WrClock), .CD(rRst), .Q(r_gcount_w3)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(627[12:19])
    defparam FF_19.GSR = "ENABLED";
    FD1S3DX FF_18 (.D(r_gcount_4), .CK(WrClock), .CD(rRst), .Q(r_gcount_w4)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(630[12:19])
    defparam FF_18.GSR = "ENABLED";
    FD1S3DX FF_17 (.D(r_gcount_5), .CK(WrClock), .CD(rRst), .Q(r_gcount_w5)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(633[12:19])
    defparam FF_17.GSR = "ENABLED";
    FD1S3DX FF_16 (.D(r_gcount_6), .CK(WrClock), .CD(rRst), .Q(r_gcount_w6)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(636[12:19])
    defparam FF_16.GSR = "ENABLED";
    FD1S3DX FF_15 (.D(w_gcount_r0), .CK(RdClock), .CD(Reset), .Q(w_gcount_r20)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(639[12:19])
    defparam FF_15.GSR = "ENABLED";
    FD1S3DX FF_14 (.D(w_gcount_r1), .CK(RdClock), .CD(Reset), .Q(w_gcount_r21)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(643[12:19])
    defparam FF_14.GSR = "ENABLED";
    FD1S3DX FF_13 (.D(w_gcount_r2), .CK(RdClock), .CD(Reset), .Q(w_gcount_r22)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(647[12:19])
    defparam FF_13.GSR = "ENABLED";
    FD1S3DX FF_12 (.D(w_gcount_r3), .CK(RdClock), .CD(Reset), .Q(w_gcount_r23)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(651[12:19])
    defparam FF_12.GSR = "ENABLED";
    FD1S3DX FF_11 (.D(w_gcount_r4), .CK(RdClock), .CD(Reset), .Q(w_gcount_r24)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(655[12:19])
    defparam FF_11.GSR = "ENABLED";
    FD1S3DX FF_10 (.D(w_gcount_r5), .CK(RdClock), .CD(Reset), .Q(w_gcount_r25)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(659[12:19])
    defparam FF_10.GSR = "ENABLED";
    FD1S3DX FF_9 (.D(w_gcount_r6), .CK(RdClock), .CD(Reset), .Q(w_gcount_r26)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(663[11:18])
    defparam FF_9.GSR = "ENABLED";
    FD1S3DX FF_8 (.D(r_gcount_w0), .CK(WrClock), .CD(rRst), .Q(r_gcount_w20)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(667[11:18])
    defparam FF_8.GSR = "ENABLED";
    FD1S3DX FF_7 (.D(r_gcount_w1), .CK(WrClock), .CD(rRst), .Q(r_gcount_w21)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(670[11:18])
    defparam FF_7.GSR = "ENABLED";
    FD1S3DX FF_6 (.D(r_gcount_w2), .CK(WrClock), .CD(rRst), .Q(r_gcount_w22)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(673[11:18])
    defparam FF_6.GSR = "ENABLED";
    FD1S3DX FF_5 (.D(r_gcount_w3), .CK(WrClock), .CD(rRst), .Q(r_gcount_w23)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(676[11:18])
    defparam FF_5.GSR = "ENABLED";
    FD1S3DX FF_4 (.D(r_gcount_w4), .CK(WrClock), .CD(rRst), .Q(r_gcount_w24)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(679[11:18])
    defparam FF_4.GSR = "ENABLED";
    FD1S3DX FF_3 (.D(r_gcount_w5), .CK(WrClock), .CD(rRst), .Q(r_gcount_w25)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(682[11:18])
    defparam FF_3.GSR = "ENABLED";
    FD1S3DX FF_2 (.D(r_gcount_w6), .CK(WrClock), .CD(rRst), .Q(r_gcount_w26)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(685[11:18])
    defparam FF_2.GSR = "ENABLED";
    FD1S3BX FF_1 (.D(empty_d), .CK(RdClock), .PD(rRst), .Q(Empty)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(688[11:18])
    defparam FF_1.GSR = "ENABLED";
    FD1S3DX FF_0 (.D(full_d), .CK(WrClock), .CD(Reset), .Q(Full)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(691[11:18])
    defparam FF_0.GSR = "ENABLED";
    CCU2C w_gctr_cia (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(w_gctr_ci)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(694[17:22])
    defparam w_gctr_cia.INIT0 = 16'b0110011010101010;
    defparam w_gctr_cia.INIT1 = 16'b0110011010101010;
    defparam w_gctr_cia.INJECT1_0 = "NO";
    defparam w_gctr_cia.INJECT1_1 = "NO";
    CCU2C w_gctr_0 (.A0(wcount_0), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_1), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(w_gctr_ci), .COUT(co0), .S0(iwcount_0), .S1(iwcount_1)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(701[15:20])
    defparam w_gctr_0.INIT0 = 16'b0110011010101010;
    defparam w_gctr_0.INIT1 = 16'b0110011010101010;
    defparam w_gctr_0.INJECT1_0 = "NO";
    defparam w_gctr_0.INJECT1_1 = "NO";
    CCU2C w_gctr_1 (.A0(wcount_2), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_3), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0), .COUT(co1), .S0(iwcount_2), .S1(iwcount_3)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(709[15:20])
    defparam w_gctr_1.INIT0 = 16'b0110011010101010;
    defparam w_gctr_1.INIT1 = 16'b0110011010101010;
    defparam w_gctr_1.INJECT1_0 = "NO";
    defparam w_gctr_1.INJECT1_1 = "NO";
    CCU2C w_gctr_2 (.A0(wcount_4), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_5), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1), .COUT(co2), .S0(iwcount_4), .S1(iwcount_5)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(717[15:20])
    defparam w_gctr_2.INIT0 = 16'b0110011010101010;
    defparam w_gctr_2.INIT1 = 16'b0110011010101010;
    defparam w_gctr_2.INJECT1_0 = "NO";
    defparam w_gctr_2.INJECT1_1 = "NO";
    CCU2C w_gctr_3 (.A0(wcount_6), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2), .S0(iwcount_6)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(725[15:20])
    defparam w_gctr_3.INIT0 = 16'b0110011010101010;
    defparam w_gctr_3.INIT1 = 16'b0110011010101010;
    defparam w_gctr_3.INJECT1_0 = "NO";
    defparam w_gctr_3.INJECT1_1 = "NO";
    CCU2C r_gctr_cia (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vhi), .B1(scuba_vhi), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(r_gctr_ci)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(732[17:22])
    defparam r_gctr_cia.INIT0 = 16'b0110011010101010;
    defparam r_gctr_cia.INIT1 = 16'b0110011010101010;
    defparam r_gctr_cia.INJECT1_0 = "NO";
    defparam r_gctr_cia.INJECT1_1 = "NO";
    CCU2C r_gctr_0 (.A0(rcount_0), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_1), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(r_gctr_ci), .COUT(co0_1), .S0(ircount_0), .S1(ircount_1)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(739[15:20])
    defparam r_gctr_0.INIT0 = 16'b0110011010101010;
    defparam r_gctr_0.INIT1 = 16'b0110011010101010;
    defparam r_gctr_0.INJECT1_0 = "NO";
    defparam r_gctr_0.INJECT1_1 = "NO";
    CCU2C r_gctr_1 (.A0(rcount_2), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_3), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_1), .COUT(co1_1), .S0(ircount_2), .S1(ircount_3)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(747[15:20])
    defparam r_gctr_1.INIT0 = 16'b0110011010101010;
    defparam r_gctr_1.INIT1 = 16'b0110011010101010;
    defparam r_gctr_1.INJECT1_0 = "NO";
    defparam r_gctr_1.INJECT1_1 = "NO";
    CCU2C r_gctr_2 (.A0(rcount_4), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(rcount_5), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_1), .COUT(co2_1), .S0(ircount_4), .S1(ircount_5)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(755[15:20])
    defparam r_gctr_2.INIT0 = 16'b0110011010101010;
    defparam r_gctr_2.INIT1 = 16'b0110011010101010;
    defparam r_gctr_2.INJECT1_0 = "NO";
    defparam r_gctr_2.INJECT1_1 = "NO";
    CCU2C r_gctr_3 (.A0(rcount_6), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co2_1), .S0(ircount_6)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(763[15:20])
    defparam r_gctr_3.INIT0 = 16'b0110011010101010;
    defparam r_gctr_3.INIT1 = 16'b0110011010101010;
    defparam r_gctr_3.INJECT1_0 = "NO";
    defparam r_gctr_3.INJECT1_1 = "NO";
    CCU2C empty_cmp_ci_a (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(rden_i), .B1(rden_i), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(cmp_ci)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(771[21:26])
    defparam empty_cmp_ci_a.INIT0 = 16'b0110011010101010;
    defparam empty_cmp_ci_a.INIT1 = 16'b0110011010101010;
    defparam empty_cmp_ci_a.INJECT1_0 = "NO";
    defparam empty_cmp_ci_a.INJECT1_1 = "NO";
    CCU2C empty_cmp_0 (.A0(rcount_0), .B0(wcount_r0), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(rcount_1), .B1(wcount_r1), .C1(scuba_vhi), 
          .D1(scuba_vhi), .CIN(cmp_ci), .COUT(co0_2)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(778[18:23])
    defparam empty_cmp_0.INIT0 = 16'b1001100110101010;
    defparam empty_cmp_0.INIT1 = 16'b1001100110101010;
    defparam empty_cmp_0.INJECT1_0 = "NO";
    defparam empty_cmp_0.INJECT1_1 = "NO";
    CCU2C empty_cmp_1 (.A0(rcount_2), .B0(wcount_r2), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(rcount_3), .B1(w_g2b_xor_cluster_0), .C1(scuba_vhi), 
          .D1(scuba_vhi), .CIN(co0_2), .COUT(co1_2)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(785[18:23])
    defparam empty_cmp_1.INIT0 = 16'b1001100110101010;
    defparam empty_cmp_1.INIT1 = 16'b1001100110101010;
    defparam empty_cmp_1.INJECT1_0 = "NO";
    defparam empty_cmp_1.INJECT1_1 = "NO";
    CCU2C empty_cmp_2 (.A0(rcount_4), .B0(wcount_r4), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(rcount_5), .B1(wcount_r5), .C1(scuba_vhi), 
          .D1(scuba_vhi), .CIN(co1_2), .COUT(co2_2)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(793[18:23])
    defparam empty_cmp_2.INIT0 = 16'b1001100110101010;
    defparam empty_cmp_2.INIT1 = 16'b1001100110101010;
    defparam empty_cmp_2.INJECT1_0 = "NO";
    defparam empty_cmp_2.INJECT1_1 = "NO";
    CCU2C empty_cmp_3 (.A0(empty_cmp_set), .B0(empty_cmp_clr), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), 
          .D1(scuba_vhi), .CIN(co2_2), .COUT(empty_d_c)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(800[18:23])
    defparam empty_cmp_3.INIT0 = 16'b1001100110101010;
    defparam empty_cmp_3.INIT1 = 16'b1001100110101010;
    defparam empty_cmp_3.INJECT1_0 = "NO";
    defparam empty_cmp_3.INJECT1_1 = "NO";
    CCU2C a0 (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(empty_d_c), .S0(empty_d)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(808[9:14])
    defparam a0.INIT0 = 16'b0110011010101010;
    defparam a0.INIT1 = 16'b0110011010101010;
    defparam a0.INJECT1_0 = "NO";
    defparam a0.INJECT1_1 = "NO";
    CCU2C full_cmp_ci_a (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(wren_i), .B1(wren_i), .C1(scuba_vhi), 
          .D1(scuba_vhi), .COUT(cmp_ci_1)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(816[20:25])
    defparam full_cmp_ci_a.INIT0 = 16'b0110011010101010;
    defparam full_cmp_ci_a.INIT1 = 16'b0110011010101010;
    defparam full_cmp_ci_a.INJECT1_0 = "NO";
    defparam full_cmp_ci_a.INJECT1_1 = "NO";
    CCU2C full_cmp_0 (.A0(wcount_0), .B0(rcount_w0), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_1), .B1(rcount_w1), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(cmp_ci_1), .COUT(co0_3)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(823[17:22])
    defparam full_cmp_0.INIT0 = 16'b1001100110101010;
    defparam full_cmp_0.INIT1 = 16'b1001100110101010;
    defparam full_cmp_0.INJECT1_0 = "NO";
    defparam full_cmp_0.INJECT1_1 = "NO";
    CCU2C full_cmp_1 (.A0(wcount_2), .B0(rcount_w2), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_3), .B1(r_g2b_xor_cluster_0), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co0_3), .COUT(co1_3)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(831[17:22])
    defparam full_cmp_1.INIT0 = 16'b1001100110101010;
    defparam full_cmp_1.INIT1 = 16'b1001100110101010;
    defparam full_cmp_1.INJECT1_0 = "NO";
    defparam full_cmp_1.INJECT1_1 = "NO";
    CCU2C full_cmp_2 (.A0(wcount_4), .B0(rcount_w4), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(wcount_5), .B1(rcount_w5), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(co1_3), .COUT(co2_3)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(839[17:22])
    defparam full_cmp_2.INIT0 = 16'b1001100110101010;
    defparam full_cmp_2.INIT1 = 16'b1001100110101010;
    defparam full_cmp_2.INJECT1_0 = "NO";
    defparam full_cmp_2.INJECT1_1 = "NO";
    CCU2C full_cmp_3 (.A0(full_cmp_set), .B0(full_cmp_clr), .C0(scuba_vhi), 
          .D0(scuba_vhi), .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), 
          .D1(scuba_vhi), .CIN(co2_3), .COUT(full_d_c)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(846[17:22])
    defparam full_cmp_3.INIT0 = 16'b1001100110101010;
    defparam full_cmp_3.INIT1 = 16'b1001100110101010;
    defparam full_cmp_3.INJECT1_0 = "NO";
    defparam full_cmp_3.INJECT1_1 = "NO";
    VHI scuba_vhi_inst (.Z(scuba_vhi));
    VLO scuba_vlo_inst (.Z(scuba_vlo));
    CCU2C a1 (.A0(scuba_vlo), .B0(scuba_vlo), .C0(scuba_vhi), .D0(scuba_vhi), 
          .A1(scuba_vlo), .B1(scuba_vlo), .C1(scuba_vhi), .D1(scuba_vhi), 
          .CIN(full_d_c), .S0(full_d)) /* synthesis syn_black_box=true, syn_unconnected_inputs="CIN", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(860[9:14])
    defparam a1.INIT0 = 16'b0110011010101010;
    defparam a1.INIT1 = 16'b0110011010101010;
    defparam a1.INJECT1_0 = "NO";
    defparam a1.INJECT1_1 = "NO";
    GSR GSR_INST (.GSR(scuba_vhi));
    INV INV_1 (.A(Full), .Z(invout_1));
    AND2 AND2_t13 (.A(RdEn), .B(invout_0), .Z(rden_i)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(262[15:19])
    INV INV_0 (.A(Empty), .Z(invout_0));
    OR2 OR2_t12 (.A(Reset), .B(RPReset), .Z(rRst)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(268[14:17])
    XOR2 XOR2_t11 (.A(wcount_0), .B(wcount_1), .Z(w_gdata_0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(271[15:19])
    XOR2 XOR2_t10 (.A(wcount_1), .B(wcount_2), .Z(w_gdata_1)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(274[15:19])
    XOR2 XOR2_t9 (.A(wcount_2), .B(wcount_3), .Z(w_gdata_2)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(277[14:18])
    XOR2 XOR2_t8 (.A(wcount_3), .B(wcount_4), .Z(w_gdata_3)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(280[14:18])
    XOR2 XOR2_t7 (.A(wcount_4), .B(wcount_5), .Z(w_gdata_4)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(283[14:18])
    XOR2 XOR2_t6 (.A(wcount_5), .B(wcount_6), .Z(w_gdata_5)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(286[14:18])
    XOR2 XOR2_t5 (.A(rcount_0), .B(rcount_1), .Z(r_gdata_0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(289[14:18])
    XOR2 XOR2_t4 (.A(rcount_1), .B(rcount_2), .Z(r_gdata_1)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(292[14:18])
    XOR2 XOR2_t3 (.A(rcount_2), .B(rcount_3), .Z(r_gdata_2)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(295[14:18])
    XOR2 XOR2_t2 (.A(rcount_3), .B(rcount_4), .Z(r_gdata_3)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(298[14:18])
    XOR2 XOR2_t1 (.A(rcount_4), .B(rcount_5), .Z(r_gdata_4)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(301[14:18])
    XOR2 XOR2_t0 (.A(rcount_5), .B(rcount_6), .Z(r_gdata_5)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(304[14:18])
    ROM16X1A LUT4_15 (.AD0(w_gcount_r26), .AD1(w_gcount_r25), .AD2(w_gcount_r24), 
            .AD3(w_gcount_r23), .DO0(w_g2b_xor_cluster_0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_15.initval = 16'b0110100110010110;
    ROM16X1A LUT4_14 (.AD0(scuba_vlo), .AD1(scuba_vlo), .AD2(w_gcount_r26), 
            .AD3(w_gcount_r25), .DO0(wcount_r5)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_14.initval = 16'b0110100110010110;
    ROM16X1A LUT4_13 (.AD0(scuba_vlo), .AD1(w_gcount_r26), .AD2(w_gcount_r25), 
            .AD3(w_gcount_r24), .DO0(wcount_r4)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_13.initval = 16'b0110100110010110;
    ROM16X1A LUT4_12 (.AD0(wcount_r5), .AD1(w_gcount_r24), .AD2(w_gcount_r23), 
            .AD3(w_gcount_r22), .DO0(wcount_r2)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_12.initval = 16'b0110100110010110;
    ROM16X1A LUT4_11 (.AD0(wcount_r4), .AD1(w_gcount_r23), .AD2(w_gcount_r22), 
            .AD3(w_gcount_r21), .DO0(wcount_r1)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_11.initval = 16'b0110100110010110;
    ROM16X1A LUT4_10 (.AD0(w_g2b_xor_cluster_0), .AD1(w_gcount_r22), .AD2(w_gcount_r21), 
            .AD3(w_gcount_r20), .DO0(wcount_r0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_10.initval = 16'b0110100110010110;
    ROM16X1A LUT4_9 (.AD0(r_gcount_w26), .AD1(r_gcount_w25), .AD2(r_gcount_w24), 
            .AD3(r_gcount_w23), .DO0(r_g2b_xor_cluster_0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_9.initval = 16'b0110100110010110;
    ROM16X1A LUT4_8 (.AD0(scuba_vlo), .AD1(scuba_vlo), .AD2(r_gcount_w26), 
            .AD3(r_gcount_w25), .DO0(rcount_w5)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_8.initval = 16'b0110100110010110;
    ROM16X1A LUT4_7 (.AD0(scuba_vlo), .AD1(r_gcount_w26), .AD2(r_gcount_w25), 
            .AD3(r_gcount_w24), .DO0(rcount_w4)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_7.initval = 16'b0110100110010110;
    ROM16X1A LUT4_6 (.AD0(rcount_w5), .AD1(r_gcount_w24), .AD2(r_gcount_w23), 
            .AD3(r_gcount_w22), .DO0(rcount_w2)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_6.initval = 16'b0110100110010110;
    ROM16X1A LUT4_5 (.AD0(rcount_w4), .AD1(r_gcount_w23), .AD2(r_gcount_w22), 
            .AD3(r_gcount_w21), .DO0(rcount_w1)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_5.initval = 16'b0110100110010110;
    ROM16X1A LUT4_4 (.AD0(r_g2b_xor_cluster_0), .AD1(r_gcount_w22), .AD2(r_gcount_w21), 
            .AD3(r_gcount_w20), .DO0(rcount_w0)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_4.initval = 16'b0110100110010110;
    ROM16X1A LUT4_3 (.AD0(scuba_vlo), .AD1(w_gcount_r26), .AD2(rcount_6), 
            .AD3(rptr_6), .DO0(empty_cmp_set)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_3.initval = 16'b0000010000010000;
    ROM16X1A LUT4_2 (.AD0(scuba_vlo), .AD1(w_gcount_r26), .AD2(rcount_6), 
            .AD3(rptr_6), .DO0(empty_cmp_clr)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_2.initval = 16'b0001000000000100;
    ROM16X1A LUT4_1 (.AD0(scuba_vlo), .AD1(r_gcount_w26), .AD2(wcount_6), 
            .AD3(wptr_6), .DO0(full_cmp_set)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_1.initval = 16'b0000000101000000;
    ROM16X1A LUT4_0 (.AD0(scuba_vlo), .AD1(r_gcount_w26), .AD2(wcount_6), 
            .AD3(wptr_6), .DO0(full_cmp_clr)) /* synthesis syn_black_box=true, syn_instantiated=1 */ ;
    defparam LUT4_0.initval = 16'b0100000000000001;
    DP16KD pdp_ram_0_0_0 (.DIA0(Data[0]), .DIA1(Data[1]), .DIA2(Data[2]), 
           .DIA3(Data[3]), .DIA4(Data[4]), .DIA5(Data[5]), .DIA6(Data[6]), 
           .DIA7(Data[7]), .DIA8(Data[8]), .DIA9(Data[9]), .DIA10(scuba_vlo), 
           .DIA11(scuba_vlo), .DIA12(scuba_vlo), .DIA13(scuba_vlo), .DIA14(scuba_vlo), 
           .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), .ADA0(scuba_vhi), 
           .ADA1(scuba_vhi), .ADA2(scuba_vlo), .ADA3(scuba_vlo), .ADA4(wptr_0), 
           .ADA5(wptr_1), .ADA6(wptr_2), .ADA7(wptr_3), .ADA8(wptr_4), 
           .ADA9(wptr_5), .ADA10(scuba_vlo), .ADA11(scuba_vlo), .ADA12(scuba_vlo), 
           .ADA13(scuba_vlo), .CEA(wren_i), .OCEA(wren_i), .CLKA(WrClock), 
           .WEA(scuba_vhi), .CSA0(scuba_vlo), .CSA1(scuba_vlo), .CSA2(scuba_vlo), 
           .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), .DIB2(scuba_vlo), 
           .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), .DIB6(scuba_vlo), 
           .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), .DIB10(scuba_vlo), 
           .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), .DIB14(scuba_vlo), 
           .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), .ADB0(scuba_vlo), 
           .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), .ADB4(rptr_0), 
           .ADB5(rptr_1), .ADB6(rptr_2), .ADB7(rptr_3), .ADB8(rptr_4), 
           .ADB9(rptr_5), .ADB10(scuba_vlo), .ADB11(scuba_vlo), .ADB12(scuba_vlo), 
           .ADB13(scuba_vlo), .CEB(rden_i), .OCEB(rden_i), .CLKB(RdClock), 
           .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), 
           .RSTB(Reset), .DOB0(Q[0]), .DOB1(Q[1]), .DOB2(Q[2]), .DOB3(Q[3]), 
           .DOB4(Q[4]), .DOB5(Q[5]), .DOB6(Q[6]), .DOB7(Q[7]), .DOB8(Q[8]), 
           .DOB9(Q[9])) /* synthesis syn_black_box=true, MEM_LPC_FILE="dcfifo_tx_b2.lpc", MEM_INIT_FILE="", syn_instantiated=1 */ ;
    defparam pdp_ram_0_0_0.DATA_WIDTH_A = 18;
    defparam pdp_ram_0_0_0.DATA_WIDTH_B = 18;
    defparam pdp_ram_0_0_0.REGMODE_A = "NOREG";
    defparam pdp_ram_0_0_0.REGMODE_B = "NOREG";
    defparam pdp_ram_0_0_0.RESETMODE = "ASYNC";
    defparam pdp_ram_0_0_0.ASYNC_RESET_RELEASE = "SYNC";
    defparam pdp_ram_0_0_0.WRITEMODE_A = "NORMAL";
    defparam pdp_ram_0_0_0.WRITEMODE_B = "NORMAL";
    defparam pdp_ram_0_0_0.CSDECODE_A = "0b000";
    defparam pdp_ram_0_0_0.CSDECODE_B = "0b000";
    defparam pdp_ram_0_0_0.GSR = "ENABLED";
    defparam pdp_ram_0_0_0.INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_20 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_21 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_22 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_23 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_24 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_25 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_26 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_27 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_28 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_29 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_2F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_30 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_31 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_32 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_33 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_34 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_35 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_36 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_37 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_38 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_39 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INITVAL_3F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
    defparam pdp_ram_0_0_0.INIT_DATA = "STATIC";
    FD1P3BX FF_71 (.D(iwcount_0), .SP(wren_i), .CK(WrClock), .PD(Reset), 
            .Q(wcount_0)) /* synthesis syn_black_box=true, GSR="ENABLED", syn_instantiated=1 */ ;   // //scpfsp01.sysmex.co.jp/11052/12_fpga_data/04808/s124m/pcbno.10083/rtl/ipcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd(429[12:19])
    defparam FF_71.GSR = "ENABLED";
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

