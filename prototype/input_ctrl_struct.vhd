----------------------------------------------------------------------------------
-- File name:		input_ctrl_struct.vhd
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
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ARCHITECTURE struct of input_ctrl IS
	
	----------------------------------
	-- FSM state type
	----------------------------------
	TYPE input_ctrl_state_type IS (
		idle,
		transmit_data,
		wait_cpu_busy
		);
		
	----------------------------------
	-- Internal signals
	----------------------------------
	SIGNAL state	: input_ctrl_state_type;
	SIGNAL work_index	: unsigned(4 DOWNTO 0);
	SIGNAL cfg_sel_y	: std_logic;
	
BEGIN
	----------------------------------
	p_clocked_serial : PROCESS (
		clk_i,
		res_n_i
	)
	----------------------------------
		----------------------------------
		-- Work variables
		----------------------------------
		VARIABLE temp_data : std_logic_vector(31 DOWNTO 0);
	BEGIN
	
		-- asynchronous reset
		IF (res_n_i = g_reset_level) THEN
			state <= idle;
			data_valid_o <= '0';
			
		-- synchronous operation
		ELSIF (rising_edge(clk_i)) THEN
				
				-- FSM
				CASE state IS
					
					-- when IDLE
					--	wait for external trigger
					--		set configuration
					--		reset work variables
					WHEN idle =>
						IF (t_trigger_i = '1') THEN
							cfg_sel_y <= cfg_sel;
							state <= transmit_data;
							work_index <= (OTHERS => '0');
							temp_data := (OTHERS => '0');
						END IF;
				
					-- when TRANSMIT DATA
					WHEN transmit_data =>
						
						-- if serial configuration
						--	sample input
						--		if 32th cycle
						--			output to parser
						--		else
						--			next bit in
						IF (cfg_sel_y = '0') THEN
							temp_data := s_di_i & temp_data(31 DOWNTO 1) ;
							IF (work_index = x"1F") THEN
								do_o <= temp_data;
								data_valid_o <= '1';
							ELSE
								data_valid_o <= '0';
							END IF;
							
							work_index <= work_index + 1;
							
							-- if last transfer, then go to IDLE state
							IF (last_tr_i = '1') THEN
								state <= idle;
							
							-- hold on cpu busy state
							ELSIF (cpu_busy_i = '1') THEN
								state <= wait_cpu_busy;
							END IF;
						
						-- If parallel configuration
						--	each cycle deliver the next data to parser
						ELSE
							do_o <= p_di_i;
							
							-- if last transfer, then go to IDLE state
							IF (last_tr_i = '1') THEN
								state <= idle;
								data_valid_o <= '0';
								
							-- else hold on cpu busy state
							ELSIF (cpu_busy_i = '1') THEN
								state <= wait_cpu_busy;
								data_valid_o <= '0';
							ELSE
								data_valid_o <= '1';
							END IF;
						END IF;
					
					-- when WAIT CPU BUSY
					--	sample cpu busy and continue transfer
					WHEN wait_cpu_busy =>
						IF (cpu_busy_i = '0') THEN
							state <= transmit_data;
						END IF;
				END CASE;
			END IF;
	END PROCESS;
END struct;

