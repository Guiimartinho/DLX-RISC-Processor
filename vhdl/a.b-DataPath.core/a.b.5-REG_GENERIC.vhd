library IEEE;
use IEEE.std_logic_1164.all; 

entity REG_GENERIC is
	Generic ( N : integer := 32 );
	Port (	D:	In	std_logic_vector(N-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	out	std_logic_vector(N-1 downto 0);
		EN: In	std_logic
		);
end REG_GENERIC;


architecture BEH of REG_GENERIC is -- flip flop D with syncronous reset

begin
	PSYNCH: process(CK)
	begin
	  if CK'event and CK='1' then -- positive edge triggered:
		if EN='1' then
			if RESET='0' then -- active high reset 
			  Q <= (others => '0'); 
			else
			  Q <= D; -- input is written on output
			end if;
		end if;
	  end if;
	end process;

end BEH;


  
