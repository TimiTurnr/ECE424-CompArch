-- 
-- 
--

library ieee;
use ieee.std_logic_1164.all;


ENTITY bit_slice IS
    PORT(A, B, Less, Ainvert, carryIn :IN std_logic;
         Op                                :IN std_logic_vector(2 downto 0);
         result,carryout: Out std_logic);
END bit_slice;

architecture alu of bit_slice is
  
 signal  a_sig, b_sig, alu_sig: std_logic;
 
component fulladd is 
port (A, B, Cin:IN std_logic;
      Sum,Cout: Out std_logic);
End component;



BEGIN
    
    a_sig <= A when (Ainvert = '0') else
              not A;
    b_sig <= B when (Op(2) = '0' ) else
              not B;
              
    
  fulladd1: fulladd port map(A=>a_sig, B=>b_sig, Cin=>carryIn, Cout=>carryout,Sum=>alu_sig);
    
    Result <= a_sig and b_sig when (Op(1) = '0' and Op(0) = '0') else
              a_sig or  b_sig when (Op(1) = '0' and Op(0) = '1') else
              alu_sig         when (Op(1) = '1' and Op(0) = '0') else
              less  	         when (Op(1) = '1' and Op(0) = '1') else
              '0';
END alu;
