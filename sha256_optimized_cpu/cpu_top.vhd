----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:05:58 05/21/2016 
-- Design Name: 
-- Module Name:    cpu_top - Behavioral 
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

ENTITY cpu_top IS
	GENERIC (
			g_reset_level : std_logic := '0'
			);
	PORT (
			clk_i 		: IN std_logic;
			res_n_i 	: IN std_logic;
			di_i 		: IN std_logic_vector(31 DOWNTO 0);
			
			start_tr_i	: IN std_logic;
			last_tr_i	: IN std_logic;
			next_tr_o 	: OUT std_logic;
			
			hash_do_o 	: OUT std_logic_vector(255 DOWNTO 0)
			);

END cpu_top;

ARCHITECTURE Behavioral OF cpu_top IS
	
	----------------------------------
	--	Memory type
	----------------------------------
	TYPE work_const_type IS ARRAY (63 DOWNTO 0) OF std_logic_vector (31 DOWNTO 0);
	
	----------------------------------
	-- Work constants
	----------------------------------
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
	SIGNAL msg_do_y 		: std_logic_vector(31 DOWNTO 0);
	SIGNAL kt_y 			: std_logic_vector(31 DOWNTO 0);
	SIGNAL msg_mux_sel_y 	: std_logic;
	SIGNAL cpu_mux0_sel_y 	: std_logic_vector (1 DOWNTO 0);
	SIGNAL cpu_mux1_sel_y 	: std_logic;
	SIGNAL work_index 		: std_logic_vector(5 DOWNTO 0);
	SIGNAL clr_y 			: std_logic;
	SIGNAL en_vector_y 		: std_logic_vector (10 DOWNTO 0);
	SIGNAL hash_en_y 		: std_logic;
	SIGNAL next_tr_y 		: std_logic;
	signal cntr_clr_y 		: std_logic;
	
BEGIN
	----------------------------------
	p_clocked_serial : PROCESS (
		clk_i,
		start_tr_i
	)
	----------------------------------
	BEGIN
		-- asynchronous start
		--	reset register enable control signals
		--	reset multiplexer control signals
		--	reset module control signals
		IF (start_tr_i = '1') THEN
			en_vector_y(1 DOWNTO 0) <= "11";
			en_vector_y(10 DOWNTO 2) <= (OTHERS => '0');
			cpu_mux1_sel_y <= '0';
			cpu_mux0_sel_y <= "00";
			msg_mux_sel_y <= '0';
			hash_en_y <= '0';
			next_tr_y <= '0';
			next_tr_o <= '0';
			
		-- synchronous operation
		ELSIF (rising_edge(clk_i)) THEN
		
			-- Enable register L and E..H
			--	 Multiplexer state:
			--		d1 = G
			--		d0 = C
			IF (work_index = "000000") THEN
				en_vector_y(2) <= '1';
				en_vector_y(7) <= '1';
				en_vector_y(8) <= '1';
				en_vector_y(9) <= '1';
				en_vector_y(10) <= '1';
				
				cpu_mux1_sel_y <= '1';
				cpu_mux0_sel_y <= "01";
			END IF;
			
			-- Enable register A..D
			--	 Multiplexer state:
			--		d0 = B
			IF (work_index = "000001") THEN
				cpu_mux0_sel_y <= "10";
				en_vector_y(3) <= '1';
				en_vector_y(4) <= '1';
				en_vector_y(5) <= '1';
				en_vector_y(6) <= '1';
			END IF;
			
			-- Disable register E..H, M1, M2
			-- Message scheduler multiplexer state:
			--		data in
			--		drive next transfer output signal
			IF (work_index = "000000" and en_vector_y(3) = '1' ) THEN
				en_vector_y(7) <= '0';
				en_vector_y(8) <= '0';
				en_vector_y(9) <= '0';
				en_vector_y(10) <= '0';
				en_vector_y(1 DOWNTO 0) <= "00";
				msg_mux_sel_y <= '0';
				next_tr_o <= '1';
			END IF;
			
			-- Disable register A..D, L
			-- Enable hash registers
			-- remove next transfer output signal
			IF (work_index = "000001" and en_vector_y(3) = '1' ) THEN
				en_vector_y(2) <= '0';
				en_vector_y(3) <= '0';
				en_vector_y(4) <= '0';
				en_vector_y(5) <= '0';
				en_vector_y(6) <= '0';
				hash_en_y <= '1';
				next_tr_o <= '0';
			END IF;
			
			-- Disable hash registers
			-- Drive next transfer internal signal
			IF (hash_en_y = '1') THEN
				hash_en_y <= '0';
				en_vector_y(1 DOWNTO 0) <= "11";
				next_tr_y <= '1';
			-- Remove next transfer internal signal
			ELSE
				next_tr_y <= '0';
			END IF;
			
			-- Set message scheduler multiplexer state
			--	extended message
			IF (work_index > "001101") THEN
				msg_mux_sel_y <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	-- 6 bit counter clear signal
	cntr_clr_y <= start_tr_i or next_tr_y;
	
	-- 6 bit counter instantiation
	cntr : ENTITY work.bin_cntr
	GENERIC MAP (
			g_bit_num => 6
		)
	PORT MAP (
			clk_i => clk_i,
			clr_i => cntr_clr_y,
			do_o => work_index
		);

	-- CPU register clear signal
	clr_y <= start_tr_i;
	
	-- CPU constant input
	kt_y <= c_work_const_val(to_integer(unsigned(work_index)));
	
	-- Message scheduler instantiation
	msg_sched : ENTITY work.msg_sched
	PORT MAP(
			clk_i =>clk_i,
			di_i => di_i,
			do_o => msg_do_y,
			
			mux_sel_i => msg_mux_sel_y
			);
	
	-- CPU instantiation
	hash_cpu : ENTITY work.proc_unit
		PORT MAP(
	
			clk_i => clk_i,
			clr_i => clr_y,
			
			wt_i => msg_do_y,
			kt_i => kt_y,
			
			en_vecotr_i => en_vector_y,
			mux0_sel_i => cpu_mux0_sel_y,
			mux1_sel_i => cpu_mux1_sel_y,
			hash_en_i => hash_en_y,
			
			do_o => hash_do_o
			);

END Behavioral;

