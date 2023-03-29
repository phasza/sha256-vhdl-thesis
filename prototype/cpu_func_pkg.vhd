----------------------------------------------------------------------------------
-- File name:		cpu_func_pkg.vhd
-- Create Date:    	04/14/2016 
-- Module Name:    	parser_unit
-- Project Name:   	hp_sha256
-- Description: 	Utility package of SHA256 mathematical functions
--
----------------------------------------------------------------------------------
-- History: 
-- Date			| Change
-- 04.Apr.2016  | Initial
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE cpu_func_pkg IS

	FUNCTION sigma0 (in_word: unsigned) RETURN unsigned;
	FUNCTION sigma1 (in_word: unsigned) RETURN unsigned;
	FUNCTION sum0 (in_word: unsigned) RETURN unsigned;
	FUNCTION sum1 (in_word: unsigned) RETURN unsigned;
	FUNCTION ch_x_y_z (x,y,z: unsigned) RETURN unsigned;
	FUNCTION maj_x_y_z (x,y,z: unsigned) RETURN unsigned;
	FUNCTION hash_compute_word (w,x,y,z: unsigned) RETURN unsigned;
	FUNCTION modulo32_reduction (x: unsigned) RETURN unsigned;
END;

PACKAGE BODY cpu_func_pkg IS

	FUNCTION sigma0 (in_word: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(in_word'length-1 DOWNTO 0);
		
	BEGIN
		a := in_word ROR 7;
		b := in_word ROR 18;
		c := in_word SRL 3;
	
		result := a XOR b XOR c;
		
		return result;
	END FUNCTION;
	
	FUNCTION sigma1 (in_word: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(in_word'length-1 DOWNTO 0);
		
	BEGIN
		a := in_word ROR 17;
		b := in_word ROR 19;
		c := in_word SRL 10;
		
		result := a XOR b XOR c;
		
		return result;
	END FUNCTION;
	
	FUNCTION sum0 (in_word: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(in_word'length-1 DOWNTO 0);
		
	BEGIN
		a := in_word ROR 2;
		b := in_word ROR 13;
		c := in_word ROR 22;
	
		result := a XOR b XOR c;
		
		return result;
	END FUNCTION;
	
	FUNCTION sum1 (in_word: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(in_word'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(in_word'length-1 DOWNTO 0);
		
	BEGIN
		a := in_word ROR 6;
		b := in_word ROR 11;
		c := in_word ROR 25;
		
		result := a XOR b XOR c;
		
		return result;
	END FUNCTION;
	
	FUNCTION ch_x_y_z (x,y,z: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(x'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(x'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(x'length-1 DOWNTO 0);
		
	BEGIN
		a := x AND y;
		b := (NOT x) AND z;
		
		result := a XOR b;
		
		return result;
	END FUNCTION;
	
	FUNCTION maj_x_y_z (x,y,z: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(x'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(x'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(x'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(x'length-1 DOWNTO 0);
		
	BEGIN
		a := x AND y;
		b := x AND z;
		c := y AND z;
		
		result := a XOR b XOR c;
		
		return result;
	END FUNCTION;
	
	FUNCTION hash_compute_word (w,x,y,z: unsigned) RETURN unsigned IS
		VARIABLE a		:		unsigned(w'length-1 DOWNTO 0);
		VARIABLE b		:		unsigned(w'length-1 DOWNTO 0);
		VARIABLE c		:		unsigned(w'length-1 DOWNTO 0);
		VARIABLE d		:		unsigned(w'length-1 DOWNTO 0);
		VARIABLE result :		unsigned(w'length-1 DOWNTO 0);
		
	BEGIN
		a := sigma1(w);
		b := x;
		c := sigma0(y);
		d := z;
		result := (a + b + c + d);
		return result;
	END FUNCTION;
	
	FUNCTION modulo32_reduction (x: unsigned) RETURN unsigned IS
		VARIABLE result :		unsigned(31 DOWNTO 0);
	BEGIN
		result := x(31 DOWNTO 0);
		return result;
	END FUNCTION;
	
END PACKAGE BODY;
		