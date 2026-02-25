-------------------------------------------------
--File Name : DAC43608_top.vhd
--Project	 : M207M
--
--Date		: 2022/05/30
--Ver		: 0.00
--Doc		: New Release
--Designed by HASEGAWA RYO
-------------------------------------
--Date		: 2022/12/09
--Ver		: 0.01
--Doc		: Initial value and Prescaler LSB value are changed to feed by generic
--Changed by
-------------------------------------------------

library IEEE ;
	use IEEE.std_logic_1164.all ;
	use IEEE.std_logic_unsigned.all ;

library WORK ;
	use WORK.w_pack.all;

entity DAC43608_top is
	generic (
		g_InitValue		: std_logic_vector( 7 downto 0 )	-- (CTRL_32CH) Initial value
			:= X"00" ;
		g_PrescaleL		: std_logic_vector( 7 downto 0 )	-- (DAC_CTRL_1CH) SCL freq Prescaler LSB
--			:= X"4F"	-- 100kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] * 2 - 1"
--			:= X"27"	-- 200kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] - 1"
			:= X"13"	-- 400kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] / 2 - 1"
	) ;
	port (
		CLK				: in	std_logic ;	-- Clock 40MHz
		LRSTb			: in	std_logic ;	-- Local Reset (active Low)
	-- SEND DATA
		DA_SEND_DATA	: ta_DA8(c_STM_CH downto 1);
	-- I2C
		SCL				: inout	std_logic ;
		SDA				: inout	std_logic
	) ;
end DAC43608_top ;

architecture RTL of DAC43608_top is	--************


--****************************
	component i2c_master_wb_top
	generic (
		ARST_LVL : integer := 0
	) ;
	port (
		wb_clk_i	: in	std_logic ;
		wb_rst_i	: in	std_logic ;
		arst_i		: in	std_logic ;
		wb_adr_i	: in	std_logic_vector( 2 downto 0 ) ;
		wb_dat_i	: in	std_logic_vector( 7 downto 0 ) ;
		wb_dat_o	: out	std_logic_vector( 7 downto 0 ) ;
		wb_we_i		: in	std_logic ;
		wb_stb_i	: in	std_logic ;
		wb_cyc_i	: in	std_logic ;
		wb_ack_o	: out	std_logic ;
		wb_inta_o	: out	std_logic ;
		scl			: inout	std_logic ;
		sda			: inout	std_logic
	) ;
	end component ;


--****************************
	component DAC_CTRL_1CH
	generic (
		g_PrescaleL	: std_logic_vector( 7 downto 0 )	-- SCL freq Prescaler LSB
--			:= X"4F"	-- 100kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] * 2 - 1"
--			:= X"27"	-- 200kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] - 1"
			:= X"13"	-- 400kbps @ CLK=40MHz	-- Maybe feeding "clock freq [MHz] / 2 - 1"
	) ;
	port (
		CLK			: in	std_logic ;	-- clock 40MHz
		LRSTb		: in	std_logic ;	-- local reset

		ch_slave	: in	std_logic_vector( 4 downto 0 ) ;	-- [4:2] ch, [1:0]slave sel
		DATA		: in	std_logic_vector( 7 downto 0 ) ;	-- DAC data
		TRIGGER		: in	std_logic ;	-- statemachine start trigger (Act.H)
		COMP_FLAG	: out	std_logic ;	-- send end (Act.H pulse)
	-- WISHBONE interface signals
		WB_ADR_I	: out	std_logic_vector( 2 downto 0 ) ;
		WB_DAT_I	: out	std_logic_vector( 7 downto 0 ) ;
		WB_DAT_O	: in	std_logic_vector( 7 downto 0 ) ;
		WB_WE_I		: out	std_logic ;
		WB_STB_I	: out	std_logic ;
		WB_CYC_I	: out	std_logic ;
		WB_ACK_O	: in	std_logic ;
		WB_INTA_O	: in	std_logic
	) ;
	end component ;

	signal		s_ch_slave	: std_logic_vector( 4 downto 0 ) ;
	signal		s_data		: std_logic_vector( 7 downto 0 ) ;
	signal		s_trigger	: std_logic ;
	signal		s_COMP_FLAG	: std_logic ;

	-- WISHBONE interface signals
	signal		s_wb_adr_i	: std_logic_vector( 2 downto 0 ) ;
	signal		s_wb_dat_i	: std_logic_vector( 7 downto 0 ) ;
	signal		s_wb_dat_o	: std_logic_vector( 7 downto 0 ) ;
	signal		s_wb_we_i	: std_logic ;
	signal		s_wb_stb_i	: std_logic ;
	signal		s_wb_cyc_i	: std_logic ;
	signal		s_wb_ack_o	: std_logic ;
	signal		s_wb_inta_o	: std_logic ;

	signal		s_DA_SEND_DATA	: ta_DA8(32 downto 1);


