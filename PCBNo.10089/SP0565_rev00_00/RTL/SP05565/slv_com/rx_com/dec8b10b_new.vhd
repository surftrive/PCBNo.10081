-------------------------------------------------
--File Name : dec8b10b_new.vhd
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

entity dec8b10b_new is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_DEL    : in std_logic;
        DATAIN      : in std_logic_vector(9 downto 0);   --jhgfiedcba
        DATAOUT     : out std_logic_vector(7 downto 0);  --HGFEDCBA
        VALID       : out std_logic;
        KOUT        : out std_logic;
        KERR        : out std_logic;
		RD_OUT		: out std_logic
    );
end dec8b10b_new;

architecture RTL of dec8b10b_new is

component dec6b_5b
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_DEL    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(5 downto 0);   --iedcba
        DATAOUT     : out std_logic_vector(4 downto 0);  --EDCBA
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=pogitive
        VALID5B     : out std_logic;
        KERR5B      : out std_logic;
        KOUT5B      : out std_logic
    );
end component;

component dec4b_3b is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_DEL    : in std_logic;
        RD_IN       : in std_logic;
        DATAIN      : in std_logic_vector(9 downto 0);   --jhgf
        DATAOUT     : out std_logic_vector(2 downto 0);  --HGF
        RD_OUT      : out std_logic;                      -- '0' -> RD=negative, '1' -> RD=pogitive
        VALID3B     : out std_logic;
        KERR3B      : out std_logic;
        KOUT3B      : out std_logic
    );
end component;

signal RD_6b5b      : std_logic;
signal RD_4b3b      : std_logic;
signal VALID5B      : std_logic;
signal VALID3B      : std_logic;
signal KERR5B       : std_logic;
signal KERR3B       : std_logic;
signal KOUT5B       : std_logic;
signal KOUT3B       : std_logic;
signal ENB_BUF		: std_logic;
signal IDLE_DEL_BUF	: std_logic;
signal DATA5B       : std_logic_vector(4 downto 0);
signal DATA3B       : std_logic_vector(2 downto 0);
signal DATAIN_BUF	: std_logic_vector(9 downto 0);

begin

    process(CLK)
    begin
        if(CLK'event and CLK='1') then
            VALID <= VALID5B and VALID3B;
            DATAOUT <= DATA3B & DATA5B;
            KERR <= KERR5B or KERR3B;
            KOUT <= KOUT5B or KOUT3B;
			ENB_BUF <= ENB;
			IDLE_DEL_BUF <= IDLE_DEL;
			RD_OUT <= RD_4b3b;
			DATAIN_BUF <= DATAIN;
        end if;
    end process;

dec6b_5b_inst : dec6b_5b
    port map(
        CLK         => CLK,
        RSTb        => RSTb,
        ENB         => ENB,
        IDLE_DEL    => IDLE_DEL,
        RD_IN       => RD_4b3b,
        DATAIN      => DATAIN(5 downto 0),
        DATAOUT     => DATA5B,
        RD_OUT      => RD_6b5b,
        VALID5B     => VALID5B,
        KERR5B      => KERR5B,
        KOUT5B      => KOUT5B
    );

dec4b_3b_inst: dec4b_3b
    port map(
        CLK         => CLK,
        RSTb        => RSTb,
        ENB         => ENB_BUF,
        IDLE_DEL    => IDLE_DEL_BUF,
        RD_IN       => RD_6b5b,
        DATAIN      => DATAIN_BUF,
        DATAOUT     => DATA3B,
        RD_OUT      => RD_4b3b,
        VALID3B     => VALID3B,
        KERR3B      => KERR3B,
        KOUT3B      => KOUT3B
    );

end RTL;