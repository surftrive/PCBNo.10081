-------------------------------------------------
--File Name : rx_ctl_1st.vhd
--Project	: S3IO
--
--Date		: 2003/12/01
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity rx_ctl_1st is
	port(
		CLK2			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		RX_DT			: in std_logic;							-- rx_data_in
		RXDE_B			: out std_logic_vector(9 downto 0);		-- rx_data(10bit)
		RXCF_WRREQ		: out std_logic;						-- rx_ck_fifi write_request
		IDLE_EN			: out std_logic							-- IDLE_data enable
		);
end rx_ctl_1st;

architecture RTL of rx_ctl_1st is
	signal	sp_dt		: std_logic_vector( 9 downto 0);
	signal	sp_dt_1q	: std_logic_vector( 9 downto 0);
	signal	sp_dt_2q	: std_logic_vector( 9 downto 0);
	signal	event_p		: std_logic;
	signal	pa_count	: std_logic_vector( 3 downto 0);
	signal	state_count	: std_logic_vector( 2 downto 0);

	signal illegal_dat	: std_logic;		--toku add 2005.06.23

-- Prevent register sharing/merging of shift register pipeline stages
attribute syn_preserve : boolean;
attribute syn_preserve of sp_dt    : signal is true;
attribute syn_preserve of sp_dt_1q : signal is true;
attribute syn_preserve of sp_dt_2q : signal is true;

begin


--**********************--
--		sp_chg			--
--**********************--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			sp_dt <= "0000000000";
		elsif(CLK2' event and CLK2 ='1') then
			sp_dt(0)  <= sp_dt(1);
			sp_dt(1)  <= sp_dt(2);
			sp_dt(2)  <= sp_dt(3);
			sp_dt(3)  <= sp_dt(4);
			sp_dt(4)  <= sp_dt(5);
			sp_dt(5)  <= sp_dt(6);
			sp_dt(6)  <= sp_dt(7);
			sp_dt(7)  <= sp_dt(8);
			sp_dt(8)  <= sp_dt(9);
			sp_dt(9)  <= RX_DT;
		end if;
	end process;

	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			sp_dt_1q <= "0000000000";
		elsif(CLK2' event and CLK2 ='1') then
			sp_dt_1q  <= sp_dt;
		end if;
	end process;

	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			sp_dt_2q <= "0000000000";
		elsif(CLK2' event and CLK2 ='1') then
				sp_dt_2q  <= sp_dt_1q;
		end if;
	end process;

	RXDE_B <= sp_dt_2q;

--**********************--
--		paturn_chk		--
--**********************--
--************ IDLE_code check	***************--
-- sp_dt = IDLE_code("0101111100" or "1010000011")
--*********************************************--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			event_p <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(sp_dt="0101111100" or sp_dt="1010000011") then
				event_p <= '1';
			else
				event_p <= '0';
			end if;
		end if;
	end process;

--*** paturn_counter10 ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			pa_count <= "0000";
		elsif(CLK2' event and CLK2 ='1') then
			if(event_p='1'and state_count="000") then
				pa_count <= "0001";
			elsif(pa_count="1001") then
				pa_count <= "0000";
			else
				pa_count <= pa_count + '1';
			end if;
		end if;
	end process;

--*** state_counter7 ***--

	illegal_dat <= '1' when (sp_dt = "0000000000") else '0';		--toku add 2005.06.23

	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			state_count <= "000";
		elsif(CLK2' event and CLK2 ='1') then

			if (illegal_dat = '1') then				--toku add 2005.06.23
				state_count <= "000";				--toku add 2005.06.23
			else							--toku add 2005.06.23

				if(state_count="000") then				--ST0:
					if(event_p='1') then
						state_count <= "001";
					else
						state_count <= "000";
					end if;
				elsif(state_count="001") then			--ST1:
					if(event_p='1' and pa_count="0000") then
						state_count <= "010";
					elsif(event_p='0' and pa_count="0000") then
						state_count <= "000";
					else
						state_count <= "001";
					end if;
				elsif(state_count="010") then			--ST2:
					if(event_p='1' and pa_count="0000") then
						state_count <= "011";
					elsif(event_p='0' and pa_count="0000") then
						state_count <= "000";
					else
						state_count <= "010";
					end if;
				elsif(state_count="011") then			--ST3:
					if(event_p='1' and pa_count="0000") then
						state_count <= "100";
					elsif(event_p='1' and pa_count/="0000") then
						state_count <= "000";
					else
						state_count <= "011";
					end if;
				elsif(state_count="100") then			--ST4:
					if(event_p='1' and pa_count="0000") then
						state_count <= "101";
					elsif(event_p='1' and pa_count/="0000") then
						state_count <= "011";
					else
						state_count <= "100";
					end if;
				elsif(state_count="101") then			--ST5:
					if(event_p='1' and pa_count/="0000") then
						state_count <= "100";
					else
						state_count <= "101";
					end if;
				else
					state_count <= "000";
				end if;

			end if;							--toku add 2005.06.23

		end if;
	end process;

--*** 10bit_data latch_enable ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			IDLE_EN <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(event_p='1' and state_count>="011") then
				IDLE_EN <= '1';
			else
				IDLE_EN <= '0';
			end if;
		end if;
	end process;

--***rx_ck_fifo_write ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			RXCF_WRREQ <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(pa_count="0000" and state_count>="011") then
				RXCF_WRREQ <= '1';
			else
				RXCF_WRREQ <= '0';
			end if;
		end if;
	end process;


end RTL ;



