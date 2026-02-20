-------------------------------------------------
--File Name : gpio_reg.vhd
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

entity gpio_reg is
	port(
		CLK			: in std_logic;								-- clock 20MHz
		LRSTb		: in std_logic;								-- local reset
		LDI			: in std_logic_vector(7 downto 0);			-- local data in
		LA			: in std_logic_vector(4 downto 0);			-- local address
		REGSEL		: in std_logic;								-- regster select
		LWEb		: in std_logic;								-- local write enable
		LRDb		: in std_logic;								-- local read enable
		LATCH_L		: in std_logic;								-- local latch
		LOAD_L		: in std_logic;								-- local load
		REGDO		: out std_logic_vector(7 downto 0);			-- regster data out

		-- GPIO --
		GPI_0		: in std_logic_vector(7 downto 0);
		GPI_1		: in std_logic_vector(7 downto 0);
		GPI_2		: in std_logic_vector(7 downto 0);
		GPI_3		: in std_logic_vector(7 downto 0);
		GPI_4		: in std_logic_vector(7 downto 0);
		GPI_5		: in std_logic_vector(7 downto 0);
		GPI_6		: in std_logic_vector(7 downto 0);
		GPI_7		: in std_logic_vector(7 downto 0);
		GPI_8		: in std_logic_vector(7 downto 0);
		GPI_9		: in std_logic_vector(7 downto 0);
		GPI_10		: in std_logic_vector(7 downto 0);
		GPI_11		: in std_logic_vector(7 downto 0);
		GPI_12		: in std_logic_vector(7 downto 0);
		GPI_13		: in std_logic_vector(7 downto 0);
		GPI_14		: in std_logic_vector(7 downto 0);
		GPI_15		: in std_logic_vector(7 downto 0);
		GPI_16		: in std_logic_vector(7 downto 0);
		GPI_17		: in std_logic_vector(7 downto 0);
		GPI_18		: in std_logic_vector(7 downto 0);
		GPI_19		: in std_logic_vector(7 downto 0);
		GPI_20		: in std_logic_vector(7 downto 0);
		GPI_21		: in std_logic_vector(7 downto 0);
		GPI_22		: in std_logic_vector(7 downto 0);
		GPI_23		: in std_logic_vector(7 downto 0);
		GPI_24		: in std_logic_vector(7 downto 0);
		GPI_25		: in std_logic_vector(7 downto 0);
		GPI_26		: in std_logic_vector(7 downto 0);
		GPI_27		: in std_logic_vector(7 downto 0);
		GPI_28		: in std_logic_vector(7 downto 0);
		GPI_29		: in std_logic_vector(7 downto 0);
		GPI_30		: in std_logic_vector(7 downto 0);
		GPI_31		: in std_logic_vector(7 downto 0);
		GPO_0		: out std_logic_vector(7 downto 0);
		GPO_1		: out std_logic_vector(7 downto 0);
		GPO_2		: out std_logic_vector(7 downto 0);
		GPO_3		: out std_logic_vector(7 downto 0);
		GPO_4		: out std_logic_vector(7 downto 0);
		GPO_5		: out std_logic_vector(7 downto 0);
		GPO_6		: out std_logic_vector(7 downto 0);
		GPO_7		: out std_logic_vector(7 downto 0);
		GPO_8		: out std_logic_vector(7 downto 0);
		GPO_9		: out std_logic_vector(7 downto 0);
		GPO_10		: out std_logic_vector(7 downto 0);
		GPO_11		: out std_logic_vector(7 downto 0);
		GPO_12		: out std_logic_vector(7 downto 0);
		GPO_13		: out std_logic_vector(7 downto 0);
		GPO_14		: out std_logic_vector(7 downto 0);
		GPO_15		: out std_logic_vector(7 downto 0);
		GPO_16		: out std_logic_vector(7 downto 0);
		GPO_17		: out std_logic_vector(7 downto 0);
		GPO_18		: out std_logic_vector(7 downto 0);
		GPO_19		: out std_logic_vector(7 downto 0);
		GPO_20		: out std_logic_vector(7 downto 0);
		GPO_21		: out std_logic_vector(7 downto 0);
		GPO_22		: out std_logic_vector(7 downto 0);
		GPO_23		: out std_logic_vector(7 downto 0);
		GPO_24		: out std_logic_vector(7 downto 0);
		GPO_25		: out std_logic_vector(7 downto 0);
		GPO_26		: out std_logic_vector(7 downto 0);
		GPO_27		: out std_logic_vector(7 downto 0);
		GPO_28		: out std_logic_vector(7 downto 0);
		GPO_29		: out std_logic_vector(7 downto 0);
		GPO_30		: out std_logic_vector(7 downto 0);
		GPO_31		: out std_logic_vector(7 downto 0)
		);
