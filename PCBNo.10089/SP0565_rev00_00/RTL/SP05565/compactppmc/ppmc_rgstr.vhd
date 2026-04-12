-------------------------------------------------
--File Name : ppmc_rgstr.vhd
--Project   : S3IO
--
--Date      : 2003/12/12
--Ver       : 0.00
--Doc       : New Release
--Designed by Kazutoshi Tokunaga
-------------------------------------
--Date      : 2005/09/15
--Ver       : 5.00
--Doc       : Delete the functions of ENB and PWM
--            Use only Init_REG bit(6)
--            Unused Limit_Mask for Limit_Monitor
--Changed by  Kazutoshi Tokunaga
-------------------------------------
--Date      : 2008/09/25
--Ver       : 6.00
--Doc       : Added Resister [UPDELAY]
--          : Added Resister [DOWNDELAY]
--Changed by  J.I
-------------------------------------------------
--Date      :2008/12/18
--Ver       :6.00
--Doc       :[CURRENT_DOWN] is simplified
--			:  [UPDELAY] is deleted. 
--Changed by J.I
-------------------------------------------------

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_unsigned.all;

entity ppmc_rgstr is
    port(
        LRSTb               : in std_logic;                             -- power on reset   (active Low)
        nMRST               : in std_logic;                             -- software reset   (active Low)
        CLK                 : in std_logic;                             -- Internal Clock 20MHZ
        LDI                 : in std_logic_vector( 7 downto 0);         -- data bus
        REGDO               : out std_logic_vector( 7 downto 0);        -- Local data bus
        LWEb                : in std_logic;                             -- write signal         (active Low)
        LATCH_L             : in std_logic;                             -- lat signal           (active Low)
        LRDb                : in std_logic;                             -- read signal          (active Low)
        LOAD_L              : in std_logic;                             -- load signal          (active Low)
        SEL_INI             : in std_logic;                             -- initialize register select(active High)
        SEL_COM             : in std_logic;                             -- command register select(active High)
        SEL_PLS_L           : in std_logic;                             -- pulse register(L) select(active High)
        SEL_PLS_H           : in std_logic;                             -- pulse register(H) select(active High)
        SEL_HIGH_L          : in std_logic;                             -- high freqency register(L) select(active High)
        SEL_HIGH_H          : in std_logic;                             -- high freqency register(H) select(active High)
        SEL_LOW_L           : in std_logic;                             -- low freqency register(L) select(active High)
        SEL_LOW_H           : in std_logic;                             -- low freqency register(H) select(active High)
        SEL_ACC_L           : in std_logic;                             -- acc rate register(L) select(active High)
        SEL_ACC_H           : in std_logic;                             -- acc rate register(H) select(active High)
        SEL_SLOW_L          : in std_logic;                             -- slow down register(L) select(active High)
        SEL_SLOW_H          : in std_logic;                             -- slow down register(H) select(active High)
        SEL_L_MASK          : in std_logic;                             -- limit mask register select(active High)
        SEL_L_MON           : in std_logic;                             -- limit monitor register select(active High)
        SEL_STATUS          : in std_logic;                             -- Status register select(active High)
        SEL_PRE             : in std_logic;                             -- pre register select(active High)
        SEL_MORE_L          : in std_logic;                             -- more register select(active High)
        SEL_MORE_H          : in std_logic;                             -- more register select(active High)		
        SEL_DOWNDELAY       : in std_logic;                             -- CURRENT DOWN Delay Register select(active High)
		SEL_CTRL2			: in std_logic; 							-- Control Resister Register select(active High)		--Added by Y.Takao
        SEL_MP_A            : in std_logic;                             -- multipurpose I/O registerA select(active High)
        SEL_MP_B            : in std_logic;                             -- multipurpose I/O registerB select(active High)
        INIT_REG            : out std_logic_vector( 7 downto 0);        -- initialize_register
        COMMAND_REG         : out std_logic_vector( 7 downto 0);        -- command register
        PULSE_REG           : out std_logic_vector(15 downto 0);        -- pulse register
        HIGH_FREQ_REG       : out std_logic_vector(15 downto 0);        -- high freqency register
        LOW_FREQ_REG        : out std_logic_vector(15 downto 0);        -- low freqency register
        ACC_RATE_REG        : out std_logic_vector(15 downto 0);        -- acc rate register
        SLOW_DOWN_REG       : out std_logic_vector(15 downto 0);        -- slow down register
        LIMIT_MASK_REG      : out std_logic_vector( 7 downto 0);        -- limit mask register
        LIMIT_MONITOR_REG   : out std_logic_vector( 7 downto 0);        -- limit monitor register
        PRE_PLS_REG         : out std_logic_vector( 7 downto 0);        -- Pre Pulse register
        MORE_PLS_REG        : out std_logic_vector( 15 downto 0);        -- More Pulse register
        DOWNDELAY_REG       : out std_logic_vector( 7 downto 0);        -- CURRENT DOWN Delay Register
		CTRL2_REG			: out std_logic_vector( 7 downto 0);        -- Control  Register(Mannual Slowdown used)			--Added by Y.Takao
		
        START_STOP          : in std_logic;                             -- start_stop
        COMMAND_CNG         : out std_logic;                            -- coommand change flag
        COMMAND_HIT         : in std_logic;                             -- coommand hit
        STATUS              : in std_logic_vector( 7 downto 0);         -- Status in
        PULSE               : in std_logic_vector(15 downto 0);         -- pulse_cnt
        LCW                 : in std_logic;                             -- Limit lcw
        LCCW                : in std_logic;                             -- Limit lccw
        MPI                 : in std_logic_vector(7 downto 0);          -- Multipurpose register
        MPO_A               : out std_logic_vector(7 downto 0);         -- Multipurpose register A
        MPO_B               : out std_logic_vector(7 downto 0)          -- Multipurpose register B
       );
