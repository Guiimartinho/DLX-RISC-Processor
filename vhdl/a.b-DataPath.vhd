library IEEE;
use IEEE.std_logic_1164.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.GLOBALS.all; 

entity DATAPATH is
	generic ( NBit_reg: integer := NumBit32;
			  NBit_addr: integer := NumBitAddr;
			  NBit_ram: integer := BIT_ADDR_RAM);  -- IR, PC AND GPR
  port (
	Clk                : in  std_logic;  -- Clock
	Rst                : in  std_logic;  -- Reset:Active-Low
    -- IF Control Signal
	EN_IF : IN std_logic;  -- NPC1 REGISTERS ENABLE
	SEL_MUX_SEL_PC : IN std_logic; -- SEL MUX_SEL_PC	

    -- ID Control Signals	
	EN_ID : IN std_logic;  -- ID REGISTERS ENABLE
	EN_RF : IN std_logic;  -- REGISTER FILE ENABLE
	EN_RD1 : IN std_logic;  -- REGISTER FILE RD1 ENABLE
	EN_RD2 : IN std_logic;  -- REGISTER FILE RD2 ENABLE
	EN_WR : IN std_logic;  -- REGISTER FILE WR ENABLE
	B_CTRL : IN std_logic; --CHECK IF BNEZ OR BEQZ
	EN_BRANCH: IN std_logic; --CHECK IF THE CURRENT INSTRUCTION IS A BRANCH
	EN_JUMP: IN std_logic; --CHECK IF THE CURRENT INSTRUCTION IS A JUMP
	IS_UNSIGNED_CTRL : IN std_logic; --CHECK IF UNSIGNED
	IS_JUMP_CTRL : IN std_logic; --CHECK IF JUMP
	SEL_MUX_REG_R0 : IN std_logic; -- SEL MUX_REG_R0
	
    
    -- EX Control Signals
	SEL_MUX_A1 : IN std_logic_vector (1 downto 0);  -- SEL MUX_A1
	SEL_MUX_B1 : IN std_logic_vector (1 downto 0);  -- SEL MUX_B1
	SEL_MUX_B2 : IN std_logic; -- SEL MUX_B2
	SEL_MUX_WAIT : IN std_logic; -- SEL MUX_WAIT
	SEL_MUX_A2 : IN std_logic;  -- SEL MUX_A2
	SEL_MUX_SEL_RD : IN std_logic;  -- SEL MUX_SEL_RD
	EN_EX : IN std_logic;  -- EX REGISTERS ENABLE

	
    -- ALU Operation Code
	ALU_CTRL : IN std_logic_vector (Alu_op_bit-1 downto 0); --CONTROL SIGNAL FOR THE ALU

    
    -- MEM Control Signals
	EN_MEM : IN std_logic;  -- MEM REGISTERS ENABLE

    -- WB Control signals
	SEL_MUX_WB : IN std_logic; -- SEL MUX FOR THE WB STAGE MUX

    -- DATA MEMORY
	
	DATA_DRAM  : OUT std_logic_vector(NBit_reg - 1 DOWNTO 0); -- DATA TO WRITE
	ADDR_DRAM          : OUT std_logic_vector(NBit_ram - 1 DOWNTO 0); -- ADDRESS WHERE READ/WRITE
	OUT_DRAM           : IN std_logic_vector(NBit_reg - 1 DOWNTO 0);  -- DATA TO READ

    
    -- OUTSIDE THE DATAPATH
	TO_PC              : OUT std_logic_vector(NBit_reg -1 DOWNTO 0); -- from datapath
	FROM_PC           : IN std_logic_vector(NBit_reg -1 DOWNTO 0);  -- to datapath
	FROM_IR            : IN std_logic_vector(NBit_reg -1 DOWNTO 0); -- from IRAM

    -- DATA HAZARDS 
	 ADDR_Rs1_TO_CU  : OUT std_logic_vector(NBit_addr - 1 DOWNTO 0); -- ADDRESS OF SOURCE REGISTER1
	 ADDR_RS2_TO_CU  : OUT std_logic_vector(NBit_addr - 1 DOWNTO 0); -- ADDRESS OF SOURCE REGISTER2 (R-TYPE INSTR)
	 ADDR_Rd_TO_CU_MEM  : OUT std_logic_vector(NBit_addr - 1 DOWNTO 0); -- ADDRESS OF DESTINATION REGISTER IN MEM PIPE
	 ADDR_Rd_TO_CU_WB : OUT std_logic_vector(NBit_addr - 1 DOWNTO 0) -- ADDRESS OF DESTINATION REGISTER IN WB PIPE

    );  

