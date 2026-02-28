----------------------------------------------------------------------------------------------------
--File Name	: LEDLT_TOP.vhd
--Project	: S127M(S3IO)
--Date		: 2025.11.20
--Ver		: 00_00
--Doc		: New Release
--			: S127M PCB No.10081
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

------------------------entity----------------------------------------------------------------------
entity LEDLT_TOP is
	port(
		CLK				: in	std_logic; 								-- Slave Clock 20MHZ
		LRSTb			: in	std_logic; 								-- Power On Reset
		CKEN1k			: in	std_logic;
		CLK500k			: in	std_logic;
		CKEN500k		: in	std_logic;
		CKEN5M			: in	std_logic;
		
		LEDPTN_NO		: in	std_logic_vector( 3 downto 0);
		LED_I_SET		: in	std_logic_vector( 7 downto 0);
		LEDLT_ON		: in	std_logic;
		
		LEDDRV_LE		: out	std_logic;
		LEDDRV_OEb		: out	std_logic;
		LEDDRV_CLK		: out	std_logic;
		LEDDRV_SD		: out	std_logic;
		DPM_CSb			: out	std_logic;
		DPM_CLK			: out	std_logic;
		DPM_SD			: out	std_logic
	);
end LEDLT_TOP;
---------------architecture-------------------------------------------------------------------------
architecture RTL of LEDLT_TOP is
-------------- constant ----------------------------------------------------------------------------
constant	c_wait_time			: std_logic_vector( 7 downto 0)		:= X"0A";

---------------type---------------------------------------------------------------------------------

---------------signal-------------------------------------------------------------------------------
signal		s_LEDPTN		: std_logic_vector(15 downto 0);
-- Prevent pruning and constant optimization of LED pattern bits
attribute syn_keep : boolean;
attribute syn_keep of s_LEDPTN : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of s_LEDPTN : signal is true;

signal		s_TLC5916_START		: std_logic;
signal		s_TLC5916_BUSY		: std_logic;
signal		s_TLC5916_FIN		: std_logic;
signal		s_TLC5916_wait_cnt	: std_logic_vector( 7 downto 0);


signal		s_AD8402_START		: std_logic;
signal		s_AD8402_BUSY		: std_logic;
signal		s_AD8402_FIN		: std_logic;
signal		s_AD8402_TXD		: std_logic_vector( 7 downto 0);
signal		s_AD8402_wait_cnt	: std_logic_vector( 7 downto 0);

---------------component----------------------------------------------------------------------------
component TLC5916_CTRL
	port (
		CLK				: in	std_logic;
		RST_n			: in	std_logic;							-- async reset (Act.L)
		CLK500k			: in	std_logic;							-- SCLK base : 500kHz(duty 50%)
		CKEN500k		: in	std_logic;							-- clock enable 500kHz
		SDATA			: in	std_logic_vector(15 downto 0);
		START			: in	std_logic;
		BUSY			: out	std_logic;
		FIN				: out	std_logic;
		LE				: out	std_logic;
		OEb				: out	std_logic;
		SCLK			: out	std_logic;
		SD				: out	std_logic
	);
end component;

