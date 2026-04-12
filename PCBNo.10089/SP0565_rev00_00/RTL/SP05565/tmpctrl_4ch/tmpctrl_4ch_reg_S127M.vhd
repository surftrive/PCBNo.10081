-------------------------------------------------
--File Name : tmpctrl_4ch_reg_S127M.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/14
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2005/09/12
--Ver		: 2.00
--Doc		: Separated Temp_Ctrl_Main and ADC_Ctrl
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2005/09/15
--Ver		: 4.00
--Doc		: Delete Logic Settings
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2005/12/05
--Ver		: 5.00
--Doc		: [temp_cut_ref_reg] is write-protected
--			: [temp_cut_ref_reg] Initial Value
--			:			190h (400) -> 64h(100)
--Changed by J.I
-------------------------------------------------
--Date		: 2006/05/23
--Ver		: 5.10
--Doc		: component temp_rng_chk
--			: "HEATREF" is disregarded at the time of [CLON='1']
--Changed by	J.I
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
--Doc		: ADD REG '1Ah''1Bh''1Ch''1Dh'
--Changed by	J.I
-------------------------------------------------
--Date		: 2025/02/03
--Ver		: 6.00
--Doc		: custum for PCBNO10089(Linear control)
--Changed by	Nobuhisa Hatashima(PHR)
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity tmpctrl_4ch_reg_S127M is
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		REGSEL		: in	std_logic;
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LA			: in	std_logic_vector( 4 downto 0);
		LDI			: in	std_logic_vector( 7 downto 0);
		REGDO		: out	std_logic_vector( 7 downto 0);
		LATCH_L		: in	std_logic;
		LOAD_L		: in	std_logic;
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

		NUM			: out	std_logic_vector(2 downto 0);	-- Number of Pulse (1/8-8/8)
		NEG			: out	std_logic;						-- Negative signal of subtract value (Measure - target)
		ENB			: out	std_logic						-- Enable signal of temp ctrl
	);
end tmpctrl_4ch_reg_S127M;

architecture RTL of tmpctrl_4ch_reg_S127M is

---Component Deffinition
component temp_dec
	port (
		REGSEL	: in	std_logic;
		LA		: in	std_logic_vector( 4 downto 0);
		SEL		: out	std_logic_vector(31 downto 0)
	);
end component;

component temp_meas_reg_S127M
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector( 7 downto 0);
		LRDb		: in	std_logic;
		LOAD_L		: in	std_logic;
		MEASDO		: out	std_logic_vector( 7 downto 0);
		TEMP0_DATA	: in	std_logic_vector(11 downto 0);
		TEMP1_DATA	: in	std_logic_vector(11 downto 0);
		TEMP2_DATA	: in	std_logic_vector(11 downto 0);
		TEMP3_DATA	: in	std_logic_vector(11 downto 0);
		TEMP_CH		: in	std_logic_vector( 1 downto 0);
		TEMP_WRP	: in	std_logic;
		CH0MEAS		: out	std_logic_vector(11 downto 0);
		CH1MEAS		: out	std_logic_vector(11 downto 0);
		CH2MEAS		: out	std_logic_vector(11 downto 0);
		CH3MEAS		: out	std_logic_vector(11 downto 0)
	);
end component;

component temp_ref_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector( 7 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LATCH_L		: in	std_logic;
		LDI			: in	std_logic_vector( 7 downto 0);
		REFDO		: out	std_logic_vector( 7 downto 0);
		CH0REF		: out	std_logic_vector(11 downto 0);
		CH1REF		: out	std_logic_vector(11 downto 0);
		CH2REF		: out	std_logic_vector(11 downto 0);
		CH3REF		: out	std_logic_vector(11 downto 0)
	);
end component;

component temp_ajst_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector(3 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LATCH_L		: in	std_logic;
		LDI			: in	std_logic_vector(7 downto 0);
		AJSTDO		: out	std_logic_vector(7 downto 0);
		CH0AJST		: out	std_logic_vector(7 downto 0);
		CH1AJST		: out	std_logic_vector(7 downto 0);
		CH2AJST		: out	std_logic_vector(7 downto 0);
		CH3AJST		: out	std_logic_vector(7 downto 0)
	);
