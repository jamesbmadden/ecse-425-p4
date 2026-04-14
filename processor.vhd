library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  -- port (
    -- clk : in std_logic
  -- );
end processor;

architecture behaviour of processor is

  signal s_addr : std_logic_vector(31 downto 0) := (others => '0');
  signal clk : std_logic;

  -- declare components
  component pc is
    port (
      clk : in std_logic;
      stall : in std_logic;
      w : in std_logic;
      w_addr : in std_logic_vector(31 downto 0);
      addr : out std_logic_vector(31 downto 0)
    );
  end component;

  CONSTANT clk_period : time := 1 ns;

begin
	
  -- connect to the appropriate ports of a memory instance
	p: pc port map (
		clk => clk,
		stall => '0',
		w => '0',
    		w_addr => (others => '0'),
    		addr => s_addr
	);

clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;

end behaviour;