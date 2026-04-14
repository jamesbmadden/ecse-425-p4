library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_Decoder is
    Port ( opcode     : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3     : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7     : in  STD_LOGIC_VECTOR (6 downto 0);
           ALUControl : out STD_LOGIC_VECTOR (3 downto 0));
end ALU_Decoder;

architecture Behavioral of ALU_Decoder is
begin
    process(opcode, funct3, funct7)
    begin
        -- Default assignment to prevent latches
        ALUControl <= "0000"; 

        case opcode is
            when "0110011" => -- R-Type and Multiply
                if funct7 = "0000000" and funct3 = "000" then
                    ALUControl <= "0000"; -- add
                elsif funct7 = "0100000" and funct3 = "000" then
                    ALUControl <= "0001"; -- sub
                elsif funct7 = "0000001" and funct3 = "000" then
                    ALUControl <= "0111"; -- mul
                elsif funct7 = "0000000" and funct3 = "001" then
                    ALUControl <= "1000"; -- sll
                elsif funct7 = "0000000" and funct3 = "010" then
                    ALUControl <= "0101"; -- slt
                elsif funct7 = "0000000" and funct3 = "011" then
                    ALUControl <= "0110"; -- sltu
                elsif funct7 = "0000000" and funct3 = "100" then
                    ALUControl <= "0100"; -- xor
                elsif funct7 = "0000000" and funct3 = "101" then
                    ALUControl <= "1001"; -- srl
                elsif funct7 = "0100000" and funct3 = "101" then
                    ALUControl <= "1010"; -- sra
                elsif funct7 = "0000000" and funct3 = "110" then
                    ALUControl <= "0011"; -- or
                elsif funct7 = "0000000" and funct3 = "111" then
                    ALUControl <= "0010"; -- and
                end if;
                
            when "0010011" => -- I-Type ALU
                if funct3 = "000" then
                    ALUControl <= "0000"; -- addi
                elsif funct3 = "010" then
                    ALUControl <= "0101"; -- slti
                elsif funct3 = "011" then
                    ALUControl <= "0110"; -- sltiu
                elsif funct3 = "100" then
                    ALUControl <= "0100"; -- xori
                elsif funct3 = "110" then
                    ALUControl <= "0011"; -- ori
                elsif funct3 = "111" then
                    ALUControl <= "0010"; -- andi
                -- Immediate shifts use the funct7 space (imm[11:5]) to differentiate logical/arithmetic
                elsif funct7 = "0000000" and funct3 = "001" then
                    ALUControl <= "1000"; -- slli
                elsif funct7 = "0000000" and funct3 = "101" then
                    ALUControl <= "1001"; -- srli
                elsif funct7 = "0100000" and funct3 = "101" then
                    ALUControl <= "1010"; -- srai
                end if;

            when "0000011" | "0100011" => -- Loads and Stores
                ALUControl <= "0000"; -- Addition for memory address calculation

            when "1100011" => -- Branches
                ALUControl <= "0001"; -- Subtraction for equality/magnitude comparison

            when "0110111" | "0010111" | "1101111" | "1100111" => -- LUI, AUIPC, JAL, JALR
                ALUControl <= "0000"; -- Addition for PC/address calculations

            when others =>
                ALUControl <= "0000"; -- Default fallback to prevent latches
        end case;
    end process;
end Behavioral;