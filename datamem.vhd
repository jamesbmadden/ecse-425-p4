library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datamem is
    port (
        clk : in std_logic;
        addr : in std _logic_vector(31 downto 0);
        writedata : in std_logic_vector(31 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        memwrite : in std_logic;
        memread : in std_logic;
        readdata : out std_logic_vector(31 downto 0);
        waitrequest : out std_logic
    );
end datamem;

architecture behaviour of datamem is

    component memory is
        generic(
            ram_size : integer := 32768;
            mem_delay : time := 1 ns;
            clock_period : time := 1 ns
        );
        port (
            clock : in std_logic;
            writedata : in std_logic_vector(7 downto 0);
            address : in integer range 0 to ram_size-1;
            memwrite : in std_logic;
            memread : in std_logic;
            readdata : out std_logic_vector(7 downto 0);
            waitrequest : out std_logic
        );
    end component;

    constant words : integer := 32768 / 4;

    signal word_addr : integer range 0 to words-1;
    signal byte_offset : std_logic_vector(1 downto 0);

    signal lane0_in : std_logic_vector(7 downto 0);
    signal lane1_in : std_logic_vector(7 downto 0);
    signal lane2_in : std_logic_vector(7 downto 0);
    signal lane3_in : std_logic_vector(7 downto 0);

    signal lane0_out : std_logic_vector(7 downto 0);
    signal lane1_out : std_logic_vector(7 downto 0);
    signal lane2_out : std_logic_vector(7 downto 0);
    signal lane3_out : std_logic_vector(7 downto 0);

    signal wr0 : std_logic;
    signal wr1 : std_logic;
    signal wr2 : std_logic;
    signal wr3 : std_logic;

    signal wait0 : std_logic;
    signal wait1 : std_logic;
    signal wait2 : std_logic;
    signal wait3 : std_logic;

begin
    word_addr <= to_integer(unsigned(addr(14 downto 2)));
    byte_offset <= addr(1 downto 0);

    process(memwrite, funct3, byte_offset, writedata)
    begin
        wr0 <= '0';
        wr1 <= '0';
        wr2 <= '0';
        wr3 <= '0';

        lane0_in <= (others => '0');
        lane1_in <= (others => '0');
        lane2_in <= (others => '0');
        lane3_in <= (others => '0');

        case funct3 is
            when "000" =>
                case byte_offset is
                    when "00" =>
                        wr0 <= memwrite;
                        lane0_in <= writedata(7 downto 0);
                    when "01" =>
                        wr1 <= memwrite;
                        lane1_in <= writedata(7 downto 0);
                    when "10" =>
                        wr2 <= memwrite;
                        lane2_in <= writedata(7 downto 0);
                    when others =>
                        wr3 <= memwrite;
                        lane3_in <= writedata(7 downto 0);
                end case;

            when "001" =>
                if byte_offset(1) = '0' then
                    wr0 <= memwrite;
                    wr1 <= memwrite;
                    lane0_in <= writedata(7 downto 0);
                    lane1_in <= writedata(15 downto 8);
                else
                    wr2 <= memwrite;
                    wr3 <= memwrite;
                    lane2_in <= writedata(7 downto 0);
                    lane3_in <= writedata(15 downto 8);
                end if;

            when "010" =>
                wr0 <= memwrite;
                wr1 <= memwrite;
                wr2 <= memwrite;
                wr3 <= memwrite;
                lane0_in <= writedata(7 downto 0);
                lane1_in <= writedata(15 downto 8);
                lane2_in <= writedata(23 downto 16);
                lane3_in <= writedata(31 downto 24);

            when others =>
                null;
        end case;
    end process;

    mem0 : memory
        generic map(
            ram_size => words
        )
        port map(
            clock => clk,
            writedata => lane0_in,
            address => word_addr,
            memwrite => wr0,
            memread => memread,
            readdata => lane0_out,
            waitrequest => wait0
        );

    mem1 : memory
        generic map(
            ram_size => words
        )
        port map(
            clock => clk,
            writedata => lane1_in,
            address => word_addr,
            memwrite => wr1,
            memread => memread,
            readdata => lane1_out,
            waitrequest => wait1
        );

    mem2 : memory
        generic map(
            ram_size => words
        )
        port map(
            clock => clk,
            writedata => lane2_in,
            address => word_addr,
            memwrite => wr2,
            memread => memread,
            readdata => lane2_out,
            waitrequest => wait2
        );

    mem3 : memory
        generic map(
            ram_size => words
        )
        port map(
            clock => clk,
            writedata => lane3_in,
            address => word_addr,
            memwrite => wr3,
            memread => memread,
            readdata => lane3_out,
            waitrequest => wait3
        );

    process(memread, funct3, byte_offset, lane0_out, lane1_out, lane2_out, lane3_out)
        variable b : std_logic_vector(7 downto 0);
        variable h : std_logic_vector(15 downto 0);
        variable w : std_logic_vector(31 downto 0);
        variable outv : std_logic_vector(31 downto 0);
    begin
        outv := (others => '0');

        w := lane3_out & lane2_out & lane1_out & lane0_out;

        case byte_offset is
            when "00" => b := lane0_out;
            when "01" => b := lane1_out;
            when "10" => b := lane2_out;
            when others => b := lane3_out;
        end case;

        if byte_offset(1) = '0' then
            h := lane1_out & lane0_out;
        else
            h := lane3_out & lane2_out;
        end if;

        if memread = '1' then
            case funct3 is
                when "000" =>
                    outv(7 downto 0) := b;
                    if b(7) = '1' then
                        outv(31 downto 8) := (others => '1');
                    else
                        outv(31 downto 8) := (others => '0');
                    end if;

                when "100" =>
                    outv(7 downto 0) := b;
                    outv(31 downto 8) := (others => '0');

                when "001" =>
                    outv(15 downto 0) := h;
                    if h(15) = '1' then
                        outv(31 downto 16) := (others => '1');
                    else
                        outv(31 downto 16) := (others => '0');
                    end if;

                when "101" =>
                    outv(15 downto 0) := h;
                    outv(31 downto 16) := (others => '0');

                when "010" =>
                    outv := w;

                when others =>
                    outv := (others => '0');
            end case;
        end if;

        readdata <= outv;
    end process;

    waitrequest <= wait0 and wait1 and wait2 and wait3;

end behaviour;