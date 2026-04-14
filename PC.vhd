LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- pc manages the program counter, and either increments it or updates it to a new given value
entity pc is
	port (
		-- pc will need to output current address, and take in clock and new address to set it to
		clk : in std_logic;
		stall : in std_logic;
		w : in std_logic; -- whether to do a write from the w_addr input or just increment
		w_addr : in std_logic_vector(31 downto 0);
		addr : out std_logic_vector(31 downto 0)
	);
end pc;

architecture behaviour of pc is

	-- internally keep track of the current pc address
	signal s_addr : std_logic_vector(31 downto 0) := (others => '0');
	
begin

	-- 
	process(clk)
	begin
	
		if rising_edge(clk) then
			-- output the current count
			addr <= s_addr;
		
			-- only update the value if not stalling
			if stall = '0' then
				if w = '1' then
					-- set the signal to the inputted addr
					s_addr <= w_addr;
				else
					-- just increment
					s_addr <= std_logic_vector(unsigned(s_addr) + 4);
				end if;
			end if;
		end if;
	
	end process;

end architecture;