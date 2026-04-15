library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control is
    Port (opcode : in  std_logic_vector (6 downto 0);
        --execution
        ALUPc : out std_logic;
        ALUSrc : out std_logic;
        IsJump : out std_logic;
        --memory
        Branch : out std_logic;
        MemRead : out std_logic;
        MemWrite : out std_logic; 
        --write back
        MemtoReg : out std_logic;
        RegWrite : out std_logic);
end control;

architecture behaviour of control is
begin
    process(opcode)
    begin
        --default
        ALUPc <= '0';
        ALUSrc <= '0';
        IsJump <= '0';
        Branch <= '0';
        MemRead <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';

        case opcode is

            --add, sub, mul, sll, srl, sra, or, and
            when "0110011" => 
                RegWrite <= '1';

            --addi, xori, ori, andi, slti
            when "0010011" => 
                ALUSrc <= '1'; --take second operand from ImmGen
                RegWrite <= '1';


        --lw
            when "0000011" => 
                ALUSrc <= '1'; --add base address + ImmGen offset
                MemRead <= '1'; --turn on data memory read
                MemtoReg <= '1'; --write memory output back to register
                RegWrite <= '1';

            --sw
            when "0100011" =>
                ALUSrc <= '1'; --add base address + ImmGen offset
                MemWrite <= '1'; --turn on data memory write

            --beq, bne, blt, bge
            when "1100011" => 
                Branch <= '1'; --turn on comparator

            --lui
            when "0110111" =>
                ALUSrc <= '1'; --pass immediate through ALU
                RegWrite <= '1';

            --auipc
            when "0010111" =>
                ALUPc <= '1'; --use PC instead of reg1
                ALUSrc <= '1'; --add immediate to PC
                RegWrite <= '1';

            --jal
            when "1101111" =>
                ALUPc <= '1'; --use PC instead of reg1
                ALUSrc <= '1';
                RegWrite <= '1';
                IsJump <= '1';

            --jalr
            when "1100111" =>
                ALUSrc <= '1'; --base+offset
                RegWrite <= '1';
                IsJump <= '1';

            --others
            when others =>
                null;
        end case;
    end process;
end behaviour;