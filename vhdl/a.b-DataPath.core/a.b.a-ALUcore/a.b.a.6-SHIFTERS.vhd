library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use WORK.GLOBALS.all;

entity SHIFTER is

	generic(N: integer := 32);
	port(	A: in std_logic_vector(N-1 downto 0);
			B: in std_logic_vector(4 downto 0);		-- # of bits to be shifted
			LOGIC_ARITH: in std_logic;		-- 1 = logic, 0 = arith
			LEFT_RIGHT: in std_logic;		-- 1 = left, 0 = right
			SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
			OUTPUT: out std_logic_vector(N-1 downto 0)
		);
end SHIFTER;

architecture Behavioral of SHIFTER is
begin

SHIFT: process (A, B, LOGIC_ARITH, LEFT_RIGHT, SHIFT_ROTATE) is
	begin
		if SHIFT_ROTATE = ROT then

			if LEFT_RIGHT = RIGHT then
				OUTPUT <= to_StdLogicVector((to_bitvector(A)) ror (conv_integer(B)));
			else
				OUTPUT <= to_StdLogicVector((to_bitvector(A)) rol (conv_integer(B)));
			end if;
		else

			if LEFT_RIGHT = RIGHT then

				if LOGIC_ARITH = ARITH then
					OUTPUT <= to_StdLogicVector((to_bitvector(A)) sra (conv_integer(B)));
				else
					OUTPUT <= to_StdLogicVector((to_bitvector(A)) srl (conv_integer(B)));
				end if;				
			else

				if LOGIC_ARITH = ARITH then
					OUTPUT <= to_StdLogicVector((to_bitvector(A)) sla (conv_integer(B)));
				else
					OUTPUT <= to_StdLogicVector((to_bitvector(A)) sll (conv_integer(B)));
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;