end gpio_reg;

architecture RTL of gpio_reg is

component gpio_op_reg
	port(
		CLK			: in std_logic;								-- clock 20MHz
		LRSTb		: in std_logic;								-- local reset
		LDI			: in std_logic_vector(7 downto 0);			-- local data in
		REGSEL		: in std_logic;								-- regster select
		LWEb		: in std_logic;								-- local write enable
		LATCH_L		: in std_logic;								-- local latch
		GPO			: out std_logic_vector(7 downto 0)			-- parallel out
		);
end component;

component gpio_ip_reg
	port(
		CLK			: in std_logic;								-- clock 20MHz
		LRSTb		: in std_logic;								-- local reset
		REGSEL		: in std_logic;								-- regster select
		LRDb		: in std_logic;								-- local read enable
		LOAD_L		: in std_logic;								-- local load
		REGDO		: out std_logic_vector(7 downto 0);			-- regster data out
		GPI			: in std_logic_vector(7 downto 0)			-- parallel in
		);
end component;

	signal REGSEL0		: std_logic;
	signal REGSEL1		: std_logic;
	signal REGSEL2		: std_logic;
	signal REGSEL3		: std_logic;
	signal REGSEL4		: std_logic;
	signal REGSEL5		: std_logic;
	signal REGSEL6		: std_logic;
	signal REGSEL7		: std_logic;
	signal REGSEL8		: std_logic;
	signal REGSEL9		: std_logic;
	signal REGSEL10		: std_logic;
	signal REGSEL11		: std_logic;
	signal REGSEL12		: std_logic;
	signal REGSEL13		: std_logic;
	signal REGSEL14		: std_logic;
	signal REGSEL15		: std_logic;
	signal REGSEL16		: std_logic;
	signal REGSEL17		: std_logic;
	signal REGSEL18		: std_logic;
	signal REGSEL19		: std_logic;
	signal REGSEL20		: std_logic;
	signal REGSEL21		: std_logic;
	signal REGSEL22		: std_logic;
	signal REGSEL23		: std_logic;
	signal REGSEL24		: std_logic;
	signal REGSEL25		: std_logic;
	signal REGSEL26		: std_logic;
	signal REGSEL27		: std_logic;
	signal REGSEL28		: std_logic;
	signal REGSEL29		: std_logic;
	signal REGSEL30		: std_logic;
	signal REGSEL31		: std_logic;
	signal REGDO_0		: std_logic_vector( 7 downto 0);
	signal REGDO_1		: std_logic_vector( 7 downto 0);
	signal REGDO_2		: std_logic_vector( 7 downto 0);
	signal REGDO_3		: std_logic_vector( 7 downto 0);
	signal REGDO_4		: std_logic_vector( 7 downto 0);
	signal REGDO_5		: std_logic_vector( 7 downto 0);
	signal REGDO_6		: std_logic_vector( 7 downto 0);
	signal REGDO_7		: std_logic_vector( 7 downto 0);
	signal REGDO_8		: std_logic_vector( 7 downto 0);
	signal REGDO_9		: std_logic_vector( 7 downto 0);
	signal REGDO_10		: std_logic_vector( 7 downto 0);
	signal REGDO_11		: std_logic_vector( 7 downto 0);
	signal REGDO_12		: std_logic_vector( 7 downto 0);
	signal REGDO_13		: std_logic_vector( 7 downto 0);
	signal REGDO_14		: std_logic_vector( 7 downto 0);
	signal REGDO_15		: std_logic_vector( 7 downto 0);
	signal REGDO_16		: std_logic_vector( 7 downto 0);
	signal REGDO_17		: std_logic_vector( 7 downto 0);
	signal REGDO_18		: std_logic_vector( 7 downto 0);
	signal REGDO_19		: std_logic_vector( 7 downto 0);
	signal REGDO_20		: std_logic_vector( 7 downto 0);
	signal REGDO_21		: std_logic_vector( 7 downto 0);
	signal REGDO_22		: std_logic_vector( 7 downto 0);
	signal REGDO_23		: std_logic_vector( 7 downto 0);
	signal REGDO_24		: std_logic_vector( 7 downto 0);
	signal REGDO_25		: std_logic_vector( 7 downto 0);
	signal REGDO_26		: std_logic_vector( 7 downto 0);
	signal REGDO_27		: std_logic_vector( 7 downto 0);
	signal REGDO_28		: std_logic_vector( 7 downto 0);
	signal REGDO_29		: std_logic_vector( 7 downto 0);
	signal REGDO_30		: std_logic_vector( 7 downto 0);
	signal REGDO_31		: std_logic_vector( 7 downto 0);

