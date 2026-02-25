--
-- Synopsys
-- Vhdl wrapper for top level design, written on Wed Jan 28 14:52:57 2026
--
library ieee;
use ieee.std_logic_1164.all;
library ecp5u;
use ecp5u.components.all;

entity wrapper_for_pll_gen is
   port (
      CLKI : in std_logic;
      RST : in std_logic;
      CLKOP : out std_logic;
      CLKOS : out std_logic;
      CLKOS2 : out std_logic;
      CLKOS3 : out std_logic;
      LOCK : out std_logic
   );
end wrapper_for_pll_gen;

architecture structure of wrapper_for_pll_gen is

component pll_gen
 port (
   CLKI : in std_logic;
   RST : in std_logic;
   CLKOP : out std_logic;
   CLKOS : out std_logic;
   CLKOS2 : out std_logic;
   CLKOS3 : out std_logic;
   LOCK : out std_logic
 );
end component;

signal tmp_CLKI : std_logic;
signal tmp_RST : std_logic;
signal tmp_CLKOP : std_logic;
signal tmp_CLKOS : std_logic;
signal tmp_CLKOS2 : std_logic;
signal tmp_CLKOS3 : std_logic;
signal tmp_LOCK : std_logic;

begin

tmp_CLKI <= CLKI;

tmp_RST <= RST;

CLKOP <= tmp_CLKOP;

CLKOS <= tmp_CLKOS;

CLKOS2 <= tmp_CLKOS2;

CLKOS3 <= tmp_CLKOS3;

LOCK <= tmp_LOCK;



u1:   pll_gen port map (
		CLKI => tmp_CLKI,
		RST => tmp_RST,
		CLKOP => tmp_CLKOP,
		CLKOS => tmp_CLKOS,
		CLKOS2 => tmp_CLKOS2,
		CLKOS3 => tmp_CLKOS3,
		LOCK => tmp_LOCK
       );
end structure;
