`timescale 1ns/1ps

module pack14to16_signext #(
  parameter int IN_WIDTH  = 224,
  parameter int PAD_WIDTH = 256,
  parameter int OUTPUT_WIDTH = 64
)(
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 en_i,
  input  logic 		       load_i,

  input  logic [IN_WIDTH-1:0]  data_i,
  output logic [OUTPUT_WIDTH-1:0] data_o
);

  logic [PAD_WIDTH-1:0] padded_data_q, padded_data_d;
  assign data_o = padded_data_q[63:0];

  // ---------------- COMBINATIONAL PACK ----------------
  always_comb begin
    padded_data_d = padded_data_q;

    for (int g = 0; g < 4; g++) begin
      for (int i = 0; i < 4; i++) begin
        logic [13:0] val;

        val = data_i[g*56 + i*14 +: 14];

        padded_data_d[g*64 + i*16 +: 16] = {{2{val[13]}}, val};
      end
    end
  end

  // ---------------- REGISTER WITH ENABLE ----------------
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      padded_data_q <= '0;
    end else if (load_i) begin
      padded_data_q <= padded_data_d;
    end else if(en_i) begin 
      padded_data_q <= {64'd0, padded_data_q[255:64]}; // shift immediately
    end
  end

endmodule
