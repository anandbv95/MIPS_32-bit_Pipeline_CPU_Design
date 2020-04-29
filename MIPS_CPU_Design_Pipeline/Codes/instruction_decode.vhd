library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_decode is
    port( input_Reset            : in std_logic;
          input_Clock            : in std_logic;
			 input_Instruction      : in std_logic_vector(31 downto 0);
          input_Forward_RS_Sel1  : in std_logic;
          input_Forward_RS_Sel2  : in std_logic;
          input_Forward_RT_Sel1  : in std_logic;
          input_Forward_RT_Sel2  : in std_logic;
          input_WB_Data          : in std_logic_vector(31 downto 0);
          input_EXMEM_ALUOut     : in std_logic_vector(31 downto 0);    
          input_IDEX_MemRead     : in std_logic;
          input_IDEX_WriteReg    : in std_logic_vector(4 downto 0);
          input_EXMEM_WriteReg   : in std_logic_vector(4 downto 0);
          input_IFID_RS          : in std_logic_vector(4 downto 0);
          input_IFID_RT          : in std_logic_vector(4 downto 0);
          input_IDEX_RT          : in std_logic_vector(4 downto 0);
          input_WriteReg         : in std_logic_vector(4 downto 0);  
          input_RegWriteEn       : in std_logic;                     
          input_JAL_WB           : in std_logic;
          input_PCPlus4          : in std_logic_vector(31 downto 0);
			 input_WriteData        : in std_logic_vector(31 downto 0);
          output_Instruction      : out std_logic_vector(31 downto 0); 
          output_STALL_IFID       : out std_logic;
          output_STALL_PC         : out std_logic;
          output_PCPlus4          : out std_logic_vector(31 downto 0);
          output_JAL              : out std_logic;
          output_SHAMT            : out std_logic_vector(31 downto 0);
          output_BJ_Address       : out std_logic_vector(31 downto 0);
          output_PCSrc            : out std_logic;
          output_Immediate        : out std_logic_vector(31 downto 0);
          output_WR               : out std_logic_vector(4 downto 0);
          output_RegWriteEn       : out std_logic;
          output_ALUOP            : out std_logic_vector(3 downto 0);
          output_Sel_Mux2         : out std_logic;
          output_Mem_To_Reg       : out std_logic;
          output_MemWrite         : out std_logic;
          output_ALUSrc           : out std_logic;
          output_Branch           : out std_logic;
          output_JR               : out std_logic;
			           output_RD1              : out std_logic_vector(31 downto 0);
          output_RD2              : out std_logic_vector(31 downto 0);

          output_FLUSH_IFID       : out std_logic;
          output_FLUSH_IDEX       : out std_logic;
          output_MemRead          : out std_logic ); 
end instruction_decode;

architecture structural of instruction_decode is
    component branch_jump_logic is
        port( input_BEQ              : in std_logic;
              input_BNE              : in std_logic;
              input_JR               : in std_logic;
              input_Zero_Flag        : in std_logic;
              input_Instruc_25to0    : in std_logic_vector(25 downto 0);
              input_RD1              : in std_logic_vector(31 downto 0);
              input_IMM              : in std_logic_vector(31 downto 0);
				  input_PCPlus4          : in std_logic_vector(31 downto 0);
				  input_J                : in std_logic;
              input_JAL              : in std_logic;
              output_BJ_Address       : out std_logic_vector(31 downto 0);
              output_PCSrc            : out std_logic;
              output_BranchTaken      : out std_logic;
              output_Branch           : out std_logic );
    end component;

    component control is
        port( input_Instruction    : in std_logic_vector(31 downto 0);
              output_Sel_ALU_A_Mux2 : out std_logic;
              output_RegDst         : out std_logic;
              output_Mem_To_Reg     : out std_logic;
              output_ALUOP		   : out std_logic_vector(3 downto 0);
              output_MemWrite       : out std_logic;
              output_ALUSrc         : out std_logic;
              output_RegWrite       : out std_logic;
              output_BEQ            : out std_logic;
              output_BNE            : out std_logic;
              output_J              : out std_logic;
              output_JAL            : out std_logic;
              output_JR             : out std_logic;
              output_MemRead        : out std_logic );
    end component;

    component register_file is
        port( input_CLK       : in std_logic;
              input_RST       : in std_logic;
				  input_RR1       : in std_logic_vector(4 downto 0);
              input_RR2       : in std_logic_vector(4 downto 0);
              input_WR        : in std_logic_vector(4 downto 0);
              input_WD        : in std_logic_vector(31 downto 0);
              input_REGWRITE  : in std_logic;
              output_RD1       : out std_logic_vector(31 downto 0);
              output_RD2       : out std_logic_vector(31 downto 0) );
    end component;

    component mux2to1_5bit is
        port( input_X   : in std_logic_vector(4 downto 0);
              input_Y   : in std_logic_vector(4 downto 0);
              input_SEL : in std_logic;
              output_OUT   : out std_logic_vector(4 downto 0) );
    end component;

    component extend_16to32bit is
        port( input_input	: in std_logic_vector(15 downto 0);
              input_sign    : in std_logic;
              output_output  : out std_logic_vector(31 downto 0) );
    end component;

    component extend_5to32bit is
        port( input_input   : in std_logic_vector(4 downto 0);
              input_sign    : in std_logic;
              output_output  : out std_logic_vector(31 downto 0) );
    end component;

    component rd1_rd2_zero_detect is
        port( input_RD1       : in std_logic_vector(31 downto 0);
              input_RD2       : in std_Logic_vector(31 downto 0);
              output_Zero_Flag : out std_logic );
    end component;


    component mux2to1_32bit is
        port( input_X   : in std_logic_vector(31 downto 0);
              input_Y   : in std_logic_vector(31 downto 0);
              input_SEL : in std_logic;
              output_OUT   : out std_logic_vector(31 downto 0) );
    end component;

    -- Signal declaration ---
    signal signal_Sel_ALU_A_Mux2, signal_RegDst, signal_Mem_To_Reg, signal_MemWrite,
           signal_ALUSrc, signal_RegWrite, signal_BEQ, signal_BNE, signal_J, signal_JAL, signal_JR, signal_PCSrc,
           signal_Zero, signal_MemRead, signal_BranchTaken, signal_Branch, signal_FLUSH_IFID,
           signal_FLUSH_IDEX, signal_STALL_IFID, signal_STALL_PC : std_logic;
    signal signal_ALUOP : std_logic_vector(3 downto 0);
    signal signal_Immediate, signal_RD1, signal_RD2, signal_BJ_Addr, signal_SHAMT, signal_Forward_RS,
           signal_Forward_RT, signal_RS_Data_Final, signal_RT_Data_Final : std_logic_vector(31 downto 0);
    signal signal_ThirtyOne, signal_WR_Passthru, signal_WR : std_logic_vector(4 downto 0);

