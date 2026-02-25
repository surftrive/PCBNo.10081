-------------------------------------------------
--File Name : crc_gen.vhd
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

entity crc_gen is
	port(
		CLK3			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		TXD_Q			: in std_logic_vector(7 downto 0);		-- tx_fifo read data
		CRCCK_EN		: in std_logic;							-- crc clock enable
		CRCTD_EN		: in std_logic;							-- crc generate enable
		SD_SEL			: in std_logic;							-- data select
		CRC_INIT		: in std_logic;							-- CRC initial
		DATA_LD			: in std_logic;							-- CRC initial
		LATCH_EN		: in std_logic;							-- CRC_data latch enable
		TX_CRCD			: out std_logic_vector( 7 downto 0)		--
		);
end crc_gen;

architecture RTL of crc_gen is

	signal	ps_dt		: std_logic_vector( 7 downto 0);	--
	signal	sp_dt		: std_logic_vector( 7 downto 0);	--
	signal	crcin_d		: std_logic;
	signal	dt_gen		: std_logic_vector( 15 downto 0);
	signal	txd			: std_logic;
	signal	tx_sd		: std_logic;
	signal	crc_td		: std_logic;
	signal	crc_8td		: std_logic_vector( 7 downto 0);


begin

--*** p/s_change ***--
	tx_sd <= ps_dt(0);

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			ps_dt <= "00000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(DATA_LD='1') then
				ps_dt <= TXD_Q;
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
	crcin_d <= (tx_sd xor dt_gen(15)) and CRCTD_EN and not SD_SEL;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			dt_gen <= "0000000000000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(CRC_INIT='1') then
				dt_gen <= "0000000000000000";
			elsif(CRCCK_EN='1') then
				dt_gen(0)  <= crcin_d;
				dt_gen(1)  <= dt_gen(0);
				dt_gen(2)  <= dt_gen(1);
				dt_gen(3)  <= dt_gen(2);
				dt_gen(4)  <= dt_gen(3);
				dt_gen(5)  <= dt_gen(4) xor crcin_d;
				dt_gen(6)  <= dt_gen(5);
				dt_gen(7)  <= dt_gen(6);
				dt_gen(8)  <= dt_gen(7);
				dt_gen(9)  <= dt_gen(8);
				dt_gen(10) <= dt_gen(9);
				dt_gen(11) <= dt_gen(10);
				dt_gen(12) <= dt_gen(11) xor crcin_d;
				dt_gen(13) <= dt_gen(12);
				dt_gen(14) <= dt_gen(13);
				dt_gen(15) <= dt_gen(14);
			else
				dt_gen <= dt_gen;
			end if;
		end if;
	end process;

	crc_td <= dt_gen(15);

	txd <= tx_sd when SD_SEL='0' else crc_td;

--*** s/p_change ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			sp_dt <= "00000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(CRCCK_EN='1') then
				sp_dt(0)  <= sp_dt(1);
				sp_dt(1)  <= sp_dt(2);
				sp_dt(2)  <= sp_dt(3);
				sp_dt(3)  <= sp_dt(4);
				sp_dt(4)  <= sp_dt(5);
				sp_dt(5)  <= sp_dt(6);
				sp_dt(6)  <= sp_dt(7);
				sp_dt(7)  <= txd;
			else
				sp_dt  <= sp_dt;
			end if;
		end if;
	end process;

--*** pararel_data latch ***--
	TX_CRCD <= crc_8td;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			crc_8td <= "00000000";
		elsif(CLK3' event and CLK3 ='1') then
			if(LATCH_EN='1') then
				crc_8td	 <= sp_dt;
			else
				crc_8td	 <= crc_8td;
			end if;
		end if;
	end process;


end RTL ;



