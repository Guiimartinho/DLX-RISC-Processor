library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity LOG_COMPONENT is

port(
			S : in std_logic_vector(3 downto 0);
			A : in std_logic;
			B : in std_logic;
			Y : out std_logic
		);

end entity;


architecture STRUCT of LOG_COMPONENT is

component NAND3x1 is
	port (
			S : in std_logic;
			A : in std_logic;
			B : in std_logic;
			Y : out std_logic
	);
end component;

component NAND4x1 is
	port (
			A : in std_logic;
			B : in std_logic;
			C : in std_logic;
			D : in std_logic;
			Y : out std_logic
	);
end component;

signal L0, L1, L2, L3 : std_logic; -- temp signal between logic nand gates
signal s_NOT_A, s_NOT_B : std_logic;
begin

	NAND_0: NAND3x1 PORT MAP (S(0), s_NOT_A, s_NOT_B, L0);
	NAND_1: NAND3x1 PORT MAP (S(1), s_NOT_A, B, L1);
	NAND_2: NAND3x1 PORT MAP (S(2), A, s_NOT_B, L2);
	NAND_3: NAND3x1 PORT MAP (S(3), A, B, L3);
	NAND_4: NAND4x1 PORT MAP (L0, L1, L2, L3, Y);
	
	s_NOT_A <= NOT(A);
	s_NOT_B <= NOT(B);


end STRUCT;