end component;

component temp_ctst_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector(3 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LATCH_L		: in	std_logic;
		LOAD_L		: in	std_logic;
		LDI			: in	std_logic_vector(7 downto 0);
		CTSTDO		: out	std_logic_vector(7 downto 0);
		CUT			: in	std_logic_vector(3 downto 0);
		LIMIT		: out	std_logic_vector(3 downto 0);
		IDLING		: out	std_logic_vector(3 downto 0);
		CH0CLHTb	: out	std_logic;
		CH0TC_ENB	: out	std_logic;
		CH1CLHTb	: out	std_logic;
		CH1TC_ENB	: out	std_logic;
		CH2CLHTb	: out	std_logic;
		CH2TC_ENB	: out	std_logic;
		CH3CLHTb	: out	std_logic;
		CH3TC_ENB	: out	std_logic
	);
end component;

component temp_cut_ref_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector( 1 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LATCH_L		: in	std_logic;
		LDI			: in	std_logic_vector( 7 downto 0);
		CUTDO		: out	std_logic_vector( 7 downto 0);
		CUTREF		: out	std_logic_vector(11 downto 0)
	);
end component;

component temp_idlm_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector(3 downto 0);
		LRDb		: in	std_logic;
		LWEb		: in	std_logic;
		LATCH_L		: in	std_logic;
		LDI			: in	std_logic_vector(7 downto 0);
		IDLMDO		: out	std_logic_vector(7 downto 0);
		CH0IDLM		: out	std_logic_vector(7 downto 0);
		CH1IDLM		: out	std_logic_vector(7 downto 0);
		CH2IDLM		: out	std_logic_vector(7 downto 0);
		CH3IDLM		: out	std_logic_vector(7 downto 0)
	);
end component;

component temp_prm_sel
	port (
		CH0MEAS		: in	std_logic_vector(11 downto 0);
		CH0REF		: in	std_logic_vector(11 downto 0);
		CH0AJST		: in	std_logic_vector( 7 downto 0);
		CH0CLHTb	: in	std_logic;
		CH0TC_ENB	: in	std_logic;
		CH1MEAS		: in	std_logic_vector(11 downto 0);
		CH1REF		: in	std_logic_vector(11 downto 0);
		CH1AJST		: in	std_logic_vector( 7 downto 0);
		CH1CLHTb	: in	std_logic;
		CH1TC_ENB	: in	std_logic;
		CH2MEAS		: in	std_logic_vector(11 downto 0);
		CH2REF		: in	std_logic_vector(11 downto 0);
		CH2AJST		: in	std_logic_vector( 7 downto 0);
		CH2CLHTb	: in	std_logic;
		CH2TC_ENB	: in	std_logic;
		CH3MEAS		: in	std_logic_vector(11 downto 0);
		CH3REF		: in	std_logic_vector(11 downto 0);
		CH3AJST		: in	std_logic_vector( 7 downto 0);
		CH3CLHTb	: in	std_logic;
		CH3TC_ENB	: in	std_logic;
		PRM_CH		: in	std_logic_vector( 1 downto 0);
		MEAS		: out	std_logic_vector(11 downto 0);
		REF			: out	std_logic_vector(11 downto 0);
		AJST		: out	std_logic_vector( 7 downto 0);
		CLHTb		: out	std_logic;
		TC_ENB		: out	std_logic
	);
end component;

component temp_edge_dtct
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		CH0CLHTb	: in	std_logic;
		CH1CLHTb	: in	std_logic;
		CH2CLHTb	: in	std_logic;
		CH3CLHTb	: in	std_logic;
		CHANGE		: out	std_logic_vector(3 downto 0)
	);
end component;

component temp_rng_chk
	port (
		CH0MEAS		: in	std_logic_vector(11 downto 0);
		CH1MEAS		: in	std_logic_vector(11 downto 0);
		CH2MEAS		: in	std_logic_vector(11 downto 0);
		CH3MEAS		: in	std_logic_vector(11 downto 0);
		CUTREF		: in	std_logic_vector(11 downto 0);
		CUT			: out	std_logic_vector( 3 downto 0)
	);
