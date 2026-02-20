-------------------------------------------------
--File Name : ppmc_speed_cnt.vhd
--Project   : S3IO
--
--Date      : 2002/10/11
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2004/03/02
--Ver       : 1.00
--Doc       : Initial SPEED changed HF to LF when STOP => ACC
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date      : 2025/12/17
--Ver       : 2.00
--Doc       : êMçÜíxâÑëŒçÙÇÃà◊ÅAWAIT_DOWN_ST/WAIT_UP_STÇí«â¡
--Changed by Nobuhisa Hatashima(PHR)
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_speed_cnt is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        acc_pulse   : in std_logic;
        high_reg    : in std_logic_vector(15 downto 0 );
        low_reg     : in std_logic_vector(15 downto 0 );
        up_down     : in std_logic;
        start_stop  : in std_logic;
        predrv_now  : in std_logic;

        speed       : out std_logic_vector(15 downto 0 );
        tm_clr      : out std_logic
        );

end ppmc_speed_cnt;


architecture RTL of ppmc_speed_cnt is

    signal reg : std_logic_vector(15 downto 0 );

    type visual_STOP_ST_states is (STOP_ST, WAIT_DOWN_ST, DOWN_ST, WAIT_UP_ST, UP_ST);
    signal visual_STOP_ST_current : visual_STOP_ST_states;


begin

  -- Synchronous process
    ppmc_speed_cnt_STOP_ST:
    process (clk, rst)
    begin
        if (rst = '1') then
            reg <=(others =>'0');
            tm_clr <= '1';
            visual_STOP_ST_current <= STOP_ST;
        elsif (clk'event and clk = '1') then
            case visual_STOP_ST_current is
                when STOP_ST =>
                    if (start_stop = '1' and up_down = '1') then
--                        reg <= low_reg;
--                        tm_clr <= '0';
                        visual_STOP_ST_current <= WAIT_UP_ST;
                    elsif (start_stop = '1' and up_down = '0') then
--                      reg <= high_reg;
--                        reg <= low_reg;     -- toku chng 2004.03.02
--                        tm_clr <= '0';
                        visual_STOP_ST_current <= WAIT_DOWN_ST;
                    else
                        visual_STOP_ST_current <= STOP_ST;
                    end if;

                when WAIT_DOWN_ST =>
                    if low_reg = x"0000" then
                        visual_STOP_ST_current <= WAIT_DOWN_ST;
                    else
                        reg <= low_reg;
                        tm_clr <= '0';
                        visual_STOP_ST_current <= DOWN_ST;
                    end if;

                when DOWN_ST =>
                    if (start_stop = '0') then
                        reg <=(others =>'0');
                        tm_clr <= '1';
                        visual_STOP_ST_current <= STOP_ST;
                    elsif (up_down = '1') then
                        visual_STOP_ST_current <= UP_ST;
                    elsif (acc_pulse = '1' and reg > low_reg) then
                        reg <= reg -'1';
                        visual_STOP_ST_current <= DOWN_ST;
                    else
                        visual_STOP_ST_current <= DOWN_ST;
                    end if;

                when WAIT_UP_ST =>
                    if low_reg = x"0000" then
                        visual_STOP_ST_current <= WAIT_UP_ST;
                    else
                        reg <= low_reg;
                        tm_clr <= '0';
                        visual_STOP_ST_current <= UP_ST;
                    end if;

                when UP_ST =>
                    if (start_stop = '0') then
                        reg <=(others =>'0');
                        tm_clr <= '1';
                        visual_STOP_ST_current <= STOP_ST;
                    elsif (up_down = '0') then
                        visual_STOP_ST_current <= DOWN_ST;
                    elsif (predrv_now = '1') then
                        visual_STOP_ST_current <= UP_ST;
                    elsif (acc_pulse = '1' and reg < high_reg) then
                        reg <= reg +'1';
                        visual_STOP_ST_current <= UP_ST;
                    else
                        visual_STOP_ST_current <= UP_ST;
                    end if;

                when others =>
                    reg <=(others =>'0');
                    tm_clr <= '1';
                    visual_STOP_ST_current <= STOP_ST;
            end case;
        end if;
    end process;

    speed <= reg;

end RTL;
