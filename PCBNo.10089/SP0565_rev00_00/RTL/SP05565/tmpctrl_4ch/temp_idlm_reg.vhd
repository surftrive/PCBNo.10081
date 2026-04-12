-------------------------------------------------
--File Name : temp_idlm_reg.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2010/09/07
--Ver       : 0.00
--Doc       : New Release
--Designed by J.I
-------------------------------------------------
--Date		: 2010/12/24
--Ver		: 3.00
--Doc		: [100V MODE] Duty 4/8
--Changed by  J.I
-------------------------------------------------
--Date		: 2010/12/25
--Ver		: 4.00
--Doc		: [100V MODE] Duty 4/8 -> */8
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_idlm_reg is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 SEL :in std_logic_vector(3 downto 0);
			 LRDb :in std_logic;
			 LWEb :in std_logic;
			 LATCH_L :in std_logic;
			 LDI :in std_logic_vector(7 downto 0);
        IDLMDO  : out std_logic_vector(7 downto 0);
        CH0IDLM : out std_logic_vector(7 downto 0);
        CH1IDLM : out std_logic_vector(7 downto 0);
        CH2IDLM : out std_logic_vector(7 downto 0);
        CH3IDLM : out std_logic_vector(7 downto 0));
end temp_idlm_reg;

architecture RTL of temp_idlm_reg is

	signal WRP : std_logic_vector(3 downto 0);
	signal RDSEL : std_logic_vector(3 downto 0);
	signal CH0ILDO :std_logic_vector(7 downto 0);
	signal CH1ILDO :std_logic_vector(7 downto 0);
	signal CH2ILDO :std_logic_vector(7 downto 0);
	signal CH3ILDO :std_logic_vector(7 downto 0);
	signal CH0IDLMDO :std_logic_vector(7 downto 0);
	signal CH1IDLMDO :std_logic_vector(7 downto 0);
	signal CH2IDLMDO :std_logic_vector(7 downto 0);
	signal CH3IDLMDO :std_logic_vector(7 downto 0);

begin

	WRP <= SEL when LWEb = '0' else (others => '0');
	RDSEL <= SEL when LRDb = '0' else (others => '0');

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0ILDO <= (others => '0');
			CH1ILDO <= (others => '0');
			CH2ILDO <= (others => '0');
			CH3ILDO <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (WRP(0) = '1' ) then
				CH0ILDO <= LDI;
			end if;
			if (WRP(1) = '1' ) then
				CH1ILDO <= LDI;
			end if;
			if (WRP(2) = '1' ) then
				CH2ILDO <= LDI;
			end if;
			if (WRP(3) = '1' ) then
				CH3ILDO <= LDI;
			end if;
		end if;
	end process;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			CH0IDLM <= (others => '0');
			CH1IDLM <= (others => '0');
			CH2IDLM <= (others => '0');
			CH3IDLM <= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (LATCH_L = '1') then
				CH0IDLM <= CH0ILDO;
				CH1IDLM <= CH1ILDO;
				CH2IDLM <= CH2ILDO;
				CH3IDLM <= CH3ILDO;
			end if;
		end if;
	end process;

	CH0IDLMDO <= CH0ILDO when RDSEL(0) = '1' else (others => '0');
	CH1IDLMDO <= CH1ILDO when RDSEL(1) = '1' else (others => '0');
	CH2IDLMDO <= CH2ILDO when RDSEL(2) = '1' else (others => '0');
	CH3IDLMDO <= CH3ILDO when RDSEL(3) = '1' else (others => '0');

	IDLMDO <= CH0IDLMDO or CH1IDLMDO or CH2IDLMDO or CH3IDLMDO;

end RTL;
