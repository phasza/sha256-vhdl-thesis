----------------------------------------------------------------------------------
-- File name:		input_ctrl.vhd
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity input_ctrl is
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
	
			clk_i	 		: 		IN std_logic;
			res_n_i			:		IN std_logic;
			cfg_sel			:		IN std_logic;
			
			t_trigger_i		:		IN std_logic;
			last_tr_i		:		IN std_logic;
			cpu_busy_i		:		IN std_logic;
			s_di_i				: 		IN std_logic;
			p_di_i				: 		IN std_logic_vector(31 DOWNTO 0);
			
			data_valid_o			:		OUT std_logic;
			do_o				:		OUT std_logic_vector(31 DOWNTO 0)
			
			);
end input_ctrl;
