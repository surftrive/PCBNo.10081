------------------------------------------------------------
--File Name : ad5270_5271_ctrl.vhd
--Project	: 
--
--Date		: 2021/03/25
--Ver		: 0.00
--Doc		: New Release
--Designed by Yoshinori Nakamura
------------------------------------------------------------
--Date		: 2021/12/03
--Ver		: 0.01
--Doc		: Changed SCLK 10MHz -> 2.5MHz
--Changed by Yoshinori Nakamura
-------------------------------------------------
--Date		: 2021/12/08
--Ver		: 0.02
--Doc		: Add Initial Operation
--Changed by Yoshinori Nakamura
-------------------------------------------------
--Date		: 2026/02/06
--Ver		: 0.03
--Doc		: Change SCLK to match [CPOL = 0,CPHA = 1]
--Changed by Nobuhisa Hatashima(PHR)
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------

entity ad5270_5271_ctrl is
	port (
		CLK		: in	std_logic;						-- 20MHz CLK
		LRSTb	: in	std_logic;						-- Local Reset (active Low)
		DATA0	: in	std_logic_vector(9 downto 0);	-- DATA0
		DATA1	: in	std_logic_vector(9 downto 0);	-- DATA1
		DATA2	: in	std_logic_vector(9 downto 0);	-- DATA2
		DATA3	: in	std_logic_vector(9 downto 0);	-- DATA3
		DATA4	: in	std_logic_vector(9 downto 0);	-- DATA4
		DA_SEND	: in	std_logic_vector(4 downto 0);	-- Data Send Trigger
		SCLK	: out	std_logic;						-- Serial clock (Fall edge enable)
		SYNC	: out	std_logic_vector(4 downto 0);	-- Chip select (active Low)
		DO		: out	std_logic						-- Serial Data Output
	);
end ad5270_5271_ctrl;

----------------------architecture---------------------------
architecture RTL of ad5270_5271_ctrl is
---------------component-------------------------------------
---------------type-------------------------------------------
type STATE is ( IDLE,
				Z1_LOW,
				Z1_HIGH,
				Z0_LOW,
				Z0_HIGH,
				C3_LOW,
				C3_HIGH,
				C2_LOW,
				C2_HIGH,
				C1_LOW,
				C1_HIGH,
				C0_LOW,
				C0_HIGH,
				D9_LOW,
				D9_HIGH,
				D8_LOW,
				D8_HIGH,
				D7_LOW,
				D7_HIGH,
				D6_LOW,
				D6_HIGH,
				D5_LOW,
				D5_HIGH,
				D4_LOW,
				D4_HIGH,
				D3_LOW,
				D3_HIGH,
				D2_LOW,
				D2_HIGH,
				D1_LOW,
				D1_HIGH,
				D0_LOW,
				D0_HIGH,
				-- CS_HOLD,
				RTRN_IDLE);
---------------constant---------------------------------------
constant	c_cd1	: std_logic_vector(3 downto 0) := "0001";		-- Command data 1 (Write data to RDAC for AD5270/AD5271)
constant	c_cd7	: std_logic_vector(3 downto 0) := "0111";		-- Command data 7 (Write data to control register for AD5270/AD5271)
constant	c_wd7	: std_logic_vector(9 downto 0) := "0000000010";	-- Write Data to control register to enable writing of RDAC register

---------------signal-----------------------------------------	
signal	s_state			: STATE;
signal	s_gd			: std_logic_vector(9 downto 0);
signal	s_sdo			: std_logic;
signal	s_cs			: std_logic_vector(4 downto 0);
signal	s_sck			: std_logic;
signal	s_SYNC			: std_logic_vector(4 downto 0);
signal	s_DA_SEND_ago	: std_logic_vector(4 downto 0);
signal	s_DATA			: std_logic_vector(9 downto 0);		-- DATA
signal	s_CNT5M			: std_logic_vector(1 downto 0);
signal	s_CKEN5M		: std_logic;
signal	s_cd			: std_logic_vector(3 downto 0);
signal	s_INIT			: std_logic;

