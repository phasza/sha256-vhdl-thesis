----------------------------------------------------------------------------------
-- File name:		dma_ram_e.vhd
-- Create Date:    	04/14/2016 
-- Module Name:    	dma_ram
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

ENTITY dma_ram IS
	GENERIC (
			g_data_width : integer := 16;
			g_addr_width : integer := 12;
			g_ram_size	 : integer := 4096
			);
	PORT (
	
			clk_i	 		: 		IN std_logic;
			rd_en_i		:		IN std_logic;
			wr_en_i		:		IN std_logic;
			
			rd_addr_i	:		IN std_logic_vector(g_addr_width-1 DOWNTO 0);
			wr_addr_i	:		IN std_logic_vector(g_addr_width-1 DOWNTO 0);	
			di_i			:		IN std_logic_vector(g_data_width-1 DOWNTO 0);
			do_o			:		OUT std_logic_vector(g_data_width-1 DOWNTO 0)
			
			);
END dma_ram;
