library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.GLOBALS.all;

entity PG_network is
	generic (Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B) potenza di due
			);
	port(
		a, b : in std_logic_vector(Num-1 downto 0); -- Num bits
		g : out std_logic_vector(Num-1 downto 0);
		p : out std_logic_vector(Num-1 downto 0)
		);
end PG_network;

architecture Behavioral of PG_network is

begin

	process(a, b)
	begin
	for I in 0 to Num-1
	loop
		p(I) <= a(I) xor b(I);
		g(I) <= a(I) and b(I);
	end loop;
	end process;

end Behavioral;

