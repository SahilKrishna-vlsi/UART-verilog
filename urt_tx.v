`timescale 1ns/1ps
module urt_tx #(parameter bitsPerClk=10)(
    input clk,
    input rst,
    input tx_signal,
    input [0:7] data,
    output reg sed,
    output reg datas

);
    reg [bitsPerClk-1:0] Clck=0;

    localparam idel = 3'b000;

    localparam start = 3'b001;

     localparam transferdata = 3'b010;

     localparam done = 3'b011;

     localparam parity1 = 3'b100;

    reg [2:0] state=0;

    reg parity;

    reg [3:0] bit_counter   = 0;

    reg [0:10] datatx; // 0- start 1 2 3 4 5 6 7 8 9parity 10stop



    always@(posedge clk)
    begin
	    if(~rst)
	    begin
		case(state)
			    idel:
			    begin
				Clck<=0;
				sed<=1'b0;
				datas<=1'b1;
				bit_counter<=0;
				if(tx_signal==1'b1)
				    state <= parity1;
				else
				    state <= idel;
			    end

			    parity1:
			    begin
				parity <= data[0]^data[1]^data[2]^data[3]^data[4]^data[5]^data[6]^data[7];
				state <= start;
			    end

			    start:
			    begin
				datas<=1'b0;
				if(Clck < bitsPerClk-1)
				    begin
					Clck<=Clck+1;
					state<=start;
				    end
				else begin
				    datatx <= {data,parity,1'b1};
				    state <= transferdata;
				end
			    end

			    transferdata:
			    begin
				if(Clck < bitsPerClk-1)
				    begin
					Clck <= Clck+1;
					datas <= datatx[bit_counter];
				    end
				else
				    begin
					Clck <= 0;
					bit_counter <= bit_counter+1'b1;
					if(bit_counter == 4'b1010)
					    state <= done;
					else
					    state <= transferdata;
				    end
			    end

			    done:
			    begin
				state<=idel;
				sed=1'd1;
			    end
			    
			    default:
			    state <= idel;
			    
			endcase
		    end
	    else
	    begin
	    	Clck<=0;
		sed<=1'b0;
		datas<=1'b1;
		bit_counter<=0;
	    end
	end

endmodule
