`timescale 1ns/1ps
module urt_rx #(parameter bitsPerClk=10) (
    input clk,
    input rst,
    input datar,
    output reg [0:7]data,
    output reg prob,
    output reg red
);

    localparam idel = 3'b000;

    localparam start = 3'b001;

    localparam receiveData = 3'b010;

    localparam done = 3'b011;

    reg [bitsPerClk-1:0] clck=0;

    reg [2:0] state=0;

    reg parity;

    reg [3:0] bit_counter   = 0;

    reg [0:10] datarx;

    always@(posedge clk)
    begin
    if(~rst)
    begin
        case(state)

            idel:
            begin
                clck<=0;
                prob<=1'b0;
                red<=1'b0;
                if(datar==1'b0)
                    begin
                        bit_counter<=0;
                        datarx[0]<=1'b0;
                        state = receiveData;
                    end
                else
                    state <= idel;
            end

            start:
            begin
                parity = datarx[1]^datarx[2]^datarx[3]^datarx[4]^datarx[5]^datarx[6]^datarx[7]^datarx[8];
                if(parity ^ datarx[9]!=1'b0)
                begin
                    prob <= 1'b1;
                    data <= 8'bxxxxxxxx;
                    state <= idel;
                end
                data <= datarx[1:8];
                state <= done;
            end

            receiveData:
            begin

                if(clck < bitsPerClk-1)
                    begin
                        clck<=clck+1;
						datarx[bit_counter] <= datar;
                    end
                else begin
                    clck<=0;
                    bit_counter = bit_counter+1'b1;
                    if(bit_counter == 4'b1011) state <= start;
                    else state <= receiveData;
                end
            end

            done:
            begin
                state <= idel;
                red <= 1'd1;
                prob<=1'b0;
                data <= datarx[1:8];
            end
            
        	  default:
        	    state <= idel;
        	endcase
    	end
    
	else
	begin
		 clck<=0;
                prob<=1'b0;
                red<=1'b0;
                data<=8'bx;
	end
end

endmodule
