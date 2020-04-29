library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity writeback is
    port( input_Reset       : in std_logic;     
          input_Clock       : in std_logic;  
          input_JAL         : in std_logic;
          input_WR          : in std_logic_vector(4 downto 0);
          input_Mem_To_Reg  : in std_logic;
          input_MemOut      : in std_logic_vector(31 downto 0);
			 input_PCPlus4     : in std_logic_vector(31 downto 0);
			 input_ALUOut      : in std_logic_vector(31 downto 0);
			 input_RegWriteEn  : in std_logic;
			 output_WR          : out std_logic_vector(4 downto 0);
          output_RegWriteEn  : out std_logic;   
          output_WD          : out std_logic_vector(31 downto 0);
          output_JAL         : out std_logic );
end writeback;

architecture structural of writeback is

    component fulladder_32bit is
        port( input_A    : in std_logic_vector(31 downto 0);
              input_B    : in std_logic_vector(31 downto 0);
              input_Cin  : in std_logic;
              output_Cout : out std_logic;
              output_S    : out std_logic_vector(31 downto 0) );
    end component;


    component mux2to1_32bit is
        port( input_X   : in std_logic_vector(31 downto 0);
              input_Y   : in std_logic_vector(31 downto 0);
              input_SEL : in std_logic;
              output_OUT   : out std_logic_vector(31 downto 0) );
    end component;

    signal signal_mux_mem_out, signal_mux_wb_out : std_logic_vector(31 downto 0);

begin
    output_JAL <= input_JAL;
	 output_RegWriteEn <= input_RegWriteEn;
    output_WD <= signal_mux_wb_out;
    output_WR <= input_WR;
    mux_mem: mux2to1_32bit
        port map(input_ALUOut, input_MemOut, input_Mem_To_Reg, signal_mux_mem_out);

    mux_wb_final: mux2to1_32bit
        port map(signal_mux_mem_out, input_PCPlus4, input_JAL, signal_mux_wb_out);

end structural;
