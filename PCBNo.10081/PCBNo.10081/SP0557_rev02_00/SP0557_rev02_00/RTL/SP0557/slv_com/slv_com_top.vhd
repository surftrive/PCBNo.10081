-------------------------------------------------
--File Name : slv_com_top.vhd
--Project	: S3IO
--
--Date		: 2003/12/11
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by	Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2004/11/01
--Ver		: 3.00
--Doc		: Addition -> CLKCOM_OUT [PLL Output Clock(100MHz)]
--Changed by	Jun Inagaki
-------------------------------------------------
--Date		: 2024/11/22
--Ver		: 4.00
--Doc		: change clk_gen -> clk_gen_S124M
--Changed by	Nobuhisa Hatashima(PHR)
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity slv_com_top is
	port(
		-- System --
		CLKSLV	: in std_logic;	 -- Internal Clock 20MHZ
		CLKBASE : in std_logic;	 -- Communication Clock 20MHZ
		CLKBASEOUT	: out std_logic;	-- Communication Clock 20MHZ Out
		RSTb		: in std_logic;	 -- System Reset (active Low)

		-- S3IO Interface --
		UPLINK_Ip	: in std_logic;	 -- up link RX port(+)
		UPLINK_Op	: out std_logic;	-- up link TX port(+)
		LVCLK_Ip	: in std_logic;	 -- up link CLK port(+)
		UPRX		: out std_logic;	-- up link RX Flag
		UPTX		: out std_logic;	-- up link TX Flag

		-- Slave Address --
		SLVADR		: in std_logic_vector(7 downto 0);	-- Slave Address

		-- Local BUS --
		NSb		 : out std_logic_vector(15 downto 0);	-- Node Select
		ND_0		: in std_logic_vector(7 downto 0);	-- Node0 data bus
		ND_1		: in std_logic_vector(7 downto 0);	-- Node1 data bus
		ND_2		: in std_logic_vector(7 downto 0);	-- Node2 data bus
		ND_3		: in std_logic_vector(7 downto 0);	-- Node3 data bus
		ND_4		: in std_logic_vector(7 downto 0);	-- Node4 data bus
		ND_5		: in std_logic_vector(7 downto 0);	-- Node5 data bus
		ND_6		: in std_logic_vector(7 downto 0);	-- Node6 data bus
		ND_7		: in std_logic_vector(7 downto 0);	-- Node7 data bus
		ND_8		: in std_logic_vector(7 downto 0);	-- Node8 data bus
		ND_9		: in std_logic_vector(7 downto 0);	-- Node9 data bus
		ND_10		: in std_logic_vector(7 downto 0);	-- Node10 data bus
		ND_11		: in std_logic_vector(7 downto 0);	-- Node11 data bus
		ND_12		: in std_logic_vector(7 downto 0);	-- Node12 data bus
		ND_13		: in std_logic_vector(7 downto 0);	-- Node13 data bus
		ND_14		: in std_logic_vector(7 downto 0);	-- Node14 data bus
		ND_15		: in std_logic_vector(7 downto 0);	-- Node15 data bus
		LA			: out std_logic_vector(11 downto 0);	-- Local Address bus
		LDI		 : out std_logic_vector(7 downto 0); -- Local data bus
		IDSb		: out std_logic;	-- ID Select (active Low)
		LGSb		: out std_logic;	-- LOG Select (active Low)
		LRDb		: out std_logic;	-- Local Read (active Low)
		LWEb		: out std_logic;	-- Local Write (active Low)
		LATCH		: out std_logic;	-- Latch Signal (active High)
		LOAD		: out std_logic;	-- Load Signal (active High)
		LRSTb		: out std_logic;	-- Local Reset (active Low)

		-- for TEST --
		CLK_RSTb_OUT	: out std_logic;	-- SLV RESET--2005/01/17
		CLKCOM_OUT		: out std_logic;	-- PLL Output Clock(100MHz)
		LOCKED			: out std_logic	 -- PLL locked signal
		);
end slv_com_top;

architecture RTL of slv_com_top is

signal s_RSTb1	: std_logic;
signal s_RSTb2	 : std_logic;