--****************************
	component CTRL_32CH
	generic (
		g_InitValue	: std_logic_vector( 7 downto 0 )	-- (CTRL_32CH) Initial value
			:= X"80"
	) ;
	port (
		CLK				: in	std_logic ;	-- clock 40MHz
		LRSTb			: in	std_logic ;	-- local reset

		DA_SEND_1CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_2CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_3CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_4CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_5CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_6CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_7CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_8CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_9CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_10CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_11CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_12CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_13CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_14CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_15CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_16CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_17CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_18CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_19CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_20CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_21CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_22CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_23CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_24CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_25CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_26CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_27CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_28CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_29CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_30CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_31CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_32CH	: in	std_logic_vector( 7 downto 0 ) ;

		CH_SLAVE		: out	std_logic_vector( 4 downto 0 ) ;
		DATA			: out	std_logic_vector( 7 downto 0 ) ;
		TRIGGER			: out	std_logic ;
		COMP_FLAG		: in	std_logic
	) ;
	end component ;


begin	--****************************************

	s_DA_SEND_DATA(c_STM_CH downto 1) 		<= DA_SEND_DATA(c_STM_CH downto 1);
	s_DA_SEND_DATA(32 downto (c_STM_CH+1))	<= (others => (others => '0'));

	U01 : i2c_master_wb_top
	generic map (
		ARST_LVL	=>	0
	)
	port map (
		wb_clk_i	=>	CLK			-- in
	,	wb_rst_i	=>	'0'			-- in
	,	arst_i		=>	LRSTb		-- in
	,	wb_adr_i	=>	s_wb_adr_i	-- in
	,	wb_dat_i	=>	s_wb_dat_i	-- in
	,	wb_dat_o	=>	s_wb_dat_o	-- out
	,	wb_we_i		=>	s_wb_we_i	-- in
	,	wb_stb_i	=>	s_wb_stb_i	-- in
	,	wb_cyc_i	=>	s_wb_cyc_i	-- in
	,	wb_ack_o	=>	s_wb_ack_o	-- out
	,	wb_inta_o	=>	s_wb_inta_o	-- out
	,	scl			=>	SCL			-- inout
	,	sda			=>	SDA			-- inout
	) ;


--****************************
	U02 : DAC_CTRL_1CH
	generic map (
		g_PrescaleL	=>	g_PrescaleL
	)
	port map (
		CLK			=>	CLK			-- in
	,	LRSTb		=>	LRSTb		-- in

	,	TRIGGER		=>	s_trigger	-- in
	,	COMP_FLAG	=>	s_COMP_FLAG	-- in
	,	DATA		=>	s_data		-- out
	,	CH_SLAVE	=>	s_ch_slave	-- in
	-- WISHBONE interface signals
	,	WB_ADR_I	=>	s_wb_adr_i	-- out
	,	WB_DAT_I	=>	s_wb_dat_i	-- out
	,	WB_DAT_O	=>	s_wb_dat_o	-- in
	,	WB_WE_I		=>	s_wb_we_i	-- out
	,	WB_STB_I	=>	s_wb_stb_i	-- out
	,	WB_CYC_I	=>	s_wb_cyc_i	-- out
	,	WB_ACK_O	=>	s_wb_ack_o	-- in
	,	WB_INTA_O	=>	s_wb_inta_o	-- in
	) ;


