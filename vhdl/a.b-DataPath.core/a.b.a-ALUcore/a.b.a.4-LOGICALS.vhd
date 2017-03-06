library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity LOGICALS is
	
	generic (N : integer := 32);
	port(
			S : in std_logic_vector(3 downto 0);
			A : in std_logic_vector(N-1 downto 0);
			B : in std_logic_vector(N-1 downto 0);
			Y : out std_logic_vector(N-1 downto 0)
		);
end entity LOGICALS;

architecture BEH of LOGICALS is

component LOG_COMPONENT is
port(
			S : in std_logic_vector(3 downto 0);
			A : in std_logic;
			B : in std_logic;
			Y : out std_logic
		);
end component;

begin

log_init: for I in 0 to N-1 generate
					log_block: LOG_COMPONENT PORT MAP(S, A(I), B(I), Y(I));
				
	end generate log_init;

end BEH;