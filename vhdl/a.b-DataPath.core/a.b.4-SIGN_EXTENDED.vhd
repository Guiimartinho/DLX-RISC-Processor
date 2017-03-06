library IEEE;
use IEEE.std_logic_1164.all; 

entity SIGN_EXTENDED is 
	generic ( N: INTEGER := 32
	         );
	Port (	
	   IS_UNSIGNED :  In	std_logic;
	   IS_JUMP :  In	std_logic;
	   S_IN:	In	std_logic_vector(N-1 downto 0); 
		S_OUT:	Out	std_logic_vector(N-1 downto 0)
		);
end SIGN_EXTENDED ;


ARCHITECTURE BEH OF SIGN_EXTENDED IS

        
BEGIN    
  process(S_IN,IS_UNSIGNED,IS_JUMP)
  begin
     IF IS_JUMP='1' THEN 
        
        IF IS_UNSIGNED ='1' THEN 
           S_OUT (31 DOWNTO 26) <= (OTHERS => '0');
		   S_OUT (25 DOWNTO 0) <= S_IN (25 DOWNTO 0);
        ELSE
		   S_OUT (31 DOWNTO 26) <= (OTHERS => S_IN(25));
		   S_OUT (25 DOWNTO 0) <= S_IN (25 DOWNTO 0);
        END IF;   
     ELSE 
        IF IS_UNSIGNED ='1' THEN 
		   S_OUT (31 DOWNTO 16) <= (OTHERS => '0');
		   S_OUT (15 DOWNTO 0) <= S_IN (15 DOWNTO 0);
        ELSE
		   S_OUT (31 DOWNTO 16) <= (OTHERS => S_IN(15));
		   S_OUT (15 DOWNTO 0) <= S_IN (15 DOWNTO 0);        
		END IF;  
     END IF;   
  end process;
  
END BEH;