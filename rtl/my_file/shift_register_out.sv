`timescale 1ns/1ps

module shift_registers_out #(
  parameter int unsigned BIT_WIDTH   = 64,
  parameter int unsigned NO_OF_PORTS = 16
)(
  input  logic                     clk_i,
  input  logic                     rst_ni,
  input  logic [BIT_WIDTH-1:0]     data_i,
  input  logic                     load_i,
  output logic [NO_OF_PORTS-1:0]   data_o
);

  logic [BIT_WIDTH-1:0] data_to_stream;
  assign data_o = data_to_stream[BIT_WIDTH-1 -: NO_OF_PORTS];
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      data_to_stream <= '0;
    end else begin
      if (load_i) begin
        data_to_stream <= data_i;
      end else begin
        data_to_stream <= {data_to_stream[BIT_WIDTH-NO_OF_PORTS-1:0], {NO_OF_PORTS{1'b0}}};
      end
    end
  end

endmodule
