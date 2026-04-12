-------------------------------------------------
--File Name : TEMP_ALM_TOP.vhd
--Project	: S124M(S3IO)
--Date		: 2026.02.09
--Ver		: 00_00
--Doc		: New Release
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------------------------entity----------------------------------------------------------------------
entity TEMP_ALM_TOP is
	Port (
		CLK			: in	std_logic;						-- クロック
		RSTb		: in	std_logic;						-- リセット（０＝リセット）
		CKEN1k		: in	std_logic;						-- 1msクロックイネーブル
		COOL_MODE	: in	std_logic;						-- １＝保冷モード
		TEMP_MEAS	: in	std_logic_vector(11 downto 0);	-- 温度測定値
		TEMP_REF	: in	std_logic_vector(11 downto 0);	-- 温度目標値
		TEMP_THRESH	: in	std_logic_vector(11 downto 0);	-- 温度逸脱と見なす差分値
		TEMP_ALM	: out	std_logic						-- 温度異常出力（１＝異常）
	);
end TEMP_ALM_TOP;

---------------architecture-------------------------------------------------------------------------
architecture RTL of TEMP_ALM_TOP is

-------------- constant ----------------------------------------------------------------------------
constant	c_AVG_DEPTH	: integer := 10;	-- 10回分（10分間）

---------------type---------------------------------------------------------------------------------
type	temp_array is array (c_AVG_DEPTH-1 downto 0) of unsigned(11 downto 0);

---------------signal-------------------------------------------------------------------------------
signal	s_cnt1min	: unsigned(15 downto 0)				:= (others => '0');				-- 1分クロックイネーブル用カウンタ
signal	s_CKEN1min	: std_logic							:= '0';							-- 1分クロックイネーブル

signal	s_temp_d	: temp_array						:= (others => (others => '0'));	-- 測定値10回分保存用
signal	s_sum		: unsigned(23 downto 0)				:= (others => '0');				-- 10回合計
signal	s_cnt		: integer range 0 to c_AVG_DEPTH	:= 0;							-- 初期化時のカウント

signal	s_sum_buf	: unsigned(23 downto 0)				:= (others => '0');				-- 合計値×205
signal	s_avg_temp	: unsigned(11 downto 0)				:= (others => '0');				-- 平均値

signal	s_alm		: std_logic							:= '0';							-- 温度異常アラーム
signal	s_diff		: unsigned(11 downto 0)				:= (others => '0');				-- 平均値と目標値の差

---------------component----------------------------------------------------------------------------

-------------------- begin -------------------------------------------------------------------------
begin
-- 1分クロックイネーブル
	process(CLK, RSTb)
	begin
		if RSTb = '0' then
			s_cnt1min <= (others => '0');
			s_CKEN1min <= '0';
		elsif rising_edge(CLK) then
			s_CKEN1min <= '0';
			if CKEN1k = '1' then
				if s_cnt1min = to_unsigned(59999, s_cnt1min'length) then
					s_cnt1min <= (others => '0');
					s_CKEN1min <= '1';
				else
					s_cnt1min <= s_cnt1min + 1;
				end if;
			end if;
		end if;
	end process;

-- 1分ごとにTEMP_MEASをシフトレジスタに格納し、合計値を更新
	process(CLK, RSTb)
	begin
		if RSTb = '0' then
			s_temp_d	<= (others => (others => '0'));
			s_sum	<= (others => '0');
			s_cnt	<= 0;
		elsif rising_edge(CLK) then
			if s_CKEN1min = '1' then
				-- 合計値から一番古い値を引き、新しい値を加える
				s_sum	<= s_sum + resize(unsigned(TEMP_MEAS), s_sum'length) - resize(s_temp_d(c_AVG_DEPTH-1), s_sum'length);

				-- シフトレジスタ
				s_temp_d(c_AVG_DEPTH-1 downto 1)	<= s_temp_d(c_AVG_DEPTH-2 downto 0);
				s_temp_d(0)	<= unsigned(TEMP_MEAS);

				if s_cnt < c_AVG_DEPTH then
					s_cnt	<= s_cnt + 1;
				end if;
			end if;
		end if;
	end process;

-- 10回平均値演算（205倍して11ビットシフト）
	-- 合計値×205倍
	s_sum_buf	<= (s_sum sll 8)		-- s_sum * 256
					- (s_sum sll 6)		-- s_sum * 64
					+ (s_sum sll 4)		-- s_sum * 16
					- (s_sum sll 2)		-- s_sum * 4
					+ s_sum;			-- s_sum * 1
	-- 205倍した合計値を2048で割る（11ビットシフト）
	s_avg_temp	<= s_sum_buf(22 downto 11); -- 12ビット分だけ使う

-- 測定値平均と目標値の差を計算
	s_diff	<= (s_avg_temp - unsigned(TEMP_REF)) when (s_avg_temp > unsigned(TEMP_REF)) else (unsigned(TEMP_REF) - s_avg_temp);

-- アラーム判定
	process(CLK, RSTb)
	begin
		if RSTb = '0' then
			s_alm	<= '0';
		elsif rising_edge(CLK) then
			if COOL_MODE = '1' then
				-- 10回分揃うまでは異常判定しない
				if ( (s_cnt = c_AVG_DEPTH) and (s_diff > unsigned(TEMP_THRESH)) ) or (s_alm = '1') then
					s_alm <= '1'; -- アラーム保持
				else
					s_alm <= '0';
				end if;
			else
				s_alm <= '0'; -- COOL_MODE=0でアラーム解除
			end if;
		end if;
	end process;

	TEMP_ALM <= s_alm;

end RTL;


