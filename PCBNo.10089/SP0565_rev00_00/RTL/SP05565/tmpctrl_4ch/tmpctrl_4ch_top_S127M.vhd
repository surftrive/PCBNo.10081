-------------------------------------------------
--File Name : tmpctrl_4ch_top_S127M.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/14
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2005/02/22
--Ver		: 1.00
--Doc		: Added HTANDCLP
--Changed by Jun Inagaki
-------------------------------------------------
--Date		: 2005/09/15
--Ver		: 4.00
--Doc		: Separated Temp_Ctrl_Main	and ADC_Ctrl
--			Fixed Logic
--			Delete General PIO
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2005/12/05
--Ver		: 5.00
--Doc		: [temp_cut_ref_reg] is write-protected
--			: [temp_cut_ref_reg] Initial Value
--			:			190h (400) -> 64h(100)
--Changed by J.I
-------------------------------------------------
--Date		: 2009/04/08
--Ver		: 2.00
--Doc		: Delete --> "HEATREF" is disregarded at the time of [CLON='1']
--Changed by	J.I
-------------------------------------------------
--Date		: 2010/12/24
--Ver		: 3.00
--Doc		: [100V MODE] Duty 4/8
--Changed by	J.I
-------------------------------------------------
--Date		: 2010/12/25
--Ver		: 4.00
--Doc		: [100V MODE] Duty 4/8 -> */8
--Changed by	J.I
-------------------------------------------------
--Date		: 2015/12/10
--Ver		: 5.00
--Doc		: 4CH TEMPERATURE CONTROL IP
--			: ADD REG '1Ah''1Bh''1Ch''1Dh'
--Changed by	J.I
-------------------------------------------------
--Date		: 2025/12/05
--Ver		: 6.00
--Doc		: custum for PCBNO10089(Linear control)
--Changed by  Nobuhisa Hatashima(PHR)
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tmpctrl_4ch_top_S127M is
	Port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		NSb			: in	std_logic;
		IDSb		: in	std_logic;
		LGSb		: in	std_logic;
		LATCH		: in	std_logic;
		LOAD		: in	std_logic;
		LA			: in	std_logic_vector( 4 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LDI			: in	std_logic_vector( 7 downto 0);
		LDO			: out	std_logic_vector( 7 downto 0);
		CKEN1k		: in	std_logic;
		TEMP0_DATA	: in	std_logic_vector(11 downto 0);
		TEMP1_DATA	: in	std_logic_vector(11 downto 0);
		TEMP2_DATA	: in	std_logic_vector(11 downto 0);
		TEMP3_DATA	: in	std_logic_vector(11 downto 0);
		CLON		: out	std_logic_vector( 3 downto 0);
		CLP			: out	std_logic_vector( 3 downto 0);
		HTON		: out	std_logic_vector( 3 downto 0);
		HTP			: out	std_logic_vector( 3 downto 0);
		CLPORHTPhf	: out	std_logic_vector( 3 downto 0);
		CLPORHTP	: out	std_logic_vector( 3 downto 0);
		TERM		: out	std_logic;						-- Terminal Signal
		CH0TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH0
		CH1TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH1
		CH2TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH2
		CH3TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH3
		NUM		 	: out	std_logic_vector(2 downto 0);	-- Number of Pulse (1/8-8/8)
		NEG		 	: out	std_logic;						-- Negative signal of subtract value (Measure - target)
		ENB		 	: out	std_logic						-- Enable signal of temp ctrl
	);
end tmpctrl_4ch_top_S127M;

architecture RTL of tmpctrl_4ch_top_S127M is

-- Componetn Definition
component fc_dec	-- Standard Decoder for S3IO Function
	port (
		NSb		: in	std_logic;
		IDSb	: in	std_logic;
		LGSb	: in	std_logic;
		LATCH	: in	std_logic;
		LOAD	: in	std_logic;
		LOGSEL	: out	std_logic;
		IDSEL	: out	std_logic;
		REGSEL	: out	std_logic;
		LATCH_L	: out	std_logic;
		LOAD_L	: out	std_logic
	);
end component;

component fc_sel	-- Standard Selector for S3IO Function
	port (
		NSb		: in	std_logic;
		REGDO	: in	std_logic_vector(7 downto 0);
		IDDO	: in	std_logic_vector(7 downto 0);
		LOGDO	: in	std_logic_vector(7 downto 0);
		LDO		: out	std_logic_vector(7 downto 0)
	);
end component;

component tmpctrl_4ch_id -- log_cleia ID Block
	port (
		IDSEL	: in	std_logic;
		LRDb	: in	std_logic;
		LA		: in	std_logic_vector(4 downto 0);
		IDDO	: out	std_logic_vector(7 downto 0)
	);
