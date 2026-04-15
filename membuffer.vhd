LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- holds values for a clock cycle for the memory stage
entity membuffer is
	port (
		clk : in std_logic;
        flush : in std_logic;
        new_btaken : in std_logic;
        new_mr : in std_logic;
        new_mw : in std_logic;
        new_mtr : in std_logic;
        new_rw : in std_logic;
        new_jump : in std_logic;
		new_instr : in std_logic_vector(31 downto 0);
        new_reg2 : in std_logic_vector(31 downto 0);
        new_alu_res : in std_logic_vector(31 downto 0);
        new_pc_incr : in std_logic_vector(31 downto 0);
        btaken : out std_logic;
        mr : out std_logic;
        mw : out std_logic;
        mtr : out std_logic;
        rw : out std_logic;
        jump : out std_logic;
        instr : out std_logic_vector(31 downto 0);
        reg2 : out std_logic_vector(31 downto 0);
        alu_res : out std_logic_vector(31 downto 0);
        pc_incr : out std_logic_vector(31 downto 0)
	);
end membuffer;

architecture behaviour of membuffer is

begin

    -- update values
    process(clk)
	begin
        if rising_edge(clk) then
            if flush = '1' then
                btaken <= '0';
                mr <= '0';
                mw <= '0';
                mtr <= '0';
                rw <= '0';
                jump <= '0';
                instr <= (others => '0');
                reg2 <= (others => '0');
                alu_res <= (others => '0');
                pc_incr <= (others => '0');
            else
                btaken <= new_btaken;
                mr <= new_mr;
                mw <= new_mw;
                mtr <= new_mtr;
                rw <= new_rw;
                jump <= new_jump;
                instr <= new_instr;
                reg2 <= new_reg2;
                alu_res <= new_alu_res;
                pc_incr <= new_pc_incr;
            end if;
        end if;
	end process;

end architecture;