end ppmc_rgstr;

architecture RTL of ppmc_rgstr is


--    signal READ_COMP            : std_logic_vector(18 downto 0);        -- read compare data		
	signal READ_COMP            : std_logic_vector(20 downto 0);        -- read compare data		--Changed by Y.Takao
    signal READ_DATA            : std_logic_vector( 7 downto 0);        --
    signal INIT_REG_O           : std_logic_vector( 7 downto 0);        -- initialize_register
    signal COMMAND_REG_O        : std_logic_vector( 7 downto 0);        -- command register
    signal PULSE_REG_O          : std_logic_vector(15 downto 0);        -- pulse register
    signal HIGH_FREQ_REG_O      : std_logic_vector(15 downto 0);        -- high freqency register
    signal LOW_FREQ_REG_O       : std_logic_vector(15 downto 0);        -- low freqency register
    signal ACC_RATE_REG_O       : std_logic_vector(15 downto 0);        -- acc rate register
    signal SLOW_DOWN_REG_O      : std_logic_vector(15 downto 0);        -- slow down register
    signal LIMIT_MASK_REG_O     : std_logic_vector( 7 downto 0);        -- limit mask register
    signal LIMIT_MONITOR_REG_O  : std_logic_vector( 7 downto 0);        -- limit monitor register
    signal PRE_REG_O            : std_logic_vector( 7 downto 0);        -- pre pulse register
    signal MORE_REG_O           : std_logic_vector( 15 downto 0);        -- more pulse register
    signal MPO_REG_A_O          : std_logic_vector( 7 downto 0);        -- Multipurpose register A
    signal MPO_REG_B_O          : std_logic_vector( 7 downto 0);        -- Multipurpose register B
    signal MPO_A_O              : std_logic_vector( 7 downto 0);        -- Multipurpose register A Latched
    signal MPO_B_O              : std_logic_vector( 7 downto 0);        -- Multipurpose register B Latched
    signal MPI_A                : std_logic_vector( 7 downto 0);        -- Multipurpose register In 1st
    signal MPI_B                : std_logic_vector( 7 downto 0);        -- Multipurpose register In 2nd
    signal MPI_R                : std_logic_vector( 7 downto 0);        -- Multipurpose register In Latched
    signal DOWNDELAY_REG_O      : std_logic_vector( 7 downto 0);        -- CURRENT DOWN Delay Register
	signal CTRL2_REG_O			: std_logic_vector( 7 downto 0);        -- Control Register				--Added by Y.Takao

    signal LIMIT_IN_A           : std_logic_vector( 7 downto 0);        -- limit monitor register

    signal REG_READ             : std_logic;
    signal nRST                 : std_logic;
    signal com_cng              : std_logic;

begin

-- output assign
    INIT_REG            <= INIT_REG_O;
    COMMAND_REG         <= COMMAND_REG_O;
    PULSE_REG           <= PULSE_REG_O;
    HIGH_FREQ_REG       <= HIGH_FREQ_REG_O;
    LOW_FREQ_REG        <= LOW_FREQ_REG_O;
    ACC_RATE_REG        <= ACC_RATE_REG_O;
    SLOW_DOWN_REG       <= SLOW_DOWN_REG_O;
    LIMIT_MASK_REG      <= LIMIT_MASK_REG_O;
    LIMIT_MONITOR_REG   <= LIMIT_MONITOR_REG_O;
    PRE_PLS_REG         <= PRE_REG_O;
    MORE_PLS_REG        <= MORE_REG_O;
    MPO_A               <= MPO_A_O;
    MPO_B               <= MPO_B_O;
    COMMAND_CNG         <= com_cng;
    DOWNDELAY_REG       <= DOWNDELAY_REG_O;
	CTRL2_REG			<= CTRL2_REG_O;

    nRST <= '0' when (LRSTb='0' or nMRST='0') else '1';


