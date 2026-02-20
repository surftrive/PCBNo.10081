----------------------------------------------------------------------------------------------------
--File Name : enc_lmt.vhd
--Project   : S118M
--
--Date      : 2020/02/07
--Ver       : 0.01
--Doc       : New Release
--Designed by Y.Aoki
----------------------------------------------------------------------------------------------------
--Date      :2021/02/23
--Ver       :0.02
--Doc       : add LMT_REG_OUT
--Changed by Y.Aoki
-------------------------------------------------
--Date      :2025/01/15
--Ver       :0.03
--Doc       : EXT_MODE add bit
--Changed by D.Chikayama
-------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_unsigned.all;

	entity enc_lmt is
	port(
		CLK		     : in std_logic;		                 -- Clock 20MHz
		LRSTb		   : in std_logic;		                 -- Local Reset	(active Low)
		ENCLMT_EN	 : in std_logic;		                 -- Enable
    LMT_LGC    : in std_logic;                     -- select signal of logic value for limit out 0:negative 1:positive
    STM_ST     : in std_logic;                     -- state of STM 0:stop 1:operate
    ENC_TH     : in std_logic_vector(7 downto 0);  -- threshold of error of enc to pls
    EXT_MODE   : in std_logic_vector(2 downto 0);  -- extension mode of STM 00:2phase 01:1-2phase 10:1/4micor 11:1/8micro
    DIR        : in std_logic;                     -- rotate direction of STM
		CNT_UP		 : in std_logic;		                 -- signal of count up for enc
		CNT_DWN		 : in std_logic;		                 -- signal of count down for enc
    STM_PLS    : in std_logic;                     -- stm pulse signal
    LMT_OUT    : out std_logic;                     -- enc error limit out
    LMT_REG_OUT : out std_logic                     -- enc error limit register out
	);
	end enc_lmt;

-------------- architecture ------------------------------------------------------------------------
architecture RTL of enc_lmt is
-------------- component ---------------------------------------------------------------------------
-------------- type --------------------------------------------------------------------------------
-------------- signal ------------------------------------------------------------------------------
signal s_encerr   : std_logic_vector(13 downto 0);
signal s_enc_thh  : std_logic_vector(13 downto 0);
signal s_enc_thl  : std_logic_vector(13 downto 0);
signal s_smtadd   : std_logic_vector(3 downto 0);
signal s_enc_th   : std_logic_vector(10 downto 0);
signal s_enc_lmt  : std_logic;
signal s_smt_pls0 : std_logic;
signal s_smt_pls  : std_logic;
signal s_smt_pls_1sh  : std_logic;
signal s_lmt_ast  : std_logic;
signal s_lmt_ngt  : std_logic;

--20250319 Chikayama ADD
signal s_stmst_pls0 : std_logic;
signal s_stmst_pls  : std_logic;
signal s_stmst_pls_1sh  : std_logic;

-------------- constant ----------------------------------------------------------------------------
constant c_offset   : std_logic_vector(13 downto 0):=B"10_0000_0000_0000";
-------------- begin -------------------------------------------------------------------------------
begin
  s_enc_thh <= c_offset + s_enc_th + 1;
  s_enc_thl <= c_offset - s_enc_th - 1;
  s_lmt_ast <= '1' when LMT_LGC = '1' else '0';
  s_lmt_ngt <= not s_lmt_ast;
  LMT_OUT   <= s_enc_lmt;
  --------------process-----------------------------------------
  process (EXT_MODE,ENC_TH) begin
    case EXT_MODE is
      when "000"   => s_enc_th <=         ENC_TH & "000";--2phase
      when "001"   => s_enc_th <= "0"   & ENC_TH & "00";--1-2phaseNC
      when "010"   => s_enc_th <= "0"   & ENC_TH & "00";--1-2phase
      when "011"   => s_enc_th <= "00"  & ENC_TH & "0";--1/4 microstep
	  when "100"   => s_enc_th <= "000" & ENC_TH;--1/8 microstep
      when others  => s_enc_th <=         ENC_TH & "000";--others
    end case;
  end process;
  
  process (CLK, LRSTb) begin
    if (LRSTb = '0') then
      s_smt_pls0 <= '0';
      s_smt_pls <= '0';
      s_smt_pls_1sh <= '0';
    elsif (CLK'event and CLK='1') then
      s_smt_pls0 <= STM_PLS;
      s_smt_pls <= s_smt_pls0;
      s_smt_pls_1sh <= s_smt_pls0 and not s_smt_pls;
    end if;
  end process;

  process (CLK, LRSTb) begin
    if (LRSTb = '0') then
      s_smtadd  <= "0000";
    elsif (CLK'event and CLK='1') then
      if(s_smt_pls_1sh='1') then
        case EXT_MODE is
          when "000"     => s_smtadd <= "1000";    --2phase
          when "001"     => s_smtadd <= "0100";    --1-2phaseNC
          when "010"     => s_smtadd <= "0100";    --1-2phase
          when "011"     => s_smtadd <= "0010";    --1/4 microstep
		  when "100"     => s_smtadd <= "0001";    --1/8 microstep
          when others	 => s_smtadd <= "0000";
        end case;
       else
        s_smtadd <= "0000";
       end if;
    end if;
  end process;

  -- counter
  process (CLK, LRSTb) begin
    if (LRSTb = '0') then
      s_encerr <= c_offset;
    elsif (CLK'event and CLK='1') then
      if(ENCLMT_EN = '0') then
        s_encerr <= c_offset;
      elsif(STM_ST = '0') then
        s_encerr <= c_offset;
      else
        if(DIR = '0') then
          s_encerr <= s_encerr + CNT_UP - CNT_DWN - s_smtadd;
        else
          s_encerr <= s_encerr + CNT_UP - CNT_DWN + s_smtadd;
        end if;
      end if;
    end if;
  end process;

  -- compare
  process (CLK, LRSTb,s_lmt_ngt) begin
    if (LRSTb = '0') then
      s_enc_lmt <= s_lmt_ngt;
    elsif (CLK'event and CLK='1') then
      if(ENCLMT_EN = '0') then
        s_enc_lmt <=s_lmt_ngt;
      elsif(STM_ST <= '0') then
        s_enc_lmt <= s_lmt_ngt;   
      elsif(s_encerr < s_enc_thl  or  s_encerr > s_enc_thh) then
        s_enc_lmt <= s_lmt_ast;
      else
        s_enc_lmt <= s_lmt_ngt;
      end if;
    end if;
  end process;

--20250319 Chikayama Add
 process (CLK, LRSTb) begin
    if (LRSTb = '0') then
      s_stmst_pls0 		<= '0';
      s_stmst_pls 		<= '0';
      s_stmst_pls_1sh 	<= '0';
    elsif (CLK'event and CLK='1') then
      s_stmst_pls0 		<= STM_ST;
      s_stmst_pls 		<= s_stmst_pls0;
      s_stmst_pls_1sh 	<= s_stmst_pls0 and not s_stmst_pls;
    end if;
  end process;


  -- save limit state to register
  process (CLK, LRSTb) begin
    if (LRSTb = '0') then
      LMT_REG_OUT <= '0';
    elsif (CLK'event and CLK='1') then
      if(ENCLMT_EN = '0') then
        LMT_REG_OUT <='0';
	  elsif(s_stmst_pls_1sh = '1') then
		LMT_REG_OUT <='0';
	  elsif(s_enc_lmt = '1') then
        LMT_REG_OUT <= '1';
      end if;
    end if;
  end process;

end RTL;
