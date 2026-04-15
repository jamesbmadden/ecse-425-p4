LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- holds values for a clock cycle for the register stage, except for the memdata which is delayed
-- a clock cycle by the memory read already
entity wbbuffer is
	port (
		clk : in std_logic;
        new_mtr : in std_logic;
        new_rw : in std_logic;
        new_jump : in std_logic;
		new_alu_res : in std_logic_vector(31 downto 0);
		new_memdata : in std_logic_vector(31 downto 0);
        new_rd : in std_logic_vector(4 downto 0);
        new_pc_incr : in std_logic_vector(31 downto 0);
        mtr : out std_logic;
        rw : out std_logic;
        jump : out std_logic;
        alu_res : out std_logic_vector(31 downto 0);
        memdata : out std_logic_vector(31 downto 0);
        rd : out std_logic_vector(4 downto 0);
        pc_incr : out std_logic_vector(31 downto 0)
	);
end wbbuffer;

architecture behaviour of wbbuffer is

    -- implement a 1-clock delay by holding a value of pc here
    signal s_alu_res : std_logic_vector(31 downto 0);
    signal s_pc_incr : std_logic_vector(31 downto 0);
    signal s_rd : std_logic_vector(4 downto 0);
    signal s_mtr : std_logic;
    signal s_rw : std_logic;
    signal s_jump : std_logic;

begin

    -- update values
    process(clk)
	begin
        if rising_edge(clk) then
            mtr <= s_mtr;
            rw <= s_rw;
            alu_res <= s_alu_res;
            pc_incr <= s_pc_incr;
            rd <= s_rd;
            jump <= s_jump;
            s_mtr <= new_mtr;
            s_rw <= new_rw;
            s_alu_res <= new_alu_res;
            s_rd <= new_rd;
            s_jump <= new_jump;
            memdata <= new_memdata; -- compensate for the memory delay
            s_pc_incr <= new_pc_incr;
        end if;
	end process;

end architecture;