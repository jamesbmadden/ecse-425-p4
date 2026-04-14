library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ImmGen is
    Port (instruction : in std_logic_vector(31 downto 0);
        ExtImm : out std_logic_vector(31 downto 0));
end ImmGen;

architecture behaviour of ImmGen is
begin
    process(instruction)
        variable opcode : std_logic_vector(6 downto 0);
        variable i_imm : std_logic_vector(11 downto 0);
        variable s_imm : std_logic_vector(11 downto 0);
        variable b_imm : std_logic_vector(12 downto 0);
        variable u_imm : std_logic_vector(31 downto 0);
        variable j_imm : std_logic_vector(20 downto 0);
    begin
        opcode := instruction(6 downto 0);

        i_imm := instruction(31 downto 20);
        s_imm := instruction(31 downto 25) & instruction(11 downto 7);
        b_imm := instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
        u_imm := instruction(31 downto 12) & "000000000000"; 
        j_imm := instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

        ExtImm <= (others => '0');

        --extender
        case opcode is

                --addi, xori, ori, andi, slti, lw, jalr : copy the 11th bit of i_imm 20 times to fill the upper 32 bits
            when "0010011" | "0000011" | "1100111" => 
                ExtImm <= (31 downto 12 => i_imm(11)) & i_imm;

            --sw
            when "0100011" => 
                ExtImm <= (31 downto 12 => s_imm(11)) & s_imm;

            --beq, bne, blt, bge
            when "1100011" => 
                ExtImm <= (31 downto 13 => b_imm(12)) & b_imm;

            --lui, auipc
            when "0110111" | "0010111" => 
                ExtImm <= u_imm;

            --jal
            when "1101111" => 
                ExtImm <= (31 downto 21 => j_imm(20)) & j_imm;

            when others =>
                ExtImm <= (others => '0');
        end case;
    end process;
end behaviour;