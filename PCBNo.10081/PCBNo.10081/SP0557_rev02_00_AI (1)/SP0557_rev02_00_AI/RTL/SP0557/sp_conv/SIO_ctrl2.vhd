--************************************************
-- Copyright (C) 2022 Sysmex Corporation
-- Project	:	Hematology Measurment System M204M(XR)
--				PCBNO.30057 FPGA(SP0531)
--------------------
-- Function	: Serial I/F (on board)
--------------------
-- Text format (set to EditorConfig)
-- 	1. Line feed	: CR+LF
-- 	2. Encording	: Shift-JIS
-- 	3. Indent		: Tab-4
--------------------
-- Revision History :
--	[Rev.]	[Date]		[Author]				[Description]
----------
--	0.00	2019/11/19	M.Tanaka(MEITEC)		New
----------
--	0.10	2019/11/19	M.Tanaka(MEITEC)		revised
--		* each length is defined within the generic
----------
--	0.11	2022/08/26	M.Tanaka(MEITEC)		revised
--		* SPI_START is added
--************************************************
-- Note
--************************************************

library IEEE ;
	use IEEE.std_logic_1164.all ;
	use IEEE.std_logic_unsigned.all ;

library WORK ;
	use WORK.w_pack.all;


entity SIO_ctrl2 is
	generic (
		g_MISOLen	: natural := 11 * 8 ;	-- num of SNS data bits
		g_MOSILen	: natural := 15 * 8 	-- num of SV data bits
	) ;
	port (
		nRESET		: in	std_logic ;	-- power on reset (active Low)
		CLK40M		: in	std_logic ;	-- Internal Clock 40MHz
	-- Clock Enable
		CE_SIO		: in	std_logic ;	-- for SPI		-- 5MHz(200ns)
	-- Serial Control
		SPI_START	: in	std_logic := '1' ;	-- start
		SPI_UPDATE	: out	std_logic ;	-- SPI_RDATA update timing pulse
		SPI_BUSY	: out	std_logic ;
		SPI_SENDING	: out	std_logic ;
		-- Parallel data
		SPI_SDATA	: in	std_logic_vector( g_MOSILen downto 1 ) ;	-- send data (SV data)
		SPI_RDATA	: out	std_logic_vector( g_MISOLen downto 1 ) ;	-- received data (SNS data)
	-- Serial I/F (in:74x165  out:74x595)
		SIO_SCLK	: out	std_logic ;
		SIO_SLAT	: out	std_logic ;	-- for SV out
		SIO_nSGE	: out	std_logic ;
		SIO_nSLD	: out	std_logic ;	-- for SENSOR read
		SIO_MOSI	: out	std_logic ;
		SIO_MISO	: in	std_logic
	) ;
end SIO_ctrl2 ;