--************************--
-- RESISTER Write CONTROL --
--************************--

-- initialize_reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            INIT_REG_O <= (others =>'0');
        elsif(CLK' event and CLK ='1') then
            if(START_STOP='0' and SEL_INI = '1' and LWEb = '0')then         -- write (00h)
                INIT_REG_O <= '0' & LDI(6) & "000000";
            else
                INIT_REG_O <= INIT_REG_O;
            end if;
        end if;
    end process;

-- command_reg
    process(CLK,LRSTb)
    begin
        if(LRSTb='0') then
            COMMAND_REG_O   <= (others =>'0');
            com_cng         <= '0';
        elsif(CLK' event and CLK = '1') then
            if(COMMAND_HIT='1') then
                com_cng     <= '0';
                COMMAND_REG_O   <= COMMAND_REG_O;
            elsif(SEL_COM='1' and LWEb='0') then            -- write (02h)
                COMMAND_REG_O   <= LDI;
                com_cng         <= '1';
            else
                COMMAND_REG_O   <= COMMAND_REG_O;
                com_cng         <= com_cng;
            end if;
        end if;
    end process;

-- pulse_reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            PULSE_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_PLS_L='1' and LWEb='0') then         -- write (03h)
                PULSE_REG_O(7 downto 0) <= LDI;
            else
                PULSE_REG_O(7 downto 0) <= PULSE_REG_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            PULSE_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_PLS_H='1' and LWEb='0') then         -- write (04h)
                PULSE_REG_O(15 downto 8) <= LDI;
            else
                PULSE_REG_O(15 downto 8) <= PULSE_REG_O(15 downto 8);
            end if;
        end if;
    end process;


-- high freqency reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            HIGH_FREQ_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_HIGH_L='1' and LWEb='0') then            -- write (06h)
                HIGH_FREQ_REG_O(7 downto 0) <= LDI;
            else
                HIGH_FREQ_REG_O(7 downto 0) <= HIGH_FREQ_REG_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            HIGH_FREQ_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_HIGH_H='1' and LWEb='0') then            -- write (07h)
                HIGH_FREQ_REG_O(15 downto 8) <= LDI;
            else
                HIGH_FREQ_REG_O(15 downto 8) <= HIGH_FREQ_REG_O(15 downto 8);
            end if;
        end if;
    end process;

-- low freqency reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            LOW_FREQ_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_LOW_L='1' and LWEb='0') then         -- write (08h)
                LOW_FREQ_REG_O(7 downto 0) <= LDI;
            else
                LOW_FREQ_REG_O(7 downto 0) <= LOW_FREQ_REG_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            LOW_FREQ_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_LOW_H='1' and LWEb='0') then         -- write (09h)
                LOW_FREQ_REG_O(15 downto 8) <= LDI;
            else
                LOW_FREQ_REG_O(15 downto 8) <= LOW_FREQ_REG_O(15 downto 8);
            end if;
        end if;
    end process;

-- acc rate reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            ACC_RATE_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_ACC_L='1' and LWEb='0') then         -- write (0Ah)
                ACC_RATE_REG_O(7 downto 0) <= LDI;
            else
                ACC_RATE_REG_O(7 downto 0) <= ACC_RATE_REG_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            ACC_RATE_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_ACC_H='1' and LWEb='0') then         -- write (0Bh)
                ACC_RATE_REG_O(15 downto 8) <= LDI;
            else
                ACC_RATE_REG_O(15 downto 8) <= ACC_RATE_REG_O(15 downto 8);
            end if;
        end if;
    end process;

-- slow down reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            SLOW_DOWN_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_SLOW_L='1' and LWEb='0') then            -- write (0Ch)
                SLOW_DOWN_REG_O(7 downto 0) <= LDI;
            else
                SLOW_DOWN_REG_O(7 downto 0) <= SLOW_DOWN_REG_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            SLOW_DOWN_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_SLOW_H='1' and LWEb='0') then            -- write (0Dh)
                SLOW_DOWN_REG_O(15 downto 8) <= LDI;
            else
                SLOW_DOWN_REG_O(15 downto 8) <= SLOW_DOWN_REG_O(15 downto 8);
            end if;
        end if;
    end process;