signal s_PLL_CLK20M	 : std_logic;	-- Clock 20MHz
signal CLK1	 : std_logic;	-- Clock 10MHz
signal CLK2	 : std_logic;	-- Clock 100MHz for Communication
signal CLK2A	: std_logic;	-- Clock 100MHz 90 Delay
signal CLK3	 : std_logic;	-- Clock 100MHz for CRC
signal RX_EMPTY : std_logic;	-- RX FIFO Empty
signal RX_DATA	: std_logic_vector(7 downto 0); -- RX Data
signal RX_RDENB : std_logic;	-- RX Read Enable
signal TX_FULL	: std_logic;	-- TX FIFO Full
signal TX_DATA	: std_logic_vector(7 downto 0); -- TX Data
signal TX_WRENB : std_logic;	-- TX Write Enable
signal RX_ERR	: std_logic;	-- RX K-code Error
signal CRC_ERR	: std_logic;	-- RX CRC Error
signal PACK_END : std_logic;	-- Packet End Signal
signal	RX_DT	: std_logic;

signal LOCKED_RST	: std_logic;
signal CLK_RSTb	 : std_logic;
signal	SYNC_FLG	: std_logic;
signal	TX_RSTb	 : std_logic;
signal	LRESETb	 : std_logic;

signal	SLVADR_HEX	: std_logic_vector(7 downto 0);

-- for clk_gen reset -
signal	ckgen_rstb	: std_logic;
signal	ck_state	: std_logic_vector(1 downto 0);

-- add Nakatsuka
signal	CLK2p_RSTb	: std_logic;
signal	CLK2n_RSTb	: std_logic;
signal	CLK2Ap_RSTb	: std_logic;
signal	CLK2An_RSTb	: std_logic;

signal	s_RSTb3_2p	: std_logic;
signal	s_RSTb3_2n	: std_logic;
signal	s_RSTb3_2Ap	: std_logic;
signal	s_RSTb3_2An	: std_logic;


component slv_ctrl_top
	port(
		RSTb		: in std_logic;	 -- System Reset (active Low)
		CLK1		: in std_logic;	 -- Clock 10MHz
		SLVADR		: in std_logic_vector(7 downto 0);	-- Slave Address
		RX_EMPTY	: in std_logic;	 -- RX FIFO Empty
		RX_DATA	 : in std_logic_vector(7 downto 0);	-- RX Data
		RX_RDENB	: out std_logic;	-- RX Read Enable
		TX_FULL	 : in std_logic;	 -- TX FIFO Full
		TX_DATA	 : out std_logic_vector(7 downto 0); -- TX Data
		TX_WRENB	: out std_logic;	-- TX Write Enable
		RX_ERR		: in std_logic;	 -- RX K-code Error
		CRC_ERR	 : in std_logic;	 -- RX CRC Error
		TX_START	: out std_logic;	-- TX Start Signal
		PACK_END	: in std_logic;	 -- Packet End Signal
		-- Local BUS --
		NSb		 : out std_logic_vector(15 downto 0);-- Node Select
		ND_0		: in std_logic_vector(7 downto 0);	-- Node0 data bus
		ND_1		: in std_logic_vector(7 downto 0);	-- Node1 data bus
		ND_2		: in std_logic_vector(7 downto 0);	-- Node2 data bus
		ND_3		: in std_logic_vector(7 downto 0);	-- Node3 data bus
		ND_4		: in std_logic_vector(7 downto 0);	-- Node4 data bus
		ND_5		: in std_logic_vector(7 downto 0);	-- Node5 data bus
		ND_6		: in std_logic_vector(7 downto 0);	-- Node6 data bus
		ND_7		: in std_logic_vector(7 downto 0);	-- Node7 data bus
		ND_8		: in std_logic_vector(7 downto 0);	-- Node8 data bus
		ND_9		: in std_logic_vector(7 downto 0);	-- Node9 data bus
		ND_10		: in std_logic_vector(7 downto 0);	-- Node10 data bus
		ND_11		: in std_logic_vector(7 downto 0);	-- Node11 data bus
		ND_12		: in std_logic_vector(7 downto 0);	-- Node12 data bus
		ND_13		: in std_logic_vector(7 downto 0);	-- Node13 data bus
		ND_14		: in std_logic_vector(7 downto 0);	-- Node14 data bus
		ND_15		: in std_logic_vector(7 downto 0);	-- Node15 data bus
		LA			: out std_logic_vector(11 downto 0);-- Local Address bus
		LDI		 : out std_logic_vector(7 downto 0); -- Local data bus
		IDSb		: out std_logic;	-- ID Select (active Low)
		LGSb		: out std_logic;	-- LOG Select (active Low)
		LRDb		: out std_logic;	-- Local Read (active Low)
		LWEb		: out std_logic;	-- Local Write (active Low)
		LATCH		: out std_logic;	-- Latch Signal (active High)
		LOAD		: out std_logic;	-- Load Signal (active High)
		LRSTb		: out std_logic	 -- Local Reset (active Low)
		);
