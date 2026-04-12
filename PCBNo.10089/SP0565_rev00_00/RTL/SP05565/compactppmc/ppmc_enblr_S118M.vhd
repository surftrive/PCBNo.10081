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


architecture RTL of ppmc_enblr_S118M is

	signal st_stop			: std_logic;
	signal st_stop_old		: std_logic;
	signal s_P_STOP_old		: std_logic;
	signal ph_flag			: std_logic;
	signal enb_wait_cnt		: std_logic_vector(13 downto 0);
	signal enb_wait_1280us	: std_logic;
	signal dsb_wait_cnt		: std_logic_vector(7 downto 0);
	--
--	signal s_CURRENT_UP		: std_logic;
	signal s_PLUSE10M_ST	: std_logic;
--	signal s_DOWNDELAYold		: std_logic_vector(7 downto 0);		--

begin

	START_STOP   <= st_stop;
--	CURRENT_DOWN <= not (s_CURRENT_UP);
CURRENT_DOWN <= '0';  --
--s_CURRENT_UP <= '0';
----------------------------------------------------------------------
--	Current Down Timmer												--
--ENABLE_START waits for change of DIR signal  toku add 2005.06.23	--
--ina Changed 2008.09.24											--
----------------------------------------------------------------------
	process (nMRST, CLK)
	begin
		if (nMRST = '0') then
			enb_wait_cnt <= (others =>'0');
--			s_CURRENT_UP <= '0';
			s_PLUSE10M_ST <= '0';
			enb_wait_1280us <= '0';
			enb_wait_cnt <= (others =>'0');
			dsb_wait_cnt <= (others =>'0');
--			s_DOWNDELAYold <= "11111111";
		elsif (CLK'event and CLK='1') then
			s_P_STOP_old <= P_STOP;
			st_stop_old <= st_stop;
--			s_DOWNDELAYold <= DOWNDELAY;
			if P_STOP = '1' and s_P_STOP_old = '0' then
				if  (DOWNDELAY /= "00000000" and enb_wait_cnt /= "0000000000000" ) then		--Added by Y.Takao
--					s_CURRENT_UP <= '0';						--
					enb_wait_cnt <= (others =>'0');				--
					enb_wait_1280us <= '0';						--
					dsb_wait_cnt <= dsb_wait_cnt;				--
					s_PLUSE10M_ST <= s_PLUSE10M_ST;				--
				else											--Added by Y.Takao
					enb_wait_1280us <= '0';
					enb_wait_cnt <= (others =>'0');
--					s_CURRENT_UP <= s_CURRENT_UP;
					dsb_wait_cnt <= dsb_wait_cnt;
					s_PLUSE10M_ST <= s_PLUSE10M_ST;
				end if;
			---------------- Current Up Timmer ---------------------------------------------------------
			elsif (ENB_START='1' or enb_wait_cnt /= "0000000000000" ) then
--				s_CURRENT_UP <= '1';
				dsb_wait_cnt <= (others =>'0');
				s_PLUSE10M_ST <= '0';
				if (enb_wait_cnt = "111111" & "11111111") then --819.15usec
					enb_wait_cnt <= (others =>'0');
					enb_wait_1280us <= '1';
				else
					enb_wait_cnt <= enb_wait_cnt + '1';
					enb_wait_1280us <= '0';
				end if;
			---------------- Current Down Timmer ------------------------------------------------------
			elsif (st_stop='0' and st_stop_old ='1') or (s_PLUSE10M_ST = '1')  then
				enb_wait_cnt <= (others =>'0');
				enb_wait_1280us <= '0';
				if (DOWNDELAY = "00000000") then
--					s_CURRENT_UP <='1';
					dsb_wait_cnt <= dsb_wait_cnt;
					s_PLUSE10M_ST <= s_PLUSE10M_ST;
				elsif dsb_wait_cnt < DOWNDELAY then
					s_PLUSE10M_ST <= '1';
					if KCLK = '1' then
						dsb_wait_cnt <= dsb_wait_cnt + '1';
					else
						dsb_wait_cnt <= dsb_wait_cnt;
					end if;
--					s_CURRENT_UP <='1';
				else
					s_PLUSE10M_ST <= '0';
--					s_CURRENT_UP <='0';
					dsb_wait_cnt <= (others =>'0');
				end if;
			else
				enb_wait_1280us <= enb_wait_1280us;
				enb_wait_cnt <= enb_wait_cnt;
				dsb_wait_cnt <= dsb_wait_cnt;
				s_PLUSE10M_ST <= s_PLUSE10M_ST;
--				if (DOWNDELAY = "00000000") and (s_DOWNDELAYold /= "00000000") and (st_stop = '0') and (s_PLUSE10M_ST = '0')	then
--					s_CURRENT_UP <= '1';
--				elsif (DOWNDELAY /= "00000000") and (s_DOWNDELAYold = "00000000") and (st_stop = '0') and (s_PLUSE10M_ST = '0')	then
--					s_CURRENT_UP <= '0';
--				else
--					s_CURRENT_UP <= s_CURRENT_UP;
--				end if;
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
			else
				ph_flag <= ph_flag;
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
