library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_ARITH.all;

package GLOBALS is

constant NumBitRCA 	: integer := 4;
constant NumBit32 	: integer := 32;
constant levels_gen : integer := 5;
constant NumBitAddr : integer := 5;
constant Alu_op_bit : integer := 5;
constant Bit_Addr_Ram : integer := 11 ; 

constant Shift_mul : integer := 2;  


--ALU OPERATIONS-----------------------
constant F_ADD 	: std_logic_vector 	:= "00000";
constant F_SUB 	: std_logic_vector 	:= "00001";
constant F_MULT 	: std_logic_vector 	:= "00010";
constant F_AND 	: std_logic_vector 	:= "00011";
constant F_OR 		: std_logic_vector 	:= "00100";
constant F_XOR 	: std_logic_vector 	:= "00101";
constant F_SLL 	: std_logic_vector 	:= "00110";
constant F_SRL 	: std_logic_vector 	:= "00111";
constant F_SRA 	: std_logic_vector 	:= "01000";
constant F_SEQ 	: std_logic_vector 	:= "01001";
constant F_SEQU 	: std_logic_vector 	:= "01010";
constant F_SNE 	: std_logic_vector 	:= "01011";
constant F_SLT 	: std_logic_vector 	:= "01100";
constant F_SGT 	: std_logic_vector 	:= "01101";
constant F_SLE 	: std_logic_vector 	:= "01110";
constant F_SGE 	: std_logic_vector 	:= "01111";
constant F_SLTU 	: std_logic_vector	:= "10000";
constant F_SGTU 	: std_logic_vector	:= "10001";
constant F_SLEU 	: std_logic_vector 	:= "10010";
constant F_SGEU 	: std_logic_vector 	:= "10011";
constant F_JAL 	: std_logic_vector 	:= "10100";
constant F_LHI 	: std_logic_vector 	:= "10101";
constant NOP 		: std_logic_vector 	:= "10110";
constant F_JALR 	: std_logic_vector 	:= "10111";
-------------------------------------------------------------------------------------

-- Control unit input sizes
constant OP_CODE_SIZE_GLOBALS : integer :=  6;                                              -- OPCODE field size
constant FUNC_SIZE_GLOBALS    : integer :=  11;                                             -- FUNC field size
constant MICROCODE_MEM_SIZE_GLOBALS : integer := 62;										-- MEM field size	
constant CW_SIZE_GLOBALS : integer := 21;
constant CW_SIZE2 : integer := 10;
constant CW_SIZE3 : integer := 5;
constant CW_SIZE4: integer := 2;													-- OUTPUT field size
constant ALU_OPC_SIZE_GLOBALS : integer := Alu_op_bit;


constant LEFT	: std_logic := '1';
constant RIGHT	: std_logic := '0';
constant LOGIC	: std_logic := '1';
constant ARITH	: std_logic := '0';
constant SHIFT	: std_logic := '1';
constant ROT	: std_logic := '0';
	
constant BIT_MUL : INTEGER := 16;


constant FTYPE		 : INTEGER := 1;	-- USED ONLY FOR MULT
constant F_TYPE_MULT : INTEGER := 14;

-- R-Type instruction -> FUNC field
constant RTYPE_SLL     : INTEGER :=  4;
constant RTYPE_SRL     : INTEGER :=  6;
constant RTYPE_SRA     : INTEGER :=  7;
constant RTYPE_ADD     : INTEGER :=  32; 

constant RTYPE_ADDU    : INTEGER :=  33;
constant RTYPE_SUB     : INTEGER :=  34;
constant RTYPE_SUBU    : INTEGER :=  35;
constant RTYPE_AND     : INTEGER :=  36;

constant RTYPE_OR      : INTEGER :=  37;
constant RTYPE_XOR     : INTEGER :=  38;
constant RTYPE_SEQ     : INTEGER :=  40;
constant RTYPE_SNE     : INTEGER :=  41; 

constant RTYPE_SLT     : INTEGER :=  42;
constant RTYPE_SGT     : INTEGER :=  43;
constant RTYPE_SLE     : INTEGER :=  44;
constant RTYPE_SGE     : INTEGER :=  45; 
	  
constant RTYPE_SLTU    : INTEGER :=  58;
constant RTYPE_SGTU    : INTEGER :=  59;
constant RTYPE_SLEU    : INTEGER :=  60;
constant RTYPE_SGEU    : INTEGER :=  61; 

constant RTYPE_MULT    : INTEGER :=  14;

-- R-Type instruction -> OPCODE field
constant RTYPE : INTEGER := 0;      -- register-to-register operation
	
	
-- GENERAL instruction -> OPCODE field
constant TYPE_J     : INTEGER :=  2; 
constant TYPE_JAL   : INTEGER :=  3; 
constant TYPE_BEQZ  : INTEGER :=  4; 
constant TYPE_BNEZ  : INTEGER :=  5; 

constant TYPE_ADDI  : INTEGER :=  8; 
constant TYPE_ADDUI : INTEGER :=  9;

constant TYPE_SUBI  : INTEGER :=  10; 
constant TYPE_SUBUI : INTEGER :=  11; 
constant TYPE_ANDI  : INTEGER :=  12; 
constant TYPE_ORI   : INTEGER :=  13; 

constant TYPE_XORI  : INTEGER :=  14; 
constant TYPE_LHI   : INTEGER :=  15; 


constant TYPE_JR    : INTEGER :=  18; 
constant TYPE_JALR  : INTEGER :=  19; 
constant TYPE_SLLI  : INTEGER :=  20;
constant TYPE_NOP   : INTEGER :=  21;
 
constant TYPE_SRLI  : INTEGER :=  22; 
constant TYPE_SRAI  : INTEGER :=  23; 
constant TYPE_SEQI  : INTEGER :=  24;
constant TYPE_SNEI  : INTEGER :=  25; 

constant TYPE_SLTI  : INTEGER :=  26; 
constant TYPE_SGTI  : INTEGER :=  27; 
constant TYPE_SLEI  : INTEGER :=  28;
constant TYPE_SGEI  : INTEGER :=  29; 
constant TYPE_LW    : INTEGER :=  35;
constant TYPE_SW    : INTEGER :=  43;

constant TYPE_SLTUI : INTEGER :=  58;
constant TYPE_SGTUI : INTEGER :=  59; 
constant TYPE_SLEUI : INTEGER :=  60; 

constant TYPE_SGEUI : INTEGER :=  61; 

end GLOBALS;
