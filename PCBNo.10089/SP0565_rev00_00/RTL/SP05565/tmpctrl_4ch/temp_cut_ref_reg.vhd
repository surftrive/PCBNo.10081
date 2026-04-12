-------------------------------------------------
--File Name : temp_cut_ref_reg.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2003/09/17
--Ver		: 0.01
--Doc		: for Specification Ver.0.03
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date		: 2005/12/05
--Ver		: 1.00
--Doc		: Initial Value 190h(400) -> 64h(100)
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_cut_ref_reg is
	port ( 
		CLK		:in std_logic;
		LRSTb	:in std_logic;
		SEL		:in std_logic_vector(1 downto 0);
		LRDb	:in std_logic;
		LWEb	:in std_logic;
		LATCH_L	:in std_logic;
		LDI		:in std_logic_vector(7 downto 0);
		CUTDO	:out std_logic_vector(7 downto 0);
		CUTREF	:out std_logic_vector(11 downto 0)
	);
end temp_cut_ref_reg;

architecture RTL of temp_cut_ref_reg is

	signal WRP : std_logic_vector(1 downto 0);
	signal RDSEL : std_logic_vector(1 downto 0);
	signal CUTREFDO :std_logic_vector(15 downto 0);
	signal CUTREFLDO :std_logic_vector(7 downto 0);
	signal CUTREFHDO :std_logic_vector(7 downto 0);
	signal regl :std_logic_vector(7 downto 0);
	signal regh :std_logic_vector(3 downto 0);
	constant c_INITIAL_VALUE : std_logic_vector(15 downto 0) := "0000000001100100";

begin

	WRP		<= SEL when LWEb = '0' else (others => '0');
	RDSEL	<= SEL when LRDb = '0' else (others => '0');

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			regl <= c_INITIAL_VALUE(7 downto 0);
			regh <= c_INITIAL_VALUE(11 downto 8);
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1' ) then
				regl <= LDI;
			end if;
			if (WRP(1) = '1' ) then
				regh <= LDI(3 downto 0);
			end if;
		end if;
	end process;

	CUTREFDO <= "0000" & regh & regl;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CUTREF <= c_INITIAL_VALUE(11 downto 0);
		elsif (CLK'event and CLK = '1') then
			if (LATCH_L = '1') then
				CUTREF <= CUTREFDO(11 downto 0);
			end if;
		end if;
	end process;

	CUTREFLDO <= CUTREFDO(7 downto 0)  when RDSEL(0) = '1' else (others => '0');
	CUTREFHDO <= CUTREFDO(15 downto 8) when RDSEL(1) = '1' else (others => '0');

	CUTDO <= CUTREFLDO or CUTREFHDO;

end RTL;
