library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_MEM_WB is
    port( input_Clock       : in std_logic;
	       input_Reset       : in std_logic;
          input_Mem_To_Reg  : in std_logic;			 
          input_JAL         : in std_logic;
          input_Flush       : in std_logic;
          input_WR          : in std_logic_vector(4 downto 0);			 
          input_Stall       : in std_logic;
          input_PCPlus4     : in std_logic_vector(31 downto 0);
          input_MemOut      : in std_logic_vector(31 downto 0);
          input_ALUOut      : in std_logic_vector(31 downto 0);
          input_RegWriteEn  : in std_logic;
          output_RegWriteEn  : out std_logic;
          output_ALUOut      : out std_logic_vector(31 downto 0);
          output_JAL         : out std_logic;
          output_PCPlus4     : out std_logic_vector(31 downto 0);
          output_MemOut      : out std_logic_vector(31 downto 0); 
          output_WR          : out std_logic_vector(4 downto 0);
          output_Mem_To_Reg  : out std_logic);
          end register_MEM_WB;
			 
architecture structural of register_MEM_WB is    
    component register_Nbit is
        generic ( N : integer := 104 );
        port ( input_CLK  : in std_logic;
               input_RST  : in std_logic;
               input_WD   : in std_logic_vector(N-1 downto 0);
               input_WE   : in std_logic;
               output_Q    : out std_logic_vector(N-1 downto 0) );
    end component;

    
    signal signal_WD, signal_RD : std_logic_vector(103 downto 0);   
    signal signal_stall_reg : std_logic;

begin

    signal_stall_reg <= not input_Stall;

    with input_Flush select signal_WD <=
        (others => '0') when '1',    
        (input_PCPlus4 & input_JAL & input_ALUOut & input_WR & input_Mem_To_Reg & input_RegWriteEn & input_MemOut) when '0',            -- updates the register as usual
        (others => '0') when others; 

    reg: register_Nbit
        port map (input_Clock, input_Reset, signal_WD, signal_stall_reg, signal_RD);
    output_ALUOut <= signal_RD(70 downto 39);
    output_JAL <= signal_RD(71);
	 output_MemOut <= signal_RD(31 downto 0);
	 output_RegWriteEn <= signal_RD(32);
	 output_Mem_To_Reg <= signal_RD(33);
    output_WR <= signal_RD(38 downto 34);
	 output_PCPlus4 <= signal_RD(103 downto 72);
end structural;
