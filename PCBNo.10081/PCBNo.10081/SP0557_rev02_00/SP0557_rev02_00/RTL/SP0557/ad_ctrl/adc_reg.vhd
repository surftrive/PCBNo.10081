----- Information---------------------------------------------------------------
--File Name : adc_reg.vhdl
--Project	: S127M
--
--Date		: 2025/10/28
--Ver		: 0.00
--Doc		: ADC128S022 Controller
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------
--Date		: 2026/02/20
--Ver		: 0.01
--Doc		: [OPTIMIZATION] Removed unused ADC channels 3-8 (s_REG3-s_REG8)
--            ADDATA03-08 are connected to 'open' in SP0557.vhd top level
--            Only channels 1,2 used for pressure sensors
--            Also removed redundant self-assignments from case statement
--            Savings: 6 channels x 12 FF = 72 FF + comparison logic
--Changed by RTL Optimization
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

----- signal ------------------------------------------------------------------
signal	s_WREND	: std_logic;
signal	s_WRP	: std_logic;
signal	s_REG1	: std_logic_vector(11 downto 0);
signal	s_REG2	: std_logic_vector(11 downto 0);

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

	ADDATA01	<= s_REG1;
	ADDATA02	<= s_REG2;
	-- [OPTIMIZATION] Channels 3-8 unused (connected to 'open' at top level)
	ADDATA03	<= (others => '0');
	ADDATA04	<= (others => '0');
	ADDATA05	<= (others => '0');
	ADDATA06	<= (others => '0');
	ADDATA07	<= (others => '0');
	ADDATA08	<= (others => '0');

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_REG1 <= (others => '0');
			s_REG2 <= (others => '0');
		elsif rising_edge(CLK) then
			if s_WRP = '1' then
				case CH is
					when "000" =>
						s_REG1 <= AD_DATA;
					when "001" =>
						s_REG2 <= AD_DATA;
					when others =>
						null;  -- channels 3-8 unused
				end case;
			end if;
		end if;
	end process;

end RTL;