end component;

component tmpctrl_4ch_reg_S127M -- log_cleia REG Block
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		REGSEL		: in	std_logic;
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LA			: in	std_logic_vector(4 downto 0);
		LDI			: in	std_logic_vector(7 downto 0);
		REGDO		: out	std_logic_vector(7 downto 0);
		LATCH_L		: in	std_logic;
		LOAD_L		: in	std_logic;
		CKEN1k		: in	std_logic;
		TEMP0_DATA	: in	std_logic_vector(11 downto 0);
		TEMP1_DATA	: in	std_logic_vector(11 downto 0);
		TEMP2_DATA	: in	std_logic_vector(11 downto 0);
		TEMP3_DATA	: in	std_logic_vector(11 downto 0);
		CLON		: out	std_logic_vector(3 downto 0);
		CLP			: out	std_logic_vector(3 downto 0);
		HTON		: out	std_logic_vector(3 downto 0);
		HTP			: out	std_logic_vector(3 downto 0);
		CLPORHTPhf	: out	std_logic_vector(3 downto 0);
		CLPORHTP	: out	std_logic_vector(3 downto 0);
		TERM		: out	std_logic;						-- Terminal Signal
		CH0TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH0
		CH1TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH1
		CH2TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH2
		CH3TC_ENB	: out	std_logic;						-- TMPCTRL Enable CH3
		NUM			: out	std_logic_vector(2 downto 0);	-- Number of Pulse (1/8-8/8)
		NEG			: out	std_logic;						-- Negative signal of subtract value (Measure - target)
		ENB			: out	std_logic						-- Enable signal of temp ctrl
	);
end component;

-- signal	Definition
signal	REGSEL	: std_logic;
signal	IDSEL	: std_logic;
signal	REGDO	: std_logic_vector(7 downto 0);
signal	IDDO	: std_logic_vector(7 downto 0);
signal	LOGDO	: std_logic_vector(7 downto 0);
signal	LATCH_L	: std_logic;
signal	LOAD_L	: std_logic;
signal	s_CLP	: std_logic_vector(3 downto 0);
signal	s_HTP	: std_logic_vector(3 downto 0);

-- Main	Block
begin

CLP<=s_CLP;
HTP<=s_HTP;

fc_dec_inst : fc_dec port map(
	NSb		=> NSb,
	IDSb	=> IDSb,
	LGSb	=> LGSb,
	LATCH	=> LATCH,
	LOAD	=> LOAD,
	REGSEL	=> REGSEL,
	IDSEL	=> IDSEL,
	LATCH_L	=> LATCH_L,
	LOAD_L	=> LOAD_L
);

LOGDO <= (others => '0');

fc_sel_inst : fc_sel port map(
	NSb		=> NSb,
	REGDO	=> REGDO,
	IDDO	=> IDDO,
	LOGDO	=> LOGDO,
	LDO		=> LDO
);

tmpctrl_4ch_id_inst : tmpctrl_4ch_id port map(
	IDSEL	=> IDSEL,
	LRDb	=> LRDb,
	LA		=> LA,
	IDDO	=> IDDO
);

tmpctrl_4ch_reg_inst : tmpctrl_4ch_reg_S127M port map(
	CLK			=> CLK,
	LRSTb		=> LRSTb,
	REGSEL		=> REGSEL,
	LRDb		=> LRDb,
	LWEb		=> LWEb,
	LA			=> LA,
	LDI			=> LDI,
	REGDO		=> REGDO,
	LATCH_L		=> LATCH_L,
	LOAD_L		=> LOAD_L,
	CLON		=> CLON,
	CLP			=> s_CLP,
	HTON		=> HTON,
	HTP			=> s_HTP,
	CLPORHTPhf	=> CLPORHTPhf,
	CLPORHTP	=> CLPORHTP,
	CKEN1k		=> CKEN1k,
	TEMP0_DATA	=> TEMP0_DATA,
	TEMP1_DATA	=> TEMP1_DATA,
	TEMP2_DATA	=> TEMP2_DATA,
	TEMP3_DATA	=> TEMP3_DATA,
	TERM			=> TERM,
	CH0TC_ENB	=> CH0TC_ENB,
	CH1TC_ENB	=> CH1TC_ENB,
	CH2TC_ENB	=> CH2TC_ENB,
	CH3TC_ENB	=> CH3TC_ENB,
	NUM			=> NUM,
	NEG			=> NEG,
	ENB			=> ENB
);

end RTL;
