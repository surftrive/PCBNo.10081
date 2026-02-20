-------------------------------------------------
--File Name : tx_ctl_3rd.vhd
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

entity tx_ctl_3rd is
	port(
		CLK2			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		TXEN_B			: in std_logic_vector(9 downto 0);		-- tx_ck_fifo read data 10bit
		TXCF_EMPTY		: in std_logic;							-- tx_ck_fifo empty_flag
		TXCF_RDREQ		: out std_logic;						-- tx_ck_fifo read_request
		TX_D			: out std_logic							-- tx_sirial_data out

		);
end tx_ctl_3rd;

architecture RTL of tx_ctl_3rd is

	signal	tx_start	: std_logic;
	signal	st_count	: std_logic_vector( 3 downto 0);
	signal	txdt_count	: std_logic_vector( 3 downto 0);
	signal	ps_dt		: std_logic_vector( 9 downto 0);
	signal	dt_load		: std_logic;


begin

--*** tx_data read_request ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			tx_start <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(TXCF_EMPTY='0') then
				tx_start <= '1';
			elsif(st_count="1001" and TXCF_EMPTY='1') then
				tx_start <= '0';
			else
				tx_start <= tx_start;
			end if;
		end if;
	end process;

--*** start_data_counter10 ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			st_count <= "0000";
		elsif(CLK2' event and CLK2 ='1') then
			if(tx_start='1') then
				if(st_count="1001") then
					st_count <= st_count;
				else
					st_count <= st_count + '1';
				end if;
			else
				st_count <= "0000";
			end if;
		end if;
	end process;

--*** tx_data read_request ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			TXCF_RDREQ <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(st_count="1001") then
				if(txdt_count="1001") then
					TXCF_RDREQ <= '1';
				else
					TXCF_RDREQ <= '0';
				end if;
			else
				TXCF_RDREQ <= '0';
			end if;
		end if;
	end process;

--*** tx_data_counter10 ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			txdt_count <= "0000";
		elsif(CLK2' event and CLK2 ='1') then
			if(st_count="1001") then
				if(txdt_count="1001") then
					txdt_count <= "0000";
				else
					txdt_count <= txdt_count + '1';
				end if;
			else
				txdt_count <= "0000";
			end if;
		end if;
	end process;


--*** p/s_load ***--
	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			dt_load <= '0';
		elsif(CLK2' event and CLK2 ='1') then
			if(txdt_count="1001") then
				dt_load <= '1';
			else
				dt_load <= '0';
			end if;
		end if;
	end process;

--*** p/s_change ***--
	TX_D <= ps_dt(0);

	process(CLK2,nRESET)
	begin
		if(nRESET='0') then
			ps_dt <= "0000000000";
		elsif(CLK2' event and CLK2 ='1') then
			if(dt_load='1') then
				ps_dt <= TXEN_B;
			else
				ps_dt(0)  <= ps_dt(1);
				ps_dt(1)  <= ps_dt(2);
				ps_dt(2)  <= ps_dt(3);
				ps_dt(3)  <= ps_dt(4);
				ps_dt(4)  <= ps_dt(5);
				ps_dt(5)  <= ps_dt(6);
				ps_dt(6)  <= ps_dt(7);
				ps_dt(7)  <= ps_dt(8);
				ps_dt(8)  <= ps_dt(9);
				ps_dt(9)  <= ps_dt(9);
			end if;
		end if;
	end process;


end RTL;



