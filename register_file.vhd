library.IEEE
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port (
        clk : in std_logic;
        reset : in std_logic;
        reg_write : in std_logic;

        rs1_addr : in std_logic_vector(4 downto 0);
        rs2_addr : in std_logic_vector(4 downto 0);
        rd_addr : in std_logic_vector(4 downto 0);

        write_data : in std_logic_vector(31 downto 0);

        rs1_data : out std_logic_vector(31 downto 0);
        rs2_data : out std_logic_vector(31 downto 0);
    );
end entity register_file;

architecture Behavioral of register_file is
    type reg_array_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array_type := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- reset to clear all registers
            if reset = '1' then
                regs <= (others => (others => '0'));

            else
            -- write if enabled
            if reg_write = '1' and rd_addr /= "0000" then
                regs(to_integer(unsigned(rd_addr))) <= write_data;
            end if;

            -- keep x0 forced to zero
            regs(0) <= x"00000000";

        end if;
    end if;
end process;

-- read port 1
rs1_data <= x"00000000" when rs1_addr = "00000" else
    regs(to_integer(unsigned(rs1_addr)));

-- read port 2
rs2_data <= x"00000000" when rs1_addr = "00000" else
    regs(to_integer(unsigned(rs2_addr)));