component AD8402_CTRL
	port (
		RST_n			: in	std_logic ;							-- reset (act.L)
		CLK				: in	std_logic ;							-- clock
		CE				: in	std_logic ;							-- clock enable : 1pulse/1period (act.H) SCLK_freq = CE_freq/2.
		CH1				: in	std_logic_vector( 7 downto 0 ) ;	-- TX data (ch1)
		CH2				: in	std_logic_vector( 7 downto 0 ) ;	-- TX data (ch2)
		START			: in	std_logic ;							-- process start (act.H)
		CMND_BUSY		: out	std_logic ;							-- command statemachine not idle
		CMND_FIN		: out	std_logic ;							-- ���M��X�e�[�g��FIN
		AD8402_BUSY		: out	std_logic ;							-- ad8402 statemachine not idle
		AD8402_CS_n		: out	std_logic ;							-- SPI Chip select
		AD8402_SCK		: out	std_logic ;							-- SPI shift clock
		AD8402_SDO		: out	std_logic							-- serial data (to slave)
	) ;
end component ;

-------------------- begin -------------------------------------------------------------------------
begin

	-- LED Pattern select
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_LEDPTN <= (others => '0');
		elsif (rising_edge (CLK)) then
			case LEDPTN_NO is
				when X"1"	=>
					s_LEDPTN <= "0001111100011111";
				when X"2"	=>
					s_LEDPTN <= "0001111100000000";
				when X"3"	=>
					s_LEDPTN <= "0000010000000000";
				when others =>
					s_LEDPTN <= (others => '0');
			end case;	
		end if;
	end process;

	-- TLC5916 TX Start signal generate
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_TLC5916_wait_cnt <= (others => '0');
		elsif (rising_edge (CLK)) then
			if (LEDLT_ON = '1')  and (s_TLC5916_BUSY = '0') then
				if (CKEN1k = '1') then
					if s_TLC5916_wait_cnt = c_wait_time then
						s_TLC5916_wait_cnt <= s_TLC5916_wait_cnt;
					else
						s_TLC5916_wait_cnt <= s_TLC5916_wait_cnt + '1';
					end if;
				end if;
			else
				s_TLC5916_wait_cnt <= (others => '0');
			end if;
		end if;
	end process;
	
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_TLC5916_START <= '0';
		elsif (rising_edge (CLK)) then
			if (s_TLC5916_wait_cnt = c_wait_time) then
				s_TLC5916_START <= '1';
			elsif (s_TLC5916_FIN = '1') then
				s_TLC5916_START <= '0';
			else
				s_TLC5916_START <= s_TLC5916_START;
			end if;
		end if;
	end process;

	-- s_AD8402_TXD
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_AD8402_TXD <= (others => '1');
		elsif (rising_edge (CLK)) then
			if  (LEDLT_ON = '1') then
				if LED_I_SET > x"18" then
					s_AD8402_TXD <= LED_I_SET;
				else
					s_AD8402_TXD <= x"19";
				end if;
			else
				s_AD8402_TXD <= (others => '1');
			end if;
		end if;
	end process;

	-- AD8402 TX Start signal generate
	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_AD8402_wait_cnt <= (others => '0');
		elsif (rising_edge (CLK)) then
			if (LEDLT_ON = '1')  and (s_AD8402_BUSY = '0') then
				if (CKEN1k = '1') then
					if s_AD8402_wait_cnt = c_wait_time then
						s_AD8402_wait_cnt <= s_AD8402_wait_cnt;
					else
						s_AD8402_wait_cnt <= s_AD8402_wait_cnt + '1';
					end if;
				end if;
			else
				s_AD8402_wait_cnt <= (others => '0');
			end if;
		end if;
	end process;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			s_AD8402_START <= '0';
		elsif (rising_edge (CLK)) then
			if (s_AD8402_wait_cnt = c_wait_time) then
				s_AD8402_START <= '1';
			elsif (s_AD8402_FIN = '1') then
				s_AD8402_START <= '0';
			else
				s_AD8402_START <= s_AD8402_START;
			end if;
		end if;
	end process;

	-- TLC5916 Control
	TLC5916 : TLC5916_CTRL
	port map (
		CLK			=> CLK,
		RST_n		=> LRSTb,
		CLK500k		=> CLK500k,
		CKEN500k	=> CKEN500k,
		SDATA		=> s_LEDPTN,
		START		=> s_TLC5916_START,
		BUSY		=> s_TLC5916_BUSY,
		FIN			=> s_TLC5916_FIN,
		LE			=> LEDDRV_LE,
		OEb			=> LEDDRV_OEb,
		SCLK		=> LEDDRV_CLK,
		SD			=> LEDDRV_SD
	);

	-- AD8402 Control
	AD8402 : AD8402_CTRL
	port map (
		RST_n		=> LRSTb,			-- in
		CLK			=> CLK,				-- in
		CE			=> CKEN5M,			-- in
		CH1			=> s_AD8402_TXD,	-- in
		CH2			=> s_AD8402_TXD,	-- in
		START		=> s_AD8402_START,	-- in
		CMND_BUSY	=> s_AD8402_BUSY,	-- out
		CMND_FIN	=> s_AD8402_FIN,	-- out
		AD8402_BUSY	=> open,			-- out
		AD8402_CS_n	=> DPM_CSb,			-- out
		AD8402_SCK	=> DPM_CLK,			-- out
		AD8402_SDO	=> DPM_SD			-- out
	) ;

end RTL;
