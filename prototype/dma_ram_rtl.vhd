----------------------------------------------------------------------------------
-- File name:		dma_ram_rtl.vhd
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

ARCHITECTURE rtl OF dma_ram IS
	
	TYPE mem_type is array (integer range <>) of std_logic_vector (g_data_width-1 downto 0);
	
	SIGNAL ram 		: 					mem_type(0 to g_ram_size-1);
	
begin
	
	p_write_data : process (clk_i) is
	begin
		if rising_edge(clk_i) then
			if (wr_en_i='1') then
				ram(to_integer(unsigned(wr_addr_i))) <= di_i;
			end if;
		end if;
	end process p_write_data;

	p_read_data : process (clk_i) is
	begin
		if rising_edge(clk_i) then
			if (rd_en_i='1') then
				do_o <= ram(to_integer(unsigned(rd_addr_i)));
			end if;
		end if;
	end process p_read_data;
	

end rtl;