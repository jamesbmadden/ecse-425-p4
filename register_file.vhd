library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port (
        clk        : in std_logic;
        reset      : in std_logic;
        reg_write  : in std_logic;
        
        instr      : in std_logic_vector(31 downto 0);
        write_data : in std_logic_vector(31 downto 0);

        rs1_data   : out std_logic_vector(31 downto 0);
        rs2_data   : out std_logic_vector(31 downto 0)
    );
end entity register_file;

architecture behaviour of register_file is
    type reg_array_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array_type := (others => (others => '0'));

    signal rs1_addr : std_logic_vector(4 downto 0);
    signal rs2_addr : std_logic_vector(4 downto 0);
    signal rd_addr  : std_logic_vector(4 downto 0);

begin
    -- extract addresses from instr
    rs2_addr <= instr(24 downto 20);
    rs1_addr <= instr(19 downto 15);
    rd_addr  <= instr(11 downto 7);

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                regs <= (others => (others => '0'));
            else
                -- write if enabled and not writing to x0
                if reg_write = '1' and rd_addr /= "00000" then
                    regs(to_integer(unsigned(rd_addr))) <= write_data;
                end if;

                -- x0 must be 0
                regs(0) <= (others => '0');
            end if;
        end if;
    end process;

    -- asynchronous Read Ports
    rs1_data <= regs(to_integer(unsigned(rs1_addr)));
    rs2_data <= regs(to_integer(unsigned(rs2_addr)));

end architecture;