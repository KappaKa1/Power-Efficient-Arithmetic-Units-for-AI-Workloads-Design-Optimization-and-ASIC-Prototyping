module mux_7to1_onehot #(
  parameter int WIDTH = 16
)(
  input  logic [WIDTH-1:0] in [7], // Expanded to 7 inputs
  input  logic [6:0]       sel,    // Expanded to 7-bit select line
  output logic [WIDTH-1:0] out
);

  always_comb begin
    out = '0;

    unique case (1'b1)
      sel[0]: out = in[0];
      sel[1]: out = in[1];
      sel[2]: out = in[2];
      sel[3]: out = in[3];
      sel[4]: out = in[4];
      sel[5]: out = in[5];
      sel[6]: out = in[6];
      default: out = '0;
    endcase
  end
 
endmodule
