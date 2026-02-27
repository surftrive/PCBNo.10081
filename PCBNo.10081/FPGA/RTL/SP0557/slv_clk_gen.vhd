-------------------------------------------------
--File Name : slv_clk_gen.vhd
--Project	: S124M(S3IO)
--Date		: 2024.10.04
--Ver		: 00_00
--Doc		: New Release
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity slv_clk_gen is
	port(
		RSTb			: in	std_logic;		-- power on reset
		CLK_BASE_20M	: in	std_logic;		-- Clock 20MHZ

		CLK500k			: out	std_logic;		-- Clock 500kHz
		CLK_EN_1k		: out	std_logic;		-- Clock ENABLE 1k
		CLK_EN_500k		: out	std_logic;		-- Clock ENABLE 500k
		CLK_EN_5M		: out	std_logic		-- Clock ENABLE 5M
	);
end slv_clk_gen;

architecture RTL of slv_clk_gen is

---------------constant-----------------------------------------------------------------------------
constant c_CNT200ns	: std_logic_vector(1 downto 0) := "11";		-- 20 MHz / 5 MHz - 1
constant c_CNT1us	: std_logic_vector(2 downto 0) := "100";		-- 5 MHz / 1 MHz - 1
constant c_CNT2us	: std_logic_vector(3 downto 0) := "1001";		-- 5 MHz / 500 kHz - 1
constant c_CNT100us	: std_logic_vector(5 downto 0) := "110001";	-- 500 kHz / 10 kHz - 1
constant c_CNT1ms	: std_logic_vector(3 downto 0) := "1001";		-- 10 kHz / 1 kHz - 1

---------------signal-------------------------------------------------------------------------------
signal s_CNT5M		: std_logic_vector(1 downto 0);
signal s_CNT500k	: std_logic_vector(3 downto 0);
signal s_CNT10k		: std_logic_vector(5 downto 0);
signal s_CNT1k		: std_logic_vector(3 downto 0);

signal s_CKEN5M		: std_logic;
signal s_CKEN500k	: std_logic;
signal s_CKEN10k	: std_logic;
signal s_CKEN1k		: std_logic;
signal s_CLK500k	: std_logic;

begin
	CLK500k			<= s_CLK500k;
	CLK_EN_1k		<= s_CKEN1k;
	CLK_EN_500k		<= s_CKEN500k;
	CLK_EN_5M		<= s_CKEN5M;
	
--CKEN5M
	process (CLK_BASE_20M, RSTb)
	begin
		if (RSTb = '0') then
			s_CNT5M <= (others => '0');
			s_CKEN5M <= '0';
		elsif rising_edge(CLK_BASE_20M) then
			s_CNT5M <= s_CNT5M + 1;
			if (s_CNT5M = c_CNT200ns) then
				s_CKEN5M <= '1';
			else
				s_CKEN5M <= '0';
			end if;
		end if;
	end process;

--CLK500k
--CKEN500k
	process (CLK_BASE_20M, RSTb)
	begin
		if (RSTb = '0') then
			s_CNT500k 	<= (others => '0');
			s_CKEN500k	<= '0';
			s_CLK500k	<= '0';
		elsif rising_edge(CLK_BASE_20M) then
			if (s_CKEN5M = '1') then
				s_CNT500k <= s_CNT500k + 1;
				if (s_CNT500k =  c_CNT1us ) then
					s_CLK500k <= '1';
				elsif (s_CNT500k =  c_CNT2us ) then
					s_CNT500k <= (others => '0');
					s_CLK500k <= '0';
					s_CKEN500k <= '1';
				else
					s_CKEN500k <= '0';
				end if;
			else
				s_CKEN500k <= '0';
			end if;
		end if;
	end process;

--CKEN10k
	process (CLK_BASE_20M, RSTb)
	begin
		if (RSTb = '0') then
			s_CNT10k 	<= (others => '0');
			s_CKEN10k	<= '0';
		elsif rising_edge(CLK_BASE_20M) then
			if (s_CKEN500k = '1') then
				s_CNT10k <= s_CNT10k + 1;
				if (s_CNT10k =  c_CNT100us ) then
					s_CNT10k <= (others => '0');
					s_CKEN10k <= '1';
				else
					s_CKEN10k <= '0';
				end if;
			else
				s_CKEN10k <= '0';
			end if;
		end if;
	end process;

--CKEN1k
	process (CLK_BASE_20M, RSTb)
	begin
		if (RSTb = '0') then
			s_CNT1k 	<= (others => '0');
			s_CKEN1k	<= '0';
		elsif rising_edge(CLK_BASE_20M) then
			if (s_CKEN10k = '1') then
				s_CNT1k <= s_CNT1k + 1;
				if (s_CNT1k =  c_CNT1ms ) then
					s_CNT1k <= (others => '0');
					s_CKEN1k <= '1';
				else
					s_CKEN1k <= '0';
				end if;
			else
				s_CKEN1k <= '0';
			end if;
		end if;
	end process;
	
end RTL;