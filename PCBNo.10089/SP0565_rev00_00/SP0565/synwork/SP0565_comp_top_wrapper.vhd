--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue Feb  3 10:34:26 2026
--
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.w_pack.all;
use ieee.std_logic_unsigned.all;

entity wrapper_for_SP0565 is
   port (
      CLK20M : in std_logic;
      PORb : in std_logic;
      SLVADR : in std_logic_vector(7 downto 0);
      UP_CLK : in std_logic;
      UP_RXD : in std_logic;
      UP_TXD : out std_logic;
      SLV_ER : out std_logic;
      PW_PLS_ON : out std_logic;
      PW_SV_ON : out std_logic;
      PW_PUMP_ON : out std_logic;
      PW_LMT_ON : out std_logic;
      PW_SNSLED_ON : out std_logic;
      nFLT_PLS : in std_logic;
      nFLT_PLSSNS : in std_logic;
      nFLT_SV : in std_logic;
      nFLT_PUMP : in std_logic;
      nFLT_LMT : in std_logic;
      nFLT_SNSLED : in std_logic;
      STM_PCK : out std_logic_vector(1 downto 1);
      STM_nSLP : out std_logic;
      STM_EN : out std_logic;
      STM_DIR : out std_logic;
      STM_M0S : out std_logic;
      STM_M0Z : out std_logic;
      STM_M1 : out std_logic;
      STM_SYNCb : out std_logic;
      STM_SCLK : out std_logic;
      STM_MOSI : out std_logic;
      STM_nFAULT : in std_logic_vector(1 downto 1);
      PLT_EN : out std_logic;
      PLT_ON : out std_logic;
      PLT_SYNCb : out std_logic;
      PLT_SCLK : out std_logic;
      PLT_MOSI : out std_logic;
      nFLT_PLT : in std_logic;
      ADC_nCS : out std_logic;
      ADC_SCK : out std_logic;
      ADC_MOSI : out std_logic;
      ADC_MISO : in std_logic;
      STM_LCW : in std_logic_vector(1 downto 1);
      STM_LCCW : in std_logic_vector(1 downto 1);
      SNS : in std_logic_vector(2 downto 1);
      PLS_SNS : in std_logic_vector(2 downto 1);
      PTLEDb : out std_logic_vector(2 downto 1);
      ENC_A : in std_logic_vector(1 downto 1);
      ENC_B : in std_logic_vector(1 downto 1);
      ACTb : out std_logic_vector(6 downto 1);
      PUMPb : out std_logic_vector(2 downto 1);
      FAN_SNS : in std_logic_vector(1 downto 1);
      FAN_ON : out std_logic_vector(1 downto 1)
   );
end wrapper_for_SP0565;

architecture rtl of wrapper_for_SP0565 is

component SP0565
 port (
   CLK20M : in std_logic;
   PORb : in std_logic;
   SLVADR : in std_logic_vector (7 downto 0);
   UP_CLK : in std_logic;
   UP_RXD : in std_logic;
   UP_TXD : out std_logic;
   SLV_ER : out std_logic;
   PW_PLS_ON : out std_logic;
   PW_SV_ON : out std_logic;
   PW_PUMP_ON : out std_logic;
   PW_LMT_ON : out std_logic;
   PW_SNSLED_ON : out std_logic;
   nFLT_PLS : in std_logic;
   nFLT_PLSSNS : in std_logic;
   nFLT_SV : in std_logic;
   nFLT_PUMP : in std_logic;
   nFLT_LMT : in std_logic;
   nFLT_SNSLED : in std_logic;
   STM_PCK : out std_logic_vector (1 downto 1);
   STM_nSLP : out std_logic;
   STM_EN : out std_logic;
   STM_DIR : out std_logic;
   STM_M0S : out std_logic;
   STM_M0Z : out std_logic;
   STM_M1 : out std_logic;
   STM_SYNCb : out std_logic;
   STM_SCLK : out std_logic;
   STM_MOSI : out std_logic;
   STM_nFAULT : in std_logic_vector (1 downto 1);
   PLT_EN : out std_logic;
   PLT_ON : out std_logic;
   PLT_SYNCb : out std_logic;
   PLT_SCLK : out std_logic;
   PLT_MOSI : out std_logic;
   nFLT_PLT : in std_logic;
   ADC_nCS : out std_logic;
   ADC_SCK : out std_logic;
   ADC_MOSI : out std_logic;
   ADC_MISO : in std_logic;
   STM_LCW : in std_logic_vector (1 downto 1);
   STM_LCCW : in std_logic_vector (1 downto 1);
   SNS : in std_logic_vector (2 downto 1);
   PLS_SNS : in std_logic_vector (2 downto 1);
   PTLEDb : out std_logic_vector (2 downto 1);
   ENC_A : in std_logic_vector (1 downto 1);
   ENC_B : in std_logic_vector (1 downto 1);
   ACTb : out std_logic_vector (6 downto 1);
   PUMPb : out std_logic_vector (2 downto 1);
   FAN_SNS : in std_logic_vector (1 downto 1);
   FAN_ON : out std_logic_vector (1 downto 1)
 );