architecture RTL of SIO_ctrl2 is	--************

	constant	c_SPIFLen		: natural := fn_MAX( g_MISOLen, g_MOSILen ) ; 	-- num of transfer bits (greater one of SV or SNS)
	constant	c_MOSIMSB		: natural := g_MOSILen ;					-- MOSI data MSB in SPI data
	constant	c_MOSILSB		: natural := 1 ;							-- MOSI data LSB in SPI data
	constant	c_MISOMSB		: natural := c_SPIFLen ;					-- MISO data MSB in SPI data
	constant	c_MISOLSB		: natural := c_SPIFLen - g_MISOLen + 1 ;	-- MISO data LSB in SPI data

	subtype		sb_SPIF			is std_logic_vector( c_SPIFLen downto 1 ) ;			-- SPI Full
	subtype		sb_MOSI			is std_logic_vector( c_MOSIMSB downto c_MOSILSB ) ;	-- SPI Master out Slave in data
	subtype		sb_MISO			is std_logic_vector( c_MISOMSB downto c_MISOLSB ) ;	-- SPI Master in Slave out data

	signal
		s_TxData
	,	s_RxData
	: std_logic_vector( c_SPIFLen downto 1 ) := ( others => '0' ) ;

	alias		a_MOSI_Data	: sb_MOSI is s_TxData( sb_MOSI'range ) ;
	alias		a_MISO_Data	: sb_MISO is s_RxData( sb_MISO'range ) ;


--****************************
	component SPI_master2
	generic (
		g_DatSize	: integer := 8		-- Data size
	) ;
	port (
		RESETb		: in	std_logic ;	-- reset (act.L)
		CLR			: in	std_logic ;	-- sync clear except internal SCLK and MODE (act.H)
		CLK			: in	std_logic ;	-- clock
		CE			: in	std_logic ;	-- clock enable : 1pulse/1period (act.H). SCLK_freq = CE_freq/2.
		DI			: in	std_logic_vector( g_DatSize-1 downto 0 ) ;	-- parallel data (to slave)
		DO			: out	std_logic_vector( g_DatSize-1 downto 0 ) ;	-- parallel data (from slave)
		START		: in	std_logic ;	-- shift start (act.H)
		BUSY		: out	std_logic ;	-- not idle
		MODE		: in	std_logic_vector( 1 downto 0 ) ;	-- SPI mode
		MODE2		: in	std_logic ;	-- assert one SCLK before/after SCSb
		SCSb		: out	std_logic ;	-- SPI Chip select
		SCLK		: out	std_logic ;	-- SPI shift clock
		MISO		: in	std_logic ;	-- SPI shift data (master in slabe out)
		MOSI		: out	std_logic ;	-- SPI shift data (master out slabe in)
		SLAT		: out	std_logic ;
		nSLD		: out	std_logic
	);
	end component;

	signal		s_SPI_start	: std_logic ;	-- SPI_master start
	signal		s_SPI_busy	: std_logic ;	-- SPI_master busy

	-- for SPI_master input
	constant	C_CLR		: std_logic := '0' ;
	constant	C_MODE		: std_logic_vector( 1 downto 0 ) := B"00" ;
	constant	C_MODE2		: std_logic := '0' ;


--****************************
	type		ty_STATE is (										--	{BUSY, SENDING}
		st_IDLE		-- Idle												{0,0}
	,	st_DSET		-- data set & wait until SPI_master start to send	{1,0}
	,	st_WAIT		-- wait until SPI_master finish to send				{1,1}
	,	st_FIN		-- finished sending to all selected CHs				{1,0}
	);

	signal		s_state		: ty_STATE ;


begin	--****************************************


-- Tx Data
	a_MOSI_Data	<=	SPI_SDATA ;

-- Rx Data latch
	process ( nRESET, CLK40M )
	begin
		if ( nRESET = '0' ) then
			SPI_UPDATE	<= '0' ;
			SPI_RDATA	<= ( others => '0' ) ;
		elsif ( rising_edge(CLK40M) ) then
			if ( s_state = st_FIN ) then
				SPI_UPDATE	<= '1' ;
				SPI_RDATA	<= a_MISO_Data ;
			else
				SPI_UPDATE	<= '0' ;
			end if ;
		end if ;
	end process ;


-- state machine
	process ( nRESET, CLK40M )
	begin
		if ( nRESET = '0' ) then
			s_state		<= st_IDLE ;
			s_SPI_start	<= '0' ;
		elsif ( rising_edge(CLK40M) ) then
			case ( s_state ) is
			when st_IDLE =>
				if ( SPI_START = '1' ) then
					s_state		<= st_DSET ;
					s_SPI_start	<= '0' ;
				else
					s_state		<= st_IDLE ;
					s_SPI_start	<= '0' ;
				end if ;
			when st_DSET =>
				if ( s_SPI_busy = '0' ) then
					s_state		<= st_DSET ;
					s_SPI_start	<= '1' ;
				else
					s_state		<= st_WAIT ;
					s_SPI_start	<= '0' ;
				end if ;
			when st_WAIT =>
				if ( s_SPI_busy = '1' ) then
					s_state		<= st_WAIT ;
					s_SPI_start	<= '0' ;
				else
					s_state		<= st_FIN ;
					s_SPI_start	<= '0' ;
				end if ;
			when st_FIN =>
					s_state		<= st_IDLE ;
					s_SPI_start	<= '0' ;
			when others =>				-- Illegal state
					s_state		<= st_IDLE ;
					s_SPI_start	<= '0' ;
			end case ;
		end if ;
	end process ;


	SPI_BUSY	<=		'0'		when ( s_state = st_IDLE )
				else	'1' ;

	SPI_SENDING	<=		'0'		when ( ( s_state = st_IDLE ) or ( s_state = st_FIN ) )
				else	'1' ;


	process ( nRESET, CLK40M )
	begin
		if ( nRESET = '0' ) then
			SIO_nSGE <= '1' ;
		elsif ( rising_edge(CLK40M) ) then
			if ( s_state = st_FIN ) then
				SIO_nSGE <= '0' ;
			end if ;
		end if ;
	end process ;


-- SPI
	U_SPI_master : SPI_master2
	generic map (
		g_DatSize	=> c_SPIFLen
	)
	port map (
		RESETb		=> nRESET
	,	CLR			=> C_CLR
	,	CLK			=> CLK40M
	,	CE			=> CE_SIO
	,	DI			=> s_TxData
	,	DO			=> s_RxData
	,	START		=> s_SPI_start
	,	BUSY		=> s_SPI_busy
	,	MODE		=> C_MODE
	,	MODE2		=> C_MODE2
	,	SCSb		=> open
	,	SCLK		=> SIO_SCLK
	,	MISO		=> SIO_MISO
	,	MOSI		=> SIO_MOSI
	,	SLAT		=> SIO_SLAT
	,	nSLD		=> SIO_nSLD
	) ;


end RTL ;