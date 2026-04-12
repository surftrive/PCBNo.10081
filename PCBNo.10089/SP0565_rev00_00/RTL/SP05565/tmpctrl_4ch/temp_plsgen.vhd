-------------------------------------------------
--File Name : temp_plsgen.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity temp_plsgen is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 PLS :out std_logic_vector(7 downto 0);
			 TERM :out std_logic);
end temp_plsgen;

architecture RTL of temp_plsgen is

constant da : std_logic_vector(7 downto 0) := "11111111";
constant db : std_logic_vector(7 downto 0) := "11111110";
constant dc : std_logic_vector(7 downto 0) := "11111100";
constant dd : std_logic_vector(7 downto 0) := "11111000";
constant de : std_logic_vector(7 downto 0) := "11110000";
constant df : std_logic_vector(7 downto 0) := "11100000";
constant dg : std_logic_vector(7 downto 0) := "11000000";
constant dh : std_logic_vector(7 downto 0) := "10000000";

constant sa : std_logic_vector(2 downto 0) := "000";
constant sb : std_logic_vector(2 downto 0) := "001";
constant sc : std_logic_vector(2 downto 0) := "011";
constant sd : std_logic_vector(2 downto 0) := "010";
constant se : std_logic_vector(2 downto 0) := "110";
constant sf : std_logic_vector(2 downto 0) := "111";
constant sg : std_logic_vector(2 downto 0) := "101";
constant sh : std_logic_vector(2 downto 0) := "100";

signal st : std_logic_vector(2 downto 0);
signal tc : std_logic;
signal count : std_logic_vector(18 downto 0);
--signal count : std_logic_vector(7 downto 0);			-- for easy test

begin

	TERM <= tc;

	process (CLK, LRSTb) begin
		if (LRSTb = '0' ) then
			tc <= '0';
			count <= (others => '0');
		elsif (CLK'event and CLK='1') then
			count <= count + 1;
			if (count = "1111111111111111111") then
--			if (count = "11111111") then				-- for easy test
				tc <= '1';
			else
				tc <= '0';
			end if;
		end if;
	end process;

	process (CLK, LRSTb) begin
		if (LRSTb = '0') then
			st <= sa;
			PLS <= da;
		elsif (CLK'event and CLK= '1') then
			if (tc = '1') then
				case st is
					when sa =>
						PLS <= da;
						st	<= sb;
					when sb =>
						PLS <= db;
						st	<= sc;
					when sc =>
						PLS <= dc;
						st	<= sd;
					when sd =>
						PLS <= dd;
						st	<= se;
					when se =>
						PLS <= de;
						st	<= sf;
					when sf =>
						PLS <= df;
						st	<= sg;
					when sg =>
						PLS <= dg;
						st	<= sh;
					when sh =>
						PLS <= dh;
						st	<= sa;
					when others =>
						PLS <= da;
						st	<= sa;
				end case;
			end if;
		end if;
	end process;

end RTL;
