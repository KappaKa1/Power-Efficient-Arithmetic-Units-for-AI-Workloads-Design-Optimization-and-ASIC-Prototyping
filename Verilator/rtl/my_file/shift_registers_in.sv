`timescale 1ns/1ps

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

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      data_o <= '0;
    end else if (enable_i) begin
      data_o <= {data_o[BIT_WIDTH-NO_OF_PORTS-1:0], streamed_i};
    end
  end
  
endmodule
