-------------------------------------------------
--File Name : temp_ctrl.vhd
--Project   : 4CH TEMPERATURE CONTROL IP
--
--Date      : 2003/07/18
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 
--Ver       : 
--Doc       : 
--Changed by 
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity temp_ctrl is
	port ( CLK :in std_logic;
			 LRSTb :in std_logic;
			 TEMP_WRP :in std_logic;
			 TEMP_CH :in std_logic_vector(1 downto 0);
			 MEAS :in std_logic_vector(11 downto 0);
			 REF : in std_logic_vector(11 downto 0);
			 AJST : in std_logic_vector(7 downto 0);
			 CLHTb :in std_logic;
			 NUM : out std_logic_vector(2 downto 0);
			 NEG : out std_logic;
			 NUM_WRP : out std_logic;
			 PRM_CH : out std_logic_vector(1 downto 0));
end temp_ctrl;

architecture RTL of temp_ctrl is

constant IDLE    : std_logic_vector(2 downto 0) := "000";
constant NOP1    : std_logic_vector(2 downto 0) := "001";
constant SUBSET  : std_logic_vector(2 downto 0) := "011";
constant NOP2    : std_logic_vector(2 downto 0) := "010";
constant NEGSET  : std_logic_vector(2 downto 0) := "110";
constant SUBST   : std_logic_vector(2 downto 0) := "111";
constant CNTUP   : std_logic_vector(2 downto 0) := "101";
constant NOP3    : std_logic_vector(2 downto 0) := "100";

signal st : std_logic_vector(2 downto 0);
signal sub : std_logic_vector(12 downto 0);
signal ajstreg : std_logic_vector(7 downto 0);
signal numreg : std_logic_vector(2 downto 0);
signal count : std_logic_vector(2 downto 0);

begin

	NUM <= numreg;

	process (CLK, LRSTb) begin
		if (LRSTb = '0' ) then
			st <= IDLE;
      	PRM_CH <= "00";
      	NEG <= '1';  -- Inhibit TEMP ctrl
      	numreg <= "000";
      	NUM_WRP <= '0';
		elsif (CLK'event and CLK = '1') then
			case st is
				when IDLE =>
					NUM_WRP <= '0';
					if (TEMP_WRP = '1') then
						PRM_CH <= TEMP_CH;
		 		   	st <= NOP1;
					else
						st <= IDLE;
					end if;
				when NOP1 =>
					st <= SUBSET;
				when SUBSET =>
					if (CLHTb = '1') then
						sub <= ('0' & MEAS) - ('0' & REF );
 				   else
						sub <= ('0' & REF ) - ('0' & MEAS);
					end if;
					ajstreg <= AJST;
					st <= NOP2;
				when NOP2 =>
					st <= NEGSET;
				when NEGSET =>
					NEG <= sub(12);
					numreg <= "000";
					count <= "000";
					st <= SUBST;
				when SUBST =>
					sub <= sub - ("00000" & ajstreg);
					st <= CNTUP;
				when CNTUP =>
					if (count = "111") then
						NUM_WRP <= '1';
						st <= NOP3;
					else
						count <= count + "001";
						st <= SUBST;
						if (sub(12) = '0') then
							numreg <= numreg + "001";
						end if;
					end if;
				when NOP3 =>
					st <= IDLE;
					NUM_WRP <= '0';
				when others =>
					st <= IDLE;
	      		NEG <= '1';  -- Inhibit TEMP ctrl
	      		numreg <= "000";
	      		NUM_WRP <= '0';
			end case;
		end if;
	end process;

end RTL;