-- limit mask reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            LIMIT_MASK_REG_O  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_L_MASK='1' and LWEb='0') then            -- write (0Eh)
                LIMIT_MASK_REG_O    <= LDI;
            else
                LIMIT_MASK_REG_O    <= LIMIT_MASK_REG_O;
            end if;
        end if;
    end process;

-- limit monitor reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            LIMIT_IN_A  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            LIMIT_IN_A(0)   <= '0';
            LIMIT_IN_A(1)   <= not LIMIT_MASK_REG_O(5)  xor LCW;
            LIMIT_IN_A(2)   <= not LIMIT_MASK_REG_O(6)  xor LCCW;
            LIMIT_IN_A(7 downto 3)  <= (others => '0');
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            LIMIT_MONITOR_REG_O  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(LOAD_L='1') then                     -- LOAD
                LIMIT_MONITOR_REG_O <= LIMIT_IN_A;
            else
                LIMIT_MONITOR_REG_O <= LIMIT_MONITOR_REG_O;
            end if;
        end if;
    end process;

-- pre pulse reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            PRE_REG_O  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_PRE='1' and LWEb='0') then            -- write (11h)
                PRE_REG_O    <= LDI;
            else
                PRE_REG_O    <= PRE_REG_O;
            end if;
        end if;
    end process;

-- more pulse reg_L
    process(CLK,nRST)
    begin
        if(nRST='0') then
            MORE_REG_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_MORE_L='1' and LWEb='0') then            -- write (12h)
                MORE_REG_O(7 downto 0)    <= LDI;
            else
                MORE_REG_O(7 downto 0)    <= MORE_REG_O(7 downto 0);
            end if;
        end if;
    end process;

-- more pulse reg_H
    process(CLK,nRST)
    begin
        if(nRST='0') then
            MORE_REG_O(15 downto 8)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_MORE_H='1' and LWEb='0') then            -- write (13h)
                MORE_REG_O(15 downto 8)    <= LDI;
            else
                MORE_REG_O(15 downto 8)    <= MORE_REG_O(15 downto 8);
            end if;
        end if;
    end process;

-- CURRENT DOWN Delay reg
    process(CLK,nRST)
    begin
        if(nRST='0') then
            DOWNDELAY_REG_O  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_DOWNDELAY='1' and LWEb='0') then            -- write (14h)
                DOWNDELAY_REG_O    <= LDI;
            else
                DOWNDELAY_REG_O    <= DOWNDELAY_REG_O;
            end if;
        end if;
    end process;

-- Control 2 reg 										--Added by Y.Takao
    process(CLK,nRST)
    begin
        if(nRST='0') then
            CTRL2_REG_O  <= (others =>'0');
		elsif(CLK' event and CLK = '1') then
			if(SEL_CTRL2='1' and LWEb='0') then            		-- write (15h)
                CTRL2_REG_O    <= LDI;
            else
                CTRL2_REG_O    <= CTRL2_REG_O;
            end if;
		end if;
    end process;


-- multipurpose I/O reg A (write)
    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPO_REG_A_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_MP_A='1' and LWEb='0') then           -- write (18h)
                MPO_REG_A_O(7 downto 0)   <= LDI;
            else
                MPO_REG_A_O(7 downto 0)   <= MPO_REG_A_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPO_A_O <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(LATCH_L='1') then                        --LATCH
                MPO_A_O   <= MPO_REG_A_O;
            else
                MPO_A_O <= MPO_A_O;
            end if;
        end if;
    end process;

-- multipurpose I/O reg B (write)
    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPO_REG_B_O(7 downto 0)  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(SEL_MP_B='1' and LWEb='0') then           -- write (19h)
                MPO_REG_B_O(7 downto 0)   <= LDI;
            else
                MPO_REG_B_O(7 downto 0)   <= MPO_REG_B_O(7 downto 0);
            end if;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPO_B_O <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(LATCH_L='1') then                        --LATCH
                MPO_B_O   <= MPO_REG_B_O;
            else
                MPO_B_O <= MPO_B_O;
            end if;
        end if;
    end process;



