library ieee;
use ieee.std_logic_1164.all;
use WORK.GLOBALS.all; -- ALU TYPE AND CONSTANTS

entity DLX is
  port (
	Clk : in std_logic;
	Rst : in std_logic;                -- Active Low
  -- Data Ram Bus signals
	DRAM_DATAIN : OUT std_logic_vector(NumBit32 - 1 downto 0); 
	DRAM_ADDR  : OUT std_logic_vector(Bit_Addr_Ram  - 1 downto 0); -- ADDRESS WHERE READ/WRITE
	DRAM_DATAOUT  : IN std_logic_vector(NumBit32 - 1 downto 0); -- DATA TO READ
	EN_MEM_RD  : OUT std_logic; -- READ ENABLE
	EN_MEM_WR  : OUT std_logic; -- WRITE ENABLE

  -- Instruction Ram Bus signals
	PC : OUT std_logic_vector(NumBit32 - 1 downto 0); -- PC_SIZE = IR_SIZE
	IRam_DOut : IN std_logic_vector(NumBit32 - 1 downto 0) 
	);
end DLX;

architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------
  
  
  component REG_GENERIC is
	Generic ( N : integer := 32 );
	Port (	D:	In	std_logic_vector(N-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	out	std_logic_vector(N-1 downto 0);
		EN: In	std_logic
		);
	end component;

  -- Datapath 
  COMPONENT DATAPATH  
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
  end COMPONENT ;
  
  -- Control Unit
  component hardwired_cu is
  generic (
		 MICROCODE_MEM_SIZE :     integer := MICROCODE_MEM_SIZE_GLOBALS;  -- Microcode Memory Size
		 FUNC_SIZE          :     integer := FUNC_SIZE_GLOBALS;  -- Func Field Size for R-Type Ops
		 OP_CODE_SIZE       :     integer := OP_CODE_SIZE_GLOBALS;  -- Op Code Size   
		 CW_SIZE            :     integer := CW_SIZE_GLOBALS;  -- Control Word Size
		 ALU_OPC_SIZE       :     integer := ALU_OPC_SIZE_GLOBALS;  -- ALU Op Code Word Size
		 IR_SIZE            :     integer := NumBit32 );
	 port (
	 
	Clk                : in  std_logic;  -- Clock
	Rst                : in  std_logic;  -- Reset:Active-Low
	IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
	
    -- IF Control Signal
	EN_IF : OUT std_logic;  -- NPC1 REGISTERS ENABLE
	SEL_MUX_SEL_PC : OUT std_logic; -- SEL MUX_SEL_PC	

    -- ID Control Signals	
	EN_ID : OUT std_logic;  -- ID REGISTERS ENABLE
	EN_RF : OUT std_logic;  -- REGISTER FILE ENABLE
	EN_RD1 : OUT std_logic;  -- REGISTER FILE RD1 ENABLE
	EN_RD2 : OUT std_logic;  -- REGISTER FILE RD2 ENABLE
	EN_WR : OUT std_logic;  -- REGISTER FILE WR ENABLE
	B_CTRL : OUT std_logic; --CHECK IF BNEZ OR BEQZ
	EN_BRANCH: OUT std_logic; --CHECK IF THE CURRENT INSTRUCTION IS A BRANCH
	EN_JUMP: OUT std_logic; --CHECK IF THE CURRENT INSTRUCTION IS A JUMP
	IS_UNSIGNED_CTRL : OUT std_logic; --CHECK IF UNSIGNED
	IS_JUMP_CTRL : OUT std_logic; --CHECK IF JUMP
	SEL_MUX_REG_R0 : OUT std_logic; -- SEL MUX_REG_R0
	
    
    -- EX Control Signals
	SEL_MUX_A1 : OUT std_logic_vector (1 downto 0);  -- SEL MUX_A1
	SEL_MUX_B1 : OUT std_logic_vector (1 downto 0);  -- SEL MUX_B1
	SEL_MUX_B2 : OUT std_logic; -- SEL MUX_B2
	SEL_MUX_WAIT : OUT std_logic; -- SEL MUX_WAIT
	SEL_MUX_A2 : OUT std_logic;  -- SEL MUX_A2
	SEL_MUX_SEL_RD : OUT std_logic;  -- SEL MUX_SEL_RD
	EN_EX : OUT std_logic;  -- EX REGISTERS ENABLE
	
    -- ALU Operation Code
	ALU_CTRL : OUT std_logic_vector (Alu_op_bit-1 downto 0); --CONTROL SIGNAL FOR THE ALU

    
    -- MEM Control Signals
	EN_MEM : OUT std_logic;  -- MEM REGISTERS ENABLE

    -- WB Control signals
	SEL_MUX_WB : OUT std_logic; -- SEL MUX FOR THE WB STAGE MUX

    -- DATA MEMORY
	
	EN_DRAM_WR : OUT std_logic; --ENABLE WRITE DRAM
	EN_DRAM_RD : OUT std_logic; --ENABLE READ DRAM
	RST_DRAM : OUT std_logic; --RESET FOR DRAM
	RST_IRAM : OUT std_logic; --RESET FOR IRAM
	
    -- DATA HAZARDS 
	 ADDR_Rs1_TO_CU  : IN std_logic_vector(NumBitAddr - 1 DOWNTO 0); -- ADDRESS OF SOURCE REGISTER1
	ADDR_RS2_TO_CU  : IN std_logic_vector(NumBitAddr - 1 DOWNTO 0); -- ADDRESS OF SOURCE REGISTER2 (R-TYPE INSTR)
	ADDR_Rd_TO_CU_MEM  : IN std_logic_vector(NumBitAddr - 1 DOWNTO 0); -- ADDRESS OF DESTINATION REGISTER IN MEM PIPE
	ADDR_Rd_TO_CU_WB : IN std_logic_vector(NumBitAddr - 1 DOWNTO 0) -- ADDRESS OF DESTINATION REGISTER IN WB PIPE
	);
  end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal s_IR_OUT : std_logic_vector(NumBit32 - 1 downto 0);
  signal s_PC_OUT : std_logic_vector(NumBit32 - 1 downto 0);

  -- Instruction Ram Bus signals
--  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals
  signal s_DATAPATH_TO_PC : std_logic_vector(NumBit32 -1 downto 0);

  -- Control Unit Bus signals
  signal s_EN_IF, s_SEL_MUX_SEL_PC, s_EN_ID, s_EN_RF, s_EN_RD1, s_EN_RD2, s_EN_WR, s_B_CTRL, s_EN_BRANCH, s_EN_JUMP, s_IS_UNSIGNED_CTRL, s_IS_JUMP_CTRL, s_SEL_MUX_REG_R0, s_SEL_MUX_B2, s_SEL_MUX_WAIT, s_SEL_MUX_A2, s_SEL_MUX_SEL_RD, s_EN_EX, s_EN_MEM, s_SEL_MUX_WB : std_logic;
  
  signal  s_SEL_MUX_A1, s_SEL_MUX_B1 : std_logic_vector(1 downto 0);
  
  signal s_ALU_CTRL : std_logic_vector(Alu_op_bit-1 downto 0);
  
  signal s_TO_PC, s_FROM_PC, s_FROM_IR : std_logic_vector(NumBit32-1 DOWNTO 0);
  
  signal s_ADDR_Rs1_TO_CU, s_ADDR_RS2_TO_CU, s_ADDR_Rd_TO_CU_MEM, s_ADDR_Rd_TO_CU_WB : std_logic_vector(NumBitAddr-1 DOWNTO 0);

  -- Data Ram Bus signals
  
  signal s_EN_MEM_WR, s_EN_MEM_RD, s_RST_IRAM, s_RST_DRAM : std_logic;
	
  begin  -- DLX

-- SIGNAL ASSIGNMENT DUE TO THE MOVE OF THE IRAM AND DRAM OUTSIDE THE TESTBENCH
	PC <= s_PC_OUT;
	EN_MEM_RD <= s_EN_MEM_RD;
	EN_MEM_WR <= s_EN_MEM_WR;

    -- purpose: Instruction Register Process 
    
    REG_IR:   REG_GENERIC 
    GENERIC MAP (NumBit32)
    PORT MAP (IRam_DOut,  CLK, RST, s_IR_OUT, s_EN_IF); 

    -- purpose: Program Counter Process
    
    REG_PC:   REG_GENERIC 
    GENERIC MAP (NumBit32)
    PORT MAP (s_DATAPATH_TO_PC, CLK, RST, s_PC_OUT, s_EN_IF);

    -- Control Unit 
    hwired: hardwired_cu
    port map ( Clk, Rst, s_IR_OUT, s_EN_IF, s_SEL_MUX_SEL_PC, s_EN_ID, s_EN_RF, s_EN_RD1, s_EN_RD2, s_EN_WR, s_B_CTRL, s_EN_BRANCH, s_EN_JUMP, s_IS_UNSIGNED_CTRL, s_IS_JUMP_CTRL, s_SEL_MUX_REG_R0, s_SEL_MUX_A1, s_SEL_MUX_B1, s_SEL_MUX_B2, s_SEL_MUX_WAIT, s_SEL_MUX_A2, s_SEL_MUX_SEL_RD, s_EN_EX, s_ALU_CTRL, s_EN_MEM, s_SEL_MUX_WB, s_EN_MEM_WR, s_EN_MEM_RD, s_RST_DRAM, s_RST_IRAM, s_ADDR_Rs1_TO_CU, s_ADDR_RS2_TO_CU, s_ADDR_Rd_TO_CU_MEM, s_ADDR_Rd_TO_CU_WB );

    -- DATAPATH 
    Data_path: DATAPATH
    port MAP( Clk, Rst, s_EN_IF, s_SEL_MUX_SEL_PC, s_EN_ID, s_EN_RF, s_EN_RD1, s_EN_RD2, s_EN_WR, s_B_CTRL, s_EN_BRANCH, s_EN_JUMP, s_IS_UNSIGNED_CTRL, s_IS_JUMP_CTRL, s_SEL_MUX_REG_R0, s_SEL_MUX_A1, s_SEL_MUX_B1, s_SEL_MUX_B2, s_SEL_MUX_WAIT, s_SEL_MUX_A2, s_SEL_MUX_SEL_RD, s_EN_EX, s_ALU_CTRL, s_EN_MEM, s_SEL_MUX_WB, DRAM_DATAIN, DRAM_ADDR, DRAM_DATAOUT, s_DATAPATH_TO_PC, s_PC_OUT, s_IR_OUT, s_ADDR_Rs1_TO_CU, s_ADDR_RS2_TO_CU, s_ADDR_Rd_TO_CU_MEM, s_ADDR_Rd_TO_CU_WB );  
    
end dlx_rtl;
