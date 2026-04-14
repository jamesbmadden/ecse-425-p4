library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datamem is
    port (
        clk : in std_logic;
        addr : in std_logic_vector(31 downto 0);
        writedata : in std_logic_vector(31 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        memwrite : in std_logic;
        memread : in std_logic;
        readdata : out std_logic_vector(31 downto 0);
        waitrequest : out std_logic
    );
end datamem;

architecture behaviour of datamem is

    type state_type is (idle, load_wait, rmw_wait);
    signal state : state_type := idle;

    signal addrint : integer range 0 to 32767 := 0;
    signal addr_reg : integer range 0 to 32767 := 0;
    signal funct3_reg : std_logic_vector(2 downto 0) := (others => '0');
    signal writedata_reg : std_logic_vector(31 downto 0) := (others => '0');

    signal mem_addr : integer range 0 to 32767 := 0;
    signal mem_writedata : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_readdata : std_logic_vector(31 downto 0);
    signal memwrite_i : std_logic := '0';
    signal memread_i : std_logic := '0';
    signal mem_waitrequest : std_logic;

    signal readdata_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal waitrequest_reg : std_logic := '0';

    component memory is
        generic(
            ram_size : integer := 32768;
            mem_delay : time := 1 ns;
            clock_period : time := 1 ns
        );
        port (
            clock : in std_logic;
            writedata : in std_logic_vector(31 downto 0);
            address : in integer range 0 to ram_size-1;
            memwrite : in std_logic;
            memread : in std_logic;
            readdata : out std_logic_vector(31 downto 0);
            waitrequest : out std_logic
        );
    end component;

    function swap_word(x : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable y : std_logic_vector(31 downto 0);
    begin
        y := x(7 downto 0) & x(15 downto 8) & x(23 downto 16) & x(31 downto 24);
        return y;
    end function;

    function format_load(f3 : std_logic_vector(2 downto 0); x : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable y : std_logic_vector(31 downto 0);
        variable b : std_logic_vector(7 downto 0);
        variable h : std_logic_vector(15 downto 0);
    begin
        y := (others => '0');
        b := x(31 downto 24);
        h := x(23 downto 16) & x(31 downto 24);

        case f3 is
            when "000" =>
                y(7 downto 0) := b;
                if b(7) = '1' then
                    y(31 downto 8) := (others => '1');
                else
                    y(31 downto 8) := (others => '0');
                end if;

            when "100" =>
                y(7 downto 0) := b;
                y(31 downto 8) := (others => '0');

            when "001" =>
                y(15 downto 0) := h;
                if h(15) = '1' then
                    y(31 downto 16) := (others => '1');
                else
                    y(31 downto 16) := (others => '0');
                end if;

            when "101" =>
                y(15 downto 0) := h;
                y(31 downto 16) := (others => '0');

            when "010" =>
                y := swap_word(x);

            when others =>
                y := (others => '0');
        end case;

        return y;
    end function;

    function rmw_word(f3 : std_logic_vector(2 downto 0); newdata : std_logic_vector(31 downto 0); oldword : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable y : std_logic_vector(31 downto 0);
    begin
        y := oldword;

        case f3 is
            when "000" =>
                y := newdata(7 downto 0) & oldword(23 downto 0);

            when "001" =>
                y := newdata(7 downto 0) & newdata(15 downto 8) & oldword(15 downto 0);

            when "010" =>
                y := swap_word(newdata);

            when others =>
                y := oldword;
        end case;

        return y;
    end function;

begin

    addrint <= to_integer(unsigned(addr(14 downto 0)));

    mem_inst : memory
        port map(
            clock => clk,
            writedata => mem_writedata,
            address => mem_addr,
            memwrite => memwrite_i,
            memread => memread_i,
            readdata => mem_readdata,
            waitrequest => mem_waitrequest
        );

    process(state, memread, memwrite, addrint, addr_reg, funct3, funct3_reg, writedata, writedata_reg, mem_readdata)
    begin
        memread_i <= '0';
        memwrite_i <= '0';
        mem_addr <= addrint;
        mem_writedata <= (others => '0');
        waitrequest_reg <= '0';

        case state is
            when idle =>
                if memread = '1' then
                    memread_i <= '1';
                    mem_addr <= addrint;
                    waitrequest_reg <= '1';
                elsif memwrite = '1' then
                    waitrequest_reg <= '1';
                    if funct3 = "010" then
                        memwrite_i <= '1';
                        mem_addr <= addrint;
                        mem_writedata <= swap_word(writedata);
                    else
                        memread_i <= '1';
                        mem_addr <= addrint;
                    end if;
                end if;

            when load_wait =>
                waitrequest_reg <= '1';

            when rmw_wait =>
                waitrequest_reg <= '1';
                memwrite_i <= '1';
                mem_addr <= addr_reg;
                mem_writedata <= rmw_word(funct3_reg, writedata_reg, mem_readdata);
        end case;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when idle =>
                    if memread = '1' then
                        addr_reg <= addrint;
                        funct3_reg <= funct3;
                        state <= load_wait;
                    elsif memwrite = '1' then
                        addr_reg <= addrint;
                        funct3_reg <= funct3;
                        writedata_reg <= writedata;
                        if funct3 = "010" then
                            state <= idle;
                        else
                            state <= rmw_wait;
                        end if;
                    end if;

                when load_wait =>
                    readdata_reg <= format_load(funct3_reg, mem_readdata);
                    state <= idle;

                when rmw_wait =>
                    state <= idle;
            end case;
        end if;
    end process;

    readdata <= readdata_reg;
    waitrequest <= waitrequest_reg;

end behaviour;