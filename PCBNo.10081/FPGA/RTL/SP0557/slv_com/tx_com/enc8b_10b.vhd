-------------------------------------------------
--File Name : enc8b_10b.vhd
--Project   : S3IO
--
--Date      : 2007/12/18
--Ver       : 0.00
--Doc       : New Release
--Designed by Takemune Oshikawa
-------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity enc8b_10b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        DATAIN      : in std_logic_vector(7 downto 0);   --HGFEDCBA
        DATAOUT     : out std_logic_vector(9 downto 0);  --jhgfiedcba
        VALID       : out std_logic;
        RD_OUT      : out std_logic
    );
end enc8b_10b;

architecture RTL of enc8b_10b is

component enc5b_6b
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(4 downto 0);   --EDCBA
        DATAOUT     : out std_logic_vector(5 downto 0);  --iedcba
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=positive
        VALID6B     : out std_logic
   );
end component;

component enc3b_4b
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(2 downto 0);   --HGF
        DATA_ie     : in std_logic_vector(1 downto 0);
        DATAOUT     : out std_logic_vector(3 downto 0);  --jhgf
        RD_OUT      : out std_logic;                     -- '0' -> RD=negative, '1' -> RD=positive
        VALID4B     : out std_logic
    );
end component;

signal RD_5b6b      : std_logic;
signal RD_3b4b      : std_logic;
signal VALID6B      : std_logic;
signal VALID4B      : std_logic;
signal ENB_BUF      : std_logic;
signal IDLE_INS_BUF : std_logic;
signal DATA6B       : std_logic_vector(5 downto 0);
signal DATA4B       : std_logic_vector(3 downto 0);
signal DATA3BIN     : std_logic_vector(2 downto 0);

begin

    process(CLK)
    begin
        if(CLK'event and CLK='1') then
            VALID <= VALID4B and VALID6B;
            DATAOUT <= DATA4B & DATA6B;
            ENB_BUF <= ENB;
            IDLE_INS_BUF <= IDLE_INS;
            DATA3BIN <= DATAIN(7 downto 5);
            RD_OUT <= RD_3b4b;
        end if;
    end process;

enc5b_6b_inst : enc5b_6b
    port map(
        CLK        => CLK,
        RSTb       => RSTb,
        ENB        => ENB,
        IDLE_INS   => IDLE_INS,
        RD_IN      => RD_3b4b,
        DATAIN     => DATAIN(4 downto 0),
        DATAOUT    => DATA6B,
        RD_OUT     => RD_5b6b,
        VALID6B    => VALID6B
    );

enc3b_4b_inst : enc3b_4b
    port map(
        CLK        => CLK,
        RSTb       => RSTb,
        ENB        => ENB_BUF,
        IDLE_INS   => IDLE_INS_BUF,
        RD_IN      => RD_5b6b,
        DATAIN     => DATA3BIN,
        DATA_ie    => DATA6B(5 downto 4),
        DATAOUT    => DATA4B,
        RD_OUT     => RD_3b4b,
        VALID4B    => VALID4B
    );

end RTL;