end component;

component temp_ctrl
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		TEMP_WRP	: in	std_logic;
		TEMP_CH		: in	std_logic_vector( 1 downto 0);
		MEAS		: in	std_logic_vector(11 downto 0);
		REF			: in	std_logic_vector(11 downto 0);
		AJST		: in	std_logic_vector( 7 downto 0);
		CLHTb		: in	std_logic;
		NUM			: out	std_logic_vector( 2 downto 0);
		NEG			: out	std_logic;
		NUM_WRP		: out	std_logic;
		PRM_CH		: out	std_logic_vector( 1 downto 0)
	);
end component;

component temp_plsnum_reg
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		SEL			: in	std_logic_vector(3 downto 0);
		LRDb		: in	std_logic;
		LOAD_L		: in	std_logic;
		MODDO		: out	std_logic_vector(7 downto 0);
		-------------------------------------------
		NUM			: in	std_logic_vector(2 downto 0);
		NEG			: in	std_logic;
		CLHTb		: in	std_logic;
		TC_ENB		: in	std_logic;
		NUM_WRP		: in	std_logic;
		PRM_CH		: in	std_logic_vector(1 downto 0);
		CHANGE		: in	std_logic_vector(3 downto 0);
		CUT			: in	std_logic_vector(3 downto 0);
		CH0NUM		: out	std_logic_vector(2 downto 0);
		CH0NEG		: out	std_logic;
		CH0ENB		: out	std_logic;
		CH0COOL		: out	std_logic;
		CH1NUM		: out	std_logic_vector(2 downto 0);
		CH1NEG		: out	std_logic;
		CH1ENB		: out	std_logic;
		CH1COOL		: out	std_logic;
		CH2NUM		: out	std_logic_vector(2 downto 0);
		CH2NEG		: out	std_logic;
		CH2ENB		: out	std_logic;
		CH2COOL		: out	std_logic;
		CH3NUM		: out	std_logic_vector(2 downto 0);
		CH3NEG		: out	std_logic;
		CH3ENB		: out	std_logic;
		CH3COOL		: out	std_logic
	);
end component;

component temp_plsmod
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		PLS			: in	std_logic_vector(7 downto 0);
		NUM			: in	std_logic_vector(2 downto 0);
		NEG			: in	std_logic;
		TERM		: in	std_logic;
		DLY			: in	std_logic_vector(1 downto 0);
		COOL		: in	std_logic;
		ENB			: in	std_logic;
		LIMIT		: in	std_logic;
		IDLING		: in	std_logic;
		IDLM		: in	std_logic_vector(7 downto 0);
		CLON		: out	std_logic;
		CLP			: out	std_logic;
		HTON		: out	std_logic;
		HTP			: out	std_logic;
		CLPORHTPhf	: out	std_logic;
		CLPORHTP	: out	std_logic
	);
end component;

component temp_plsgen
	port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;
		PLS			: out	std_logic_vector(7 downto 0);
		TERM		: out	std_logic
	);
end component;

---constant	Deffinition
constant	cst00	: std_logic_vector(1 downto 0) := "00";
constant	cst01	: std_logic_vector(1 downto 0) := "01";
constant	cst10	: std_logic_vector(1 downto 0) := "10";
constant	cst11	: std_logic_vector(1 downto 0) := "11";

