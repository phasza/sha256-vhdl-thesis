----------------------------------------------------------------------------------
-- File name:		output_ctrl_e.vhd
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

ENTITY output_ctrl IS
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
	
			clk_i	 		: 		IN std_logic;
			res_n_i			:		IN std_logic;
			hash_ready_i	:		IN std_logic;
			cfg_sel			:		IN std_logic;
			di_i			:		IN std_logic_vector(31 DOWNTO 0);
			s_do_o			:		OUT std_logic;
			p_do_o			:		OUT std_logic_vector(31 DOWNTO 0)
			);
END output_ctrl;
