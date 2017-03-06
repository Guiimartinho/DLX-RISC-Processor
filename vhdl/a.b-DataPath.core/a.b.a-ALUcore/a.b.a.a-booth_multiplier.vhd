--							DA NOTARE  
--QUESTO ESERCIZIO CI CHIEDEVA DI FARE UN MOLTIPLICATORE CON L'ALGORTIMO DI BOOTH, SENZA SPECIFICARE SE LA VERSIONE DOVEVA GESTIRE O NO LE MOLTIPLICAZIONI NEGATIVE:
--QUESTA VERSIONE è STATA FATTA SENZA GESTIRE LE MOLTIPLICAZIONI NEGATIVE MA SFRUTTANDO AL MASSIMO TUTTI GLI NA E NB BIT DEGLI INPUT CON VALORI POSITIVI COSA CHE NON SI SAREBBE POTUTA FARE CON
--LA GESTIONE DELLE MOLTIPLICAZIONI NEGATIVE, IN QUANTO CON LA RAPPRESENTAZIONE CON IL COMPLEMENTO A 2 SI POSSONO RAPPRESENTARE DA -2^(N-1) A 2^(N-1)-1 VALORI. 
--LA LOGICA PER IMPLEMENTARE QUESTA VERSIONE DI MOLTIPLICATORE è STATA QUELLA DI EFFETTUARE UNA MOLTIPLICAZIONE PER ESEMPIO A N BIT,  MA DENTRO IL MOLTIPLICATORE VIENE GESTITA A N+2 BIT(SEMPRE PARI)
--IN MODO DA POTER RAPPRESENTARE UN RANGE DI VALORI PIù GRANDE MA DANDO IN INPUTI SEMPRE N BIT (QUINDI TUTTI I NUMERI VENGONO CONSIDERATI POSITIVI).
--Nel seguente codice le modifiche sono state evidenziate dai commenti.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use WORK.GLOBALS.all;

entity booth_multiplier is
	generic(
		Na: integer:= NumBit32;										--bit del operando a
		Nb: integer:= NumBit32										--bit del operando b		DEVE ESSERE UN NUMERO PARI PER COME è DEFINITO NEL ALGORITMO
	);
	port(
		a: in std_logic_vector(Na-1 downto 0);						--operando a
		b: in std_logic_vector(Nb-1 downto 0);						--operando b
		result: out std_logic_vector(Na+Nb-1 downto 0)				--risultato del operazione: numero di bit pari al numero di bit del operando a + numero di bit del operando b
	);
end booth_multiplier;

architecture Behavioral of booth_multiplier is

	component RCA is 														--adder RCA
		generic (
			N: integer:= NumBitRCA);
		Port (	A:	In	std_logic_vector(N-1 downto 0);		
			B:	In	std_logic_vector(N-1 downto 0);
			Ci:	In	std_logic;
			S:	Out	std_logic_vector(N-1 downto 0);
			Co:	Out	std_logic);
	end component; 
	
	component mux_booth is												--mux per l'algoritmo di booth
		generic(
			Na: integer:= NumBit32;										--bit del operando a
			Nb: integer:= NumBit32										--bit del operando b
		);
		port(
			in0: in std_logic_vector((Nb+Na)-1 downto 0);			--input nella porta 0
			in1: in std_logic_vector((Nb+Na)-1 downto 0);			--input nella porta 1
			in2: in std_logic_vector((Nb+Na)-1 downto 0);			--input nella porta 2
			in3: in std_logic_vector((Nb+Na)-1 downto 0);			--input nella porta 3
			in4: in std_logic_vector((Nb+Na)-1 downto 0);			--input nella porta 4
			output: out std_logic_vector((Nb+Na)-1 downto 0);		--output 
			sel: in std_logic_vector(2 downto 0)						--selettore del mux secondo la logica del componente "mux_booth"
		);
	end component;
	
	component shift_booth is											--componente per lo shift dell'operando a per l'algoritmo di booth
		generic(
			Na: integer:= NumBit32;										--bit del operando a
			Nb: integer:= NumBit32;										--bit del operando b
			Nshift: integer:= Shift_mul								--numero di shift da compiere secondo la logica del componente "shift_booth"
		);
		port(
			a: in std_logic_vector(Na-1 downto 0);						--numero da shiftare
			y1: out std_logic_vector((Nb+Na)-1 downto 0);			--output: a shiftata di Nshift
			y2: out std_logic_vector((Nb+Na)-1 downto 0);			--output: a shiftata di Nshift e negata
			y3: out std_logic_vector((Nb+Na)-1 downto 0);			--output: a shiftata di Nshift+1
			y4: out std_logic_vector((Nb+Na)-1 downto 0)				--output: a shiftata di Nshift+1 e negata
		);
	end component;
	
	constant Nb_all_bit: integer:= Nb+2;																						--ridefinzione di Nb aumentandoli di 2 bit per aumentare di uno stadio il moltiplicatore (1 mux e 1 RCA in più), per gestire le moltiplicazioni positive di tutti gli 8 bit, eliminando la possibilità di moltiplicazioni negative 
																																		--NOTA: SE VOGLIAMO POSSIAMO TOGLIERE IL "+2" E FAR IN MODO CHE IL MOLTIPLICATORE FUNZIONI ANCHE PER MOLTIPLICAZIONI NEGATIVE, RICORDANDO CHE LA RAPPRESENTAZIONE DEI VALORI AVRà UN BIT IN MENO A CAUSA DEL COMPLEMENTO A 2.
	
	type type_mux is array (0 to((Nb_all_bit/2)-1)) of std_logic_vector((Nb_all_bit+Na)-1  downto 0);  
	signal output_mux : type_mux;																								-- segnali interni usati per l'output dei mux, la creazione di un array è utile per poterli usare iterativamente nella generazione dei "mux_booth"
	
	type type_shift is array (0 to((Nb_all_bit/2)-1)) of std_logic_vector((Nb_all_bit+Na)-1  downto 0);
	signal output_shift1, output_shift2, output_shift3, output_shift4 : type_shift;  						-- segnali interni usati per gli output dello shifter, la creazione di un array è utile per poterli usare iterativamente nella generazione dei "shift_booth"

	type type_rca is array (0 to((Nb_all_bit/2)-1)) of std_logic_vector((Nb_all_bit+Na)-1  downto 0);
	signal input_output_rca : type_rca;																						-- segnali interni usati per l'output e l'input dei RCA, la creazione di un array è utile per poterli usare iterativamente nella generazione dei "RCA"

	signal b_encoder: std_logic_vector(Nb_all_bit downto 0);															-- segnale interno usato operando b che fungerà da selettore per i mux, ricordando che deve avere un bit in più per il bit 0 b-1
	signal internal_result: std_logic_vector(((Na+Nb_all_bit)-1) downto 0); 									-- analogo motivo già sopracitato ma per il risultato della moltiplicazioni

