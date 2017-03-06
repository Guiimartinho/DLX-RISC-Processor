library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.GLOBALS.all;

entity P4_adder is
	generic (Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B) deve essere una potenza di due >= 4
			);
	port( A, B : in std_logic_vector(Num-1 downto 0);
			c_in : in std_logic; 
			c_out : out std_logic;
			SUM : out std_logic_vector(Num-1 downto 0)
		);
end P4_adder;

architecture Behavioral of P4_adder is

component carry_gen_par is
	generic (Num: integer:= NumBit32; --numero di bit degli addendi in ingresso (A,B) potenza di due
			LEVELS: INTEGER:= levels_gen	--numero di livelli del carry generator, introdotto perchè non si può sintetizzare il logaritmo.
			);
	port( 
		A, B : in std_logic_vector(Num-1 downto 0);
		c_0 : in std_logic;
		carry_out : out std_logic_vector((Num/4) downto 0)
	);
end component;

component sum_generator is
	generic (N: integer:=NumBitRCA;  --  R carry adder num bit
				Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B)
			);
	Port 	(	A: In	std_logic_vector(Num-1 downto 0);
				B:	In	std_logic_vector(Num-1 downto 0);
				Ci: In std_logic_vector( ((Num/N)-1) downto 0);
				S:	Out std_logic_vector(Num-1 downto 0)
			);
end component;

signal carry_generated : std_logic_vector(Num/4 downto 0);

begin

	SUM_gen : sum_generator PORT MAP( A, B, carry_generated((Num/4)-1 downto 0), SUM);
	carry_gen: carry_gen_par PORT MAP( A, B, c_in, carry_generated);
	
	c_out <= carry_generated(Num/4);

end Behavioral;

