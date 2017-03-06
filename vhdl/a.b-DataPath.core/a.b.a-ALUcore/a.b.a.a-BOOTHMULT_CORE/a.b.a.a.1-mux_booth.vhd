library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.GLOBALS.all;

entity mux_booth is
	generic(
			Na: integer:= NumBit32;
			Nb: integer:= NumBit32
		);
		port(
			in0: in std_logic_vector((Nb+Na)-1 downto 0);
			in1: in std_logic_vector((Nb+Na)-1 downto 0);
			in2: in std_logic_vector((Nb+Na)-1 downto 0);
			in3: in std_logic_vector((Nb+Na)-1 downto 0);
			in4: in std_logic_vector((Nb+Na)-1 downto 0);
			output: out std_logic_vector((Nb+Na)-1 downto 0);
			sel: in std_logic_vector(2 downto 0)
		);
end mux_booth;

architecture Behavioral of mux_booth is

begin

	mux_proc: process (in0, in1, in2, in3, in4, sel)
		begin
			case sel is
				when "000" =>													 					-- 0
					output<=in0;
				when "001" =>													 					-- +A
					output<=in1;
				when "010" =>													 					-- +A
					output<=in1;
				when "011"  =>																		-- +2A
					output <=in3;
				when "100"  =>																		-- -2A
					output <=in4;
				when "101" =>													 					-- -A
					output<=in2;
				when "110" =>													 					-- -A
					output<=in2;
				when "111" =>													 					-- 0
					output<=in0;
				when others =>													 					
					output<= (others => '0');
			end case;
	end process;
		


end Behavioral;