begin

	proc_encoder: process(b)																									-- processo usato per impostare il bit b-1 
		variable b_temp: std_logic_vector(Nb_all_bit downto 0);
		begin
			b_temp:=(others=>'0');
			b_temp(Nb downto 1):=b;																								--ricordiamo b a nb bit, b_encoder a nb+2 per la gestione di tutte le moltiplicazioni positive, +1 per il bit b-1, quindi si aggiungono 2 bit 0 come MSB a b per colmare quei 2 bit in più
			b_encoder<=b_temp;
	end process;

	input_output_rca(0)<=output_mux(0);																						--l'uscita del primo MUX corrisponde ad un input del primo RCA, perchè il primo RCA ha come input due uscite dei primi 2 MUX

	GenRCA: for I in 0 to ((Nb_all_bit/2)-2) generate																	-- generazione di tutti i RCA che ha la seguente dipendenza logica con il numero di bit di b
		RCA_I : RCA 
		generic map (N   => Nb_all_bit+Na)
		Port Map (input_output_rca(I),  output_mux(I+1), '0', input_output_rca(I+1)); 
	end generate;
	
	
	internal_result<=input_output_rca((Nb_all_bit/2)-1);																--assegno l'uscita dell'ultimo RCA al segnale interno "internal_result"
	
	result<=internal_result(Na+Nb-1 downto 0); 																			--assegno all'uscita del moltiplicatore una parte di "internal_result" che è quella significativa, warning durante la sintesi causato perchè non connetto tutto "internal_result" all'output.
	
	GenShift_booth: for I in 0 to ((Nb_all_bit/2)-1) generate  														-- generazione di tutti i " shift_booth" che ha la seguente dipendenza logica con il numero di bit di b
		shift_booth_I : shift_booth
		generic map (Na => Na, Nb => Nb_all_bit, Nshift=>I) 															-- la dipenda di quanti shift deve subire a dipende iterativamente da I cioè dal numero di stadi
		Port Map (a, output_shift1(I), output_shift2(I), output_shift3(I), output_shift4(I)); 
	end generate;
	
	GenMux_booth: for I in 0 to ((Nb_all_bit/2)-1) generate 															-- generazione di tutti i " mux_booth" che ha la seguente dipendenza logica con il numero di bit di b
		mux_booth_I : mux_booth 
		generic map (Na => Na, Nb => Nb_all_bit)
		Port Map ((others=>'0'), output_shift1(I), output_shift2(I), output_shift3(I), output_shift4(I), output_mux(I), b_encoder(((2*I)+2) downto (2*I))); 
	end generate;

end Behavioral;