--****************************
	U03 : CTRL_32CH
	generic map (
		g_InitValue		=>	g_InitValue
	)
	port map (
		CLK				=>	CLK				-- in
	,	LRSTb			=>	LRSTb			-- in

	,	DA_SEND_1CH		=>	s_DA_SEND_DATA( 1)		-- in
	,	DA_SEND_2CH		=>	s_DA_SEND_DATA( 2)		-- in
	,	DA_SEND_3CH		=>	s_DA_SEND_DATA( 3)		-- in
	,	DA_SEND_4CH		=>	s_DA_SEND_DATA( 4)		-- in
	,	DA_SEND_5CH		=>	s_DA_SEND_DATA( 5)		-- in
	,	DA_SEND_6CH		=>	s_DA_SEND_DATA( 6)		-- in
	,	DA_SEND_7CH		=>	s_DA_SEND_DATA( 7)		-- in
	,	DA_SEND_8CH		=>	s_DA_SEND_DATA( 8)		-- in

	,	DA_SEND_9CH		=>	s_DA_SEND_DATA( 9)		-- in
	,	DA_SEND_10CH	=>	s_DA_SEND_DATA(10)		-- in
	,	DA_SEND_11CH	=>	s_DA_SEND_DATA(11)		-- in
	,	DA_SEND_12CH	=>	s_DA_SEND_DATA(12)		-- in
	,	DA_SEND_13CH	=>	s_DA_SEND_DATA(13)		-- in
	,	DA_SEND_14CH	=>	s_DA_SEND_DATA(14)		-- in
	,	DA_SEND_15CH	=>	s_DA_SEND_DATA(15)		-- in
	,	DA_SEND_16CH	=>	s_DA_SEND_DATA(16)		-- in

	,	DA_SEND_17CH	=>	s_DA_SEND_DATA(17)		-- in
	,	DA_SEND_18CH	=>	s_DA_SEND_DATA(18)		-- in
	,	DA_SEND_19CH	=>	s_DA_SEND_DATA(19)		-- in
	,	DA_SEND_20CH	=>	s_DA_SEND_DATA(20)		-- in
	,	DA_SEND_21CH	=>	s_DA_SEND_DATA(21)		-- in
	,	DA_SEND_22CH	=>	s_DA_SEND_DATA(22)		-- in
	,	DA_SEND_23CH	=>	s_DA_SEND_DATA(23)		-- in
	,	DA_SEND_24CH	=>	s_DA_SEND_DATA(24)		-- in

	,	DA_SEND_25CH	=>	s_DA_SEND_DATA(25)		-- in
	,	DA_SEND_26CH	=>	s_DA_SEND_DATA(26)		-- in
	,	DA_SEND_27CH	=>	s_DA_SEND_DATA(27)		-- in
	,	DA_SEND_28CH	=>	s_DA_SEND_DATA(28)		-- in
	,	DA_SEND_29CH	=>	s_DA_SEND_DATA(29)		-- in
	,	DA_SEND_30CH	=>	s_DA_SEND_DATA(30)		-- in
	,	DA_SEND_31CH	=>	s_DA_SEND_DATA(31)		-- in
	,	DA_SEND_32CH	=>	s_DA_SEND_DATA(32)		-- in

	,	CH_SLAVE		=>	s_ch_slave		-- out
	,	DATA			=>	s_data			-- out
	,	TRIGGER			=>	s_trigger		-- out
	,	COMP_FLAG		=>	s_COMP_FLAG		-- in
	) ;


end RTL ;