LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- holds values for a clock cycle for the execute stage, and can output a stall instruction
entity regbuffer is
	port (
		-- instrmem has to take in an address and return a value
		clk : in std_logic;
        stall : in std_logic;
        new_pc : in std_logic_vector(31 downto 0);
		new_rega : in std_logic_vector(31 downto 0);
		new_regb : in std_logic_vector(31 downto 0);
        new_instr : in std_logic_vector(31 downto 0);
        -- control unit values
        new_wb : in std_logic;
        new_mr : in std_logic;
        new_mw : in std_logic;
        pc : out std_logic_vector(31 downto 0);
        rega : out std_logic_vector(31 downto 0);
        regb : out std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0);
        wb : out std_logic;
        mr : out std_logic;
        mw : out std_logic
	);
end regbuffer;

architecture behaviour of regbuffer is

    -- implement a 1-clock delay by holding a value of pc here
    signal s_pc : std_logic_vector(31 downto 0);
    signal s_rega : std_logic_vector(31 downto 0);
    signal s_regb : std_logic_vector(31 downto 0);
    signal s_instr : std_logic_vector(31 downto 0);
    signal s_wb : std_logic;
    signal s_mr : std_logic;
    signal s_mw : std_logic;

begin

    -- update values
    process(clk)
	begin
        if stall = '1' then
            -- set the outputs to a stall instr
            wb <= '0';
            mr <= '0';
            mw <= '0';
            rega <= (others => '0');
            regb <= (others => '0');
            instr <= "00000000000000000000000000010011"; -- addi x0, x0, 0; instr
        else 
            pc <= s_pc;
            rega <= s_rega;
            regb <= s_regb;
            instr <= s_instr;
            wb <= s_wb;
            mr <= s_mr;
            mw <= s_mw;
            s_pc <= new_pc;
            s_rega <= new_rega;
            s_regb <= new_regb;
            s_instr <= new_instr;
            s_wb <= new_wb;
            s_mr <= new_mr;
            s_mw <= new_mw;
        end if;
	end process;

end architecture;