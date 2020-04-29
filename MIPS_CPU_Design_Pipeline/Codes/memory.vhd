library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    port( input_Reset       : in std_logic;         
      	 input_Clock       : in std_logic;
          input_ALUOut      : in std_logic_vector(31 downto 0);
          input_WR          : in std_logic_vector(4 downto 0);
          input_Mem_To_Reg  : in std_logic;
          input_RegWriteEn  : in std_logic;
			 input_RD2         : in std_logic_vector(31 downto 0);
          input_MemWrite    : in std_logic;
			 input_PCPlus4     : in std_Logic_vector(31 downto 0);
			 input_JAL         : in std_logic;
          output_PCPlus4     : out std_logic_vector(31 downto 0);       
          output_WR          : out std_logic_vector(4 downto 0);
          output_Mem_To_Reg  : out std_logic;
          output_RegWriteEn  : out std_logic;
			 output_JAL         : out std_logic;
			 output_ALUOut      : out std_logic_vector(31 downto 0);
          output_MemOut      : out std_logic_vector(31 downto 0) );
end memory;

architecture structural of memory is
    component mem is
    	generic ( DATA_WIDTH : natural := 32; ADDR_WIDTH : natural := 10 );
    	port ( clk	: in std_logic;
    		   addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
    		   data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
    		   we	: in std_logic := '1';
    		   q	: out std_logic_vector((DATA_WIDTH-1) downto 0) );
    end component;

    signal signal_dmem_out : std_logic_vector(31 downto 0);    
    signal signal_dmem_addr : natural range 0 to 2**10 - 1;

begin
    output_PCPlus4 <= input_PCPlus4;
     output_WR <= input_WR;
    output_Mem_To_Reg <= input_Mem_To_Reg;    
    output_RegWriteEn <= input_RegWriteEn;
    output_MemOut <= signal_dmem_out;
	 output_JAL <= input_JAL;
	 output_ALUOut <= input_ALUOut;


    signal_dmem_addr <= to_integer(unsigned(input_ALUOut(11 downto 2)));

    data_mem: mem
        port map(input_Clock, signal_dmem_addr, input_RD2, input_MemWrite, signal_dmem_out);

end structural;
