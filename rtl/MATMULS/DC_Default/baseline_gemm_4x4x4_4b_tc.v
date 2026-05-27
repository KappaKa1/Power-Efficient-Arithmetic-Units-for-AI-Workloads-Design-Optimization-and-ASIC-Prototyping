module baseline_gemm_4x4x4_4b_tc (
    input  signed [3:0] a_0_0,
    input  signed [3:0] a_0_1,
    input  signed [3:0] a_0_2,
    input  signed [3:0] a_0_3,
    input  signed [3:0] a_1_0,
    input  signed [3:0] a_1_1,
    input  signed [3:0] a_1_2,
    input  signed [3:0] a_1_3,
    input  signed [3:0] a_2_0,
    input  signed [3:0] a_2_1,
    input  signed [3:0] a_2_2,
    input  signed [3:0] a_2_3,
    input  signed [3:0] a_3_0,
    input  signed [3:0] a_3_1,
    input  signed [3:0] a_3_2,
    input  signed [3:0] a_3_3,
    input  signed [3:0] b_0_0,
    input  signed [3:0] b_0_1,
    input  signed [3:0] b_0_2,
    input  signed [3:0] b_0_3,
    input  signed [3:0] b_1_0,
    input  signed [3:0] b_1_1,
    input  signed [3:0] b_1_2,
    input  signed [3:0] b_1_3,
    input  signed [3:0] b_2_0,
    input  signed [3:0] b_2_1,
    input  signed [3:0] b_2_2,
    input  signed [3:0] b_2_3,
    input  signed [3:0] b_3_0,
    input  signed [3:0] b_3_1,
    input  signed [3:0] b_3_2,
    input  signed [3:0] b_3_3,
    input  signed [12:0] c_0_0,
    input  signed [12:0] c_0_1,
    input  signed [12:0] c_0_2,
    input  signed [12:0] c_0_3,
    input  signed [12:0] c_1_0,
    input  signed [12:0] c_1_1,
    input  signed [12:0] c_1_2,
    input  signed [12:0] c_1_3,
    input  signed [12:0] c_2_0,
    input  signed [12:0] c_2_1,
    input  signed [12:0] c_2_2,
    input  signed [12:0] c_2_3,
    input  signed [12:0] c_3_0,
    input  signed [12:0] c_3_1,
    input  signed [12:0] c_3_2,
    input  signed [12:0] c_3_3,
    output signed [13:0] y_0_0,
    output signed [13:0] y_0_1,
    output signed [13:0] y_0_2,
    output signed [13:0] y_0_3,
    output signed [13:0] y_1_0,
    output signed [13:0] y_1_1,
    output signed [13:0] y_1_2,
    output signed [13:0] y_1_3,
    output signed [13:0] y_2_0,
    output signed [13:0] y_2_1,
    output signed [13:0] y_2_2,
    output signed [13:0] y_2_3,
    output signed [13:0] y_3_0,
    output signed [13:0] y_3_1,
    output signed [13:0] y_3_2,
    output signed [13:0] y_3_3
);
    function automatic signed [13:0] sx4(input signed [3:0] v);
        sx4 = {{10{v[3]}}, v};
    endfunction
    function automatic signed [13:0] sx13(input signed [12:0] v);
        sx13 = {{1{v[12]}}, v};
    endfunction
    assign y_0_0 = sx4(a_0_0) * sx4(b_0_0) + sx4(a_0_1) * sx4(b_1_0) + sx4(a_0_2) * sx4(b_2_0) + sx4(a_0_3) * sx4(b_3_0) + sx13(c_0_0);
    assign y_0_1 = sx4(a_0_0) * sx4(b_0_1) + sx4(a_0_1) * sx4(b_1_1) + sx4(a_0_2) * sx4(b_2_1) + sx4(a_0_3) * sx4(b_3_1) + sx13(c_0_1);
    assign y_0_2 = sx4(a_0_0) * sx4(b_0_2) + sx4(a_0_1) * sx4(b_1_2) + sx4(a_0_2) * sx4(b_2_2) + sx4(a_0_3) * sx4(b_3_2) + sx13(c_0_2);
    assign y_0_3 = sx4(a_0_0) * sx4(b_0_3) + sx4(a_0_1) * sx4(b_1_3) + sx4(a_0_2) * sx4(b_2_3) + sx4(a_0_3) * sx4(b_3_3) + sx13(c_0_3);
    assign y_1_0 = sx4(a_1_0) * sx4(b_0_0) + sx4(a_1_1) * sx4(b_1_0) + sx4(a_1_2) * sx4(b_2_0) + sx4(a_1_3) * sx4(b_3_0) + sx13(c_1_0);
    assign y_1_1 = sx4(a_1_0) * sx4(b_0_1) + sx4(a_1_1) * sx4(b_1_1) + sx4(a_1_2) * sx4(b_2_1) + sx4(a_1_3) * sx4(b_3_1) + sx13(c_1_1);
    assign y_1_2 = sx4(a_1_0) * sx4(b_0_2) + sx4(a_1_1) * sx4(b_1_2) + sx4(a_1_2) * sx4(b_2_2) + sx4(a_1_3) * sx4(b_3_2) + sx13(c_1_2);
    assign y_1_3 = sx4(a_1_0) * sx4(b_0_3) + sx4(a_1_1) * sx4(b_1_3) + sx4(a_1_2) * sx4(b_2_3) + sx4(a_1_3) * sx4(b_3_3) + sx13(c_1_3);
    assign y_2_0 = sx4(a_2_0) * sx4(b_0_0) + sx4(a_2_1) * sx4(b_1_0) + sx4(a_2_2) * sx4(b_2_0) + sx4(a_2_3) * sx4(b_3_0) + sx13(c_2_0);
    assign y_2_1 = sx4(a_2_0) * sx4(b_0_1) + sx4(a_2_1) * sx4(b_1_1) + sx4(a_2_2) * sx4(b_2_1) + sx4(a_2_3) * sx4(b_3_1) + sx13(c_2_1);
    assign y_2_2 = sx4(a_2_0) * sx4(b_0_2) + sx4(a_2_1) * sx4(b_1_2) + sx4(a_2_2) * sx4(b_2_2) + sx4(a_2_3) * sx4(b_3_2) + sx13(c_2_2);
    assign y_2_3 = sx4(a_2_0) * sx4(b_0_3) + sx4(a_2_1) * sx4(b_1_3) + sx4(a_2_2) * sx4(b_2_3) + sx4(a_2_3) * sx4(b_3_3) + sx13(c_2_3);
    assign y_3_0 = sx4(a_3_0) * sx4(b_0_0) + sx4(a_3_1) * sx4(b_1_0) + sx4(a_3_2) * sx4(b_2_0) + sx4(a_3_3) * sx4(b_3_0) + sx13(c_3_0);
    assign y_3_1 = sx4(a_3_0) * sx4(b_0_1) + sx4(a_3_1) * sx4(b_1_1) + sx4(a_3_2) * sx4(b_2_1) + sx4(a_3_3) * sx4(b_3_1) + sx13(c_3_1);
    assign y_3_2 = sx4(a_3_0) * sx4(b_0_2) + sx4(a_3_1) * sx4(b_1_2) + sx4(a_3_2) * sx4(b_2_2) + sx4(a_3_3) * sx4(b_3_2) + sx13(c_3_2);
    assign y_3_3 = sx4(a_3_0) * sx4(b_0_3) + sx4(a_3_1) * sx4(b_1_3) + sx4(a_3_2) * sx4(b_2_3) + sx4(a_3_3) * sx4(b_3_3) + sx13(c_3_3);
endmodule
