library IEEE;
use IEEE.std_logic_1164.all; 

entity ZERO_COMPARATOR is 
	generic (
	         N: INTEGER := 32
	         );
	Port (	
	    CTRL_COND :  In	std_logic;
	    S_IN:	In	std_logic_vector(N-1 downto 0); 
		S_OUT:	Out	std_logic;
		EN_BRANCH: IN std_logic;
		EN_JUMP : IN std_logic
		);
end ZERO_COMPARATOR ;


ARCHITECTURE BEH OF ZERO_COMPARATOR IS

signal ZERO : std_logic_vector(N-1 downto 0) := (OTHERS => '0');

BEGIN    
  process(S_IN, CTRL_COND, EN_BRANCH, EN_JUMP)
  begin
	
	IF EN_JUMP = '1' THEN
		S_OUT <= '0';
	ELSIF EN_BRANCH = '0'THEN
	
		S_OUT <= '1';
	
	ELSE
	
		 IF CTRL_COND = '0' THEN -- IF CTRL_COND=0 => IS A BEQZ 
			IF S_IN = ZERO  THEN 
			   S_OUT <= '0';
			ELSE
			   S_OUT <= '1' ;
			END IF;   
		 ELSE 				 	-- IF CTRL_COND=1 => IS A BNEZ 
			IF S_IN /= ZERO  THEN 
			   S_OUT <= '0';
			ELSE
			   S_OUT <= '1' ;
			END IF;      
		 END IF; 
		 
	END IF;
  end process;
  
END BEH;