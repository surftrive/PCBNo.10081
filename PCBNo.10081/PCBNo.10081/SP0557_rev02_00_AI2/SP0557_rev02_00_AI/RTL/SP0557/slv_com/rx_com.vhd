-------------------------------------------------
--File Name : rx_com.vhd
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
--Changed by Takemune Oshikawa
-------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity rx_com is
    port(
        CLK1            : in std_logic;                         -- Clock 10MHZ
        CLK2            : in std_logic;                         -- Clock 100MHZ
        CLK2A           : in std_logic;                         -- Clock 100MHZ_90
        CLK3            : in std_logic;                         -- Clock 100MHZ fro CRC
        nRESET          : in std_logic;                         -- power on reset
        RX_D            : in std_logic;                         -- rx_sirial_data in
        RX_RDREQ        : in std_logic;                         -- rx_fifo write_request
        HUB_EN          : in std_logic;                         -- hub_enable
        RX_RDEMPTY      : out std_logic;                        -- fifo empty_flag
        RX_RDFULL       : out std_logic;                        -- fifo full_flag
        K_ERR           : out std_logic;                        -- 8b10b_e k_code error
        RX_START        : out std_logic;                        -- rx_start flag
        RXD             : out std_logic_vector(7 downto 0);     -- rx_fifo read data
        CRC_ERR         : out std_logic ;                       -- crc_error flag
        SYNC_FLG        : out std_logic;
        IDLE_EN         : out std_logic;
        PACK_END        : out std_logic                         -- Packet End Signal
        );
end rx_com;

architecture RTL of rx_com is

component dec8b10b_wrapper
  port (
       clk       : in  std_logic;
       reset_n   : in  std_logic;
       enable    : in  std_logic;
       idle_del  : in  std_logic;
       datain    : in  std_logic_vector( 9 downto 0 );
       kout      : out std_logic;
       kerr      : out std_logic;
       dataout   : out std_logic_vector( 7 downto 0 );
       valid     : out std_logic;
       rdout     : out std_logic
       );
end component;

component rx_cont_b1
    PORT
    (
        CLK1            : in std_logic;                         -- Clock 10MHZ
        CLK2            : in std_logic;                         -- Clock 100MHZ
        nRESET          : in std_logic;                         -- power on reset
        RX_D            : in std_logic;                         -- rx_data_in
        RXDE_C          : out std_logic_vector(9 downto 0);     -- rx_data(10bit)
        ENABLE          : out std_logic;                        -- 8b10B data enable
        IDLE_DEL        : out std_logic;                        -- IDLE_code delete
        IDLE_EN_O       : out std_logic;
        RD_IN           : out std_logic                     -- running_disparity insert
    );
end component;

component rx_cont_b2
    PORT
    (
        CLK1            : in std_logic;                         -- Clock 10MHZ
        CLK3            : in std_logic;                         -- Clock 100MHZ for CRC
        nRESET          : in std_logic;                         -- power on reset
        RXDCD           : in std_logic_vector(7 downto 0);      -- 8b10b_dec out_data
        VALID           : in std_logic;                         -- 8b10b_dec data_valid
        RX_RDREQ        : in std_logic;                         -- fifo read_request
        HUB_EN          : in std_logic;                         -- hub_enable
        RXD             : out std_logic_vector(7 downto 0);     -- rx_fifo read data
        RX_RDEMPTY      : out std_logic;                        -- fifo empty_flag
        RX_RDFULL       : out std_logic;                        -- fifo full_flag
        RX_START        : out std_logic;                        -- rx_start flag
        CRC_ERR         : out std_logic;                        -- crc_check error
        SYNC_FLG        : out std_logic;
        PACK_END        : out std_logic;                        -- Packet End Signal
        K_ERR           : out std_logic
    );
end component;


    signal  IDLE_DEL    : std_logic;
    signal  ENABLE      : std_logic;
    signal  RXDCD       : std_logic_vector( 7 downto 0);
    signal  RXDE_C      : std_logic_vector( 9 downto 0);
    signal  VALID       : std_logic;

    signal  val     : std_logic;
    signal  kout    : std_logic;
    signal  kerr    : std_logic;

begin


dec8b10b_wrapper_inst : dec8b10b_wrapper PORT MAP (
        clk         => CLK1,
        reset_n     => nRESET,
        idle_del    => IDLE_DEL,
        enable      => ENABLE,
        datain      => RXDE_C(9 downto 0),
        valid       => val,
        dataout     => RXDCD(7 downto 0),
        kout        => kout,
        kerr        => kerr,
        rdout       => open
    );

    VALID       <= val and not kout and not kerr;

rx_cont_b1_inst : rx_cont_b1 PORT MAP (
        CLK1        => CLK1,
        CLK2        => CLK2,
        nRESET      => nRESET,
        RX_D        => RX_D,
        RXDE_C      => RXDE_C(9 downto 0),
        ENABLE      => ENABLE,
        IDLE_DEL    => IDLE_DEL,
        IDLE_EN_O   => IDLE_EN,
        RD_IN       => open
    );

rx_cont_b2_inst : rx_cont_b2 PORT MAP (
        CLK1        => CLK1,
        CLK3        => CLK3,
        nRESET      => nRESET,
        RXDCD       => RXDCD(7 downto 0),
        VALID       => VALID,
        RX_RDREQ    => RX_RDREQ,
        HUB_EN      => HUB_EN,
        RXD         => RXD(7 downto 0),
        RX_RDEMPTY  => RX_RDEMPTY,
        RX_RDFULL   => RX_RDFULL,
        RX_START    => RX_START,
        CRC_ERR     => CRC_ERR,
        SYNC_FLG    => SYNC_FLG,
        K_ERR       => K_ERR,
        PACK_END    => PACK_END
    );


end RTL;