---signal	Deffinition
signal	SEL				: std_logic_vector(31 downto 0);
signal	MEASDO			: std_logic_vector( 7 downto 0);
signal	CH0MEAS			: std_logic_vector(11 downto 0);
signal	CH1MEAS			: std_logic_vector(11 downto 0);
signal	CH2MEAS			: std_logic_vector(11 downto 0);
signal	CH3MEAS			: std_logic_vector(11 downto 0);
signal	REFDO			: std_logic_vector( 7 downto 0);
signal	CH0REF			: std_logic_vector(11 downto 0);
signal	CH1REF			: std_logic_vector(11 downto 0);
signal	CH2REF			: std_logic_vector(11 downto 0);
signal	CH3REF			: std_logic_vector(11 downto 0);
signal	AJSTDO			: std_logic_vector( 7 downto 0);
signal	CH0AJST			: std_logic_vector( 7 downto 0);
signal	CH1AJST			: std_logic_vector( 7 downto 0);
signal	CH2AJST			: std_logic_vector( 7 downto 0);
signal	CH3AJST			: std_logic_vector( 7 downto 0);
signal	CTSTDO			: std_logic_vector( 7 downto 0);
signal	CUT				: std_logic_vector( 3 downto 0);
signal	CH0CLHTb		: std_logic;
signal	s_CH0TC_ENB		: std_logic;		-- Change 2020/11/11
signal	CH1CLHTb		: std_logic;
signal	s_CH1TC_ENB		: std_logic;		-- Change 2020/11/11
signal	CH2CLHTb		: std_logic;
signal	s_CH2TC_ENB		: std_logic;		-- Change 2020/11/11
signal	CH3CLHTb		: std_logic;
signal	s_CH3TC_ENB		: std_logic;		-- Change 2020/11/11
signal	CUTDO			: std_logic_vector( 7 downto 0);
signal	CUTREF			: std_logic_vector(11 downto 0);
signal	PRM_CH			: std_logic_vector( 1 downto 0);
signal	MEAS			: std_logic_vector(11 downto 0);
signal	REF				: std_logic_vector(11 downto 0);
signal	AJST			: std_logic_vector( 7 downto 0);
signal	CLHTb			: std_logic;
signal	TC_ENB			: std_logic;
signal	CHANGE			: std_logic_vector( 3 downto 0);
signal	s_NUM			: std_logic_vector( 2 downto 0);
signal	s_NEG			: std_logic;
signal	NUM_WRP			: std_logic;
signal	CH0NUM			: std_logic_vector( 2 downto 0);
signal	CH0NEG			: std_logic;
signal	CH0ENB			: std_logic;
signal	CH0COOL			: std_logic;
signal	CH1NUM			: std_logic_vector( 2 downto 0);
signal	CH1NEG			: std_logic;
signal	CH1ENB			: std_logic;
signal	CH1COOL			: std_logic;
signal	CH2NUM			: std_logic_vector( 2 downto 0);
signal	CH2NEG			: std_logic;
signal	CH2ENB			: std_logic;
signal	CH2COOL			: std_logic;
signal	CH3NUM			: std_logic_vector( 2 downto 0);
signal	CH3NEG			: std_logic;
signal	CH3ENB			: std_logic;
signal	CH3COOL			: std_logic;
signal	PLS				: std_logic_vector( 7 downto 0);
signal	s_TERM			: std_logic;		-- Change 2020/11/11
signal	s_CLON			: std_logic_vector( 3 downto 0);
signal	s_LIMIT			: std_logic_vector( 3 downto 0);
signal	s_IDLING		: std_logic_vector( 3 downto 0);
signal	s_CH0IDLM		: std_logic_vector( 7 downto 0);
signal	s_CH1IDLM		: std_logic_vector( 7 downto 0);
signal	s_CH2IDLM		: std_logic_vector( 7 downto 0);
signal	s_CH3IDLM		: std_logic_vector( 7 downto 0);
signal	IDLMDO			: std_logic_vector( 7 downto 0);
signal	MODDO			: std_logic_vector( 7 downto 0);

signal	s_TEMP_WRP		: std_logic;
signal	s_TEMP_CH		: std_logic_vector( 1 downto 0);
signal	s_COUNT_TEMP	: unsigned( 1 downto 0);


