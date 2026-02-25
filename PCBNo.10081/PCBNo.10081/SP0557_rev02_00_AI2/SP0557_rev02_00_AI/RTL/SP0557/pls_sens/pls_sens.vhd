-------------------------------------------------
--File Name : pls_sens.vhd
--Project	: S3IO
--
--Date		: 2003/12/22
--Ver		: 0.01
--Doc		: New Release
--Designed by Satoshi Iguchi
-------------------------------------
--Date		: 2025/11/25
--Ver		: 1.00
--Doc		: Completely rewritten to allow setting the number of channels
--Changed by Nobuhisa Hatashima(PHR)
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

------------------------entity----------------------------------------------------------------------
entity pls_sens is
	generic (
		CH : integer := 12	-- デフォルト値12
	);
	port(
		CLK			: in std_logic;								-- Clock 20MHZ
		LRSTb		: in std_logic;								-- Local Reset (active Low)
		CKEN1k		: in std_logic;								-- Clock Enable 1k
		PLSPD		: in std_logic_vector((CH - 1) downto 0);	-- Phot Diode
		PLSPDLT		: out std_logic_vector((CH - 1) downto 0);	-- Phot Diode Latched
		PLSLEDb		: out std_logic_vector((CH - 1) downto 0)	-- Pulse LED -- toku chng 2004.01.10
	);
end pls_sens;

---------------architecture-------------------------------------------------------------------------
architecture RTL of pls_sens is
-------------- constant ----------------------------------------------------------------------------

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal	s_PD_A			: std_logic_vector((CH - 1) downto 0);
signal	s_PD_B			: std_logic_vector((CH - 1) downto 0);
signal	s_PD_C			: std_logic_vector((CH - 1) downto 0);
signal	s_PD_D			: std_logic_vector((CH - 1) downto 0);
signal	s_PD_SIG		: std_logic_vector((CH - 1) downto 0);
signal	s_SNS_SIG		: std_logic_vector((CH - 1) downto 0);
signal	s_LED_SIG		: std_logic_vector((CH - 1) downto 0);

---------------component----------------------------------------------------------------------------

-------------------- begin -------------------------------------------------------------------------
begin

-- Noise Filter
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_PD_A <= (others => '0');
			s_PD_B <= (others => '0');
			s_PD_C <= (others => '0');
			s_PD_D <= (others => '0');
		elsif (CLK'event and CLK='1') then
			s_PD_A <= PLSPD;
			s_PD_B <= s_PD_A;
			s_PD_C <= s_PD_B;
			s_PD_D <= s_PD_C;
		end if;
	end process;
	s_PD_SIG <= s_PD_B and s_PD_C and s_PD_D;

-- LED
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_LED_SIG(0) <= '1';
			s_LED_SIG((CH-1) downto 0)	<= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (CKEN1k = '1') then
				s_LED_SIG <= s_LED_SIG((CH-2) downto 0) & s_LED_SIG(CH-1) ;
			else
				s_LED_SIG <= s_LED_SIG;
			end if;
		end if;
	end process;
	PLSLEDb <= not s_LED_SIG;

-- PD Latch
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_SNS_SIG <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (CKEN1k = '1') then
				for i in 0 to CH-1 loop
					if (s_LED_SIG(i) = '1') then
						s_SNS_SIG(i) <= s_PD_SIG(i);
					else
						s_SNS_SIG(i) <= s_SNS_SIG(i);
					end if;
				end loop;
			else
				s_SNS_SIG <= s_SNS_SIG;
			end if;
		end if;
	end process;
	PLSPDLT <= s_SNS_SIG;

end RTL;