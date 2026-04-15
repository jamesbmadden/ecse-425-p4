LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- holds values for a clock cycle for the register stage, except for the instr read which is delayed
-- a clock cycle by the memory read already
entity regbuffer is
	port (
		-- instrmem has to take in an address and return a value
		clk : in std_logic;
        stall : in std_logic;
        flush : in std_logic;
		new_pc : in std_logic_vector(31 downto 0);
		new_instr : in std_logic_vector(31 downto 0);
        pc : out std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0)
	);
end regbuffer;

architecture behaviour of regbuffer is

    -- implement a 1-clock delay by holding a value of pc here
    signal s_pc : std_logic_vector(31 downto 0);

begin

    -- update values
    process(clk)
	begin
        if rising_edge(clk) then
            if flush = '1' then
                pc <= (others => '0');
                instr <= (others => '0');
                s_pc <= (others => '0');
            elsif stall = '0' then
                pc <= s_pc;
                instr <= new_instr; -- since it's already delayed a clock cycle
                s_pc <= new_pc;
            end if;
        end if;
	end process;

end architecture;