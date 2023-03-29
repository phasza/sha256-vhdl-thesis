----------------------------------------------------------------------------------
-- File name:		proc_unit_struct.vhd
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
USE work.cpu_func_pkg.ALL;

ARCHITECTURE struct OF proc_unit IS

	----------------------------------
	-- Memory types
	----------------------------------
	TYPE hash_value_type IS ARRAY (7 DOWNTO 0) OF unsigned (31 DOWNTO 0);
	TYPE work_value_type IS ARRAY (7 DOWNTO 0) OF unsigned (31 DOWNTO 0);
	TYPE work_const_type IS ARRAY (63 DOWNTO 0) OF unsigned (31 DOWNTO 0);
	TYPE mem_type IS ARRAY (integer RANGE <>) of unsigned (31 DOWNTO 0);
	
	----------------------------------
	-- FSM state type
	----------------------------------
	TYPE proc_unit_state_type IS (
		idle,
		init,
		compute_hash,
		save_hash_value
	);
	
	----------------------------------
	-- Constant sets
	----------------------------------
	CONSTANT c_init_hash_val		:	hash_value_type :=
										(
										 x"5be0_cd19",
										 x"1f83_d9ab",
										 x"9b05_688c",
										 x"510e_527f",
									    x"a54f_f53a",
										 x"3c6e_f372",
										 x"bb67_ae85",
										 x"6a09_e667"
										);
	
	CONSTANT c_work_const_val		:	work_const_type :=
										(
										 x"c671_78f2",
										 x"bef9_a3f7",
										 x"a450_6ceb",
										 x"90be_fffa",
										
										 x"8cc7_0208",
										 x"84c8_7814",
										 x"78a5_636f",
										 x"748f_82ee",
										
										 x"682e_6ff3",
										 x"5b9c_ca4f",
										 x"4ed8_aa4a",
										 x"391c_0cb3",
										
										 x"34b0_bcb5",
										 x"2748_774c",
										 x"1e37_6c08",
										 x"19a4_c116",
										
										 x"106a_a070",
										 x"f40e_3585",
										 x"d699_0624",
										 x"d192_e819",
										
										 x"c76c_51a3",
										 x"c24b_8b70",
										 x"a81a_664b",
										 x"a2bf_e8a1",
										
										 x"9272_2c85",
										 x"81c2_c92e",
										 x"766a_0abb",
										 x"650a_7354",

										 x"5338_0d13",
										 x"4d2c_6dfc",
										 x"2e1b_2138",
										 x"27b7_0a85",
										
										 x"1429_2967",
										 x"06ca_6351",
										 x"d5a7_9147",
										 x"c6e0_0bf3",
										
										 x"bf59_7fc7",
										 x"b003_27c8",
										 x"a831_c66d",
										 x"983e_5152",
										
										 x"76f9_88da",
										 x"5cb0_a9dc",
										 x"4a74_84aa",
										 x"2de9_2c6f",
										
										 x"240c_a1cc",
										 x"0fc1_9dc6",
										 x"efbe_4786",
										 x"e49b_69c1",
										
										 x"c19b_f174",
										 x"9bdc_06a7",
										 x"80de_b1fe",
										 x"72be_5d74",
										
										 x"550c_7dc3",
										 x"2431_85be",
										 x"1283_5b01",
										 x"d807_aa98",
										
										 x"ab1c_5ed5",
										 x"923f_82a4",
										 x"59f1_11f1",
										 x"3956_c25b",
										
										 x"e9b5_dba5",
										 x"b5c0_fbcf",
										 x"7137_4491",
										 x"428a_2f98"
										);
	
	----------------------------------
	-- Internal signals
	----------------------------------	
	SIGNAL  prev_wt 		:  mem_type(0 to 15);
	SIGNAL	cur_state		: proc_unit_state_type;
	SIGNAL 	hash_ready		: std_logic;
	SIGNAL	cpu_busy		: std_logic;
	SIGNAL	data_valid		:  std_logic;
	
	SIGNAL	work_index		: unsigned (5 DOWNTO 0);
	SIGNAL 	rd_index		: unsigned (2 DOWNTO 0);
	SIGNAL	work_var	    : work_value_type;
	SIGNAL	cur_hash_value	: hash_value_type;
	
