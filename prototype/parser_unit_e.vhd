----------------------------------------------------------------------------------
-- File name:		parser_unit_e.vhd
-- Create Date:    	04/14/2016 
-- Module Name:    	parser_unit
-- Project Name:   	hp_sha256
-- Description: 
--
----------------------------------------------------------------------------------
-- History: 
-- Date			| Change
-- 04.Apr.2016  | Initial
----------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY parser_unit IS
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
	
			clk_i	 		: 		IN std_logic;
			rst_n_i			:		IN std_logic;
			cpu_busy_i		:		IN std_logic;
			tr_trigger_i 	:		IN std_logic;
			data_valid_i 	:		IN std_logic;
			
			di_i			:		IN std_logic_vector(31 DOWNTO 0);
			do_o			:		OUT std_logic_vector(31 DOWNTO 0);
			
			wr_en_o			:		OUT std_logic;
			wr_addr_o		:		OUT std_logic_vector(3 DOWNTO 0);
			
			start_tr_o		:		OUT std_logic;
			last_tr_o		:		OUT std_logic;
			cpu_busy_o		:		OUT std_logic

			);
END parser_unit;
