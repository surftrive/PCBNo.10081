-------------------------------------------------
--File Name : temp_prm_sel.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_prm_sel is
	port ( CH0MEAS :in std_logic_vector(11 downto 0);
			 CH0REF :in std_logic_vector(11 downto 0);
			 CH0AJST :in std_logic_vector(7 downto 0);
			 CH0CLHTb :in std_logic;
			 CH0TC_ENB :in std_logic;
			 CH1MEAS :in std_logic_vector(11 downto 0);
			 CH1REF :in std_logic_vector(11 downto 0);
			 CH1AJST :in std_logic_vector(7 downto 0);
			 CH1CLHTb :in std_logic;
			 CH1TC_ENB :in std_logic;
			 CH2MEAS :in std_logic_vector(11 downto 0);
			 CH2REF :in std_logic_vector(11 downto 0);
			 CH2AJST :in std_logic_vector(7 downto 0);
			 CH2CLHTb :in std_logic;
			 CH2TC_ENB :in std_logic;
			 CH3MEAS :in std_logic_vector(11 downto 0);
			 CH3REF :in std_logic_vector(11 downto 0);
			 CH3AJST :in std_logic_vector(7 downto 0);
			 CH3CLHTb :in std_logic;
			 CH3TC_ENB :in std_logic;
			 PRM_CH :in std_logic_vector(1 downto 0);
			 MEAS :out std_logic_vector(11 downto 0);
			 REF :out std_logic_vector(11 downto 0);
			 AJST :out std_logic_vector(7 downto 0);
			 CLHTb :out std_logic;
			 TC_ENB :out std_logic);
end temp_prm_sel;

architecture RTL of temp_prm_sel is

signal sel : std_logic_vector(3 downto 0);
signal ch0m : std_logic_vector(11 downto 0);
signal ch0r : std_logic_vector(11 downto 0);
signal ch0a : std_logic_vector(7 downto 0);
signal ch0c : std_logic;
signal ch0t : std_logic;
signal ch1m : std_logic_vector(11 downto 0);
signal ch1r : std_logic_vector(11 downto 0);
signal ch1a : std_logic_vector(7 downto 0);
signal ch1c : std_logic;
signal ch1t : std_logic;
signal ch2m : std_logic_vector(11 downto 0);
signal ch2r : std_logic_vector(11 downto 0);
signal ch2a : std_logic_vector(7 downto 0);
signal ch2c : std_logic;
signal ch2t : std_logic;
signal ch3m : std_logic_vector(11 downto 0);
signal ch3r : std_logic_vector(11 downto 0);
signal ch3a : std_logic_vector(7 downto 0);
signal ch3c : std_logic;
signal ch3t : std_logic;

begin

	process (PRM_CH) begin
		case PRM_CH is
			when "00" => sel <= "0001";
			when "01" => sel <= "0010";
			when "10" => sel <= "0100";
			when "11" => sel <= "1000";
			when others => sel <= "0000";
		end case;
	end process;

	ch0m <= CH0MEAS	  when sel(0) = '1' else (others => '0');
	ch0r <= CH0REF	  when sel(0) = '1' else (others => '0');
	ch0a <= CH0AJST	  when sel(0) = '1' else (others => '0');
	ch0c <= CH0CLHTb  when sel(0) = '1' else '0';
	ch0t <= CH0TC_ENB when sel(0) = '1' else '0';

	ch1m <= CH1MEAS	  when sel(1) = '1' else (others => '0');
	ch1r <= CH1REF	  when sel(1) = '1' else (others => '0');
	ch1a <= CH1AJST	  when sel(1) = '1' else (others => '0');
	ch1c <= CH1CLHTb  when sel(1) = '1' else '0';
	ch1t <= CH1TC_ENB when sel(1) = '1' else '0';

	ch2m <= CH2MEAS	  when sel(2) = '1' else (others => '0');
	ch2r <= CH2REF	  when sel(2) = '1' else (others => '0');
	ch2a <= CH2AJST	  when sel(2) = '1' else (others => '0');
	ch2c <= CH2CLHTb  when sel(2) = '1' else '0';
	ch2t <= CH2TC_ENB when sel(2) = '1' else '0';

	ch3m <= CH3MEAS	  when sel(3) = '1' else (others => '0');
	ch3r <= CH3REF	  when sel(3) = '1' else (others => '0');
	ch3a <= CH3AJST	  when sel(3) = '1' else (others => '0');
	ch3c <= CH3CLHTb  when sel(3) = '1' else '0';
	ch3t <= CH3TC_ENB when sel(3) = '1' else '0';

	MEAS   <= ch0m or ch1m or ch2m or ch3m;
	REF	   <= ch0r or ch1r or ch2r or ch3r;
	AJST   <= ch0a or ch1a or ch2a or ch3a;
	CLHTb  <= ch0c or ch1c or ch2c or ch3c;
	TC_ENB <= ch0t or ch1t or ch2t or ch3t;

end RTL;