begin

	REGSEL0		<= REGSEL when LA="00000" else '0';
	REGSEL1		<= REGSEL when LA="00001" else '0';
	REGSEL2		<= REGSEL when LA="00010" else '0';
	REGSEL3		<= REGSEL when LA="00011" else '0';
	REGSEL4		<= REGSEL when LA="00100" else '0';
	REGSEL5		<= REGSEL when LA="00101" else '0';
	REGSEL6		<= REGSEL when LA="00110" else '0';
	REGSEL7		<= REGSEL when LA="00111" else '0';
	REGSEL8		<= REGSEL when LA="01000" else '0';
	REGSEL9		<= REGSEL when LA="01001" else '0';
	REGSEL10	<= REGSEL when LA="01010" else '0';
	REGSEL11	<= REGSEL when LA="01011" else '0';
	REGSEL12	<= REGSEL when LA="01100" else '0';
	REGSEL13	<= REGSEL when LA="01101" else '0';
	REGSEL14	<= REGSEL when LA="01110" else '0';
	REGSEL15	<= REGSEL when LA="01111" else '0';
	REGSEL16	<= REGSEL when LA="10000" else '0';
	REGSEL17	<= REGSEL when LA="10001" else '0';
	REGSEL18	<= REGSEL when LA="10010" else '0';
	REGSEL19	<= REGSEL when LA="10011" else '0';
	REGSEL20	<= REGSEL when LA="10100" else '0';
	REGSEL21	<= REGSEL when LA="10101" else '0';
	REGSEL22	<= REGSEL when LA="10110" else '0';
	REGSEL23	<= REGSEL when LA="10111" else '0';
	REGSEL24	<= REGSEL when LA="11000" else '0';
	REGSEL25	<= REGSEL when LA="11001" else '0';
	REGSEL26	<= REGSEL when LA="11010" else '0';
	REGSEL27	<= REGSEL when LA="11011" else '0';
	REGSEL28	<= REGSEL when LA="11100" else '0';
	REGSEL29	<= REGSEL when LA="11101" else '0';
	REGSEL30	<= REGSEL when LA="11110" else '0';
	REGSEL31	<= REGSEL when LA="11111" else '0';

	REGDO	<=	REGDO_0 or REGDO_1 or REGDO_2 or REGDO_3 or
				REGDO_4 or REGDO_5 or REGDO_6 or REGDO_7 or
				REGDO_8 or REGDO_9 or REGDO_10 or REGDO_11 or
				REGDO_12 or REGDO_13 or REGDO_14 or REGDO_15 or
				REGDO_16 or REGDO_17 or REGDO_18 or REGDO_19 or
				REGDO_20 or REGDO_21 or REGDO_22 or REGDO_23 or
				REGDO_24 or REGDO_25 or REGDO_26 or REGDO_27 or
				REGDO_28 or REGDO_29 or REGDO_30 or REGDO_31;

--****************************************--
--**		 component port assign		**--
--****************************************--

gpio_op_reg_inst0 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL0,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_0
		);

gpio_ip_reg_inst0 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL0,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_0,
		GPI		=> GPI_0
		);

gpio_op_reg_inst1 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL1,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_1
		);

gpio_ip_reg_inst1 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL1,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_1,
		GPI		=> GPI_1
		);
gpio_op_reg_inst2 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL2,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_2
		);

gpio_ip_reg_inst2 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL2,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_2,
		GPI		=> GPI_2
		);
gpio_op_reg_inst3 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL3,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_3
		);

gpio_ip_reg_inst3 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL3,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_3,
		GPI		=> GPI_3
		);
gpio_op_reg_inst4 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL4,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_4
		);

gpio_ip_reg_inst4 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL4,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_4,
		GPI		=> GPI_4
		);
gpio_op_reg_inst5 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL5,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_5
		);

gpio_ip_reg_inst5 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL5,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_5,
		GPI		=> GPI_5
		);
gpio_op_reg_inst6 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL6,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_6
		);

