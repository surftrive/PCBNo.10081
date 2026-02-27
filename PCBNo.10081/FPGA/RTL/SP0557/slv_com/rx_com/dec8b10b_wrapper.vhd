LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY dec8b10b_wrapper IS
   PORT (
       clk       : in  std_logic;
       reset_n   : in  std_logic;
       idle_del  : in  std_logic;
       enable    : in  std_logic;
       datain    : in  std_logic_vector( 9 downto 0 );
       valid     : out std_logic;
       dataout   : out std_logic_vector( 7 downto 0 );
       kout      : out std_logic;
       kerr      : out std_logic;
       rdout     : out std_logic);
END ENTITY dec8b10b_wrapper;

ARCHITECTURE wrapper OF dec8b10b_wrapper IS

component dec8b10b_new
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
        RD_OUT      : out std_logic
    );
end component;


    SIGNAL reset_n_reg   : std_logic;
    SIGNAL idle_del_reg  : std_logic;
    SIGNAL enable_reg    : std_logic;
    SIGNAL datain_reg    : std_logic_vector(9 DOWNTO 0);

    SIGNAL valid_pre     : std_logic;
    SIGNAL dataout_pre   : std_logic_vector(7 DOWNTO 0);
    SIGNAL kout_pre      : std_logic;
    SIGNAL kerr_pre      : std_logic;
	SIGNAL rdout_pre	 : std_logic;

BEGIN


dec8b10b_new_inst : dec8b10b_new
    port map (
        CLK         => clk,
        RSTb        => reset_n_reg,
        ENB         => enable_reg,
        IDLE_DEL    => idle_del_reg,
        DATAIN      => datain_reg,
        DATAOUT     => dataout_pre,
        VALID       => valid_pre,
        KOUT        => kout_pre,
        KERR        => kerr_pre,
        RD_OUT      => rdout_pre
    );

   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
        -- inputs
        reset_n_reg <= reset_n;
        idle_del_reg <= idle_del;
        enable_reg <= enable;
        datain_reg <= datain;

        -- outputs
        valid <= valid_pre;
        dataout <= dataout_pre;
        kout <= kout_pre;
        kerr <= kerr_pre;
        rdout <= rdout_pre;
      END IF;
   END PROCESS;

END ARCHITECTURE wrapper;
