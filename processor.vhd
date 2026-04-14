library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  port (
    -- clk : in std_logic;
    -- rst : in std_logic;
    w : in std_logic;
    w_data : in std_logic_vector(31 downto 0);
    w_addr : in std_logic_vector(31 downto 0)
  );
end processor;

architecture behaviour of processor is

  -- global signals
  signal clk : std_logic; -- temporary for debugging
  signal rst : std_logic; -- temporary for debugging

  -- instruction fetch stage signals
  signal s_if_addr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_if_instr : std_logic_vector(31 downto 0) := (others => '0');

  -- register stage signals
  signal s_re_pc : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_instr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_wd : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_d1 : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_d2 : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_imm : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_regwrite : std_logic := '0';
  signal s_c_b : std_logic := '0'; -- control unit things to pass to the exbuffer
  signal s_c_alu : std_logic := '0';
  signal s_c_mr : std_logic := '0'; -- MemRed
  signal s_c_mw : std_logic := '0'; -- MemWrite
  signal s_c_mtr : std_logic := '0'; -- MemToReg
  signal s_c_rw : std_logic := '0'; -- RegWrite


  -- declare components
  -- instruction fetch stage components
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

  component regbuffer is
    port (
      clk : in std_logic;
      new_pc : in std_logic_vector(31 downto 0);
      new_instr : in std_logic_vector(31 downto 0);
      pc : out std_logic_vector(31 downto 0);
      instr : out std_logic_vector(31 downto 0)
    );
  end component;

  -- register stage components
  component register_file is
    port (
      clk        : in std_logic;
      reset      : in std_logic;
      reg_write  : in std_logic;
      
      instr      : in std_logic_vector(31 downto 0);
      write_data : in std_logic_vector(31 downto 0);

      rs1_data   : out std_logic_vector(31 downto 0);
      rs2_data   : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmGen is
    Port (
      instruction : in std_logic_vector(31 downto 0);
      ExtImm : out std_logic_vector(31 downto 0)
    );
  end component;

  component control is
    Port (
      opcode : in  std_logic_vector (6 downto 0);
      --execution
      ALUSrc : out std_logic;
      --memory
      Branch : out std_logic;
      MemRead : out std_logic;
      MemWrite : out std_logic; 
      --write back
      MemtoReg : out std_logic;
      RegWrite : out std_logic
    );
  end component;

  CONSTANT clk_period : time := 1 ns;

begin
	
  -- connect to the appropriate ports of a memory instance
  -- instruction fetch stage (pc, instrmem, regbuf)
	if_pc: pc port map (
		clk => clk,
		stall => w, -- program shouldn't continue while instrmem write is going
		w => '0',
    w_addr => (others => '0'),
    addr => s_if_addr
	);

  if_im: instrmem port map (
    clk => clk,
    w => w,
    addr => s_if_addr,
    w_data => w_data,
    instr => s_if_instr
  );

  b_reg: regbuffer port map (
    clk => clk,
    new_pc => s_if_addr,
    new_instr => s_if_instr,
    pc => s_re_pc,
    instr => s_re_instr
  );

  -- register stage (register file, immediate generator/sign extender)
  re_fi: register_file port map (
    clk => clk,
    reset => rst,
    reg_write => s_re_regwrite,
    instr => s_re_instr,
    write_data => (others => '0'),
    rs1_data => s_re_d1,
    rs2_data => s_re_d2
  );

  re_ig: ImmGen port map (
    instruction => s_re_instr,
    ExtImm => s_re_imm
  );

  re_ct: control port map (
    opcode => s_re_instr(6 downto 0),
    ALUSrc => s_c_alu,
    Branch => s_c_b,
    MemRead => s_c_mr,
    MemWrite => s_c_mw,
    MemtoReg => s_c_mtr,
    RegWrite => s_c_rw
  );

-- for testing: generate a clock here
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;

write_process : process(w)
begin
  if w = '1' then
    s_if_addr <= w_addr;
  end if;
end process;

end behaviour;