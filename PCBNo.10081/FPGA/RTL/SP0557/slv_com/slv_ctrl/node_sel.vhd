-------------------------------------------------
--File Name : node_sel.vhd
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

entity node_sel is
	port(
		NODE		: in std_logic_vector( 3 downto 0);		-- NODE
		BC			: in std_logic;							-- blode cast

		nNS			: out std_logic_vector( 15 downto 0)	-- node select out

		);
end node_sel;

architecture RTL of node_sel is

begin

-- Local bus  node select

	process(BC,NODE)
	begin
		if(BC='1') then
			nNS			 <= "0000000000000000";
		elsif(NODE="0000") then
			nNS			 <= "1111111111111110";
		elsif(NODE="0001") then
			nNS			 <= "1111111111111101";
		elsif(NODE="0010") then
			nNS			 <= "1111111111111011";
		elsif(NODE="0011") then
			nNS			 <= "1111111111110111";
		elsif(NODE="0100") then
			nNS			 <= "1111111111101111";
		elsif(NODE="0101") then
			nNS			 <= "1111111111011111";
		elsif(NODE="0110") then
			nNS			 <= "1111111110111111";
		elsif(NODE="0111") then
			nNS			 <= "1111111101111111";
		elsif(NODE="1000") then
			nNS			 <= "1111111011111111";
		elsif(NODE="1001") then
			nNS			 <= "1111110111111111";
		elsif(NODE="1010") then
			nNS			 <= "1111101111111111";
		elsif(NODE="1011") then
			nNS			 <= "1111011111111111";
		elsif(NODE="1100") then
			nNS			 <= "1110111111111111";
		elsif(NODE="1101") then
			nNS			 <= "1101111111111111";
		elsif(NODE="1110") then
			nNS			 <= "1011111111111111";
		elsif(NODE="1111") then
			nNS			 <= "0111111111111111";
		else
			nNS			 <= "1111111111111111";
		end if;
	end process;


end RTL;
