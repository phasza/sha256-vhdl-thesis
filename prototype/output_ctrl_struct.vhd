---------------------------------------------------------------------------------
-- File name:		output_ctrl_struct.vhd
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

ARCHITECTURE struct OF output_ctrl IS

	----------------------------------
	-- FSM state type
	----------------------------------
	TYPE output_ctrl_state IS (
			idle,
			send_data
		);

	----------------------------------
	-- Internal signals
	----------------------------------
	SIGNAL state		:	output_ctrl_state;
	SIGNAL output_valid :	std_logic;
	SIGNAL input_word 	:  std_logic_vector(31 DOWNTO 0);
	SIGNAL work_index 	: unsigned(4 DOWNTO 0);
	SIGNAL cfg_sel_y 	: std_logic;
BEGIN

	----------------------------------
	p_clocked : PROCESS (
		clk_i,
		res_n_i
	)
	----------------------------------
	BEGIN
		
		-- when asynchronous reset
		IF (res_n_i = g_reset_level) THEN
			state <= idle;
			output_valid <= '0';
		
		-- else synchronous operation
		ELSIF (rising_edge(clk_i)) THEN
			
			-- FSM
			CASE state IS
			
				-- when IDLE
				-- 	wait for hash_ready
				--		- select configuration
				--		- read first input
				--		- signal output valid
				-- else
				--	output invalid
				WHEN idle =>
					IF (hash_ready_i = '1') THEN
						cfg_sel_y <= cfg_sel;
						output_valid <= '1';
						input_word <= di_i;
						work_index <= (OTHERS => '0');
						state <= send_data;
					ELSE
						output_valid <= '0';
					END IF;
					
				-- when SEND DATA
				--	if serial configuration
				--		- shift input word
				--		- increment work index
				--		if 31st iteration
				--			- disable output
				--			- return to IDLE
				WHEN send_data =>
					IF (cfg_sel_y = '0') THEN
						input_word <= '0' & input_word(31 DOWNTO 1);
						IF (work_index = x"1F") THEN
							output_valid <= '0';
							state <= idle;
						END IF;
						work_index <= work_index + 1;
					END IF;
			END CASE;
				
			-- serial configuration output
			IF (cfg_sel_y = '0' AND output_valid = '1' ) THEN
				s_do_o <= input_word(0);
			ELSE
				s_do_o <= 'Z';
			END IF;
			
			-- parallel configuration output
			IF (cfg_sel_y = '1' AND output_valid = '1' ) THEN	
				p_do_o <= di_i;
			ELSE
				p_do_o <= (OTHERS => 'Z');
			END IF;
		END IF;
		
	END PROCESS;
	
END struct;

