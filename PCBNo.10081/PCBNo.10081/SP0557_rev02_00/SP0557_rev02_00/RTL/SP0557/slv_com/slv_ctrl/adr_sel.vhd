-------------------------------------------------
--File Name : adr_sel.vhd
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

entity adr_sel is
	port(
		LA_RX		: in std_logic_vector( 4 downto 0);			-- rx local address
		LA_TX		: in std_logic_vector( 4 downto 0);			-- tx local address
		RX_F		: in std_logic;								-- rx flag
		BANK		: in std_logic_vector( 6 downto 0);			-- logger bank

		LA			: out std_logic_vector(11 downto 0)			-- local address
		);
end adr_sel;

architecture RTL of adr_sel is

begin

--	local address select
	LA <=	(BANK & LA_RX) when (RX_F='1') else
			(BANK & LA_TX);

end RTL;
