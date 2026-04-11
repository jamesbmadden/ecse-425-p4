library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Required for arithmetic operations

entity ALU is
    Port ( SrcA       : in  STD_LOGIC_VECTOR(31 downto 0);
           SrcB       : in  STD_LOGIC_VECTOR(31 downto 0);
           ALUControl : in  STD_LOGIC_VECTOR(3 downto 0);
           ALUResult  : out STD_LOGIC_VECTOR(31 downto 0));
end ALU;
architecture Behavioral of ALU is
begin
    process(SrcA, SrcB, ALUControl)
        -- Declare variables for intermediate signed/unsigned conversions
        variable A_signed : signed(31 downto 0);
        variable B_signed : signed(31 downto 0);
        variable A_unsigned : unsigned(31 downto 0);
        variable B_unsigned : unsigned(31 downto 0);
    begin
        -- Cast inputs for arithmetic and comparison operations
        A_signed := signed(SrcA);
        B_signed := signed(SrcB);
        A_unsigned := unsigned(SrcA);
        B_unsigned := unsigned(SrcB);

        case ALUControl is
            when "0000" => -- Addition
                ALUResult <= std_logic_vector(A_signed + B_signed);
                
            when "0001" => -- Subtraction
                ALUResult <= std_logic_vector(A_signed - B_signed);
                
            when "0010" => -- Bitwise AND
                ALUResult <= SrcA and SrcB;
                
            when "0011" => -- Bitwise OR
                ALUResult <= SrcA or SrcB;
                
            when "0100" => -- Bitwise XOR
                ALUResult <= SrcA xor SrcB;
                
            when "0101" => -- Set Less Than (Signed)
                if A_signed < B_signed then
                    ALUResult <= x"00000001";
                else
                    ALUResult <= x"00000000";
                end if;
                
            when "0110" => -- Set Less Than (Unsigned)
                if A_unsigned < B_unsigned then
                    ALUResult <= x"00000001";
                else
                    ALUResult <= x"00000000";
                end if;

            when "0111" => -- Multiplication (single cycle)
                -- VHDL '*' operator synthesizes to a combinational multiplier
                -- We only need the lower 32 bits of the 64-bit result for RV32I 'mul'
                ALUResult <= std_logic_vector(resize(A_signed * B_signed, 32));

            when "1000" => -- Logical Shift Left
                -- Shift amounts in RV32I are dictated by the lower 5 bits of SrcB
                ALUResult <= std_logic_vector(shift_left(A_unsigned, to_integer(B_unsigned(4 downto 0))));

            when "1001" => -- Logical Shift Right
                ALUResult <= std_logic_vector(shift_right(A_unsigned, to_integer(B_unsigned(4 downto 0))));

            when "1010" => -- Arithmetic Shift Right
                ALUResult <= std_logic_vector(shift_right(A_signed, to_integer(B_unsigned(4 downto 0))));

            when others =>
                ALUResult <= (others => '0'); -- Default case to prevent latches
        end case;
    end process;
end Behavioral;