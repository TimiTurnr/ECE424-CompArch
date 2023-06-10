library ieee;
use ieee.std_logic_1164.all;

Entity fulladd is 
port (A, B, Cin:IN std_logic;
      Sum,Cout: Out std_logic);
End fulladd;

Architecture Add1 of fulladd is
Begin
  Sum <= A xor B xor Cin;
  Cout <= (Cin and (A xor B)) or (A and B);
End Add1; 
