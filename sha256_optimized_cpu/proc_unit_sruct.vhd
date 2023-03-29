----------------------------------------------------------------------------------
-- File name:		proc_unit_struct.vhd
-- Create Date:    	04/14/2016 
-- Module Name:    	proc_unit
-- Project Name:   	hp_sha256
-- Description: 
--
----------------------------------------------------------------------------------
-- History: 
-- Date			| Change
-- 04.Apr.2015  | Initial
----------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.cpu_func_pkg.ALL;

ARCHITECTURE struct OF proc_unit IS

	---------------------------------
	-- Memory type
	---------------------------------
	TYPE hash_value_type IS ARRAY (7 DOWNTO 0) OF unsigned (31 DOWNTO 0);
	
	---------------------------------
	-- Work constant
	---------------------------------
	CONSTANT c_init_hash_val		:	hash_value_type :=
										(
										 x"5be0_cd19",
										 x"1f83_d9ab",
										 x"9b05_688c",
										 x"510e_527f",
									     x"a54f_f53a",
										 x"3c6e_f372",
										 x"bb67_ae85",
										 x"6a09_e667"
										);
	
	---------------------------------
	-- Internal signals
	---------------------------------
	-- Multiplexer D0 output
	SIGNAL mux0_y : unsigned(31 DOWNTO 0);
	
	-- Multiplexer D1 output
	SIGNAL mux1_y : unsigned(31 DOWNTO 0);
	SIGNAL sum1_y : unsigned(31 DOWNTO 0);
	
	-- Mathematical function values
	SIGNAL ch_y : unsigned(31 DOWNTO 0);
	SIGNAL sum0_y : unsigned(31 DOWNTO 0);
	SIGNAL maj_y : unsigned(31 DOWNTO 0);
	
	-- Carry Save Adder signals
	SIGNAL c0_y : unsigned(31 DOWNTO 0);
	SIGNAL s0_y : unsigned(31 DOWNTO 0);
	SIGNAL add0_y : unsigned(31 DOWNTO 0); 
	SIGNAL c1_y : unsigned(31 DOWNTO 0);
	SIGNAL s1_y : unsigned(31 DOWNTO 0);
	SIGNAL add1_y : unsigned(31 DOWNTO 0); 
	SIGNAL c2_y : unsigned(31 DOWNTO 0);
	SIGNAL s2_y : unsigned(31 DOWNTO 0);
	SIGNAL add2_y : unsigned(31 DOWNTO 0); 
	SIGNAL c3_y : unsigned(31 DOWNTO 0);
	SIGNAL s3_y : unsigned(31 DOWNTO 0);
	SIGNAL add3_y : unsigned(31 DOWNTO 0);
	SIGNAL c4_y : unsigned(31 DOWNTO 0);
	SIGNAL s4_y : unsigned(31 DOWNTO 0);
	SIGNAL add4_y : unsigned(31 DOWNTO 0);

	-- Temporary regsiter outputs
	SIGNAL m0_y : unsigned(31 DOWNTO 0);
	SIGNAL m1_y : unsigned(31 DOWNTO 0);
	SIGNAL temp_y : unsigned(31 DOWNTO 0);
	
	-- Work variable register outputs
	SIGNAL a_y : unsigned(31 DOWNTO 0);
	SIGNAL b_y : unsigned(31 DOWNTO 0);
	SIGNAL c_y : unsigned(31 DOWNTO 0);
	SIGNAL d_y : unsigned(31 DOWNTO 0);
	SIGNAL e_y : unsigned(31 DOWNTO 0);
	SIGNAL f_y : unsigned(31 DOWNTO 0);
	SIGNAL g_y : unsigned(31 DOWNTO 0);
	SIGNAL h_y : unsigned(31 DOWNTO 0);
	
	-- Work variable register inputs
	SIGNAL a_i_y : unsigned(31 DOWNTO 0);
	SIGNAL b_i_y : unsigned(31 DOWNTO 0);
	SIGNAL c_i_y : unsigned(31 DOWNTO 0);
	SIGNAL d_i_y : unsigned(31 DOWNTO 0);
	SIGNAL e_i_y : unsigned(31 DOWNTO 0);
	SIGNAL f_i_y : unsigned(31 DOWNTO 0);
	SIGNAL g_i_y : unsigned(31 DOWNTO 0);
	SIGNAL h_i_y : unsigned(31 DOWNTO 0);
	
	-- Register enable signals from input
	SIGNAL m0_en_y : std_logic;
	SIGNAL m1_en_y : std_logic;
	SIGNAL temp_en_y : std_logic;
	SIGNAL a_en_y : std_logic;
	SIGNAL b_en_y : std_logic;
	SIGNAL c_en_y : std_logic;
	SIGNAL d_en_y : std_logic;
	SIGNAL e_en_y : std_logic;
	SIGNAL f_en_y : std_logic;
	SIGNAL g_en_y : std_logic;
	SIGNAL h_en_y : std_logic;
	
	-- Hash register output signals
	SIGNAL hash_0_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_1_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_2_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_3_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_4_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_5_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_6_y : unsigned(31 DOWNTO 0);
	SIGNAL hash_7_y : unsigned(31 DOWNTO 0);
	
	-- Temporary register clear signals
	signal m0_clr_y : std_logic;
	signal m1_clr_y : std_logic;
	signal temp_clr_y : std_logic;
	
	-- Work variable register internal enable inputs
	signal a_en_i_y : std_logic;
	signal b_en_i_y : std_logic;
	signal c_en_i_y : std_logic;
	signal d_en_i_y : std_logic;
	signal e_en_i_y : std_logic;
	signal f_en_i_y : std_logic;
	signal g_en_i_y : std_logic;
	signal h_en_i_y : std_logic;
	
