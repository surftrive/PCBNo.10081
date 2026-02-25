-------------------------------------------------
--File Name : ppmc_pls_cnt.vhd
--Project   : S3IO
--
--Date      : 2002/10/11
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2010/02/22
--Ver       : 1.00
--Doc       : Added outside_slow
--Changed by Yuuki Takao
-------------------------------------------------
--Date      : 2021/07/28
--Ver       : 1.01
--Doc       : regにpulse_reg値をロードするタイミングをclk同期に変更
--Changed by Y.Aoki
-------------------------------------------------


library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_pls_cnt is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        pout        : in std_logic;
        pulse_reg   : in std_logic_vector(15 downto 0 );
        pre_reg     : in std_logic_vector(7 downto 0);
        pls_ld      : in std_logic;
        pulse_cnt   : out std_logic_vector(15 downto 0 );
        slow_reg    : in std_logic_vector(15 downto 0 );
        outside_slow: in std_logic;									--Added by Y.Takao
		speed		: in std_logic_vector(15 downto 0 );			--Added by Y.Takao
		low_reg		: in std_logic_vector(15 downto 0 );			--Added by Y.Takao
	    slow        : out std_logic;
        stop        : out std_logic;
        predrv_now  : out std_logic
        );
end ppmc_pls_cnt;


architecture RTL of ppmc_pls_cnt is

    signal reg : std_logic_vector(15 downto 0 );
    signal pre_pulse : std_logic_vector(7 downto 0);
    signal outside_slow_old : std_logic;
    signal s_slow : std_logic;
	signal o_slow : std_logic;

begin
    process ( rst, clk )
    begin     -- process
        if (rst = '1') then
            reg <= (others=>'0');
			      o_slow <= '0';
            outside_slow_old <= '0';
        elsif (clk'event and clk = '1') then
			     if(pls_ld = '1') then
              reg <= pulse_reg;
			        o_slow <= '0';
			     elsif (outside_slow = '1' and outside_slow_old = '0') then					--slow down
				      reg <= slow_reg;
				      o_slow <= '1';

			     elsif  (o_slow = '1' and s_slow = '1' and speed = low_reg) then			--stop
				      reg <= (others => '0');
				      o_slow <= '0';
			     elsif (pout = '1') then
	            reg <= reg -1;
				      o_slow <= o_slow;
			     else
				      reg <= reg;
				      o_slow <= o_slow;
			     end if;

			     outside_slow_old <= outside_slow;

		end if;
    end process;


    process(rst, clk, pls_ld)
    begin
        if rst = '1' then
            pre_pulse <= ( others => '0');
        elsif (pls_ld = '1') then
            pre_pulse <= ( others => '0');
        elsif (clk'event and clk='1') then
            if (pout = '1') then
                if (pre_pulse < pre_reg) then
                    pre_pulse <= pre_pulse + '1';
                else
                    pre_pulse <= pre_pulse;
                end if;
            else
                pre_pulse <= pre_pulse;
            end if;
        end if;
    end process;

    pulse_cnt <= reg;
    s_slow <= '1' when ( reg <= slow_reg and pls_ld='0' ) else '0';			--Changed by Y.Takao
      stop <= '1' when ( reg = 0         and pls_ld='0' ) else '0';
	    predrv_now <= '1' when (pre_pulse < pre_reg and pls_ld='0' ) else '0';
	  slow <= s_slow;											--Added by Y.Takao
end RTL;
