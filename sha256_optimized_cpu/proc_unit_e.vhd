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
	PORT (
	
			clk_i	 		: IN std_logic;
			clr_i 			: IN std_logic;
			
			wt_i			: IN std_logic_vector (31 DOWNTO 0);
			kt_i			: IN std_logic_vector (31 DOWNTO 0);
			
			mux0_sel_i		: IN std_logic_vector (1 DOWNTO 0);
			mux1_sel_i		: IN std_logic;
			en_vecotr_i		: IN std_logic_vector (10 DOWNTO 0);
			hash_en_i		: IN std_logic;
			
			do_o			: OUT std_logic_vector (255 DOWNTO 0)
			);
END proc_unit;