end component;

--2024/11/22 add
component CLK_gen_S124M
	port(
		RSTb			: in	std_logic;		-- power on reset
		CLK_BASE_20M	: in	std_logic;		-- Clock 20MHZ

		CLK_PLL_10M		: out	std_logic;		-- Clock 10MHZ PLL synchronization
		CLK_PLL_20M		: out	std_logic;		-- Clock 20MHZ PLL synchronization
		CLK_PLL_100M	: out	std_logic;		-- Clock 100MHZ PLL synchronization
		CLK_PLL_100M_90	: out	std_logic;		-- Clock 100MHZ PLL synchronization 90shift
		LOCKED			: out	std_logic		-- PLL locked signal
		);
end component;

component rx_com
	port(
		CLK1			: in std_logic;						 -- Clock 10MHz
		CLK2			: in std_logic;						 -- Clock 10MHz
		CLK2A			: in std_logic;						 -- Clock 100MHz_90
		CLK3			: in std_logic;						 -- Clock 100MHz fro CRC
		nRESET			: in std_logic;						 -- power on reset
		RX_D			: in std_logic;						 -- rx_sirial_data in
		RX_RDREQ		: in std_logic;						 -- rx_fifo write_request
		HUB_EN			: in std_logic;						 -- hub_enable
		RX_RDEMPTY		: out std_logic;						-- fifo empty_flag
		RX_RDFULL		: out std_logic;						-- fifo full_flag
		K_ERR			: out std_logic;						-- 8b10b_e k_code error
		RX_START		: out std_logic;						-- rx_start flag
		RXD			 : out std_logic_vector(7 downto 0);	 -- rx_fifo read data
		CRC_ERR		 : out std_logic ;						-- crc_error flag
		SYNC_FLG		: out std_logic;
		IDLE_EN		 : out std_logic;
		PACK_END		: out std_logic						 -- Packet End Signal
		);

end component;

component tx_com
	port(
		CLK1			: in std_logic;						 -- Clock 10MHz
		CLK2			: in std_logic;						 -- Clock 100MHz
		CLK3			: in std_logic;						 -- Clock 100MHz for CRC
		nRESET			: in std_logic;						 -- power on reset
		TXD			 : in std_logic_vector(7 downto 0);		-- tx_fifo write data
		TX_WRREQ		: in std_logic;						 -- fifo write_request
		HUB_EN			: in std_logic;						 -- hub_enable
		TX_WREMPTY		: out std_logic;						-- fifo empty_flag
		TX_WRFULL		: out std_logic;						-- fifo full_flag
		TX_END			: out std_logic;						-- tx_end flag
		TX_D			: out std_logic						 -- tx_sirial_data out
		);
end component;

component rst_cnt
	port(
		LOCAL_CLK		: in std_logic;		-- Clock 10MHz
		CLK2			: in std_logic;		-- Clock 100MHz 			-- add Nakatsuka
		CLK2A			: in std_logic;		-- Clock 100MHz 90shift		-- add Nakatsuka
		LOCKED_RST		: in std_logic;		-- PLL Reset
		CLK_RSTb		: out std_logic;	-- LOCAL_CLK sync reset		-- add Nakatsuka
		CLK2p_RSTb		: out std_logic;	-- CLK2 posedge sync reset	-- add Nakatsuka
		CLK2n_RSTb		: out std_logic;	-- CLK2 negedge sync reset	-- add Nakatsuka
		CLK2Ap_RSTb		: out std_logic;	-- CLK2A posedge sync reset	-- add Nakatsuka
		CLK2An_RSTb		: out std_logic		-- CLK2A negedge sync reset	-- add Nakatsuka
		);
