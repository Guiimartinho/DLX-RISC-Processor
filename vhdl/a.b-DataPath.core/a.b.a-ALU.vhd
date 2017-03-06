library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.GLOBALS.all;

entity ALU is
  generic (N : integer := NumBit32);
  port 	 ( FUNC: IN std_logic_vector (Alu_op_bit-1 downto 0);
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end ALU;

architecture BEHAVIOR of ALU is

--**************************************COMPONENT****************************************************************

	component P4_adder is
		generic (Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B) deve essere una potenza di due >= 4
				);
		port( A, B : in std_logic_vector(Num-1 downto 0);
				c_in : in std_logic; 
				c_out : out std_logic;
				SUM : out std_logic_vector(Num-1 downto 0)
			);
	end component;
	
	
	component booth_multiplier is
		generic(
			Na: integer:= NumBit32;										--bit del operando a
			Nb: integer:= NumBit32										--bit del operando b		DEVE ESSERE UN NUMERO PARI PER COME è DEFINITO NEL ALGORITMO
		);
		port(
			a: in std_logic_vector(Na-1 downto 0);						--operando a
			b: in std_logic_vector(Nb-1 downto 0);						--operando b
			result: out std_logic_vector(Na + Nb-1 downto 0)				--risultato del operazione: numero di bit pari al numero di bit del operando a + numero di bit del operando b
		);
	end component;
	
	
	component COMPARATOR is
	
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
	end component;
	
	
	component SHIFTER is
	
		generic(N: integer := 32);
		port(	A: in std_logic_vector(N-1 downto 0);
			B: in std_logic_vector(4 downto 0);
			LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
			LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
			SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
			OUTPUT: out std_logic_vector(N-1 downto 0)
		);
	end component;
	
	
	component LOGICALS is
	
		generic (N : integer := 32);
		port(
				S : in std_logic_vector(3 downto 0);
				A : in std_logic_vector(N-1 downto 0);
				B : in std_logic_vector(N-1 downto 0);
				Y : out std_logic_vector(N-1 downto 0)
			);
	end component;
	
--***********************************END COMPONENT****************************************************************


--***********************************INTERNAL SIGNALS*************************************************************

--ADDER
	signal out_adder	: std_logic_vector(N-1 downto 0);
	signal carry_in	: std_logic;	-- 1 for SUB, 0 otherwise
	signal carry_out	: std_logic;	--useless
	signal data2_bis	: std_logic_vector(N-1 downto 0);
	
--MULTIPLIER	
	signal out_mul : std_logic_vector(N-1 downto 0);
	
--LOGICALS
--**************************************************************
	--AND: sel0 = 0, sel1 = 0, sel2 = 0, sel3 = 1;	*
	--NAND: sel0 = 1, sel1 = 1, sel2 = 1, sel3 = 0;	*
	--OR: sel0 = 0, sel1 = 1, sel2 = 1, sel3 = 1;	*
	--NOR: sel0 = 1, sel1 = 0, sel2 = 0, sel3 = 0;	*
	--XOR: sel0 = 0, sel1 = 1, sel2 = 1, sel3 = 0;	*
	--NXOR: sel0 = 1, sel1 = 0, sel2 = 0, sel3 = 1;	*
--**************************************************************
	signal sel : std_logic_vector(3 downto 0);
	signal out_log : std_logic_vector(N-1 downto 0);

--SHIFTER
	signal logic_arith 	: std_logic;		-- 1 = logic, 0 = arith
	signal left_right 	: std_logic;		-- 1 = left, 0 = right
	signal shift_rot 		: std_logic;		-- 1 = shift, 0 = rotate
	signal out_shifter	: std_logic_vector(N-1 downto 0);

--COMPARATOR
	signal great_S, equ_S, low_S, great_U, equ_U, low_U : std_logic_vector(N-1 downto 0);
--***********************************END INTERNAL SIGNALS*********************************************************
begin
	
	
	P4_A: P4_adder
		generic map (Num => NumBit32)
			PORT MAP (DATA1,  data2_bis, carry_in, carry_out, out_adder);
		
	B_M: booth_multiplier
		generic map (Na => BIT_MUL, Nb => BIT_MUL)
			PORT MAP (DATA1(BIT_MUL-1 downto 0),  DATA2(BIT_MUL-1 downto 0), out_mul);
		
	LOG_0: LOGICALS
		generic map (N => 32)
			PORT MAP (sel, DATA1, DATA2, out_log);
			
	SHIF_0: SHIFTER
		generic map (N => 32)
			PORT MAP (DATA1, DATA2(4 downto 0), logic_arith, left_right, shift_rot, out_shifter);
	
	COMP_0: COMPARATOR
		generic map (N => 32)
			PORT MAP (DATA1, DATA2, great_S, equ_S, low_S, great_U, equ_U, low_U);

--ADDER config
	carry_in 	<= '1' 			WHEN FUNC = F_SUB ELSE '0';
	data2_bis	<= NOT(DATA2)	WHEN FUNC = F_SUB ELSE DATA2;
	
--LOGICALS config

	sel <= 	"1000" WHEN FUNC = F_AND	ELSE
				"1110" WHEN FUNC = F_OR		ELSE
				"0110" WHEN FUNC = F_XOR	ELSE
				"ZZZZ";

--SHIFTER config
		
	LOGIC_ARITH <= ARITH WHEN FUNC = F_SRA ELSE LOGIC;
	LEFT_RIGHT <= LEFT WHEN FUNC = F_SLL ELSE RIGHT;
	SHIFT_ROT <= SHIFT; --no rotate instruction in the instruction set
	
	
	OUTALU <= 	out_adder			WHEN FUNC = F_ADD		ELSE
					out_adder			WHEN FUNC = F_SUB		ELSE
					out_adder			WHEN FUNC = F_JAL		ELSE
					out_adder			WHEN FUNC = F_JALR		ELSE
					out_mul				WHEN FUNC = F_MULT		ELSE
					out_log				WHEN FUNC = F_AND		ELSE
					out_log				WHEN FUNC = F_OR		ELSE
					out_log				WHEN FUNC = F_XOR		ELSE
					out_shifter			WHEN FUNC = F_SLL		ELSE
					out_shifter			WHEN FUNC = F_SRL		ELSE
					out_shifter			WHEN FUNC = F_SRA		ELSE
					equ_S 				WHEN FUNC = F_SEQ 	ELSE
				   great_S OR low_S 	WHEN FUNC = F_SNE 	ELSE -- SET IF NOT EQUAL -> IF IS GREATER OR SMALLER IS NOT EQUAL
					low_S 				WHEN FUNC = F_SLT 	ELSE
					low_U 				WHEN FUNC = F_SLTU 	ELSE
					equ_S OR low_S 	WHEN FUNC = F_SLE 	ELSE
					equ_U OR low_U 	WHEN FUNC = F_SLEU 	ELSE
					great_S 				WHEN FUNC = F_SGT 	ELSE
					great_U 				WHEN FUNC = F_SGTU 	ELSE
					great_S OR equ_S 	WHEN FUNC = F_SGE 	ELSE
					great_U OR equ_U	WHEN FUNC = F_SGEU 	ELSE					
					DATA2(15 downto 0) & X"0000"	WHEN FUNC = F_LHI 	ELSE
					(OTHERS => '0');
					


end BEHAVIOR;

