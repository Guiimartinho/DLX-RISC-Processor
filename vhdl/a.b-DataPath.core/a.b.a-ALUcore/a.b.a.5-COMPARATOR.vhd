library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;

entity COMPARATOR is
GENERIC (N : INTEGER := 32);
	PORT (
			A: IN std_logic_VECTOR(N-1 DOWNTO 0);
			B: IN std_logic_VECTOR(N-1 DOWNTO 0);
			greater_S: OUT std_logic_VECTOR(N-1 DOWNTO 0);
			equal_S: OUT std_logic_VECTOR(N-1 DOWNTO 0);
			lower_S: OUT std_logic_VECTOR(N-1 DOWNTO 0);
			greater_U: OUT std_logic_VECTOR(N-1 DOWNTO 0);
			equal_U: OUT std_logic_VECTOR(N-1 DOWNTO 0);
			lower_U: OUT std_logic_VECTOR(N-1 DOWNTO 0)
 );
end COMPARATOR;

architecture Behavioral of COMPARATOR is

begin
	
	greater_S <= ("00000000000000000000000000000001") WHEN signed(A) > signed(B) 
		ELSE (OTHERS => '0'); 
	equal_S <= ("00000000000000000000000000000001") WHEN signed(A) = signed(B) 
		ELSE (OTHERS => '0'); 
	lower_S <= ("00000000000000000000000000000001") WHEN signed(A) < signed(B)
		ELSE (OTHERS => '0'); 

	greater_U <= ("00000000000000000000000000000001") WHEN unsigned(A) > unsigned(B)
		ELSE (OTHERS => '0'); 
	equal_U <= ("00000000000000000000000000000001") WHEN unsigned(A) = unsigned(B)
		ELSE (OTHERS => '0'); 
	lower_U <= ("00000000000000000000000000000001") WHEN unsigned(A) < unsigned(B)
		ELSE (OTHERS => '0'); 

end Behavioral;