begin

	s_TEMP_WRP	<= '1';
	s_TEMP_CH	<= std_logic_vector(s_COUNT_TEMP);

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_COUNT_TEMP	<= "00";
		elsif (CLK'event and CLK = '1') then
			if (CKEN1k = '1') then
				s_COUNT_TEMP <= s_COUNT_TEMP + 1 ;
				if (s_COUNT_TEMP = "11") then
					s_COUNT_TEMP <= "00";
				end if;
			end if;
		end if;
	end process;

	CLON		<= s_CLON;

	-- Add 2020/11/11
--	CH0TC_ENB	<= s_CH0TC_ENB;
	CH1TC_ENB	<= s_CH1TC_ENB;
	CH2TC_ENB	<= s_CH2TC_ENB;
	CH3TC_ENB	<= s_CH3TC_ENB;
	TERM		<= s_TERM;
	--  2025/02/03
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0TC_ENB	<= s_CH0TC_ENB;
			NUM			<= CH0NUM;
			NEG			<= CH0NEG;
			ENB			<= CH0ENB;
		elsif (CLK'event and CLK = '1') then
			if (s_CH1TC_ENB = '1') and (s_CH0TC_ENB = '0') then
				CH0TC_ENB	<= s_CH1TC_ENB;
				NUM			<= CH1NUM;
				NEG			<= CH1NEG;
				ENB			<= CH1ENB;
			else
				CH0TC_ENB	<= s_CH0TC_ENB;
				NUM			<= CH0NUM;
				NEG			<= CH0NEG;
				ENB			<= CH0ENB;
			end if;
		end if;
	end process;

temp_dec_inst: temp_dec
	port map(
		REGSEL	=> REGSEL,
		LA		=> LA,
		SEL		=> SEL
	);

temp_meas_reg_inst: temp_meas_reg_S127M
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(7 downto 0),
		LRDb		=> LRDb,
		LOAD_L		=> LOAD_L,
		MEASDO		=> MEASDO,
		TEMP0_DATA	=> TEMP0_DATA,
		TEMP1_DATA	=> TEMP1_DATA,
		TEMP2_DATA	=> TEMP2_DATA,
		TEMP3_DATA	=> TEMP3_DATA,
		TEMP_CH		=> s_TEMP_CH,
		TEMP_WRP	=> s_TEMP_WRP,
		CH0MEAS		=> CH0MEAS,
		CH1MEAS		=> CH1MEAS,
		CH2MEAS		=> CH2MEAS,
		CH3MEAS		=> CH3MEAS
	);

temp_ref_reg_inst: temp_ref_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(15 downto 8),
		LRDb		=> LRDb,
		LWEb		=> LWEb,
		LATCH_L		=> LATCH_L,
		LDI			=> LDI,
		REFDO		=> REFDO,
		CH0REF		=> CH0REF,
		CH1REF		=> CH1REF,
		CH2REF		=> CH2REF,
		CH3REF		=> CH3REF
	);

temp_ajst_reg_inst: temp_ajst_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(19 downto 16),
		LRDb		=> LRDb,
		LWEb		=> LWEb,
		LATCH_L		=> LATCH_L,
		LDI			=> LDI,
		AJSTDO		=> AJSTDO,
		CH0AJST		=> CH0AJST,
		CH1AJST		=> CH1AJST,
		CH2AJST		=> CH2AJST,
		CH3AJST		=> CH3AJST
	);

temp_ctst_reg_inst: temp_ctst_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(23 downto 20),
		LRDb		=> LRDb,
		LWEb		=> LWEb,
		LATCH_L		=> LATCH_L,
		LOAD_L		=> LOAD_L,
		LDI			=> LDI,
		CTSTDO		=> CTSTDO,
		CUT			=> CUT,
		LIMIT		=> s_LIMIT,
		IDLING		=> s_IDLING,
		CH0CLHTb	=> CH0CLHTb,
		CH0TC_ENB	=> s_CH0TC_ENB,	-- Change 2020/11/11
		CH1CLHTb	=> CH1CLHTb,
		CH1TC_ENB	=> s_CH1TC_ENB,	-- Change 2020/11/11
		CH2CLHTb	=> CH2CLHTb,
		CH2TC_ENB	=> s_CH2TC_ENB,	-- Change 2020/11/11
		CH3CLHTb	=> CH3CLHTb,
		CH3TC_ENB	=> s_CH3TC_ENB	-- Change 2020/11/11
	);

