library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity execution is   
    port( input_Reset              : in std_logic;
          input_Clock              : in std_logic;
          input_WB_Data            : in std_logic_vector(31 downto 0);
          input_Branch             : in std_logic;
          input_EXMEM_RegWriteEn   : in std_logic;
          input_MEMWB_RegWriteEn   : in std_logic;
          input_EXMEM_WriteReg     : in std_logic_vector(4 downto 0);
          input_MEMWB_WriteReg     : in std_logic_vector(4 downto 0);
          input_IFID_RS            : in std_logic_vector(4 downto 0);
          input_IDEX_RS            : in std_logic_vector(4 downto 0);
          input_IFID_RT            : in std_logic_vector(4 downto 0);
          input_IDEX_RT            : in std_logic_vector(4 downto 0);
          input_EXMEM_RT           : in std_logic_vector(4 downto 0);
          input_PCPlus4            : in std_logic_vector(31 downto 0);
          input_JAL                : in std_logic;
			 input_JR                 : in std_logic;
          input_MemRead            : in std_logic;
			 input_EXMEM_ALUOut       : in std_logic_vector(31 downto 0);
          input_RD1                : in std_logic_vector(31 downto 0);
          input_RD2                : in std_logic_vector(31 downto 0);
          input_IMM                : in std_logic_vector(31 downto 0);
          input_SHAMT              : in std_Logic_vector(31 downto 0);
          input_WR                 : in std_logic_vector(4 downto 0);
          input_RegWriteEn         : in std_logic;
          input_ALUOP              : in std_logic_vector(3 downto 0);
          input_Sel_Mux2           : in std_logic;
          input_Mem_To_Reg         : in std_logic;
          input_MemWrite           : in std_logic;
          input_ALUSrc             : in std_logic;
          input_Instruction        : in std_logic_vector(31 downto 0);
          output_Instruction        : out std_logic_vector(31 downto 0);
          output_PCPlus4            : out std_logic_vector(31 downto 0);
          output_JAL                : out std_logic;
          output_ALUOut             : out std_logic_vector(31 downto 0);  
          output_RD2                : out std_logic_vector(31 downto 0);
          output_WR                 : out std_logic_vector(4 downto 0);
          output_Mem_To_Reg         : out std_logic;
          output_MemWrite           : out std_logic;
          output_RegWriteEn         : out std_logic;
          output_OVF                : out std_logic;
          output_ZF                 : out std_logic;
          output_CF                 : out std_logic;
          output_Forward_RS_Sel1    : out std_logic;
          output_Forward_RS_Sel2    : out std_logic;
          output_Forward_RT_Sel1    : out std_logic;
          output_Forward_RT_Sel2    : out std_logic );
end execution;

