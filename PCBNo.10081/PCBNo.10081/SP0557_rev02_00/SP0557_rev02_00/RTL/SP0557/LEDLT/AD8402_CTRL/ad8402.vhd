-------------------------------------------------
--File Name : ad8402.vhd
--Project   : 
--
--Date      : 2005/02/28
--Ver       : 0.00
--Doc       : New Release
--Designed by Hideki Kurabayashi
-------------------------------------
--File Name : ad8400.vhd
--Date      : 2008/09/01
--Ver       : 0.10
--Doc       : for AD5206 (Analog Deveices)
--Changed by Yutaka Ikeda
-------------------------------------
--File Name : ad8402.vhd
--Date      : 2010/04/16
--Ver       : 0.20
--Doc       : back to AD8402
--Changed by Yutaka Ikeda
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;
	use ieee.std_logic_arith.all;

entity ad8402 is
	port (
		RESETb		: in  std_logic ;
		CLK_IN		: in  std_logic ;	-- 
		CLK1us_PLS	: in  std_logic ;	-- one pulse / 1us : High Active
		START		: in  std_logic ;	-- High Active
		POTD1		: in  std_logic_vector( 7 downto 0) ;
		POTD2		: in  std_logic_vector( 7 downto 0) ;	-- ver. 0.20
		CS			: out std_logic;
		SDI 		: out std_logic;
		BUSY		: out std_logic;
		NEXT_ST 	: out std_logic
	);
end ad8402;

architecture RTL of ad8402 is

	constant	s0  : integer	:= 0 ;--
	constant	s1  : integer	:= 1 ;--
	constant	s2  : integer	:= 2 ;--
	constant	s3  : integer	:= 3 ;--
	constant	s4  : integer	:= 4 ;--
	constant	s5  : integer	:= 5 ;--
	constant	s6  : integer	:= 6 ;--
	constant	s7  : integer	:= 7 ;--
	constant	s8  : integer	:= 8 ;--
	constant	s9  : integer	:= 9 ;--
--	constant	sA  : integer	:= 10 ;--
--	constant	sB  : integer	:= 11 ;--
--	constant	sC  : integer	:= 12 ;--
--	constant	sD  : integer	:= 13 ;--
--	constant	sE  : integer	:= 14 ;--
--	constant	sF  : integer	:= 15 ;--

	constant	data_size	: integer	:=	10 ;	-- 2 address bit + 8 data bit
--	constant	wait_size	: integer	:=	 2 ;	-- ver. 0.20

	signal	st	: integer	range 0 to 15 ;
	signal	i	: integer	range 0 to data_size ;

	signal	ch1_data	: std_logic_vector( 9 downto 0) ;
	signal	ch2_data	: std_logic_vector( 9 downto 0) ;		-- ver. 0.20

begin

	ch1_data	<= "00" & POTD1 ;
	ch2_data	<= "01" & POTD2 ;		-- ver. 0.20

	process ( CLK_IN )
	begin
		if ( CLK_IN' event and CLK_IN = '1') then
			if ( RESETb = '0') then
				i	 	<= 0 ;
				SDI 	<= '0';
				CS		<= '1';
				BUSY	<= '0';
				NEXT_ST	<= '0';
				st		<= s0;
			else
				if ( CLK1us_PLS = '1') then
					case st is
						when s0	=>
							if ( START = '1') then
								i		<= data_size ;
								SDI		<= '0' ;
								CS		<= '1';
								BUSY	<= '0' ;
								NEXT_ST	<= '0';
								st		<= s1 ;
							else
								i		<= 0 ;
								SDI		<= '0' ;
								CS		<= '1';
								BUSY	<= '0' ;
								NEXT_ST	<= '0';
								st		<= s0 ;
							end if;

						when s1	=>
							if ( i > 1 ) then		-- last channel
								i		<= i - 1 ;
								SDI		<= ch1_data( i - 1 ) ;
								CS		<= '0';
								BUSY	<= '1' ;
								NEXT_ST	<= '0';
								st		<= s1 ;
							else
								i		<= i - 1 ;
								SDI		<= ch1_data( i - 1 ) ;
								CS		<= '0';
								BUSY	<= '1' ;
								NEXT_ST	<= '0';
								st		<= s2 ;
							end if;

						when s2	=>				-- ver. 0.20 : wait state
							i		<= 0 ;
							SDI		<= '0' ;
							CS		<= '1';
							BUSY	<= '1' ;
							NEXT_ST	<= '0';
							st		<= s3 ;

						when s3	=>				-- ver. 0.20 : wait state
							i		<= data_size ;
							SDI		<= '0' ;
							CS		<= '1';
							BUSY	<= '1' ;
							NEXT_ST	<= '0';
							st		<= s4 ;

						when s4	=>				-- ver. 0.20 : ch2 state
							if ( i > 1 ) then		-- last channel
								i		<= i - 1 ;
								SDI		<= ch2_data( i - 1 ) ;
								CS		<= '0';
								BUSY	<= '1' ;
								NEXT_ST	<= '0';
								st		<= s4 ;
							else
								i		<= i - 1 ;
								SDI		<= ch2_data( i - 1 ) ;
								CS		<= '0';
								BUSY	<= '1' ;
								NEXT_ST	<= '1';
								st		<= s9 ;
							end if;

						when s9	=>
							i		<= 0 ;
							SDI		<= '0' ;
							CS		<= '1';
							BUSY	<= '0' ;
							NEXT_ST	<= '0';
							st		<= s0 ;

						when others	=>
							SDI		<= '0' ;
							CS		<= '1';
							BUSY	<= '0' ;
							NEXT_ST	<= '0';
							st		<= s0 ;
					end case;
				end if;
			end if;
		end if;
	end process;

end RTL ;
