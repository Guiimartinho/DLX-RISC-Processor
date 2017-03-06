library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


entity register_file is
	Generic ( N : natural := 5;
		  M : natural := 32	
	);
 port (  CLK: 		IN std_logic;
         RESET: 	IN std_logic;
		 ENABLE: 	IN std_logic;
		 RD1: 		IN std_logic;
		 RD2: 		IN std_logic;
		 WR: 		IN std_logic;
		 ADD_WR: 	IN std_logic_vector(N-1 downto 0);
		 ADD_RD1: 	IN std_logic_vector(N-1 downto 0);
		 ADD_RD2: 	IN std_logic_vector(N-1 downto 0);
		 DATAIN: 	IN std_logic_vector(M-1 downto 0);
		 OUT1: 		OUT std_logic_vector(M-1 downto 0);
		 OUT2: 		OUT std_logic_vector(M-1 downto 0));
end register_file;

architecture A of register_file is

        -- suggested structures
        subtype REG_ADDR is natural range 0 to (2**N)-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(M-1 downto 0); 
	signal REGISTERS : REG_ARRAY; 

	
begin 
-- process that compute all the operations of the register file. 
	func_process: process (CLK)
	begin
		if (RESET = '0') then
			REGISTERS <= (others => (others => '0'));
		elsif (ENABLE = '1') then
			if (falling_edge (CLK)) then
				if (WR = '1') then
					REGISTERS(TO_INTEGER(UNSIGNED(ADD_WR))) <= DATAIN;
				end if;
				
				if (RD1 = '1') then
				
					if (WR ='1' AND ADD_WR=ADD_RD1) then	--in case if we must write and read in the same address, first the data is write and after is read in the same cycle of clock, this is usefull for istruction that need data out as data in
						OUT1 <= DATAIN;
					else
						OUT1 <= REGISTERS(TO_INTEGER(UNSIGNED(ADD_RD1)));
					end if;
				
				end if;
				
				if (RD2 = '1') then	
				
					if (WR ='1' AND ADD_WR=ADD_RD2) then --in case if we must write and read in the same address, first the data is write and after is read in the same cycle of clock, this is usefull for istruction that need data out as data in
						OUT2 <= DATAIN; 
					else
						OUT2 <= REGISTERS(TO_INTEGER(UNSIGNED(ADD_RD2))); 
					end if;
				end if;
			end if;
		end if;
	end process ;
end A;

----


configuration CFG_RF_BEH of register_file is
  for A
  end for;
end configuration;
