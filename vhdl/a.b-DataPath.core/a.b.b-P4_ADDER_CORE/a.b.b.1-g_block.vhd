library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity g_block is
		port(
			I0 : in std_logic;	-- I0 is Gi:k
			I1 : in std_logic;	-- I1 is Pi:k
			I2 : in std_logic;	-- I2 is Gk-1:j 
			O : out std_logic		-- O is Gi:j
		);
end g_block;

architecture Behavioral of g_block is

begin

	O <= I0 or (I1 and I2);	-- Gi:j = Gi:k + (Pi:k * Gk-1:j)

end Behavioral;

