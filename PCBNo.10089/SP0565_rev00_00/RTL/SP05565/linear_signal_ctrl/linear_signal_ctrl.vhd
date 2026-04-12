-------------------------------------------------
--File Name	: linear_signal_ctrl.vhd
--Project	: I183M
--
--Date		: 2025/01/24
--Ver			: 0.00
--Doc			: New Release
--Designed by Takuma Kitaura
-------------------------------------------------
--Date      : 2025/03/10
--Ver       : 0.01
--Doc       : change max output 4A from 6A
--Changed by Takuma Kitaura
-------------------------------------------------------------
--Date      : 2025/06/09
--Ver       : 0.02
--Doc       : Change d0-d8 for TPS56837H and AD5271 (I246M)
--Changed by Yoshinori Nakamura
-------------------------------------------------------------
--Date      : 2025/07/10
--Ver       : 0.03
--Doc       : Change d0-d8 8bit(AD5271) -> 10bit(AD5270)
--Changed by Yoshinori Nakamura
-------------------------------------------------------------
--Date      : 2025/11/21
--Ver       : 0.04
--Doc       : Add IN port D1-D8, delete constant d0-d8
--				  Add OUT port EF_ENB
--Changed by Yoshinori Nakamura
-------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use IEEE.std_logic_arith.ALL;
------------------------entity-------------------------------
entity linear_signal_ctrl is
	port(
		CLK			: in std_logic;											-- Clock 20MHZ
		LRSTb		: in std_logic;											-- Local Reset (active Low)
		TERM		: in std_logic;											-- CLK210ms/8
		NUM			: in std_logic_vector(2 downto 0);						-- Number of Pulse (1/8-8/8)
		NEG         : in std_logic;											-- Negative signal of subtract value (Measure - target)
		ENB			: in std_logic;											-- Enable signal of temp ctrl
		START		: in std_logic;											-- Start signal of temp ctrl from IPU
		D1			: in std_logic_vector(9 downto 0)	:= "1011011010";	-- DATA1 : 730 (4.55V)
		D2			: in std_logic_vector(9 downto 0)	:= "0011110000";	-- DATA2 : 240 (7V)
		D3			: in std_logic_vector(9 downto 0)	:= "0010001110";	-- DATA3 : 142 (9.5V)
		D4			: in std_logic_vector(9 downto 0)	:= "0001100100";	-- DATA4 : 100 (12V)
		D5			: in std_logic_vector(9 downto 0)	:= "0001001101";	-- DATA5 :  77 (14.5V)
		D6			: in std_logic_vector(9 downto 0)	:= "0000111110";	-- DATA6 :  62 (17V)
		D7			: in std_logic_vector(9 downto 0)	:= "0000110100";	-- DATA7 :  52 (19.4V)
		D8			: in std_logic_vector(9 downto 0)	:= "0000101100";	-- DATA8 :  44 (22V)
		DC_ENB		: out std_logic;										-- Enable DC-DC converter
		EF_ENB		: out std_logic;										-- Enable e-FUSE (Drive peltier)
		P_DATA		: out std_logic_vector(9 downto 0);						-- Data for Digital potentiometer
		DA_SEND     : out std_logic											-- Data Send Trigger
	);
end linear_signal_ctrl;
---------------architecture----------------------------------
architecture RTL of linear_signal_ctrl is
---------------constant--------------------------------------
--constant d1			: std_logic_vector(9 downto 0)	:= "1011011010";		-- 730: 1/8×256(4.55V)
--constant d2			: std_logic_vector(9 downto 0)	:= "0011110000";		-- 240: 2/8×256(7V)
--constant d3			: std_logic_vector(9 downto 0)	:= "0010001110";		-- 142: 3/8×256(9.5V)
--constant d4			: std_logic_vector(9 downto 0)	:= "0001100100";		-- 100: 4/8×256(12V)
--constant d5			: std_logic_vector(9 downto 0)	:= "0001001101";		--  77: 5/8×256(14.5V)
--constant d6			: std_logic_vector(9 downto 0)	:= "0000111110";		--  62: 6/8×256(17V)
--constant d7			: std_logic_vector(9 downto 0)	:= "0000110100";		--  52: 7/8×256(19.4V)
--constant d8			: std_logic_vector(9 downto 0)	:= "0000101100";		--  44: 8/8×256(22V)

--------------signal-----------------------------------------
signal s_STATUS			: std_logic_vector(5 downto 0);
signal s_dSTATUS			: std_logic_vector(5 downto 0);
signal s_SET				: std_logic_vector(2 downto 0);
signal s_PDATA				: std_logic_vector(9 downto 0);
signal s_clk210ms			: std_logic;
signal s_count				: std_logic_vector(2 downto 0);
signal s_DC_ENB			: std_logic;
signal s_DC_ENB_DLY		: std_logic;
signal s_EF_ENB			: std_logic;
signal s_EF_ENB_DLY		: std_logic;
signal s_EF_ENB_DLY2		: std_logic;
signal s_UPDATE			: std_logic;
signal s_UPDATE_REG		: std_logic;

---------------begin------------------------------------------
begin

P_DATA <= s_PDATA;
DC_ENB <= s_DC_ENB_DLY;
EF_ENB <= s_EF_ENB_DLY2;
DA_SEND <= s_UPDATE_REG;

