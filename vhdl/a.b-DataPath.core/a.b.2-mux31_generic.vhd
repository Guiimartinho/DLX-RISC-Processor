library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity MUX_31 is 
	generic (N : integer := 32);
	Port (	A:	In	std_logic_vector(n-1 downto 0); 
		B:	In	std_logic_vector(n-1 downto 0);
		C:	In	std_logic_vector(n-1 downto 0);
		Sel:	In	std_logic_vector(1 downto 0);
		Y:	Out	std_logic_vector(n-1 downto 0));
end MUX_31 ;

architecture BEH of MUX_31  is
	SIGNAL UNDEF: STD_LOGIC_VECTOR (N-1 DOWNTO 0) := (OTHERS => 'X');
	
begin
	
	Y <= A when Sel = "00" else 
	
	     B when Sel = "10" else
		 
	     C when Sel = "01" else
		 
	     UNDEF;

end BEH;