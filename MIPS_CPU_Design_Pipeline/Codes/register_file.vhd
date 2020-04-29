library IEEE;
use IEEE.std_logic_1164.all;

entity register_file is
    port( input_CLK       : in std_logic;                       
          input_RST       : in std_logic;                      
          input_WR        : in std_logic_vector(4 downto 0);      
          input_WD        : in std_logic_vector(31 downto 0);    
          input_REGWRITE  : in std_logic;                         
          input_RR1       : in std_logic_vector(4 downto 0);      
          input_RR2       : in std_logic_vector(4 downto 0);    
          output_RD1       : out std_logic_vector(31 downto 0);    
          output_RD2       : out std_logic_vector(31 downto 0) );  
end register_file;

architecture structure of register_file is
  
    component register_32bit_rf
        port( input_CLK  : in std_logic;
              input_RST  : in std_logic;
              input_WD   : in std_logic_vector(31 downto 0);   
              input_WE   : in std_logic;                         
              output_Q    : out std_logic_vector(31 downto 0) ); 
    end component;

    component decode_5to32bit
        port( input_D : in std_logic_vector(4 downto 0);
              output_F : out std_logic_vector(31 downto 0) );
    end component;

    component mux32to1_32bit is
        port( input_SEL : in std_logic_vector(4 downto 0); 
              input_0   : in std_logic_vector(31 downto 0); 
              input_1   : in std_logic_vector(31 downto 0);
              input_2   : in std_logic_vector(31 downto 0);
              input_3   : in std_logic_vector(31 downto 0);
              input_4   : in std_logic_vector(31 downto 0);
              input_5   : in std_logic_vector(31 downto 0);
              input_6   : in std_logic_vector(31 downto 0);
              input_7   : in std_logic_vector(31 downto 0);
              input_8   : in std_logic_vector(31 downto 0);
              input_9   : in std_logic_vector(31 downto 0);
              input_10  : in std_logic_vector(31 downto 0);
              input_11  : in std_logic_vector(31 downto 0);
              input_12  : in std_logic_vector(31 downto 0);
              input_13  : in std_logic_vector(31 downto 0);
              input_14  : in std_logic_vector(31 downto 0);
              input_15  : in std_logic_vector(31 downto 0);
              input_16  : in std_logic_vector(31 downto 0);
              input_17  : in std_logic_vector(31 downto 0);
              input_18  : in std_logic_vector(31 downto 0);
              input_19  : in std_logic_vector(31 downto 0);
              input_20  : in std_logic_vector(31 downto 0);
              input_21  : in std_logic_vector(31 downto 0);
              input_22  : in std_logic_vector(31 downto 0);
              input_23  : in std_logic_vector(31 downto 0);
              input_24  : in std_logic_vector(31 downto 0);
              input_25  : in std_logic_vector(31 downto 0);
              input_26  : in std_logic_vector(31 downto 0);
              input_27  : in std_logic_vector(31 downto 0);
              input_28  : in std_logic_vector(31 downto 0);
              input_29  : in std_logic_vector(31 downto 0);
              input_30  : in std_logic_vector(31 downto 0);
              input_31  : in std_logic_vector(31 downto 0);
              output_F   : out std_logic_vector(31 downto 0) );  
    end component;

    component and2_1bit is
      port(input_A          : in std_logic;
           input_B          : in std_logic;
           output_F          : out std_logic);
    end component;

signal signal_decoded : std_logic_vector(31 downto 0);
signal signal_write : std_logic_vector(31 downto 0);

type vector32 is array (natural range<>) of std_logic_vector(31 downto 0); 
signal signal_register_data: vector32(31 downto 0);

begin

decode_WR: decode_5to32bit
    port map(input_WR, signal_decoded);

generate_registers: for i in 1 to 31 generate 
    do_write: and2_1bit
        port map(signal_decoded(i), input_REGWRITE, signal_write(i));   
    reg: register_32bit_rf
        port map(input_CLK, input_RST, input_WD, signal_write(i), signal_register_data(i));
end generate;

reg_0: register_32bit_rf  
    port map(input_CLK, '1', (others => '0'), '0', signal_register_data(0)); 


mux_RD1: mux32to1_32bit
    port map ( input_SEL => input_RR1, 
          input_0   => signal_register_data(0), 
          input_1   => signal_register_data(1),
          input_2   => signal_register_data(2),
          input_3   => signal_register_data(3),
          input_4   => signal_register_data(4),
          input_5   => signal_register_data(5),
          input_6   => signal_register_data(6),
          input_7   => signal_register_data(7),
          input_8   => signal_register_data(8),
          input_9   => signal_register_data(9),
          input_10  => signal_register_data(10),
          input_11  => signal_register_data(11),
          input_12  => signal_register_data(12),
          input_13  => signal_register_data(13),
          input_14  => signal_register_data(14),
          input_15  => signal_register_data(15),
          input_16  => signal_register_data(16),
          input_17  => signal_register_data(17),
          input_18  => signal_register_data(18),
          input_19  => signal_register_data(19),
          input_20  => signal_register_data(20),
          input_21  => signal_register_data(21),
          input_22  => signal_register_data(22),
          input_23  => signal_register_data(23),
          input_24  => signal_register_data(24),
          input_25  => signal_register_data(25),
          input_26  => signal_register_data(26),
          input_27  => signal_register_data(27),
          input_28  => signal_register_data(28),
          input_29  => signal_register_data(29),
          input_30  => signal_register_data(30),
          input_31  => signal_register_data(31),
          output_F   => output_RD1 );     

mux_RD2: mux32to1_32bit
    port map ( input_SEL => input_RR2, 
          input_0   => signal_register_data(0),
          input_1   => signal_register_data(1),
          input_2   => signal_register_data(2),
          input_3   => signal_register_data(3),
          input_4   => signal_register_data(4),
          input_5   => signal_register_data(5),
          input_6   => signal_register_data(6),
          input_7   => signal_register_data(7),
          input_8   => signal_register_data(8),
          input_9   => signal_register_data(9),
          input_10  => signal_register_data(10),
          input_11  => signal_register_data(11),
          input_12  => signal_register_data(12),
          input_13  => signal_register_data(13),
          input_14  => signal_register_data(14),
          input_15  => signal_register_data(15),
          input_16  => signal_register_data(16),
          input_17  => signal_register_data(17),
          input_18  => signal_register_data(18),
          input_19  => signal_register_data(19),
          input_20  => signal_register_data(20),
          input_21  => signal_register_data(21),
          input_22  => signal_register_data(22),
          input_23  => signal_register_data(23),
          input_24  => signal_register_data(24),
          input_25  => signal_register_data(25),
          input_26  => signal_register_data(26),
          input_27  => signal_register_data(27),
          input_28  => signal_register_data(28),
          input_29  => signal_register_data(29),   
          input_30  => signal_register_data(30),
          input_31  => signal_register_data(31),
          output_F   => output_RD2 );   

end structure;