begin

    output_FLUSH_IFID <= signal_FLUSH_IFID;   
    output_FLUSH_IDEX <= signal_FLUSH_IDEX;
    output_STALL_IFID <= signal_STALL_IFID;
    output_STALL_PC <= signal_STALL_PC;
    output_PCPlus4 <= input_PCPlus4;
    output_JAL <= signal_JAL;
    output_SHAMT <= signal_SHAMT;
    output_BJ_Address <= signal_BJ_Addr;
    output_PCSrc <= signal_PCSrc;
    output_Immediate <= signal_Immediate;
    output_WR <= signal_WR_Passthru;
    output_RegWriteEn <= signal_RegWrite;
    output_RD1 <= signal_RS_Data_Final;
    output_RD2 <= signal_RT_Data_Final;
    output_ALUOP <= signal_ALUOP;
    output_Sel_Mux2 <= signal_Sel_ALU_A_Mux2;
    output_Mem_To_Reg <= signal_Mem_To_Reg;
    output_MemWrite <= signal_MemWrite;
    output_ALUSrc <= signal_ALUSrc;
    output_Branch <= signal_Branch;
    output_JR <= signal_JR;
    output_MemRead <= signal_MemRead;
    output_Instruction <= input_Instruction;

    signal_ThirtyOne <= (others => '1'); 

    control_logic: control
        port map (input_Instruction, signal_Sel_ALU_A_Mux2, signal_RegDst, signal_Mem_To_Reg, signal_ALUOP,
                  signal_MemWrite, signal_ALUSrc, signal_RegWrite, signal_BEQ, signal_BNE, signal_J, signal_JAL, signal_JR, signal_MemRead);

    bj_logic: branch_jump_logic
        port map (signal_BEQ, signal_BNE, signal_J, signal_JAL, signal_JR, signal_Zero, input_Instruction(25 downto 0),
                  signal_RD1, input_PCPlus4, signal_Immediate, signal_BJ_Addr, signal_PCSrc, signal_BranchTaken, signal_Branch);

    mux_WR_Pre: mux2to1_5bit
        port map (input_Instruction(20 downto 16), input_Instruction(15 downto 11), signal_RegDst, signal_WR_Passthru);

    mux_WR_Final: mux2to1_5bit
        port map (input_WriteReg, signal_ThirtyOne, input_JAL_WB, signal_WR);

   
    rf: register_file
        port map (input_clock, input_reset, signal_WR, input_WriteData, input_RegWriteEn,
                  input_Instruction(25 downto 21), input_Instruction(20 downto 16), signal_RD1, signal_RD2);

    mux_Forward_RS: mux2to1_32bit
        port map(input_WB_Data, input_EXMEM_ALUOut, input_Forward_RS_Sel2, signal_Forward_RS);

    mux_Forward_RT: mux2to1_32bit
        port map(input_WB_Data, input_EXMEM_ALUOut, input_Forward_RT_Sel2, signal_Forward_RT);

    mux_Final_RS: mux2to1_32bit
        port map(signal_RD1, signal_Forward_RS, input_Forward_RS_Sel1, signal_RS_Data_Final);

    mux_Final_RT: mux2to1_32bit
        port map(signal_RD2, signal_Forward_RT, input_Forward_RT_Sel1, signal_RT_Data_Final);

    extend_imm: extend_16to32bit
        port map (input_Instruction(15 downto 0), '1', signal_Immediate);

    extend_shamt: extend_5to32bit
        port map (input_Instruction(10 downto 6), '1', signal_SHAMT); 

    rd1_rd2_zero : rd1_rd2_zero_detect
        port map (signal_RS_Data_Final, signal_RT_Data_Final, signal_Zero); 

end structural;
