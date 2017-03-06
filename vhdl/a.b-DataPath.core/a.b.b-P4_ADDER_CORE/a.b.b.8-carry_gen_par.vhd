library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use WORK.GLOBALS.all;

entity carry_gen_par is
	generic (Num: integer:= NumBit32; --numero di bit degli addendi in ingresso (A,B) potenza di due
		 LEVELS: INTEGER:= levels_gen	--numero di livelli del carry generator, introdotto perchè non si può sintetizzare il logaritmo.
			);
	port( 
		A, B : in std_logic_vector(Num-1 downto 0);
		c_0 : in std_logic;
		carry_out : out std_logic_vector((Num/4) downto 0)
	);
end carry_gen_par;

architecture Behavioral of carry_gen_par is

component PG_network is
	generic (Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B) potenza di due
			);
	port(
			a, b : in std_logic_vector(Num-1 downto 0); -- 32 bits
			g : out std_logic_vector(Num-1 downto 0);
			p : out std_logic_vector(Num-1 downto 0)
			);
end component;

component G_block is
	port(
			I0 : in std_logic;	-- I0 is Gi:k
			I1 : in std_logic;	-- I1 is Pi:k
			I2 : in std_logic;	-- I2 is Gk-1:j 
			O : out std_logic		-- O is Gi:j
		);
end component;

component P_block is
	port(
			I0 : in std_logic;	-- I0 is Gi:k 
			I1 : in std_logic;	-- I1 is Pi:k
			I2 : in std_logic;	-- I2 is Gk-1:j 
			I3 : in std_logic;	-- I3 is Pk-1:j
			O1 : out std_logic;	-- O1 is Gi:j 	
			O2 : out std_logic	-- O2 is Pi:j
		);
end component;

--constant LEVELS : natural := natural(log2(real(Num))); --calcolo il numero dei livelli in funzione del numero dei bit dei segnali A, B in ingresso 
type SignalVector_PG_net is array (0 to 1) of std_logic_vector(Num-1 downto 0); --matrice che contiene i risultati in uscita dal PG_network
type SignalVector_0 is array (0 to 1) of std_logic_vector((Num/2)-1 downto 0); --matrice che contienei risultati prodotti dalla prima riga di blocchi PG e G
type SignalMatrix is array (0 to LEVELS-2) of std_logic_vector((Num/4)-1 downto 0); --matrice che contiene tutti i risultati delle righe successive

signal out_PG : SignalVector_PG_net;
signal out_level_0 : SignalVector_0;
signal matrix_P : SignalMatrix := (others => (others =>'0'));
signal matrix_G : SignalMatrix := (others => (others =>'0'));

