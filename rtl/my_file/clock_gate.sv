module clock_gate (
  input  logic clk_i,
  input  logic en_i,
  output logic clk_o
);

  CGTSX1 u_cg (
    .ECK(clk_o),
    .E  (en_i),
    .SE (1'b0),
    .CK (clk_i)
  );
endmodule
