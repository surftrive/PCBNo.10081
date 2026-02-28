----------------------------------------------------------------------------------------------------
--File Name	: EFUSE_CTRL.vhd
--Project	: S127M(S3IO)
--Date		: 2026.01.21
--Ver		: 00_00
--Doc		: New Release
--			: S127M PCB No.10081
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

------------------------entity----------------------------------------------------------------------
entity EFUSE_CTRL is
	port(
		CLK					: in	std_logic;	-- Clock 20MHZ
		LRSTb				: in	std_logic;	-- Local Reset (active Low)

		MODE_COM			: in	std_logic_vector( 3 downto 0);
		MODE_OUT			: out	std_logic_vector( 3 downto 0);

		PW_SV_EN			: out	std_logic;
		PW_PUMP_EN			: out	std_logic;
		PW_PLS_EN			: out	std_logic;
		PW_LMT_EN			: out	std_logic;
		PW_ENC_EN			: out	std_logic;
		PW_SNS_EN			: out	std_logic;
		PW_SNSLED_EN		: out	std_logic;
		PW_PLSSNS_EN		: out	std_logic;
		PW_LEDSH_EN			: out	std_logic;
		PW_LEDLT_EN			: out	std_logic
	);
end EFUSE_CTRL;
---------------architecture-------------------------------------------------------------------------
architecture RTL of EFUSE_CTRL is
-------------- constant ----------------------------------------------------------------------------
constant	c_NORM_mode			: std_logic_vector( 3 downto 0)		:= X"0";
constant	c_OFF_mode			: std_logic_vector( 3 downto 0)		:= X"1";
constant	c_SLP_mode			: std_logic_vector( 3 downto 0)		:= X"2";
constant	c_COOL_mode			: std_logic_vector( 3 downto 0)		:= X"3";

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_PW_SV_EN			: std_logic;
signal		s_PW_PUMP_EN		: std_logic;
signal		s_PW_PLS_EN			: std_logic;
signal		s_PW_LMT_EN			: std_logic;
signal		s_PW_ENC_EN			: std_logic;
signal		s_PW_SNS_EN			: std_logic;
signal		s_PW_SNSLED_EN		: std_logic;
signal		s_PW_PLSSNS_EN		: std_logic;
signal		s_PW_LEDSH_EN		: std_logic;
signal		s_PW_LEDLT_EN		: std_logic;
signal		s_MODE				: std_logic_vector( 3 downto 0);

-- Synthesis attributes: prevent merging of equivalent power enable registers (each drives separate HW)
attribute syn_preserve : boolean;
attribute syn_preserve of s_PW_SV_EN     : signal is true;
attribute syn_preserve of s_PW_PUMP_EN   : signal is true;
attribute syn_preserve of s_PW_PLS_EN    : signal is true;
attribute syn_preserve of s_PW_LMT_EN    : signal is true;
attribute syn_preserve of s_PW_ENC_EN    : signal is true;
attribute syn_preserve of s_PW_SNS_EN    : signal is true;
attribute syn_preserve of s_PW_SNSLED_EN : signal is true;
attribute syn_preserve of s_PW_PLSSNS_EN : signal is true;
attribute syn_preserve of s_PW_LEDSH_EN  : signal is true;
attribute syn_preserve of s_PW_LEDLT_EN  : signal is true;
-- Prevent pruning and constant optimization of MODE bits (bus width matches interface specification)
attribute syn_keep : boolean;
attribute syn_keep of s_MODE : signal is true;
attribute syn_preserve of s_MODE : signal is true;

---------------component----------------------------------------------------------------------------

-------------------- begin -------------------------------------------------------------------------
begin

	MODE_OUT			<= s_MODE;
	PW_SV_EN			<= s_PW_SV_EN;
	PW_PUMP_EN			<= s_PW_PUMP_EN;
	PW_PLS_EN			<= s_PW_PLS_EN;
	PW_LMT_EN			<= s_PW_LMT_EN;
	PW_ENC_EN			<= s_PW_ENC_EN;
	PW_SNS_EN			<= s_PW_SNS_EN;
	PW_SNSLED_EN		<= s_PW_SNSLED_EN;
	PW_PLSSNS_EN		<= s_PW_PLSSNS_EN;
	PW_LEDSH_EN			<= s_PW_LEDSH_EN;
	PW_LEDLT_EN			<= s_PW_LEDLT_EN;

	process(CLK, LRSTb)
	begin
		if (LRSTb = '0') then
			s_PW_SV_EN		<= '0';
			s_PW_PUMP_EN	<= '0';
			s_PW_PLS_EN		<= '0';
			s_PW_LMT_EN		<= '0';
			s_PW_ENC_EN		<= '0';
			s_PW_SNS_EN		<= '0';
			s_PW_SNSLED_EN	<= '0';
			s_PW_PLSSNS_EN	<= '0';
			s_PW_LEDSH_EN	<= '0';
			s_PW_LEDLT_EN	<= '0';
			s_MODE			<= (others => '0');
		elsif rising_edge(CLK) then
			case MODE_COM is
				when c_NORM_mode =>
					s_PW_SV_EN		<= '1';
					s_PW_PUMP_EN	<= '1';
					s_PW_PLS_EN		<= '1';
					s_PW_LMT_EN		<= '1';
					s_PW_ENC_EN		<= '1';
					s_PW_SNS_EN		<= '1';
					s_PW_SNSLED_EN	<= '1';
					s_PW_PLSSNS_EN	<= '1';
					s_PW_LEDSH_EN	<= '1';
					s_PW_LEDLT_EN	<= '1';
					s_MODE			<= MODE_COM;
				when c_OFF_mode =>
					s_PW_SV_EN		<= '1';
					s_PW_PUMP_EN	<= '1';
					s_PW_PLS_EN		<= '1';
					s_PW_LMT_EN		<= '0';
					s_PW_ENC_EN		<= '1';
					s_PW_SNS_EN		<= '0';
					s_PW_SNSLED_EN	<= '0';
					s_PW_PLSSNS_EN	<= '1';
					s_PW_LEDSH_EN	<= '0';
					s_PW_LEDLT_EN	<= '0';
					s_MODE			<= MODE_COM;
				when others =>
					s_PW_SV_EN		<= s_PW_SV_EN;
					s_PW_PUMP_EN	<= s_PW_PUMP_EN;
					s_PW_PLS_EN		<= s_PW_PLS_EN;
					s_PW_LMT_EN		<= s_PW_LMT_EN;
					s_PW_ENC_EN		<= s_PW_ENC_EN;
					s_PW_SNS_EN		<= s_PW_SNS_EN;
					s_PW_SNSLED_EN	<= s_PW_SNSLED_EN;
					s_PW_PLSSNS_EN	<= s_PW_PLSSNS_EN;
					s_PW_LEDSH_EN	<= s_PW_LEDSH_EN;
					s_PW_LEDLT_EN	<= s_PW_LEDLT_EN;
					s_MODE			<= s_MODE;
			end case;
		end if;
	end process;

end RTL;
