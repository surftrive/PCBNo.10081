------------------------------------------------------------
--File Name : CTRL_32CH.vhd
--Project   : M207M
--
--Date      : 2022/05/30
--Ver       : 0.00
--Doc       : New Release
--Designed by RYO HASEGAWA
-------------------------------------
--Date		: 2022/12/09
--Ver		: 0.01
--Doc		: Initial value are changed to feed by generic
--Changed by
------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------

entity CTRL_32CH is
	generic (
		g_InitValue	: std_logic_vector( 7 downto 0 )	-- Initial value
			:= X"80"
	) ;
	port (
		CLK				: in	std_logic ;	-- 40MHz CLK
		LRSTb			: in	std_logic ;	-- Local Reset (active Low)

		--dataが入力される信号--
		DA_SEND_1CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_2CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_3CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_4CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_5CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_6CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_7CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_8CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_9CH		: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_10CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_11CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_12CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_13CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_14CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_15CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_16CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_17CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_18CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_19CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_20CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_21CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_22CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_23CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_24CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_25CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_26CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_27CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_28CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_29CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_30CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_31CH	: in	std_logic_vector( 7 downto 0 ) ;
		DA_SEND_32CH	: in	std_logic_vector( 7 downto 0 ) ;

		CH_SLAVE		: out	std_logic_vector( 4 downto 0 ) ;
		DATA			: out	std_logic_vector( 7 downto 0 ) ;	--データ出力--
		TRIGGER			: out	std_logic ;							--次のIPを動かすトリガ--
		COMP_FLAG		: in	std_logic							--送信完了フラグ--
	) ;
end CTRL_32CH ;

----------------------architecture---------------------------
architecture RTL of CTRL_32CH is
---------------component-------------------------------------
---------------type-------------------------------------------
type STATE is (
					IDLE,
					st_SEND,		--データを出力するステート--
					st_WAIT		--送信完了フラグを待つステート--
					);

---------------signal-----------------------------------------
signal s_state					: STATE;												--ステート--
--signal s_LATCH					: std_logic_vector(2 downto 0) := "000";	--データ変化の有無を示す信号--
signal s_LATCH					: std_logic_vector(31 downto 0) := (others =>'0');	--データ変化の有無を示す信号--

signal s_ch_slave				: std_logic_vector(4 downto 0);
signal s_data					: std_logic_vector(7 downto 0);		    --出力信号--

signal s_trigger				: std_logic;							--次のIPを動かすトリガ--

signal s_DA_SEND_1CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_2CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_3CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_4CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_5CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_6CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_7CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_8CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_9CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_10CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_11CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_12CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_13CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_14CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_15CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_16CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_17CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_18CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_19CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_20CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_21CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_22CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_23CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_24CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_25CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_26CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_27CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_28CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_29CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_30CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_31CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--
signal s_DA_SEND_32CH_ago	: std_logic_vector(7 downto 0);				--1クロック前の入力信号--

---------------begin------------------------------------------