begin

	--se il numero dei bit dei segnali in ingresso � > 4, si propagano i risulatati salvati nella i-esima riga della matrice alla i-esima+1 riga successiva
	--soltanto se nella j-esima colonna non � presente alcun blocco PG o G. in questo modo ogni blocco prender� i segnali in ingresso dalla matrice
	--con riga precedente e colonna pari alla propria
	
	no_4_bit: if Num > 4 generate
	
		loop_row: for row in 0 to (LEVELS-4) generate -- 0 a 1
		
			loop_col: for col in 0 to ((Num/8)/(2**row))-1 generate -- 0 a 4/(2**row) -1
			
				matrix_G(row+1)((2**(row+1))*col) <= matrix_G(row)((2**(row+1))*col);
				matrix_P(row+1)((2**(row+1))*col) <= matrix_P(row)((2**(row+1))*col);
				
				row_not_0: if row /= 0 generate
				
					other_col: for I in 1 to (2**row)-1 generate
					
						matrix_G(row+1)(((2**(row+1))*col)+I) <= matrix_G(row)(((2**(row+1))*col)+I);
						matrix_P(row+1)(((2**(row+1))*col)+I) <= matrix_P(row)(((2**(row+1))*col)+I);
						
					end generate other_col;
				end generate row_not_0;
			end generate loop_col;
		end generate loop_row;
		
		--assegnazione dei valori contenuti nella matrice al segnale in uscita
		carry_out((Num/8) downto 0) <= matrix_G(LEVELS-3)((Num/8)-1 downto 0) & c_0;
		carry_out((Num/4) downto (Num/8)+1) <= matrix_G(LEVELS-2)((Num/4)-1 downto (Num/8));
		
		
		--generazione dei blocchi PG e G delle righe successive alla prime due righe.
		--� stato creato un algortimo che consiste nel creare i blocchi in base al numero richiesto in ciascuna riga
		-- e in base alla loro ripetizione (stage). il numero di stage � inversamente proporzionale al numero di riga,
		--cos� come la quantit� di blocchi PG o G, mentre il numero totale di blocchi non cambia.
	
		condition: if LEVELS > 2 generate
			matrix: for row in 0 to LEVELS-3 generate
			
		--generazione blocchi G-------------------------------------------------------------------------------
			
				G_Generate: for num_G in 0 to (2**row)-1 generate
				
					G_BL_row_num_G: g_block PORT MAP( matrix_G(row)(num_G+(2**row)), matrix_P(row)(num_G+(2**row)), 
																		matrix_G(row)((2**row)-1), matrix_G(row+1)(num_G+(2**row)) );
					end generate G_Generate;
		------------------------------------------------------------------------------

		--generazione blocchi P-------------------------------------------------------------------------------
				
				G_Propagate: for I in 0 to (Num/(2**(row+3)))-2 generate	--I numero di stage
					
					for_J: for J in 0 to (2**row)-1 generate	--numero del blocco dello stage corrente
						P_BL_row_col: p_block PORT MAP( 	matrix_G(row)	((2**(row+1)+(2**row)+((2**(row+1))*I))+J), 
																	matrix_P(row)	((2**(row+1)+(2**row)+((2**(row+1))*I))+J),
																	matrix_G(row)	((2**(row+1)+(2**row)+((2**(row+1))*I))-1),
																	matrix_P(row)	((2**(row+1)+(2**row)+((2**(row+1))*I))-1),
																	matrix_G(row+1)((2**(row+1)+(2**row)+((2**(row+1))*I))+J),
																	matrix_P(row+1)((2**(row+1)+(2**row)+((2**(row+1))*I))+J) );
					end generate for_J;
				end generate G_Propagate;
		------------------------------------------------------------------------------	
			end generate matrix;
		end generate condition;
		
	end generate no_4_bit;
	
	
	--se il numero di bit dei segnali A e B � pari a 4, si genera solo una parte dello sparse tree
	yes_4_bit: if Num = 4 generate
		carry_out <= matrix_G(0)(0) & c_0;
	end generate yes_4_bit;
	----------------------------------------------------------------------------------
	
	PG_net : PG_network PORT MAP(A, B, out_PG(0), out_PG(1));
	
	
	--generazione della prima riga contenente blocchi PG e G pari alla met� NumBit32
	row_PG: for col in 0 to (Num/2)-1 generate
				col0: if col = 0 generate
					G_BL_PG_0: g_block PORT MAP(out_PG(0)(1), out_PG(1)(1), out_PG(0)(0), out_level_0(0)(0));
				end generate col0;
				other_cols: if col /= 0 generate
					P_BL_PG_col: p_block PORT MAP( out_PG(0)(2*col+1), out_PG(1)(2*col+1), 
												out_PG(0)(2*col), out_PG(1)(2*col), out_level_0(0)(col), out_level_0(1)(col) );
				end generate other_cols;
	end generate row_PG;
	
	--generazione della prima riga contenente blocchi PG e G pari ad un quarto di NumBit32
	row_init: for col in 0 to (Num/4)-1 generate
				col0: if col = 0 generate
					G_BL_init_0: g_block PORT MAP(out_level_0(0)(1), out_level_0(1)(1), out_level_0(0)(0), matrix_G(0)(0));
				end generate col0;
				other_cols: if col /= 0 generate
					P_BL_init_col: p_block PORT MAP( out_level_0(0)(2*col+1), out_level_0(1)(2*col+1), 
												out_level_0(0)(2*col), out_level_0(1)(2*col), matrix_G(0)(col), matrix_P(0)(col) );
				end generate other_cols;
	end generate row_init;

	
end Behavioral;