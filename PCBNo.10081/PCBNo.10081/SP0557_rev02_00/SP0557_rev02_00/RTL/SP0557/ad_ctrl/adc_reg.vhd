----- Information---------------------------------------------------------------
--File Name : adc_reg.vhdl
--Project	: S127M
--
--Date		: 2025/10/28
--Ver		: 0.00
--Doc		: ADC128S022 Controller
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

----- library ------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----- entity ------------------------------------------------------------------
entity adc_reg is
	Port (
		CLK			: in	std_logic;
		LRSTb		: in	std_logic;

		WREN		: in	std_logic;
		CH			: in	std_logic_vector( 2 downto 0);
		AD_DATA		: in	std_logic_vector(11 downto 0);

		ADDATA01 	: out	std_logic_vector (11 downto 0);	-- AD Data #1
		ADDATA02 	: out	std_logic_vector (11 downto 0);	-- AD Data #2
		ADDATA03 	: out	std_logic_vector (11 downto 0);	-- AD Data #3
		ADDATA04 	: out	std_logic_vector (11 downto 0);	-- AD Data #4
		ADDATA05 	: out	std_logic_vector (11 downto 0);	-- AD Data #5
		ADDATA06 	: out	std_logic_vector (11 downto 0);	-- AD Data #6
		ADDATA07 	: out	std_logic_vector (11 downto 0);	-- AD Data #7
		ADDATA08 	: out	std_logic_vector (11 downto 0)	-- AD Data #8
	);
end adc_reg;

----- architecture ------------------------------------------------------------------
architecture RTL of adc_reg is

----- component ---------------------------------------------------------------

----- type --------------------------------------------------------------------

----- signal ------------------------------------------------------------------
signal	s_WREND	: std_logic;
signal	s_WRP	: std_logic;
signal	s_comp	: std_logic_vector( 3 downto 0);
signal	s_REG1	: std_logic_vector(11 downto 0);
signal	s_REG2	: std_logic_vector(11 downto 0);
signal	s_REG3	: std_logic_vector(11 downto 0);
signal	s_REG4	: std_logic_vector(11 downto 0);
signal	s_REG5	: std_logic_vector(11 downto 0);
signal	s_REG6	: std_logic_vector(11 downto 0);
signal	s_REG7	: std_logic_vector(11 downto 0);
signal	s_REG8	: std_logic_vector(11 downto 0);

----- constant ----------------------------------------------------------------

----- begin -------------------------------------------------------------------
begin

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_WREND <= '0';
		elsif (CLK'event and CLK= '1' ) then
			s_WREND <= WREN;
		end if;
	end process;
	s_WRP	<= WREN and not (s_WREND);

	s_comp <= s_WRP & CH;

	ADDATA01	<= s_REG1;
	ADDATA02	<= s_REG2;
	ADDATA03	<= s_REG3;
	ADDATA04	<= s_REG4;
	ADDATA05	<= s_REG5;
	ADDATA06	<= s_REG6;
	ADDATA07	<= s_REG7;
	ADDATA08	<= s_REG8;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_REG1 <= (others => '0');
			s_REG2 <= (others => '0');
			s_REG3 <= (others => '0');
			s_REG4 <= (others => '0');
			s_REG5 <= (others => '0');
			s_REG6 <= (others => '0');
			s_REG7 <= (others => '0');
			s_REG8 <= (others => '0');
		elsif rising_edge(CLK) then
			case s_comp is
				when "1000" =>
					s_REG1 <= AD_DATA;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1001" =>
					s_REG1 <= s_REG1;
					s_REG2 <= AD_DATA;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1010" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= AD_DATA;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1011" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= AD_DATA;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1100" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= AD_DATA;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1101" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= AD_DATA;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
				when "1110" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= AD_DATA;
					s_REG8 <= s_REG8;
				when "1111" =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= AD_DATA;
				when others =>
					s_REG1 <= s_REG1;
					s_REG2 <= s_REG2;
					s_REG3 <= s_REG3;
					s_REG4 <= s_REG4;
					s_REG5 <= s_REG5;
					s_REG6 <= s_REG6;
					s_REG7 <= s_REG7;
					s_REG8 <= s_REG8;
			end case;
		end if;
	end process;

end RTL;
