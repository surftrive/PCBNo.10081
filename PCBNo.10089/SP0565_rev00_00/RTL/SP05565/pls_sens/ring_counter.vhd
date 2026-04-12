--************************************************
-- Project	: S79M
-- Doc		: generate pulse, Term=(cTERM+1), duty=1/(cTERM+1)
----------------------------------------
-- Tab size = 8
----------------------------------------
-- Histry --
-- Ver		Date		Author/Desc.
-- 0.00		2005/08/30	OKUBO Koichi
--				New Release
-- 0.00		2009/07/28	M.Tanaka
--				ring counter control is changed
--************************************************

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

	entity ring_counter is
	generic(
		gLEN	: integer := 5				-- num of LED (>=2) ッ�ォルト値であり、上位�componentで挮�した値が優先される�D0_TOPで12が指定されてあ�。SP0508は
	);
	port(
		nRST	: in	std_logic;			-- Local Reset	(active Low)
		CLK	: in	std_logic;			-- Clock
		CKEN	: in	std_logic;			-- Clock Enable	(active High ; 1 pulse)
		LED	: out	std_logic_vector(gLEN-1 downto 0)	-- LED Pulse
	);
	end ring_counter;

architecture RTL of ring_counter is	--******************

	signal	CNT	: std_logic_vector(8 downto 0); -- counter
	constant cTERM	: std_logic_vector(CNT'range) := "111011000";-- 472　1カウントかかる�720usにカウン�となる�
	constant cZERO	: std_logic_vector(CNT'range) := (others=>'0');	-- 0

	signal	s_reg	: std_logic_vector(gLEN downto 0);				-- ring counter
	constant c_INI	: std_logic_vector(s_reg'range) := (0=>'1', others=>'0');	-- bit0: wait, bit1-: pulse out

begin	--**************************************************

	process (CLK, nRST)
	begin
		if (nRST='0') then
			CNT	<= cTERM;
			s_reg	<= c_INI;
		elsif (CLK'event and CLK='1') then
			if (CKEN='1') then
				if (CNT=cZERO) then
					CNT	<= cTERM;
				else
					CNT	<= CNT - '1';--1カウントかかる�720usにカウン�となる�
				end if;
				if (CNT=cZERO or s_reg/=c_INI) then
					s_reg	<= s_reg(gLEN-1 downto 0) & s_reg(gLEN);--カウントが0になったタイミングで00001�0010�0100�1000�0000�0001
				end if;
			end if;
		end if;
	end process;

	LED <= s_reg(gLEN downto 1);

end RTL;