architecture structural of execution is
    component sel_alu_a is
        port( input_ALUSrc   : in std_logic;
              input_RD1      : in std_logic_vector(31 downto 0);
              input_ALUOP    : in std_logic_vector(3 downto 0);
              input_shamt    : in std_logic_vector(31 downto 0);
              input_mux2_sel : in std_logic;
              output_data     : out std_logic_vector(31 downto 0) );
    end component;  

    component alu_32bit is
            port( input_A        : in  std_logic_vector(31 downto 0);
                  input_B        : in  std_logic_vector(31 downto 0);
                  input_ALUOP    : in  std_logic_vector(3  downto 0);
                  output_F        : out std_logic_vector(31 downto 0);
                  output_CarryOut : out std_logic;
                  output_Overflow : out std_logic;
                  output_Zero     : out std_logic );
    end component;

    component mux2to1_32bit is
        port( input_X   : in std_logic_vector(31 downto 0);
              input_Y   : in std_logic_vector(31 downto 0);
              input_SEL : in std_logic;
              output_OUT   : out std_logic_vector(31 downto 0) );
    end component;

    component forwarding_logic is
        port( input_Branch             : in std_logic;
              input_JR                 : in std_logic;
              input_EXMEM_RegWriteEn   : in std_logic;
              input_MEMWB_RegWriteEn   : in std_logic;
              input_EXMEM_WriteReg     : in std_logic_vector(4 downto 0);
              input_MEMWB_WriteReg     : in std_logic_vector(4 downto 0);
              input_IFID_RS            : in std_logic_vector(4 downto 0);
              input_IDEX_RS            : in std_logic_vector(4 downto 0);
              input_IFID_RT            : in std_logic_vector(4 downto 0);
              input_IDEX_RT            : in std_logic_vector(4 downto 0);
              input_EXMEM_RT           : in std_logic_vector(4 downto 0);
              output_Forward_ALU_A_Sel1 : out std_logic;
              output_Forward_ALU_A_Sel2 : out std_logic;
              output_Forward_ALU_B_Sel1 : out std_logic;
              output_Forward_ALU_B_Sel2 : out std_logic;
              output_Forward_RS_Sel1    : out std_logic;
              output_Forward_RS_Sel2    : out std_logic;
              output_Forward_RT_Sel1    : out std_logic;
              output_Forward_RT_Sel2    : out std_logic );
    end component;

    signal signal_alu_out, signal_Forward_A, signal_Forward_B, signal_Normal_A, signal_Normal_B, signal_Final_A,
           signal_Final_B: std_logic_vector(31 downto 0);
    signal signal_cf, signal_ovf, signal_zero, signal_Forward_ALU_A_Sel1, signal_Forward_ALU_A_Sel2,
           signal_Forward_ALU_B_Sel1, signal_Forward_ALU_B_Sel2, signal_Forward_RS_Sel1,
           signal_Forward_RS_Sel2, signal_Forward_RT_Sel1, signal_Forward_RT_Sel2 : std_logic;

begin

    
    output_JAL <= input_JAL;
    output_ALUOut <= signal_alu_out;
    output_RD2 <= input_RD2;
    output_MemWrite <= input_MemWrite;
    output_RegWriteEn <= input_RegWriteEn;
    output_OVF <= signal_ovf;
    output_ZF <= signal_zero;
	 output_WR <= input_WR;
	 output_Forward_RT_Sel1 <= signal_Forward_RT_Sel1;
	 output_Mem_To_Reg <= input_Mem_To_Reg;
	 output_PCPlus4 <= input_PCPlus4;
    output_Instruction <= input_Instruction;
    output_Forward_RS_Sel1 <= signal_Forward_RS_Sel1;
    output_Forward_RS_Sel2 <= signal_Forward_RS_Sel2;
    output_Forward_RT_Sel2 <= signal_Forward_RT_Sel2;
	 output_CF <= signal_cf;


    select_normal_a: sel_alu_a
        port map(input_ALUSrc, input_RD1, input_ALUOP, input_SHAMT, input_Sel_Mux2, signal_Normal_A);

    mux_a_fwd: mux2to1_32bit
        port map(input_WB_Data, input_EXMEM_ALUOut, signal_Forward_ALU_A_Sel2, signal_Forward_A);

    final_mux_a: mux2to1_32bit
        port map(signal_Normal_A, signal_Forward_A, signal_Forward_ALU_A_Sel1, signal_Final_A);
		 
    select_normal_b: mux2to1_32bit
        port map(input_RD2, input_IMM, input_ALUSrc, signal_Normal_B);
    
	 mux_b_fwd: mux2to1_32bit
        port map(input_WB_Data, input_EXMEM_ALUOut, signal_Forward_ALU_B_Sel2, signal_Forward_B);


    final_mux_b: mux2to1_32bit
        port map(signal_Normal_B, signal_Forward_B, signal_Forward_ALU_B_Sel1, signal_Final_B);

    alu: alu_32bit
        port map(signal_Final_A, signal_Final_B, input_ALUOp, signal_alu_out, signal_cf, signal_ovf, signal_zero);

end structural;
