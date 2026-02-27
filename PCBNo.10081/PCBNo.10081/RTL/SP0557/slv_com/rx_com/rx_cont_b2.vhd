-------------------------------------------------
--File Name : rx_cont_b2.vhd
--Project	: S3IO
--
--Date		: 2003/12/01
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity rx_cont_b2 is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK3			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		RXDCD			: in std_logic_vector(7 downto 0);		-- 8b10b_dec out_data
		VALID			: in std_logic;							-- 8b10b_dec data_valid
		RX_RDREQ		: in std_logic;							-- fifo read_request
		HUB_EN			: in std_logic;							-- hub_enable
		RXD				: out std_logic_vector(7 downto 0);		-- rx_fifo read data
		RX_RDEMPTY		: out std_logic;						-- fifo empty_flag
		RX_RDFULL		: out std_logic;						-- fifo full_flag
		RX_START		: out std_logic;						-- rx_start flag
		CRC_ERR			: out std_logic;						-- crc_check error
		SYNC_FLG		: out std_logic;
		PACK_END		: out std_logic;						-- Packet End Signal
		K_ERR			: out std_logic
		);
end rx_cont_b2;

architecture RTL of rx_cont_b2 is

component trx_fifo8
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wrreq		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		rdclk		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdfull		: OUT STD_LOGIC ;
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;	--Not used
		wrempty		: OUT STD_LOGIC
	);
end component;

--component dcfifo
--	GENERIC (LPM_WIDTH: POSITIVE:=8;
--		LPM_WIDTHU: POSITIVE:=6;
--		LPM_NUMWORDS: POSITIVE:=48;
--		LPM_SHOWAHEAD: STRING:= "OFF";
--		OVERFLOW_CHECKING: STRING:= "ON";
--		UNDERFLOW_CHECKING: STRING:= "ON";
--		DELAY_RDUSEDW: POSITIVE:= 1;
--		DELAY_WRUSEDW: POSITIVE:= 1;
--		RDSYNC_DELAYPIPE: POSITIVE:= 3;
--		WRSYNC_DELAYPIPE: POSITIVE:= 3);
--	PORT
--	(
--		data: IN STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0);
--		rdclk, wrclk, wrreq, rdreq, aclr: IN STD_LOGIC;
--		rdfull,wrfull, wrempty, rdempty: OUT STD_LOGIC;
--		q: OUT STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0)
--	);
--end component;
component dcfifo_rx_b2 is
	port (Data	:in std_logic_vector(7 downto 0);
		Q	    :out std_logic_vector(7 downto 0);
		Empty	:out std_logic;
		Full	:out std_logic;
		RPReset	:in std_logic;
		RdClock	:in std_logic;
		RdEn	:in std_logic;
		Reset	:in std_logic;
		WrClock	:in std_logic;
		WrEn	:in std_logic
	);
end component dcfifo_rx_b2;

component crc_check
	PORT
	(
		CLK3			: in std_logic;
		nRESET			: in std_logic;
		RXDCD			: in std_logic_vector(7 downto 0);
		CRCCK_EN		: in std_logic;
		CRCRD_EN		: in std_logic;
		CRC_INIT		: in std_logic;
		DATA_LD			: in std_logic;
		LATCH_EN		: in std_logic;
		CRC_ERR			: out std_logic
	);
end component;

component rx_ctl_3rd
	PORT
	(
		CLK1			: in std_logic;
		CLK3			: in std_logic;
		nRESET			: in std_logic;
		RXDCD			: in std_logic_vector(7 downto 0);
		RX_EMPTY		: in std_logic;
		VALID			: in std_logic;
		HUB_EN			: in std_logic;
		RX_WRREQ		: out std_logic;
		CRCCK_EN		: out std_logic;
		CRCRD_EN		: out std_logic;
		RX_START		: out std_logic;
		CRC_INIT		: out std_logic;
		LATCH_EN		: out std_logic;
		DATA_LD			: out std_logic;
		K_ERR			: out std_logic;
		PACK_END		: out std_logic;
		SYNC_FLG		: out std_logic
	);
end component;

	signal	reseth		: std_logic;
	signal	rxd_1q		: std_logic_vector( 7 downto 0);
	signal	RXD_Q		: std_logic_vector( 7 downto 0);
	signal	RX_WRREQ	: std_logic;
	signal	RX_WREMPTY	: std_logic;
	signal	CRCCK_EN	: std_logic;
	signal	CRCRD_EN	: std_logic;
	signal	CRC_INIT	: std_logic;
	signal	DATA_LD		: std_logic;
	signal	LATCH_EN	: std_logic;

begin

	reseth <= not nRESET;

--*** rxifo write_data (crcdata_cut) ***--
	RXD_Q <= rxd_1q;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			rxd_1q <= "00000000";
		elsif(CLK1' event and CLK1 ='1') then
			rxd_1q <= RXDCD;
		end if;
	end process;

-- Select "trx_fifo" or "rx_dcfifo" --
--trx_fifo8_inst : trx_fifo8 PORT MAP (
--rx_dcfifo1_48_inst : dcfifo PORT MAP (
--		data		=> RXD_Q(7 downto 0),
--		rdclk		=> CLK1,
--		wrclk		=> CLK1,
--		wrreq		=> RX_WRREQ,
--		rdreq		=> RX_RDREQ,
--		aclr		=> reseth,
--		rdfull		=> RX_RDFULL,
--		wrempty		=> RX_WREMPTY,
--		rdempty		=> RX_RDEMPTY,
--		q			=> RXD(7 downto 0)
--	);

rx_dcfifo1_48_inst : dcfifo_rx_b2 PORT MAP (
		Data	=> RXD_Q(7 downto 0),
		Q	    => RXD(7 downto 0),
		Empty	=> RX_WREMPTY,
		Full	=> RX_RDFULL,
		RPReset	=> reseth,
		RdClock	=> CLK1,
		RdEn	=> RX_RDREQ,
		Reset	=> reseth,
		WrClock	=> CLK1,
		WrEn	=> RX_WRREQ
	);

	RX_RDEMPTY <= RX_WREMPTY;

crc_check_inst : crc_check PORT MAP (
		CLK3		=> CLK3,
		nRESET		=> nRESET,
		RXDCD		=> RXDCD(7 downto 0),
		CRCCK_EN	=> CRCCK_EN,
		CRCRD_EN	=> CRCRD_EN,
		CRC_INIT	=> CRC_INIT,
		DATA_LD		=> DATA_LD,
		LATCH_EN	=> LATCH_EN,
		CRC_ERR		=> CRC_ERR
	);

rx_ctl_3rd_inst : rx_ctl_3rd PORT MAP (
		CLK1		=> CLK1,
		CLK3		=> CLK3,
		nRESET		=> nRESET,
		RXDCD		=> RXDCD(7 downto 0),
		RX_EMPTY	=> RX_WREMPTY,
		VALID		=> VALID,
		HUB_EN		=> HUB_EN,
		RX_WRREQ	=> RX_WRREQ,
		CRCCK_EN	=> CRCCK_EN,
		CRCRD_EN	=> CRCRD_EN,
		RX_START	=> RX_START,
		CRC_INIT	=> CRC_INIT,
		LATCH_EN	=> LATCH_EN,
		DATA_LD		=> DATA_LD,
		K_ERR		=> K_ERR,
		PACK_END	=> PACK_END,
		SYNC_FLG	=> SYNC_FLG
	);


end RTL;



