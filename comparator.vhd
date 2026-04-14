library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Comparator is
    Port (rs1_data : in std_logic_vector(31 downto 0);
        rs2_data : in std_logic_vector(31 downto 0);
        branch_en : in STD_LOGIC; --branch signal
        funct3 : in std_logic_vector(2 downto 0);  --from the instruction
        branch_take : out STD_LOGIC); --output flag
end Comparator;

architecture behaviour of Comparator is
begin
    process(rs1_data, rs2_data, branch_en, funct3)
        variable A_signed : signed(31 downto 0);
        variable B_signed : signed(31 downto 0);
    begin
        A_signed := signed(rs1_data);
        B_signed := signed(rs2_data);

        branch_take <= '0';

        --only evaluate if flagged this as branch instruction
        if branch_en = '1' then
            case funct3 is

                --beq
                when "000" => 
                    if A_signed = B_signed then 
                        branch_take <= '1'; 
                    end if;

                --bne
                when "001" =>
                    if A_signed /= B_signed then 
                        branch_take <= '1'; 
                    end if;
                
                --blt
                when "100" =>
                    if A_signed < B_signed then 
                        branch_take <= '1'; 
                    end if;
                
                --bge
                when "101" =>
                    if A_signed >= B_signed then 
                        branch_take <= '1'; 
                    end if;
                    
                when others =>
                    branch_take <= '0';
            end case;
        end if;
    end process;
end behaviour;