library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  -- port (
    -- clk : in std_logic
  -- );
end processor;

architecture behaviour of processor is

  -- global signals
  signal clk : std_logic; -- temporary for debugging

  -- instruction fetch stage signals
  signal s_if_addr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_if_instr : std_logic_vector(31 downto 0) := (others => '0');

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

  component instrmem is
    port (
      clk : in std_logic;
      w : in std_logic;
      addr : in std_logic_vector(31 downto 0);
      w_data : in std_logic_vector(31 downto 0);
      instr : out std_logic_vector(31 downto 0)
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
    addr => s_if_addr
	);

  -- instrmem
  i: instrmem port map (
    clk => clk,
    w => '0',
    addr => s_if_addr,
    w_data => (others => '0')
    instr => s_if_instr
  );

clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;

end behaviour;