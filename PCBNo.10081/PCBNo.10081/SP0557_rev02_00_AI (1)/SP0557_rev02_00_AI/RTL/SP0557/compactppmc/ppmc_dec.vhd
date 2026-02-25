-------------------------------------------------
--File Name : ppmc_dec.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2008/09/25
--Ver       : 1.00
--Doc       : Added [SEL_UPDELAY]
--          : Added [SEL_DOWNDELAY]
--Changed by J.I
-------------------------------------------------
--Date      :2008/12/18
--Ver       :2.00
--Doc       :[CURRENT_DOWN] is simplified
--			:  [UPDELAY] is deleted.
--Changed by J.I
-------------------------------------------------
-------------------------------------------------
--Date      :2021/2/23
--Ver       :2.00
--Doc       :[DOWNDELAY] is deleted.
--Changed by Y.Aoki
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_arith;
    use IEEE.std_logic_unsigned.all;

entity ppmc_dec is
    port(
        LA              : in std_logic_vector(4 downto 0);      -- local address
        REGSEL          : in std_logic;         --register select

        SEL_INI         : out std_logic;        -- initialize register select(active High)
        SEL_COM         : out std_logic;        -- command register select(active High)
        SEL_PLS_L       : out std_logic;        -- pulse register(L) select(active High)
        SEL_PLS_H       : out std_logic;        -- pulse register(H) select(active High)
        SEL_HIGH_L      : out std_logic;        -- high freqency register(L) select(active High)
        SEL_HIGH_H      : out std_logic;        -- high freqency register(H) select(active High)
        SEL_LOW_L       : out std_logic;        -- low freqency register(L) select(active High)
        SEL_LOW_H       : out std_logic;        -- low freqency register(H) select(active High)
        SEL_ACC_L       : out std_logic;        -- acc rate register(L) select(active High)
        SEL_ACC_H       : out std_logic;        -- acc rate register(H) select(active High)
        SEL_SLOW_L      : out std_logic;        -- slow down register(L) select(active High)
        SEL_SLOW_H      : out std_logic;        -- slow down register(H) select(active High)
        SEL_L_MASK      : out std_logic;        -- limit mask register select(active High)
        SEL_L_MON       : out std_logic;        -- limit monitor register select(active High)
        SEL_STATUS      : out std_logic;        -- status register select(active High)
        SEL_PRE         : out std_logic;        -- pre-pulses register select(active High)
        SEL_MORE_L      : out std_logic;        -- more-pulse register select(active High)
		SEL_MORE_H      : out std_logic;        -- more-pulse register select(active High)
        SEL_DOWNDELAY   : out std_logic;        -- CURRENT DOWN Delay Register select(active High)
		SEL_CTRL2		: out std_logic;        -- Control Register select(active High)					--Added by Y.Takao
        SEL_MP_A        : out std_logic;        -- multipurpose I/O register select(active High)
        SEL_MP_B        : out std_logic         -- multipurpose I/O register select(active High)
        );
end ppmc_dec;

architecture RTL of ppmc_dec is

    signal compare      : std_logic_vector( 5 downto 0);
    signal SEL          : std_logic_vector(20 downto 0);			--Changed by Y.Takao

begin



--**************************--
--     Address Decoder      --
--**************************--


-- Register Area Decord
    compare <= (REGSEL & LA(4 downto 0));

    process (compare) begin
        case compare is
            when "100000" => SEL <= "000000000000000000001";  -- [00h]		--Changed by Y.Takao
            when "100010" => SEL <= "000000000000000000010";  -- [02h]
            when "100011" => SEL <= "000000000000000000100";  -- [03h]
            when "100100" => SEL <= "000000000000000001000";  -- [04h]
            when "100110" => SEL <= "000000000000000010000";  -- [06h]
            when "100111" => SEL <= "000000000000000100000";  -- [07h]
            when "101000" => SEL <= "000000000000001000000";  -- [08h]
            when "101001" => SEL <= "000000000000010000000";  -- [09h]
            when "101010" => SEL <= "000000000000100000000";  -- [0Ah]
            when "101011" => SEL <= "000000000001000000000";  -- [0Bh]
            when "101100" => SEL <= "000000000010000000000";  -- [0Ch]
            when "101101" => SEL <= "000000000100000000000";  -- [0Dh]
            when "101110" => SEL <= "000000001000000000000";  -- [0Eh]
            when "101111" => SEL <= "000000010000000000000";  -- [0Fh]
            when "110000" => SEL <= "000000100000000000000";  -- [10h]
            when "110001" => SEL <= "000001000000000000000";  -- [11h]
            when "110010" => SEL <= "000010000000000000000";  -- [12h]
            when "110100" => SEL <= "000100000000000000000";  -- [14h]
			when "110101" => SEL <= "001000000000000000000";  -- [15h]		--Added by Y.Takao
            when "111000" => SEL <= "010000000000000000000";  -- [18h]
            when "111001" => SEL <= "100000000000000000000";  -- [19h]
            when others => SEL <= (others =>'0');
        end case;
    end process;

    SEL_INI         <= SEL( 0);
    SEL_COM         <= SEL( 1);
    SEL_PLS_L       <= SEL( 2);
    SEL_PLS_H       <= SEL( 3);
    SEL_HIGH_L      <= SEL( 4);
    SEL_HIGH_H      <= SEL( 5);
    SEL_LOW_L       <= SEL( 6);
    SEL_LOW_H       <= SEL( 7);
    SEL_ACC_L       <= SEL( 8);
    SEL_ACC_H       <= SEL( 9);
    SEL_SLOW_L      <= SEL(10);
    SEL_SLOW_H      <= SEL(11);
    SEL_L_MASK      <= SEL(12);
    SEL_L_MON       <= SEL(13);
    SEL_STATUS      <= SEL(14);
    SEL_PRE         <= SEL(15);
    SEL_MORE_L      <= SEL(16);
    SEL_MORE_H	    <= SEL(17);
    SEL_DOWNDELAY   <= '0';
    SEL_CTRL2		<= SEL(18);				--Added by Y.Takao
    SEL_MP_A        <= SEL(19);				--Changed by Y.Takao
    SEL_MP_B        <= SEL(20);				--Changed by Y.Takao

    end RTL ;
