----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:58:31 05/15/2016 
-- Design Name: 
-- Module Name:    module_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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


ENTITY module_top IS
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
			clk_i 			: IN std_logic;
			res_n_i 		: IN std_logic;
			cfg_sel 		: IN std_logic_vector(1 DOWNTO 0);
			p_di_i			: IN std_logic_vector (31 DOWNTO 0);
			s_di_i			: IN std_logic;
			t_trigger_i 	: IN std_logic;
			cpu_busy_o 		: OUT std_logic;
			hash_ready_o 	: OUT std_logic;
			hash_ack_i 		: IN std_logic;
			s_do_o			: OUT std_logic;
			p_do_o			: OUT std_logic_vector(31 DOWNTO 0)
			);
END module_top;

ARCHITECTURE struct OF module_top IS

		-- Internal signals
		SIGNAL cpu_busy_y			: std_logic;
		SIGNAL parser_wr_en_y		: std_logic;
		SIGNAL parser_di_y			: std_logic_vector (31 DOWNTO 0);
		SIGNAL parser_wr_addr_y		: std_logic_vector (3 DOWNTO 0);
		SIGNAL cpu_rd_addr			: std_logic_vector (3 DOWNTO 0);
		SIGNAL start_tr				: std_logic;
		SIGNAL last_tr				: std_logic;
		SIGNAL data_valid 			: std_logic;
		SIGNAL hash_ready 			: std_logic;
		SIGNAL input_ctrl_do_y		: std_logic_vector (31 DOWNTO 0);
		SIGNAL parser_do 			: std_logic_vector (31 DOWNTO 0);
		SIGNAL parser_rd_en 		: std_logic;
		SIGNAL cpu_do 				: std_logic_vector (31 DOWNTO 0);
		
BEGIN

	-- Input control instantiation
	input_ctrl : ENTITY work.input_ctrl
	GENERIC MAP(
			g_reset_level => g_reset_level
			)
	PORT MAP(
	
			clk_i => clk_i,
			res_n_i => res_n_i,
			cfg_sel => cfg_sel(1),
			t_trigger_i => t_trigger_i,
			last_tr_i => last_tr,
			cpu_busy_i => cpu_busy_y,
			s_di_i => s_di_i,
			p_di_i => p_di_i,
			data_valid_o => data_valid,
			do_o => input_ctrl_do_y
			);

	-- Parser and padder instantiation
	parser : ENTITY work.parser_unit
	GENERIC MAP(
			g_reset_level => g_reset_level
			)
	PORT MAP (
	
			clk_i => clk_i,
			rst_n_i => res_n_i,
			cpu_busy_i	=> cpu_busy_y,
			tr_trigger_i => t_trigger_i,
			data_valid_i => data_valid,
			di_i			=> input_ctrl_do_y,
			do_o			=> parser_di_y,
			wr_en_o		=> parser_wr_en_y,
			wr_addr_o	=> parser_wr_addr_y,
			start_tr_o	=> start_tr,
			last_tr_o	=> last_tr,
			cpu_busy_o	=> cpu_busy_o

			);

	-- RAM READ enable signal
	--		always '0' when WRITE is enabled
	parser_rd_en <= NOT parser_wr_en_y;

	-- Padded message RAM
	parser_ram : ENTITY work.dma_ram
		GENERIC MAP(
			g_data_width => 32,
			g_addr_width => 4,
			g_ram_size	 => 16
			)
		PORT MAP(
			clk_i => clk_i,
			rd_en_i => parser_rd_en,
			wr_en_i => parser_wr_en_y,
			rd_addr_i => cpu_rd_addr,
			wr_addr_i => parser_wr_addr_y,
			di_i => parser_di_y,
			do_o => parser_do
		);
	
	-- CPU instantiation
	hash_cpu : ENTITY work.proc_unit
		GENERIC MAP(g_reset_level => g_reset_level)
		PORT MAP(
			clk_i => clk_i,
			res_n_i => res_n_i,
			last_tr_i => last_tr,
			start_tr_i => start_tr,
			hash_ack_i => hash_ack_i,
			hash_ready_o => hash_ready,
			cpu_busy_o => cpu_busy_y,
			di_i => parser_do,
			rd_addr_o => cpu_rd_addr,
			hash_do_o => cpu_do
		);

	-- Output control instantiation
	output_ctrl : entity work.output_ctrl
		GENERIC MAP(g_reset_level => g_reset_level)
		PORT MAP(
			clk_i => clk_i,
			res_n_i => res_n_i,
			hash_ready_i => hash_ready,
			cfg_sel => cfg_sel(0),
			di_i => cpu_do,
			s_do_o => s_do_o,
			p_do_o => p_do_o
		);
	
	-- Hash ready output signal
	hash_ready_o <= hash_ready;

END struct;

