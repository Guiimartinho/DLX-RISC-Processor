library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.GLOBALS.all;

entity hardwired_cu is
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
	 
	
			 
end hardwired_cu;

architecture Behavioral of hardwired_cu is

type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0); -- THE ALU1 AND ALU2 ARE SET OR CLEAR BY ALUOPCODE INTERNAL SIGNAL
constant cw_mem : mem_array := (
					--( SEL_MUX_SEL_PC, EN_ID, EN_RF, EN_RD1, EN_RD2, B_CTRL, EN_BRANCH, EN_JUMP, IS_UNSIGNED_CTRL, IS_JUMP_CTRL, SEL_MUX_REG_R0, SEL_MUX_B2, SEL_MUX_WAIT,
					--SEL_MUX_A2, SEL_MUX_SEL_RD, EN_EX, EN_MEM, EN_DRAM_WR, EN_DRAM_RD, SEL_MUX_WB, EN_WR)
								"011110000000110110001", -- R-type(0X00), 0								
                                "011110000000110110001", -- MULT (0X01), 1
                                "010000010100000000000", -- J     (0X02), 2
                                "011010010110001110001", -- JAL   (0X03), 3
                                "011100100000010000000", -- BEQZ  (0X04), 4 
                                "011101100000010000000", -- BNEZ  (0X05), 5 
                                "000000000000000000000", -- (0X06), 6
                                "000000000000000000000", -- (0X07), 7
                                "011100000001010110001", -- ADDi  (0X08), 8
								"011100001001010110001", -- ADDUi (0X09), 9  
                                "011100000001010110001", -- SUBI  (0X0A), 10
								"011100001001010110001", -- SUBUI (0X0B), 11
                                "011100000001010110001", -- ANDI  (0X0C), 12
                                "011100000001010110001", -- ORi   (0X0D), 13
                                "011100000001010110001", -- XORI  (0X0E), 14
                                "011100000001010110001", -- LHI   (0X0F), 15
								"000000000000000000000", -- (0X10), 16
								"000000000000000000000", -- (0X11), 17
								"111100011100010000000", -- JR    (0X12), 18
								"111100011110001110000", -- JALR  (0X13), 19
                                "011100000001010110001", -- SLLI  (0X14), 20
								"000000000000000000000", -- NOP   (0X15), 21
                                "011100000001010110001", -- SRLI  (0X16), 22
                                "011100000001010110001", -- SRAI  (0X17), 23 
                                "011100000001010110001", -- SEQI  (0X18), 24
                                "011100000001010110001", -- SNEI  (0X19), 25
                                "011100000001010110001", -- SLTI  (0X1A), 26
                                "011100000001010110001", -- SGTI  (0X1B), 27
                                "011100000001010110001", -- SLEI  (0X1C), 28
                                "011100000001010110001", -- SGEI  (0X1D), 29
								"000000000000000000000", -- (0X1E), 30
                                "000000000000000000000", -- (0X1F), 31
                                "000000000000000000000", -- LB	(0X20), 32 
                                "000000000000000000000", -- (0X21), 33
                                "000000000000000000000", -- (0X22), 34
                                "011100000001010110111", -- LW    (0X23), 35
                                "000000000000000000000", -- LBU	(0X24), 36
                                "000000000000000000000", -- LHU (0X25), 37
                                "000000000000000000000", -- (0X26), 38
                                "000000000000000000000", -- (0X27), 39
                                "000000000000000000000", -- SB	(0X28), 40
                                "000000000000000000000", -- (0X29), 41
                                "000000000000000000000", -- (0X2A), 42
                                "011110000001010111000", -- SW    (0X2B), 43
                                "000000000000000000000", -- (0X2C), 44
                                "000000000000000000000", -- (0X2D), 45
                                "000000000000000000000", -- (0X2E), 46
                                "000000000000000000000", -- (0X2F), 47
                                "000000000000000000000", -- (0X30), 48
                                "000000000000000000000", -- (0X31), 49
                                "000000000000000000000", -- (0X32), 50
                                "000000000000000000000", -- (0X33), 51 
                                "000000000000000000000", -- (0X34), 52
                                "000000000000000000000", -- (0X35), 53
                                "000000000000000000000", -- (0X36), 54
                                "000000000000000000000", -- (0X37), 55
                                "000000000000000000000", -- (0X38), 56
                                "000000000000000000000", -- (0X39), 57
                                "011100001001010110001", -- SLTUI (0X3A), 58
                                "011100001001010110001", -- SGTUI (0X3B), 59
                                "011100001001010110001", -- SLEUI (0X3C), 60 
                                "011100001001010110001" -- SGEUI (0X3D), 61

							);
												

  -- control word is shifted to the correct stage
signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- IF/ID stage
signal cw2 : std_logic_vector(CW_SIZE2 - 1 downto 0); -- ID/EX stage
signal cw3 : std_logic_vector(CW_SIZE3 - 1 downto 0); -- EX/MEM stage	
signal cw4 : std_logic_vector(CW_SIZE4 - 1 downto 0); -- MEM/WB stage

signal OPCODE : std_logic_vector (OP_CODE_SIZE -1 downto 0) := (others => '0');	
signal FUNC : std_logic_vector (FUNC_SIZE -1 downto 0) := (others => '0');	

signal aluOpcode_i: std_logic_vector(ALU_OPC_SIZE - 1  downto 0) := NOP;
signal aluOpcode1: std_logic_vector(ALU_OPC_SIZE - 1  downto 0) := NOP;	
	
begin
		
  cw1 <= cw_mem(conv_integer(OPCODE));
  EN_IF  <= '1';
  OPCODE <= IR_IN(31 downto 31 - OP_CODE_SIZE +1);
  FUNC <= IR_IN(FUNC_SIZE - 1 downto 0);
  
  -- IF/ID control signals
  
  
  SEL_MUX_SEL_PC <= cw1(CW_SIZE - 1);
  EN_ID <= cw1(CW_SIZE - 2);
  EN_RF <= cw1(CW_SIZE - 3);
  EN_RD1 <= cw1(CW_SIZE - 4);
  EN_RD2 <= cw1(CW_SIZE - 5);
  B_CTRL <= cw1(CW_SIZE - 6);
  EN_BRANCH <= cw1(CW_SIZE - 7);
  EN_JUMP <= cw1(CW_SIZE - 8);
  IS_UNSIGNED_CTRL <= cw1(CW_SIZE - 9);
  IS_JUMP_CTRL <= cw1(CW_SIZE - 10);
  SEL_MUX_REG_R0 <= cw1(CW_SIZE - 11);
  
  -- ID/EX control signals
  
  SEL_MUX_B2 <= cw2(CW_SIZE - 12);
  SEL_MUX_WAIT <= cw2(CW_SIZE - 13);
  SEL_MUX_A2 <= cw2(CW_SIZE - 14);
  SEL_MUX_SEL_RD  <= cw2(CW_SIZE - 15);
  EN_EX <= cw2(CW_SIZE - 16);
  
  
  -- EX/MEM control signals
  
  EN_MEM <= cw3(CW_SIZE - 17);
  EN_DRAM_WR <= cw3(CW_SIZE - 18);
  EN_DRAM_RD <= cw3(CW_SIZE - 19);
   
  
  -- MEM/WB control signals
  
  SEL_MUX_WB <= cw4(CW_SIZE - 20);
  EN_WR <= cw4(CW_SIZE - 21);
  
  

  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '0' then                   -- asynchronous reset (active low)
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
	  
	 aluOpcode1 <= NOP;
   
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      
	  cw2 <= cw1(CW_SIZE2 -1 downto 0);
      cw3 <= cw2(CW_SIZE3 -1 downto 0);
      cw4 <= cw3(CW_SIZE4 -1 downto 0);
	
	  aluOpcode1 <= aluOpcode_i; 
     
    end if;
  end process CW_PIPE; 
  
  ALU_CTRL <= aluOpcode1;
    
  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (OPCODE, FUNC)
   begin  -- process ALU_OP_CODE_P
		case conv_integer(unsigned(OPCODE)) is
				  -- case of R type requires analysis of FUNC
			when RTYPE =>
				case conv_integer(unsigned(FUNC)) is
					when RTYPE_SLL  => aluOpcode_i <= F_SLL; 
					when RTYPE_SRL  => aluOpcode_i <= F_SRL;
					when RTYPE_SRA  => aluOpcode_i <= F_SRA; 
					when RTYPE_ADD  => aluOpcode_i <= F_ADD;				
					when RTYPE_ADDU => aluOpcode_i <= F_ADD; 
					when RTYPE_SUB  => aluOpcode_i <= F_SUB;
					when RTYPE_SUBU => aluOpcode_i <= F_SUB; 
					when RTYPE_AND  => aluOpcode_i <= F_AND;					
					when RTYPE_OR   => aluOpcode_i <= F_OR; 
					when RTYPE_XOR  => aluOpcode_i <= F_XOR;
					when RTYPE_SEQ  => aluOpcode_i <= F_SEQ; 
					when RTYPE_SNE  => aluOpcode_i <= F_SNE;					
					when RTYPE_SLT  => aluOpcode_i <= F_SLT; 
					when RTYPE_SGT  => aluOpcode_i <= F_SGT;
					when RTYPE_SLE  => aluOpcode_i <= F_SLE; 
					when RTYPE_SGE  => aluOpcode_i <= F_SGE;									
					when RTYPE_SLTU => aluOpcode_i <= F_SLTU;
					when RTYPE_SGTU => aluOpcode_i <= F_SGTU; 
					when RTYPE_SLEU => aluOpcode_i <= F_SLEU;
					when RTYPE_SGEU => aluOpcode_i <= F_SGEU;					
					--when RTYPE_MULT => aluOpcode_i <= F_MULT; 																				 			 
					when others => aluOpcode_i <= NOP;
				end case;
			when FTYPE =>
				case conv_integer(unsigned(FUNC)) is
					when F_TYPE_MULT  => aluOpcode_i <= F_MULT; 																				 			 
					when others => aluOpcode_i <= NOP;
				end case;
				
			when TYPE_J    => aluOpcode_i <= NOP; 
			when TYPE_JAL  => aluOpcode_i <= F_JAL; 
			when TYPE_BEQZ => aluOpcode_i <= NOP; 
			when TYPE_BNEZ => aluOpcode_i <= NOP; 		          	
      		when TYPE_ADDI => aluOpcode_i <= F_ADD;	    	
			when TYPE_ADDUI => aluOpcode_i <= F_ADD; --F_ADDU;
			when TYPE_SUBI => aluOpcode_i <= F_SUB; 
			when TYPE_SUBUI => aluOpcode_i <= F_SUB; -- F_SUBU;		    
			when TYPE_ANDI => aluOpcode_i <= F_AND; 
			when TYPE_ORI => aluOpcode_i <= F_OR; 
			when TYPE_XORI => aluOpcode_i <= F_XOR;  	
      		when TYPE_JR => aluOpcode_i <= NOP;       
			when TYPE_JALR => aluOpcode_i <= F_JAL; 
			when TYPE_SLLI => aluOpcode_i <= F_SLL; 
			when TYPE_LHI  => aluOpcode_i <= F_LHI; 	
      		when TYPE_NOP => aluOpcode_i <= NOP;
     		when TYPE_SRLI => aluOpcode_i <= F_SRL;     	    	
			when TYPE_SRAI => aluOpcode_i <= F_SRA; 
			when TYPE_SEQI => aluOpcode_i <= F_SEQ;
			when TYPE_SNEI => aluOpcode_i <= F_SNE;    
			when TYPE_SLTI => aluOpcode_i <= F_SLT; 		    
			when TYPE_SGTI => aluOpcode_i <= F_SGT; 
			when TYPE_SLEI => aluOpcode_i <= F_SLE; 
			when TYPE_SGEI => aluOpcode_i <= F_SGE;
			when TYPE_LW => aluOpcode_i <= F_ADD; -- F_MEM; 	  
      		when TYPE_SW => aluOpcode_i <= F_ADD; -- F_MEM;
      		when TYPE_SLTUI => aluOpcode_i <= F_SLTU;  	
			when TYPE_SGTUI => aluOpcode_i <= F_SGTU;
			when TYPE_SLEUI => aluOpcode_i <= F_SLEU; 	    
			when TYPE_SGEUI => aluOpcode_i <= F_SGEU;				
			when others => aluOpcode_i <= NOP; 
	 end case;
	end process ALU_OP_CODE_P;
	
	FORWARD_UNIT: PROCESS(ADDR_Rs1_TO_CU,ADDR_RS2_TO_CU,ADDR_Rd_TO_CU_MEM,ADDR_Rd_TO_CU_WB)
		BEGIN

		SEL_MUX_A1 <= "01";
		SEL_MUX_B1 <= "00";

		-- EX hazard:

		IF ((CONV_INTEGER(ADDR_Rd_TO_CU_MEM) /= 0) and (ADDR_Rd_TO_CU_MEM = ADDR_Rs1_TO_CU)) THEN 
			SEL_MUX_A1 <= "10";
		end if;
		IF ((CONV_INTEGER(ADDR_Rd_TO_CU_MEM) /= 0) and (ADDR_Rd_TO_CU_MEM = ADDR_RS2_TO_CU)) THEN
			SEL_MUX_B1 <= "10";
		END IF;	

		-- MEM hazard:

		if ((CONV_INTEGER(ADDR_Rd_TO_CU_WB) /= 0) and not((CONV_INTEGER(ADDR_Rd_TO_CU_MEM) /= 0) and (ADDR_Rd_TO_CU_MEM = ADDR_Rs1_TO_CU)) and (ADDR_Rd_TO_CU_WB = ADDR_Rs1_TO_CU)) THEN
			SEL_MUX_A1 <= "00";
		END IF;
		if ((CONV_INTEGER(ADDR_Rd_TO_CU_WB) /= 0) and not((CONV_INTEGER(ADDR_Rd_TO_CU_MEM) /= 0) and (ADDR_Rd_TO_CU_MEM = ADDR_RS2_TO_CU)) and (ADDR_Rd_TO_CU_WB = ADDR_RS2_TO_CU)) THEN
			SEL_MUX_B1 <= "01";
		END IF;
	END PROCESS;
	
	
end Behavioral;

