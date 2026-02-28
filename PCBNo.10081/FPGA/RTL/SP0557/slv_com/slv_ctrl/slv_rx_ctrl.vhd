-------------------------------------------------
--File Name : slv_rx_ctrl.vhd
--Project	: S3IO
--
--Date		: 2003/12/11
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date		: 2005/06/17
--Ver		: 3.00
--Doc		: [null] of [STATE others] is deleted.
--			: [STATE S_INIT] is added.
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity slv_rx_ctrl is
	port(
		nRESET		: in std_logic;								-- power on reset or CPU reset(active Low)
		CLK1		: in std_logic;								-- Clock 10MHZ
		RX_EMPTY	: in std_logic;
		RX_D		: in std_logic_vector( 7 downto 0);			-- fifo read data
		RX_ERR		: in std_logic;		-- toku add 2004.02.24
		CRC_ERR		: in std_logic;		-- toku add 2004.02.24
		PACK_END	: in std_logic;		-- toku add 2004.05.17 -- Packet End Signal

		LDI			: out std_logic_vector( 7 downto 0);		-- local data
		CMD			: out std_logic_vector( 7 downto 0);		-- CMD
		ADR1		: out std_logic_vector( 7 downto 0);		-- ADR1
		ADR2		: out std_logic_vector( 7 downto 0);		-- ADR2
		PRPTY		: out std_logic_vector( 7 downto 0);		-- PRPTY
		NODE		: out std_logic_vector( 3 downto 0);		-- NODE
		BC			: out std_logic;							-- bload cast
		RX_RDENB	: out std_logic;							-- fifo read enb(active High)
		LRSTb		: out std_logic;							-- local reset signal(active Low)
		TX_START	: out std_logic;
		LWEb		: out std_logic;							-- local write signal(active Low)
		LGSb		: out std_logic;							-- Logger Select(active Low)
		IDSb		: out std_logic;							-- ID select(active Low)
		LOAD		: out std_logic;							-- load signal(active high)
		LATCH		: out std_logic;							-- latch signal(active high)
		BANK		: out std_logic_vector( 6 downto 0);		-- bank
		LA_RX		: out std_logic_vector( 4 downto 0);		-- local address(memory address)
		RX_F		: out std_logic								-- now recieve(active High)
		);
end slv_rx_ctrl;

architecture RTL of slv_rx_ctrl is

	signal STATE		: std_logic_vector(13 downto 0);
	constant INIT		: std_logic_vector(13 downto 0)	:="00000000000001";
	constant IDLE		: std_logic_vector(13 downto 0)	:="00000000000011";
	constant S_START	: std_logic_vector(13 downto 0)	:="00000000000010";
	constant RX_SYNC	: std_logic_vector(13 downto 0)	:="00000000000110";
	constant RX_PRPTY	: std_logic_vector(13 downto 0)	:="00000000000100";
	constant RX_ADR1	: std_logic_vector(13 downto 0)	:="00000000001100";
	constant RX_ADR2	: std_logic_vector(13 downto 0)	:="00000000001000";
	constant RX_CMD		: std_logic_vector(13 downto 0)	:="00000000011000";
	constant RX_LEN		: std_logic_vector(13 downto 0)	:="00000000010000";
	constant RX_WREN	: std_logic_vector(13 downto 0)	:="00000000110000";
	constant RX_BANK	: std_logic_vector(13 downto 0)	:="00000000100000";
	constant RX_DATA	: std_logic_vector(13 downto 0)	:="00000001100000";
	constant RX_LOG_RD	: std_logic_vector(13 downto 0)	:="00000001000000";
	constant END_CHK	: std_logic_vector(13 downto 0)	:="00000011000000";
	constant END_CHK2	: std_logic_vector(13 downto 0)	:="00000010000000";

	signal LA			: std_logic_vector( 4 downto 0);
	signal LD			: std_logic_vector( 7 downto 0);
	signal CMD_DATA		: std_logic_vector( 7 downto 0);
	signal prpty_data	: std_logic_vector( 7 downto 0);
	signal wren_d		: std_logic_vector(31 downto 0);
	signal byte_cnt		: std_logic_vector(2 downto 0);
	signal cnt			: std_logic;
	signal w_enable		: std_logic;		-- write enable flag
	signal err_flg		: std_logic;

	signal rst_flg		: std_logic;
	signal slv_flg		: std_logic;
	--signal s_sync		: std_logic_vector( 7 downto 0);

