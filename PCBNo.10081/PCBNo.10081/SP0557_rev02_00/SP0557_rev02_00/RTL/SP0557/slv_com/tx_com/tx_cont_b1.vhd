-------------------------------------------------
--File Name : tx_cont_b1.vhd
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

entity tx_cont_b1 is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK3			: in std_logic;							-- Clock 100MHZ for CRC
		nRESET			: in std_logic;							-- power on reset
		TXD				: in std_logic_vector(7 downto 0);		-- tx_fifo write data
		TX_WRREQ		: in std_logic;							-- fifo write_request
		HUB_EN			: in std_logic;							-- hub_enable
		TX_WREMPTY		: out std_logic;						-- fifo empty_flag
		TX_WRFULL		: out std_logic;						-- fifo full_flag
		TXDCD			: out std_logic_vector(7 downto 0);		-- tx_data(crc_in)
		ENABLE			: out std_logic;						-- 8b10B data enable
		IDLE_INS		: out std_logic;						-- IDLE_code insert
		TX_END			: out std_logic;						-- tx_end flag
		K_IN			: out std_logic;						-- k_code insert
		RD_IN			: out std_logic
		);
end tx_cont_b1;

architecture RTL of tx_cont_b1 is

component trx_fifo8
	PORT
	(
		rdclk		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		aclr		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdfull		: OUT STD_LOGIC ;	--Not used
		wrempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC
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
end component dcfifo_tx_b1;

component crc_gen
	PORT
	(
		CLK3			: in std_logic;
		nRESET			: in std_logic;
		TXD_Q			: in std_logic_vector(7 downto 0);
		CRCCK_EN		: in std_logic;
		CRCTD_EN		: in std_logic;
		SD_SEL			: in std_logic;
		CRC_INIT		: in std_logic;
		DATA_LD			: in std_logic;
		LATCH_EN		: in std_logic;
		TX_CRCD			: out std_logic_vector( 7 downto 0)
	);
end component;

component tx_ctl_1st
	PORT
	(
		CLK1			: in std_logic;
		CLK3			: in std_logic;
		nRESET			: in std_logic;
		TXD_Q			: in std_logic_vector(7 downto 0);
		TX_EMPTY		: in std_logic;
		HUB_EN			: in std_logic;
		TX_RDREQ		: out std_logic;
		CRCCK_EN		: out std_logic;
		CRCTD_EN		: out std_logic;
		TXD_SEL			: out std_logic;
		CRC_INIT		: out std_logic;
		LATCH_EN		: out std_logic;
		DATA_LD			: out std_logic;
		SD_SEL			: out std_logic;
		ENABLE			: out std_logic;
		IDLE_INS		: out std_logic;
		TX_END			: out std_logic
	);
end component;

	signal	reseth		: std_logic;
	signal	TXD_Q		: std_logic_vector( 7 downto 0);
	signal	TX_RDREQ	: std_logic;
	signal	TX_RDEMPTY	: std_logic;
	signal	txd_1q		: std_logic_vector( 7 downto 0);
	signal	TXD_SEL		: std_logic;
	signal	TX_CRCD		: std_logic_vector( 7 downto 0);
	signal	txcrcd_q	: std_logic_vector( 7 downto 0);
	signal	txd_out		: std_logic_vector( 7 downto 0);
	signal	CRCCK_EN	: std_logic;
	signal	CRCTD_EN	: std_logic;
	signal	CRC_INIT	: std_logic;
	signal	DATA_LD		: std_logic;
	signal	LATCH_EN	: std_logic;
	signal	SD_SEL		: std_logic;

begin

--*** txdata_generete (crcdata_in) ***--
	TXDCD <= txcrcd_q;

	txd_out <= txd_1q when TXD_SEL='0' else TX_CRCD;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			txcrcd_q <= "00000000";
		elsif(CLK1' event and CLK1 ='1') then
			txcrcd_q <= txd_out;
		end if;
	end process;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			txd_1q <= "00000000";
		elsif(CLK1' event and CLK1 ='1') then
			txd_1q <= TXD_Q;
		end if;
	end process;

	K_IN <= '0';
	RD_IN <= '0';

	reseth <= not nRESET;

-- Select "trx_fifo" or "rx_dcfifo" --
--trx_fifo8_inst : trx_fifo8 PORT MAP (
--tx_dcfifo1_48_inst : dcfifo PORT MAP (
--		data		=> TXD(7 downto 0),
--		rdclk		=> CLK1,
--		wrclk		=> CLK1,
--		wrreq		=> TX_WRREQ,
--		rdreq		=> TX_RDREQ,
--		aclr		=> reseth,
--		wrfull		=> TX_WRFULL,
--		wrempty		=> TX_WREMPTY,
--		rdempty		=> TX_RDEMPTY,
--		q			=> TXD_Q(7 downto 0)
--	);

tx_dcfifo1_48_inst : dcfifo_tx_b1 PORT MAP (
		Data		=> TXD(7 downto 0),
		Q			=> TXD_Q(7 downto 0),
		Empty		=> TX_RDEMPTY,
		Full		=> TX_WRFULL,
		RPReset		=> reseth,
		RdClock		=> CLK1,
		RdEn		=> TX_RDREQ,
		Reset		=> reseth,
		WrClock		=> CLK1,
		WrEn		=> TX_WRREQ
	);
	TX_WREMPTY <= TX_RDEMPTY;

crc_gen_inst : crc_gen PORT MAP (
		CLK3		=> CLK3,
		nRESET		=> nRESET,
		TXD_Q		=> TXD_Q(7 downto 0),
		CRCCK_EN	=> CRCCK_EN,
		CRCTD_EN	=> CRCTD_EN,
		SD_SEL		=> SD_SEL,
		CRC_INIT	=> CRC_INIT,
		DATA_LD		=> DATA_LD,
		LATCH_EN	=> LATCH_EN,
		TX_CRCD		=> TX_CRCD(7 downto 0)
	);

tx_ctl_1st_inst : tx_ctl_1st PORT MAP (
		CLK1		=> CLK1,
		CLK3		=> CLK3,
		nRESET		=> nRESET,
		TXD_Q		=> TXD_Q(7 downto 0),
		TX_EMPTY	=> TX_RDEMPTY,
		HUB_EN		=> HUB_EN,
		TX_RDREQ	=> TX_RDREQ,
		CRCCK_EN	=> CRCCK_EN,
		CRCTD_EN	=> CRCTD_EN,
		TXD_SEL		=> TXD_SEL,
		CRC_INIT	=> CRC_INIT,
		LATCH_EN	=> LATCH_EN,
		DATA_LD		=> DATA_LD,
		SD_SEL		=> SD_SEL,
		ENABLE		=> ENABLE,
		IDLE_INS	=> IDLE_INS,
		TX_END		=> TX_END
	);

end RTL;