gpio_ip_reg_inst6 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL6,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_6,
		GPI		=> GPI_6
		);
gpio_op_reg_inst7 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL7,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_7
		);

gpio_ip_reg_inst7 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL7,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_7,
		GPI		=> GPI_7
		);
gpio_op_reg_inst8 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL8,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_8
		);

gpio_ip_reg_inst8 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL8,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_8,
		GPI		=> GPI_8
		);
gpio_op_reg_inst9 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL9,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_9
		);

gpio_ip_reg_inst9 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL9,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_9,
		GPI		=> GPI_9
		);
gpio_op_reg_inst10 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL10,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_10
		);

gpio_ip_reg_inst10 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL10,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_10,
		GPI		=> GPI_10
		);
gpio_op_reg_inst11 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL11,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_11
		);

gpio_ip_reg_inst11 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL11,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_11,
		GPI		=> GPI_11
		);
gpio_op_reg_inst12 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL12,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_12
		);

gpio_ip_reg_inst12 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL12,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_12,
		GPI		=> GPI_12
		);
gpio_op_reg_inst13 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL13,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_13
		);

gpio_ip_reg_inst13 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL13,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_13,
		GPI		=> GPI_13
		);
gpio_op_reg_inst14 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL14,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_14
		);

gpio_ip_reg_inst14 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL14,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_14,
		GPI		=> GPI_14
		);
gpio_op_reg_inst15 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL15,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_15
		);

gpio_ip_reg_inst15 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL15,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_15,
		GPI		=> GPI_15
		);
gpio_op_reg_inst16 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL16,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_16
		);

gpio_ip_reg_inst16 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL16,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_16,
		GPI		=> GPI_16
		);
gpio_op_reg_inst17 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL17,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_17
		);

gpio_ip_reg_inst17 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL17,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_17,
		GPI		=> GPI_17
		);
gpio_op_reg_inst18 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL18,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_18
		);

gpio_ip_reg_inst18 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL18,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_18,
		GPI		=> GPI_18
		);
gpio_op_reg_inst19 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL19,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_19
		);

gpio_ip_reg_inst19 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL19,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_19,
		GPI		=> GPI_19
		);
gpio_op_reg_inst20 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL20,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_20
		);

gpio_ip_reg_inst20 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL20,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_20,
		GPI		=> GPI_20
		);
gpio_op_reg_inst21 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL21,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_21
		);

gpio_ip_reg_inst21 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL21,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_21,
		GPI		=> GPI_21
		);
gpio_op_reg_inst22 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL22,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_22
		);

gpio_ip_reg_inst22 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL22,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_22,
		GPI		=> GPI_22
		);
gpio_op_reg_inst23 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL23,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_23
		);

gpio_ip_reg_inst23 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL23,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_23,
		GPI		=> GPI_23
		);
gpio_op_reg_inst24 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL24,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_24
		);

gpio_ip_reg_inst24 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL24,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_24,
		GPI		=> GPI_24
		);
gpio_op_reg_inst25 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL25,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_25
		);

gpio_ip_reg_inst25 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL25,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_25,
		GPI		=> GPI_25
		);
gpio_op_reg_inst26 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL26,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_26
		);

gpio_ip_reg_inst26 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL26,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_26,
		GPI		=> GPI_26
		);
gpio_op_reg_inst27 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL27,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_27
		);

gpio_ip_reg_inst27 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL27,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_27,
		GPI		=> GPI_27
		);
gpio_op_reg_inst28 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL28,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_28
		);

gpio_ip_reg_inst28 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL28,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_28,
		GPI		=> GPI_28
		);
gpio_op_reg_inst29 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL29,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_29
		);

gpio_ip_reg_inst29 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL29,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_29,
		GPI		=> GPI_29
		);
gpio_op_reg_inst30 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL30,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_30
		);

gpio_ip_reg_inst30 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL30,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_30,
		GPI		=> GPI_30
		);
gpio_op_reg_inst31 : gpio_op_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		LDI		=> LDI,
		REGSEL	=> REGSEL31,
		LWEb	=> LWEb,
		LATCH_L	=> LATCH_L,
		GPO		=> GPO_31
		);

gpio_ip_reg_inst31 : gpio_ip_reg port map (
		CLK		=> CLK,
		LRSTb	=> LRSTb,
		REGSEL	=> REGSEL31,
		LRDb	=> LRDb,
		LOAD_L	=> LOAD_L,
		REGDO	=> REGDO_31,
		GPI		=> GPI_31
		);

end RTL;
