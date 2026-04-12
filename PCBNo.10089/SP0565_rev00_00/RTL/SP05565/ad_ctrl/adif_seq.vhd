-------------------------------------------------
--File Name : adif_seq.vhd
--Project	: S127M
--
--Date		: 2025/10/28
--Ver		: 0.00
--Doc		: ADC128S022 Controller
--Designed by Nobuhisa Hatashima(PHR)
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adif_seq is
	port (
		CLK		: in	std_logic;
		LRSTb	: in	std_logic;
		FALL	: in	std_logic;
		ADCSb	: out	std_logic;
		ADDI	: out	std_logic;
		RDEN	: out	std_logic;
		WREN	: out	std_logic;
		CH		: out	std_logic_vector(2 downto 0)
	);
end adif_seq;

architecture RTL of adif_seq is

constant	s0	: std_logic_vector(4 downto 0)	:= "00000";
constant	s1	: std_logic_vector(4 downto 0)	:= "00001"; --Wait until ADCSb='0' Dummy1
constant	s2	: std_logic_vector(4 downto 0)	:= "00010"; --Dummy2
constant	s3	: std_logic_vector(4 downto 0)	:= "00011"; --ADD2(s_next_CH(2))
constant	s4	: std_logic_vector(4 downto 0)	:= "00100"; --ADD1(s_next_CH(1))
constant	s5	: std_logic_vector(4 downto 0)	:= "00101"; --ADD0(s_next_CH(0)) & RDEN <= '1' & Bit11
constant	s6	: std_logic_vector(4 downto 0)	:= "00110"; --Bit10 & ADDI <= '0'
constant	s7	: std_logic_vector(4 downto 0)	:= "00111"; --Bit9
constant	s8	: std_logic_vector(4 downto 0)	:= "01000"; --Bit8
constant	s9	: std_logic_vector(4 downto 0)	:= "01001"; --Bit7
constant	s10	: std_logic_vector(4 downto 0)	:= "01010"; --Bit6
constant	s11	: std_logic_vector(4 downto 0)	:= "01011"; --Bit5
constant	s12	: std_logic_vector(4 downto 0)	:= "01100"; --Bit4
constant	s13	: std_logic_vector(4 downto 0)	:= "01101"; --Bit3
constant	s14	: std_logic_vector(4 downto 0)	:= "01110"; --Bit2
constant	s15	: std_logic_vector(4 downto 0)	:= "01111"; --Bit1
constant	s16	: std_logic_vector(4 downto 0)	:= "10000"; --Bit0
constant	s17	: std_logic_vector(4 downto 0)	:= "10001"; --Wait until RDEN <= '0' ADCSb <= '1'
constant	s18	: std_logic_vector(4 downto 0)	:= "10010"; --Wait until WREN <= '1'
constant	s19	: std_logic_vector(4 downto 0)	:= "10011"; --Wait until WREN <= '0' & s_CH Counter

signal		st			: std_logic_vector(4 downto 0);
signal		s_CH		: std_logic_vector(2 downto 0);
signal		s_next_CH	: std_logic_vector(2 downto 0);

begin
	CH <= s_CH;
	s_next_CH <= s_CH + "001";

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
		 ADCSb <= '1';
			ADDI <= '0';
			WREN <= '0';
			RDEN <= '0';
		 s_CH <= "000";
			st <= s0;
		elsif (CLK'event and CLK='1') then
			if (FALL = '1') then
				case st is
					when s0 =>
						ADCSb	<= '1';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st 		<= s1;
					when s1 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s2;
					when s2 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s3;
					when s3 =>
						ADCSb	<= '0';
						ADDI	<= s_next_CH(2);
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s4;
					when s4 =>
						ADCSb	<= '0';
						ADDI	<= s_next_CH(1);
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s5;
					when s5 =>
						ADCSb	<= '0';
						ADDI	<= s_next_CH(0);
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s6;
					when s6 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s7;
					when s7 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s8;
					when s8 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s9;
					when s9 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s10;
					when s10 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s11;
					when s11 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s12;
					when s12 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s13;
					when s13 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s14;
					when s14 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s15;
					when s15 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s16;
					when s16 =>
						ADCSb	<= '0';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '1';
						s_CH	<= s_CH;
						st		<= s17;
					when s17 =>
						ADCSb	<= '1';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s18;
					when s18 =>
						ADCSb	<= '1';
						ADDI	<= '0';
						WREN	<= '1';
						RDEN	<= '0';
						s_CH	<= s_CH;
						st		<= s19;
					when s19 =>
						ADCSb	<= '1';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= s_CH + "001";
						st		<= s0;
					when others	=>
						ADCSb	<= '1';
						ADDI	<= '0';
						WREN	<= '0';
						RDEN	<= '0';
						s_CH	<= "000";
						st		<= s0;
				end case;
			end if;
		end if;
	end process;
end RTL;

