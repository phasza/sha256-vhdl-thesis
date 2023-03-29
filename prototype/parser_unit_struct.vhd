----------------------------------------------------------------------------------
-- File name:		parser_unit_struct.vhd
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

ARCHITECTURE struct OF parser_unit IS

	----------------------------------
	-- FSM state type
	----------------------------------
	TYPE parser_state_type IS (
		idle,
		first_length_word,
		second_length_word,
		calculate_data,
		wait_cpu_response,
		transmit_data
	);
	
	----------------------------------
	-- Internal signals
	----------------------------------
	SIGNAL	data_length	:	unsigned(63 DOWNTO 0);
	SIGNAL	work_index	:	unsigned(3 DOWNTO 0);
	SIGNAL	start_tr		:	std_logic;
	SIGNAL	last_tr		:	std_logic;
	SIGNAL	wr_en			: std_logic;
	SIGNAL	state	:	parser_state_type;

BEGIN
	
	----------------------------------
	p_clocked : PROCESS(
			clk_i,
			rst_n_i
	)
	----------------------------------
		----------------------------------
		-- Process variables
		----------------------------------
		VARIABLE data_end_index : unsigned(4 DOWNTO 0);
		VARIABLE cur_data_length : unsigned(63 DOWNTO 0);
		VARIABLE padding_word : unsigned(31 DOWNTO 0);
		VARIABLE padding_bit_index : unsigned(4 DOWNTO 0);
		VARIABLE padding : std_logic;
		VARIABLE padding_extra_block : std_logic;
	BEGIN
		
		-- asynchronous reset
		IF (rst_n_i = g_reset_level) THEN
			state <= idle;
			start_tr <= '0';
			last_tr <= '0';
			
		-- synchronous operation
		ELSIF (rising_edge(clk_i)) THEN
			
			-- FSM
			CASE state IS
			
				-- when IDLE
				--	wait for external trigger
				--		- state to read length word
				--		- set control signals
				WHEN idle =>
					IF (tr_trigger_i  = '1') THEN
						state <= first_length_word;
						last_tr <= '0';
						start_tr <= '0';
					END IF;
				
				-- when READ FIRST LENGHT WORD
				--	read input data
				WHEN first_length_word =>
					IF (data_valid_i = '1') THEN
						data_length <=  x"0000_0000" & unsigned(di_i) ;
						state <= second_length_word;
					END IF;
				
				-- when READ SECOND LENGHT WORD
				--	read input data
				WHEN second_length_word =>
					IF (data_valid_i = '1') THEN
						data_length <= unsigned(di_i) & data_length(31 DOWNTO 0);
						cur_data_length := unsigned(di_i) & data_length(31 DOWNTO 0);
						state <= calculate_data;
					END IF;
				
				-- when CALCULATE DATA
				WHEN calculate_data =>
				
					-- Larger than a whole block
					IF (cur_data_length(63 DOWNTO 9) > 0) THEN
						data_end_index := "10000";
						padding := '0';
						wr_en <= '1';
						work_index <= (OTHERS => '0');
						cur_data_length := cur_data_length - x"200";
						padding_extra_block := '1';
						padding := '1';
						state <= transmit_data;
						
					-- Else smaller than one block
					ELSIF (cur_data_length > 0) THEN
						data_end_index := "00000" + cur_data_length(8 DOWNTO 5);
						padding_bit_index := cur_data_length(4 DOWNTO 0);
						padding := '1';
						padding_word := (OTHERS => '0');
						wr_en <= '1';
						work_index <= (OTHERS => '0');
						state <= transmit_data;
						
						-- if data_length > 447, then add extra block
						IF (cur_data_length(8 DOWNTO 6) = "111") THEN
							padding_extra_block := '1';
						ELSIF
							padding_extra_block := '0';
						END IF;
						cur_data_length := (OTHERS => '0');
					
					-- Already transmitted everything but the extra padding block
					ELSIF (padding_extra_block = '1') THEN
						
						-- If '1' bit padding is needed in extra block
						--	i.e. previous data_length was exactly 512 bit
						IF (padding = '1') THEN
							padding_bit_index := (OTHERS => '0');
							padding_word := (OTHERS => '0');
						END IF;
						
						padding_extra_block := '0';
						data_end_index := "00000";
						wr_en <= '1';
						work_index <= (OTHERS => '0');
						state <= transmit_data;
					
					-- Else everything is transmitted, close padding and parsing
					ELSIF
						last_tr <= '1';
						state <= idle;
					END IF;
					
				-- when TRANSMIT DATA
				WHEN transmit_data =>
					
					-- if input is valid
					IF (data_valid_i = '1') THEN
						
						-- if block is not finished read next data
						IF (work_index < data_end_index) THEN
							do_o <= di_i;
						
						-- else if padding is needed, then add padding bit
						ELSIF (padding = '1') THEN
							IF (padding_bit_index = x"0") THEN
								padding_word := padding_word + x"1";
							ELSE
								padding_word := padding_word + unsigned(di_i(31 DOWNTO (31 - to_integer(padding_bit_index) + 1)) & '1');
							END IF;
							do_o <= std_logic_vector(padding_word sll (31 - to_integer(padding_bit_index)));
							padding := '0';
						
						-- add datalength to the last block
						ELSIF (cur_data_length = x"0" and padding_extra_block = '0' and work_index > x"d") THEN
							IF work_index(0) = '0' THEN
								do_o <= std_logic_vector(data_length(63 DOWNTO 32));
							ELSE
								do_o <= std_logic_vector(data_length(31 DOWNTO 0));
							END IF;
							
						-- else drive output to 0
						ELSE
							do_o <= (OTHERS => '0');
						END IF;
						
						-- if end of transmitting block, then start CPU transfer
						IF (work_index = x"F") THEN
							start_tr <= '1';
							state <= wait_cpu_response;
						END IF;
						work_index <= work_index + 1;
					END IF;
				
				-- when WAIT CPU RESPONSE
				--	after 5 cycles check if cpu is still busy
				--		if not then start another transfer
				WHEN wait_cpu_response =>
					wr_en <= '0';
					start_tr <= '0';
					IF (work_index > 5 and cpu_busy_i = '0') THEN
						state <= calculate_data;
					END IF;
					work_index <= work_index + 1;
			END CASE;
		END IF;
	END PROCESS;
	
	-- output of control signals
	start_tr_o <= start_tr;
	last_tr_o <= last_tr;
	wr_en_o <= wr_en;
	wr_addr_o <= std_logic_vector(work_index - 1) WHEN wr_en = '1' ELSE
					(OTHERS => 'Z');
	cpu_busy_o <= cpu_busy_i;
		
END struct;