library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity NAND3x1 is
	
	port (
			S : in std_logic;
			A : in std_logic;
			B : in std_logic;
			Y : out std_logic
	);
end entity NAND3X1;

architecture BEH of NAND3x1 is
begin

Y <=	NOT(A AND B AND S);

end BEH;