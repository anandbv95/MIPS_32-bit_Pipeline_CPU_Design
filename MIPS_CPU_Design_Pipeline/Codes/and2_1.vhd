library IEEE;
use IEEE.std_logic_1164.all;

entity and2_1 is
  port(input_A          : in std_logic;
       input_B          : in std_logic;
       output_F          : out std_logic);    
end and2_1;

architecture dataflow of and2_1bit is
begin

  output_F <= input_A and input_B;

end dataflow;
