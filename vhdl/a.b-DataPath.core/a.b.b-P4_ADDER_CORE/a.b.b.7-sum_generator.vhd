library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.GLOBALS.all;

entity sum_generator is 
	generic (N: integer:= NumBitRCA;  --  R carry adder num bit
				Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B)
			);
		Port (	A:	In	std_logic_vector(Num-1 downto 0);
					B:	In	std_logic_vector(Num-1 downto 0);
					Ci:	In	std_logic_vector( ((Num/N)-1) downto 0);
					S:	Out	std_logic_vector(Num-1 downto 0)
			);
end sum_generator; 

architecture STRUCTURAL of sum_generator is

  component carry_select is 
	generic (N: integer:= NumBitRCA);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;	-- the selector
				S:	Out	std_logic_vector(N-1 downto 0)
			);
  end component; 


begin


 CARRY_SELECT_GEN: for I in 0 to ((Num/N)-1) generate
    carry_select_i : carry_select 
	  Port Map (A((N*(I+1))-1 downto N*I), B((N*(I+1))-1 downto N*I), Ci(I), S((N*(I+1))-1 downto N*I)); 
  end generate;

end STRUCTURAL;

