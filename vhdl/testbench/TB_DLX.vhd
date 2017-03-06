library IEEE;
use IEEE.std_logic_1164.all;
use WORK.GLOBALS.all; -- ALU TYPE AND CONSTANTS

entity tb_dlx is
end tb_dlx;

architecture TEST of tb_dlx is


    constant NumBit32      : integer := 32;       
    constant Bit_Addr_Ram  : integer := 11;       
    
    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';

  -- Data Ram Bus signals
  SIGNAL s_DRAM_DATAIN : std_logic_vector(NumBit32 - 1 downto 0); 
  SIGNAL s_DRAM_ADDR  : std_logic_vector(Bit_Addr_Ram - 1 downto 0); -- ADDRESS WHERE READ/WRITE
  SIGNAL s_DRAM_DATAOUT  : std_logic_vector(NumBit32 - 1 downto 0); -- DATA TO READ
  SIGNAL s_DRAM_EN_RD  : std_logic; -- READ ENABLE
  SIGNAL s_DRAM_EN_WR  : std_logic; -- WRITE ENABLE

  -- Instruction Ram Bus signals
  SIGNAL s_PC_TO_IRAM : std_logic_vector(NumBit32 - 1 downto 0); -- PC_SIZE = IR_SIZE
  SIGNAL s_IRAM_TO_DLX : std_logic_vector(NumBit32 - 1 downto 0); -- PC_SIZE = IR_SIZE

    component DLX
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
    end component;

  --Instruction Ram
  component IRAM
    	port (
      		Rst  : in  std_logic;
      		Addr : in  std_logic_vector(NumBit32 - 1 downto 0);
      		Dout : out std_logic_vector(NumBit32 - 1 downto 0));
  end component;

  -- Data Ram
   COMPONENT DATA_RAM 
 	generic( 
		nBit: integer:=32;
          	nWords: integer:=2048 ); -- E' UNA RAM DI 32 PAROLE   
 	port ( 	
			CLK: 		IN std_logic;
			RESET: 	IN std_logic;
			EN_RD: IN STD_LOGIC;
			EN_WR: 		IN std_logic;
			ADDR: 	 IN std_logic_vector(Bit_Addr_Ram - 1 downto 0); 
			DATAIN: 	IN std_logic_vector(nbit-1 downto 0);
			DATAOUT: 		OUT std_logic_vector(nbit-1 downto 0)
	);
  END COMPONENT;

begin


    -- Instruction Ram Instantiation
    IRAM_I: IRAM
      port map (
        Rst  => RESET,
        Addr => s_PC_TO_IRAM,
        Dout => s_IRAM_TO_DLX);
          
    -- Data Ram Instantiation      
    DRAM_I: DATA_RAM 
    generic MAP( NumBit32, 1024) 
    port MAP( 
	Clock,
        Reset,
	s_DRAM_EN_RD,
	s_DRAM_EN_WR,
	s_DRAM_ADDR,
	s_DRAM_DATAIN,
	s_DRAM_DATAOUT
              );

    -- instance of DLX
	U1: DLX
	Port Map (Clock, Reset, s_DRAM_DATAIN, s_DRAM_ADDR, s_DRAM_DATAOUT, s_DRAM_EN_RD, s_DRAM_EN_WR, s_PC_TO_IRAM, s_IRAM_TO_DLX);


   PCLOCK : process(Clock)
	begin
		Clock <= not(Clock) after 0.5 ns;	
	end process;
	
	Reset <= '0', '1' after 5.5 ns;--, '0' after 11 ns, '1' after 15 ns;
       

end TEST;

