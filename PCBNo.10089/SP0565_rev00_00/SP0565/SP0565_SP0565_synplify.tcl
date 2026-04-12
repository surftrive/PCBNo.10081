#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology ECP5U
set_option -part LFE5U_25F
set_option -package BG256C
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup 1

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0
set_option -vhdl2008 1

set_option -seqshift_no_replicate 0

#-- add_file options
set_option -hdl_define -set SBP_SYNTHESIS
set_option -include_path {C:/work/S127M/PCBNo_10089/SP0565_rev00_00}
add_file -verilog {C:/lscc/diamond/3.13/cae_library/synthesis/verilog/pmi_def.v}
add_file -verilog {C:/lscc/diamond/3.13/module/reveal/src/ertl/ertl.v}
add_file -verilog {C:/lscc/diamond/3.13/module/reveal/src/rvl_j2w_module/rvl_j2w_module.v}
add_file -verilog {C:/lscc/diamond/3.13/module/reveal/src/rvl_j2w_module/wb2sci.v}
add_file -verilog {C:/lscc/diamond/3.13/module/reveal/src/ertl/JTAG_SOFT.v}
add_file -verilog -vlog_std v2001 {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/sp0565_la0_trig_gen.v}
add_file -verilog -vlog_std v2001 {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/sp0565_la0_gen.v}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/reveal_coretop.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/w_pack.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rst_cnt_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slv_tx_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slv_rx_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/node_sel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/adr_sel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/nd_sel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slv_ctrl_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slvadr_cnv_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/pll_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/clk_gen_s124m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc5b_6b_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc3b_4b_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc8b_10b_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc8b10b_new_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc8b10b_wrapper_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dcfifo_tx_b1_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/crc_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tx_ctl_1st_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tx_cont_b1_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dcfifo_tx_b2_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tx_ctl_3rd_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tx_cont_b2_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tx_com_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dec6b_5b_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dec4b_3b_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dec8b10b_new_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dec8b10b_wrapper_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dcfifo_rx_b1_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rx_ctl_1st_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rx_cont_b1_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dcfifo_rx_b2_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/crc_check_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rx_ctl_3rd_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rx_cont_b2_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/rx_com_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/cds_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slv_com_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slv_clk_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/log_ca_dacclk_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/log_ca_dacif_seq_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/log_ca_dac_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/dac081s101_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/adclk_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/adif_seq_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/shiftreg12bit_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/adc_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ad_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/encoder_2bit_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc_lmt_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/enc_func_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ring_counter_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/pulse_sens_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/linear_signal_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ad5270_5271_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_dec_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_sel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_id_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_u_step_ext_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_acc_tim_gen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_speed_cnt_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_timer_cnt_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_pls_cnt_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_plsgen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_dec_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_rgstr_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_enblr_s118m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_phgen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_cmdchk_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_reg_s118m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/ppmc_top_s118m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_dec_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_sel_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_id_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_4.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_4.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_5.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_5.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_6.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_6.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_7.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_7.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_8.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_8.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_9.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_9.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_10.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_10.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_11.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_11.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_12.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_12.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_13.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_13.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_14.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_14.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_15.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_15.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_16.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_16.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_17.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_17.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_18.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_18.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_19.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_19.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_20.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_20.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_21.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_21.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_22.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_22.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_23.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_23.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_24.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_24.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_25.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_25.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_26.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_26.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_27.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_27.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_28.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_28.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_29.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_29.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_30.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_30.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_op_reg_uniq_31.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_ip_reg_uniq_31.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/gpio_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_dec_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_sel_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tmpctrl_4ch_id_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dec_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_meas_reg_s127m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_ref_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_ajst_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_ctst_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_cut_ref_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_idlm_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_prm_sel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_edge_dtct_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_rng_chk_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_ctrl_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsnum_reg_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plssel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dlysel_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsmod_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plssel_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_4.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_5.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dlysel_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsmod_uniq_1.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plssel_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_6.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_7.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_8.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dlysel_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_4.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_5.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsmod_uniq_2.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plssel_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_9.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_10.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dly_2term_uniq_11.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_dlysel_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_6.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsdrv_uniq_7.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsmod_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/temp_plsgen_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tmpctrl_4ch_reg_s127m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/tmpctrl_4ch_top_s127m_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_dec_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/fc_sel_uniq_3.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slaveid_id_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/slaveid_top_uniq_0.vhd}
add_file -vhdl -lib "work" {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/reveal_workspace/tmpreveal/sp0565.vhd}

#-- top module name
set_option -top_module SP0565

#-- set result format/file last
project -result_file {C:/work/S127M/PCBNo_10089/SP0565_rev00_00/SP0565/SP0565_SP0565.edi}

#-- error message log file
project -log_file {SP0565_SP0565.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