BEGIN
	----------------------------------
	p_clocked : PROCESS (
		clk_i,
		res_n_i
	)
	----------------------------------
	BEGIN
		
		-- asynchronous reset
		IF (res_n_i = '0') THEN
			cur_state <= idle;
			hash_ready <= '0';
			cpu_busy <= '0';
			data_valid <= '0';
			rd_index <= (OTHERS => '0');
		
		-- synchronous operation
		ELSIF (rising_edge(clk_i)) THEN
			
			-- if final hash value ready
			IF (hash_ready = '1') THEN
				
				-- if hash has been acknowledged, disable broadcast
				IF (hash_ack_i = '1') THEN
					hash_ready <= '0';
					rd_index <= (OTHERS => '0');
				-- else broadcast next hash word
				ELSE
					rd_index <= rd_index + 1;
				END IF;
			end if;
			
			-- if parser is ready, set data valid
			IF (start_tr_i = '1') THEN
				data_valid <= '1';
			END IF;
			
			-- FSM
			CASE cur_state IS
			
				-- when IDLE
				--	wait for transfer start and hash acknowledged
				--		initialize current hash values to constans
				--		reset work index
				WHEN idle =>
					IF (start_tr_i = '1' and hash_ready = '0') THEN
						cur_state <= init;
						cur_hash_value(0) <= c_init_hash_val(0);
						cur_hash_value(1) <= c_init_hash_val(1);
						cur_hash_value(2) <= c_init_hash_val(2);
						cur_hash_value(3) <= c_init_hash_val(3);
						cur_hash_value(4) <= c_init_hash_val(4);
						cur_hash_value(5) <= c_init_hash_val(5);
						cur_hash_value(6) <= c_init_hash_val(6);
						cur_hash_value(7) <= c_init_hash_val(7);
						work_index <= (OTHERS => '0');
					END IF;
					
				-- when INIT
				--	wait for data_valid and hash acknowledged
				--		set work variables to intermediate hash value
				--		set busy state
				WHEN init =>
					IF (data_valid = '1' and hash_ready = '0') THEN
						data_valid <= '0';
						work_var(0) <= cur_hash_value(0);
						work_var(1) <= cur_hash_value(1);
						work_var(2) <= cur_hash_value(2);
						work_var(3) <= cur_hash_value(3);
						work_var(4) <= cur_hash_value(4);
						work_var(5) <= cur_hash_value(5);
						work_var(6) <= cur_hash_value(6);
						work_var(7) <= cur_hash_value(7);
						cpu_busy <= '1';
						work_index <= work_index + 1;
						cur_state <= compute_hash;
					END IF;
				
				-- when COMPUTE HASH
				--	calculate iterative algorithm values for 64 cycles
				WHEN compute_hash =>

					-- H = G
					-- G = F
					-- F = E
					work_var(7) <=  work_var(6);
					work_var(6) <=  work_var(5);
					work_var(5) <=  work_var(4);
					
					-- if work index < 16 use input data
					IF ((work_index-1) <= x"F") THEN
						-- load message FIFO
						prev_wt(to_integer(work_index(3 DOWNTO 0)-1)) <= unsigned(di_i);
						
						-- E = D + T1
						work_var(4) <=  work_var(3) + work_var(7) + sum1(work_var(4)) + ch_x_y_z(work_var(4),work_var(5),work_var(6)) + unsigned(c_work_const_val(to_integer(work_index - 1))) + unsigned(di_i);
						-- A = T1 + T2
						work_var(0) <=  work_var(7) + sum1(work_var(4)) + ch_x_y_z(work_var(4),work_var(5),work_var(6)) + unsigned(c_work_const_val(to_integer(work_index - 1))) + sum0(work_var(0)) + maj_x_y_z(work_var(0),work_var(1),work_var(2)) + unsigned(di_i);
					
					-- else remove busy and use extended message
					ELSE
						cpu_busy <= '0';
						
						-- load message FIFO
						prev_wt(to_integer(work_index(3 DOWNTO 0)-1)) <= hash_compute_word(prev_wt(to_integer(work_index(3 DOWNTO 0) - 3)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 8)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 16)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 17)));
						
						-- E = D + T1
						work_var(4) <= work_var(3) + (work_var(7) + sum1(work_var(4)) + ch_x_y_z(work_var(4),work_var(5),work_var(6)) + unsigned(c_work_const_val(to_integer(work_index - 1))) + hash_compute_word(prev_wt(to_integer(work_index(3 DOWNTO 0) - 3)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 8)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 16)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 17))));
						-- A = T1 + T2
						work_var(0) <= (work_var(7) + sum1(work_var(4)) + ch_x_y_z(work_var(4),work_var(5),work_var(6)) + unsigned(c_work_const_val(to_integer(work_index - 1))) + hash_compute_word(prev_wt(to_integer(work_index(3 DOWNTO 0) - 3)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 8)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 16)),prev_wt(to_integer(work_index(3 DOWNTO 0) - 17)))) + (sum0(work_var(0)) + maj_x_y_z(work_var(0),work_var(1),work_var(2)));

					END IF;
					
					-- D = C
					-- C = B
					-- B = A
					work_var(3) <=  work_var(2);
					work_var(2) <=  work_var(1);
					work_var(1) <=  work_var(0);
					
					-- at 64th iteration save the intermediate hash
					IF ((work_index - 1) = x"3F") THEN
						cur_state <= save_hash_value;
					END IF;
					work_index <= work_index + 1;					
					
				-- when SAVE HASH VALUE
				--	calculate intermediate hash values
				--  	if there are more processing blocks -> init the next one
				--		else -> start hash broadcast and go to idle
				WHEN save_hash_value =>
					work_index <= (OTHERS => '0');
					
					cur_hash_value(0) <= work_var(0) + cur_hash_value(0);
					cur_hash_value(1) <= work_var(1) + cur_hash_value(1);
					cur_hash_value(2) <= work_var(2) + cur_hash_value(2);
					cur_hash_value(3) <= work_var(3) + cur_hash_value(3);
					cur_hash_value(4) <= work_var(4) + cur_hash_value(4);
					cur_hash_value(5) <= work_var(5) + cur_hash_value(5);
					cur_hash_value(6) <= work_var(6) + cur_hash_value(6);
					cur_hash_value(7) <= work_var(7) + cur_hash_value(7);
					
					IF (last_tr_i = '0') THEN
						cur_state <= init;
					ELSE
						hash_ready <= '1';
						cur_state <= idle;
					END IF;
				END CASE;
		END IF;
	END PROCESS;
	
	-- data output control
	hash_do_o <= std_logic_vector(cur_hash_value(to_integer(rd_index))) WHEN hash_ready = '1' ELSE
				(OTHERS => 'Z');
	
	-- input address
	rd_addr_o <= std_logic_vector(work_index(3 DOWNTO 0));
	
	-- output control signals
	hash_ready_o <= hash_ready;
	cpu_busy_o <= cpu_busy;
END struct;