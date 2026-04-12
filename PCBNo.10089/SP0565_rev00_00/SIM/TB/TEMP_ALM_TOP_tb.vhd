library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_TEMP_ALM_TOP is
end TB_TEMP_ALM_TOP;

architecture SIM of TB_TEMP_ALM_TOP is

    -- DUTのポート宣言
    signal CLK         : std_logic := '0';
    signal RSTb        : std_logic := '0';
    signal CKEN1min    : std_logic := '0';
    signal COOL_MODE   : std_logic := '0';
    signal TEMP_MEAS   : std_logic_vector(11 downto 0) := (others => '0');
    signal TEMP_REF    : std_logic_vector(11 downto 0) := (others => '0');
    signal TEMP_THRESH : std_logic_vector(11 downto 0) := (others => '0');
    signal TEMP_ALM    : std_logic;

    -- CKEN1min生成用
    constant CLK_PERIOD : time := 50 ns; -- 20MHz
    constant CKEN1min_INTERVAL : time := 1 ms; -- 1msごとにパルス

begin

    -- DUTインスタンス
    DUT: entity work.TEMP_ALM_TOP
        port map (
            CLK         => CLK,
            RSTb        => RSTb,
            CKEN1min    => CKEN1min,
            COOL_MODE   => COOL_MODE,
            TEMP_MEAS   => TEMP_MEAS,
            TEMP_REF    => TEMP_REF,
            TEMP_THRESH => TEMP_THRESH,
            TEMP_ALM    => TEMP_ALM
        );

    -- 20MHzクロック生成
    CLK_GEN: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- CKEN1min生成（1msごとに1クロックだけ'1'）
    CKEN1MIN_GEN: process
    begin
        CKEN1min <= '0';
        wait for CKEN1min_INTERVAL - CLK_PERIOD;
        CKEN1min <= '1';
        wait for CLK_PERIOD;
    end process;

    -- テストシナリオ
    STIMULUS: process
    begin
        -- 初期化
        RSTb <= '0';
        COOL_MODE <= '0';
        TEMP_MEAS <= x"100"; -- 256
        TEMP_REF  <= x"100"; -- 256
        TEMP_THRESH <= x"010"; -- 16
        wait for 200 ns;

        -- リセット解除
        RSTb <= '1';
        wait for 500 ns;

        -- COOL_MODE ON
        COOL_MODE <= '1';

        -- 10回分データを入れる（1msごとにTEMP_MEASを変化させる）
        -- 最初は正常値
        for i in 0 to 9 loop
            TEMP_MEAS <= std_logic_vector(to_unsigned(256, 12)); -- 256
            wait for CKEN1min_INTERVAL;
        end loop;

        -- 以降、異常値を入れてアラーム発生を確認
        for i in 0 to 9 loop
            TEMP_MEAS <= std_logic_vector(to_unsigned(300, 12)); -- 300（異常値）
            wait for CKEN1min_INTERVAL;
        end loop;

        -- COOL_MODE OFFでアラーム解除
        COOL_MODE <= '0';
        wait for 2 ms;

        -- シミュレーション終了
        wait;
    end process;

end SIM;
