-------------------------------------------------
--File Name : slv_tx_ctrl.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2004/05/19
--Ver       : 2.00
--Doc       : Communication Clock 16MHz => 25MHz => 20MHz
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date		: 2005/06/17
--Ver		: 3.00
--Doc		: [null] of [STATE others] is deleted.
--			: [STATE others] was changed initialization processing.
--Changed by  Kazutoshi Tokunaga
-------------------------------------------------
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity slv_tx_ctrl is
    port(
        LRSTb       : in std_logic;                             -- local reset
        CLK1        : in std_logic;                             -- Clock 10MHZ
        TX_FULL     : in std_logic;                             -- fifo full flag(active high)
        TX_START    : in std_logic;                             -- start signal
        LDO         : in std_logic_vector( 7 downto 0);         -- local data
        PRPTY       : in std_logic_vector( 7 downto 0);         -- prpty data
        CMD         : in std_logic_vector( 7 downto 0);         -- cmd data
        ADR1        : in std_logic_vector( 7 downto 0);         -- adr1 data
        ADR2        : in std_logic_vector( 7 downto 0);         -- dar2 data
        SLVADR      : in std_logic_vector( 7 downto 0);         -- slave address

        TX_D        : out std_logic_vector( 7 downto 0);        -- fifo write data
        TX_WRENB    : out std_logic;                            -- fifo write enb(active High)
        LRDb        : out std_logic;                            -- local data read(active Low)
        LA_TX       : out std_logic_vector( 4 downto 0)         -- local address(memory address)
        );
end slv_tx_ctrl;

architecture RTL of slv_tx_ctrl is

    signal STATE        : std_logic_vector(9 downto 0);
    constant IDLE       : std_logic_vector(9 downto 0)  :="0000000001";
    constant TX_SYNC    : std_logic_vector(9 downto 0)  :="0000000010";
    constant TX_PRPTY   : std_logic_vector(9 downto 0)  :="0000000100";
    constant TX_ADR1    : std_logic_vector(9 downto 0)  :="0000001000";
    constant TX_ADR2    : std_logic_vector(9 downto 0)  :="0000010000";
    constant TX_CMD     : std_logic_vector(9 downto 0)  :="0000100000";
    constant TX_LEN     : std_logic_vector(9 downto 0)  :="0001000000";
    constant TX_WREN    : std_logic_vector(9 downto 0)  :="0010000000";
    constant TX_SLV     : std_logic_vector(9 downto 0)  :="0100000000";
    constant TX_DATA    : std_logic_vector(9 downto 0)  :="1000000000";

    signal SYNC         : std_logic_vector( 7 downto 0);
    signal LA           : std_logic_vector( 4 downto 0);
    signal TX_WRENB_O   : std_logic;
    signal count        : std_logic_vector( 1 downto 0);

begin

    TX_WRENB <= TX_WRENB_O;
    SYNC    <= "01111110";
    LA_TX <= LA( 4 downto 0);


--*******************************************--
--            tx fifo write control          --
--*******************************************--
-- State Machine

    process(LRSTb, CLK1)
    begin
        if(LRSTb= '0')  then
            TX_WRENB_O <= '0';
            TX_D     <= (others=>'0');
            LA       <= (others=>'0');
            count    <= (others=>'0');
            LRDb     <= '1';
            STATE    <= IDLE;

        elsif(CLK1'event and CLK1='1') then
            case STATE is
                when IDLE =>
                    count       <= (others=>'0');
                    LRDb       <= '1';
                    TX_WRENB_O <= '0';
                    if(TX_START='1') then
                        LA    <= (others=>'0');
                        STATE <= TX_SYNC;
                    else
                        STATE <= IDLE;
                    end if;
                when TX_SYNC =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= SYNC;
                        STATE    <= TX_PRPTY;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_SYNC;
                    end if;
                when TX_PRPTY =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= PRPTY;
                        STATE    <= TX_ADR1;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_PRPTY;
                    end if;
                when TX_ADR1 =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= ADR1;
                        STATE    <= TX_ADR2;
                    else
                        TX_WRENB_O <= '0';
                        STATE   <= TX_ADR1;
                    end if;
                when TX_ADR2 =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= ADR2;
                        STATE    <= TX_CMD;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_ADR2;
                    end if;
                when TX_CMD =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= CMD;
                        STATE    <= TX_LEN;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_CMD;
                    end if;
                when TX_LEN =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        if(CMD="00000100" or CMD="00001000") then       --  data rx or log in
                            TX_D    <= "00000000";
                            STATE   <= TX_WREN;
                        elsif(CMD="00000001") then                      -- slave check
                            TX_D    <= "00000001";
                            STATE   <= TX_WREN;
                        else
                            TX_D    <= "00100000";
                            STATE   <= TX_WREN;
                        end if;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_LEN;
                    end if;
                when TX_WREN =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        if(count ="11") then
                            count <= (others =>'0');
                            if(CMD="00000010" or CMD="00000101" or CMD="00001001") then     --  data rx or log in
                                TX_D    <= "11111111";
                                LRDb    <= '0';
                                STATE   <= TX_DATA;
                            elsif(CMD="00000001") then          -- slave check
                                TX_D    <= (others => '0');
                                LRDb    <= '1';
                                STATE   <= TX_SLV;
                            else
                                TX_D    <= (others => '0');
                                LRDb    <= '1';
                                STATE   <= IDLE;
                            end if;
                        else
                            if(CMD="00000010" or CMD="00000101" or CMD="00001001") then     --  data rx or log in
                                TX_D    <= "11111111";
                                STATE   <= TX_WREN;
                                count   <= count + '1';
                            else
                                TX_D    <= (others => '0');
                                STATE   <= TX_WREN;
                                count   <= count + '1';
                            end if;
                        end if;
                    else
                        TX_WRENB_O  <= '0';
                        STATE       <= TX_WREN;
                    end if;
                when TX_SLV =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        TX_D     <= SLVADR;
                        STATE <= IDLE;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_SLV;
                    end if;
                when TX_DATA =>
                    if(TX_FULL='0') then
                        TX_WRENB_O <= '1';
                        if(LA = "00000011111" ) then
                            TX_D    <= LDO;
                            LRDb    <= '1';
                            STATE   <= IDLE;
                        else
                            TX_D    <= LDO;
                            LA      <= LA + 1;
                            STATE   <= TX_DATA;
                        end if;
                    else
                        TX_WRENB_O <= '0';
                        STATE    <= TX_DATA;
                    end if;
                when others =>
	            	TX_WRENB_O <= '0';
        	    	TX_D     <= (others=>'0');
            		LA       <= (others=>'0');
            		count    <= (others=>'0');
            		LRDb     <= '1';
            		STATE    <= IDLE;
            end case;
        end if;
    end process;


end RTL;

