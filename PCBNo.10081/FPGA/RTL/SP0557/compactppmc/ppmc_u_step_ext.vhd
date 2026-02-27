------------------------------------------------------------
--File Name : ppmc_u_step_ext.vhd
--Project   : CA-NEXT Prototype(A) uStep addition
--
--Date      : 2004/10/26
--Ver       : 0.00
--Doc       : Correspondence model
--          : STK672-400(SANYO) or STK672-410(SANYO)
--          : [1/16step] is set to 1/2.
--Designed by Jun Inagaki
------------------------------------------------------------
--Date      :2005/09/15
--Ver       :5.00
--Doc       :Fixed the logic of POUT High Active
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
------------------------------------------------------------
--Date      :2025/01/15
--Ver       :6.00
--Doc       :M出力の変更、PCBNO.10080用
--Changed by Dai Chikayama
-------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
------------------------entity-------------------------------
entity ppmc_u_step_ext is
    port (
        CLK             : in    std_logic;
        nRST            : in    std_logic;
        SSEL            : in    std_logic;
        MSEL            : in    std_logic_vector(3 downto 1);
        INIT_REG_IN     : in    std_logic_vector(7 downto 0);  -- bits [7,5:0] unused; 8-bit register map bus width, only bit 6 used for mode select
        POUT_IN         : in    std_logic;
        M               : out   std_logic_vector(3 downto 1);
        POUT            : out   std_logic
    );
end ppmc_u_step_ext;
----------------------architecture---------------------------
architecture RTL of ppmc_u_step_ext is
---------------component-------------------------------------
---------------type------------------------------------------
---------------signal----------------------------------------
signal s_POUT           : std_logic;
---------------constant--------------------------------------
---------------begin-----------------------------------------
begin
    POUT <= s_POUT;
--================ MSEL to M ================================
    --------------process------------------------------------
    process(CLK,nRST) begin
        if (nRST = '0') then
            M <= (others => '0');
        elsif(CLK'event and CLK='1')then
            if (SSEL = '0') then
                if INIT_REG_IN(6) = '0' then
                                        -- STK672-400(uSTEP)        STK672-600			DRV8424
                    M <= "000";         -- UP     edge(2)           UP     edge(2)		2(100%)
                else
                    M <= "010";         -- UP     edge(1-2)         UP     edge(1-2)	1-2
                end if;
            else
                case MSEL is            --  u STK672-400            STK672-600			DRV8424
                when "000"=> M<="000";  -- UP     edge(2)           UP     edge(2)		2(100%)
                when "001"=> M<="001";  -- UP     edge(1-2)         UP     edge(1-2)	1-2(Non Cir)
                when "010"=> M<="010";  -- UP     edge(W1-2)        UP     edge(2)		1-2
                when "011"=> M<="011";  -- UP     edge(2W1-2)       UP     edge(1-2)	1/4
                when "100"=> M<="100";  -- UP     edge(2W1-2)       UP     edge(1-2)	1/8
                when "101"=> M<="101";  -- UP     edge(2W1-2)       UP     edge(1-2)	1/16	
                when others => M<="000";-- UP     edge(4W1-2)       UPDOWN edge(1-2)	2(100%)
                end case;
            end if;
        end if;
    end process;
--================ 'POUT 1/2',when MSEL(3).==================
    --------------process------------------------------------
    process(CLK,nRST) begin
        if (nRST = '0') then
            s_POUT <= '0';
        elsif(CLK'event and CLK='1')then
                s_POUT <= POUT_IN;
        end if;
    end process;
    --------------------------------------------------------------
end RTL;