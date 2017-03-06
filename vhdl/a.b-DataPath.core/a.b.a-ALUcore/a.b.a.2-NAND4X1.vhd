library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity NAND4x1 is
	
	port (
			A : in std_logic;
			B : in std_logic;
			C : in std_logic;
			D : in std_logic;
			Y : out std_logic
	);
end entity NAND4X1;

architecture BEH of NAND4x1 is
begin

Y <=	NOT(A AND B AND C AND D);

end BEH;