-------------------------------------------------
--File Name : temp_rng_chk.vhd
--Project	: 4CH TEMPERATURE CONTROL IP
--
--Date		: 2003/07/18
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2003/09/17
--Ver		: 0.01
--Doc		: for Specification Ver.0.03
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date		: 2006/05/23
--Ver		: 1.00
--Doc		: "HEATREF" is disregarded at the time of [CLON='1']
--Changed by  J.I
-------------------------------------
--Date		: 2009/04/08
--Ver		: 2.00
--Doc		: Delete --> "HEATREF" is disregarded at the time of [CLON='1']
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity temp_rng_chk is
	port (	 CH0MEAS	: in std_logic_vector(11 downto 0);
			 CH1MEAS	: in std_logic_vector(11 downto 0);
			 CH2MEAS	: in std_logic_vector(11 downto 0);
			 CH3MEAS	: in std_logic_vector(11 downto 0);
			 CUTREF		: in std_logic_vector(11 downto 0);
			 CUT		:out std_logic_vector(3 downto 0));
end temp_rng_chk;

architecture RTL of temp_rng_chk is

constant HEATREF : std_logic_vector(11 downto 0) := "111110100000";

signal ch0cut : std_logic;
signal ch1cut : std_logic;
signal ch2cut : std_logic;
signal ch3cut : std_logic;

begin

	ch0cut <= '1' when (CH0MEAS < CUTREF or CH0MEAS > HEATREF) else '0';
	ch1cut <= '1' when (CH1MEAS < CUTREF or CH1MEAS > HEATREF) else '0';
	ch2cut <= '1' when (CH2MEAS < CUTREF or CH2MEAS > HEATREF) else '0';
	ch3cut <= '1' when (CH3MEAS < CUTREF or CH3MEAS > HEATREF) else '0';
	CUT <= ch3cut & ch2cut & ch1cut & ch0cut;
	
end RTL;
