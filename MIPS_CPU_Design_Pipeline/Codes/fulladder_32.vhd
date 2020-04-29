library IEEE;
use IEEE.std_logic_1164.all;

entity fulladder_32 is
    port( input_A    : in std_logic_vector(31 downto 0);
          input_B    : in std_logic_vector(31 downto 0);
          input_Cin  : in std_logic;
          output_Cout : out std_logic;
          output_S    : out std_logic_vector(31 downto 0) );
end fulladder_32;

architecture structure of fulladder_32 is
    component or2_1bit
        port( input_A          : in std_logic;
              input_B          : in std_logic;
              output_F          : out std_logic );
    end component;

    component and2_1bit
        port( input_A          : in std_logic;
              input_B          : in std_logic;
              output_F          : out std_logic );
    end component;

    component xor2_1bit is
        port(input_A          : in std_logic;
             input_B          : in std_logic;
             output_F          : out std_logic);
    end component;

    
    signal signal_XOR_ab, signal_AND_ab, signal_AND_nextand : std_logic_vector(31 downto 0);
    signal signal_Carry : std_logic_vector(32 downto 0); 

begin
signal_Carry(0) <= input_Cin;
output_Cout <= signal_Carry(32);

GENFOR: for i in 0 to 31 generate
    ab_xor: xor2_1bit
        port map ( input_A => input_A(i),
                   input_B => input_B(i),
                   output_F => signal_XOR_ab(i) );

    ab_and: and2_1bit
        port map ( input_A => input_A(i),
                   input_B => input_B(i),
                   output_F => signal_AND_ab(i) );

    nextand: and2_1bit
        port map ( input_A => signal_XOR_ab(i),
                   input_B => signal_Carry(i),
                   output_F => signal_AND_nextand(i) );

    or_fin: or2_1bit
        port map ( input_A => signal_AND_nextand(i),
                   input_B => signal_AND_ab(i),
                   output_F => signal_Carry(i+1) );
    xor_fin: xor2_1bit
        port map ( input_A => signal_XOR_ab(i),
                   input_B => signal_Carry(i),
                   output_F => output_S(i) );
end generate;

end structure;
