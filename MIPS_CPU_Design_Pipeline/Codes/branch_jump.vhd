library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity branch_Jump is
    port(input_J                : in std_logic; 
input_PCPlus4          : in std_logic_vector(31 downto 0);
input_BNE              : in std_logic;
input_Instruc_25to0    : in std_logic_vector(25 downto 0);
input_JAL              : in std_logic;
input_Zeroutput_Flag        : in std_logic;
input_RD1              : in std_logic_vector(31 downto 0); 
input_JR               : in std_logic;
input_IMM              : in std_logic_vector(31 downto 0);
			 input_BEQ              : in std_logic;
          output_Binput_J_Address       : out std_logic_vector(31 downto 0);
          output_PCSrc            : out std_logic;
          output_BranchTaken      : out std_logic; 
          output_Branch           : out std_logic );  
end branch_Jump;

architecture structural of branch_Jump is
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

    component or2_1bit is
      port(input_A          : in std_logic;
           input_B          : in std_logic;
           output_F          : out std_logic);
    end component;

    component and2_1bit is
      port(input_A          : in std_logic;
           input_B          : in std_logic;
           output_F          : out std_logic);
    end component;

    component sel_input_BEQ_input_BNE is
        port( input_Zeroutput_Flag : in std_logic;
              input_SELect    : in std_logic_vector(1 downto 0);
              output_F         : out std_logic );
    end component;

    signal signal_Cout_IMM, signal_AND_Out, signal_OR_input_J, signal_OR_input_BEQinput_BNE, signal_sel_br_out : std_logic; 
    signal signal_AddIMM_Out, signal_Mux1_Out, signal_Mux2_Out, signal_Mux3_Out : std_logic_vector(31 downto 0);
    signal signal_IMM_Shift, signal_input_J_addr : std_logic_vector(31 downto 0);
    signal signal_i_Instruc_25to0_sl2 : std_logic_vector(27 downto 0);
    signal signal_input_BEQinput_BNE : std_logic_vector(1 downto 0);

begin

    signal_IMM_Shift <= input_IMM(29 downto 0) & "00";
    signal_input_BEQinput_BNE <= input_BEQ & input_BNE; 
    signal_i_Instruc_25to0_sl2 <= input_Instruc_25to0 & "00"; 
    signal_input_J_addr <= input_PCPlus4(31 downto 28) & signal_i_Instruc_25to0_sl2; 

    output_Binput_J_Address <= signal_Mux3_Out;
    output_PCSrc <= '1' when (input_BEQ = '1' or input_BNE = '1' or input_JAL = '1' or input_J = '1' or input_JR = '1') else
               '0';

    output_BranchTaken <= signal_AND_Out;
    output_Branch <= signal_OR_input_BEQinput_BNE;

    add_IMM: fulladder_32bit
        port map (input_PCPlus4, signal_IMM_Shift, '0', signal_Cout_IMM, signal_AddIMM_Out);

    mux1: mux2to1_32bit
        port map (input_PCPlus4, signal_AddIMM_Out, signal_AND_Out, signal_Mux1_Out);

    mux2: mux2to1_32bit
        port map (signal_Mux1_Out, signal_input_J_addr, signal_OR_input_J, signal_Mux2_Out);

    mux3: mux2to1_32bit
        port map (signal_Mux2_Out, input_RD1, input_JR, signal_Mux3_Out);

    or_input_BEQ_input_BNE: or2_1bit
        port map (input_BEQ, input_BNE, signal_OR_input_BEQinput_BNE);

    and_Z: and2_1bit
        port map (signal_OR_input_BEQinput_BNE, signal_sel_br_out, signal_AND_Out);

    selinput_BEQinput_BNE: sel_input_BEQ_input_BNE
        port map (input_Zeroutput_Flag, signal_input_BEQinput_BNE, signal_sel_br_out);

    or_input_J: or2_1bit
        port map (input_J, input_JAL, signal_OR_input_J);

end structural;