end DATAPATH;

architecture STRUCTURAL of DATAPATH  is

--COMPONENTS DECLARATIONS---------------------------------------------------------------------------------------------------------------
component MUX21_GENERIC is

	Generic (N: integer:= 32					--numbit and tp_mux is a constant value definied into the file constants.vhd
		);
	Port (	A:	In	std_logic_vector(N-1 downto 0) ;	--entity declaration of a mux2x1
				B:	In	std_logic_vector(N-1 downto 0);
				SEL:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0)
				);
end component;

component MUX_31 is 
	generic (N : integer := 32);
	Port (	A:	In	std_logic_vector(n-1 downto 0); 
		B:	In	std_logic_vector(n-1 downto 0);
		C:	In	std_logic_vector(n-1 downto 0);
		Sel:	In	std_logic_vector(1 downto 0);
		Y:	Out	std_logic_vector(n-1 downto 0));
end component ;

component REG_GENERIC is
	
	Generic ( N : integer := 32 );
	Port (	D:	In	std_logic_vector(N-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	out	std_logic_vector(N-1 downto 0);
		EN: In	std_logic
			);
end component;


component P4_adder is

generic (Num: integer:= NumBit32 --numero di bit degli addendi in ingresso (A,B) deve essere una potenza di due >= 4
			);
	port( A, B : in std_logic_vector(Num-1 downto 0);
			c_in : in std_logic; 
			c_out : out std_logic;
			SUM : out std_logic_vector(Num-1 downto 0)
		);
end component;

component SIGN_EXTENDED is

	generic ( N: INTEGER := 32
	         );
	Port (	
	   IS_UNSIGNED :  In	std_logic;
	   IS_JUMP :  In	std_logic;
	   S_IN:	In	std_logic_vector(N-1 downto 0); 
		S_OUT:	Out	std_logic_vector(N-1 downto 0)
		);
end component;

component register_file is

	generic ( N : natural := 5;
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
		 OUT2: 		OUT std_logic_vector(M-1 downto 0)
		 );
end component;

component ZERO_COMPARATOR is 
	generic (
	         N: INTEGER := 32
	         );
	Port (	
	    CTRL_COND :  In	std_logic;
	    S_IN:	In	std_logic_vector(N-1 downto 0); 
		S_OUT:	Out	std_logic;
		EN_BRANCH: in std_logic;
		EN_JUMP: in std_logic
		);
end component;		

component booth_multiplier is

	generic(
			Na: integer:= NumBit32;										--bit del operando a
			Nb: integer:= NumBit32										--bit del operando b		DEVE ESSERE UN NUMERO PARI PER COME è DEFINITO NEL ALGORITMO
			);
	port(
		a: in std_logic_vector(Na-1 downto 0);						--operando a
		b: in std_logic_vector(Nb-1 downto 0);						--operando b
		result: out std_logic_vector(Na+Nb-1 downto 0)				--risultato del operazione: numero di bit pari al numero di bit del operando a + numero di bit del operando b
	);
end component;

component FFD is
	Port (	D:	In	std_logic;
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	out	std_logic;
		EN: In	std_logic
		);
end component;

component ALU is
	
	generic (N : integer := NumBit32);
	port 	 ( FUNC: IN std_logic_vector (Alu_op_bit-1 downto 0);
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end component;

--END COMPONENTS-------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
-- FECTH SIGNALS
SIGNAL ADDER_PC_OUT, P4_ADDER1_OUT, NPC1_IN , NPC1_OUT: STD_LOGIC_VECTOR(NBit_reg -1 DOWNTO 0);
CONSTANT P4_ADDER1_IN2: STD_LOGIC_VECTOR(NBit_reg -1 DOWNTO 0) := X"00000004" ; 
SIGNAL Cout_P4_ADDER1 : STD_LOGIC;

-- DECODE SIGNALS

SIGNAL S_EXTENDED, RD1, REG_A_OUT, RD2, REG_B_OUT, REG_IMM_OUT, REG_WAIT1_OUT, WRITE_BACK, NPC2_BIS_OUT : STD_LOGIC_VECTOR(NBit_reg -1 DOWNTO 0);
SIGNAL RF_ADDR_RD1, RF_ADDR_RD2, REG_WAIT3_OUT : STD_LOGIC_VECTOR( NBit_addr-1 DOWNTO 0);
SIGNAL Cout_P4_ADDER2, ZERO_COMP_OUT : STD_LOGIC;
CONSTANT ADDR_R0 : STD_LOGIC_VECTOR( NBit_addr-1 DOWNTO 0) := (others => '0');
 
-- EXECUTE SIGNALS

SIGNAL ALU_OUT1, ALU_IN1, MUX_B1_OUT, ALU_IN2, ALU_OUT, MUX_A1_OUT : STD_LOGIC_VECTOR(NBit_reg -1 DOWNTO 0);
SIGNAL REG_WAIT2_IN, REG_WAIT2_OUT, MUX_WAIT_OUT: STD_LOGIC_VECTOR(NBit_addr -1 DOWNTO 0);
CONSTANT ADDR_R31 : STD_LOGIC_VECTOR( NBit_addr-1 DOWNTO 0) := (others => '1');

-- MEMORY SIGNALS

SIGNAL ALU_OUT2, LMD_OUT: STD_LOGIC_VECTOR(NBit_reg -1 DOWNTO 0);

-- WRITE BACK SIGNALS

begin

-- FWD UNIT SIGNAL 

	ADDR_Rs1_TO_CU  <= REG_WAIT1_OUT(25 DOWNTO 21);
	ADDR_RS2_TO_CU  <= REG_WAIT1_OUT(20 DOWNTO 16);
	ADDR_Rd_TO_CU_MEM <= REG_WAIT2_OUT;
	ADDR_Rd_TO_CU_WB <= REG_WAIT3_OUT;

-- FECTH

	MUX_SEL_PC: MUX21_GENERIC 
	GENERIC MAP (NBit_reg) 
	PORT MAP ( NPC1_IN ,RD1, SEL_MUX_SEL_PC, TO_PC);

   
   MUX_NPC1: MUX21_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP ( ADDER_PC_OUT ,P4_ADDER1_OUT, ZERO_COMP_OUT, NPC1_IN);
   
   NPC1: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (NPC1_IN, CLK, RST, NPC1_OUT, EN_IF);       
   
   P4_ADDER1: P4_adder 
   GENERIC MAP (NBit_reg) 
   PORT MAP (FROM_PC, P4_ADDER1_IN2, '0', Cout_P4_ADDER1, P4_ADDER1_OUT);
 

-- DECODE 
   
   
 
	P4_ADDER2: P4_adder 
   GENERIC MAP (NBit_reg) 
   PORT MAP (S_EXTENDED, NPC1_OUT, '0', Cout_P4_ADDER2, ADDER_PC_OUT);
   
	NPC2_BIS: REG_GENERIC 
	GENERIC MAP (NBit_reg) 
	PORT MAP (P4_ADDER1_OUT, CLK, RST, NPC2_BIS_OUT, EN_ID);  
   
   REG_A: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (RD1, CLK, RST, REG_A_OUT, EN_ID);
   
   REG_B: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (RD2, CLK, RST, REG_B_OUT, EN_ID);
   
   REG_IMM: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (S_EXTENDED, CLK, RST, REG_IMM_OUT, EN_ID);
   
   REG_WAIT1: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (FROM_IR, CLK, RST, REG_WAIT1_OUT, EN_ID);
   
   RF_ADDR_RD1 <= FROM_IR (25 DOWNTO 21); 
   --RF_ADDR_RD2 <= FROM_IR (20 DOWNTO 16);
   
   REG_FILE: register_file 
   GENERIC MAP (N => NBit_addr, M => NBit_reg) 
   PORT MAP (CLK, RST, EN_RF, EN_RD1, EN_RD2, EN_WR, REG_WAIT3_OUT, RF_ADDR_RD1, RF_ADDR_RD2, WRITE_BACK, RD1, RD2);
   
   ZERO_COMP: ZERO_COMPARATOR 
   GENERIC MAP (NBit_reg) 
   PORT MAP (B_CTRL, RD1, ZERO_COMP_OUT, EN_BRANCH, EN_JUMP);
   
   SIGN_EXT: SIGN_EXTENDED 
   GENERIC MAP (NBit_reg) 
   PORT MAP (IS_UNSIGNED_CTRL, IS_JUMP_CTRL, FROM_IR, S_EXTENDED);
   
	MUX_REG_R0: MUX21_GENERIC 
	GENERIC MAP (NBit_addr) 
	PORT MAP ( FROM_IR (20 DOWNTO 16) , ADDR_R0, SEL_MUX_REG_R0, RF_ADDR_RD2);   


-- EXECUTE
   MUX_A1: MUX_31 
   GENERIC MAP (NBit_reg) 
   PORT MAP ( WRITE_BACK, ALU_OUT1, REG_A_OUT, SEL_MUX_A1, MUX_A1_OUT);
   
   MUX_B1: MUX_31 
   GENERIC MAP (NBit_reg) 
   PORT MAP ( REG_B_OUT, ALU_OUT1, WRITE_BACK, SEL_MUX_B1, MUX_B1_OUT);
   
   MUX_B2: MUX21_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP ( MUX_B1_OUT, REG_IMM_OUT, SEL_MUX_B2, ALU_IN2);
   
   MUX_WAIT: MUX21_GENERIC 
   GENERIC MAP (NBit_addr) 
   PORT MAP ( REG_WAIT1_OUT(20 DOWNTO 16), REG_WAIT1_OUT(15 DOWNTO 11), SEL_MUX_WAIT, MUX_WAIT_OUT);
   
   ALU0: ALU
   GENERIC MAP (NBit_reg)
   PORT MAP (ALU_CTRL, ALU_IN1, ALU_IN2, ALU_OUT);
   
   REG_ALU_OUT1: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (ALU_OUT, CLK, RST, ALU_OUT1, EN_EX);
   
   REG_READ_MEM: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (MUX_B1_OUT, CLK, RST, DATA_DRAM, EN_EX);
   
   REG_WAIT2: REG_GENERIC 
   GENERIC MAP (NBit_addr) 
   PORT MAP (REG_WAIT2_IN, CLK, RST, REG_WAIT2_OUT, EN_EX);
   
	MUX_A2: MUX21_GENERIC 
	GENERIC MAP (NBit_reg) 
	PORT MAP ( NPC2_BIS_OUT, MUX_A1_OUT, SEL_MUX_A2, ALU_IN1);   

	MUX_SEL_RD: MUX21_GENERIC 
	GENERIC MAP (NBit_addr) 
	PORT MAP ( MUX_WAIT_OUT, ADDR_R31, SEL_MUX_SEL_RD, REG_WAIT2_IN); 
   
   
-- MEMORY 
 
	ADDR_DRAM <= ALU_OUT1 (NBit_ram - 1  DOWNTO 0);
	
	REG_ALU_OUT2: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (ALU_OUT1, CLK, RST, ALU_OUT2, EN_MEM);
   
   LMD: REG_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP (OUT_DRAM, CLK, RST, LMD_OUT, EN_MEM);
   
   REG_WAIT3: REG_GENERIC 
   GENERIC MAP (NBit_addr) 
   PORT MAP (REG_WAIT2_OUT, CLK, RST, REG_WAIT3_OUT, EN_MEM);
 
   
-- WRITE BACK
 
	MUX_WB: MUX21_GENERIC 
   GENERIC MAP (NBit_reg) 
   PORT MAP ( ALU_OUT2, LMD_OUT, SEL_MUX_WB, WRITE_BACK);
   
end STRUCTURAL;
