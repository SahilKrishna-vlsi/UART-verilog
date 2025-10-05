#setting test bench
iverilog -g2012 -o uart1 urt_tx.v urt_rx.v uart_block.v uart_block_tb.v
#simulating the testbench
vvp uart1
#launching gtkwave
gtkwave dev.vcd
