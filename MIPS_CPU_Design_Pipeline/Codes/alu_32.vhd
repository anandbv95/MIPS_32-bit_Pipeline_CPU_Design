library IEEE;
use IEEE.std_logic_1164.all;

entity alu_32bit is
        port( input_A        : in  std_logic_vector(31 downto 0);  
              input_B        : in  std_logic_vector(31 downto 0); 
              input_ALUOP    : in  std_logic_vector(3  downto 0); 
              output_CarryOut : out std_logic;                                                     
              output_F        : out std_logic_vector(31 downto 0)				  
          );                   
end alu_32bit;

architecture structure of alu_32bit is
    component and2_32bit is
        port( input_A : in  std_logic_vector(31 downto 0);
              input_B : in  std_logic_vector(31 downto 0);
              output_F : out std_logic_vector(31 downto 0));
    end component;

    component or2_32bit is
        port( input_A : in  std_logic_vector(31 downto 0);
              input_B : in  std_logic_vector(31 downto 0);
              output_F : out std_logic_vector(31 downto 0));
    end component;

    component addsub_32bit is
        port( input_A         : in std_logic_vector(31 downto 0);
              input_B         : in std_logic_vector(31 downto 0);
              input_nAdd_Sub  : in std_logic;
              output_Cout      : out std_logic;
              output_S         : out std_logic_vector(31 downto 0) );
    end component;

    component slt_32bit is
        port( input_SubF    : in std_logic_vector(31 downto 0); 
              input_OVF     : in std_logic; 
              output_F       : out std_logic_vector(31 downto 0) );
    end component;


    component nor2_32bit is
        port( input_A : in  std_logic_vector(31 downto 0);
              input_B : in  std_logic_vector(31 downto 0);
              output_F : out std_logic_vector(31 downto 0));
    end component;

    component xor2_32bit is
        port( input_A : in  std_logic_vector(31 downto 0);
              input_B : in  std_logic_vector(31 downto 0);
              output_F : out std_logic_vector(31 downto 0));
    end component;

    component mux7to1_32bit is
        port( input_SEL : in std_logic_vector(3 downto 0); 
              input_0   : in std_logic_vector(31 downto 0); 
              input_1   : in std_logic_vector(31 downto 0);
              input_2   : in std_logic_vector(31 downto 0);
              input_3   : in std_logic_vector(31 downto 0);
              input_4   : in std_logic_vector(31 downto 0);
              input_5   : in std_logic_vector(31 downto 0);
              input_6   : in std_logic_vector(31 downto 0);
              output_F   : out std_logic_vector(31 downto 0) ); 
    end component;

    
    signal mux0_in, mux1_in, mux2_in, mux3_in, mux4_in, mux5_in, mux6_in
        : std_logic_vector(31 downto 0);

    signal signal_F : std_logic_vector(31 downto 0);  

    signal signal_ovf, signal_zero, signal_carry : std_logic; 

begin

    AND_OP: and2_32bit
        port map (input_A, input_B, mux0_in);

    OR_OP: or2_32bit
        port map (input_A, input_B, mux1_in);

    ARITH_OP: addsub_32bit
        port map (input_A, input_B, input_ALUOP(2), signal_carry, mux2_in);

 

    SLT_OP: slt_32bit
        port map (mux2_in, signal_ovf, mux3_in);

    NOR_OP: nor2_32bit
        port map (input_A, input_B, mux5_in);

    XOR_OP: xor2_32bit
        port map (input_A, input_B, mux6_in);

    SELECT_OPERATION: mux7to1_32bit
        port map (input_ALUOP, mux0_in, mux1_in, mux2_in, mux3_in, mux4_in, mux5_in, mux6_in,
            signal_F);

    
 
    output_CarryOut <= signal_carry;

end structure;
