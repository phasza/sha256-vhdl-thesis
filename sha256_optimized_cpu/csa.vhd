----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:15:08 05/20/2016 
-- Design Name: 
-- Module Name:    csa - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	Carry Save Adder
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

ENTITY csa IS
  GENERIC(g_bit_num: NATURAL := 8);
	PORT (
		x1, x2, x3: IN unsigned(g_bit_num-1 DOWNTO 0);
		y1, y2: OUT unsigned(g_bit_num-1 DOWNTO 0)
	);
END csa;

ARCHITECTURE behavior OF csa IS
BEGIN
  y2(0) <= '0';
  iteration: FOR i IN 0 TO g_bit_num-2 GENERATE
    y1(i) <= x1(i) XOR x2(i) XOR x3(i);
    y2(i+1) <= (x1(i) AND x2(i)) OR (x1(i) AND x3(i)) OR (x2(i) AND x3(i));
  END GENERATE;
  y1(g_bit_num-1) <= x1(g_bit_num-1) XOR x2(g_bit_num-1) XOR x3(g_bit_num-1);
END behavior;