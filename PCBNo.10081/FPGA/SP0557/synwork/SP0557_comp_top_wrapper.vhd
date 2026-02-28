--
-- Synopsys
-- Vhdl wrapper for top level design, written on Sat Feb 28 20:11:36 2026
--
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.w_pack.all;
use ieee.std_logic_unsigned.all;

entity wrapper_for_SP0557 is
   port (
      CLK20M : in std_logic;
      PORb : in std_logic;
      SLVADR : in std_logic_vector(7 downto 0);
      UP_CLK : in std_logic;
      UP_RXD : in std_logic;
      UP_TXD : out std_logic;
      S2P_SCK : out std_logic;
      S2P_RCK : out std_logic;
      S2P_nOE : out std_logic;
      S2P_nCLR : out std_logic;
      S2P_SDO : out std_logic;
      P2S_SCK : out std_logic;
      P2S_SLD : out std_logic;
      P2S_SDI : in std_logic;
      STMVREF_SCL : in std_logic;
      STMVREF_SDA : in std_logic;
      ADC_nCS : out std_logic;
      ADC_SCK : out std_logic;
      ADC_MOSI : out std_logic;
      ADC_MISO : in std_logic;
      LEDSH_RESETb : out std_logic;
      LEDSH_SCK : out std_logic;
      LEDSH_nCS : out std_logic;
      LEDSH_MOSI : out std_logic;
      LEDSH_MISO : in std_logic;
      LEDDRV_LE : out std_logic;
      LEDDRV_OEb : out std_logic;
      LEDDRV_CLK : out std_logic;
      LEDDRV_SD : out std_logic;
      DPM_CSb : out std_logic;
      DPM_CLK : out std_logic;
      DPM_SD : out std_logic;
      STM_PCK : out std_logic_vector(13 downto 1);
      STM_LCW : in std_logic_vector(13 downto 1);
      STM_LCCW : in std_logic_vector(13 downto 1);
      PLS_SNS : in std_logic_vector(8 downto 1);
      PTLEDb : out std_logic_vector(8 downto 1);
      ENC_A : in std_logic_vector(13 downto 1);
      ENC_B : in std_logic_vector(13 downto 1);
      ACTb : out std_logic_vector(6 downto 1);
      PUMPb : out std_logic_vector(2 downto 1)
   );
end wrapper_for_SP0557;

architecture rtl of wrapper_for_SP0557 is

component SP0557
 port (
   CLK20M : in std_logic;
   PORb : in std_logic;
   SLVADR : in std_logic_vector (7 downto 0);
   UP_CLK : in std_logic;
   UP_RXD : in std_logic;
   UP_TXD : out std_logic;
   S2P_SCK : out std_logic;
   S2P_RCK : out std_logic;
   S2P_nOE : out std_logic;
   S2P_nCLR : out std_logic;
   S2P_SDO : out std_logic;
   P2S_SCK : out std_logic;
   P2S_SLD : out std_logic;
   P2S_SDI : in std_logic;
   STMVREF_SCL : inout std_logic;
   STMVREF_SDA : inout std_logic;
   ADC_nCS : out std_logic;
   ADC_SCK : out std_logic;
   ADC_MOSI : out std_logic;
   ADC_MISO : in std_logic;
   LEDSH_RESETb : out std_logic;
   LEDSH_SCK : out std_logic;
   LEDSH_nCS : out std_logic;
   LEDSH_MOSI : out std_logic;
   LEDSH_MISO : in std_logic;
   LEDDRV_LE : out std_logic;
   LEDDRV_OEb : out std_logic;
   LEDDRV_CLK : out std_logic;
   LEDDRV_SD : out std_logic;
   DPM_CSb : out std_logic;
   DPM_CLK : out std_logic;
   DPM_SD : out std_logic;
   STM_PCK : out std_logic_vector (13 downto 1);
   STM_LCW : in std_logic_vector (13 downto 1);
   STM_LCCW : in std_logic_vector (13 downto 1);
   PLS_SNS : in std_logic_vector (8 downto 1);
   PTLEDb : out std_logic_vector (8 downto 1);
   ENC_A : in std_logic_vector (13 downto 1);
   ENC_B : in std_logic_vector (13 downto 1);
   ACTb : out std_logic_vector (6 downto 1);
   PUMPb : out std_logic_vector (2 downto 1)
 );
end component;

signal tmp_CLK20M : std_logic;
signal tmp_PORb : std_logic;
signal tmp_SLVADR : std_logic_vector (7 downto 0);
signal tmp_UP_CLK : std_logic;
signal tmp_UP_RXD : std_logic;
signal tmp_UP_TXD : std_logic;
signal tmp_S2P_SCK : std_logic;
signal tmp_S2P_RCK : std_logic;
signal tmp_S2P_nOE : std_logic;
signal tmp_S2P_nCLR : std_logic;
signal tmp_S2P_SDO : std_logic;
signal tmp_P2S_SCK : std_logic;
signal tmp_P2S_SLD : std_logic;
signal tmp_P2S_SDI : std_logic;
signal tmp_STMVREF_SCL : std_logic;
signal tmp_STMVREF_SDA : std_logic;
signal tmp_ADC_nCS : std_logic;
signal tmp_ADC_SCK : std_logic;
signal tmp_ADC_MOSI : std_logic;
signal tmp_ADC_MISO : std_logic;
signal tmp_LEDSH_RESETb : std_logic;
signal tmp_LEDSH_SCK : std_logic;
signal tmp_LEDSH_nCS : std_logic;
signal tmp_LEDSH_MOSI : std_logic;
signal tmp_LEDSH_MISO : std_logic;
signal tmp_LEDDRV_LE : std_logic;
signal tmp_LEDDRV_OEb : std_logic;
signal tmp_LEDDRV_CLK : std_logic;
signal tmp_LEDDRV_SD : std_logic;
signal tmp_DPM_CSb : std_logic;
signal tmp_DPM_CLK : std_logic;
signal tmp_DPM_SD : std_logic;
signal tmp_STM_PCK : std_logic_vector (13 downto 1);
signal tmp_STM_LCW : std_logic_vector (13 downto 1);
signal tmp_STM_LCCW : std_logic_vector (13 downto 1);
signal tmp_PLS_SNS : std_logic_vector (8 downto 1);
signal tmp_PTLEDb : std_logic_vector (8 downto 1);
signal tmp_ENC_A : std_logic_vector (13 downto 1);
signal tmp_ENC_B : std_logic_vector (13 downto 1);
signal tmp_ACTb : std_logic_vector (6 downto 1);
signal tmp_PUMPb : std_logic_vector (2 downto 1);

