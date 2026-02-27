LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY enc8b10b_wrapper IS
   PORT (
      clk                     : IN std_logic;
      reset_n                 : IN std_logic;
      idle_ins                : IN std_logic;
      enable                  : IN std_logic;
      datain                  : IN std_logic_vector(7 DOWNTO 0);
      dataout                 : OUT std_logic_vector(9 DOWNTO 0);
      valid                   : OUT std_logic;
      rdout                   : OUT std_logic);
END ENTITY enc8b10b_wrapper;

ARCHITECTURE wrapper OF enc8b10b_wrapper IS

component enc8b10b_new
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
end component;

   SIGNAL reset_n_reg   : std_logic;
   SIGNAL idle_ins_reg  : std_logic;
   SIGNAL enable_reg    : std_logic;
   SIGNAL datain_reg    : std_logic_vector(7 DOWNTO 0);
   
   SIGNAL dataout_pre   : std_logic_vector(9 DOWNTO 0);
   SIGNAL valid_pre     : std_logic;
   SIGNAL rdout_pre     : std_logic;

BEGIN


enc8b10b_new_inst : enc8b10b_new
    port map(
        CLK         => clk,
        RSTb        => reset_n_reg,
        ENB         => enable_reg,
        IDLE_INS    => idle_ins_reg,
        DATAIN      => datain_reg,
        DATAOUT     => dataout_pre,
        VALID       => valid_pre,
        RD_OUT      => rdout_pre
    );

   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
        -- inputs
        reset_n_reg <=  reset_n;
        idle_ins_reg <=  idle_ins;
        enable_reg <=  enable;
        datain_reg <= datain;

        -- outputs
        dataout <=  dataout_pre;
        valid <=   valid_pre;
        rdout <=   rdout_pre;
      END IF;
   END PROCESS;

END ARCHITECTURE wrapper;