end component;

component cds
	port(
		CLK2			: in std_logic;	 -- Clock 100MHZ
		CLK2A			: in std_logic;	 -- Clock 100MHZ_90
--		nRESET			: in std_logic;	 -- power on reset
		nRESET_CLK2p	: in std_logic;	 -- add Nakatsuka
		nRESET_CLK2n	: in std_logic;	 -- add Nakatsuka
		nRESET_CLK2Ap	: in std_logic;	 -- add Nakatsuka
		nRESET_CLK2An	: in std_logic;	 -- add Nakatsuka
		RX_D			: in std_logic;	 -- rx_data_in
		RX_DT			: out std_logic	 -- rx_data
		);
end component;

component slvadr_cnv
	port(
		CLK		 : in	std_logic;					-- Clock 20MHZ
		nRST		: in	std_logic;					-- Local Reset (active Low)
		DEC_IN		: in	std_logic_vector(7 downto 0);
		HEX_OUT	 : out std_logic_vector(7 downto 0)		--
		);
end component;

begin

s_RSTb1	<=	RSTb and CLK_RSTb;
s_RSTb2	<=	RSTb and ckgen_rstb;

s_RSTb3_2p	<=	RSTb and CLK2p_RSTb;	 -- add Nakatsuka
s_RSTb3_2n	<=	RSTb and CLK2n_RSTb;	 -- add Nakatsuka
s_RSTb3_2Ap	<=	RSTb and CLK2Ap_RSTb;	 -- add Nakatsuka
s_RSTb3_2An	<=	RSTb and CLK2An_RSTb;	 -- add Nakatsuka


TX_RSTb <= RSTb and (not SYNC_FLG) and CLK_RSTb and LRESETb;
LRSTb	<= LRESETb;

CLKBASEOUT <= s_PLL_CLK20M;
UPRX <= RX_RDENB;
UPTX <= TX_WRENB;
CLKCOM_OUT <= CLK2;

