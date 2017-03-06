library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_ARITH.all;
USE WORK.GLOBALS.ALL;

entity DATA_RAM is
 generic( nBit: integer:=32;
          nWords: integer:=2048);  
 port ( CLK: 		IN std_logic;
        RESET: 	IN std_logic;
        EN_RD: IN STD_LOGIC;
		EN_WR: 		IN std_logic;
		ADDR: 	 IN std_logic_vector(Bit_Addr_Ram - 1 downto 0); 
		DATAIN: 	IN std_logic_vector(nbit-1 downto 0);
        DATAOUT: 		OUT std_logic_vector(nbit-1 downto 0));
end DATA_RAM;

architecture beh of DATA_RAM is


   subtype MEM_ADDR is natural range 0 to (nWords -1); -- using natural type
	type MEM_ARRAY is array(MEM_ADDR) of std_logic_vector(8-1 downto 0); -- BYTE ADDRESSED
	signal RAM : MEM_ARRAY; 
	
begin 
process(CLK)
   begin
   
	if(falling_edge(CLK)) then
		if(reset='0') then -- SYNCHRONUS RESET, ACTIVE LOW
			RAM <= (others =>(others => '0'));
		else
			if(EN_WR ='1') then 
				RAM(conv_integer(ADDR))<=datain(31 downto 24);
				RAM(conv_integer(ADDR)+1)<=datain(23 downto 16);
				RAM(conv_integer(ADDR)+2)<=datain(15 downto 8);
				RAM(conv_integer(ADDR)+3)<=datain(7 downto 0);
			end if; 
			IF(EN_RD='1') THEN
				DATAOUT<=RAM(conv_integer(ADDR)) & RAM(conv_integer(ADDR)+1) & RAM(conv_integer(ADDR) + 2) & RAM(conv_integer(ADDR) + 3);
			END IF;		        
		end if;
	end if;

end process;

end beh;