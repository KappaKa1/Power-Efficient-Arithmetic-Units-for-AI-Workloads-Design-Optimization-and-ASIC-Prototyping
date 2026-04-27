module clock_gate (
  input  logic clk_i,
  input  logic en_i,
  output logic clk_o
);

  logic en_latched;

  // Latch enable while clock is low
  always_latch begin
    if (!clk_i) begin
      en_latched <= en_i;
    end
  end

  // Gate clock with stable latched enable
  assign clk_o = clk_i & en_latched;

endmodule
