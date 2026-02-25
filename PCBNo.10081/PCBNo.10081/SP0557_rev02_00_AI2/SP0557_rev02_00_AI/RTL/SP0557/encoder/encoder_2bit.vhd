--************************************************
-- Project	: CA-NEXT Prototype(B)
-- Doc		: 2bit glaycode decoder & 16bit counter
----------------------------------------
-- Tab size = 8
----------------------------------------
-- Histry --
-- Ver		Date		Author/Desc.
-- 0.01		2004/10/04	Kazutoshi Tokunaga
--				New Release
-- 0.02		2005/08/25	Jun Iagaki
--				Debug
-- 1.00		2005/08/26	Jun Iagaki
--				Resolution Up
-- 1.10		2009/07/28	M.Tanaka
--				fix description clearly.
--				73 LE -> 54 LE @Cyclone
-- 1.20   2020/02/07 Y.Aoki
--        add countup and countdown port
--************************************************

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

	entity encoder_2bit is
	port(
		CLK		: in std_logic;		-- Clock 20MHz
		LRSTb		: in std_logic;		-- Local Reset	(active Low)
		ENCPHASE_A	: in std_logic;		-- Encoder Phase A
		ENCPHASE_B	: in std_logic;		-- Encoder Phase B
		ENC_EN		: in std_logic;		-- Enable
		ENCDATA		: out std_logic_vector(15 downto 0);	-- Encoder Count DATA
		CNT_UP		: out std_logic;		-- output for encoder limit stop
		CNT_DWN		: out std_logic		-- output for encoder limit stop
	);
	end encoder_2bit;

architecture RTL of encoder_2bit is	--******************

	signal	encdat		: std_logic_vector(15 downto 0);	-- 16bit counter

	signal	s_ph_a		: std_logic;	-- filterd ph A
	signal	s_ph_a_p	: std_logic;	-- prev filterd ph A
	signal	s_ph_a_r	: std_logic;	-- rise edge of filterd ph A
	signal	s_ph_a_f	: std_logic;	-- fall edge of filterd ph A

	signal	s_ph_b		: std_logic;	-- filterd ph B
	signal	s_ph_b_p	: std_logic;	-- prev filterd ph B
	signal	s_ph_b_r	: std_logic;	-- rise edge of filterd ph B
	signal	s_ph_b_f	: std_logic;	-- fall edge of filterd ph B

	signal	s_ph_a_flt	: std_logic_vector(8 downto 0);	-- filter for ph A
	signal	s_ph_b_flt	: std_logic_vector(8 downto 0);	-- filter for ph B
	constant c_ADfull	: std_logic_vector(8 downto 0):= "111111111";	-- 511*50ns = 25.5usec
	constant c_ADzero	: std_logic_vector(8 downto 0):= "000000000";

	signal	plus_cnd	: std_logic;	-- count up condition;		[ph_b,ph_a] move 00->01->11->10
	signal	minus_cnd	: std_logic;	-- count down condition;	[ph_b,ph_a] move 00->10->11->01

begin	--**************************************************

	ENCDATA	<= encdat;
	CNT_UP  <= plus_cnd;  -- add 2020/02/07 ver1.02
	CNT_DWN <= minus_cnd; -- add 2020/02/07 ver1.02

	-- Noise Filter A
	process (CLK, LRSTb, ENCPHASE_A)
	begin
		if (LRSTb='0') then
				s_ph_a_flt	<= c_ADzero;
				s_ph_a		<= ENCPHASE_A;
				s_ph_a_p	<= ENCPHASE_A;
		elsif (CLK'event and CLK='1') then
			if s_ph_a=ENCPHASE_A then
				s_ph_a_flt	<= c_ADzero;
				s_ph_a		<= s_ph_a;
			elsif s_ph_a_flt<c_ADfull then
				s_ph_a_flt	<= s_ph_a_flt + '1';
				s_ph_a		<= s_ph_a;
			else
				s_ph_a_flt	<= s_ph_a_flt;
				s_ph_a		<= ENCPHASE_A;
			end if;
				s_ph_a_p	<= s_ph_a;
		end if;
	end process;

	-- Edge Detect A
	process (CLK, LRSTb)
	begin
		if (LRSTb='0') then
			s_ph_a_r	<= '0';
			s_ph_a_f	<= '0';
		elsif (CLK'event and CLK='1') then
			s_ph_a_r	<= s_ph_a and (not s_ph_a_p);
			s_ph_a_f	<= (not s_ph_a) and s_ph_a_p;
		end if;
	end process;

	-- Noise Filter B
	process (CLK, LRSTb, ENCPHASE_B)
	begin
		if (LRSTb='0') then
				s_ph_b_flt	<= c_ADzero;
				s_ph_b		<= ENCPHASE_B;
				s_ph_b_p	<= ENCPHASE_B;
		elsif (CLK'event and CLK='1') then
			if s_ph_b=ENCPHASE_B then
				s_ph_b_flt	<= c_ADzero;
				s_ph_b		<= s_ph_b;
			elsif s_ph_b_flt<c_ADfull then
				s_ph_b_flt	<= s_ph_b_flt + '1';
				s_ph_b		<= s_ph_b;
			else
				s_ph_b_flt	<= s_ph_b_flt;
				s_ph_b		<= ENCPHASE_B;
			end if;
				s_ph_b_p	<= s_ph_b;
		end if;
	end process;

	-- Edge Detect B
	process (CLK, LRSTb)
	begin
		if (LRSTb='0') then
			s_ph_b_r	<= '0';
			s_ph_b_f	<= '0';
		elsif (CLK'event and CLK='1') then
			s_ph_b_r	<= s_ph_b and (not s_ph_b_p);
			s_ph_b_f	<= (not s_ph_b) and s_ph_b_p;
		end if;
	end process;

	-- Decode --------------------------------
	plus_cnd	<=	(s_ph_a_r and not s_ph_b) or
				(s_ph_a_f and s_ph_b) or
				(s_ph_b_r and s_ph_a) or
				(s_ph_b_f and not s_ph_a);

	minus_cnd	<=	(s_ph_a_r and s_ph_b) or
				(s_ph_a_f and not s_ph_b) or
				(s_ph_b_r and not s_ph_a) or
				(s_ph_b_f and s_ph_a);

	-- 16bit counter -------------------------
	process (CLK, LRSTb)
	begin
		if (LRSTb='0') then
				encdat	<= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (ENC_EN='0') then
				encdat	<= (others=>'0');
			elsif (plus_cnd='1') then
				encdat	<= encdat + '1';
			elsif (minus_cnd='1') then
				encdat	<= encdat - '1';
			end if;
		end if;
	end process;

end RTL;
