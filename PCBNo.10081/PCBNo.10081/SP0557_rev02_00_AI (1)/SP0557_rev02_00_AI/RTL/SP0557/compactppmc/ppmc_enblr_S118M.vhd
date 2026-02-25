-------------------------------------------------
--File Name : ppmc_enblr.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      :2005/06/22
--Ver       :1.00
--Doc       :POUT waits for DIR because of Constant Current STM Driver's Spec.
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      :2005/09/15
--Ver       :5.00
--Doc       :Delete ENB and PWM
--Changed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2008/09/22
--Ver       : 2.00
--Doc       : Added CURRENT DOWN OutPort [CURRENT_DOWN].
--			: Added CURRENT UP Delay Register InPort [UPDELAY].
--			: Added CURRENT DOWN Delay Register InPort [DOWNDELAY].
--Changed by J.I
-------------------------------------------------
--Date      :2008/12/18
--Ver       :3.00
--Doc       :[CURRENT_DOWN] is simplified
--			:  [UPDELAY] is deleted.
--Changed by J.I
-------------------------------------------------
--Date      :2010/09/14
--Ver       :3.01
--Doc       :
--Changed by Y.Takao
-------------------------------------------------
--Date      :2020/03/17
--Ver       :3.02
--Doc       : increase delay of pulse start 12.8usec(8bit) ->  819.15usec(14bit)
--            [CURRENT_DOWN] is deleted
--Changed by Y.Aoki
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity ppmc_enblr_S118M is
	port(
		nMRST			: in std_logic;							-- power on reset or CPU reset(active Low)
		CLK				: in std_logic;							-- Clock 20MHZ
        KCLK        	: in std_logic;                         -- 1khz clock
		ENB_START		: in std_logic;							-- enb start pulse
		P_STOP			: in std_logic;							-- pulse stop
		DOWNDELAY		: in std_logic_vector(7 downto 0);		--
		CURRENT_DOWN	: out std_logic;						--
		START_STOP		: out std_logic							-- start_stop
		);
end ppmc_enblr_S118M;


-- [OPTIMIZATION] Dead code removed: CURRENT_DOWN timer logic (dsb_wait_cnt, s_PLUSE10M_ST, st_stop_old)
-- CURRENT_DOWN was already hardcoded to '0'. Related timer signals only affected CURRENT_DOWN output.
-- Analysis confirmed no impact on START_STOP output path.
-- Savings: 10 FF (dsb_wait_cnt:8 + s_PLUSE10M_ST:1 + st_stop_old:1) + ~15 LUT per instance x 13 = 130 FF + 195 LUT
architecture RTL of ppmc_enblr_S118M is

	signal st_stop			: std_logic;
	signal s_P_STOP_old		: std_logic;
	signal ph_flag			: std_logic;
	signal enb_wait_cnt		: std_logic_vector(13 downto 0);
	signal enb_wait_1280us	: std_logic;

begin

	START_STOP   <= st_stop;
	CURRENT_DOWN <= '0';

----------------------------------------------------------------------
--	Current Up Timmer												--
--ENABLE_START waits for change of DIR signal  toku add 2005.06.23	--
----------------------------------------------------------------------
	process (nMRST, CLK)
	begin
		if (nMRST = '0') then
			enb_wait_cnt <= (others =>'0');
			enb_wait_1280us <= '0';
			s_P_STOP_old <= '0';
		elsif (CLK'event and CLK='1') then
			s_P_STOP_old <= P_STOP;
			if P_STOP = '1' and s_P_STOP_old = '0' then
				-- P_STOP rising edge: reset up timer
				enb_wait_cnt <= (others =>'0');
				enb_wait_1280us <= '0';
			elsif (ENB_START='1' or enb_wait_cnt /= "00000000000000" ) then
				-- Current Up Timer: count to 819.15usec
				if (enb_wait_cnt = "111111" & "11111111") then
					enb_wait_cnt <= (others =>'0');
					enb_wait_1280us <= '1';
				else
					enb_wait_cnt <= enb_wait_cnt + '1';
					enb_wait_1280us <= '0';
				end if;
			end if;
		end if;
	end process;

------------------------------------------------------------------
--Phase
	process (nMRST,CLK)
	begin
		if(nMRST='0') then
			ph_flag <= '0';
		elsif(CLK'event and CLK = '1') then
			if (P_STOP='1') then
				ph_flag	 <= '0';
			elsif(enb_wait_1280us='1') then
				ph_flag <= '1';
			end if;
		end if;
	end process;

	process (nMRST,CLK)
	begin
		if(nMRST='0') then
			st_stop <= '0';
		elsif(CLK'event and CLK = '1') then
			if(ph_flag = '1') then
				st_stop <= '1';
			else
				st_stop <= '0';
			end if;
		end if;
	end process;
end RTL;
