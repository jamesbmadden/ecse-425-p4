library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUdecoder is
--break down the bits
    Port (opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);
        ALUControl : out std_logic_vector(3 downto 0));
end ALUdecoder;

architecture behaviour of ALUdecoder is
begin
    process(opcode, funct3, funct7)
    begin
        ALUControl <= "0000"; 

        case opcode is
            when "0110011" => --r type and multiply

                --add
                if funct7 = "0000000" and funct3 = "000" then
                    ALUControl <= "0000";

                --sub
                elsif funct7 = "0100000" and funct3 = "000" then
                    ALUControl <= "0001";

                --mul
                elsif funct7 = "0000001" and funct3 = "000" then
                    ALUControl <= "0111";

                --sll
                elsif funct7 = "0000000" and funct3 = "001" then
                    ALUControl <= "1000";

                --srl
                elsif funct7 = "0000000" and funct3 = "101" then
                    ALUControl <= "1001";

                --sra
                elsif funct7 = "0100000" and funct3 = "101" then
                    ALUControl <= "1010";

                --or
                elsif funct7 = "0000000" and funct3 = "110" then
                    ALUControl <= "0011";

                --and
                elsif funct7 = "0000000" and funct3 = "111" then
                    ALUControl <= "0010";

                end if;
                
            when "0010011" => --i type
                --addi
                if funct3 = "000" then
                    ALUControl <= "0000";

                --slti
                elsif funct3 = "010" then
                    ALUControl <= "0101";

                --xori
                elsif funct3 = "100" then
                    ALUControl <= "0100";

                --ori
                elsif funct3 = "110" then
                    ALUControl <= "0011";

                --andi
                elsif funct3 = "111" then
                    ALUControl <= "0010";

            --compute memory address for lw and sw: r1+offset
            when "0000011" | "0100011" =>
                ALUControl <= "0000";

            --beq, bne, blt, bge: subtract to compare
            when "1100011" => -- Branches
                ALUControl <= "0001";

            lui, auipc, jal, jalr: addition to compute pc or address
            when "0110111" | "0010111" | "1101111" | "1100111" =>
                ALUControl <= "0000";

            when others =>
                ALUControl <= "0000";
        end case;
    end process;
end behaviour;