---------------begin------------------------------------------
begin

	DO		<= s_sdo;
	SYNC	<= not (s_cs);
	-- SCLK <= not s_sck;  -- Fall edge enable for AD5270/AD5271
	SCLK	<= s_sck;	-- 2026/02/06
	
	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_CNT5M		<= (others =>'0');
			s_CKEN5M	<= '0';
		elsif(CLK'event and CLK='1')then
			if (s_CNT5M = "11") then
				s_CNT5M		<= (others =>'0');
				s_CKEN5M	<= '1';
			else
				s_CNT5M		<= s_CNT5M + "01";
				s_CKEN5M	<= '0';
			end if;
		end if;
	end process;

	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_DA_SEND_ago	<= (others =>'1');
		elsif(CLK'event and CLK='1')then
			if (s_CKEN5M = '1') then
				s_DA_SEND_ago	<= DA_SEND;
			end if;
		end if;
	end process;
	--------------------------------------------------------------

	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_SYNC	<= (others =>'0');
			s_DATA	<= (others =>'0');
			s_cd	<= (others =>'0');
			s_INIT	<= '0';
		elsif(CLK'event and CLK='1') then
			if (s_CKEN5M = '1') then
				 if (s_INIT = '0') then	-- Initial operation to enable data writing
					s_SYNC	<= (others =>'1');
					s_DATA	<= c_wd7;
					s_cd	<= c_cd7;
					s_INIT	<= '1';
				elsif (DA_SEND /= s_DA_SEND_ago) then
					case DA_SEND is
						when "00001"	=> s_SYNC <= "00001";			s_DATA <= DATA0;
						when "00010"	=> s_SYNC <= "00010";			s_DATA <= DATA1;
						when "00100"	=> s_SYNC <= "00100";			s_DATA <= DATA2;
						when "01000"	=> s_SYNC <= "01000";			s_DATA <= DATA3;
						when "10000"	=> s_SYNC <= "10000";			s_DATA <= DATA4;
						when others		=> s_SYNC <= (others =>'0');	s_DATA <= s_DATA;
					end case;
					s_cd	<= c_cd1;
					s_INIT	<= s_INIT;
				else
					s_SYNC	<= (others =>'0');
					s_DATA	<= s_DATA;
					s_cd	<= s_cd;
					s_INIT	<= s_INIT;
				end if;
			end if;
		end if;
	end process;


--===================== State Machine ==================================
---------------process------------------------------------------
	process (CLK,LRSTb) begin
		if (LRSTb = '0') then
			s_state	<= IDLE;
			s_gd	<= (others => '0');
			s_sdo	<= '0';
			s_cs	<= (others => '0');
			s_sck	<= '0';
		elsif (CLK'event and CLK='1') then
			if (s_CKEN5M = '1') then
				case s_state	is
					when IDLE =>							
						 if (s_SYNC = "00000") then
							s_state	<= IDLE;
							s_gd	<= s_gd;
							s_sdo	<= s_sdo;
							s_cs	<= (others => '0');
							s_sck	<= '0';
						else
							---- ZERO BITS ----
							s_state	<= Z1_LOW;
							s_gd	<= s_DATA;
							s_sdo	<= s_sdo;
							s_cs	<= s_SYNC;
							s_sck	<= '0';
						end if;
					when Z1_LOW =>
						s_state	<= Z1_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= '0'; -- Zero
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when Z1_HIGH =>
						s_state	<= Z0_LOW;
						s_gd	<= s_gd;
						s_sdo	<= '0';
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when Z0_LOW =>
						s_state	<= Z0_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= '0'; -- Zero
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when Z0_HIGH =>
						s_state	<= C3_LOW;
						s_gd	<= s_gd;
						s_sdo	<= '0';
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
	
					---- COMMAND BITS ----
					when C3_LOW =>
						s_state	<= C3_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(3);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when C3_HIGH =>
						s_state	<= C2_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(3);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when C2_LOW =>
						s_state	<= C2_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(2);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when C2_HIGH =>
						s_state	<= C1_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(2);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when C1_LOW =>
						s_state	<= C1_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(1);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when C1_HIGH =>
						s_state	<= C0_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(1);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when C0_LOW =>
						s_state	<= C0_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(0);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when C0_HIGH =>
						s_state	<= D9_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_cd(0);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
	
					---- DATA BITS ----
					when D9_LOW =>
						s_state	<= D9_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(9);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D9_HIGH =>
						s_state	<= D8_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(9);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D8_LOW =>
						s_state	<= D8_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(8);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D8_HIGH =>
						s_state	<= D7_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(8);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D7_LOW =>
						s_state	<= D7_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(7);
						s_cs	<= s_cs;
						s_sck	<= '1';	-- 2026/02/06
					when D7_HIGH =>
						s_state	<= D6_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(7);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D6_LOW =>
						s_state	<= D6_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(6);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D6_HIGH =>
						s_state	<= D5_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(6);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D5_LOW =>
						s_state	<= D5_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(5);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D5_HIGH =>
						s_state	<= D4_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(5);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D4_LOW =>
						s_state	<= D4_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(4);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D4_HIGH =>
						s_state	<= D3_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(4);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D3_LOW =>
						s_state	<= D3_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(3);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D3_HIGH =>
						s_state	<= D2_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(3);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D2_LOW =>
						s_state	<= D2_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(2);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D2_HIGH =>
						s_state	<= D1_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(2);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D1_LOW =>
						s_state	<= D1_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(1);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D1_HIGH =>
						s_state	<= D0_LOW;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(1);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					when D0_LOW =>
						s_state	<= D0_HIGH;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(0);
						s_cs	<= s_cs;
						-- s_sck	<= '0';
						s_sck	<= '1';	-- 2026/02/06
					when D0_HIGH =>
						s_state	<= RTRN_IDLE;
						s_gd	<= s_gd;
						s_sdo	<= s_gd(0);
						s_cs	<= s_cs;
						-- s_sck	<= '1';
						s_sck	<= '0';	-- 2026/02/06
					--	when CS_HOLD =>
					--		s_state	<= RTRN_IDLE;
					--		s_gd	<= s_gd;
					--		s_sdo	<= s_gd(0);
					--		s_cs	<= s_cs;
					--		s_sck	<= '0';
					when RTRN_IDLE =>
						s_state	<= IDLE;
						s_gd	<= s_gd;
						s_sdo	<= s_sdo;
						s_cs	<= (others => '0');
						s_sck	<= '0';
					when others =>
						s_state	<= IDLE;
						s_gd	<= s_gd;
						s_sdo	<= s_sdo;
						s_cs	<= (others => '0');
						s_sck	<= '0';
				end case;
			end if;
		end if;
	end process;
	--------------------------------------------------------------
end RTL;
