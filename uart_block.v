`timescale 1ns/1ps
module uart_block#(parameter bitsPerClk=5208)(
	input clock,
	input [0:7] data,
	input startTransfer,
	input serialDatai,
	input reset,
	output reg [0:7] parallelData,
	output reg serialData,
	output reg doneRx,
	output reg doneTx,
	output reg inValid
);

        urt_tx	#(bitsPerClk)uart_tx(
        	.clk(clock),
        	.rst(reset),
        	.tx_signal(startTransfer),
        	.data(data),
        	.sed(doneTx),
        	.datas(serialData)
        );
        
        urt_rx #(bitsPerClk)uart_rx(
        	.clk(clock),
        	.rst(reset),
        	.datar(serialDatai),
        	.data(parallelData),
        	.prob(inValid),
        	.red(doneRx)
        );
        

endmodule