s_STATUS <= START & ENB & NEG & s_SET;

---- generate 210ms clock ----
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_clk210ms <= '0';
			s_count <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (ENB = '0' or START = '0' or NEG = '1') then
				s_clk210ms <= '0';
				s_count <= (others => '0');
			elsif (TERM = '1') then
				s_count <= s_count + 1;
				if (s_count = "111") then			-- 210ms/8×8
					s_clk210ms <= '1';
				else
					s_clk210ms <= '0';
				end if;
			else
				s_count <= s_count;
				s_clk210ms <= '0';
			end if;
		end if;
	end process;


---- Select setting value ----
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_SET <= (others =>'0');
		elsif (CLK'event and CLK='1') then
			if (ENB = '0' or START = '0' or NEG = '1') then
				s_SET <= (others =>'0');
			elsif (s_clk210ms = '1') then
				if (s_SET < NUM) then			-- voltage up
					s_SET <= s_SET + "001";
				elsif (s_SET > NUM) then		-- voltage down
					s_SET <= s_SET - "001";
				else
					s_SET <= s_SET;
				end if;
			else
				s_SET <= s_SET;
			end if;
		end if;
	end process;


---- D-FF for temperature control status ----
	process (CLK,LRSTb) begin
		if (LRSTb='0') then
			s_dSTATUS <= (others =>'0');
		elsif (CLK'event and CLK='1') then
			if (TERM = '1') then
				s_dSTATUS <= s_STATUS;
			else
				s_dSTATUS <= s_dSTATUS;
			end if;
		end if;
	end process;
	

---- Select sending data to potentiometer and generate update signal ----
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_PDATA <= D1;
			s_UPDATE <= '0';
		elsif (CLK'event and CLK='1') then
			if (TERM = '1' and  s_STATUS /= s_dSTATUS) then
				case s_SET is
					when "000"  => s_PDATA <= D1; s_UPDATE <= '1';
					when "001"  => s_PDATA <= D2; s_UPDATE <= '1';
					when "010"  => s_PDATA <= D3; s_UPDATE <= '1';
					when "011"  => s_PDATA <= D4; s_UPDATE <= '1';
					when "100"  => s_PDATA <= D5; s_UPDATE <= '1';
					when "101"  => s_PDATA <= D6; s_UPDATE <= '1';
					when "110"  => s_PDATA <= D7; s_UPDATE <= '1';
					when "111"  => s_PDATA <= D8; s_UPDATE <= '1';
					when others =>	s_PDATA <= D1; s_UPDATE <= '0';
				end case;
			else
				s_PDATA <= s_PDATA;
				s_UPDATE <= '0';
			end if;
		end if;
	end process;

	process (CLK,LRSTb) begin
		if (LRSTb='0') then
			s_UPDATE_REG <= '0';
		elsif (CLK'event and CLK='1') then
			if (s_UPDATE = '1') then
				s_UPDATE_REG <= '1';
			elsif (TERM = '1') then
				s_UPDATE_REG <= '0';
			else
				s_UPDATE_REG <= s_UPDATE_REG;
			end if;
		end if;
	end process;

	
---- Generate Enable signal for DC-DC converter and efuse ----
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_DC_ENB <= '0';
			s_EF_ENB <= '0';
		elsif (CLK'event and CLK='1') then
			if (ENB = '0' or START = '0') then
				s_DC_ENB <= '0';		-- OFF
				s_EF_ENB <= '0';		-- OFF
			elsif (NEG = '1') then
				s_DC_ENB <= '1';		-- ON
				s_EF_ENB <= '0';		-- OFF
			elsif (TERM = '1') then
				s_DC_ENB <= '1';		-- ON
				s_EF_ENB <= '1';		-- ON
			else
				s_DC_ENB <= s_DC_ENB;
				s_EF_ENB <= s_EF_ENB;
			end if;
		end if;
	end process;

	process (CLK,LRSTb) begin
		if (LRSTb='0') then
			s_DC_ENB_DLY <= '0';
		elsif (CLK'event and CLK='1') then
			if (s_DC_ENB = '0') then		-- immediate OFF
				s_DC_ENB_DLY <= '0';
			elsif (TERM = '1') then
				s_DC_ENB_DLY <= s_DC_ENB;			-- delay
			else
				s_DC_ENB_DLY <= s_DC_ENB_DLY;
			end if;
		end if;
	end process;	
	
	process (CLK,LRSTb) begin
		if (LRSTb='0') then
			s_EF_ENB_DLY <= '0';
			s_EF_ENB_DLY2 <= '0';
		elsif (CLK'event and CLK='1') then
			if (s_EF_ENB = '0') then		-- immediate OFF
				s_EF_ENB_DLY <= '0';
				s_EF_ENB_DLY2 <= '0';
			elsif (TERM = '1') then
				s_EF_ENB_DLY <= s_EF_ENB;			-- 1delay
				s_EF_ENB_DLY2 <= s_EF_ENB_DLY;	-- 2delay
			else
				s_EF_ENB_DLY <= s_EF_ENB_DLY;
				s_EF_ENB_DLY2 <= s_EF_ENB_DLY2;
			end if;
		end if;
	end process;
	

end RTL;
