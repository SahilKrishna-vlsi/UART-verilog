`timescale 1ns/1ps
module uart_block_tb();
    reg clk1;
    reg clk2;
    reg reset;
    reg [0:7] input_data;    
    reg [0:7] parallel_data;
    wire serial_data;
    reg serial_data2;    
    reg transferBegin;    
    wire doneTx;
    wire doneRx;
    wire invalid;

    localparam clkPerBits1 = 34;
    localparam CLK_PERIOD1 = 10; 
    localparam clkPerBits2 = 17;
    localparam CLK_PERIOD2 = 20;
    
    initial begin
    	clk1=1'b0;
    	forever #(CLK_PERIOD1/2) clk1=~clk1;
    end
    
    uart_block #(clkPerBits1)Dev1(
    .clock(clk1),
    .data(input_data),
    .startTransfer(transferBegin),
    .reset(reset),
    .serialData(serial_data),
    .doneTx(doneTx)
    );
	
   always @(serial_data) begin
        #1 serial_data2 <= serial_data;
    end
    
   initial begin
    	clk2=1'b0;
    	forever #(CLK_PERIOD2/2) clk2=~clk2;
    end
    
    uart_block #(clkPerBits2)Dev2(
    .clock(clk2),
    .serialDatai(serial_data2),
    .reset(reset),
    .parallelData(parallel_data),
    .doneRx(doneRx),
    .inValid(invalid)
    );   
   
    task send_and_check (input [0:7]data_to_send);
    	 begin	
	   transferBegin = 1'b1;
           @(posedge clk1);
	   input_data = data_to_send;
           @(posedge clk1);
           transferBegin = 1'b0;
           @(posedge doneTx); 
           @(posedge doneRx);
           if (data_to_send == parallel_data)
               $display("Test Passed - Sent: %h, Received: %h", data_to_send, parallel_data);
          else
              $display("Test Failed - Sent: %h, Received: %h", data_to_send, parallel_data);
        end
    endtask
  
    
    initial begin
    	$dumpfile("dev.vcd");
    	$dumpvars(0,uart_block_tb);
    end
    
    initial begin
    	#100
	reset=1'b0;
        transferBegin = 1'b0;
        input_data = 8'b00001000;
        #100
        send_and_check(8'b10101010);
        #100
        send_and_check(8'b10111011);
        #100
        send_and_check(8'b10011011);
        #100
        send_and_check(8'b00101010);
        #1000
	$finish;
    end
    
endmodule
