LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- instrmem is a wrapper around the given memory component for interacting with memory
-- (RETURN WILL BE DELAYED BY A CLOCKCYCLE BY THE UNDERLYING MEMORY)
entity instrmem is
	port (
		-- instrmem has to take in an address and return a value
		clk : in std_logic;
		addr : in std_logic_vector(31 downto 0);
		instr : out std_logic_vector(31 downto 0);
	);
end instrmem;

architecture behaviour of instrmem is

	signal memread : std_logic := '0';
	signal waitrequest : std_logic;

	component memory is
		PORT (
			clock: IN STD_LOGIC;
			writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			address: IN INTEGER RANGE 0 TO ram_size-1;
			memwrite: IN STD_LOGIC;
			memread: IN STD_LOGIC;
			readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			waitrequest: OUT STD_LOGIC
		);
	end component;
	
begin

	-- on clock cycle, ask for a new read. it will be done on the next clock cycle
	process(clk)
	begin
		memread <= '1';
	end process;

	-- connect to the appropriate ports of a memory instance
	MEM: memory port map (
		clock => clk,
		writedata => open,
		address => addr,
		memwrite => open,
		memread => memread,
		readdata => instr,
		waitrequest => waitrequest
	);

end architecture;