begin

tmp_CLK20M <= CLK20M;

tmp_PORb <= PORb;

tmp_SLVADR <= SLVADR;

tmp_UP_CLK <= UP_CLK;

tmp_UP_RXD <= UP_RXD;

UP_TXD <= tmp_UP_TXD;

S2P_SCK <= tmp_S2P_SCK;

S2P_RCK <= tmp_S2P_RCK;

S2P_nOE <= tmp_S2P_nOE;

S2P_nCLR <= tmp_S2P_nCLR;

S2P_SDO <= tmp_S2P_SDO;

P2S_SCK <= tmp_P2S_SCK;

P2S_SLD <= tmp_P2S_SLD;

tmp_P2S_SDI <= P2S_SDI;

tmp_STMVREF_SCL <= STMVREF_SCL;

tmp_STMVREF_SDA <= STMVREF_SDA;

ADC_nCS <= tmp_ADC_nCS;

ADC_SCK <= tmp_ADC_SCK;

ADC_MOSI <= tmp_ADC_MOSI;

tmp_ADC_MISO <= ADC_MISO;

LEDSH_RESETb <= tmp_LEDSH_RESETb;

LEDSH_SCK <= tmp_LEDSH_SCK;

LEDSH_nCS <= tmp_LEDSH_nCS;

LEDSH_MOSI <= tmp_LEDSH_MOSI;

tmp_LEDSH_MISO <= LEDSH_MISO;

LEDDRV_LE <= tmp_LEDDRV_LE;

LEDDRV_OEb <= tmp_LEDDRV_OEb;

LEDDRV_CLK <= tmp_LEDDRV_CLK;

LEDDRV_SD <= tmp_LEDDRV_SD;

DPM_CSb <= tmp_DPM_CSb;

DPM_CLK <= tmp_DPM_CLK;

DPM_SD <= tmp_DPM_SD;

STM_PCK <= tmp_STM_PCK;

tmp_STM_LCW <= STM_LCW;

tmp_STM_LCCW <= STM_LCCW;

tmp_PLS_SNS <= PLS_SNS;

PTLEDb <= tmp_PTLEDb;

tmp_ENC_A <= ENC_A;

tmp_ENC_B <= ENC_B;

ACTb <= tmp_ACTb;

PUMPb <= tmp_PUMPb;



u1:   SP0557 port map (
		CLK20M => tmp_CLK20M,
		PORb => tmp_PORb,
		SLVADR => tmp_SLVADR,
		UP_CLK => tmp_UP_CLK,
		UP_RXD => tmp_UP_RXD,
		UP_TXD => tmp_UP_TXD,
		S2P_SCK => tmp_S2P_SCK,
		S2P_RCK => tmp_S2P_RCK,
		S2P_nOE => tmp_S2P_nOE,
		S2P_nCLR => tmp_S2P_nCLR,
		S2P_SDO => tmp_S2P_SDO,
		P2S_SCK => tmp_P2S_SCK,
		P2S_SLD => tmp_P2S_SLD,
		P2S_SDI => tmp_P2S_SDI,
		STMVREF_SCL => tmp_STMVREF_SCL,
		STMVREF_SDA => tmp_STMVREF_SDA,
		ADC_nCS => tmp_ADC_nCS,
		ADC_SCK => tmp_ADC_SCK,
		ADC_MOSI => tmp_ADC_MOSI,
		ADC_MISO => tmp_ADC_MISO,
		LEDSH_RESETb => tmp_LEDSH_RESETb,
		LEDSH_SCK => tmp_LEDSH_SCK,
		LEDSH_nCS => tmp_LEDSH_nCS,
		LEDSH_MOSI => tmp_LEDSH_MOSI,
		LEDSH_MISO => tmp_LEDSH_MISO,
		LEDDRV_LE => tmp_LEDDRV_LE,
		LEDDRV_OEb => tmp_LEDDRV_OEb,
		LEDDRV_CLK => tmp_LEDDRV_CLK,
		LEDDRV_SD => tmp_LEDDRV_SD,
		DPM_CSb => tmp_DPM_CSb,
		DPM_CLK => tmp_DPM_CLK,
		DPM_SD => tmp_DPM_SD,
		STM_PCK => tmp_STM_PCK,
		STM_LCW => tmp_STM_LCW,
		STM_LCCW => tmp_STM_LCCW,
		PLS_SNS => tmp_PLS_SNS,
		PTLEDb => tmp_PTLEDb,
		ENC_A => tmp_ENC_A,
		ENC_B => tmp_ENC_B,
		ACTb => tmp_ACTb,
		PUMPb => tmp_PUMPb
       );
end rtl;
