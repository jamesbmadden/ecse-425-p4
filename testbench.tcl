vsim work.processor

# start the clock (1 GHz = 1 ns period)
force -freeze sim:/processor/clk 0 0, 1 {500 ps} -repeat 1 ns

# initialize instruction memory writing signals
force -freeze sim:/processor/w 0
force -freeze sim:/processor/w_addr 10#0
force -freeze sim:/processor/w_data 10#0

# open file
set fp_in [open "program.txt" r]
set addr 0

puts "Loading program into instruction memory..."
while {[gets $fp_in line] >= 0} {
    # skip empty lines
    set line [string trim $line]
    if {[string length $line] == 32} {
        force -freeze sim:/processor/w 1
        force -freeze sim:/processor/w_addr 10#$addr
        force -freeze sim:/processor/w_data 2#$line
        
        # step one clock cycle to write to memory
        run 1 ns
        
        incr addr 4
    }
}
close $fp_in

# disable writing to instruction memory and reset writing signals
force -freeze sim:/processor/w 0
force -freeze sim:/processor/w_addr 10#0
force -freeze sim:/processor/w_data 10#0

puts "Executing program for 10,000 cycles..."
# run the processor for 10,000 cycles
run 10000 ns

# extract Register File to "register_file.txt"
puts "Dumping register file..."
set fp_reg [open "register_file.txt" w]
for {set i 0} {$i < 32} {incr i} {
    set raw_val [examine -binary sim:/processor/re_fi/regs($i)]
    
    regsub -all {[{}]} $raw_val "" clean_val
    puts $fp_reg $clean_val
}
close $fp_reg

# extract Data Memory contents to "memory.txt"
puts "Dumping data memory..."
set fp_mem [open "memory.txt" w]

for {set i 0} {$i < 32768} {incr i 4} {
    # extract 4 bytes
    set b3 [examine -binary sim:/processor/mem_mem/mem_inst/ram_block($i)]
    set b2 [examine -binary sim:/processor/mem_mem/mem_inst/ram_block([expr {$i + 1}])]
    set b1 [examine -binary sim:/processor/mem_mem/mem_inst/ram_block([expr {$i + 2}])]
    set b0 [examine -binary sim:/processor/mem_mem/mem_inst/ram_block([expr {$i + 3}])]
    
    regsub -all {[{}]} $b3 "" b3
    regsub -all {[{}]} $b2 "" b2
    regsub -all {[{}]} $b1 "" b1
    regsub -all {[{}]} $b0 "" b0
    
    # make 32-bit word and write to file
    puts $fp_mem "${b3}${b2}${b1}${b0}"
}
close $fp_mem

puts "Simulation finished. Output files generated."