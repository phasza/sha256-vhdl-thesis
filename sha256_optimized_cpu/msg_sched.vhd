----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:01:12 05/20/2016 
-- Design Name: 
-- Module Name:    msg_sched - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.cpu_func_pkg.ALL;

ENTITY msg_sched IS
	PORT (
	
			clk_i		: IN std_logic;
			di_i		: IN std_logic_vector(31 DOWNTO 0);
			do_o		: OUT std_logic_vector(31 DOWNTO 0);
			
			mux_sel_i	: IN std_logic

			);
END msg_sched;

ARCHITECTURE struct OF msg_sched IS

	--------------------------
	-- Internal signals
	--------------------------
	
	-- Register outputs
	SIGNAL	y_0	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_1	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_2	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_3	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_4	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_5	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_6	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_7	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_8	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_9	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_10	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_11	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_12	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_13	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_14	:	unsigned (31 DOWNTO 0);
	SIGNAL	y_15	:	unsigned (31 DOWNTO 0);

	-- Carry Save Adder outputs
	SIGNAL	wt_00_y	:	unsigned (31 DOWNTO 0);
	SIGNAL	wt_01_y	:	unsigned (31 DOWNTO 0);
	SIGNAL	wt_10_y	:	unsigned (31 DOWNTO 0);
	SIGNAL	wt_11_y	:	unsigned (31 DOWNTO 0);
	
	-- Multiplexer output
	SIGNAL	mux_y	:	unsigned (31 DOWNTO 0);
	-- Actual message word
	SIGNAL	wt_y	:	unsigned (31 DOWNTO 0);

BEGIN

	-- Input multiplexer
	mux_y <= unsigned(di_i) WHEN mux_sel_i = '0' ELSE
			  wt_10_y + wt_11_y;

	-- Register instantiations from 0 to 15
	reg0 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => mux_y, 
			y => y_0
		);
	reg1 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_0, 
			y => y_1
		);
	reg2 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_1, 
			y => y_2
		);
	reg3 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_2, 
			y => y_3
		);
	reg4 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_3, 
			y => y_4
		);
	reg5 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_4, 
			y => y_5
		);
	reg6 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_5, 
			y => y_6
		);
	reg7 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_6, 
			y => y_7
		);
	reg8 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_7, 
			y => y_8
		);
	reg9 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_8, 
			y => y_9
		);
	reg10 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_9, 
			y => y_10
		);
	reg11 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_10, 
			y => y_11
		);
	reg12 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_11, 
			y => y_12
		);
	reg13 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_12, 
			y => y_13
		);
	reg14 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_13, 
			y => y_14
		);
	reg15 : ENTITY work.reg32
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			clk_i => clk_i, 
			x => y_14, 
			y => y_15
		);
	
	-- First Carry Save Adder
	--		output <= prev_wt(0) + sigma0(prev_wt(1)) + prev_wt(9)
	wt_csa0 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => y_15, 
			x2 => sigma0(y_14), 
			x3 => y_6,
			y1 => wt_00_y, 
			y2 => wt_01_y
		);
	
	-- Second Carry Save Adder
	--		output <= prev_wt(0) + sigma0(prev_wt(1)) + prev_wt(9) + prev_wt(14)
	wt_csa1 : ENTITY work.csa
		GENERIC MAP(
			g_bit_num => 32
			)
		PORT MAP(
			x1 => wt_00_y, 
			x2 => wt_01_y, 
			x3 => sigma1(y_1),
			y1 => wt_10_y, 
			y2 => wt_11_y
		);
	
	-- Message output
	do_o <= std_logic_vector(y_0);
END struct;

