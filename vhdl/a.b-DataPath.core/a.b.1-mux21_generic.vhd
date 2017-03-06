library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_GENERIC is

	Generic (N: integer:= 32					--numbit and tp_mux is a constant value definied into the file constants.vhd
);
	Port (	A:	In	std_logic_vector(N-1 downto 0) ;	--entity declaration of a mux2x1
				B:	In	std_logic_vector(N-1 downto 0);
				SEL:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0));

end entity;

architecture BEHAVIORAL of MUX21_GENERIC is

begin 
		
		Y <= A when SEL='0' else B;		--behavioral description


end BEHAVIORAL;


