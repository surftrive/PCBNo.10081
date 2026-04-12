-------------------------------------------------
--File Name : log_ca_DACif_seq.vhd
--Project   : DAC_CONTROL IP
--
--Date      : 2009/03/18
--Ver       : 0.00
--Doc       : DAC081S101 Controller
--Designed by JUN.INAGAKI
-------------------------------------
--Date      :
--Ver       :
--Doc       :
--Changed by
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity log_ca_DACif_seq is
    port (
        CLK		: in std_logic;
        LRSTb	: in std_logic;
        TC		: in std_logic;
        SEND_TC	: in std_logic;
        PDATA	: in std_logic_vector(7 downto 0);
        SYNC	: out std_logic;
        DO		: out std_logic;
		IDLE	: out std_logic
    );
end log_ca_DACif_seq;

architecture RTL of log_ca_DACif_seq is

constant s0  : std_logic_vector(4 downto 0) := "00000"; --Wait until DA_SEND=1
constant s1  : std_logic_vector(4 downto 0) := "00001"; --Bit15 => X
constant s2  : std_logic_vector(4 downto 0) := "00011"; --Bit14 => X
constant s3  : std_logic_vector(4 downto 0) := "00010"; --Bit13 => PD(1)
constant s4  : std_logic_vector(4 downto 0) := "00110"; --Bit12 => PD(0)
constant s5  : std_logic_vector(4 downto 0) := "00111"; --Bit11 => P_D12(7)
constant s6  : std_logic_vector(4 downto 0) := "00101"; --Bit10 => P_D12(6)
constant s7  : std_logic_vector(4 downto 0) := "00100"; --Bit9  => P_D12(5)
constant s8  : std_logic_vector(4 downto 0) := "01100"; --Bit8  => P_D12(4)
constant s9  : std_logic_vector(4 downto 0) := "01101"; --Bit7  => P_D12(3)
constant s10 : std_logic_vector(4 downto 0) := "01111"; --Bit6  => P_D12(2)
constant s11 : std_logic_vector(4 downto 0) := "01110"; --Bit5  => P_D12(1)
constant s12 : std_logic_vector(4 downto 0) := "01010"; --Bit4  => P_D12(0)
constant s13 : std_logic_vector(4 downto 0) := "01011"; --Bit3  => X
constant s14 : std_logic_vector(4 downto 0) := "01001"; --Bit2  => X
constant s15 : std_logic_vector(4 downto 0) := "01000"; --Bit1  => X
constant s16 : std_logic_vector(4 downto 0) := "11000"; --Bit0  => X
constant s17 : std_logic_vector(4 downto 0) := "11001"; --Through

constant PD			: std_logic_vector(1 downto 0) := (others=>'0');  --Normal Operation mode

signal st			: std_logic_vector(4 downto 0);
signal s_SEND_DATA	: std_logic_vector(7 downto 0);

begin

    process (CLK, LRSTb) begin
        if (LRSTb = '0') then
            SYNC	<= '0';
            st		<= s0;
			IDLE	<= '0';
        elsif (CLK'event and CLK='1') then
            if (TC = '1') then
                case st is
                    when s0 =>
                        if ( SEND_TC='1' ) then		--Data Send Trigger
                            s_SEND_DATA <= PDATA;	--Get SEND_DATA
                            SYNC	<= '1';			--
                            DO		<= '0';				--Bit15
							IDLE	<= '0';
                            st		<= s1;
                        else
							SYNC	<= '0';
							DO		<= '0';
							IDLE	<= '1';
                            st		<= s0;
                        end if;
                    when s1 =>
						SYNC    <= '0';				--
						DO      <= '0';				--Bit15
						IDLE    <= '0';				--
						st      <= s2;				--
                    when s2 =>
						SYNC    <= '0';				--
						DO      <= '0';				--Bit14
						IDLE    <= '0';				--
						st      <= s3;				--
                    when s3 =>
						SYNC    <= '0';				--
						DO      <= PD(1);			--Bit13
						IDLE    <= '0';				--
						st      <= s4;				--
                    when s4 =>
						SYNC    <= '0';				--
						DO      <= PD(0);			--Bit12
						IDLE    <= '0';				--
						st      <= s5;				--
                    when s5 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(7);  --Bit11
						IDLE    <= '0';				--
						st      <= s6;				--
                    when s6 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(6);  --Bit10
						IDLE    <= '0';				--
						st      <= s7;				--
                    when s7 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(5);  --Bit9
						IDLE    <= '0';				--
						st      <= s8;				--
                    when s8 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(4);  --Bit8
						IDLE    <= '0';				--
						st      <= s9;				--
                    when s9 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(3);  --Bit7
						IDLE    <= '0';				--
						st      <= s10;				--
                    when s10 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(2);  --Bit6
						IDLE    <= '0';				--
						st      <= s11;				--
                    when s11 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(1);  --Bit5
						IDLE    <= '0';				--
						st      <= s12;				--
                    when s12 =>
						SYNC    <= '0';             --
						DO      <= s_SEND_DATA(0);  --Bit4
						IDLE    <= '0';				--
						st      <= s13;				--
                    when s13 =>
						SYNC    <= '0';             --
						DO      <= '0';				--Bit3
						IDLE    <= '0';				--
						st      <= s14;				--
                    when s14 =>
						SYNC    <= '0';             --
						DO      <= '0';				--Bit2
						IDLE    <= '0';				--
						st      <= s15;				--
                    when s15 =>
						SYNC    <= '0';             --
						DO      <= '0';				--Bit1
						IDLE    <= '0';				--
						st      <= s16;				--
                    when s16 =>
						SYNC    <= '0';             --
						DO      <= '0';				--Bit0
						IDLE    <= '0';				--
						st      <= s17;				--
                    when s17 =>
						SYNC    <= '0';             --
						DO      <= '0';				--
						IDLE    <= '1';				--
						st      <= s0;				--
                    when others =>
						SYNC    <= '0';				--
						DO      <= '0';				--
						IDLE    <= '1';				--
						st      <= s0;				--
                end case;
            end if;
        end if;
    end process;

end RTL;