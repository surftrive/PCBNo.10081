----------------------------------------------------------------------------------------------------
--File Name	: TLC5916_CTRL.vhd
--Project	: S127M(S3IO)
--Date		: 2025.11.20
--Ver		: 00_00
--Doc		: New Release
--			: S127M PCB No.10081
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

------------------------entity----------------------------------------------------------------------
entity TLC5916_CTRL is
	port (
		CLK			: in	std_logic;
		RST_n		: in	std_logic;	-- async reset (Act.L)
		CLK500k		: in	std_logic;	-- SCLK base : 500kHz(duty 50%)
		CKEN500k	: in	std_logic;	-- clock enable 500kHz

		SDATA		: in	std_logic_vector(15 downto 0);
		START		: in	std_logic;
		BUSY		: out	std_logic;
		FIN			: out	std_logic;

		LE			: out	std_logic;
		OEb			: out	std_logic;
		SCLK		: out	std_logic;
		SD			: out	std_logic
	);
end TLC5916_CTRL;
-------------- architecture ------------------------------------------------------------------------
architecture RTL of TLC5916_CTRL is
-------------- constant ----------------------------------------------------------------------------
constant	C_DATA_SIZE		: integer := 16;

--------------- type--------------------------------------------------------------------------------
type		ty_STATE	is (
	st_IDLE,	-- idle
	st_SHIFT,	-- data shift
	st_END		-- data latch(SHIFTから遷移してきた時)
);

--------------- signal -----------------------------------------------------------------------------
signal		s_shreg		: std_logic_vector(C_DATA_SIZE downto 0 );	-- シフトレジスタ
signal		s_state		: ty_STATE;
signal		s_cnt		: integer range 0 to C_DATA_SIZE;			-- シフト動作のカウンタ
signal		s_sclk_oe	: std_logic;								-- SCLK 出力イネーブル
signal		s_latch		: std_logic;								-- LATCH pulse

--------------- component --------------------------------------------------------------------------

--------------- begin ------------------------------------------------------------------------------
begin

	LE		<= s_latch;
	OEb		<= not RST_n;
	SCLK	<= CLK500k and s_sclk_oe;
	SD		<= s_shreg( s_shreg'left );

	BUSY	<= '0'	when ( s_state = st_IDLE ) else	'1';
	FIN		<= '1'	when ( s_state = st_END ) else '0';

	process ( RST_n, CLK )
	begin
		if ( RST_n = '0') then
			s_state		<= st_IDLE;
			s_cnt		<= 0;
			s_sclk_oe	<= '0';
			s_latch		<= '0';
			s_shreg		<= ( others => '0' );
		elsif ( rising_edge(CLK) ) then
			if ( CKEN500k = '1' ) then
				case ( s_state ) is
					when st_IDLE =>
						if START = '1' then
							s_state		<= st_SHIFT;
						else
							s_state		<= st_IDLE;
						end if;
						s_shreg		<= '0' & SDATA;
						s_cnt		<= 0;
						s_sclk_oe	<= '0';
						s_latch		<= '0';
					when st_SHIFT =>
						if ( s_cnt < C_DATA_SIZE ) then
							s_state		<= st_SHIFT;
							s_cnt		<= s_cnt + 1;
							s_sclk_oe	<= '1';
							s_latch		<= '0';
						else
							s_state		<= st_END;
							s_cnt		<= s_cnt;
							s_sclk_oe	<= '0';
							s_latch		<= '1';
						end if;
						s_shreg		<= s_shreg( s_shreg'left-1 downto 0 ) & '0';
					when st_END =>
						if ( START = '1' ) then
							s_state		<= st_END;
						else
							s_state		<= st_IDLE;
						end if;
						s_cnt		<= 0;
						s_sclk_oe	<= '0';
						s_latch		<= '0';
						s_shreg		<= ( others => '0' );
					when others =>
						s_state		<= st_IDLE;
						s_cnt		<= 0;
						s_sclk_oe	<= '0';
						s_latch		<= '0';
						s_shreg		<= ( others => '0' );
				end case;
			end if;
		end if;
	end process;

end RTL;
