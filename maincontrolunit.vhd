library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Main_Control is
    Port ( opcode   : in  STD_LOGIC_VECTOR (6 downto 0);
           ALUSrc   : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC;
           MemRead  : out STD_LOGIC;
           MemWrite : out STD_LOGIC;
           Branch   : out STD_LOGIC);
end Main_Control;

architecture Behavioral of Main_Control is
begin
    process(opcode)
    begin
        -- Default assignments to '0' to prevent inferred latches
        ALUSrc   <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '0';

        case opcode is
            when "0110011" => -- R-Type (add, sub, mul, etc.)
                RegWrite <= '1';
                -- ALUSrc is 0 (reads rs2)
                -- MemtoReg is 0 (writes ALU result)

            when "0010011" => -- I-Type ALU (addi, slli, etc.)
                ALUSrc   <= '1'; -- Use immediate
                RegWrite <= '1';
                -- MemtoReg is 0

            when "0000011" => -- I-Type Loads (lw, lh, lb, etc.)
                ALUSrc   <= '1'; -- Use immediate for address calculation
                MemtoReg <= '1'; -- Write memory output to register
                RegWrite <= '1';
                MemRead  <= '1';

            when "0100011" => -- S-Type Stores (sw, sh, sb)
                ALUSrc   <= '1'; -- Use immediate for address calculation
                MemWrite <= '1';
                -- RegWrite is 0

            when "1100011" => -- B-Type Branches (beq, bne, etc.)
                Branch   <= '1';
                -- ALUSrc is 0 (needs to compare rs1 and rs2)
                -- RegWrite is 0

            when "0110111" => -- U-Type LUI
                ALUSrc   <= '1'; -- Use immediate
                RegWrite <= '1';

            when "0010111" => -- U-Type AUIPC
                ALUSrc   <= '1'; -- Use immediate
                RegWrite <= '1';

            when "1101111" => -- J-Type JAL
                RegWrite <= '1';
                -- Assuming your architecture writes PC+4 to rd

            when "1100111" => -- I-Type JALR
                ALUSrc   <= '1';
                RegWrite <= '1';

            when others =>
                -- Keep defaults
                null;
        end case;
    end process;
end Behavioral;