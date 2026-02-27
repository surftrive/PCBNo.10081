-------------------------------------------------
--File Name : fc_dec.vhd
--Project	: S3IO
--
--Date		: 2003/12/12
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		:
--Ver		:
--Doc		:
--Changed by
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity fc_dec is
	port(
		NSb			: in std_logic;								-- node select
		IDSb		: in std_logic;								-- ID select
		LGSb		: in std_logic;								-- logger select
		LATCH		: in std_logic;								-- latch signal
		LOAD		: in std_logic;								-- load signal

		REGSEL		: out std_logic;							-- register select(Active High)
		IDSEL		: out std_logic;							-- id select(Active High)
		LOGSEL		: out std_logic;							-- log select(Active High)
		LATCH_L		: out std_logic;							-- local latch signal(Active High)
		LOAD_L		: out std_logic								-- local load signal(Active High)
		);
end fc_dec;

architecture RTL of fc_dec is

begin

	process(NSb,IDSb,LGSb)
	begin
		if(NSb= '0' and IDSb='1' and LGSb='1')	then
			REGSEL 	<= '1';
			IDSEL 	<= '0';
			LOGSEL 	<= '0';
		elsif(NSb= '0' and LGSb='0')	then
			REGSEL 	<= '0';
			IDSEL 	<= '0';
			LOGSEL 	<= '1';
		elsif(NSb= '0' and IDSb='0' and LGSb='1')	then
			REGSEL 	<= '0';
			IDSEL 	<= '1';
			LOGSEL 	<= '0';
		else
			REGSEL 	<= '0';
			IDSEL 	<= '0';
			LOGSEL 	<= '0';
		end if;
	end process;

	LATCH_L <= not (NSb) and LATCH;
	LOAD_L <= not (NSb) and LOAD;
end RTL;
