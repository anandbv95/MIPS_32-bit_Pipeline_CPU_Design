library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_ID_EX is
    port( input_Clock       : in std_logic;
          input_Reset       : in std_logic;   
          input_WR          : in std_logic_vector(4 downto 0);
			 input_MemRead     : in std_logic;
          input_Stall       : in std_logic;
          input_MemWrite    : in std_logic;
			 input_ALUOP       : in std_logic_vector(3 downto 0);
          input_PCPlus4     : in std_logic_vector(31 downto 0);
          input_JAL         : in std_logic;
          input_SHAMT       : in std_logic_vector(31 downto 0);
          input_RD1         : in std_logic_vector(31 downto 0);
          input_RD2         : in std_logic_vector(31 downto 0);
          input_IMM         : in std_logic_vector(31 downto 0);
          input_Instruction : in std_logic_vector(31 downto 0);
          input_RegWriteEn  : in std_logic;
          input_Sel_Mux2    : in std_logic; 
          input_Mem_To_Reg  : in std_logic;
          input_ALUSrc      : in std_logic;
			 input_Flush       : in std_logic; 
          output_MemRead     : out std_logic;
			 output_WR          : out std_logic_vector(4 downto 0);
          output_ALUOP       : out std_logic_vector(3 downto 0);
			 output_MemWrite    : out std_logic;
          output_PCPlus4     : out std_logic_vector(31 downto 0);
          output_SHAMT       : out std_logic_vector(31 downto 0);
          output_RD1         : out std_logic_vector(31 downto 0);
          output_RD2         : out std_logic_vector(31 downto 0);
          output_IMM         : out std_logic_vector(31 downto 0);
          output_RegWriteEn  : out std_logic;
          output_Instruction : out std_logic_vector(31 downto 0);
          output_Sel_Mux2    : out std_logic;
          output_Mem_To_Reg  : out std_logic;
                    output_JAL         : out std_logic;
          output_ALUSrc      : out std_logic );    
end register_ID_EX;   

architecture structural of register_ID_EX is

    component register_Nbit is
        generic ( N : integer := 208 );
        port ( input_CLK  : in std_logic;
               input_RST  : in std_logic;
               input_WD   : in std_logic_vector(N-1 downto 0);   
               input_WE   : in std_logic;                        
               output_Q    : out std_logic_vector(N-1 downto 0) ); 
    end component;

    
    signal signal_WD, signal_RD : std_logic_vector(207 downto 0);
    signal signal_stall_reg : std_logic;

begin

    signal_stall_reg <= not input_Stall;

    with input_Flush select signal_WD <=
        (others => '0') when '1',     
        (input_Instruction & input_MemRead & input_PCPlus4 & input_JAL & input_SHAMT & input_RD1 & input_RD2 & input_IMM & input_WR &
            input_RegWriteEn & input_ALUOP & input_Sel_Mux2 & input_Mem_To_Reg &
            input_MemWrite & input_ALUSrc) when '0',          
        (others => '0') when others;  

    reg: register_Nbit
        port map (input_Clock, input_Reset, signal_WD, signal_stall_reg, signal_RD);

    output_Instruction <= signal_RD(207 downto 176);
    output_MemRead <= signal_RD(175);
    output_PCPlus4 <= signal_RD(174 downto 143);
    output_JAL <= signal_RD(142);
    output_SHAMT <= signal_RD(141 downto 110);
    output_RD1 <= signal_RD(109 downto 78);
    output_RD2 <= signal_RD(77 downto 46);
    output_IMM <= signal_RD(45 downto 14);
    output_WR  <= signal_RD(13 downto 9);
    output_RegWriteEn <= signal_RD(8);
    output_ALUOP      <= signal_RD(7 downto 4);
	 output_ALUSrc     <= signal_RD(0);
    output_MemWrite   <= signal_RD(1);
    output_Mem_To_Reg <= signal_RD(2);
    output_Sel_Mux2   <= signal_RD(3);
    end structural;
