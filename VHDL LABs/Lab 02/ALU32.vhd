library ieee;
use ieee.std_logic_1164.all;

ENTITY ALU32 IS
 PORT( A, B: in std_logic_vector (31 downto 0);
       ALUOp: in std_logic_vector (3 downto 0);
       RESULT: out std_logic_vector (31 downto 0);
       Z, V, C: out std_logic );
END ALU32;

Architecture Structural of ALU32 is 
  
  --signals
  signal gnd : STD_LOGIC := '0';
  signal MSB_set : STD_LOGIC;
  signal carry_sig : STD_LOGIC_VECTOR(31 downto 0);
  signal result_sig : STD_LOGIC_VECTOR(31 downto 0);
  
  --components
  component MSB_slice IS
    PORT(A, B, Less, Ainvert, carryIn :IN std_logic;
         Op  :IN std_logic_vector(2 downto 0);
         result,carryout, Set, Overflow: Out std_logic);
  END component;
  
  component bit_slice IS
    PORT(A, B, Less, Ainvert, carryIn :IN std_logic;
         Op  :IN std_logic_vector(2 downto 0);
         result,carryout: Out std_logic);
  END component;
  
  begin
    
    -- port mapping for 0th ALU (least significant)
    alu0: bit_slice port map (A => A(0), B => B(0), Less => MSB_Set, Ainvert => ALUOp(3), carryIn => ALUOp(2), Op =>ALUOp(2 downto 0), result => result_sig(0), carryout => carry_sig(0));
    RESULT(0) <= result_sig(0); 
    -- port mapping for 1 to 30th ALUs
    General_ALU:
    for i in 1 to 30 generate
      alui: bit_slice port map (A => A(i), B => B(i), Less => gnd, Ainvert => ALUOp(3), carryIn => carry_sig(i-1), Op =>ALUOp(2 downto 0), result => result_sig(i), carryout => carry_sig(i));
      RESULT(i) <= result_sig(i);
    end generate General_ALU;
    
    -- port mapping for 31st ALU (Most significant)
    alu31: MSB_slice port map (A => A(31), B => B(31), Less => gnd, Ainvert => ALUOp(3), carryIn => carry_sig(30), Op =>ALUOp(2 downto 0), result => result_sig(31), carryout => C, Set => MSB_Set, Overflow => V);
    RESULT(31) <= result_sig(31);
    -- Zero Flag
    Z <= NOT(result_sig(0) OR result_sig(1)OR result_sig(2) OR result_sig(3) OR result_sig(4) OR result_sig(5) OR result_sig(6) OR result_sig(7) OR result_sig(8) OR result_sig(9) OR result_sig(10) OR result_sig(11) OR result_sig(12) OR result_sig(13) OR result_sig(14) OR result_sig(15) OR result_sig(16) OR result_sig(17) OR result_sig(18) OR result_sig(19) OR result_sig(20) OR result_sig(21)OR result_sig(22) OR result_sig(23) OR result_sig(24) OR result_sig(25) OR result_sig(26) OR result_sig(27) OR result_sig(28) OR result_sig(29)OR result_sig(30) OR result_sig(31));
    
end Structural;