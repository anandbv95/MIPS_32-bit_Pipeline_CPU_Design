library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control is
    port( input_Instruction    : in std_logic_vector(31 downto 0); 
          output_ALUOP		   : out std_logic_vector(3 downto 0);
           output_ALUSrc         : out std_logic;
			  output_BEQ            : out std_logic;
          output_RegDst         : out std_logic;
          output_Mem_To_Reg     : out std_logic;
          output_MemWrite       : out std_logic;
          output_output_JR      : out std_logic;
          output_RegWrite       : out std_logic; 
          output_BNE            : out std_logic;
          output_J              : out std_logic;
          output_JAL            : out std_logic;
			 output_Sel_ALU_A_Mux2 : out std_logic;
          output_MemRead        : out std_logic );
end control;


architecture dataflow of control is
    signal op, funct : std_logic_vector(5 downto 0);
    signal all_outputs : std_logic_vector(8 downto 0);

begin
    process (input_Instruction, op, funct)
    begin
        op <= input_Instruction(31 downto 26);
        funct <= input_Instruction(5 downto 0);
		  output_MemRead <= '0';
        output_Sel_ALU_A_Mux2 <= '0'; 
        output_BEQ <= '0'; 
        output_J <= '0';
        output_JAL <= '0';
        output_output_JR <= '0';
		  output_BNE <= '0';
        

        if op = "000000" then
        -- R-type
            if funct = "101010" then
                all_outputs <= "001110011"; -- slt
            elsif funct = "101011" then
                all_outputs <= "001110011"; -- sltu
            elsif funct = "100000" then
                all_outputs <= "000100011"; -- and
            elsif funct = "100001" then
                all_outputs <= "000100011"; -- addu
            elsif funct = "100100" then
                all_outputs <= "000000011"; -- and
            elsif funct = "100110" then
                all_outputs <= "011010011"; -- xor
            elsif funct = "100101" then
                all_outputs <= "000010011"; -- or
            elsif funct = "100111" then
                all_outputs <= "011000011"; -- nor
            elsif funct = "000000" then
                all_outputs <= "010010011"; -- sll
                output_Sel_ALU_A_Mux2 <= '1'; 
            elsif funct = "000010" then
                all_outputs <= "010000011"; -- srl
                output_Sel_ALU_A_Mux2 <= '1'; 
            elsif funct = "000011" then
                all_outputs <= "010100011"; -- sra
                output_Sel_ALU_A_Mux2 <= '1';
            elsif funct = "000100" then
                all_outputs <= "010010011"; -- sllv
            elsif funct = "000110" then
                all_outputs <= "010000011"; -- srlv
            elsif funct = "000111" then
                all_outputs <= "010100011"; -- srav
            elsif funct = "100010" then
                all_outputs <= "001100011"; -- sub
            elsif funct = "100011" then
                all_outputs <= "001100011"; -- subu
            elsif funct = "001000" then
                all_outputs <= "000000000"; -- output_Jr
                output_output_JR <= '1';
            else
                all_outputs <= "111111111"; 
            end if;
        else
        -- I-or-output_J-type
            if op = "001000" then
                all_outputs <= "000100110"; -- addi
            elsif op = "001001" then
                all_outputs <= "000100110"; -- addiu
            elsif op = "001100" then
                all_outputs <= "000000110"; -- andi
            elsif op = "001111" then
                all_outputs <= "010010110"; -- lui
                output_Sel_ALU_A_Mux2 <= '1'; 
            elsif op = "100011" then
                all_outputs <= "100100110"; -- lw
                output_MemRead <= '1';
            elsif op = "001110" then
                all_outputs <= "011010110"; -- xori
            elsif op = "001101" then
                all_outputs <= "000010110"; -- ori
            elsif op = "001010" then
                all_outputs <= "001110110"; -- slti
            elsif op = "001011" then
                all_outputs <= "001110110"; -- sltiu
            elsif op = "101011" then
                all_outputs <= "100101100"; -- sw 
            elsif op = "000100" then
                all_outputs <= "001100000"; -- BEQ output
                output_BEQ <= '1';
            elsif op = "000101" then
                all_outputs <= "001100000"; -- BNE output
                output_BNE <= '1';
            elsif op = "000010" then
                all_outputs <= "000000000"; -- J outpur
                output_J <= '1';
            elsif op = "000011" then
                all_outputs <= "000000000"; -- Jal output
                output_JAL <= '1';
            else
                all_outputs <= "111111110"; 
            end if;
        end if;

    end process;

   
output_Mem_To_Reg <= all_outputs(8);
    output_ALUOP <= all_outputs(7 downto 4);
    output_MemWrite <= all_outputs(3);
  output_ALUSrc <= all_outputs(2);
    output_RegWrite <= '1' when (op = "000011") else
                         all_outputs(1);
    output_RegDst <= all_outputs(0);   

end dataflow;
