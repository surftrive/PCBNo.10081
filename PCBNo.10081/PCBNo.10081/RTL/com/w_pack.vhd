----------------------------------------------------------------------------------------------------
--File Name	: w_pack.vhd																					
--Project	: S124M(S3IO)
--Date		: 2024.12.04
--Ver		: 0.00
--Doc		: New Release
--			: S124M PCB No.10082
--Designed by Nobuhisa Hatashima(PHR)
----------------------------------------------------------------------------------------------------
--Date	 	:
--Ver		:
--Doc		:
--Changed by 
----------------------------------------------------------------------------------------------------

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_arith.all;
	use IEEE.std_logic_unsigned.all;
	use IEEE.std_logic_misc.all;
	use IEEE.numeric_std.all;

package w_pack is

	type	ta_DA2		is array(natural range <>) of std_logic_vector( 1 downto 0);
	type	ta_DA3		is array(natural range <>) of std_logic_vector( 2 downto 0);
	type	ta_DA6		is array(natural range <>) of std_logic_vector( 5 downto 0);
	type	ta_DA8		is array(natural range <>) of std_logic_vector( 7 downto 0);
	type	ta_DA12		is array(natural range <>) of std_logic_vector(11 downto 0);
	type	ta_DA16		is array(natural range <>) of std_logic_vector(15 downto 0);

	constant	oct0		: std_logic_vector(7 downto 0) := "00000000";

	constant	c_STM_CH	: integer :=13;		-- モータの接続可能最大数
	constant	c_ENC_CH	: integer :=13;		-- エンコーダの接続可能最大数
	constant	c_SNS_CH	: integer :=16;		-- 汎用センサの接続可能最大数
	constant	c_PLS_CH	: integer :=8;		-- 分離型パルスセンサの接続可能最大数
	constant	c_ACT_CH	: integer :=6;		-- アクチュエータの接続可能最大数
	constant	c_PUM_CH	: integer :=2;		-- ポンプの接続可能最大数
	constant	c_MISOLen	: integer :=40;		-- 
	constant	c_MOSILen	: integer :=114;	-- 

	type MODE_TYPE			is array ( 3 downto 0 )	of integer;
	type STM_ENC_MODE_TYPE	is array ( 1 to c_STM_CH) of MODE_TYPE;
	type ENC_STM_MODE_TYPE	is array ( 1 to c_ENC_CH) of MODE_TYPE;
	type STM_ENC_TYPE		is array ( 1 to c_STM_CH) of integer;
	type ENC_STM_TYPE		is array ( 1 to c_ENC_CH) of integer;

	constant C_STM_ENC : STM_ENC_MODE_TYPE :=(	--このコンスタントは各モータにどのエンコーダの出力を入力するかを決めるため
		-- 予備[11]	予備[10]	SL[01] default[00]--
		(		0,		0,		0,			 1	),
		(		0,		0,		0,			 2	),
		(		0,		0,		0,			 3	),
		(		0,		0,		0,			 4	),
		(		0,		0,		0,			 5	),
		(		0,		0,		0,			 6	),
		(		0,		0,		0,			 7	),
		(		0,		0,		0,			 8	),
		(		0,		0,		0,			 9	),
		(		0,		0,		0,			10	),
		(		0,		0,		0,			11	),
		(		0,		0,		0,			12	),
		(		0,		0,		0,			13	)
	);

	constant C_ENC_STM : ENC_STM_MODE_TYPE := (	--このコンスタントは各エンコーダにどのモータのモア駆動無効リミット入力に接続するかを決めるため
		-- 予備[11]	予備[10]	SL[01] default[00]--
		(		0,		0,		0,			 1	),
		(		0,		0,		0,			 2	),
		(		0,		0,		0,			 3	),
		(		0,		0,		0,			 4	),
		(		0,		0,		0,			 5	),
		(		0,		0,		0,			 6	),
		(		0,		0,		0,			 7	),
		(		0,		0,		0,			 8	),
		(		0,		0,		0,			 9	),
		(		0,		0,		0,			10	),
		(		0,		0,		0,			11	),
		(		0,		0,		0,			12	),
		(		0,		0,		0,			13	)
	);

	--****************************
	-- return greater one
	function	fn_MAX	(
		A	: integer ;
		B	: integer
	) return	integer ;

	function	fn_MAX	(
		A	: std_logic_vector ;
		B	: std_logic_vector
	) return	std_logic_vector ;
end package w_pack;

package body w_pack is	
	--****************************
	-- return greater one
	function	fn_MAX	(
		A	: integer ;
		B	: integer
	) return	integer	is
		variable	vi_Y	: integer ;
	begin
		if ( A > B ) then
			vi_Y := A ;
		else
			vi_Y := B ;
		end if ;
			
		return vi_Y ;
	end function ;

	function	fn_MAX	(
		A	: std_logic_vector ;
		B	: std_logic_vector
	) return	std_logic_vector	is
		variable	vi_A	: integer ;
		variable	vi_B	: integer ;
		variable	vi_Y	: integer ;
		variable	v_YA	: std_logic_vector( A'range ) ;
		variable	v_YB	: std_logic_vector( B'range ) ;
	begin
		vi_A	:= conv_integer( A ) ;
		vi_B	:= conv_integer( B ) ;
		if ( vi_A > vi_B ) then
			vi_Y := vi_A ;
		else
			vi_Y := vi_B ;
		end if ;

		if ( A'length > B'length ) then
			v_YA := conv_std_logic_vector( vi_Y, A'length ) ;
			return v_YA ;
		else
			v_YB := conv_std_logic_vector( vi_Y, B'length ) ;
			return v_YB ;
		end if ;
	end function ;
	
end package body w_pack ;