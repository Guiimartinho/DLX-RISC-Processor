library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity p_block is
		port(
			I0 : in std_logic;	-- I0 is Gi:k 
			I1 : in std_logic;	-- I1 is Pi:k
			I2 : in std_logic;	-- I2 is Gk-1:j 
			I3 : in std_logic;	-- I3 is Pk-1:j
			O1 : out std_logic;	-- O1 is Gi:j 	
			O2 : out std_logic	-- O2 is Pi:j
		);
end p_block;

architecture Behavioral of p_block is

begin

	O1 <= I0 or (I1 and I2);	-- Gi:j = Gi:k + Pi:k * Gk-1:j
	O2 <= I1 and I3;				-- Pi:j = Pi:k * Pk-1:j

end Behavioral; 

