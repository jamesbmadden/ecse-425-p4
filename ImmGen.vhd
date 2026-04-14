library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ImmGen is
    Port ( instruction : in  STD_LOGIC_VECTOR (31 downto 0);
           ExtImm      : out STD_LOGIC_VECTOR (31 downto 0));
end ImmGen;

architecture Behavioral of ImmGen is
begin
    process(instruction)
        -- Variables to temporarily hold the extracted bits for each format
        variable opcode : std_logic_vector(6 downto 0);
        variable funct3 : std_logic_vector(2 downto 0);
        
        variable i_imm : std_logic_vector(11 downto 0);
        variable s_imm : std_logic_vector(11 downto 0);
        variable b_imm : std_logic_vector(12 downto 0);
        variable u_imm : std_logic_vector(31 downto 0);
        variable j_imm : std_logic_vector(20 downto 0);
    begin
        -- 1. Extract the control fields
        opcode := instruction(6 downto 0);
        funct3 := instruction(14 downto 12);

        -- 2. Extract the raw immediate fields based on standard RISC-V formats
        i_imm := instruction(31 downto 20);
        s_imm := instruction(31 downto 25) & instruction(11 downto 7);
        
        -- B and J types have scrambled immediate bits in the machine code
        b_imm := instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
        u_imm := instruction(31 downto 12) & x"000";
        j_imm := instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';

        -- Default output to prevent latches
        ExtImm <= (others => '0');

        -- 3. Extend the immediate based on opcode and funct3
        case opcode is
            when "0010011" => -- I-Type ALU (addi, slti, etc.)
                if funct3 = "011" then 
                    -- sltiu explicitly zero-extends
                    ExtImm <= x"00000" & i_imm;
                else 
                    -- All others msb-extend (sign extend)
                    -- Copies the 11th bit of i_imm 20 times to fill the upper 32 bits
                    ExtImm <= (31 downto 12 => i_imm(11)) & i_imm;
                end if;

            when "0000011" => -- I-Type Loads (lw, lh, lb, etc.)
                if funct3 = "100" or funct3 = "101" then 
                    -- lbu and lhu explicitly zero-extend
                    ExtImm <= x"00000" & i_imm;
                else 
                    -- lw, lh, lb msb-extend
                    ExtImm <= (31 downto 12 => i_imm(11)) & i_imm;
                end if;

            when "0100011" => -- S-Type Stores (sw, sh, sb)
                -- Stores always msb-extend
                ExtImm <= (31 downto 12 => s_imm(11)) & s_imm;

            when "1100011" => -- B-Type Branches (beq, bne, blt, etc.)
                if funct3 = "110" or funct3 = "111" then 
                    -- bltu and bgeu explicitly zero-extend
                    ExtImm <= (31 downto 13 => '0') & b_imm;
                else 
                    -- All other branches msb-extend
                    ExtImm <= (31 downto 13 => b_imm(12)) & b_imm;
                end if;

            when "0110111" | "0010111" => -- U-Type LUI and AUIPC
                -- U-types are already 32 bits (shifted left by 12)
                ExtImm <= u_imm;

            when "1101111" => -- J-Type JAL
                -- Jumps always msb-extend
                ExtImm <= (31 downto 21 => j_imm(20)) & j_imm;

            when "1100111" => -- I-Type JALR
                -- JALR uses the standard I-type immediate and msb-extends
                ExtImm <= (31 downto 12 => i_imm(11)) & i_imm;

            when others =>
                ExtImm <= (others => '0');
        end case;
    end process;
end Behavioral;