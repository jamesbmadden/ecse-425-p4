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
        variable failures : integer := 0;
    begin
        wait for 2 ns;

        -- sw x"12345678" to address 0
        addr <= x"00000000";
        writedata <= x"12345678";
        funct3 <= "010";
        memwrite <= '1';
        memread <= '0';
        wait until rising_edge(clk);
        memwrite <= '0';
        wait for 1 ps;

        -- lw from address 0
        addr <= x"00000000";
        funct3 <= "010";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"12345678" then
            assert false report "lw failed after sw at address 0" severity error;
            failures := failures + 1;
        end if;

        -- sb x"ab" to address 1
        addr <= x"00000001";
        writedata <= x"000000AB";
        funct3 <= "000";
        memwrite <= '1';
        wait until rising_edge(clk);
        memwrite <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;

        -- lbu from address 1
        addr <= x"00000001";
        funct3 <= "100";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"000000AB" then
            assert false report "lbu failed at address 1" severity error;
            failures := failures + 1;
        end if;

        -- lb from address 1
        addr <= x"00000001";
        funct3 <= "000";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"FFFFFFAB" then
            assert false report "lb failed sign extension at address 1" severity error;
            failures := failures + 1;
        end if;

        -- lw from address 0
        addr <= x"00000000";
        funct3 <= "010";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"1234AB78" then
            assert false report "word contents wrong after sb" severity error;
            failures := failures + 1;
        end if;

        -- sh x"cdef" to address 2
        addr <= x"00000002";
        writedata <= x"0000CDEF";
        funct3 <= "001";
        memwrite <= '1';
        wait until rising_edge(clk);
        memwrite <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;

        -- lhu from address 2
        addr <= x"00000002";
        funct3 <= "101";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"0000CDEF" then
            assert false report "lhu failed at address 2" severity error;
            failures := failures + 1;
        end if;

        -- lh from address 2
        addr <= x"00000002";
        funct3 <= "001";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"FFFFCDEF" then
            assert false report "lh failed sign extension at address 2" severity error;
            failures := failures + 1;
        end if;

        -- lw from address 0
        addr <= x"00000000";
        funct3 <= "010";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"CDEFAB78" then
            assert false report "word contents wrong after sh to upper halfword" severity error;
            failures := failures + 1;
        end if;

        -- sh x"007f" to address 0
        addr <= x"00000000";
        writedata <= x"0000007F";
        funct3 <= "001";
        memwrite <= '1';
        wait until rising_edge(clk);
        memwrite <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;

        -- lhu from address 0
        addr <= x"00000000";
        funct3 <= "101";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"0000007F" then
            assert false report "lhu failed at address 0" severity error;
            failures := failures + 1;
        end if;

        -- lh from address 0
        addr <= x"00000000";
        funct3 <= "001";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"0000007F" then
            assert false report "lh failed positive halfword case" severity error;
            failures := failures + 1;
        end if;

        -- final lw from address 0
        addr <= x"00000000";
        funct3 <= "010";
        memread <= '1';
        wait until rising_edge(clk);
        memread <= '0';
        wait until rising_edge(clk);
        wait for 1 ps;
        if readdata /= x"CDEF007F" then
            assert false report "final lw check failed" severity error;
            failures := failures + 1;
        end if;

        if failures = 0 then
            assert false report "datamem test passed" severity note;
        else
            assert false report "datamem test failed" severity failure;
        end if;

        wait;
    end process;

end tb;