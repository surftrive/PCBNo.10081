-------------------------------------------------------------
--File Name : log_ca_DAC_ctrl.vhd
--Project   : DAC_CONTROL IP
--
--Date      : 2009/03/18
--Ver       : 0.00
--Doc       : DAC081S101 Controller
--Designed by JUN.INAGAKI
-------------------------------------------------------------
--Date      :
--Ver       :
--Doc       :
--Changed by
-------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------
entity log_ca_DAC_ctrl is								--
    port (												--
        CLK         : in std_logic;						-- 20MHz CLK
        LRSTb       : in std_logic;						-- Local Reset (active Low)
        P_DATA      : in std_logic_vector(7 downto 0);	-- DATA
        DA_SEND     : in std_logic;	                    -- Data Send Trigger
        SCLK        :out std_logic;						-- OUTPUT to DAC(2.5MHz)
        SYNC        :out std_logic;	                    -- OUTPUT to DAC
        DO          :out std_logic						-- OUTPUT to DAC
    );													--
end log_ca_DAC_ctrl;									--
---------------architecture----------------------------------
architecture RTL of log_ca_DAC_ctrl is
---------------component-------------------------------------
component log_ca_DACclk_gen								--
    port (												--
        CLK			: in std_logic;						-- 20MHz CLK
        LRSTb		: in std_logic;						-- Local Reset (active Low)
        SCLK		:out std_logic;						-- OUTPUT to DAC(2.5MHz)
        RISE		:out std_logic						-- 2.5MHz One Shot RISE Pulse
    );													--
end component;											--

component log_ca_DACif_seq								--
    port (												--
        CLK			: in std_logic;						-- 20MHz CLK
        LRSTb		: in std_logic;						-- Local Reset (active Low)
        TC			: in std_logic;						--
        SEND_TC		: in std_logic;						--
        PDATA		: in std_logic_vector(7 downto 0);	-- 16bit 2.5MHz -> 6.4Usec
        SYNC		:out std_logic;						-- OUTPUT to DAC
        DO			:out std_logic;						-- OUTPUT to DAC
		IDLE		:out std_logic						--
        );												--
end component;											--
---------------type-------------------------------------------
---------------constant---------------------------------------
---------------signal-----------------------------------------
signal  s_RISE			: std_logic;
signal  s_SEND_TC		: std_logic;
signal  s_IDLE			: std_logic;
signal  s_P_DATA		: std_logic_vector(7 downto 0);	-- DATA
signal	s_DA_SEND_old	: std_logic;
signal  s_SYNC			: std_logic;
signal  s_SYNC_t		: std_logic;
signal  s_TC			: std_logic;
signal  s_IDLE_old		: std_logic;
signal  s_IDLE_RISE		: std_logic;

---------------begin------------------------------------------
begin
	----------------------------------------------------------
	process(CLK,LRSTb) begin
        if(LRSTb='0') then
            s_P_DATA <= (others =>'0');
        elsif(CLK'event and CLK='1') then
			s_DA_SEND_old <= DA_SEND;
            if(DA_SEND = '1' and s_DA_SEND_old = '0') then
                s_P_DATA <= P_DATA;
            else
                s_P_DATA <= s_P_DATA;
            end if;
        end if;
    end process;

	process(CLK,LRSTb) begin
		if(LRSTb='0') then
			s_IDLE_old <= '0';
			s_IDLE_RISE <= '0';
		elsif(CLK'event and CLK='1') then
			s_IDLE_old <= s_IDLE;
			if(s_IDLE = '1' and s_IDLE_old = '0') then
				s_IDLE_RISE <= '1';
			else
				s_IDLE_RISE <= '0';
			end if;
		end if;
	end process;

    process(CLK,LRSTb) begin
        if(LRSTb='0') then
        	s_TC <= '0';
        elsif(CLK'event and CLK='1') then
            if(s_IDLE_RISE = '1') then
        		s_TC <= '0';
            elsif(DA_SEND ='1') then
        		s_TC <= '1';
            else
        		s_TC <= s_TC;
            end if;
        end if;
    end process;

 ---Component Instantiation
log_ca_DACclk_gen_inst: log_ca_DACclk_gen
    port map(
        CLK     => CLK,
        LRSTb   => LRSTb,
        SCLK    => SCLK,
        RISE    => s_RISE
    );

log_ca_DACif_seq_inst: log_ca_DACif_seq
    port map(
        CLK     => CLK,					--: in std_logic;						-- 20MHz CLK
        LRSTb   => LRSTb,               --: in std_logic;						-- Local Reset (active Low)
        TC      => s_RISE,              --: in std_logic;						--
        SEND_TC => s_TC,                --: in std_logic;						--
        PDATA   => s_P_DATA,            --: in std_logic_vector(7 downto 0);	-- 16bit 2.5MHz -> 6.4Usec
        SYNC    => SYNC,            --:out std_logic;						-- OUTPUT to DAC
        DO      => DO ,                 --:out std_logic;						-- OUTPUT to DAC
		IDLE	=> s_IDLE               --:out std_logic						--
    );

end RTL;