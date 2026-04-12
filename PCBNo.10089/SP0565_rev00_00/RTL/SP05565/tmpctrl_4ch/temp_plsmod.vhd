-------------------------------------------------
--File Name : temp_plsmod.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2003/07/22
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      :2005/09/15
--Ver       :4.00
--Doc       :Delete Logic Setteings
--Changed by Kazutoshi Tokunaga
-------------------------------------------------
--Date		: 2010/12/24
--Ver		: 5.00
--Doc		: [100V MODE] Duty 4/8
--Changed by  J.I
-------------------------------------------------
--Date		: 2010/12/25
--Ver		: 6.00
--Doc		: [100V MODE] Duty 4/8 -> */8
--Changed by  J.I
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity temp_plsmod is
    port ( CLK :in std_logic;
             LRSTb :in std_logic;
             PLS :in std_logic_vector(7 downto 0);
             NUM :in std_logic_vector(2 downto 0);
             NEG :in std_logic;
             TERM :in std_logic;
             DLY :in std_logic_vector(1 downto 0);
             COOL :in std_logic;
             ENB :in std_logic;
			 LIMIT :in std_logic;
    		 IDLING	: in std_logic;
    		 IDLM	: in std_logic_vector(7 downto 0);
             CLON :out std_logic;
             CLP :out std_logic;
             HTON :out std_logic;
             HTP :out std_logic;
             CLPORHTPhf    : out std_logic;
             CLPORHTP    : out std_logic);
end temp_plsmod;

architecture RTL of temp_plsmod is

component temp_plssel
    port ( CLK :in std_logic;
             LRSTb :in std_logic;
             PLS :in std_logic_vector(7 downto 0);
             NUM :in std_logic_vector(2 downto 0);
             NEG :in std_logic;
			 LIMIT :in std_logic;
			 IDLING	: in std_logic;
             IDLM :in std_logic_vector(7 downto 0);
             PLS0D :out std_logic;
             TERM :in std_logic);
end component;

component temp_dly_2term
    port ( CLK :in std_logic;
             LRSTb :in std_logic;
             PLS :in std_logic;
             TERM :in std_logic;
             PLSDD :out std_logic);
end  component;

component temp_dlysel
    port ( DLY :in std_logic_vector(1 downto 0);
             PLS0D :in std_logic;
             PLS2D :in std_logic;
             PLS4D :in std_logic;
             PLS6D :in std_logic;
             PLSOhf :out std_logic;
             PLSO :out std_logic);
end component;

component temp_plsdrv
    port ( CLK :in std_logic;
             LRSTb :in std_logic;
             TERM :in std_logic;
             PLSO :in std_logic;
             COOL :in std_logic;
             ENB :in std_logic;
             CLON :out std_logic;
             CLP :out std_logic;
             HTON :out std_logic;
             HTP :out std_logic;
             CLPORHTP : out std_logic);
end component;

signal PLS0D : std_logic;
signal PLS2D : std_logic;
signal PLS4D : std_logic;
signal PLS6D : std_logic;
signal PLSO : std_logic;
signal PLSOhf : std_logic;

begin

temp_plssel_inst: temp_plssel
    port map(
        CLK => CLK,
        LRSTb  => LRSTb,
        PLS    => PLS,
        NUM    => NUM,
        NEG    => NEG,
        PLS0D  => PLS0D,
		LIMIT  => LIMIT,
		IDLING => IDLING,
		IDLM   => IDLM,
        TERM   => TERM
    );

temp_dly_2term_inst1: temp_dly_2term
    port map(
        CLK => CLK,
        LRSTb  => LRSTb,
        PLS    => PLS0D,
        TERM   => TERM,
        PLSDD  => PLS2D
    );

temp_dly_2term_inst2: temp_dly_2term
    port map(
        CLK => CLK,
        LRSTb  => LRSTb,
        PLS    => PLS2D,
        TERM   => TERM,
        PLSDD  => PLS4D
    );

temp_dly_2term_inst3: temp_dly_2term
    port map(
        CLK => CLK,
        LRSTb  => LRSTb,
        PLS    => PLS4D,
        TERM   => TERM,
        PLSDD  => PLS6D
    );

temp_dlysel_inst: temp_dlysel
    port map(
        DLY   => DLY,
        PLS0D => PLS0D,
        PLS2D => PLS2D,
        PLS4D => PLS4D,
        PLS6D => PLS6D,
        PLSOhf  => PLSOhf,
        PLSO  => PLSO
    );

temp_plsdrv_inst: temp_plsdrv
    port map(
        CLK => CLK,
        LRSTb   => LRSTb,
        TERM    => TERM,
        PLSO    => PLSO,
        COOL    => COOL,
        ENB     => ENB,
        CLON    => CLON,
        CLP     => CLP,
        HTON    => HTON,
        HTP     => HTP,
        CLPORHTP => CLPORHTP
    );

temp_plsdrv_inst1: temp_plsdrv
    port map(
        CLK => CLK,
        LRSTb   => LRSTb,
        TERM    => TERM,
        PLSO    => PLSOhf,
        COOL    => COOL,
        ENB     => ENB,
        CLON    => open,
        CLP     => open,
        HTON    => open,
        HTP     => open,
        CLPORHTP => CLPORHTPhf
    );

end RTL;