end component;

signal tmp_CLK20M : std_logic;
signal tmp_PORb : std_logic;
signal tmp_SLVADR : std_logic_vector (7 downto 0);
signal tmp_UP_CLK : std_logic;
signal tmp_UP_RXD : std_logic;
signal tmp_UP_TXD : std_logic;
signal tmp_SLV_ER : std_logic;
signal tmp_PW_PLS_ON : std_logic;
signal tmp_PW_SV_ON : std_logic;
signal tmp_PW_PUMP_ON : std_logic;
signal tmp_PW_LMT_ON : std_logic;
signal tmp_PW_SNSLED_ON : std_logic;
signal tmp_nFLT_PLS : std_logic;
signal tmp_nFLT_PLSSNS : std_logic;
signal tmp_nFLT_SV : std_logic;
signal tmp_nFLT_PUMP : std_logic;
signal tmp_nFLT_LMT : std_logic;
signal tmp_nFLT_SNSLED : std_logic;
signal tmp_STM_PCK : std_logic_vector (1 downto 1);
signal tmp_STM_nSLP : std_logic;
signal tmp_STM_EN : std_logic;
signal tmp_STM_DIR : std_logic;
signal tmp_STM_M0S : std_logic;
signal tmp_STM_M0Z : std_logic;
signal tmp_STM_M1 : std_logic;
signal tmp_STM_SYNCb : std_logic;
signal tmp_STM_SCLK : std_logic;
signal tmp_STM_MOSI : std_logic;
signal tmp_STM_nFAULT : std_logic_vector (1 downto 1);
signal tmp_PLT_EN : std_logic;
signal tmp_PLT_ON : std_logic;
signal tmp_PLT_SYNCb : std_logic;
signal tmp_PLT_SCLK : std_logic;
signal tmp_PLT_MOSI : std_logic;
signal tmp_nFLT_PLT : std_logic;
signal tmp_ADC_nCS : std_logic;
signal tmp_ADC_SCK : std_logic;
signal tmp_ADC_MOSI : std_logic;
signal tmp_ADC_MISO : std_logic;
signal tmp_STM_LCW : std_logic_vector (1 downto 1);
signal tmp_STM_LCCW : std_logic_vector (1 downto 1);
signal tmp_SNS : std_logic_vector (2 downto 1);
signal tmp_PLS_SNS : std_logic_vector (2 downto 1);
signal tmp_PTLEDb : std_logic_vector (2 downto 1);
signal tmp_ENC_A : std_logic_vector (1 downto 1);
signal tmp_ENC_B : std_logic_vector (1 downto 1);
signal tmp_ACTb : std_logic_vector (6 downto 1);
signal tmp_PUMPb : std_logic_vector (2 downto 1);
signal tmp_FAN_SNS : std_logic_vector (1 downto 1);
signal tmp_FAN_ON : std_logic_vector (1 downto 1);

begin

tmp_CLK20M <= CLK20M;

tmp_PORb <= PORb;

tmp_SLVADR <= SLVADR;

tmp_UP_CLK <= UP_CLK;

tmp_UP_RXD <= UP_RXD;

UP_TXD <= tmp_UP_TXD;

SLV_ER <= tmp_SLV_ER;

PW_PLS_ON <= tmp_PW_PLS_ON;

PW_SV_ON <= tmp_PW_SV_ON;

PW_PUMP_ON <= tmp_PW_PUMP_ON;

PW_LMT_ON <= tmp_PW_LMT_ON;

PW_SNSLED_ON <= tmp_PW_SNSLED_ON;

tmp_nFLT_PLS <= nFLT_PLS;

tmp_nFLT_PLSSNS <= nFLT_PLSSNS;

tmp_nFLT_SV <= nFLT_SV;

tmp_nFLT_PUMP <= nFLT_PUMP;

tmp_nFLT_LMT <= nFLT_LMT;

tmp_nFLT_SNSLED <= nFLT_SNSLED;

