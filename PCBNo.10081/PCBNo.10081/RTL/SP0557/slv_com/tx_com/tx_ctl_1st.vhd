-------------------------------------------------
--File Name : tx_ctl_1st.vhd
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

entity tx_ctl_1st is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK3			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		TXD_Q			: in std_logic_vector(7 downto 0);		-- tx_fifo read data
		TX_EMPTY		: in std_logic;							-- fifo empty_flag
		HUB_EN			: in std_logic;							-- hub_enable
		TX_RDREQ		: out std_logic;						-- fifo read_request
		CRCCK_EN		: out std_logic;						-- crc clock enable
		CRCTD_EN		: out std_logic;						-- crc generate enable
		TXD_SEL			: out std_logic;						-- data select
		CRC_INIT		: out std_logic;						-- crc initial
		LATCH_EN		: out std_logic;						-- crc_data latch enable
		DATA_LD			: out std_logic;						--
		SD_SEL			: out std_logic;						-- sirial_data select
		ENABLE			: out std_logic;						-- 8b10B data enable
		IDLE_INS		: out std_logic;						-- IDLE_code insert
		TX_END			: out std_logic							-- tx_end flag
		);
end tx_ctl_1st;

architecture RTL of tx_ctl_1st is

	signal	txf_rd		: std_logic;
	signal	txdt_count	: std_logic_vector( 3 downto 0);
	signal	dn_count	: std_logic_vector( 7 downto 0);
	signal	bit_count	: std_logic_vector( 3 downto 0);
	signal	rst_reg1	: std_logic;
	signal	rst_reg2	: std_logic;
	signal	rst_reg3	: std_logic;
	signal	crc_reset	: std_logic;
	signal	dt_load		: std_logic;
	signal	crc_en		: std_logic;
	signal	clk_en		: std_logic;
	signal	d_sel		: std_logic;
	signal	e8b10b_en	: std_logic;
	signal	e8b10b_en_q	: std_logic;
	
begin

--*** tx_fifo read ***--
	TX_RDREQ <= txf_rd;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			txf_rd <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(TX_EMPTY='0') then
				txf_rd <= '1';
			else
				txf_rd <= '0';
			end if;
		end if;
	end process;

--*** header_counter7 ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			txdt_count <= "0000";
		elsif(CLK1' event and CLK1 ='1') then
			if(TX_EMPTY='0'and txf_rd = '0') then
				txdt_count <= "0000";
			elsif(txf_rd='1') then
				if(txdt_count="1011") then
					txdt_count <= txdt_count;
				else
					txdt_count <= txdt_count + '1';
				end if;
			else
				txdt_count <= txdt_count;
			end if;
		end if;
	end process;

--*** down_counter(length) ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			dn_count <= "11111111";
		elsif(CLK1' event and CLK1 ='1') then
			if(txdt_count="0110") then
				dn_count <= TXD_Q + "110";		  --LENGTH+6
			elsif(txf_rd='0' and dn_count = "11111111") then
				dn_count <= dn_count;
			elsif(txdt_count="0111" or txdt_count="1000" or txdt_count="1001" or txdt_count="1010" or txdt_count="1011") then
				dn_count <= dn_count - '1';
			else
				dn_count <= dn_count;
			end if;
		end if;
	end process;

--*** bit_counter10 ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			bit_count <= "0000";
		elsif(CLK3' event and CLK3 ='1') then
			if(crc_reset='1' or bit_count="1001") then
				bit_count <= "0000";
			else
				bit_count <= bit_count + '1';
			end if;
		end if;
	end process;

--*** crc_generete start ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			rst_reg1 <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(CLK1 ='0' and txdt_count="0001") then
				rst_reg1 <= '1';
			else
				rst_reg1 <= '0';
			end if;
		end if;
	end process;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			rst_reg2 <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			rst_reg2 <= rst_reg1;
		end if;
	end process;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			rst_reg3 <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			rst_reg3 <= rst_reg2;
		end if;
	end process;

	crc_reset <= rst_reg2 and not rst_reg3;

	CRC_INIT <= crc_reset;

--*** p/s_load ***--

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			dt_load <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(bit_count="1000") then
				dt_load <= '1';
			else
				dt_load <= '0';
			end if;
		end if;
	end process;

	DATA_LD <= dt_load or crc_reset;

--*** p/s clock enable ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			crc_en <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(HUB_EN ='0') then
				if(crc_reset='1') then
					crc_en <= '1';
				elsif(dn_count="00000010" and bit_count="0111") then
					crc_en <= '0';
				else
					crc_en <= crc_en;
				end if;
			else
				crc_en <= '0';
			end if;
		end if;
	end process;

	CRCTD_EN <= crc_en;

--*** p/s clock enable ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			clk_en <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(HUB_EN ='0') then
				if(not(bit_count="0111" or bit_count="1000")) then
					clk_en <= '1';
				else
					clk_en <= '0';
				end if;
			else
				clk_en <= '0';
			end if;
		end if;
	end process;

	CRCCK_EN <= clk_en;

--*** crc byte_data latch enable ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			LATCH_EN <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if((dn_count="00000000" or dn_count="00000001") and bit_count="0111") then
				LATCH_EN <= '1';
			else
				LATCH_EN <= '0';
			end if;
		end if;
	end process;

--*** tx_data/crc_data selest ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			TXD_SEL <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(HUB_EN ='0') then
				if(dn_count="00000001" or dn_count="00000010") then
					TXD_SEL <= '1';							--"1"->crc_data
				else
					TXD_SEL <= '0';							--"0"->tx_data
				end if;
			else
				TXD_SEL <= '0';								--"0"->tx_data
			end if;
		end if;
	end process;


--*** tx_data/crc_sirial_data selest ***--
	SD_SEL <= d_sel;

	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			d_sel <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(dn_count="00000010" and bit_count="1001") then
				d_sel <= '1';								--"1"->crc_data
			elsif(dn_count="00000000" and bit_count="1001") then
				d_sel <= '0';								--"0"->tx_data
			else
				d_sel <= d_sel;
			end if;
		end if;
	end process;

--*** 8b10b_encoder i/f ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			e8b10b_en <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(txdt_count="0001" and TXD_Q="01111110") then
				e8b10b_en <= '1';
			elsif(dn_count="00000000") then
				e8b10b_en <= '0';
			else
				e8b10b_en <= e8b10b_en;
			end if;
		end if;
	end process;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			e8b10b_en_q <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			e8b10b_en_q <= e8b10b_en;
		end if;
	end process;

	ENABLE <= e8b10b_en_q;
	IDLE_INS <= not e8b10b_en_q;

--*** tx_end flag ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			TX_END <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(dn_count="00000000") then
				TX_END <= '1';
			else
				TX_END <= '0';
			end if;
		end if;
	end process;


end RTL;



