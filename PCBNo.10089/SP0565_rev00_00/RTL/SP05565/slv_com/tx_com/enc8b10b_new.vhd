-------------------------------------------------
--File Name : enc8b10b_new.vhd
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

entity enc8b10b_new is
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        DATAIN      : in std_logic_vector(7 downto 0);   --HGFEDCBA
        DATAOUT     : out std_logic_vector(9 downto 0);  --jhgfiedcba
        VALID       : out std_logic;
		RD_OUT		: out std_logic
    );
end enc8b10b_new;

architecture RTL of enc8b10b_new is

component enc8b_10b
    port(
        CLK         : in std_logic;
        RSTb        : in std_logic;
        ENB         : in std_logic;
        IDLE_INS    : in std_logic;
        DATAIN      : in std_logic_vector(7 downto 0);   --HGFEDCBA
        DATAOUT     : out std_logic_vector(9 downto 0);  --jhgfiedcba
        VALID       : out std_logic;
		RD_OUT		: out std_logic
    );
end component;

signal VALID_BUF	: std_logic;
signal RD_OUT_BUF	: std_logic;

signal DATAOUT_BUF	: std_logic_vector(9 downto 0);

begin

    process(CLK)
    begin
        if(CLK'event and CLK='1') then
			DATAOUT <= DATAOUT_BUF;
			VALID <= VALID_BUF;
			RD_OUT <= RD_OUT_BUF;
        end if;
    end process;

enc8b_10b_inst : enc8b_10b
    port map(
        CLK         => CLK,
        RSTb        => RSTb,
        ENB         => ENB,
        IDLE_INS    => IDLE_INS,
        DATAIN      => DATAIN,
        DATAOUT     => DATAOUT_BUF,
        VALID       => VALID_BUF,
		RD_OUT		=> RD_OUT_BUF
    );

end RTL;