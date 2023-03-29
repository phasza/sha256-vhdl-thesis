----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:57:28 05/21/2016 
-- Design Name: 
-- Module Name:    hash_reg32 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	register with adder output
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY hash_reg32 IS
	GENERIC(
		g_bit_num: NATURAL := 32;
		g_clear_value: unsigned(31 DOWNTO 0)
	);
	PORT (
		clk_i 	: IN std_logic;
		clr_i 	: IN std_logic;
		en_i 	: IN std_logic;
		x		: IN unsigned(g_bit_num-1 DOWNTO 0);
		y		: OUT unsigned(g_bit_num-1 DOWNTO 0)
);
END hash_reg32;

ARCHITECTURE behavior OF hash_reg32 IS
	SIGNAL x_y : unsigned (g_bit_num-1 DOWNTO 0);
BEGIN
  ----------------------------------
	p_clocked : PROCESS (
		clk_i,
		clr_i
	)
	----------------------------------
	-- 
	BEGIN
		IF (clr_i = '1') THEN
			x_y <= g_clear_value;
		elsif (rising_edge(clk_i)) THEN
			IF (en_i = '1') THEN
				x_y <= x;
			END IF;
		END IF;
	END PROCESS;
	y <= x_y + x;
	
	
END behavior;

