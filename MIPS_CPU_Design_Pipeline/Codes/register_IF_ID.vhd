library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_IF_ID is
    port( 
	      input_Clock       : in std_logic;
        input_Reset       : in std_logic;
           input_Flush       : in std_logic;
          input_Stall       : in std_logic; 
          input_Instruction : in std_logic_vector(31 downto 0);
          input_PCPlus4     : in std_logic_vector(31 downto 0);
          output_PCPlus4     : out std_logic_vector(31 downto 0);
			 output_Instruction : out std_logic_vector(31 downto 0));
end register_IF_ID;

architecture structural of register_IF_ID is

    component register_Nbit is
        generic ( N : integer := 64 );
        port ( input_CLK  : in std_logic;
               input_RST  : in std_logic;
               input_WD   : in std_logic_vector(N-1 downto 0);    
               input_WE   : in std_logic;                       
               output_Q    : out std_logic_vector(N-1 downto 0) ); 
    end component;

    
    signal signal_WD, signal_RD : std_logic_vector(63 downto 0);
    signal signal_stall_reg : std_logic;

begin

    signal_stall_reg <= not input_Stall;

    with input_Flush select signal_WD <=
        (others => '0') when '1',   
        (input_Instruction & input_PCPlus4) when '0',            
        (others => '0') when others;  

    reg: register_Nbit
        port map (input_Clock, input_Reset, signal_WD, signal_stall_reg, signal_RD);

    output_Instruction <= signal_RD(63 downto 32);
    output_PCPlus4 <= signal_RD(31 downto 0);

end structural;
