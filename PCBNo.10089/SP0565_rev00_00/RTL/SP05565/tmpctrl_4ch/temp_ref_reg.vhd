-------------------------------------------------
--File Name : temp_ref_reg.vhd
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

entity temp_ref_reg is
   port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 SEL :in std_logic_vector(7 downto 0);
			 LRDb :in std_logic;
			 LWEb :in std_logic;
			 LATCH_L :in std_logic;
			 LDI :in std_logic_vector(7 downto 0);
			 REFDO :out std_logic_vector(7 downto 0);
			 CH0REF :out std_logic_vector (11 downto 0);
			 CH1REF :out std_logic_vector (11 downto 0);
			 CH2REF :out std_logic_vector (11 downto 0);
			 CH3REF :out std_logic_vector (11 downto 0));
end temp_ref_reg;

architecture RTL of temp_ref_reg is

	signal WRP : std_logic_vector(7 downto 0);
	signal RDSEL : std_logic_vector(7 downto 0);
	signal CH0REFDO :std_logic_vector(15 downto 0);
	signal CH1REFDO :std_logic_vector(15 downto 0);
	signal CH2REFDO :std_logic_vector(15 downto 0);
	signal CH3REFDO :std_logic_vector(15 downto 0);
	signal CH0REFLDO :std_logic_vector(7 downto 0);
	signal CH0REFHDO :std_logic_vector(7 downto 0);
	signal CH1REFLDO :std_logic_vector(7 downto 0);
	signal CH1REFHDO :std_logic_vector(7 downto 0);
	signal CH2REFLDO :std_logic_vector(7 downto 0);
	signal CH2REFHDO :std_logic_vector(7 downto 0);
	signal CH3REFLDO :std_logic_vector(7 downto 0);
	signal CH3REFHDO :std_logic_vector(7 downto 0);
	signal ch0regl :std_logic_vector(7 downto 0);
	signal ch0regh :std_logic_vector(3 downto 0);
	signal ch1regl :std_logic_vector(7 downto 0);
	signal ch1regh :std_logic_vector(3 downto 0);
	signal ch2regl :std_logic_vector(7 downto 0);
	signal ch2regh :std_logic_vector(3 downto 0);
	signal ch3regl :std_logic_vector(7 downto 0);
	signal ch3regh :std_logic_vector(3 downto 0);

begin

	WRP <= SEL when LWEb = '0' else (others => '0');
	RDSEL <= SEL when LRDb = '0' else (others => '0');

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			ch0regl <= (others => '0');
			ch0regh <= (others => '0');
			ch1regl <= (others => '0');
			ch1regh <= (others => '0');
			ch2regl <= (others => '0');
			ch2regh <= (others => '0');
			ch3regl <= (others => '0');
			ch3regh <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1' ) then
				ch0regl <= LDI;
			end if;
			if (WRP(1) = '1' ) then
				ch0regh <= LDI(3 downto 0);
			end if;
			if (WRP(2) = '1' ) then
				ch1regl <= LDI;
			end if;
			if (WRP(3) = '1' ) then
				ch1regh <= LDI(3 downto 0);
			end if;
			if (WRP(4) = '1' ) then
				ch2regl <= LDI;
			end if;
			if (WRP(5) = '1' ) then
				ch2regh <= LDI(3 downto 0);
			end if;
			if (WRP(6) = '1' ) then
				ch3regl <= LDI;
			end if;
			if (WRP(7) = '1' ) then
				ch3regh <= LDI(3 downto 0);
			end if;
		end if;
	end process;

	CH0REFDO <= "0000" & ch0regh & ch0regl;
	CH1REFDO <= "0000" & ch1regh & ch1regl;
	CH2REFDO <= "0000" & ch2regh & ch2regl;
	CH3REFDO <= "0000" & ch3regh & ch3regl;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0REF <= (others => '0');
			CH1REF <= (others => '0');
			CH2REF <= (others => '0');
			CH3REF <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (LATCH_L = '1') then
				CH0REF <= CH0REFDO(11 downto 0);
				CH1REF <= CH1REFDO(11 downto 0);
				CH2REF <= CH2REFDO(11 downto 0);
				CH3REF <= CH3REFDO(11 downto 0);
			end if;
		end if;
	end process;

	CH0REFLDO <= CH0REFDO(7 downto 0)  when RDSEL(0) = '1' else (others => '0');
	CH0REFHDO <= CH0REFDO(15 downto 8) when RDSEL(1) = '1' else (others => '0');
	CH1REFLDO <= CH1REFDO(7 downto 0)  when RDSEL(2) = '1' else (others => '0');
	CH1REFHDO <= CH1REFDO(15 downto 8) when RDSEL(3) = '1' else (others => '0');
	CH2REFLDO <= CH2REFDO(7 downto 0)  when RDSEL(4) = '1' else (others => '0');
	CH2REFHDO <= CH2REFDO(15 downto 8) when RDSEL(5) = '1' else (others => '0');
	CH3REFLDO <= CH3REFDO(7 downto 0)  when RDSEL(6) = '1' else (others => '0');
	CH3REFHDO <= CH3REFDO(15 downto 8) when RDSEL(7) = '1' else (others => '0');

	REFDO <= CH0REFLDO or CH0REFHDO or CH1REFLDO or CH1REFHDO
	      or CH2REFLDO or CH2REFHDO or CH3REFLDO or CH3REFHDO;

end RTL;
