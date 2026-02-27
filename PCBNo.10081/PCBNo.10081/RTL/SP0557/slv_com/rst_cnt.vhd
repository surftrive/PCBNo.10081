-------------------------------------------------
--File Name : rst_cnt.vhd
--Project	: S3IO
--
--Date		: 2004/01/19
--Ver		: 0.00
--Doc		: New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity rst_cnt is
	port(
		LOCAL_CLK		: in std_logic;		-- Clock 10MHZ
		LOCKED_RST		: in std_logic;		-- PLL Reset

		CLK2			: in std_logic;		-- add Nakatsuka
		CLK2A			: in std_logic;		-- add Nakatsuka

		CLK_RSTb		: out std_logic;

		CLK2p_RSTb		: out std_logic;	-- add Nakatsuka
		CLK2n_RSTb		: out std_logic;	-- add Nakatsuka

		CLK2Ap_RSTb		: out std_logic;	-- add Nakatsuka
		CLK2An_RSTb		: out std_logic		-- add Nakatsuka

		);
end rst_cnt;

architecture RTL of rst_cnt is

signal	clk_cntr	: std_logic_vector( 8 downto 0);

signal	clk2p_cntr	: std_logic_vector( 8 downto 0);	-- add Nakatsuka
signal	clk2n_cntr	: std_logic_vector( 8 downto 0);	-- add Nakatsuka

signal	clk2Ap_cntr	: std_logic_vector( 8 downto 0);	-- add Nakatsuka
signal	clk2An_cntr	: std_logic_vector( 8 downto 0);	-- add Nakatsuka

begin

	CLK_RSTb	<= not clk_cntr(8);
	CLK2p_RSTb	<= not clk2p_cntr(8);	-- add Nakatsuka
	CLK2n_RSTb	<= not clk2n_cntr(8);	-- add Nakatsuka
	CLK2Ap_RSTb	<= not clk2Ap_cntr(8);	-- add Nakatsuka
	CLK2An_RSTb	<= not clk2An_cntr(8);	-- add Nakatsuka


	process(LOCAL_CLK, LOCKED_RST)
	begin
		if (LOCKED_RST = '1') then
			clk_cntr <= (others => '0');
		elsif (LOCAL_CLK'event and LOCAL_CLK = '1') then
			if (clk_cntr(8) = '0') then
				clk_cntr <= clk_cntr + 1;
			end if;
		end if;
	end process;

---CLK2 positive edge syncronization ------------ add Nakatsuka
	process(CLK2, LOCKED_RST)
	begin
		if (LOCKED_RST = '1') then
			clk2p_cntr <= (others => '0');
		elsif (CLK2'event and CLK2 = '1') then
			if (clk2p_cntr(8) = '0') then
				clk2p_cntr <= clk2p_cntr + 1;
			end if;
		end if;
	end process;

---CLK2 negative edge syncronization ------------ add Nakatsuka
	process(CLK2, LOCKED_RST)
	begin
		if (LOCKED_RST = '1') then
			clk2n_cntr <= (others => '0');
		elsif (CLK2'event and CLK2 = '0') then
			if (clk2n_cntr(8) = '0') then
				clk2n_cntr <= clk2n_cntr + 1;
			end if;
		end if;
	end process;

---CLK2A positive edge syncronization ------------ add Nakatsuka
	process(CLK2A, LOCKED_RST)
	begin
		if (LOCKED_RST = '1') then
			clk2Ap_cntr <= (others => '0');
		elsif (CLK2A'event and CLK2A = '1') then
			if (clk2Ap_cntr(8) = '0') then
				clk2Ap_cntr <= clk2Ap_cntr + 1;
			end if;
		end if;
	end process;

---CLK2A negative edge syncronization ------------ add Nakatsuka
	process(CLK2A, LOCKED_RST)
	begin
		if (LOCKED_RST = '1') then
			clk2An_cntr <= (others => '0');
		elsif (CLK2A'event and CLK2A = '0') then
			if (clk2An_cntr(8) = '0') then
				clk2An_cntr <= clk2An_cntr + 1;
			end if;
		end if;
	end process;

end RTL;
