module shift_reg (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic bit_i,
  input  logic enable_i,
  output logic data_o
);

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      data_o <= 1'b0;
    end
    else if (enable_i) begin
      data_o <= bit_i;
    end
  end

endmodule
