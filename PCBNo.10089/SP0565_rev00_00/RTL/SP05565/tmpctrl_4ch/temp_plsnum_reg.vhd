-------------------------------------------------
--File Name : temp_plsnum_reg.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2015/12/10
--Ver		: 1.00
--Doc		: ADD REG '1Ah''1Bh''1Ch''1Dh'
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_plsnum_reg is
	port ( CLK :in std_logic;
		LRSTb :in std_logic;
		SEL     : in std_logic_vector(3 downto 0);
		LRDb    : in std_logic;
		LOAD_L  : in std_logic;
		MODDO   : out std_logic_vector(7 downto 0);
		NUM :in std_logic_vector(2 downto 0);
		NEG :in std_logic;
		CLHTb :in std_logic;
		TC_ENB :in std_logic;
		NUM_WRP :in std_logic;
		PRM_CH :in std_logic_vector(1 downto 0);
		CHANGE :in std_logic_vector(3 downto 0);
		CUT :in std_logic_vector(3 downto 0);
		CH0NUM :out std_logic_vector(2 downto 0);
		CH0NEG :out std_logic;
		CH0ENB :out std_logic;
		CH0COOL :out std_logic;
		CH1NUM :out std_logic_vector(2 downto 0);
		CH1NEG :out std_logic;
		CH1ENB :out std_logic;
		CH1COOL :out std_logic;
		CH2NUM :out std_logic_vector(2 downto 0);
		CH2NEG :out std_logic;
		CH2ENB :out std_logic;
		CH2COOL :out std_logic;
		CH3NUM :out std_logic_vector(2 downto 0);
		CH3NEG :out std_logic;
		CH3ENB :out std_logic;
		CH3COOL :out std_logic);
end temp_plsnum_reg;

architecture RTL of temp_plsnum_reg is

	signal WRP : std_logic_vector(3 downto 0);
	signal comp :std_logic_vector(2 downto 0);
	signal inh : std_logic_vector(3 downto 0);
	signal s_CH0NUMDO :std_logic_vector(7 downto 0);
	signal s_CH1NUMDO :std_logic_vector(7 downto 0);
	signal s_CH2NUMDO :std_logic_vector(7 downto 0);
	signal s_CH3NUMDO :std_logic_vector(7 downto 0);
	signal RDSEL :std_logic_vector(3 downto 0);
	signal s_CH0NUM :std_logic_vector(2 downto 0);
	signal s_CH1NUM :std_logic_vector(2 downto 0);
	signal s_CH2NUM :std_logic_vector(2 downto 0);
	signal s_CH3NUM :std_logic_vector(2 downto 0);

begin

	RDSEL <= SEL when LRDb = '0' else (others => '0');
	s_CH0NUMDO <= "00000" & s_CH0NUM when RDSEL(0) = '1' else (others =>'0');
	s_CH1NUMDO <= "00000" & s_CH1NUM when RDSEL(1) = '1' else (others =>'0');
	s_CH2NUMDO <= "00000" & s_CH2NUM when RDSEL(2) = '1' else (others =>'0');
	s_CH3NUMDO <= "00000" & s_CH3NUM when RDSEL(3) = '1' else (others =>'0');

	MODDO <= s_CH0NUMDO or s_CH1NUMDO or s_CH2NUMDO or s_CH3NUMDO;

	CH0NUM <= s_CH0NUM;
	CH1NUM <= s_CH1NUM;
	CH2NUM <= s_CH2NUM;
	CH3NUM <= s_CH3NUM;
	 
	comp <= NUM_WRP & PRM_CH;

	process (comp) begin
		case comp is
			when "100"	=> WRP <= "0001";
			when "101"	=> WRP <= "0010";
			when "110"	=> WRP <= "0100";
			when "111"	=> WRP <= "1000";
			when others => WRP <= "0000";
		end case;
	end process;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_CH0NUM <= (others => '0');
			CH0NEG <= '1';
			CH0COOL <= '0';
			s_CH1NUM <= (others => '0');
			CH1NEG <= '1';
			CH1COOL <= '0';
			s_CH2NUM <= (others => '0');
			CH2NEG <= '1';
			CH2COOL <= '0';
			s_CH3NUM <= (others => '0');
			CH3NEG <= '1';
			CH3COOL <= '0';
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1') then
				s_CH0NUM <= NUM;
				CH0NEG <= NEG;
				CH0COOL <= CLHTb;
			end if;
			if (WRP(1) = '1') then
				s_CH1NUM <= NUM;
				CH1NEG <= NEG;
				CH1COOL <= CLHTb;
			end if;
			if (WRP(2) = '1') then
				s_CH2NUM <= NUM;
				CH2NEG <= NEG;
				CH2COOL <= CLHTb;
			end if;
			if (WRP(3) = '1') then
				s_CH3NUM <= NUM;
				CH3NEG <= NEG;
				CH3COOL <= CLHTb;
			end if;
		end if;
	end process;

	inh <= CUT or CHANGE;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0ENB <= '0';
			CH1ENB <= '0';
			CH2ENB <= '0';
			CH3ENB <= '0';
		elsif (CLK'event and CLK = '1') then
			if (inh(0) = '1') then
				CH0ENB <= '0';
			elsif (WRP(0) = '1') then
				CH0ENB <= TC_ENB;
			end if;
			if (inh(1) = '1') then
				CH1ENB <= '0';
			elsif (WRP(1) = '1') then
				CH1ENB <= TC_ENB;
			end if;
			if (inh(2) = '1') then
				CH2ENB <= '0';
			elsif (WRP(2) = '1') then
				CH2ENB <= TC_ENB;
			end if;
			if (inh(3) = '1') then
				CH3ENB <= '0';
			elsif (WRP(3) = '1') then
				CH3ENB <= TC_ENB;
			end if;
		end if;
	end process;
end RTL;
