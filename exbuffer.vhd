LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- holds values for a clock cycle for the execute stage, and can output a stall instruction
entity exbuffer is
	port (
		-- instrmem has to take in an address and return a value
		clk : in std_logic;
        stall : in std_logic;
        new_pc : in std_logic_vector(31 downto 0);
		new_reg1 : in std_logic_vector(31 downto 0);
		new_reg2 : in std_logic_vector(31 downto 0);
        new_instr : in std_logic_vector(31 downto 0);
        new_imm : in std_logic_vector(31 downto 0);
        -- control unit values
        new_mr : in std_logic;
        new_mw : in std_logic;
        new_b : in std_logic;
        new_mtr : in std_logic;
        new_alu : in std_logic;
        new_rw : in std_logic;
        pc : out std_logic_vector(31 downto 0);
        reg1 : out std_logic_vector(31 downto 0);
        reg2 : out std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0);
        imm : out std_logic_vector(31 downto 0);
        mr : out std_logic;
        mw : out std_logic;
        b : out std_logic;
        mtr : out std_logic;
        alu : out std_logic;
        rw : out std_logic
	);
end exbuffer;

architecture behaviour of exbuffer is

begin

    -- update values
    process(clk)
	begin
        if rising_edge(clk) then 
            if stall = '1' then
                -- set the outputs to a stall instr
                mr <= '0';
                mw <= '0';
                b <= '0';
                mtr <= '0';
                alu <= '0';
                rw <= '0';
                reg1 <= (others => '0');
                reg2 <= (others => '0');
                pc <= (others => '0');
                imm <= (others => '0');
                instr <= "00000000000000000000000000010011"; -- addi x0, x0, 0; instr
            else 
                pc <= new_pc;
                instr <= new_instr;
                reg1 <= new_reg1;
                reg2 <= new_reg2;
                imm <= new_imm;
                mr <= new_mr;
                mw <= new_mw;
                b <= new_b;
                mtr <= new_mtr;
                alu <= new_alu;
                rw <= new_rw;
            end if;
        end if;
	end process;

end architecture;