temp_cut_ref_reg_inst: temp_cut_ref_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(25 downto 24),
		LRDb		=> LRDb,
		LWEb		=> '1',
		LATCH_L		=> LATCH_L,
		LDI			=> LDI,
		CUTDO		=> CUTDO,
		CUTREF		=> CUTREF
	);

temp_idlm_reg_inst: temp_idlm_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(31 downto 28),
		LRDb		=> LRDb,
		LWEb		=> LWEb,
		LATCH_L		=> LATCH_L,
		LDI			=> LDI,
		IDLMDO		=> IDLMDO,
		CH0IDLM		=> s_CH0IDLM,
		CH1IDLM		=> s_CH1IDLM,
		CH2IDLM		=> s_CH2IDLM,
		CH3IDLM		=> s_CH3IDLM
	);

-- or8bit_7to1
	REGDO <= MEASDO or REFDO or AJSTDO or CTSTDO or CUTDO or IDLMDO or MODDO;

temp_prm_sel_inst: temp_prm_sel
	port map(
		CH0MEAS		=> CH0MEAS,
		CH0REF		=> CH0REF,
		CH0AJST		=> CH0AJST,
		CH0CLHTb	=> CH0CLHTb,
		CH0TC_ENB	=> s_CH0TC_ENB,	-- Change 2020/11/11
		CH1MEAS		=> CH1MEAS,
		CH1REF		=> CH1REF,
		CH1AJST		=> CH1AJST,
		CH1CLHTb	=> CH1CLHTb,
		CH1TC_ENB	=> s_CH1TC_ENB,	-- Change 2020/11/11
		CH2MEAS		=> CH2MEAS,
		CH2REF		=> CH2REF,
		CH2AJST		=> CH2AJST,
		CH2CLHTb	=> CH2CLHTb,
		CH2TC_ENB	=> s_CH2TC_ENB,	-- Change 2020/11/11
		CH3MEAS		=> CH3MEAS,
		CH3REF		=> CH3REF,
		CH3AJST		=> CH3AJST,
		CH3CLHTb	=> CH3CLHTb,
		CH3TC_ENB	=> s_CH3TC_ENB,	-- Change 2020/11/11
		PRM_CH		=> PRM_CH,
		MEAS		=> MEAS,
		REF			=> REF,
		AJST		=> AJST,
		CLHTb		=> CLHTb,
		TC_ENB		=> TC_ENB
	);

temp_edge_dtct_inst: temp_edge_dtct
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		CH0CLHTb	=> CH0CLHTb,
		CH1CLHTb	=> CH1CLHTb,
		CH2CLHTb	=> CH2CLHTb,
		CH3CLHTb	=> CH3CLHTb,
		CHANGE		=> CHANGE
	);

temp_rng_chk_inst: temp_rng_chk
	port map(
		CH0MEAS		=> CH0MEAS,
		CH1MEAS		=> CH1MEAS,
		CH2MEAS		=> CH2MEAS,
		CH3MEAS		=> CH3MEAS,
		CUTREF		=> CUTREF,
		CUT			=> CUT
	);

temp_ctrl_inst: temp_ctrl
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		MEAS		=> MEAS,
		REF			=> REF,
		AJST		=> AJST,
		CLHTb		=> CLHTb,
		NUM			=> s_NUM,
		NEG			=> s_NEG,
		NUM_WRP		=> NUM_WRP,
		PRM_CH		=> PRM_CH,
		TEMP_WRP	=> s_TEMP_WRP,
		TEMP_CH		=> s_TEMP_CH
	);

