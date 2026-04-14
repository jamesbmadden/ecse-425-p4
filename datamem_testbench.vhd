library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datamem_tb is
end datamem_tb;

architecture tb of datamem_tb is

    constant clk_period : time := 1 ns;

    signal clk : std_logic := '0';
    signal addr : std_logic_vector(31 downto 0) := (others => '0');
    signal writedata : std_logic_vector(31 downto 0) := (others => '0');
    signal funct3 : std_logic_vector(2 downto 0) := (others => '0');
    signal memwrite : std_logic := '0';
    signal memread : std_logic := '0';
    signal readdata : std_logic_vector(31 downto 0);
    signal waitrequest : std_logic;

begin
    uut : entity work.datamem
        port map (
            clk => clk,
            addr => addr,
            writedata => writedata,
            funct3 => funct3,
            memwrite => memwrite,
            memread => memread,
            readdata => readdata,
            waitrequest => waitrequest
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        wait for 2 ns;

        -- write a full word at address 0
        addr <= x"00000000";
        writedata <= x"12345678";
        funct3 <= "010";
        memwrite <= '1';
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        memwrite <= '0';

        -- read it back with lw
        addr <= x"00000000";
        funct3 <= "010";
        memread <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"12345678"
            report "lw failed after sw at address 0"
            severity error;
        memread <= '0';

        -- overwrite byte at address 1 with ab
        addr <= x"00000001";
        writedata <= x"000000AB";
        funct3 <= "000";
        memwrite <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        memwrite <= '0';

        -- read unsigned byte
        addr <= x"00000001";
        funct3 <= "100";
        memread <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"000000AB"
            report "lbu failed at address 1"
            severity error;

        -- read signed byte
        addr <= x"00000001";
        funct3 <= "000";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"FFFFFFAB"
            report "lb failed sign extension at address 1"
            severity error;

        -- read whole word again to check byte update
        addr <= x"00000000";
        funct3 <= "010";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"1234AB78"
            report "word contents wrong after sb"
            severity error;
        memread <= '0';

        -- overwrite upper halfword at address 2 with cdef
        addr <= x"00000002";
        writedata <= x"0000CDEF";
        funct3 <= "001";
        memwrite <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        memwrite <= '0';

        -- read unsigned halfword
        addr <= x"00000002";
        funct3 <= "101";
        memread <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"0000CDEF"
            report "lhu failed at address 2"
            severity error;

        -- read signed halfword
        addr <= x"00000002";
        funct3 <= "001";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"FFFFCDEF"
            report "lh failed sign extension at address 2"
            severity error;

        -- read whole word again to check halfword update
        addr <= x"00000000";
        funct3 <= "010";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"CDEFAB78"
            report "word contents wrong after sh to upper halfword"
            severity error;
        memread <= '0';

        -- overwrite lower halfword with 007f
        addr <= x"00000000";
        writedata <= x"0000007F";
        funct3 <= "001";
        memwrite <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        memwrite <= '0';

        -- lhu should zero extend
        addr <= x"00000000";
        funct3 <= "101";
        memread <= '1';
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"0000007F"
            report "lhu failed at address 0"
            severity error;

        -- lh should also stay positive here
        addr <= x"00000000";
        funct3 <= "001";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"0000007F"
            report "lh failed positive halfword case"
            severity error;

        -- final word check
        addr <= x"00000000";
        funct3 <= "010";
        wait until rising_edge(clk);
        wait for 1 ps;
        assert readdata = x"CDEF007F"
            report "final lw check failed"
            severity error;
        memread <= '0';

        assert false report "datamem test passed" severity note;
        wait;
    end process;

end tb;