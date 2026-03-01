#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file C:/FPGAwork/PCBNo.10081/FPGA/SP0557/launch_synplify.tcl
#-- Written on Sun Mar  1 22:03:08 2026

project -close
set filename "C:/FPGAwork/PCBNo.10081/FPGA/SP0557/SP0557_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology ECP5U
set_option -part LFE5U_25F
set_option -package BG256C
set_option -speed_grade -6

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency 200
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -disable_io_insertion false
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	set_option -dup false
	
	set_option -default_enum_encoding default
	
	
	
	set_option -write_apr_constraint 1
	set_option -fix_gated_and_generated_clocks 1
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 1
	set_option -vhdl2008 1
	
	set_option -seqshift_no_replicate 0
	
}
#-- add_file options
add_file -constraint {C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/pll_gen/pll_gen.fdc}
add_file -constraint {C:/FPGAwork/PCBNo.10081/FPGA/SP0557/SP0557.fdc}
add_file -vhdl "C:/lscc/diamond/3.14/cae_library/synthesis/vhdl/ecp5u.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/com/fc_dec.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/com/fc_sel.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/com/w_pack.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/dcfifo_rx_b1/dcfifo_rx_b1.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/dcfifo_rx_b2/dcfifo_rx_b2.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/dcfifo_tx_b1/dcfifo_tx_b1.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/dcfifo_tx_b2/dcfifo_tx_b2.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/pll_gen/pll_gen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/IPcore/IPcore.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_clk_gen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/ad_ctrl/ad_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/ad_ctrl/adc_reg.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/ad_ctrl/adclk_gen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/ad_ctrl/adif_seq.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/ad_ctrl/shiftreg12bit.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_acc_tim_gen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_cmdchk.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_dec.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_enblr_S118M.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_id.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_phgen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_pls_cnt.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_plsgen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_reg_S118M.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_rgstr.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_speed_cnt.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_timer_cnt.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_top_S118M.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/compactppmc/ppmc_u_step_ext.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/CTRL_32CH.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/DAC_CTRL_1CH.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/DAC43608_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/i2c_master_bit_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/i2c_master_byte_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/i2c_master_registers.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/DAC43608/i2c_master_wb_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/EFUSE_CTRL/EFUSE_CTRL.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/encoder/enc_func_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/encoder/enc_lmt.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/encoder/enc_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/encoder/encoder_2bit.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/gpio/gpio_id.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/gpio/gpio_ip_reg.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/gpio/gpio_op_reg.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/gpio/gpio_reg.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/gpio/gpio_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/LEDLT/LEDLT_TOP.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/LEDLT/TLC5916_CTRL.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/LEDLT/AD8402_CTRL/ad8402.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/LEDLT/AD8402_CTRL/AD8402_CTRL.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/pls_sens/pls_sens.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slaveid_top/slaveid_id.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slaveid_top/slaveid_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/crc_check.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/dec4b_3b.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/dec6b_5b.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/dec8b10b_new.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/dec8b10b_wrapper.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/rx_cont_b1.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/rx_cont_b2.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/rx_ctl_1st.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com/rx_ctl_3rd.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl/adr_sel.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl/nd_sel.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl/node_sel.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl/slv_rx_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl/slv_tx_ctrl.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/crc_gen.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/enc3b_4b.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/enc5b_6b.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/enc8b_10b.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/enc8b10b_new.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/enc8b10b_wrapper.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/tx_cont_b1.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/tx_cont_b2.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/tx_ctl_1st.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com/tx_ctl_3rd.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/cds.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/CLK_gen_S124M.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rst_cnt.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/rx_com.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_com_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slv_ctrl_top.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/slvadr_cnv.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/slv_com/tx_com.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/sp_conv/SIO_ctrl2.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/sp_conv/sp_conv.vhd"
add_file -vhdl -lib "work" "C:/FPGAwork/PCBNo.10081/FPGA/RTL/SP0557/sp_conv/SPI_master2.vhd"
#-- top module name
set_option -top_module {SP0557}
project -result_file {C:/FPGAwork/PCBNo.10081/FPGA/SP0557/SP0557.edi}
project -save "$filename"
