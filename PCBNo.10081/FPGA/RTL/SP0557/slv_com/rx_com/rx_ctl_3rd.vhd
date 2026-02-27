-------------------------------------------------
--File Name : rx_ctl_3rd.vhd
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

entity rx_ctl_3rd is
	port(
		CLK1			: in std_logic;							-- Clock 10MHZ
		CLK3			: in std_logic;							-- Clock 100MHZ
		nRESET			: in std_logic;							-- power on reset
		RXDCD			: in std_logic_vector(7 downto 0);		-- tx_fifo read data
		RX_EMPTY		: in std_logic;							-- fifo empty_flag
		VALID			: in std_logic;							-- 8b10b_dec data_valid
		HUB_EN			: in std_logic;							-- hub_enable
		RX_WRREQ		: out std_logic;						-- fifo write_request
		CRCCK_EN		: out std_logic;						-- crc clock enable
		CRCRD_EN		: out std_logic;						-- crc generate enable
		RX_START		: out std_logic;						-- rx_end flag
		CRC_INIT		: out std_logic;						-- crc initial
		LATCH_EN		: out std_logic;						-- crc_data latch enable
		DATA_LD			: out std_logic;						--
		K_ERR			: out std_logic;
		PACK_END		: out std_logic;						-- Packet End Signal
		SYNC_FLG		: out std_logic
		);
end rx_ctl_3rd;

architecture RTL of rx_ctl_3rd is

	signal	rxdt_count	: std_logic_vector( 3 downto 0);
	signal	dn_count	: std_logic_vector( 7 downto 0);
	signal	bit_count	: std_logic_vector( 3 downto 0);
	signal	rst_reg1	: std_logic;
	signal	rst_reg2	: std_logic;
	signal	rst_reg3	: std_logic;
	signal	crc_reset	: std_logic;
	signal	dt_load		: std_logic;
	signal	crc_en		: std_logic;
	signal	clk_en		: std_logic;
	signal	ff_wrreq	: std_logic;
	signal	VALID_Q		: std_logic;
	signal	rxdata_top	: std_logic;
	signal	pack_enb	: std_logic;
	signal	sync_f		: std_logic;
	signal	kerr		: std_logic;
	signal	pack_enb_d	: std_logic;


begin
--*** detect pack_enb falling edge ***--
	PACK_END <= (not pack_enb) and pack_enb_d;

	process(CLK1, nRESET)
	begin
		if (nRESET = '0') then
			pack_enb_d <= '0';
		elsif (CLK1'event and CLK1 = '1') then
			pack_enb_d <= pack_enb;
		end if;
	end process;

--*** valid_signal latch ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			VALID_Q <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			VALID_Q <= VALID;
		end if;
	end process;

	rxdata_top <= VALID and not VALID_Q;

--*** rx_fifo write_request ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			ff_wrreq <= '0';
			sync_f	 <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(rxdata_top ='1' and RXDCD="01111110") then
				ff_wrreq <= '1';
				sync_f	 <= '1';
			elsif(HUB_EN ='0' and dn_count="00000010") then
				ff_wrreq <= '0';
				sync_f	 <= '0';
			elsif(HUB_EN ='1' and dn_count="00000000") then
				ff_wrreq <= '0';
				sync_f	 <= '0';
			elsif (VALID='0') then
				ff_wrreq <= '0';
				sync_f	 <= '0';
			else
				ff_wrreq <= ff_wrreq;
				sync_f	 <= '0';
			end if;
		end if;
	end process;

	RX_WRREQ <= ff_wrreq;
	SYNC_FLG <= sync_f;

--*** header_counter7 ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			rxdt_count <= "0000";
			pack_enb <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(rxdata_top='1'and RXDCD="01111110") then
				rxdt_count <= "0001";
				pack_enb <= '1';
			elsif(VALID='1' and pack_enb='1') then
				if(rxdt_count="1010") then
					rxdt_count <= rxdt_count;
				else
					rxdt_count <= rxdt_count + '1';
				end if;
			elsif(dn_count="00000000") then
				rxdt_count <= "0000";
				pack_enb <= '0';
			elsif(VALID = '0') then
				rxdt_count <= "0000";
				pack_enb <= '0';
			else
				rxdt_count <= rxdt_count;
			end if;
		end if;
	end process;

--*** down_counter(length) ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			dn_count <= "11111111";
		elsif(CLK1' event and CLK1 ='1') then
			if(VALID='0') then
				dn_count <= "11111111";
			elsif(rxdt_count="0101") then
				dn_count <= RXDCD + "110";			   --LENGTH+6
			elsif(rxdt_count="0110" or rxdt_count="0111" or rxdt_count="1000" or rxdt_count="1001" or rxdt_count="1010") then
				dn_count <= dn_count - '1';
			else
				dn_count <= dn_count;
			end if;
		end if;
	end process;
	
--*** k-code error detection --toku add 2004.02.02 ***--
	K_ERR <= kerr;

	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			kerr <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(rxdata_top='1'and RXDCD="01111110") then
				kerr <= '0';
			elsif(VALID = '0' and pack_enb = '1' and dn_count /= "00000000") then
				kerr <= '1';
			else
				kerr <= kerr;
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

--*** crc_check start ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			rst_reg1 <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(CLK1 ='0' and VALID='1' and rxdt_count="0000") then
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

--*** crc_check enable ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			crc_en <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(HUB_EN ='0') then
				if(crc_reset='1') then
					crc_en <= '1';
				elsif(dn_count="00000000" and bit_count="0111") then
					crc_en <= '0';
				else
					crc_en <= crc_en;
				end if;
			else
				crc_en <= '0';
			end if;
		end if;
	end process;

	CRCRD_EN <= crc_en;

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

--*** crc check_data latch enable ***--
	process(CLK3,nRESET)
	begin
		if(nRESET='0') then
			LATCH_EN <= '0';
		elsif(CLK3' event and CLK3 ='1') then
			if(dn_count="00000000" and bit_count="0111") then
				LATCH_EN <= '1';
			else
				LATCH_EN <= '0';
			end if;
		end if;
	end process;

--*** rx_start flag ***--
	process(CLK1,nRESET)
	begin
		if(nRESET='0') then
			RX_START <= '0';
		elsif(CLK1' event and CLK1 ='1') then
			if(rxdt_count="0001") then
				RX_START <= '1';
			else
				RX_START <= '0';
			end if;
		end if;
	end process;


end RTL;



