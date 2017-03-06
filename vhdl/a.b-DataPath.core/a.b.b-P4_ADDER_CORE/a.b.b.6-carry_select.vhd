library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.GLOBALS.all;

entity carry_select is 
	generic (
		 N: integer:= NumBitRCA);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;	--the selector
				S:	Out	std_logic_vector(N-1 downto 0)	--the sum
		);
end carry_select; 

architecture STRUCTURAL of carry_select is

	signal S0: std_logic_vector(N-1 downto 0);	
	signal S1: std_logic_vector(N-1 downto 0);

  component RCA is 
	generic (N: integer:= NumBitRCA);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				Ci:	In	std_logic;
				S:	Out	std_logic_vector(N-1 downto 0);
				Co:	Out	std_logic
		);
  end component;

  component MUX21_GENERIC is
	generic (N: integer:= NumBitRCA);					--numbit is a constant value definied into the file constants.vhd);
	Port (	A:	In	std_logic_vector(N-1 downto 0) ;	--entity declaration of a mux2x1
				B:	In	std_logic_vector(N-1 downto 0);
				SEL:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0)
		);
  end component; 

begin

  RCA_0 : RCA 
  generic map (N) 
  Port Map (A, B, '0', S0); 

  RCA_1 : RCA 
  generic map (N) 
  Port Map (A, B, '1', S1); 

  MUX21_GENERIC_0 : MUX21_GENERIC 
  generic map (N) 
  Port Map (S0, S1, Ci, S); 

end STRUCTURAL;

