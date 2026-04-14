library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  port (
    clk : in std_logic;
    w : in std_logic;
    w_data : in std_logic_vector(31 downto 0);
    w_addr : in std_logic_vector(31 downto 0)
  );
end processor;

architecture behaviour of processor is

  -- instruction fetch stage signals
  signal s_if_addr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_if_instr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_pc_out : std_logic_vector(31 downto 0) := (others => '0');
  signal s_pc_stall : std_logic;

  -- register stage signals
  signal s_re_pc : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_instr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_wd : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_d1 : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_d2 : std_logic_vector(31 downto 0) := (others => '0');
  signal s_re_imm : std_logic_vector(31 downto 0) := (others => '0');
  signal s_c_b : std_logic := '0'; -- control unit things to pass to the exbuffer
  signal s_c_alu : std_logic := '0';
  signal s_c_mr : std_logic := '0'; -- MemRed
  signal s_c_mw : std_logic := '0'; -- MemWrite
  signal s_c_mtr : std_logic := '0'; -- MemToReg
  signal s_c_rw : std_logic := '0'; -- RegWrite

  -- execution buffer signals
  signal b_ex_mr : std_logic := '0';
  signal b_ex_mw : std_logic := '0';
  signal b_ex_b : std_logic := '0';
  signal b_ex_mtr : std_logic := '0';
  signal b_ex_alu : std_logic := '0';
  signal b_ex_rw : std_logic := '0';
  signal b_ex_pc : std_logic_vector(31 downto 0);
  signal b_ex_reg1 : std_logic_vector(31 downto 0);
  signal b_ex_reg2 : std_logic_vector(31 downto 0);
  signal b_ex_instr : std_logic_vector(31 downto 0);
  signal b_ex_imm : std_logic_vector(31 downto 0);

  -- execution stage signals
  signal s_ex_ALUControl : std_logic_vector(3 downto 0);
  signal s_ex_ALUResult : std_logic_vector(31 downto 0);
  signal s_ex_alu_srcB : std_logic_vector(31 downto 0);
  signal s_ex_btake : std_logic;

  -- memory buffer signals
  signal b_mem_btaken : std_logic;
  signal b_mem_mr : std_logic;
  signal b_mem_mw : std_logic;
  signal b_mem_mtr : std_logic;
  signal b_mem_rw : std_logic;
  signal b_mem_instr : std_logic_vector(31 downto 0);
  signal b_mem_reg2 : std_logic_vector(31 downto 0);
  signal b_mem_alu_res : std_logic_vector(31 downto 0);

  -- memory stage signals
  signal s_mem_data : std_logic_vector(31 downto 0);
  signal s_mem_waitreq : std_logic;

  -- writeback buffer signals
  signal b_wb_mtr : std_logic;
  signal b_wb_rw : std_logic;
  signal b_wb_alu_res : std_logic_vector(31 downto 0);
  signal b_wb_data : std_logic_vector(31 downto 0);
  signal b_wb_rd : std_logic_vector(4 downto 0);

  -- writeback stage signals
  signal s_wb_data : std_logic_vector(31 downto 0);

  -- hazard detection signals
  signal s_hdu_stall : std_logic := '0';

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
      stall : in std_logic;
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
      w_addr     : in std_logic_vector(4 downto 0);

      rs1_data   : out std_logic_vector(31 downto 0);
      rs2_data   : out std_logic_vector(31 downto 0)
    );
  end component;

  component ImmGen is
    port (
      instruction : in std_logic_vector(31 downto 0);
      ExtImm : out std_logic_vector(31 downto 0)
    );
  end component;

  component control is
    port (
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

  -- execution buffer
  component exbuffer is
    port (
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
  end component;

  -- execute stage components
  component ALUdecoder is
    port (
      opcode : in std_logic_vector(6 downto 0);
      funct3 : in std_logic_vector(2 downto 0);
      funct7 : in std_logic_vector(6 downto 0);
      ALUControl : out std_logic_vector(3 downto 0)
    );
  end component;

  component ALU is
    port (
      srcA : in std_logic_vector(31 downto 0);
      srcB : in std_logic_vector(31 downto 0);
      ALUControl : in std_logic_vector(3 downto 0);
      ALUResult : out std_logic_vector(31 downto 0)
    );
  end component;

  component comparator is
    port (
      rs1_data : in std_logic_vector(31 downto 0);
      rs2_data : in std_logic_vector(31 downto 0);
      branch_en : in std_logic;
      funct3 : in std_logic_vector(2 downto 0);
      branch_take : out std_logic
    );
  end component;

  -- memory buffer
  component membuffer is
	  port (
      clk : in std_logic;
      new_btaken : in std_logic;
      new_mr : in std_logic;
      new_mw : in std_logic;
      new_mtr : in std_logic;
      new_rw : in std_logic;
      new_instr : in std_logic_vector(31 downto 0);
      new_reg2 : in std_logic_vector(31 downto 0);
      new_alu_res : in std_logic_vector(31 downto 0);
      btaken : out std_logic;
      mr : out std_logic;
      mw : out std_logic;
      mtr : out std_logic;
      rw : out std_logic;
      instr : out std_logic_vector(31 downto 0);
      reg2 : out std_logic_vector(31 downto 0);
      alu_res : out std_logic_vector(31 downto 0)
	  );
  end component;

  -- memory stage components
  component datamem is
    port (
      clk : in std_logic;
      addr : in std_logic_vector(31 downto 0);
      writedata : in std_logic_vector(31 downto 0);
      funct3 : in std_logic_vector(2 downto 0);
      memwrite : in std_logic;
      memread : in std_logic;
      readdata : out std_logic_vector(31 downto 0);
      waitrequest : out std_logic
    );
  end component;

  -- FINALLY, the write-back buffer!
  component wbbuffer is
	  port (
		  clk : in std_logic;
      new_mtr : in std_logic;
      new_rw : in std_logic;
		  new_alu_res : in std_logic_vector(31 downto 0);
		  new_memdata : in std_logic_vector(31 downto 0);
      new_rd : in std_logic_vector(4 downto 0);
      mtr : out std_logic;
      rw : out std_logic;
      alu_res : out std_logic_vector(31 downto 0);
      memdata : out std_logic_vector(31 downto 0);
      rd : out std_logic_vector(4 downto 0)
	  );
  end component;


  CONSTANT clk_period : time := 1 ns;

begin

  -- this is the multiplexer for reg2 or immediate before the ALU
  s_ex_alu_srcB <= b_ex_imm when b_ex_alu = '1' else b_ex_reg2;
  -- select write address in write mode, otherwise pc output
  s_if_addr <= w_addr when w = '1' else s_pc_out;
  -- select what will get written back to the register
  s_wb_data <= b_wb_data when b_wb_mtr = '1' else b_wb_alu_res;
  -- whether the pc should stall
  s_pc_stall <= w or s_hdu_stall;
	
  -- connect to the appropriate ports of a memory instance
  -- instruction fetch stage (pc, instrmem, regbuf)
	if_pc: pc port map (
		clk => clk,
		stall => s_pc_stall, -- program shouldn't continue while instrmem write is going
		w => b_mem_btaken,
    w_addr => s_ex_alu_srcB,
    addr => s_pc_out
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
    stall => s_hdu_stall,
    new_pc => s_if_addr,
    new_instr => s_if_instr,
    pc => s_re_pc,
    instr => s_re_instr
  );

  -- register stage (register file, immediate generator/sign extender)
  re_fi: register_file port map (
    clk => clk,
    reset => '0',
    reg_write => b_wb_rw,
    instr => s_re_instr,
    write_data => s_wb_data,
    w_addr => b_wb_rd,
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

  -- execution buffer
  b_ex: exbuffer port map (
    clk => clk,
    stall => s_hdu_stall,
    new_pc => s_re_pc,
    new_reg1 => s_re_d1,
    new_reg2 => s_re_d2,
    new_instr => s_re_instr,
    new_imm => s_re_imm,
    new_mr => s_c_mr,
    new_mw => s_c_mw,
    new_b => s_c_b,
    new_mtr => s_c_mtr,
    new_alu => s_c_alu,
    new_rw => s_c_rw,
    pc => b_ex_pc,
    reg1 => b_ex_reg1,
    reg2 => b_ex_reg2,
    instr => b_ex_instr,
    imm => b_ex_imm,
    mr => b_ex_mr,
    mw => b_ex_mw,
    b => b_ex_b,
    mtr => b_ex_mtr,
    alu => b_ex_alu,
    rw => b_ex_rw
  );

  -- execution stage components
  ex_alude: ALUdecoder port map (
    opcode => b_ex_instr(6 downto 0),
    funct3 => b_ex_instr(14 downto 12),
    funct7 => b_ex_instr(31 downto 25),
    ALUControl => s_ex_ALUControl
  );

  ex_alu: ALU port map (
    srcA => b_ex_reg1,
    srcB => s_ex_alu_srcB,
    ALUControl => s_ex_ALUControl,
    ALUResult => s_ex_ALUResult
  );

  ex_cmp: comparator port map (
    rs1_data => b_ex_reg1,
    rs2_data => b_ex_reg2,
    branch_en => b_ex_b,
    funct3 => b_ex_instr(14 downto 12),
    branch_take => s_ex_btake
  );

  -- memory buffer (almost there!!)
  b_mem: membuffer port map (
    clk => clk,
    new_btaken => b_mem_btaken,
    new_mr => b_mem_mr,
    new_mw => b_mem_mw,
    new_mtr => b_mem_mtr,
    new_rw => b_mem_rw,
    new_instr => b_mem_instr,
    new_reg2 => b_mem_reg2,
    new_alu_res => b_mem_alu_res,
    btaken => s_ex_btake,
    mr => b_ex_mr,
    mw => b_ex_mw,
    mtr => b_ex_mtr,
    rw => b_ex_rw,
    instr => b_ex_instr,
    reg2 => b_ex_reg2,
    alu_res => s_ex_ALUResult
  );

  -- memory stage components
  mem_mem: datamem port map (
    clk => clk,
    addr => b_mem_alu_res,
    writedata => b_mem_reg2,
    funct3 => b_mem_instr(14 downto 12),
    memwrite => b_mem_mw,
    memread => b_mem_mr,
    readdata => s_mem_data,
    waitrequest => s_mem_waitreq
  );

  -- FINALLY, the writeback buffer
  b_wb: wbbuffer port map (
    clk => clk,
    new_mtr => b_mem_mtr,
    new_rw => b_mem_rw,
		new_alu_res => b_mem_alu_res,
		new_memdata => s_mem_data,
    new_rd => b_mem_instr(11 downto 7), -- rd from the current instr
    mtr => b_wb_mtr,
    rw => b_wb_rw,
    alu_res => b_wb_alu_res,
    memdata => b_wb_data,
    rd => b_wb_rd
  );

-- hazard detection 
-- stalls if register stage needs a register that's gonna be written to
process(s_re_instr, b_ex_instr, b_mem_instr, b_wb_rd, b_ex_rw, b_mem_rw, b_wb_rw)

  variable rs1, rs2 : std_logic_vector(4 downto 0);
  variable ex_rd, mem_rd : std_logic_vector(4 downto 0);

begin
  rs1 := s_re_instr(19 downto 15);
  rs2 := s_re_instr(24 downto 20);
  ex_rd := b_ex_instr(11 downto 7);
  mem_rd := b_mem_instr(11 downto 7);
    
  s_hdu_stall <= '0';

  -- read after write hazards
  if (rs1 /= "00000") then
    if (rs1 = ex_rd and b_ex_rw = '1') or 
      (rs1 = mem_rd and b_mem_rw = '1') or 
      (rs1 = b_wb_rd and b_wb_rw = '1') then
      s_hdu_stall <= '1';
    end if;
  end if;

  if (rs2 /= "00000") then
    if (rs2 = ex_rd and b_ex_rw = '1') or 
      (rs2 = mem_rd and b_mem_rw = '1') or 
      (rs2 = b_wb_rd and b_wb_rw = '1') then
      s_hdu_stall <= '1';
    end if;
  end if;
end process;

end behaviour;