STM_PCK <= tmp_STM_PCK;

STM_nSLP <= tmp_STM_nSLP;

STM_EN <= tmp_STM_EN;

STM_DIR <= tmp_STM_DIR;

STM_M0S <= tmp_STM_M0S;

STM_M0Z <= tmp_STM_M0Z;

STM_M1 <= tmp_STM_M1;

STM_SYNCb <= tmp_STM_SYNCb;

STM_SCLK <= tmp_STM_SCLK;

STM_MOSI <= tmp_STM_MOSI;

tmp_STM_nFAULT <= STM_nFAULT;

PLT_EN <= tmp_PLT_EN;

PLT_ON <= tmp_PLT_ON;

PLT_SYNCb <= tmp_PLT_SYNCb;

PLT_SCLK <= tmp_PLT_SCLK;

PLT_MOSI <= tmp_PLT_MOSI;

tmp_nFLT_PLT <= nFLT_PLT;

ADC_nCS <= tmp_ADC_nCS;

ADC_SCK <= tmp_ADC_SCK;

ADC_MOSI <= tmp_ADC_MOSI;

tmp_ADC_MISO <= ADC_MISO;

tmp_STM_LCW <= STM_LCW;

tmp_STM_LCCW <= STM_LCCW;

tmp_SNS <= SNS;

tmp_PLS_SNS <= PLS_SNS;

PTLEDb <= tmp_PTLEDb;

tmp_ENC_A <= ENC_A;

tmp_ENC_B <= ENC_B;

ACTb <= tmp_ACTb;

PUMPb <= tmp_PUMPb;

tmp_FAN_SNS <= FAN_SNS;

FAN_ON <= tmp_FAN_ON;



u1:   SP0565 port map (
		CLK20M => tmp_CLK20M,
		PORb => tmp_PORb,
		SLVADR => tmp_SLVADR,
		UP_CLK => tmp_UP_CLK,
		UP_RXD => tmp_UP_RXD,
		UP_TXD => tmp_UP_TXD,
		SLV_ER => tmp_SLV_ER,
		PW_PLS_ON => tmp_PW_PLS_ON,
		PW_SV_ON => tmp_PW_SV_ON,
		PW_PUMP_ON => tmp_PW_PUMP_ON,
		PW_LMT_ON => tmp_PW_LMT_ON,
		PW_SNSLED_ON => tmp_PW_SNSLED_ON,
		nFLT_PLS => tmp_nFLT_PLS,
		nFLT_PLSSNS => tmp_nFLT_PLSSNS,
		nFLT_SV => tmp_nFLT_SV,
		nFLT_PUMP => tmp_nFLT_PUMP,
		nFLT_LMT => tmp_nFLT_LMT,
		nFLT_SNSLED => tmp_nFLT_SNSLED,
		STM_PCK => tmp_STM_PCK,
		STM_nSLP => tmp_STM_nSLP,
		STM_EN => tmp_STM_EN,
		STM_DIR => tmp_STM_DIR,
		STM_M0S => tmp_STM_M0S,
		STM_M0Z => tmp_STM_M0Z,
		STM_M1 => tmp_STM_M1,
		STM_SYNCb => tmp_STM_SYNCb,
		STM_SCLK => tmp_STM_SCLK,
		STM_MOSI => tmp_STM_MOSI,
		STM_nFAULT => tmp_STM_nFAULT,
		PLT_EN => tmp_PLT_EN,
		PLT_ON => tmp_PLT_ON,
		PLT_SYNCb => tmp_PLT_SYNCb,
		PLT_SCLK => tmp_PLT_SCLK,
		PLT_MOSI => tmp_PLT_MOSI,
		nFLT_PLT => tmp_nFLT_PLT,
		ADC_nCS => tmp_ADC_nCS,
		ADC_SCK => tmp_ADC_SCK,
		ADC_MOSI => tmp_ADC_MOSI,
		ADC_MISO => tmp_ADC_MISO,
		STM_LCW => tmp_STM_LCW,
		STM_LCCW => tmp_STM_LCCW,
		SNS => tmp_SNS,
		PLS_SNS => tmp_PLS_SNS,
		PTLEDb => tmp_PTLEDb,
		ENC_A => tmp_ENC_A,
		ENC_B => tmp_ENC_B,
		ACTb => tmp_ACTb,
		PUMPb => tmp_PUMPb,
		FAN_SNS => tmp_FAN_SNS,
		FAN_ON => tmp_FAN_ON
       );
end rtl;
