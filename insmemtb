library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_instrmem_load is
end tb_instrmem_load;

architecture behavior of tb_instrmem_load is
    -- Signals to interface with the processor
    signal w      : std_logic := '0';
    signal w_data : std_logic_vector(31 downto 0) := (others => '0');
    signal w_addr : std_logic_vector(31 downto 0) := (others => '0');

begin
    -- Instantiate the processor entity
    uut: entity work.processor
        port map (
            w      => w,
            w_data => w_data,
            w_addr => w_addr
        );

    -- Process to read the text file and drive the write ports
    load_process: process
        -- Open the file in read mode
        file text_file      : text open read_mode is "program.txt";
        variable text_line  : line;
        variable instr_bits : std_logic_vector(31 downto 0);
        variable current_addr : integer := 0;
    begin
        -- 1. Enable writing to instruction memory
        w <= '1';

        -- 2. Loop through the file until the end
        while not endfile(text_file) loop
            
            -- Read a line from the file
            readline(text_file, text_line);
            
            -- Extract the 32-bit binary string from the line
            read(text_line, instr_bits);

            -- Assign values to the processor ports
            w_data <= instr_bits;
            w_addr <= std_logic_vector(to_unsigned(current_addr, 32));

            -- Wait 1 ns to allow the processor's internal clock cycle to process the write
            wait for 1 ns;

            -- Increment address by 4 for the next 32-bit word
            current_addr := current_addr + 4;
            
        end loop;

        -- 3. Finished reading the file, disable write mode
        w <= '0';

        -- Suspend the process indefinitely
        wait;
    end process;

end behavior;