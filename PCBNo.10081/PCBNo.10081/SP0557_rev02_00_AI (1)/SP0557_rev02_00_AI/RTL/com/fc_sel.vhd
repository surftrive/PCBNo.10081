-------------------------------------------------
--File Name : fc_sel.vhd
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

entity fc_sel is
	port(
		NSb			: in std_logic;								-- node select
		IDDO		: in std_logic_vector(7 downto 0);			-- ID data bus
		LOGDO		: in std_logic_vector(7 downto 0);			-- LOG data bus
		REGDO		: in std_logic_vector(7 downto 0);			-- regster data bus

		LDO			: out std_logic_vector(7 downto 0)			-- local data out
		);
end fc_sel;

architecture RTL of fc_sel is

begin

	LDO <= (REGDO or IDDO or LOGDO) when (NSb='0') else
			(others => '0');


end RTL;
