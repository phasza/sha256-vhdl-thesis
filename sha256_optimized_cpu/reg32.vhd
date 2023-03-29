----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:56:45 05/20/2016 
-- Design Name: 
-- Module Name:    reg32 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	simple n bit register
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


ENTITY reg32 IS
  GENERIC(g_bit_num: NATURAL := 32);
	PORT (
		clk_i 	: IN std_logic;
		x		: IN unsigned(g_bit_num-1 DOWNTO 0);
		y		: OUT unsigned(g_bit_num-1 DOWNTO 0)
	);
END reg32;

ARCHITECTURE behavior OF reg32 IS
	SIGNAL x_y : unsigned (g_bit_num-1 DOWNTO 0);
BEGIN
  ----------------------------------
	p_clocked : PROCESS (
		clk_i
	)
	----------------------------------
	-- 
	BEGIN
		IF (rising_edge(clk_i)) THEN
			y <= x_y;
		END IF;
	END PROCESS;
	x_y <= x;
	
END behavior;

