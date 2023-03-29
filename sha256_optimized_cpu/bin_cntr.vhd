----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:41:35 05/21/2016 
-- Design Name: 
-- Module Name:    bin_cntr - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	n bit binary counter
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY bin_cntr IS
  GENERIC (
		g_bit_num : natural := 6
	);
  PORT (
    clk_i  	: IN  std_logic;
	 clr_i  : IN std_logic;
	 do_o	: OUT std_logic_vector(g_bit_num-1 DOWNTO 0)
  );
END bin_cntr;

ARCHITECTURE structure of bin_cntr IS
	
	-- D FlipFlop component
	COMPONENT dflop IS
		PORT (
				clk_i	: IN std_logic;
				clr_i	: IN std_logic;
				d_i 	: IN std_logic;
				q_o 	: OUT std_logic;
				n_q_o 	: OUT std_logic
				);
	END COMPONENT;
	
	-- Internal signals
	SIGNAL d_y : std_logic_vector(g_bit_num-1 DOWNTO 0);
	SIGNAL q_y : std_logic_vector(g_bit_num-1 DOWNTO 0);
	
BEGIN

	-- 0th bit D FlipFlop
	dflop0: dflop PORT MAP (
			clk_i => clk_i,
			clr_i => clr_i,
			d_i => q_y(0),
			q_o => d_y(0),
			n_q_o => q_y(0)
		);
		
	-- 1th to n D FlipFlop
	dflop_vector: FOR i IN 1 TO g_bit_num-1 GENERATE
		dflop_i: dflop PORT MAP (
			clk_i => q_y(i-1),
			clr_i => clr_i,
			d_i => q_y(i),
			q_o => d_y(i),
			n_q_o => q_y(i)
		);
	END GENERATE;

	-- output signal
	do_o <= d_y;

END structure;