-- MPI latch
    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPI_A  <= (others =>'0');
            MPI_B  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            MPI_A <= MPI;
            MPI_B <= MPI_A;
        end if;
    end process;

    process(CLK,nRST)
    begin
        if(nRST='0') then
            MPI_R  <= (others =>'0');
        elsif(CLK' event and CLK = '1') then
            if(LOAD_L='1') then
                MPI_R <= MPI_B;
            else
                MPI_R <= MPI_R;
            end if;
        end if;
    end process;

--******************************--
--** READ DATA OUTPUT CONTROL **--
--******************************--

    READ_COMP <= (SEL_INI & SEL_COM & SEL_PLS_L & SEL_PLS_H &
                  SEL_HIGH_L & SEL_HIGH_H & SEL_LOW_L & SEL_LOW_H &
                  SEL_ACC_L & SEL_ACC_H & SEL_SLOW_L & SEL_SLOW_H &
                  SEL_L_MASK & SEL_L_MON & SEL_STATUS & SEL_PRE & SEL_MORE_L & SEL_MORE_H & SEL_DOWNDELAY & SEL_CTRL2 & SEL_MP_A);

    process(READ_COMP, READ_DATA, INIT_REG_O, COMMAND_REG_O,
            PULSE, HIGH_FREQ_REG_O, LOW_FREQ_REG_O, ACC_RATE_REG_O,
            SLOW_DOWN_REG_O, LIMIT_MASK_REG_O, LIMIT_MONITOR_REG_O,
            STATUS, PRE_REG_O, MORE_REG_O, DOWNDELAY_REG_O, CTRL2_REG_O, MPI_R) begin
            
        case (READ_COMP) is
            when "100000000000000000000"=> READ_DATA <= INIT_REG_O                       ;   --[00]
            when "010000000000000000000"=> READ_DATA <= COMMAND_REG_O                    ;   --[02]
            when "001000000000000000000"=> READ_DATA <= PULSE( 7 downto 0)               ;   --[03]
            when "000100000000000000000"=> READ_DATA <= PULSE(15 downto 8)               ;   --[04]
            when "000010000000000000000"=> READ_DATA <= HIGH_FREQ_REG_O( 7 downto 0)     ;   --[06]
            when "000001000000000000000"=> READ_DATA <= HIGH_FREQ_REG_O(15 downto 8)     ;   --[07]
            when "000000100000000000000"=> READ_DATA <= LOW_FREQ_REG_O( 7 downto 0)      ;   --[08]
            when "000000010000000000000"=> READ_DATA <= LOW_FREQ_REG_O(15 downto 8)      ;   --[09]
            when "000000001000000000000"=> READ_DATA <= ACC_RATE_REG_O( 7 downto 0)      ;   --[0A]
            when "000000000100000000000"=> READ_DATA <= ACC_RATE_REG_O(15 downto 8)      ;   --[0B]
            when "000000000010000000000"=> READ_DATA <= SLOW_DOWN_REG_O( 7 downto 0)     ;   --[0C]
            when "000000000001000000000"=> READ_DATA <= SLOW_DOWN_REG_O(15 downto 8)     ;   --[0D]
            when "000000000000100000000"=> READ_DATA <= LIMIT_MASK_REG_O                 ;   --[0E]
            when "000000000000010000000"=> READ_DATA <= LIMIT_MONITOR_REG_O              ;   --[0F]
            when "000000000000001000000"=> READ_DATA <= STATUS                           ;   --[10]
            when "000000000000000100000"=> READ_DATA <= PRE_REG_O                        ;   --[11]
			when "000000000000000010000"=> READ_DATA <= MORE_REG_O(7 downto 0)          ;   --[12]
            when "000000000000000001000"=> READ_DATA <= MORE_REG_O(15 downto 8)          ;   --[12]
            when "000000000000000000100"=> READ_DATA <= DOWNDELAY_REG_O                  ;   --[14]
			when "000000000000000000010"=> READ_DATA <= CTRL2_REG_O				 	 	;   --[15]		--Added by Y.Takao
            when "000000000000000000001"=> READ_DATA <= MPI_R( 7 downto 0)               ;   --[18]
            when others => READ_DATA <= (others =>'0');
        end case;
    end process;


    REG_READ <= (SEL_INI or SEL_COM or SEL_PLS_L or SEL_PLS_H or
                 SEL_HIGH_L or SEL_HIGH_H or SEL_LOW_L or SEL_LOW_H or
                 SEL_ACC_L or SEL_ACC_H or SEL_SLOW_L or SEL_SLOW_H or
                 SEL_L_MASK or SEL_L_MON or SEL_STATUS or SEL_PRE or
                 SEL_MORE_L or SEL_MORE_H or SEL_DOWNDELAY or SEL_CTRL2 or SEL_MP_A);

    REGDO   <= READ_DATA when (REG_READ='1' and LRDb='0') else (others =>'0')   ;

end RTL ;