
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_EX_MEM is
    port( input_Clock       : in std_logic;
	       input_Reset       : in std_logic; 
          input_MemWrite    : in std_logic; 
          input_JAL         : in std_logic;
			 input_PCPlus4     : in std_logic_vector(31 downto 0);
          input_Flush       : in std_logic;
          input_Stall       : in std_logic;
          input_ALUOut      : in std_logic_vector(31 downto 0);
          input_RD2         : in std_logic_vector(31 downto 0);
          input_WR          : in std_logic_vector(4 downto 0);
          input_Mem_To_Reg  : in std_logic;
          input_RegWriteEn  : in std_logic;
          input_Instruction : in std_logic_vector(31 downto 0);
          output_Instruction : out std_logic_vector(31 downto 0);
          output_PCPlus4     : out std_logic_vector(31 downto 0);
          output_ALUOut      : out std_logic_vector(31 downto 0);
          output_RD2         : out std_logic_vector(31 downto 0);
          output_Mem_To_Reg  : out std_logic;
          output_JAL         : out std_logic;			 
          output_MemWrite    : out std_logic;
          output_WR          : out std_logic_vector(4 downto 0);			 
			 output_RegWriteEn  : out std_logic );
end register_EX_MEM;

architecture structural of register_EX_MEM is

    component register_Nbit is
        generic ( N : integer := 137 );
        port ( input_CLK  : in std_logic;
               input_RST  : in std_logic;
		         input_WD   : in std_logic_vector(N-1 downto 0);
					input_WE   : in std_logic; 
		         output_Q    : out std_logic_vector(N-1 downto 0) ); 
    end component;

    signal signal_stall_reg : std_logic;
    signal signal_WD, signal_RD : std_logic_vector(136 downto 0);
    
	 begin

    signal_stall_reg <= not input_Stall;

    with input_Flush select signal_WD <=
        (others => '0') when '1',     
        (input_Instruction & input_PCPlus4 & input_JAL & input_ALUOut & input_RD2 & input_WR & input_Mem_To_Reg & input_MemWrite & input_RegWriteEn) when '0',
        (others => '0') when others;  

    reg: register_Nbit
        port map (input_Clock, input_Reset, signal_WD, signal_stall_reg, signal_RD);

    output_Instruction <= signal_RD(136 downto 105);  
    output_JAL <= signal_RD(72);
    output_PCPlus4 <= signal_RD(104 downto 73);
    output_RD2 <= signal_RD(39 downto 8); 
	 output_RegWriteEn <= signal_RD(0);
	 output_MemWrite <= signal_RD(1);
    output_Mem_To_Reg <= signal_RD(2);
    output_WR <= signal_RD(7 downto 3);
	     output_ALUOut <= signal_RD(71 downto 40);
end structural;
