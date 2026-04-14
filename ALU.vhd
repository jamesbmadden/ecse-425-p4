library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( srcA : in std_logic_vector(31 downto 0); --from register 1 or PC
           srcB : in std_logic_vector(31 downto 0); --from register 2 or immgen
           ALUControl : in std_logic_vector(3 downto 0); --command from control unit
           ALUResult : out std_logic_vector(31 downto 0)); --output
end ALU;
architecture behaviour of ALU is
begin
    process(srcA, srcB, ALUControl)
        variable A_signed : signed(31 downto 0);
        variable B_signed : signed(31 downto 0);
        variable A_unsigned : unsigned(31 downto 0);
        variable B_unsigned : unsigned(31 downto 0);
    begin
        A_signed := signed(srcA);
        B_signed := signed(srcB);
        A_unsigned := unsigned(srcA);
        B_unsigned := unsigned(srcB);

        case ALUControl is
            --addition
            when "0000" => 
                ALUResult <= std_logic_vector(A_signed + B_signed);

            --subtraction
            when "0001" =>
                ALUResult <= std_logic_vector(A_signed - B_signed);
            
            --and
            when "0010" =>
                ALUResult <= srcA and srcB;

            --or  
            when "0011" =>
                ALUResult <= srcA or srcB;
            
            --xor
            when "0100" =>
                ALUResult <= srcA xor srcB;
            
            --< signed
            when "0101" =>
                if A_signed < B_signed then
                    ALUResult <= x"00000001";
                else
                    ALUResult <= x"00000000";
                end if;
            
            --< unsigned
            when "0110" =>
                if A_unsigned < B_unsigned then
                    ALUResult <= x"00000001";
                else
                    ALUResult <= x"00000000";
                end if;

            --multiplication
            when "0111" =>
                -- VHDL '*' operator synthesizes to a combinational multiplier
                -- We only need the lower 32 bits of the 64-bit result for RV32I 'mul'
                ALUResult <= std_logic_vector(resize(A_signed * B_signed, 32));

            --logical shift left by lower 5 bits of srcB
            when "1000" =>
                ALUResult <= std_logic_vector(shift_left(A_unsigned, to_integer(B_unsigned(4 downto 0))));

            --logical shift right by lower 5 bits of srcB
            when "1001" =>
                ALUResult <= std_logic_vector(shift_right(A_unsigned, to_integer(B_unsigned(4 downto 0))));

            --arithmetic shift right by lower 5 bits of srcB
            when "1010" => -- Arithmetic Shift Right
                ALUResult <= std_logic_vector(shift_right(A_signed, to_integer(B_unsigned(4 downto 0))));

            when others =>
                ALUResult <= (others => '0');
        end case;
    end process;
end behaviour;