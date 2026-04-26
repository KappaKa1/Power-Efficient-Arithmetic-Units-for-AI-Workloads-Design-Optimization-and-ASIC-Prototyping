`timescale 1ns/1ps

module mux2to1 #(
  parameter int unsigned BIT_WIDTH   	= 8
)(
    input  logic 	 		sel_i,      // select
    input  logic [BIT_WIDTH-1:0] 	a_i,      // input 0
    input  logic [BIT_WIDTH-1:0] 	b_i,      // input 1
    output logic [BIT_WIDTH-1:0] 	y_o       // output
);

    assign y_o= sel_i ? b_i : a_i;

endmodule