begin

		CH_SLAVE <= s_ch_slave;
		DATA		<= s_data;
		trigger  <= s_trigger;

	--入力データをs_DA_SEND_1CH_agoに格納--

	--ラッチが0の時に入力信号をagoに格納する--
	process(CLK,LRSTb) begin
		if(LRSTb = '0') then
			s_DA_SEND_1CH_ago	<=	g_InitValue ;
			s_DA_SEND_2CH_ago	<=	g_InitValue ;
			s_DA_SEND_3CH_ago	<=	g_InitValue ;
			s_DA_SEND_4CH_ago	<=	g_InitValue ;
			s_DA_SEND_5CH_ago	<=	g_InitValue ;
			s_DA_SEND_6CH_ago	<=	g_InitValue ;
			s_DA_SEND_7CH_ago	<=	g_InitValue ;
			s_DA_SEND_8CH_ago	<=	g_InitValue ;
			s_DA_SEND_9CH_ago	<=	g_InitValue ;
			s_DA_SEND_10CH_ago	<=	g_InitValue ;
			s_DA_SEND_11CH_ago	<=	g_InitValue ;
			s_DA_SEND_12CH_ago	<=	g_InitValue ;
			s_DA_SEND_13CH_ago	<=	g_InitValue ;
			s_DA_SEND_14CH_ago	<=	g_InitValue ;
			s_DA_SEND_15CH_ago	<=	g_InitValue ;
			s_DA_SEND_16CH_ago	<=	g_InitValue ;
			s_DA_SEND_17CH_ago	<=	g_InitValue ;
			s_DA_SEND_18CH_ago	<=	g_InitValue ;
			s_DA_SEND_19CH_ago	<=	g_InitValue ;
			s_DA_SEND_20CH_ago	<=	g_InitValue ;
			s_DA_SEND_21CH_ago	<=	g_InitValue ;
			s_DA_SEND_22CH_ago	<=	g_InitValue ;
			s_DA_SEND_23CH_ago	<=	g_InitValue ;
			s_DA_SEND_24CH_ago	<=	g_InitValue ;
			s_DA_SEND_25CH_ago	<=	g_InitValue ;
			s_DA_SEND_26CH_ago	<=	g_InitValue ;
			s_DA_SEND_27CH_ago	<=	g_InitValue ;
			s_DA_SEND_28CH_ago	<=	g_InitValue ;
			s_DA_SEND_29CH_ago	<=	g_InitValue ;
			s_DA_SEND_30CH_ago	<=	g_InitValue ;
			s_DA_SEND_31CH_ago	<=	g_InitValue ;
			s_DA_SEND_32CH_ago	<=	g_InitValue ;


		elsif(CLK'event and CLK='1')then

			if(s_LATCH(0) = '0') then
				s_DA_SEND_1CH_ago <= DA_SEND_1CH;
			else
				s_DA_SEND_1CH_ago <= s_DA_SEND_1CH_ago;
			end if;

			if(s_LATCH(1) = '0') then
				s_DA_SEND_2CH_ago <= DA_SEND_2CH;
			else
				s_DA_SEND_2CH_ago <= s_DA_SEND_2CH_ago;
			end if;

			if(s_LATCH(2) = '0') then
				s_DA_SEND_3CH_ago <= DA_SEND_3CH;
			else
				s_DA_SEND_3CH_ago <= s_DA_SEND_3CH_ago;
			end if;

			if(s_LATCH(3) = '0') then
				s_DA_SEND_4CH_ago <= DA_SEND_4CH;
			else
				s_DA_SEND_4CH_ago <= s_DA_SEND_4CH_ago;
			end if;

			if(s_LATCH(4) = '0') then
				s_DA_SEND_5CH_ago <= DA_SEND_5CH;
			else
				s_DA_SEND_5CH_ago <= s_DA_SEND_5CH_ago;
			end if;

			if(s_LATCH(5) = '0') then
				s_DA_SEND_6CH_ago <= DA_SEND_6CH;
			else
				s_DA_SEND_6CH_ago <= s_DA_SEND_6CH_ago;
			end if;

			if(s_LATCH(6) = '0') then
				s_DA_SEND_7CH_ago <= DA_SEND_7CH;
			else
				s_DA_SEND_7CH_ago <= s_DA_SEND_7CH_ago;
			end if;

			if(s_LATCH(7) = '0') then
				s_DA_SEND_8CH_ago <= DA_SEND_8CH;
			else
				s_DA_SEND_8CH_ago <= s_DA_SEND_8CH_ago;
			end if;

			if(s_LATCH(8) = '0') then
				s_DA_SEND_9CH_ago <= DA_SEND_9CH;
			else
				s_DA_SEND_9CH_ago <= s_DA_SEND_9CH_ago;
			end if;

			if(s_LATCH(9) = '0') then
				s_DA_SEND_10CH_ago <= DA_SEND_10CH;
			else
				s_DA_SEND_10CH_ago <= s_DA_SEND_10CH_ago;
			end if;

			if(s_LATCH(10) = '0') then
				s_DA_SEND_11CH_ago <= DA_SEND_11CH;
			else
				s_DA_SEND_11CH_ago <= s_DA_SEND_11CH_ago;
			end if;

			if(s_LATCH(11) = '0') then
				s_DA_SEND_12CH_ago <= DA_SEND_12CH;
			else
				s_DA_SEND_12CH_ago <= s_DA_SEND_12CH_ago;
			end if;

			if(s_LATCH(12) = '0') then
				s_DA_SEND_13CH_ago <= DA_SEND_13CH;
			else
				s_DA_SEND_13CH_ago <= s_DA_SEND_13CH_ago;
			end if;

			if(s_LATCH(13) = '0') then
				s_DA_SEND_14CH_ago <= DA_SEND_14CH;
			else
				s_DA_SEND_14CH_ago <= s_DA_SEND_14CH_ago;
			end if;

			if(s_LATCH(14) = '0') then
				s_DA_SEND_15CH_ago <= DA_SEND_15CH;
			else
				s_DA_SEND_15CH_ago <= s_DA_SEND_15CH_ago;
			end if;

			if(s_LATCH(15) = '0') then
				s_DA_SEND_16CH_ago <= DA_SEND_16CH;
			else
				s_DA_SEND_16CH_ago <= s_DA_SEND_16CH_ago;
			end if;

			if(s_LATCH(16) = '0') then
				s_DA_SEND_17CH_ago <= DA_SEND_17CH;
			else
				s_DA_SEND_17CH_ago <= s_DA_SEND_17CH_ago;
			end if;

			if(s_LATCH(17) = '0') then
				s_DA_SEND_18CH_ago <= DA_SEND_18CH;
			else
				s_DA_SEND_18CH_ago <= s_DA_SEND_18CH_ago;
			end if;

			if(s_LATCH(18) = '0') then
				s_DA_SEND_19CH_ago <= DA_SEND_19CH;
			else
				s_DA_SEND_19CH_ago <= s_DA_SEND_19CH_ago;
			end if;

			if(s_LATCH(19) = '0') then
				s_DA_SEND_20CH_ago <= DA_SEND_20CH;
			else
				s_DA_SEND_20CH_ago <= s_DA_SEND_20CH_ago;
			end if;

			if(s_LATCH(20) = '0') then
				s_DA_SEND_21CH_ago <= DA_SEND_21CH;
			else
				s_DA_SEND_21CH_ago <= s_DA_SEND_21CH_ago;
			end if;

			if(s_LATCH(21) = '0') then
				s_DA_SEND_22CH_ago <= DA_SEND_22CH;
			else
				s_DA_SEND_22CH_ago <= s_DA_SEND_22CH_ago;
			end if;

			if(s_LATCH(22) = '0') then
				s_DA_SEND_23CH_ago <= DA_SEND_23CH;
			else
				s_DA_SEND_23CH_ago <= s_DA_SEND_23CH_ago;
			end if;

			if(s_LATCH(23) = '0') then
				s_DA_SEND_24CH_ago <= DA_SEND_24CH;
			else
				s_DA_SEND_24CH_ago <= s_DA_SEND_24CH_ago;
			end if;

			if(s_LATCH(24) = '0') then
				s_DA_SEND_25CH_ago <= DA_SEND_25CH;
			else
				s_DA_SEND_25CH_ago <= s_DA_SEND_25CH_ago;
			end if;

			if(s_LATCH(25) = '0') then
				s_DA_SEND_26CH_ago <= DA_SEND_26CH;
			else
				s_DA_SEND_26CH_ago <= s_DA_SEND_26CH_ago;
			end if;

			if(s_LATCH(26) = '0') then
				s_DA_SEND_27CH_ago <= DA_SEND_27CH;
			else
				s_DA_SEND_27CH_ago <= s_DA_SEND_27CH_ago;
			end if;

			if(s_LATCH(27) = '0') then
				s_DA_SEND_28CH_ago <= DA_SEND_28CH;
			else
				s_DA_SEND_28CH_ago <= s_DA_SEND_28CH_ago;
			end if;

			if(s_LATCH(28) = '0') then
				s_DA_SEND_29CH_ago <= DA_SEND_29CH;
			else
				s_DA_SEND_29CH_ago <= s_DA_SEND_29CH_ago;
			end if;

			if(s_LATCH(29) = '0') then
				s_DA_SEND_30CH_ago <= DA_SEND_30CH;
			else
				s_DA_SEND_30CH_ago <= s_DA_SEND_30CH_ago;
			end if;

			if(s_LATCH(30) = '0') then
				s_DA_SEND_31CH_ago <= DA_SEND_31CH;
			else
				s_DA_SEND_31CH_ago <= s_DA_SEND_31CH_ago;
			end if;

			if(s_LATCH(31) = '0') then
				s_DA_SEND_32CH_ago <= DA_SEND_32CH;
			else
				s_DA_SEND_32CH_ago <= s_DA_SEND_32CH_ago;
			end if;

		end if;
	end process;

	--ラッチ信号を生成する部分--
	--入力データと1クロック前の信号を比較--
	process(CLK) begin

		if (CLK'event and CLK='1') then
			if(s_DA_SEND_1CH_ago /= DA_SEND_1CH and COMP_FLAG = '0') then
				s_LATCH(0) <= '1';
			end if;

			if(s_DA_SEND_2CH_ago /= DA_SEND_2CH and COMP_FLAG = '0') then
				s_LATCH(1) <= '1';
			end if;

			if(s_DA_SEND_3CH_ago /= DA_SEND_3CH and COMP_FLAG = '0') then
				s_LATCH(2) <= '1';
			end if;

			if(s_DA_SEND_4CH_ago /= DA_SEND_4CH and COMP_FLAG = '0') then
				s_LATCH(3) <= '1';
			end if;

			if(s_DA_SEND_5CH_ago /= DA_SEND_5CH and COMP_FLAG = '0') then
				s_LATCH(4) <= '1';
			end if;

			if(s_DA_SEND_6CH_ago /= DA_SEND_6CH and COMP_FLAG = '0') then
				s_LATCH(5) <= '1';
			end if;

			if(s_DA_SEND_7CH_ago /= DA_SEND_7CH and COMP_FLAG = '0') then
				s_LATCH(6) <= '1';
			end if;

			if(s_DA_SEND_8CH_ago /= DA_SEND_8CH and COMP_FLAG = '0') then
				s_LATCH(7) <= '1';
			end if;

			if(s_DA_SEND_9CH_ago /= DA_SEND_9CH and COMP_FLAG = '0') then
				s_LATCH(8) <= '1';
			end if;

			if(s_DA_SEND_10CH_ago /= DA_SEND_10CH and COMP_FLAG = '0') then
				s_LATCH(9) <= '1';
			end if;

			if(s_DA_SEND_11CH_ago /= DA_SEND_11CH and COMP_FLAG = '0') then
				s_LATCH(10) <= '1';
			end if;

			if(s_DA_SEND_12CH_ago /= DA_SEND_12CH and COMP_FLAG = '0') then
				s_LATCH(11) <= '1';
			end if;

			if(s_DA_SEND_13CH_ago /= DA_SEND_13CH and COMP_FLAG = '0') then
				s_LATCH(12) <= '1';
			end if;

			if(s_DA_SEND_14CH_ago /= DA_SEND_14CH and COMP_FLAG = '0') then
				s_LATCH(13) <= '1';
			end if;

			if(s_DA_SEND_15CH_ago /= DA_SEND_15CH and COMP_FLAG = '0') then
				s_LATCH(14) <= '1';
			end if;

			if(s_DA_SEND_16CH_ago /= DA_SEND_16CH and COMP_FLAG = '0') then
				s_LATCH(15) <= '1';
			end if;

			if(s_DA_SEND_17CH_ago /= DA_SEND_17CH and COMP_FLAG = '0') then
				s_LATCH(16) <= '1';
			end if;

			if(s_DA_SEND_18CH_ago /= DA_SEND_18CH and COMP_FLAG = '0') then
				s_LATCH(17) <= '1';
			end if;

			if(s_DA_SEND_19CH_ago /= DA_SEND_19CH and COMP_FLAG = '0') then
				s_LATCH(18) <= '1';
			end if;

			if(s_DA_SEND_20CH_ago /= DA_SEND_20CH and COMP_FLAG = '0') then
				s_LATCH(19) <= '1';
			end if;

			if(s_DA_SEND_21CH_ago /= DA_SEND_21CH and COMP_FLAG = '0') then
				s_LATCH(20) <= '1';
			end if;

			if(s_DA_SEND_22CH_ago /= DA_SEND_22CH and COMP_FLAG = '0') then
				s_LATCH(21) <= '1';
			end if;

			if(s_DA_SEND_23CH_ago /= DA_SEND_23CH and COMP_FLAG = '0') then
				s_LATCH(22) <= '1';
			end if;

			if(s_DA_SEND_24CH_ago /= DA_SEND_24CH and COMP_FLAG = '0') then
				s_LATCH(23) <= '1';
			end if;

			if(s_DA_SEND_25CH_ago /= DA_SEND_25CH and COMP_FLAG = '0') then
				s_LATCH(24) <= '1';
			end if;

			if(s_DA_SEND_26CH_ago /= DA_SEND_26CH and COMP_FLAG = '0') then
				s_LATCH(25) <= '1';
			end if;

			if(s_DA_SEND_27CH_ago /= DA_SEND_27CH and COMP_FLAG = '0') then
				s_LATCH(26) <= '1';
			end if;

			if(s_DA_SEND_28CH_ago /= DA_SEND_28CH and COMP_FLAG = '0') then
				s_LATCH(27) <= '1';
			end if;

			if(s_DA_SEND_29CH_ago /= DA_SEND_29CH and COMP_FLAG = '0') then
				s_LATCH(28) <= '1';
			end if;

			if(s_DA_SEND_30CH_ago /= DA_SEND_30CH and COMP_FLAG = '0') then
				s_LATCH(29) <= '1';
			end if;

			if(s_DA_SEND_31CH_ago /= DA_SEND_31CH and COMP_FLAG = '0') then
				s_LATCH(30) <= '1';
			end if;

			if(s_DA_SEND_32CH_ago /= DA_SEND_32CH and COMP_FLAG = '0') then
				s_LATCH(31) <= '1';
			end if;


			if(COMP_FLAG = '1') then
				case s_ch_slave is
					when "00000" => s_LATCH <= s_LATCH(31 downto 1 ) & '0';
					when "00100" => s_LATCH <= s_LATCH(31 downto 2 ) & '0' & s_LATCH(0);
					when "01000" => s_LATCH <= s_LATCH(31 downto 3 ) & '0' & s_LATCH(1  downto 0);
					when "01100" => s_LATCH <= s_LATCH(31 downto 4 ) & '0' & s_LATCH(2  downto 0);
					when "10000" => s_LATCH <= s_LATCH(31 downto 5 ) & '0' & s_LATCH(3  downto 0);
					when "10100" => s_LATCH <= s_LATCH(31 downto 6 ) & '0' & s_LATCH(4  downto 0);
					when "11000" => s_LATCH <= s_LATCH(31 downto 7 ) & '0' & s_LATCH(5  downto 0);
					when "11100" => s_LATCH <= s_LATCH(31 downto 8 ) & '0' & s_LATCH(6  downto 0);
					when "00001" => s_LATCH <= s_LATCH(31 downto 9 ) & '0' & s_LATCH(7  downto 0);
					when "00101" => s_LATCH <= s_LATCH(31 downto 10) & '0' & s_LATCH(8  downto 0);
					when "01001" => s_LATCH <= s_LATCH(31 downto 11) & '0' & s_LATCH(9  downto 0);
					when "01101" => s_LATCH <= s_LATCH(31 downto 12) & '0' & s_LATCH(10 downto 0);
					when "10001" => s_LATCH <= s_LATCH(31 downto 13) & '0' & s_LATCH(11 downto 0);
					when "10101" => s_LATCH <= s_LATCH(31 downto 14) & '0' & s_LATCH(12 downto 0);
					when "11001" => s_LATCH <= s_LATCH(31 downto 15) & '0' & s_LATCH(13 downto 0);
					when "11101" => s_LATCH <= s_LATCH(31 downto 16) & '0' & s_LATCH(14 downto 0);
					when "00010" => s_LATCH <= s_LATCH(31 downto 17) & '0' & s_LATCH(15 downto 0);
					when "00110" => s_LATCH <= s_LATCH(31 downto 18) & '0' & s_LATCH(16 downto 0);
					when "01010" => s_LATCH <= s_LATCH(31 downto 19) & '0' & s_LATCH(17 downto 0);
					when "01110" => s_LATCH <= s_LATCH(31 downto 20) & '0' & s_LATCH(18 downto 0);
					when "10010" => s_LATCH <= s_LATCH(31 downto 21) & '0' & s_LATCH(19 downto 0);
					when "10110" => s_LATCH <= s_LATCH(31 downto 22) & '0' & s_LATCH(20 downto 0);
					when "11010" => s_LATCH <= s_LATCH(31 downto 23) & '0' & s_LATCH(21 downto 0);
					when "11110" => s_LATCH <= s_LATCH(31 downto 24) & '0' & s_LATCH(22 downto 0);
					when "00011" => s_LATCH <= s_LATCH(31 downto 25) & '0' & s_LATCH(23 downto 0);
					when "00111" => s_LATCH <= s_LATCH(31 downto 26) & '0' & s_LATCH(24 downto 0);
					when "01011" => s_LATCH <= s_LATCH(31 downto 27) & '0' & s_LATCH(25 downto 0);
					when "01111" => s_LATCH <= s_LATCH(31 downto 28) & '0' & s_LATCH(26 downto 0);
					when "10011" => s_LATCH <= s_LATCH(31 downto 29) & '0' & s_LATCH(27 downto 0);
					when "10111" => s_LATCH <= s_LATCH(31 downto 30) & '0' & s_LATCH(28 downto 0);
					when "11011" => s_LATCH <= s_LATCH(31)			 & '0' & s_LATCH(29 downto 0);
					when "11111" => s_LATCH <= 						   '0' & s_LATCH(30 downto 0);


					when others  => s_LATCH <= s_LATCH;
				end case;
			end if;

		end if;
	end process;

---------------process------------------------------------------
	process (CLK,LRSTb) begin
		if (LRSTb = '0') then
			s_state <= IDLE;
			s_ch_slave <= (others => '0');
			s_data 	  <= (others => '0');
			s_trigger <= '0';

		elsif (CLK'event and CLK='1') then

				case s_state is

				when IDLE =>
							s_ch_slave <= (others => '0');
							s_data 	   <= (others => '0');
							s_trigger  <= '0';

					 if(s_LATCH = "00000000000000000000000000000000") then
							s_state    <= IDLE;
					 else
							s_state    <= st_SEND;

					 end if;


				when st_SEND =>

						--CH1の入力信号が変化した時--
					 if(s_LATCH(0) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00000";
							s_data 	  <= DA_SEND_1CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(1) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00100";
							s_data 	  <= DA_SEND_2CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(2) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01000";
							s_data 	  <= DA_SEND_3CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(3) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01100";
							s_data 	  <= DA_SEND_4CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(4) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10000";
							s_data 	  <= DA_SEND_5CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(5) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10100";
							s_data 	  <= DA_SEND_6CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(6) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11000";
							s_data 	  <= DA_SEND_7CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(7) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11100";
							s_data 	  <= DA_SEND_8CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(8) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00001";
							s_data 	  <= DA_SEND_9CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(9) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00101";
							s_data 	  <= DA_SEND_10CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(10) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01001";
							s_data 	  <= DA_SEND_11CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(11) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01101";
							s_data 	  <= DA_SEND_12CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(12) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10001";
							s_data 	  <= DA_SEND_13CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(13) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10101";
							s_data 	  <= DA_SEND_14CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(14) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11001";
							s_data 	  <= DA_SEND_15CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(15) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11101";
							s_data 	  <= DA_SEND_16CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(16) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00010";
							s_data 	  <= DA_SEND_17CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(17) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00110";
							s_data 	  <= DA_SEND_18CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(18) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01010";
							s_data 	  <= DA_SEND_19CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(19) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01110";
							s_data 	  <= DA_SEND_20CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(20) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10010";
							s_data 	  <= DA_SEND_21CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(21) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10110";
							s_data 	  <= DA_SEND_22CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(22) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11010";
							s_data 	  <= DA_SEND_23CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(23) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11110";
							s_data 	  <= DA_SEND_24CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(24) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00011";
							s_data 	  <= DA_SEND_25CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(25) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "00111";
							s_data 	  <= DA_SEND_26CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(26) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01011";
							s_data 	  <= DA_SEND_27CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(27) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "01111";
							s_data 	  <= DA_SEND_28CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(28) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10011";
							s_data 	  <= DA_SEND_29CH;
							s_trigger <= '1';

						--CH3の入力信号が変化した時--
					 elsif(s_LATCH(29) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "10111";
							s_data 	  <= DA_SEND_30CH;
							s_trigger <= '1';

						--CH1の入力信号が変化した時--
					 elsif(s_LATCH(30) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11011";
							s_data 	  <= DA_SEND_31CH;
							s_trigger <= '1';

						--CH2の入力信号が変化した時--
					 elsif(s_LATCH(31) = '1') then
							s_state <= st_WAIT;
							s_ch_slave <= "11111";
							s_data 	  <= DA_SEND_32CH;
							s_trigger <= '1';

                end if;

				when st_WAIT =>

						--送信完了フラグがかえってきていないとき--
					if(COMP_FLAG = '0') then
						s_state 	<= st_WAIT;
						s_ch_slave 	<= s_ch_slave;
						s_data		<= s_data;
						s_trigger   <= '0';

						--送信完了フラグがかえってきたとき--
					else
						s_state 	<= IDLE;
						s_ch_slave 	<= (others => '0');
						s_data		<= (others => '0');
						s_trigger   <= '0';

					end if;

				when others  =>
						s_state			<= IDLE;

			end case;
		end if;
	end process;
end RTL;



