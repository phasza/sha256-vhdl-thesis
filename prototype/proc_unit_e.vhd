----------------------------------------------------------------------------------
-- File name:		proc_unit_e.vhd
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

ENTITY proc_unit IS
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
	
			clk_i	 		: 		IN std_logic;
			res_n_i			:		IN std_logic;
			
			last_tr_i		:		IN std_logic;
			start_tr_i		:		IN std_logic;
			hash_ack_i		:		IN std_logic;
			hash_ready_o	:		OUT std_logic;
			cpu_busy_o		:		OUT std_logic;
			
			di_i			:		IN std_logic_vector (31 DOWNTO 0);
			rd_addr_o		:		OUT std_logic_vector (3 DOWNTO 0);
			
			hash_do_o		:		OUT	std_logic_vector (31 DOWNTO 0)
			
			);
END proc_unit;
