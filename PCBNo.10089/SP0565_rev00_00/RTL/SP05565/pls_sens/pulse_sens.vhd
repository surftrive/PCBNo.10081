--************************************************
-- Project	: Alpha-NEXT
-- Doc		: Pulse out & synchronized sensor input to pulse out
----------------------------------------
-- Tab size = 8
----------------------------------------
-- Histry --
-- Ver		Date		Author/Desc.
-- 0.00		2005/08/30	OKUBO Koichi
--				New Release
-- 0.10		2005/09/22	OKUBO Koichi
--				add uSTEP control // Circuit of dividing frequency
-- 0.11		2005/09/26	OKUBO Koichi
--				Change DCLEDb LOGIC
-- 0.20		2005/10/30	M.Tanaka
--				Remove slv_clk_gen and Moter control function.
--				Specialized in Separated Pulse-emit Sensor
-- 0.21		2009/07/28	M.Tanaka
--				change ring_counter, port name and sensor latch description
-- 0.21		2009/09/08	M.Tanaka
--				change ring_counter, port name and sensor latch description
--************************************************

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

	entity pulse_sens is
	generic(
		gLEN	: integer := 5					-- num of LED (>=2)
	);
	port(
		nRST	: in	std_logic;				-- Local Reset			(active Low)
		CLK	: in	std_logic;				-- Clock
		CKEN	: in	std_logic;				-- Clock Enable 100kHz		(Active High 1clk)
		LED_O	: out	std_logic_vector(gLEN-1 downto 0);	-- IR-LED Pulse output		(Active Low)　パルス発光センサの発光制御信号
		LED_EN	: in	std_logic_vector(gLEN-1 downto 0);	-- Pulse Enable			(Active High)　Node4に書き込まれているパルス発光センサの発光イネーブル信号が入力される。
		SNS_I	: in	std_logic_vector(gLEN-1 downto 0);	-- Sensor Signal In		(Active High)　パルスセンサの入力信号が接続される。
		SNS_LT	: out	std_logic_vector(gLEN-1 downto 0);	-- Sensor Signal out(Latched)	(Active High)
		TEST	: out	std_logic_vector(gLEN-1 downto 0)	-- for debug
	);
	end pulse_sens;

architecture RTL of pulse_sens is	--******************

	signal	s_PD_A		: std_logic_vector(LED_O'range);	-- sensor filter 1
	signal	s_PD_B		: std_logic_vector(LED_O'range);	-- sensor filter 2
	signal	s_PD_C		: std_logic_vector(LED_O'range);	-- sensor filter 3
	signal	s_PD_D		: std_logic_vector(LED_O'range);	-- sensor filter 4
	signal	s_PD_S		: std_logic_vector(LED_O'range);	-- filtered sensor input

	signal	s_SNS		: std_logic_vector(LED_O'range);
	signal	s_SNS_LT	: std_logic_vector(LED_O'range);	-- Latched "s_SNS"

	signal	s_LED		: std_logic_vector(LED_O'range);
	signal	s_LED_C		: std_logic_vector(LED_O'range);	-- LED control

	component ring_counter
	generic(
		gLEN	: integer				-- num of LED (>=2)
	);
	port(
		nRST	: in	std_logic;			-- Local Reset	(active Low)
		CLK	: in	std_logic;			-- Clock
		CKEN	: in	std_logic;			-- Clock Enable	(active High ; 1 pulse)
		LED	: out	std_logic_vector(gLEN-1 downto 0)	-- LED Pulse
	);
	end component;

begin	--**************************************************

	TEST	<= not s_PD_S;		-- Test Pin (LED)

	-- LED -----------------------------------
	ring_counter_inst : ring_counter
	generic map (
		gLEN	=> gLEN
	)
	port map (
		CLK	=> CLK,
		nRST	=> nRST,
		CKEN	=> CKEN,
		LED	=> s_LED
	);

	LED_O	<= s_LED_C ;
	s_LED_C	<= s_LED and LED_EN;--ring_counterでつくられたs_LEDとNode4に書き込まれているパルス発光センサの発光イネーブル信号のand信号でLEDを制御

	-- Sensor In -----------------------------
	-- Noise Filter (High 4 clock)
	s_PD_S	<= s_PD_B and s_PD_C and s_PD_D;--4clock分とったセンサの値をand信号とする。
	process (CLK, nRST)
	begin
		if (nRST='0') then
			s_PD_A <= (others=>'0');
			s_PD_B <= (others=>'0');
			s_PD_C <= (others=>'0');
			s_PD_D <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			s_PD_A <= SNS_I;
			s_PD_B <= s_PD_A;
			s_PD_C <= s_PD_B;
			s_PD_D <= s_PD_C;--4clock分同じ信号をとって、信号品質を高める。
		end if;
	end process;

	-- SNS Latch -----------------------------
	SNS_LT	<= s_SNS_LT;
	process (CLK, nRST)
	begin
		if (nRST='0') then
			s_SNS_LT	<= (others=>'0');
		elsif (CLK'event and CLK='1') then
			for i in LED_O'range loop
				if (LED_EN(i)='0') then
					s_SNS_LT(i)	<= '0';
				elsif (s_LED(i)='1' and CKEN='1') then--センサEnableがアサートされ、パルスセンサ発光がONの時、100kHzのクロックで12個のセンサの値を1クロックごとに反映
					s_SNS_LT(i)	<= s_PD_S(i);
				end if;
			end loop;
		end if;
	end process;

end RTL;
