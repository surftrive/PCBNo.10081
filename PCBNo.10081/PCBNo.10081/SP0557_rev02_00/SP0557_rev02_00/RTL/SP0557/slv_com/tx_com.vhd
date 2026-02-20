-------------------------------------------------
--File Name : tx_com.vhd
--Project   : S3IO
--
--Date      : 2003/12/01
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2004/05/19
--Ver       : 2.00
--Doc       : Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------
--Date      : 2007/12/19
--Ver       : 2.10
--Doc       : New 8b10b inst
--Changed by  Takemune Oshikawa
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity tx_com is
    port(
        CLK1            : in std_logic;                         -- Clock 10MHZ
        CLK2            : in std_logic;                         -- Clock 100MHZ
        CLK3            : in std_logic;                         -- Clock 100MHZ for CRC
        nRESET          : in std_logic;                         -- power on reset
        TXD             : in std_logic_vector(7 downto 0);      -- tx_fifo write data
        TX_WRREQ        : in std_logic;                         -- fifo write_request
        HUB_EN          : in std_logic;                         -- hub_enable
        TX_WREMPTY      : out std_logic;                        -- fifo empty_flag
        TX_WRFULL       : out std_logic;                        -- fifo full_flag
        TX_END          : out std_logic;                        -- tx_end flag
        TX_D            : out std_logic                         -- tx_sirial_data out
        );
end tx_com;

architecture RTL of tx_com is

component enc8b10b_wrapper
  port (
       clk       : in  std_logic;
       reset_n   : in  std_logic;
       enable    : in  std_logic;
       idle_ins  : in  std_logic;
       datain    : in  std_logic_vector( 7 downto 0 );
       dataout   : out std_logic_vector( 9 downto 0 );
       valid     : out std_logic;
       rdout     : out std_logic    -- Not used
       );
end component;

component tx_cont_b1
    PORT
    (
        CLK1            : in std_logic;
        CLK3            : in std_logic;
        nRESET          : in std_logic;
        TXD             : in std_logic_vector(7 downto 0);
        TX_WRREQ        : in std_logic;
        HUB_EN          : in std_logic;
        TX_WREMPTY      : out std_logic;
        TX_WRFULL       : out std_logic;
        TXDCD           : out std_logic_vector(7 downto 0);
        ENABLE          : out std_logic;
        IDLE_INS        : out std_logic;
        TX_END          : out std_logic;
        K_IN            : out std_logic;
        RD_IN           : out std_logic                 -- running_disparity insert
    );
end component;

component tx_cont_b2
    PORT
    (
        CLK1            : in std_logic;
        CLK2            : in std_logic;
        nRESET          : in std_logic;
        TXEN_A          : in std_logic_vector(9 downto 0);
        VALID           : in std_logic;
        TX_D            : out std_logic                     -- tx_sirial_data out
    );
end component;


    signal  IDLE_INS    : std_logic;
    signal  ENABLE      : std_logic;
    signal  TXDCD       : std_logic_vector( 7 downto 0);
    signal  TXEN_A      : std_logic_vector( 9 downto 0);
    signal  VALID       : std_logic;

begin

enc8b10b_wrapper_inst : enc8b10b_wrapper PORT MAP (
        clk         => CLK1,
        reset_n     => nRESET,
        enable      => ENABLE,
        idle_ins    => IDLE_INS,
        datain      => TXDCD(7 downto 0),
        dataout     => TXEN_A(9 downto 0),
        valid       => VALID,
        rdout       => open
    );

tx_cont_b1_inst : tx_cont_b1 PORT MAP (
        CLK1        => CLK1,
        CLK3        => CLK3,
        nRESET      => nRESET,
        TXD         => TXD(7 downto 0),
        TX_WRREQ    => TX_WRREQ,
        HUB_EN      => HUB_EN,
        TX_WREMPTY  => TX_WREMPTY,
        TX_WRFULL   => TX_WRFULL,
        TXDCD       => TXDCD(7 downto 0),
        ENABLE      => ENABLE,
        IDLE_INS    => IDLE_INS,
        TX_END      => TX_END,
        K_IN        => open,
        RD_IN       => open
    );

tx_cont_b2_inst : tx_cont_b2 PORT MAP (
        CLK1        => CLK1,
        CLK2        => CLK2,
        nRESET      => nRESET,
        TXEN_A      => TXEN_A(9 downto 0),
        VALID       => VALID,
        TX_D        => TX_D
    );


end RTL;



