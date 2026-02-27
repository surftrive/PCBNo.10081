-------------------------------------------------
--File Name : cds.vhd
--Project   : S3IO
--
--Date      : 2003/03/30
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date		: 2004/05/19
--Ver		: 2.00
--Doc		: Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date		: 2007/01/11
--Ver		: 3.00
--Doc		: [data select process]
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

entity cds is
	port(
		CLK2			: in std_logic;			-- Clock 100MHZ
		CLK2A			: in std_logic;			-- Clock 100MHZ_90
--		nRESET			: in std_logic;			-- power on reset

		nRESET_CLK2p	: in std_logic;			-- add Nakatsuka
		nRESET_CLK2n	: in std_logic;			-- add Nakatsuka
		nRESET_CLK2Ap	: in std_logic;			-- add Nakatsuka
		nRESET_CLK2An	: in std_logic;			-- add Nakatsuka

		RX_D			: in std_logic;			-- rx_data_in
		RX_DT			: out std_logic			-- rx_data

--		RX_DA			: out std_logic;
--		RX_DB			: out std_logic;
--		RX_DC			: out std_logic;
--		RX_DD			: out std_logic;

--		DATA_SEL_O		: out std_logic_vector(1 downto 0)
		);
end cds;

-- [OPTIMIZATION CANDIDATE] az register width reduction: 10-bit -> 5-bit
-- az(5)-az(9) are only used in idle detection comparison (az = "0000000000").
-- Reducing to 5-bit would change idle detection timing from 100ns to 50ns @100MHz.
-- NOT IMPLEMENTED: This constitutes a timing behavior change.
-- Estimated savings: 5 FF + ~5 LUT per instance

architecture RTL of cds is

	signal	az		 	: std_logic_vector( 9 downto 0);	--2007/01/11
	signal	bz		 	: std_logic_vector( 4 downto 0);
	signal	cz		 	: std_logic_vector( 4 downto 0);
	signal	dz		 	: std_logic_vector( 4 downto 0);
	signal  aap,aan		: std_logic;
	signal	bbp,bbn	 	: std_logic;
	signal  ccp,ccn	 	: std_logic;
	signal  ddp,ddn	 	: std_logic;
	signal  data_selp 	: std_logic_vector( 3 downto 0);
	signal  data_seln 	: std_logic_vector( 3 downto 0);
	signal  data_sel 	: std_logic_vector( 1 downto 0);

	signal	hit_domain_a	: std_logic;
	signal	hit_domain_b	: std_logic;
	signal	hit_domain_c	: std_logic;
	signal	hit_domain_d	: std_logic;

	signal	not_domain_b	: std_logic;
	signal	not_domain_c	: std_logic;

begin