CLK_RSTb_OUT <= CLK_RSTb;--2005/01/17
-- clk_gen reset --
	process (RSTb, CLKSLV)
	begin
		if (RSTb = '0') then
			ckgen_rstb <= '1';
			ck_state <= "00";
		elsif(CLKSLV'event and CLKSLV = '1') then
			case ck_state is
				when "00" =>
					ckgen_rstb <= '1';
					if (LRESETb = '0' and CLK_RSTb = '1') then
						ck_state <= "01";
					else
						ck_state <= "00";
					end if;
				when "01" =>
					ckgen_rstb <= '0';
					if (CLK_RSTb = '0') then
						ck_state <= "11";
					else
						ck_state <= "01";
					end if;
				when "11" =>
					ckgen_rstb <= '1';
					if (LRESETb = '1' and CLK_RSTb = '1') then
						ck_state <= "10";
					else
						ck_state <= "11";
					end if;
				when "10" =>
					ckgen_rstb <= '1';
					ck_state <= "00";
				when others =>
					ckgen_rstb <= '1';
					ck_state <= "00";
			end case;
		end if;
	end process;
--------------------------------------------------

rst_cnt_inst : rst_cnt port map (
	LOCAL_CLK	=> CLKSLV,
	CLK2		=> CLK2,		-- add Nakatsuka
	CLK2A		=> CLK2A,		-- add Nakatsuka
	LOCKED_RST	=> LOCKED_RST,
	CLK_RSTb	=> CLK_RSTb,
	CLK2p_RSTb	=> CLK2p_RSTb,	-- add Nakatsuka
	CLK2n_RSTb	=> CLK2n_RSTb,	-- add Nakatsuka
	CLK2Ap_RSTb	=> CLK2Ap_RSTb,	-- add Nakatsuka
	CLK2An_RSTb	=> CLK2An_RSTb	-- add Nakatsuka
	);

slv_ctrl_top_inst : slv_ctrl_top port map (
	RSTb		=> s_RSTb1,
	CLK1		=> CLK1,
	SLVADR		=> SLVADR_HEX,
	RX_EMPTY	=> RX_EMPTY,
	RX_DATA	 => RX_DATA,
	RX_RDENB	=> RX_RDENB,
	TX_FULL	 => TX_FULL,
	TX_DATA	 => TX_DATA,
	TX_WRENB	=> TX_WRENB,
	RX_ERR		=> RX_ERR,
	CRC_ERR	 => CRC_ERR,
	TX_START	=> open,
	PACK_END	=> PACK_END,	-- Packet End Signal
	-- Local BUS --
	NSb		 => NSb,
	ND_0		=> ND_0,
	ND_1		=> ND_1,
	ND_2		=> ND_2,
	ND_3		=> ND_3,
	ND_4		=> ND_4,
	ND_5		=> ND_5,
	ND_6		=> ND_6,
	ND_7		=> ND_7,
	ND_8		=> ND_8,
	ND_9		=> ND_9,
	ND_10		=> ND_10,
	ND_11		=> ND_11,
	ND_12		=> ND_12,
	ND_13		=> ND_13,
	ND_14		=> ND_14,
	ND_15		=> ND_15,
	LA			=> LA,
	LDI		 => LDI,
	IDSb		=> IDSb,
	LGSb		=> LGSb,
	LRDb		=> LRDb,
	LWEb		=> LWEb,
	LATCH		=> LATCH,
	LOAD		=> LOAD,
	LRSTb		=> LRESETb
	);

slvadr_cnv_inst: slvadr_cnv	 port map(
--		CLK		=> CLKSLV,
		CLK		=> s_PLL_CLK20M,
		nRST	=> RSTb,
		DEC_IN	=> SLVADR,
		HEX_OUT => SLVADR_HEX
		);

--2024/11/22 add
clk_gen_inst2:	clk_gen_S124M	 
	port map(
		RSTb			=> s_RSTb2,
		CLK_BASE_20M	=> CLKBASE,
		CLK_PLL_10M		=> CLK1,
		CLK_PLL_20M		=> s_PLL_CLK20M,
		CLK_PLL_100M	=> CLK2,
		CLK_PLL_100M_90	=> CLK2A,
		LOCKED			=> LOCKED_RST
	);

CLK3 <= CLK2;

LOCKED <= LOCKED_RST;

tx_com_inst : tx_com	port map(
		CLK1		=> CLK1,
		CLK2		=> CLK2,
		CLK3		=> CLK3,
		nRESET		=> TX_RSTb,
		TXD		 => TX_DATA,
		TX_WRREQ	=> TX_WRENB,
		HUB_EN		=> '0',
		TX_END		=> open,
		TX_D		=> UPLINK_Op,
		TX_WREMPTY	=> open,
		TX_WRFULL	=> TX_FULL
		);

rx_com_inst : rx_com	port map(
		CLK1		=> CLK1,
		CLK2		=> CLK2,
		CLK2A		=> CLK2A,
		CLK3		=> CLK3,
		nRESET		=> s_RSTb1,
		RXD		 	=> RX_DATA,
		RX_RDREQ	=> RX_RDENB,
		HUB_EN		=> '0',
		RX_RDEMPTY	=> RX_EMPTY,
		RX_RDFULL	=> open,
		RX_START	=> open,
		RX_D		=> RX_DT,
		K_ERR		=> RX_ERR,
		SYNC_FLG	=> SYNC_FLG,
		PACK_END	=> PACK_END,	-- Packet End Signal
		IDLE_EN	 => open,
		CRC_ERR	 => CRC_ERR
		);

cds_inst : cds port map(
		CLK2			=> CLK2,
		CLK2A			=> CLK2A,
--		nRESET			=> s_RSTb1,
		nRESET_CLK2p	=> s_RSTb3_2p,
		nRESET_CLK2n	=> s_RSTb3_2n,
		nRESET_CLK2Ap	=> s_RSTb3_2Ap,
		nRESET_CLK2An	=> s_RSTb3_2An,
		RX_D			=> UPLINK_Ip,
		RX_DT			=> RX_DT
		);

end RTL;