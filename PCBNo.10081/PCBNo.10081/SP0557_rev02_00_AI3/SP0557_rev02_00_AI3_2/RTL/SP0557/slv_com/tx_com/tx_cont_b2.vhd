-------------------------------------------------
--File Name : tx_cont_b2.vhd
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

entity tx_cont_b2 is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK2			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		TXEN_A			: in std_logic_vector(9 downto 0);		-- tx_ck_fifo write data
		VALID			: in std_logic;							-- 8b10b_enc data_valid
		TX_D			: out std_logic							-- tx_sirial_data out
		);
end tx_cont_b2;

architecture RTL of tx_cont_b2 is

--component dcfifo
--	GENERIC (LPM_WIDTH: POSITIVE:=10;
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
--		rdusedw, wrusedw: OUT STD_LOGIC_VECTOR(LPM_WIDTHU-1 DOWNTO 0)
--	);
--end component;
-- wrfull,rdfull,wrempty	Not used

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
end component dcfifo_tx_b2;

component tx_ctl_3rd
	PORT
	(
		CLK2			: in std_logic;
		nRESET			: in std_logic;
		TXEN_B			: in std_logic_vector(9 downto 0);
		TXCF_EMPTY		: in std_logic;
		TXCF_RDREQ		: out std_logic;
		TX_D			: out std_logic
	);
end component;

	signal	reseth		: std_logic;
	signal	TXCF_RDREQ	: std_logic;
	signal	TXCF_WRREQ	: std_logic;
	signal	TXCF_RDEMPTY: std_logic;
	signal	TXEN_B		: std_logic_vector( 9 downto 0);

begin

--*** reset ***--
	reseth <= not nRESET;

--component tx_ctl_2nd
	TXCF_WRREQ <= VALID;

--tx_ck_dcfifo1_48_inst : dcfifo PORT MAP (
--		data		=> TXEN_A(9 downto 0),
--		rdclk		=> CLK2,
--		wrclk		=> CLK1,
--		wrreq		=> TXCF_WRREQ,
--		rdreq		=> TXCF_RDREQ,
--		aclr		=> reseth,
--		rdempty		=> TXCF_RDEMPTY,
--		q			=> TXEN_B(9 downto 0)
--	);

tx_ck_dcfifo1_48_inst : dcfifo_tx_b2 PORT MAP (
		Data		=> TXEN_A(9 downto 0),
		Q			=> TXEN_B(9 downto 0),
		Empty		=> TXCF_RDEMPTY,
		Full		=> open,
		RPReset		=> reseth,
		RdClock		=> CLK2,
		RdEn		=> TXCF_RDREQ,
		Reset		=> reseth,
		WrClock		=> CLK1,
		WrEn		=> TXCF_WRREQ
	);


tx_ctl_3rd_inst : tx_ctl_3rd PORT MAP (
		CLK2		=> CLK2,
		nRESET		=> nRESET,
		TXEN_B		=> TXEN_B(9 downto 0),
		TXCF_EMPTY	=> TXCF_RDEMPTY,
		TXCF_RDREQ	=> TXCF_RDREQ,
		TX_D		=> TX_D
	);


end RTL;



