-------------------------------------------------
--File Name : nd_sel.vhd
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

entity nd_sel is
	port(
		NSb			: in std_logic_vector(15 downto 0);			-- node select
		ND_0		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_1		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_2		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_3		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_4		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_5		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_6		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_7		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_8		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_9		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_10		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_11		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_12		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_13		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_14		: in std_logic_vector(7 downto 0);			-- ID data bus
		ND_15		: in std_logic_vector(7 downto 0);			-- ID data bus

		LDO			: out std_logic_vector(7 downto 0)			-- local data out
		);
end nd_sel;

architecture RTL of nd_sel is

begin

	LDO <=	(ND_0) when	 (NSb(0)='0') else
			(ND_1) when	 (NSb(1)='0') else
			(ND_2) when	 (NSb(2)='0') else
			(ND_3) when	 (NSb(3)='0') else
			(ND_4) when	 (NSb(4)='0') else
			(ND_5) when	 (NSb(5)='0') else
			(ND_6) when	 (NSb(6)='0') else
			(ND_7) when	 (NSb(7)='0') else
			(ND_8) when	 (NSb(8)='0') else
			(ND_9) when	 (NSb(9)='0') else
			(ND_10) when (NSb(10)='0') else
			(ND_11) when (NSb(11)='0') else
			(ND_12) when (NSb(12)='0') else
			(ND_13) when (NSb(13)='0') else
			(ND_14) when (NSb(14)='0') else
			(ND_15) when (NSb(15)='0') else
			(others => '0');


end RTL;
