----------------------------------------------------------------------------------
-- File name:		sha256_top.vhd
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cpu_func_pkg.ALL;
 
ENTITY cpu_test_direct IS
END cpu_test_direct;
 
ARCHITECTURE behavior OF cpu_test_direct IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT proc_unit
    PORT(
         clk_i : IN  std_logic;
         res_n_i : IN  std_logic;
         data_valid_i : IN  std_logic;
         buffer_free_i : IN  std_logic;
         last_tr_i : IN  std_logic;
         start_tr_i : IN  std_logic;
         cs_o : OUT  std_logic;
         hash_ready_o : OUT  std_logic;
         cpu_busy_o : OUT  std_logic;
         di_i : IN  std_logic_vector(31 downto 0);
         do_o : OUT  std_logic_vector(31 downto 0);
			rd_en_o : OUT  std_logic;
			wr_en_o : OUT  std_logic;
         rd_addr_o : OUT  std_logic_vector(3 downto 0);
         wr_addr_o : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    
	TYPE in_hash_value_type IS ARRAY (15 DOWNTO 0) OF unsigned (31 DOWNTO 0);
	TYPE out_hash_value_type IS ARRAY (7 DOWNTO 0) OF unsigned (31 DOWNTO 0);
   --Inputs
	
   signal clk_i : std_logic := '0';
	
	signal unused : std_logic := '0';
   signal res_n_i : std_logic := '0';
   signal data_valid_i : std_logic := '0';
   signal buffer_free_i : std_logic := '0';
   signal last_tr_i : std_logic := '0';
   signal start_tr_i : std_logic := '0';
   signal di_i : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal cs_o : std_logic := '0';
   signal hash_ready_o : std_logic := '0';
   signal cpu_busy_o : std_logic := '0';
	signal rd_en_o : std_logic := '0';
	signal wr_en_o : std_logic := '0';
   signal do_o : std_logic_vector(31 downto 0) := (others => '0');
   signal rd_addr_o : std_logic_vector(3 downto 0) := (others => '0');
   signal wr_addr_o : std_logic_vector(3 downto 0)	:= (others => '0');
	
	signal temp_data : unsigned(31 downto 0)	:= (others => '0');
	signal temp_sigma1 : unsigned(31 downto 0)	:= (others => '0');
	signal temp_sigma0 : unsigned(31 downto 0)	:= (others => '0');
	signal temp_data_ref : unsigned(31 downto 0)	:= (others => '0');
	
	signal output_data 		: out_hash_value_type;
	signal expected_output 	: out_hash_value_type :=
		(
			x"e9a92a2e",
			x"d0d53732",
			x"ac13b031",
			x"a27b0718",
			x"14231c86",
			x"33c9f418",
			x"44ccba88",
			x"4d482b16"
		);
	signal input_data2 	: in_hash_value_type :=
		(
			x"00000038",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"00000000",
			x"45464780",
			x"41424344"
		);

	signal input_data 	: in_hash_value_type :=
		(
			x"000001B8",
			x"00000000",
			x"41424380",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344"
		);
		
	signal input_data1 	: in_hash_value_type :=
		(
			x"000001B8",
			x"00000000",
			x"45464780",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344",
			x"41424344"
		);

	signal test : unsigned(31 downto 0)	:= (others => '1');

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: proc_unit PORT MAP (
          clk_i => clk_i,
          res_n_i => res_n_i,
          data_valid_i => data_valid_i,
          buffer_free_i => buffer_free_i,
          last_tr_i => last_tr_i,
          start_tr_i => start_tr_i,
          cs_o => cs_o,
          hash_ready_o => hash_ready_o,
          cpu_busy_o => cpu_busy_o,
          di_i => di_i,
          do_o => do_o,
			 rd_en_o => rd_en_o,
			 wr_en_o => wr_en_o,
          rd_addr_o => rd_addr_o,
          wr_addr_o => wr_addr_o
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      res_n_i <= '0';
		wait for clk_i_period*5;
		res_n_i <= '1';
      wait for clk_i_period*10;

      -- insert stimulus here 
		start_tr_i <= '1';
		last_tr_i <= '1';
		data_valid_i <= '1';
		buffer_free_i <= '1';
		
		wait for clk_i_period*2;
		start_tr_i <= '0';
		last_tr_i <= '1';
		
		wait for clk_i_period * 1000;
		wait;
	end process;
	
	-- Stimulus process
	rd_proc: process (clk_i)
	begin
		if rising_edge(clk_i) then
			if rd_en_o = '1' then
				di_i <= std_logic_vector(input_data(to_integer(unsigned(rd_addr_o))));
			end if;
		end if;
	end process;
	
	-- Stimulus process
	wr_proc: process (clk_i)
	begin
		if rising_edge(clk_i) then
			if wr_en_o = '1' then
				output_data(to_integer(unsigned(wr_addr_o))) <= unsigned(do_o);
			end if;
		end if;
	end process;
	
END;