BEGIN

	-- First Carry Save Adder instantiation
	csa0 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => unsigned(kt_i), 
			x2 => unsigned(wt_i), 
			x3 => mux1_y,
			y1 => c0_y, 
			y2 => s0_y
		);
	-- Output0 <= Kt + Wt + H
	add0_y <= (c0_y + s0_y);
	
	-- Second Carry Save Adder instantiation
	csa1 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => c0_y, 
			x2 => s0_y, 
			x3 => mux0_y,
			y1 => c1_y, 
			y2 => s1_y
		);
	-- Output1 <= Kt + Wt + D 
	add1_y <= (c1_y + s1_y);
	
	-- M1 register clear input
	m0_clr_y <= clr_i or hash_en_i;
	-- M1 register instantiation
	m1 : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value => x"0000_0000"
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => m0_clr_y,
			en_i => m0_en_y,
			x => add1_y, 
			y => m0_y
		);
	
	-- M2 register clear input
	m1_clr_y <= clr_i or hash_en_i;
	-- M2 register instantiation
	m2 : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value => x"0000_0000"
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => m1_clr_y,
			en_i => m1_en_y,
			x => add0_y, 
			y => m1_y
		);
	
	-- Third Carry Save Adder instantiation
	csa2 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => m0_y, 
			x2 => ch_y, 
			x3 => sum1_y,
			y1 => c2_y, 
			y2 => s2_y
		);
	-- Output2 <= Wt + Kt + H + Ch(E,F,G) + Sum1(E)
	add2_y <= (c2_y + s2_y);
	
	-- Fourth Carry Save Adder instantiation
	csa3 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => m1_y, 
			x2 => ch_y, 
			x3 => sum1_y,
			y1 => c3_y, 
			y2 => s3_y
		);
	-- Output3 <= Wt + Kt + D + Ch(E,F,G) + Sum1(E)
	add3_y <= (c3_y + s3_y);
	
	-- L register clear input
	temp_clr_y <= clr_i or hash_en_i;
	-- L register instantiation
	temp : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value => x"0000_0000"
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => temp_clr_y,
			en_i => temp_en_y,
			x => add3_y, 
			y => temp_y
		);
	
	-- Fifth Carry Save Adder instantiation
	csa4 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => temp_y, 
			x2 => maj_y, 
			x3 => sum0_y,
			y1 => c4_y, 
			y2 => s4_y
		);
	-- Output4 <= Wt + Kt + H + Ch(E,F,G) + Sum1(E)	+ Maj(A,B,C) + Sum0(A)
	add4_y <= (c4_y + s4_y);
	
	-- A..H register enable
	-- and register instantiation
	a_i_y <= hash_0_y WHEN hash_en_i = '1' ELSE
				add4_y;
	
	a_en_i_y <= a_en_y or hash_en_i;
	
	a : entity work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(0)
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => clr_i,
			en_i => a_en_i_y,
			x => a_i_y, 
			y => a_y
		);
		
	b_i_y <= hash_1_y WHEN hash_en_i = '1' ELSE
				a_y;
	
	b_en_i_y <= b_en_y or hash_en_i;
	
	b : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(1)
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => clr_i,
			en_i => b_en_i_y,
			x => b_i_y, 
			y => b_y
		);
		
	c_i_y <= hash_2_y WHEN hash_en_i = '1' ELSE
				b_y;
	
	c_en_i_y <= c_en_y or hash_en_i;
	
	c : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(2)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => c_en_i_y,
			x => c_i_y, 
			y => c_y
		);
		
	d_i_y <= hash_3_y WHEN hash_en_i = '1' ELSE
				c_y;
		
	d_en_i_y <= d_en_y or hash_en_i;
		
	d : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(3)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => d_en_i_y,		
			x => d_i_y, 
			y => d_y
		);
		
	e_i_y <= hash_4_y WHEN hash_en_i = '1' ELSE
				add2_y;
				
	e_en_i_y <= e_en_y or hash_en_i;
		
	e : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(4)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => e_en_i_y,
			x => e_i_y, 
			y => e_y
		);
		
	f_i_y <= hash_5_y WHEN hash_en_i = '1' ELSE
				e_y;
	
	f_en_i_y <= f_en_y or hash_en_i;
	
	f : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(5)
			)
		PORT MAP(
			clk_i => clk_i, 
			clr_i => clr_i,
			en_i => f_en_i_y,
			x => f_i_y, 
			y => f_y
		);
	
	g_i_y <= hash_6_y WHEN hash_en_i = '1' ELSE
				f_y;	
	
	g_en_i_y <= g_en_y or hash_en_i;
	
	g : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(6)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => g_en_i_y,
			x => g_i_y, 
			y => g_y
		);
		
	h_i_y <= hash_7_y WHEN hash_en_i = '1' ELSE
				g_y;
	
	h_en_i_y <= h_en_y or hash_en_i;
	
	h : ENTITY work.reg32_load
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(7)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => h_en_i_y,
			x => h_i_y,
			y => h_y
		);
	
	-- D0 multiplexer
	mux0_y <= d_y WHEN mux0_sel_i = "00" ELSE
				 c_y WHEN mux0_sel_i = "01" ELSE
				 b_y;
	-- D1 multiplexer
	mux1_y <= h_y WHEN mux1_sel_i = '0' ELSE
				 g_y;
				 
	-- Mathematical values
	sum1_y <= sum1(e_y);
	ch_y <= ch_x_y_z(e_y, f_y, g_y);
	sum0_y <= sum0(a_y);
	maj_y <= maj_x_y_z(a_y, b_y, c_y);
	
	-- Input enalbe vector sampling
	m0_en_y <= en_vecotr_i(0);
	m1_en_y <= en_vecotr_i(1);
	temp_en_y <= en_vecotr_i(2);
	a_en_y <= en_vecotr_i(3);
	b_en_y <= en_vecotr_i(4);
	c_en_y <= en_vecotr_i(5);
	d_en_y <= en_vecotr_i(6);
	e_en_y <= en_vecotr_i(7);
	f_en_y <= en_vecotr_i(8);
	g_en_y <= en_vecotr_i(9);
	h_en_y <= en_vecotr_i(10);
	
	-- Intermediate hash value register instantiations
	hash_0: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(0)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => a_y, 
			y => hash_0_y
		);
		
	hash_1: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(1)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => b_y, 
			y => hash_1_y
		);
		
	hash_2: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(2)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => c_y, 
			y => hash_2_y
		);
		
	hash_3: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(3)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => d_y, 
			y => hash_3_y
		);
		
	hash_4: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(4)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => e_y, 
			y => hash_4_y
		);
		
	hash_5: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(5)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => f_y, 
			y => hash_5_y
		);
		
	hash_6: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(6)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => g_y, 
			y => hash_6_y
		);
		
	hash_7: ENTITY work.hash_reg32
		GENERIC MAP(
			g_bit_num => 32,
			g_clear_value =>c_init_hash_val(7)
			)
		PORT MAP(
			clk_i => clk_i,
			clr_i => clr_i,
			en_i => hash_en_i,
			x => h_y, 
			y => hash_7_y
		);
	
	-- Output value assignmentsd
	do_o(255 DOWNTO 224) <= std_logic_vector(hash_0_y);
	do_o(223 DOWNTO 192) <= std_logic_vector(hash_1_y);
	do_o(191 DOWNTO 160) <= std_logic_vector(hash_2_y);
	do_o(159 DOWNTO 128) <= std_logic_vector(hash_3_y);
	do_o(127 DOWNTO 96) <= std_logic_vector(hash_4_y);
	do_o(95 DOWNTO 64) <= std_logic_vector(hash_5_y);
	do_o(63 DOWNTO 32) <= std_logic_vector(hash_6_y);
	do_o(31 DOWNTO 0) <= std_logic_vector(hash_0_y);
END struct;