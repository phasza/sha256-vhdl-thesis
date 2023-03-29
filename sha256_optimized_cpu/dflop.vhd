----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:44:05 05/21/2016 
-- Design Name: 
-- Module Name:    dflop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	D FlipFlop
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

ENTITY dflop IS
  PORT (
	clk_i  	: IN  std_logic;
	clr_i  	: IN std_logic;
	d_i		: IN std_logic;
	q_o	  	: OUT std_logic;
	n_q_o	: OUT std_logic
  );
END dflop;

ARCHITECTURE Behavioral OF dflop IS
	SIGNAL d : std_logic;
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
			q_o <= '0';
			n_q_o <= '1';
		ELSIF clk_i'event AND clk_i = '1' THEN
			q_o <= d_i;
			n_q_o <= NOT d_i;
		END IF;
	END process;

END Behavioral;