-- Prevent pruning of byte counter bits and constant optimization
attribute syn_keep : boolean;
attribute syn_keep of byte_cnt : signal is true;
attribute syn_preserve : boolean;
attribute syn_preserve of byte_cnt : signal is true;
-- NODE register preserved via FDC view-level attribute (v:work.slv_rx_ctrl)

begin
	err_flg <= CRC_ERR or RX_ERR;
	LA_RX	<= LA;
	LDI		<= LD;
	CMD		<= CMD_DATA;
	IDSb <= '0' when (CMD_DATA="00000010") else	'1';
	LGSb <= '0' when (CMD_DATA="00001000" or CMD_DATA="00001001")
				else '1';
	PRPTY <= prpty_data;
	BC <= prpty_data(6);
	
--*******************************************--
--			  rx fifo read control			 --
--*******************************************--
-- State Machine

	process(nRESET, CLK1)
	begin
		if(nRESET= '0')	then
			rst_flg <= '0';
			slv_flg <= '0';
			RX_F		<= '0';
			RX_RDENB	<= '0';
			LA			<= (others=>'0');
			cnt			<= '0';
			LRSTb		<= '0';
			TX_START	<= '0';
			LOAD		<= '0';
			LATCH		<= '0';
			w_enable		<='0';
			ADR1		<= (others=>'0');
			ADR2		<= (others=>'0');
			NODE		<= (others=>'0');
			CMD_DATA	<= (others=>'0');
			wren_d		<= (others=>'0');
			BANK		<= (others=>'0');
			byte_cnt	<= (others=>'0');
			STATE		<= INIT;
		elsif(CLK1'event and CLK1='1') then
			case STATE is
				when INIT =>
					if(RX_EMPTY='0') then
						RX_RDENB <= '1';
						STATE	 <= INIT;
					else
						RX_RDENB <= '0';
						STATE	 <= IDLE;
					end if;
				when IDLE =>
					w_enable	<='0';
					cnt			<= '0';
					LRSTb		<= '1';
					TX_START	<= '0';
					LOAD		<= '0';
					LATCH		<= '0';
					LA			<= (others=>'0');
					byte_cnt	<= (others=>'0');
					if(RX_EMPTY='0' and PACK_END = '1') then
						RX_F	 <= '1';
						RX_RDENB <= '1';
						STATE	 <= S_START;
					else
						RX_F	 <= '0';
						RX_RDENB <= '0';
						STATE	 <= IDLE;
					end if;
				when S_START =>
						--s_sync	 <= RX_D;
						STATE	 <= RX_SYNC;
				when RX_SYNC =>
					if (RX_D = "01111110") then
						STATE		<= RX_PRPTY;
					else
						STATE		<= END_CHK2;
					end if;
				when RX_PRPTY =>
					prpty_data	<= RX_D;
					STATE		<= RX_ADR1;
				when RX_ADR1 =>
					ADR1		<= RX_D;
					STATE		<= RX_ADR2;
				when RX_ADR2 =>
					ADR2		<= RX_D;
					NODE		<= RX_D(7 downto 4);
					STATE		<= RX_CMD;
				when RX_CMD =>
					CMD_DATA	<= RX_D;
					STATE		<= RX_LEN;
				when RX_LEN =>
					cnt <='0';
					if(CMD_DATA="00000000") then					-- reset
						STATE	<= END_CHK;
					elsif(CMD_DATA="00000001") then					-- slvchk
						slv_flg <= '1';
						STATE	<= END_CHK;
					elsif(CMD_DATA="00000010") then					-- function check
						if (slv_flg = '1') then
							STATE	<= END_CHK;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00000100") then					-- recieve
						if (slv_flg = '1') then
							STATE	<= RX_WREN;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00000101") then					-- transmit
						if (slv_flg = '1') then
							STATE	<= END_CHK;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00000110") then					-- load
						if (slv_flg = '1') then
							STATE	<= END_CHK;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00000111") then					-- latch
						if (slv_flg = '1') then
							STATE	<= END_CHK;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00001000") then					-- log recieve
						if (slv_flg = '1') then
							STATE	<= RX_WREN;
						else
							STATE	<= END_CHK2;
						end if;
					elsif(CMD_DATA="00001001") then					-- log transimit
						if (slv_flg = '1') then
							STATE	<= RX_WREN;
						else
							STATE	<= END_CHK2;
						end if;
					else
						STATE	<= END_CHK2;
					end if;
				when RX_WREN =>
					if(byte_cnt	= "001") then
						byte_cnt				<= byte_cnt + '1';
						if (err_flg = '0') then
							wren_d(15 downto 8)		<=	RX_D;
						else
							wren_d(15 downto 8)		<=	(others => '0');
						end if;
						STATE					<= RX_WREN;
					elsif(byte_cnt	= "010") then
						byte_cnt				<= byte_cnt + '1';
						if (err_flg = '0') then
							wren_d(23 downto 16)	<=	RX_D;
						else
							wren_d(23 downto 16)	<=	(others => '0');
						end if;
						STATE					<= RX_WREN;
					elsif(byte_cnt	= "011") then
						byte_cnt				<= (others=>'0');
						if (err_flg = '0') then
							wren_d(31 downto 24)	<=	RX_D;
						else
							wren_d(31 downto 24)	<=	(others => '0');
						end if;
						if(CMD_DATA="00000100") then					-- recieve
							STATE	<= RX_DATA;
						elsif(CMD_DATA = "00001000" or CMD_DATA ="00001001") then	-- loger
							STATE	<= RX_BANK;
						else
							STATE	<= END_CHK;
						end if;
					else
						byte_cnt			<= byte_cnt + '1';
						if (err_flg = '0') then
							wren_d(7 downto 0)	<=	RX_D;
						else
							wren_d(7 downto 0)	<=	(others => '0');
						end if;
						STATE				<= RX_WREN;
					end if;
				when RX_BANK =>
					BANK	<=	RX_D(6 downto 0);
					if(CMD_DATA="00001000") then					-- log recieve
						STATE	<= RX_LOG_RD;
					else
						STATE	<= END_CHK;
					end if;
				when RX_DATA =>
					w_enable	<='1';
					if(LA(4 downto 0)="11111") then
						STATE	<= END_CHK;
					else
						LD		<= RX_D;
						STATE	<= RX_DATA;
						if(cnt='0') then
							LA <= LA;
							cnt <= '1';
						else
							LA	<= LA + 1;
						end if;
					end if;
				when RX_LOG_RD =>
					w_enable	<='1';
					if(LA(4 downto 0)="11111") then
						STATE	<= END_CHK;
					else
						LD		<= RX_D;
						STATE	<= RX_LOG_RD;
						if(cnt='0') then
							LA <= LA;
							cnt <= '1';
						else
							LA		<= LA + 1;
						end if;
					end if;

				when END_CHK =>
					w_enable	<='0';
					RX_F	 	<= '0';
					if(RX_EMPTY='0') then
						RX_RDENB <= '1';
						STATE	 <= END_CHK;
						TX_START <= '0';
					else
						RX_RDENB <= '0';
						if(CMD_DATA="00000000") then
							TX_START <= '0';
							if(err_flg = '0') then
								if (rst_flg = '1') then
									LRSTb	<= '0';
									rst_flg   <= '0';
								else
									LRSTb	<='1';
									rst_flg   <= '1';
								end if;
							else
								LRSTb	<='1';
								rst_flg   <= rst_flg;
							end if;
							STATE	<= IDLE;
						elsif(CMD_DATA="00000110") then
							TX_START <= '0';
							if(err_flg = '0') then
								rst_flg   <= '0';
								LOAD	<= '1';
							else
								rst_flg <= rst_flg;
								LOAD	<= '0';
							end if;
							STATE	 <= IDLE;
						elsif(CMD_DATA="00000111") then
							TX_START <= '0';
							if(err_flg = '0') then
								rst_flg   <= '0';
								LATCH	<= '1';
							else
								rst_flg <= rst_flg;
								LATCH	<= '0';
							end if;
							STATE	 <= IDLE;
						else
							if(err_flg = '0') then
								rst_flg   <= '0';
							else
								rst_flg <= rst_flg;
							end if;
							TX_START <= '1';
							STATE	 <= IDLE;
						end if;
					end if;
					
				when END_CHK2 =>
					if(RX_EMPTY='0') then
						RX_RDENB <= '1';
						STATE	 <= END_CHK2;
					else
						RX_RDENB <= '0';
						STATE	<= IDLE;
					end if;
					
				when others =>



					rst_flg <= '0';
					slv_flg <= '0';
					RX_F		<= '0';
					RX_RDENB	<= '0';
					LA			<= (others=>'0');
					cnt			<= '0';
					LRSTb		<= '0';
					TX_START	<= '0';
					LOAD		<= '0';
					LATCH		<= '0';
					w_enable		<='0';
					ADR1		<= (others=>'0');
					ADR2		<= (others=>'0');
					NODE		<= (others=>'0');
					CMD_DATA	<= (others=>'0');
					wren_d		<= (others=>'0');
					BANK		<= (others=>'0');
					byte_cnt	<= (others=>'0');
					STATE		<= INIT;
			end case;
		end if;
	end process;


	process(LA, CLK1, w_enable, wren_d) begin
		case (LA) is
			when "00000"=> LWEb <= not(CLK1 and w_enable and wren_d(0))	;
			when "00001"=> LWEb <= not(CLK1 and w_enable and wren_d(1))	;
			when "00010"=> LWEb <= not(CLK1 and w_enable and wren_d(2))	;
			when "00011"=> LWEb <= not(CLK1 and w_enable and wren_d(3))	;
			when "00100"=> LWEb <= not(CLK1 and w_enable and wren_d(4))	;
			when "00101"=> LWEb <= not(CLK1 and w_enable and wren_d(5))	;
			when "00110"=> LWEb <= not(CLK1 and w_enable and wren_d(6))	;
			when "00111"=> LWEb <= not(CLK1 and w_enable and wren_d(7))	;
			when "01000"=> LWEb <= not(CLK1 and w_enable and wren_d(8))	;
			when "01001"=> LWEb <= not(CLK1 and w_enable and wren_d(9))	;
			when "01010"=> LWEb <= not(CLK1 and w_enable and wren_d(10));
			when "01011"=> LWEb <= not(CLK1 and w_enable and wren_d(11));
			when "01100"=> LWEb <= not(CLK1 and w_enable and wren_d(12));
			when "01101"=> LWEb <= not(CLK1 and w_enable and wren_d(13));
			when "01110"=> LWEb <= not(CLK1 and w_enable and wren_d(14));
			when "01111"=> LWEb <= not(CLK1 and w_enable and wren_d(15));
			when "10000"=> LWEb <= not(CLK1 and w_enable and wren_d(16));
			when "10001"=> LWEb <= not(CLK1 and w_enable and wren_d(17));
			when "10010"=> LWEb <= not(CLK1 and w_enable and wren_d(18));
			when "10011"=> LWEb <= not(CLK1 and w_enable and wren_d(19));
			when "10100"=> LWEb <= not(CLK1 and w_enable and wren_d(20));
			when "10101"=> LWEb <= not(CLK1 and w_enable and wren_d(21));
			when "10110"=> LWEb <= not(CLK1 and w_enable and wren_d(22));
			when "10111"=> LWEb <= not(CLK1 and w_enable and wren_d(23));
			when "11000"=> LWEb <= not(CLK1 and w_enable and wren_d(24));
			when "11001"=> LWEb <= not(CLK1 and w_enable and wren_d(25));
			when "11010"=> LWEb <= not(CLK1 and w_enable and wren_d(26));
			when "11011"=> LWEb <= not(CLK1 and w_enable and wren_d(27));
			when "11100"=> LWEb <= not(CLK1 and w_enable and wren_d(28));
			when "11101"=> LWEb <= not(CLK1 and w_enable and wren_d(29));
			when "11110"=> LWEb <= not(CLK1 and w_enable and wren_d(30));
			when "11111"=> LWEb <= not(CLK1 and w_enable and wren_d(31));
			when others => LWEb <= '1';
		end case;
	end process;

end RTL;
