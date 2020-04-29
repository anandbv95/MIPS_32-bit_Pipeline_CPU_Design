library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_fetch is
    port( input_Reset         : in std_logic;   
          input_Clock         : in std_logic;
          input_Stall_PC      : in std_logic;
          input_BranchJ_Addr  : in std_logic_vector(31 downto 0);
          input_Mux_Sel       : in std_logic;
          output_Instruction   : out std_logic_vector(31 downto 0);
          output_PCPlus4       : out std_logic_vector(31 downto 0) );
end instruction_fetch;

architecture structural of instruction_fetch is
    component register_32bit is
        port( input_CLK  : in std_logic;
              input_RST  : in std_logic;
              input_WD   : in std_logic_vector(31 downto 0);
              input_WE   : in std_logic;
              output_Q    : out std_logic_vector(31 downto 0) );
    end component;

    component mem is
    	generic ( DATA_WIDTH : natural := 32; ADDR_WIDTH : natural := 10 );
    	port ( clk	: in std_logic;
    		   addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
    		   data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
    		   we	: in std_logic := '1';
    		   q	: out std_logic_vector((DATA_WIDTH-1) downto 0) );
    end component;

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

    signal signal_Cout_PC4, signal_write_pc : std_logic; 
    signal signal_convert_addr : std_logic_vector(29 downto 0); 
    signal signal_PC_Out, signal_AddPC4_Out, signal_Four, signal_MemData_Placehold, signal_PC_WD : std_logic_vector(31 downto 0) := (others => '0');
    signal signal_convert_to_nat : natural range 0 to 2**10 - 1;

begin
    signal_Four <= (2 => '1', others => '0'); 
    signal_MemData_Placehold <= (others => '0'); 
    signal_convert_addr <= "00000000000000000000" & signal_PC_Out(11 downto 2); 
    signal_convert_to_nat <= to_integer(unsigned(signal_Convert_Addr)); 
    signal_write_pc <= not input_Stall_PC;
    output_PCPlus4 <= signal_AddPC4_Out;

    add_PC4: fulladder_32bit
        port map (signal_PC_Out, signal_Four, '0', signal_Cout_PC4, signal_AddPC4_Out);

    mux: mux2to1_32bit
        port map (signal_AddPC4_Out, input_BranchJ_Addr, input_Mux_Sel, signal_PC_WD);  

    pc: register_32bit
        port map (input_Clock, input_Reset, signal_PC_WD, signal_write_pc, signal_PC_Out);

    instruc_mem: mem
        port map (input_Clock, signal_convert_to_nat, signal_MemData_Placehold, '0', output_Instruction);

end structural;
