-------------------------------------------------
--File Name : temp_ajst_reg.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2003/07/18
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 
--Ver       : 
--Doc       : 
--Changed by 
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_ajst_reg is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 SEL :in std_logic_vector(3 downto 0);
			 LRDb :in std_logic;
			 LWEb :in std_logic;
			 LATCH_L :in std_logic;
			 LDI :in std_logic_vector(7 downto 0);
			 AJSTDO :out std_logic_vector(7 downto 0);
			 CH0AJST :out std_logic_vector(7 downto 0);
			 CH1AJST :out std_logic_vector(7 downto 0);
			 CH2AJST :out std_logic_vector(7 downto 0);
			 CH3AJST :out std_logic_vector(7 downto 0));
end temp_ajst_reg;

architecture RTL of temp_ajst_reg is

	signal WRP : std_logic_vector(3 downto 0);
	signal RDSEL : std_logic_vector(3 downto 0);
	signal CH0AJDO :std_logic_vector(7 downto 0);
	signal CH1AJDO :std_logic_vector(7 downto 0);
	signal CH2AJDO :std_logic_vector(7 downto 0);
	signal CH3AJDO :std_logic_vector(7 downto 0);
	signal CH0AJSTDO :std_logic_vector(7 downto 0);
	signal CH1AJSTDO :std_logic_vector(7 downto 0);
	signal CH2AJSTDO :std_logic_vector(7 downto 0);
	signal CH3AJSTDO :std_logic_vector(7 downto 0);

begin

	WRP <= SEL when LWEb = '0' else (others => '0');
	RDSEL <= SEL when LRDb = '0' else (others => '0');

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0AJDO <= (others => '0');
			CH1AJDO <= (others => '0');
			CH2AJDO <= (others => '0');
			CH3AJDO <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1' ) then
				CH0AJDO <= LDI;
			end if;
			if (WRP(1) = '1' ) then
				CH1AJDO <= LDI;
			end if;
			if (WRP(2) = '1' ) then
				CH2AJDO <= LDI;
			end if;
			if (WRP(3) = '1' ) then
				CH3AJDO <= LDI;
			end if;
		end if;
	end process;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0AJST <= (others => '0');
			CH1AJST <= (others => '0');
			CH2AJST <= (others => '0');
			CH3AJST <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (LATCH_L = '1') then
				CH0AJST <= CH0AJDO;
				CH1AJST <= CH1AJDO;
				CH2AJST <= CH2AJDO;
				CH3AJST <= CH3AJDO;
			end if;
		end if;
	end process;

	CH0AJSTDO <= CH0AJDO when RDSEL(0) = '1' else (others => '0');
	CH1AJSTDO <= CH1AJDO when RDSEL(1) = '1' else (others => '0');
	CH2AJSTDO <= CH2AJDO when RDSEL(2) = '1' else (others => '0');
	CH3AJSTDO <= CH3AJDO when RDSEL(3) = '1' else (others => '0');

	AJSTDO <= CH0AJSTDO or CH1AJSTDO or CH2AJSTDO or CH3AJSTDO;

end RTL;