--******************************************--
--				input stage 				--
--******************************************--
--*** time_domain A ***--
	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			az <= "0000000000";
		elsif(CLK2'event and CLK2 ='1') then
			az(0)  <= RX_D;
			az(1)  <= az(0);
			az(2)  <= az(1);
			az(3)  <= az(2);
			az(4)  <= az(3);
			az(5)  <= az(4);	--2007/01/11
			az(6)  <= az(5);	--2007/01/11
			az(7)  <= az(6);	--2007/01/11
			az(8)  <= az(7);	--2007/01/11
			az(9)  <= az(8);	--2007/01/11
		end if;
	end process;

--*** time_domain B ***--
	process(CLK2A,nRESET_CLK2Ap)
	begin
		if(nRESET_CLK2Ap='0') then
			bz(0) <= '0';
		elsif(CLK2A'event and CLK2A ='1') then
			bz(0)  <= RX_D;
		end if;
	end process;

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			bz(4 downto 1) <= "0000";
		elsif(CLK2'event and CLK2 ='1') then
			bz(1)  <= bz(0);
			bz(2)  <= bz(1);
			bz(3)  <= bz(2);
			bz(4)  <= bz(3);
		end if;
	end process;

--*** time_domain C ***--
	process(CLK2,nRESET_CLK2n)
	begin
		if(nRESET_CLK2n='0') then
			cz(0) <= '0';
		elsif(CLK2'event and CLK2 ='0') then
			cz(0)  <= RX_D;
		end if;
	end process;

	process(CLK2A,nRESET_CLK2Ap)
	begin
		if(nRESET_CLK2Ap='0') then
			cz(1) <= '0';
		elsif(CLK2A'event and CLK2A ='1') then
			cz(1)  <= cz(0);
		end if;
	end process;

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			cz(4 downto 2) <= "000";
		elsif(CLK2'event and CLK2 ='1') then
			cz(2)  <= cz(1);
			cz(3)  <= cz(2);
			cz(4)  <= cz(3);
		end if;
	end process;

--*** time_domain D ***--
	process(CLK2A,nRESET_CLK2An)
	begin
		if(nRESET_CLK2An='0') then
			dz(0) <= '0';
		elsif(CLK2A'event and CLK2A ='0') then
			dz(0)  <= RX_D;
		end if;
	end process;

	process(CLK2,nRESET_CLK2n)
	begin
		if(nRESET_CLK2n='0') then
			dz(1) <= '0';
		elsif(CLK2'event and CLK2 ='0') then
			dz(1)  <= dz(0);
		end if;
	end process;

	process(CLK2A,nRESET_CLK2Ap)
	begin
		if(nRESET_CLK2Ap='0') then
			dz(2) <= '0';
		elsif(CLK2A'event and CLK2A ='1') then
			dz(2)  <= dz(1);
		end if;
	end process;

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			dz(4 downto 3) <= "00";
		elsif(CLK2'event and CLK2 ='1') then
			dz(3)  <= dz(2);
			dz(4)  <= dz(3);
		end if;
	end process;

--******************************************--
--				decision stage 				--
--******************************************--
	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			aan <= '0';
			bbn <= '0';
			ccn <= '0';
			ddn <= '0';
		elsif(CLK2'event and CLK2 ='1') then
			aan  <= not az(3) and az(4);
			bbn  <= not bz(3) and bz(4);
			ccn  <= not cz(3) and cz(4);
			ddn  <= not dz(3) and dz(4);
		end if;
	end process;

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			aap <= '0';
			bbp <= '0';
			ccp <= '0';
			ddp <= '0';
		elsif(CLK2'event and CLK2 ='1') then
			aap  <= az(3) and not az(4);
			bbp  <= bz(3) and not bz(4);
			ccp  <= cz(3) and not cz(4);
			ddp  <= dz(3) and not dz(4);
		end if;
	end process;

--******************************************--
--				data select 				--
--******************************************--
	data_selp  <= (aap & bbp & ccp & ddp);
	data_seln  <= (aan & bbn & ccn & ddn);

	hit_domain_a	<= '1' when	(( data_selp = "1111" ) or ( data_seln = "1111" )) else '0';
	hit_domain_b	<= '1' when	(( data_selp = "1000" ) or ( data_seln = "1000" )) else '0';
	hit_domain_c	<= '1' when	(( data_selp = "1100" ) or ( data_seln = "1100" )) else '0';
	hit_domain_d	<= '1' when	(( data_selp = "1110" ) or ( data_seln = "1110" )) else '0';

	not_domain_b	<= '0' when ( data_sel = "01" ) else '1';				--2007/01/11
	not_domain_c	<= '0' when ( data_sel = "10" ) else '1';

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			data_sel <= "01";
		elsif(CLK2'event and CLK2 ='1') then
			if( hit_domain_a = '1' or az ="0000000000" ) then				--2007/01/11
				data_sel  <= "00";
			elsif( hit_domain_b = '1' and not_domain_c = '1' ) then
				data_sel  <= "01";
			elsif( hit_domain_c = '1' and not_domain_b = '1' ) then			--2007/01/11
				data_sel  <= "10";
			elsif( hit_domain_d = '1') then
				data_sel  <= "11";
			else
				data_sel <= data_sel;
			end if;
		end if;
	end process;

	process(CLK2,nRESET_CLK2p)
	begin
		if(nRESET_CLK2p='0') then
			RX_DT <= '0';
		elsif(CLK2'event and CLK2 ='1') then
			case(data_sel) is
				when "00" => 	RX_DT 	<= cz(4);			-- time_domain C
				when "01" => 	RX_DT 	<= dz(4);			-- time_domain D
				when "10" => 	RX_DT 	<= az(4);			-- time_domain A
				when "11" => 	RX_DT 	<= bz(4);			-- time_domain B
				when others => null;
			end case;
		end if;
	end process;

end RTL ;



