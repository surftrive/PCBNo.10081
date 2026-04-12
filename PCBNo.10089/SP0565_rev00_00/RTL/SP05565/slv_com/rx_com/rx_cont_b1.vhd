-------------------------------------------------
--File Name : rx_cont_b1.vhd
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
--			  Delete Clock Detect Sequencer
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity rx_cont_b1 is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK2			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		RX_D			: in std_logic;							-- rx_data_in
		RXDE_C			: out std_logic_vector(9 downto 0);		-- rx_data(10bit)
		ENABLE			: out std_logic;						-- 8b10B data enable
		IDLE_DEL		: out std_logic;						-- IDLE_code delete
		IDLE_EN_O		: out std_logic;
		RD_IN			: out std_logic							-- running_disparity insert
		);
end rx_cont_b1;

architecture RTL of rx_cont_b1 is

--component dcfifo
--	GENERIC (LPM_WIDTH: POSITIVE:=11;
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
component dcfifo_rx_b1 is
	port (Data	:in std_logic_vector(10 downto 0);
		Q	:out std_logic_vector(10 downto 0);
		Empty	:out std_logic;
		Full	:out std_logic;
		RPReset	:in std_logic;
		RdClock	:in std_logic;
		RdEn	:in std_logic;
		Reset	:in std_logic;
		WrClock	:in std_logic;
		WrEn	:in std_logic
	);
end component dcfifo_rx_b1;

component rx_ctl_1st
	PORT
	(
		CLK2			: in std_logic;
		nRESET			: in std_logic;
		RX_DT			: in std_logic;
		RXDE_B			: out std_logic_vector(9 downto 0);
		RXCF_WRREQ		: out std_logic;
		IDLE_EN			: out std_logic
	);
end component;

	signal	reseth		: std_logic;
	signal	RXDE_B		: std_logic_vector( 9 downto 0);
	signal	RXCF_RDREQ	: std_logic;
	signal	RXCF_WRREQ	: std_logic;
	signal	RXCF_RDEMPTY: std_logic;
	signal	IDLE_EN		: std_logic;
	signal	rx_data_b	: std_logic_vector( 10 downto 0);
	signal	rx_data_c	: std_logic_vector( 10 downto 0);
	signal	data_en		: std_logic;

begin

--************************************--
--			rx_ctl_2nd module		  --
--************************************--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			RXCF_RDREQ <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(RXCF_RDEMPTY='0') then
				RXCF_RDREQ <= '1';
			else
				RXCF_RDREQ <= '0';
			end if;
		end if;
	end process;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			data_en <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(RXCF_RDREQ='1') then
				data_en <= '1';
			else
				data_en <= '0';
			end if;
		end if;
	end process;

	ENABLE	<= data_en;

	IDLE_DEL	<= data_en and rx_data_c(10);

	RD_IN	<= '0';

	reseth	<= not nRESET;

	rx_data_b	<= IDLE_EN & RXDE_B(9 downto 0);
	RXDE_C		<= rx_data_c(9 downto 0);

	IDLE_EN_O	<= IDLE_EN;

--rx_ck_dcfifo1_48_inst : dcfifo PORT MAP (
--		data		=> rx_data_b(10 downto 0),
--		rdclk		=> CLK1,
--		wrclk		=> CLK2,
--		wrreq		=> RXCF_WRREQ,
--		rdreq		=> RXCF_RDREQ,
--		aclr		=> reseth,
--		rdempty		=> RXCF_RDEMPTY,
--		q			=> rx_data_c(10 downto 0)
--	);

rx_ck_dcfifo1_48_inst : dcfifo_rx_b1 PORT MAP (
		Data	=> rx_data_b(10 downto 0),
		Q		=> rx_data_c(10 downto 0),
		Empty	=> RXCF_RDEMPTY,
		Full	=> open,
		RPReset	=> reseth,
		RdClock	=> CLK1,
		RdEn	=> RXCF_RDREQ,
		Reset	=> reseth,
		WrClock	=> CLK2,
		WrEn	=> RXCF_WRREQ
	);

rx_ctl_1st_inst : rx_ctl_1st PORT MAP (
		CLK2		=> CLK2,
		nRESET		=> nRESET,
		RX_DT		=> RX_D,
		RXDE_B		=> RXDE_B(9 downto 0),
		RXCF_WRREQ	=> RXCF_WRREQ,
		IDLE_EN		=> IDLE_EN
	);

end RTL;



