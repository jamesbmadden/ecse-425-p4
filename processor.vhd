library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  port (
    -- tbd
  );
end processor;

architecture behaviour of pipeline is

  -- declare the memory component
  component memory is
    port ();
  end component;

begin
  -- create instr memory
  instr: memory 
    port map (
      
    );

  -- create data memory
  data: memory 
    port map (
      
    );

end behaviour;