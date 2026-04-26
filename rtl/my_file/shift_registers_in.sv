`timescale 1ns/1ps
`include "common_cells/registers.svh"

module shift_registers_in #(
  parameter int unsigned BIT_WIDTH   = 64,
  parameter int unsigned NO_OF_PORTS = 16
)(
  input  logic                    clk_i,
  input  logic                    rst_ni,
  input  logic [NO_OF_PORTS-1:0]  streamed_i,
  input  logic                    enable_i,
  output logic [BIT_WIDTH-1:0]    data_o
);

  `FFL(data_o,  {data_o[BIT_WIDTH-NO_OF_PORTS-1:0], streamed_i}, enable_i, '0, clk_i, rst_ni)
  
endmodule
