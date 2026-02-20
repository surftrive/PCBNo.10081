-------------------------------------------------
--File Name : crc_check.vhd
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

entity crc_check is
	port(
		CLK3			: in std_logic;							-- Clock 100MHZ for CRC
		nRESET			: in std_logic;							-- power on reset
		RXDCD			: in std_logic_vector(7 downto 0);		-- tx_fifo read data
		CRCCK_EN		: in std_logic;							-- crc clock enable
		CRCRD_EN		: in std_logic;							-- crc generate enable
		CRC_INIT		: in std_logic;							-- crc initial
		DATA_LD			: in std_logic;							-- crc initial
		LATCH_EN		: in std_logic;							-- crc_data latch enable
		CRC_ERR			: out std_logic							-- crc_check error
		);
end crc_check;

architecture RTL of crc_check is

	signal	ps_dt		: std_logic_vector( 7 downto 0);
	signal	crcin_d		: std_logic;
	signal	dt_chk		: std_logic_vector( 15 downto 0);
	signal	rx_sd		: std_logic;
	signal	crc_error	: std_logic;


begin

--*** p/s_change ***--
	rx_sd <= ps_dt(0);

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			ps_dt <= "00000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(DATA_LD='1') then
				ps_dt <= RXDCD;
			else
				ps_dt(0)  <= ps_dt(1);
				ps_dt(1)  <= ps_dt(2);
				ps_dt(2)  <= ps_dt(3);
				ps_dt(3)  <= ps_dt(4);
				ps_dt(4)  <= ps_dt(5);
				ps_dt(5)  <= ps_dt(6);
				ps_dt(6)  <= ps_dt(7);
				ps_dt(7)  <= ps_dt(7);
			end if;
		end if;
	end process;

--*** crc_data generate ***--
	crcin_d <= (rx_sd xor dt_chk(15)) and CRCRD_EN;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			dt_chk <= "0000000000000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(CRC_INIT='1') then
				dt_chk <= "0000000000000000";
			elsif(CRCCK_EN='1') then
				dt_chk(0)  <= crcin_d;
				dt_chk(1)  <= dt_chk(0);
				dt_chk(2)  <= dt_chk(1);
				dt_chk(3)  <= dt_chk(2);
				dt_chk(4)  <= dt_chk(3);
				dt_chk(5)  <= dt_chk(4) xor crcin_d;
				dt_chk(6)  <= dt_chk(5);
				dt_chk(7)  <= dt_chk(6);
				dt_chk(8)  <= dt_chk(7);
				dt_chk(9)  <= dt_chk(8);
				dt_chk(10) <= dt_chk(9);
				dt_chk(11) <= dt_chk(10);
				dt_chk(12) <= dt_chk(11) xor crcin_d;
				dt_chk(13) <= dt_chk(12);
				dt_chk(14) <= dt_chk(13);
				dt_chk(15) <= dt_chk(14);
			else
				dt_chk <= dt_chk;
			end if;
		end if;
	end process;

--*** check_check ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			crc_error <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(LATCH_EN='1') then
				if(dt_chk="0000000000000000") then
					crc_error  <= '0';
				else
					crc_error  <= '1';
				end if;
			elsif(CRC_INIT='1') then
				crc_error  <= '0';
			else
				crc_error  <= crc_error;
			end if;
		end if;
	end process;

	CRC_ERR <= crc_error;

end RTL ;