temp_plsnum_reg_inst: temp_plsnum_reg
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		SEL			=> SEL(29 downto 26),
		LRDb		=> LRDb,
		LOAD_L		=> LOAD_L,
		MODDO		=> MODDO,
		-------------------------------------
		NUM			=> s_NUM,
		NEG			=> s_NEG,
		CLHTb		=> CLHTb,
		TC_ENB		=> TC_ENB,
		NUM_WRP		=> NUM_WRP,
		PRM_CH		=> PRM_CH,
		CHANGE		=> CHANGE,
		CUT			=> CUT,
		CH0NUM		=> CH0NUM,
		CH0NEG		=> CH0NEG,
		CH0ENB		=> CH0ENB,
		CH0COOL		=> CH0COOL,
		CH1NUM		=> CH1NUM,
		CH1NEG		=> CH1NEG,
		CH1ENB		=> CH1ENB,
		CH1COOL		=> CH1COOL,
		CH2NUM		=> CH2NUM,
		CH2NEG		=> CH2NEG,
		CH2ENB		=> CH2ENB,
		CH2COOL		=> CH2COOL,
		CH3NUM		=> CH3NUM,
		CH3NEG		=> CH3NEG,
		CH3ENB		=> CH3ENB,
		CH3COOL		=> CH3COOL
	);

temp_plsmod_inst0: temp_plsmod
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		PLS			=> PLS,
		NUM			=> CH0NUM,
		NEG			=> CH0NEG,
		TERM		=> s_TERM,		-- Change 2020/11/11
		DLY			=> cst00,
		COOL		=> CH0COOL,
		ENB			=> CH0ENB,
		LIMIT		=> s_LIMIT(0),
		IDLING		=> s_IDLING(0),
		IDLM		=> s_CH0IDLM,
		CLON		=> s_CLON(0),
		CLP			=> CLP(0),
		HTON		=> HTON(0),
		HTP			=> HTP(0),
		CLPORHTPhf	=> CLPORHTPhf(0),
		CLPORHTP	=> CLPORHTP(0)
	);

temp_plsmod_inst1: temp_plsmod
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		PLS			=> PLS,
		NUM			=> CH1NUM,
		NEG			=> CH1NEG,
		TERM		=> s_TERM,		-- Change 2020/11/11
		DLY			=> cst01,
		COOL		=> CH1COOL,
		ENB			=> CH1ENB,
		LIMIT		=> s_LIMIT(1),
		IDLING		=> s_IDLING(1),
		IDLM		=> s_CH1IDLM,
		CLON		=> s_CLON(1),
		CLP			=> CLP(1),
		HTON		=> HTON(1),
		HTP			=> HTP(1),
		CLPORHTPhf	=> CLPORHTPhf(1),
		CLPORHTP	=> CLPORHTP(1)
	);

temp_plsmod_inst2: temp_plsmod
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		PLS			=> PLS,
		NUM			=> CH2NUM,
		NEG			=> CH2NEG,
		TERM		=> s_TERM,		-- Change 2020/11/11
		DLY			=> cst10,
		COOL		=> CH2COOL,
		ENB			=> CH2ENB,
		LIMIT		=> s_LIMIT(2),
		IDLING		=> s_IDLING(2),
		IDLM		=> s_CH2IDLM,
		CLON		=> s_CLON(2),
		CLP			=> CLP(2),
		HTON		=> HTON(2),
		HTP			=> HTP(2),
		CLPORHTPhf	=> CLPORHTPhf(2),
		CLPORHTP	=> CLPORHTP(2)
	);

temp_plsmod_inst3: temp_plsmod
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		PLS			=> PLS,
		NUM			=> CH3NUM,
		NEG			=> CH3NEG,
		TERM		=> s_TERM,		-- Change 2020/11/11
		DLY			=> cst11,
		COOL		=> CH3COOL,
		ENB			=> CH3ENB,
		LIMIT		=> s_LIMIT(3),
		IDLING		=> s_IDLING(3),
		IDLM		=> s_CH3IDLM,
		CLON		=> s_CLON(3),
		CLP			=> CLP(3),
		HTON		=> HTON(3),
		HTP			=> HTP(3),
		CLPORHTPhf	=> CLPORHTPhf(3),
		CLPORHTP	=> CLPORHTP(3)
	);

temp_plsgen_inst: temp_plsgen
	port map(
		CLK			=> CLK,
		LRSTb		=> LRSTb,
		PLS			=> PLS,
		TERM		=> s_TERM		-- Change 2020/11/11
	);

end RTL;
