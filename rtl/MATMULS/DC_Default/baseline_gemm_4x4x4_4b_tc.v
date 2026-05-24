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
    output signed [12:0] y_0_0,
    output signed [12:0] y_0_1,
    output signed [12:0] y_0_2,
    output signed [12:0] y_0_3,
    output signed [12:0] y_1_0,
    output signed [12:0] y_1_1,
    output signed [12:0] y_1_2,
    output signed [12:0] y_1_3,
    output signed [12:0] y_2_0,
    output signed [12:0] y_2_1,
    output signed [12:0] y_2_2,
    output signed [12:0] y_2_3,
    output signed [12:0] y_3_0,
    output signed [12:0] y_3_1,
    output signed [12:0] y_3_2,
    output signed [12:0] y_3_3
);
    assign y_0_0 = a_0_0 * b_0_0 + a_0_1 * b_1_0 + a_0_2 * b_2_0 + a_0_3 * b_3_0 + c_0_0;
    assign y_0_1 = a_0_0 * b_0_1 + a_0_1 * b_1_1 + a_0_2 * b_2_1 + a_0_3 * b_3_1 + c_0_1;
    assign y_0_2 = a_0_0 * b_0_2 + a_0_1 * b_1_2 + a_0_2 * b_2_2 + a_0_3 * b_3_2 + c_0_2;
    assign y_0_3 = a_0_0 * b_0_3 + a_0_1 * b_1_3 + a_0_2 * b_2_3 + a_0_3 * b_3_3 + c_0_3;
    assign y_1_0 = a_1_0 * b_0_0 + a_1_1 * b_1_0 + a_1_2 * b_2_0 + a_1_3 * b_3_0 + c_1_0;
    assign y_1_1 = a_1_0 * b_0_1 + a_1_1 * b_1_1 + a_1_2 * b_2_1 + a_1_3 * b_3_1 + c_1_1;
    assign y_1_2 = a_1_0 * b_0_2 + a_1_1 * b_1_2 + a_1_2 * b_2_2 + a_1_3 * b_3_2 + c_1_2;
    assign y_1_3 = a_1_0 * b_0_3 + a_1_1 * b_1_3 + a_1_2 * b_2_3 + a_1_3 * b_3_3 + c_1_3;
    assign y_2_0 = a_2_0 * b_0_0 + a_2_1 * b_1_0 + a_2_2 * b_2_0 + a_2_3 * b_3_0 + c_2_0;
    assign y_2_1 = a_2_0 * b_0_1 + a_2_1 * b_1_1 + a_2_2 * b_2_1 + a_2_3 * b_3_1 + c_2_1;
    assign y_2_2 = a_2_0 * b_0_2 + a_2_1 * b_1_2 + a_2_2 * b_2_2 + a_2_3 * b_3_2 + c_2_2;
    assign y_2_3 = a_2_0 * b_0_3 + a_2_1 * b_1_3 + a_2_2 * b_2_3 + a_2_3 * b_3_3 + c_2_3;
    assign y_3_0 = a_3_0 * b_0_0 + a_3_1 * b_1_0 + a_3_2 * b_2_0 + a_3_3 * b_3_0 + c_3_0;
    assign y_3_1 = a_3_0 * b_0_1 + a_3_1 * b_1_1 + a_3_2 * b_2_1 + a_3_3 * b_3_1 + c_3_1;
    assign y_3_2 = a_3_0 * b_0_2 + a_3_1 * b_1_2 + a_3_2 * b_2_2 + a_3_3 * b_3_2 + c_3_2;
    assign y_3_3 = a_3_0 * b_0_3 + a_3_1 * b_1_3 + a_3_2 * b_2_3 + a_3_3 * b_3_3 + c_3_3;
endmodule
