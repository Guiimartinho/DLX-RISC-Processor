library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all; 
use WORK.GLOBALS.all;

entity shift_booth is														--componente usato per shiftare e complementare a in accordanza con l'algoritmo di booth
	generic(
			Na: integer:= NumBit32;
			Nb: integer:= NumBit32;
			Nshift: integer:= Shift_mul
		);
		port(
			a: in std_logic_vector(Na-1 downto 0);
			y1: out std_logic_vector((Nb+Na)-1 downto 0);
			y2: out std_logic_vector((Nb+Na)-1 downto 0);
			y3: out std_logic_vector((Nb+Na)-1 downto 0);
			y4: out std_logic_vector((Nb+Na)-1 downto 0)


		);
end shift_booth;

architecture Behavioral of shift_booth is

begin

	process(a)
	variable temp_a1 : std_logic_vector ((Nb+Na)-1 downto 0);
	variable temp_a2 : std_logic_vector ((Nb+Na)-1 downto 0);
	variable temp_a3 : std_logic_vector ((Nb+Na)-1 downto 0);
	variable temp_a4 : std_logic_vector ((Nb+Na)-1 downto 0);
		begin
			temp_a1 := (others=>'0');
			temp_a1 (Na-1 downto 0):= a;
			temp_a1 :=std_logic_vector(unsigned(temp_a1) sll (2*Nshift));
			
			temp_a2:= (not temp_a1)+1;
			
			temp_a3 := (others=>'0');
			temp_a3 (Na-1 downto 0):= a;
			temp_a3 :=std_logic_vector(unsigned(temp_a3) sll ((2*Nshift)+1));
			
			temp_a4:= (not temp_a3)+1;
			
			y1<=temp_a1;
			y2<=temp_a2;
			y3<=temp_a3;
			y4<=temp_a4;
			
	end process;
	

end Behavioral;

