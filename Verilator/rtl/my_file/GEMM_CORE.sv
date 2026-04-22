`timescale 1ns/1ps

module GEMM_CORE #(
  parameter int unsigned SRAM_DATA_WIDTH        	= 64,
  parameter int unsigned FINAL_DATA_WIDTH        	= 224
)(
  input logic 				clk_i,
  input logic 				rst_ni,
 
  input logic 				enable_i,
  input logic 				result_valid_i,
  
  input logic [SRAM_DATA_WIDTH-1:0] 	operand_A_i,
  input logic [SRAM_DATA_WIDTH-1:0] 	operand_B_i,
  
  output logic[FINAL_DATA_WIDTH-1:0] 	final_results_o
);

  logic [SRAM_DATA_WIDTH - 1 : 0] 					operand_A_q, operand_A_d;
  logic [SRAM_DATA_WIDTH - 1 : 0] 					operand_B_q, operand_B_d;
  logic [FINAL_DATA_WIDTH - 1 : 0]					intermediate_result_q, intermediate_result_d;
  logic [FINAL_DATA_WIDTH - 1 : 0] 					final_results;

  matmul_4x4x4_int4_tc_cw13_4to2_sklansky_fused_speed u_matmul (
    .a_0_0(operand_A_q[3:0]),      .a_0_1(operand_A_q[7:4]),      .a_0_2(operand_A_q[11:8]),     .a_0_3(operand_A_q[15:12]),
    .a_1_0(operand_A_q[19:16]),    .a_1_1(operand_A_q[23:20]),    .a_1_2(operand_A_q[27:24]),    .a_1_3(operand_A_q[31:28]),
    .a_2_0(operand_A_q[35:32]),    .a_2_1(operand_A_q[39:36]),    .a_2_2(operand_A_q[43:40]),    .a_2_3(operand_A_q[47:44]),
    .a_3_0(operand_A_q[51:48]),    .a_3_1(operand_A_q[55:52]),    .a_3_2(operand_A_q[59:56]),    .a_3_3(operand_A_q[63:60]),

    .b_0_0(operand_B_q[3:0]),      .b_0_1(operand_B_q[7:4]),      .b_0_2(operand_B_q[11:8]),     .b_0_3(operand_B_q[15:12]),
    .b_1_0(operand_B_q[19:16]),    .b_1_1(operand_B_q[23:20]),    .b_1_2(operand_B_q[27:24]),    .b_1_3(operand_B_q[31:28]),
    .b_2_0(operand_B_q[35:32]),    .b_2_1(operand_B_q[39:36]),    .b_2_2(operand_B_q[43:40]),    .b_2_3(operand_B_q[47:44]),
    .b_3_0(operand_B_q[51:48]),    .b_3_1(operand_B_q[55:52]),    .b_3_2(operand_B_q[59:56]),    .b_3_3(operand_B_q[63:60]),

    .c_0_0(intermediate_result_q[12:0]),      .c_0_1(intermediate_result_q[26:14]),    .c_0_2(intermediate_result_q[40:28]),    .c_0_3(intermediate_result_q[54:42]),
    .c_1_0(intermediate_result_q[68:56]),     .c_1_1(intermediate_result_q[82:70]),    .c_1_2(intermediate_result_q[96:84]),    .c_1_3(intermediate_result_q[110:98]),
    .c_2_0(intermediate_result_q[124:112]),   .c_2_1(intermediate_result_q[138:126]),  .c_2_2(intermediate_result_q[152:140]),  .c_2_3(intermediate_result_q[166:154]),
    .c_3_0(intermediate_result_q[180:168]),   .c_3_1(intermediate_result_q[194:182]),  .c_3_2(intermediate_result_q[208:196]),  .c_3_3(intermediate_result_q[222:210]),

    .y_0_0(final_results[12:0]),      .y_0_1(final_results[26:14]),     .y_0_2(final_results[40:28]),     .y_0_3(final_results[54:42]),
    .y_1_0(final_results[68:56]),     .y_1_1(final_results[82:70]),     .y_1_2(final_results[96:84]),     .y_1_3(final_results[110:98]),
    .y_2_0(final_results[124:112]),   .y_2_1(final_results[138:126]),   .y_2_2(final_results[152:140]),   .y_2_3(final_results[166:154]),
    .y_3_0(final_results[180:168]),   .y_3_1(final_results[194:182]),   .y_3_2(final_results[208:196]),   .y_3_3(final_results[222:210])
  );
 
  always_comb begin
    operand_A_d = '0;
    operand_B_d = '0;
    intermediate_result_d = '0;
    final_results_o = '0;
    
    if(enable_i) begin
      operand_A_d = operand_A_i;
      operand_B_d = operand_B_i;
      intermediate_result_d = final_results; // Feed by MATMUL output as well.
      final_results_o = final_results;
    end
  end
    
 
   always_ff @(posedge clk_i) begin
    if(!rst_ni) begin
      operand_A_q <= '0;
      operand_B_q <= '0;
      intermediate_result_q <= '0;

    end else if(result_valid_i) begin
      operand_A_q <= operand_A_d;
      operand_B_q <= operand_B_d;
      intermediate_result_q <= '0;

    end else begin
      operand_A_q <= operand_A_d;
      operand_B_q <= operand_B_d;
      intermediate_result_q <= intermediate_result_d;
    end
  end
endmodule
