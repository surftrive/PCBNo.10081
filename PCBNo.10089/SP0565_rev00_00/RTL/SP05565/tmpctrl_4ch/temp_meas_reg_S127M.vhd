-------------------------------------------------
--File Name : temp_meas_reg_S127M.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2025/12/05
--Ver		: 1.00
--Doc		: custum for PCBNO10089(Linear control)
--Changed by  Nobuhisa Hatashima(PHR)
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_meas_reg_S127M is
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
end temp_meas_reg_S127M;

architecture RTL of temp_meas_reg_S127M is

signal	WRP			: std_logic_vector( 3 downto 0);
signal	CH0TEMP		: std_logic_vector(11 downto 0);
signal	CH1TEMP		: std_logic_vector(11 downto 0);
signal	CH2TEMP		: std_logic_vector(11 downto 0);
signal	CH3TEMP		: std_logic_vector(11 downto 0);
signal	RDSEL		: std_logic_vector( 7 downto 0);
signal	CH0MEASDO	: std_logic_vector(15 downto 0);
signal	CH1MEASDO	: std_logic_vector(15 downto 0);
signal	CH2MEASDO	: std_logic_vector(15 downto 0);
signal	CH3MEASDO	: std_logic_vector(15 downto 0);
signal	CH0MEASLDO	: std_logic_vector( 7 downto 0);
signal	CH0MEASHDO	: std_logic_vector( 7 downto 0);
signal	CH1MEASLDO	: std_logic_vector( 7 downto 0);
signal	CH1MEASHDO	: std_logic_vector( 7 downto 0);
signal	CH2MEASLDO	: std_logic_vector( 7 downto 0);
signal	CH2MEASHDO	: std_logic_vector( 7 downto 0);
signal	CH3MEASLDO	: std_logic_vector( 7 downto 0);
signal	CH3MEASHDO	: std_logic_vector( 7 downto 0);
signal	comp		: std_logic_vector( 2 downto 0);
signal	ch0reg		: std_logic_vector(11 downto 0);
signal	ch1reg		: std_logic_vector(11 downto 0);
signal	ch2reg		: std_logic_vector(11 downto 0);
signal	ch3reg		: std_logic_vector(11 downto 0);

begin

	comp <= TEMP_WRP & TEMP_CH;

	process (comp) begin
		case comp is
			when "100"	=> WRP <= "0001";
			when "101"	=> WRP <= "0010";
			when "110"	=> WRP <= "0100";
			when "111"	=> WRP <= "1000";
			when others => WRP <= "0000";
		end case;
	end process;

	CH0MEAS <= CH0TEMP;
	CH1MEAS <= CH1TEMP;
	CH2MEAS <= CH2TEMP;
	CH3MEAS <= CH3TEMP;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0TEMP <= (others => '0');
			CH1TEMP <= (others => '0');
			CH2TEMP <= (others => '0');
			CH3TEMP <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1') then
				CH0TEMP <= TEMP0_DATA;
			end if;
			if (WRP(1) = '1') then
				CH1TEMP <= TEMP1_DATA;
			end if;
			if (WRP(2) = '1') then
				CH2TEMP <= TEMP2_DATA;
			end if;
			if (WRP(3) = '1') then
				CH3TEMP <= TEMP3_DATA;
			end if;
		end if;
	end process;

	CH0MEASDO <= "0000" & ch0reg;
	CH1MEASDO <= "0000" & ch1reg;
	CH2MEASDO <= "0000" & ch2reg;
	CH3MEASDO <= "0000" & ch3reg;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			ch0reg <= (others => '0');
			ch1reg <= (others => '0');
			ch2reg <= (others => '0');
			ch3reg <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (LOAD_L = '1') then
				ch0reg <= CH0TEMP;
				ch1reg <= CH1TEMP;
				ch2reg <= CH2TEMP;
				ch3reg <= CH3TEMP;
			end if;
		end if;
	end process;

	RDSEL <= SEL when LRDb = '0' else (others => '0');

	CH0MEASLDO <= CH0MEASDO(7 downto 0) when RDSEL(0) = '1' else (others =>'0');
	CH0MEASHDO <= CH0MEASDO(15 downto 8) when RDSEL(1) = '1' else (others =>'0');
	CH1MEASLDO <= CH1MEASDO(7 downto 0) when RDSEL(2) = '1' else (others =>'0');
	CH1MEASHDO <= CH1MEASDO(15 downto 8) when RDSEL(3) = '1' else (others =>'0');
	CH2MEASLDO <= CH2MEASDO(7 downto 0) when RDSEL(4) = '1' else (others =>'0');
	CH2MEASHDO <= CH2MEASDO(15 downto 8) when RDSEL(5) = '1' else (others =>'0');
	CH3MEASLDO <= CH3MEASDO(7 downto 0) when RDSEL(6) = '1' else (others =>'0');
	CH3MEASHDO <= CH3MEASDO(15 downto 8) when RDSEL(7) = '1' else (others =>'0');

	MEASDO <= CH0MEASLDO or CH0MEASHDO or CH1MEASLDO or CH1MEASHDO
			or CH2MEASLDO or CH2MEASHDO or CH3MEASLDO or CH3MEASHDO;

end RTL;
