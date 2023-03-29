----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:57:28 05/21/2016 
-- Design Name: 
-- Module Name:    reg32_load - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	n bit register with load value with enable
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


ENTITY reg32_load IS
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
END reg32_load;

ARCHITECTURE behavior OF reg32_load IS
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
			y <= g_clear_value;
		ELSIF (rising_edge(clk_i)) THEN
			IF (en_i = '1') THEN
				y <= x_y;
			END IF;
		END IF;
	END PROCESS;
	x_y <= x;
	
END behavior;

