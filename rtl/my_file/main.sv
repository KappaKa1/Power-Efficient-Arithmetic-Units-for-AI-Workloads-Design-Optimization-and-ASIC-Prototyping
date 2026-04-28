
// After Receiving ACK_o from Chip, Testing Device must wait 1 more cycle for correct output to be received.

// [1] - Things to parameterize when possible
`timescale 1ns/1ps
`include "common_cells/registers.svh"

module main #(
  // Individual Parameters depending on the inputs, can potentially calculate the number of OUTPUT bits from INPUT bits.
  parameter int unsigned INPUT_SRAM_NUM_WORDS   	= 64, // CHANGE back to 64 after
  parameter int unsigned INPUT_NUM_BITS  		= 4,
  parameter int unsigned OUTPUT_SRAM_NUM_WORDS  	= 256,
  parameter int unsigned OUTPUT_NUM_BITS	  	= 16, // Actually 13, but round to upper 2^x.
  parameter int unsigned NUM_OF_STREAMING_PORTS		= 16,
  
  // Common Parameters
  parameter int unsigned SRAM_DATA_WIDTH        	= 64,
  parameter int unsigned MATRIX_DIMENSION 		= 32*32, // What size of matrix is being inputted
  parameter int unsigned SIZE_OF_FINAL_OUTPUT 		= 224,
  
  // Calculated Parameters, DO NOT TOUCH !!
  parameter int unsigned INPUT_SRAM_ADDR_WIDTH        	= 8,
  parameter int unsigned OUTPUT_SRAM_ADDR_WIDTH        	= 8,
  parameter int unsigned GEMM_SELECT_WIDTH        	= 5,
  parameter int unsigned ENCODING_SCHEME_WIDTH        	= 3
)
(
  input logic 						clk_i,
  input logic 						rst_ni,
  
  input logic 						req_i, 
  input logic 						we_i, 
  input logic 						streamed_wdata_0_i, // LSB
  input logic 						streamed_wdata_1_i,
  input logic 						streamed_wdata_2_i,
  input logic 						streamed_wdata_3_i,
  input logic 						streamed_wdata_4_i,
  input logic 						streamed_wdata_5_i,
  input logic 						streamed_wdata_6_i,
  input logic 						streamed_wdata_7_i,
  input logic 						streamed_wdata_8_i,
  input logic 						streamed_wdata_9_i,
  input logic 						streamed_wdata_10_i,
  input logic 						streamed_wdata_11_i,
  input logic 						streamed_wdata_12_i,
  input logic 						streamed_wdata_13_i,
  input logic 						streamed_wdata_14_i,
  input logic 						streamed_wdata_15_i, // MSB
  
  output logic 						ready_o,
  output logic 						finish_o,
  output logic 						ack_o,
  output logic  					streamed_rdata_0_o, // LSB
  output logic  					streamed_rdata_1_o,  
  output logic  					streamed_rdata_2_o,
  output logic  					streamed_rdata_3_o,
  output logic  					streamed_rdata_4_o,
  output logic  					streamed_rdata_5_o,  
  output logic  					streamed_rdata_6_o,
  output logic  					streamed_rdata_7_o,
  output logic  					streamed_rdata_8_o,
  output logic  					streamed_rdata_9_o,  
  output logic  					streamed_rdata_10_o,
  output logic  					streamed_rdata_11_o,
  output logic  					streamed_rdata_12_o,
  output logic  					streamed_rdata_13_o,  
  output logic  					streamed_rdata_14_o,
  output logic  					streamed_rdata_15_o // MSB         
);
  
  // ------------------------------------ SIGNALS USED to Stabilize input/output for TEST DEVICE ------------------------------------------
  logic req_q, req_d, req_ctrl;
  logic we_q, we_d, we_ctrl;
  logic ready_q, ready_d, ready_ctrl;
  logic finish_q, finish_d, finish_ctrl;
  logic ack_q, ack_d, ack_ctrl;
  
  assign req_d = req_i;
  assign req_ctrl = req_q;
  assign we_d = we_i;
  assign we_ctrl = we_q;
  assign ready_d = ready_ctrl;
  assign ready_o = ready_q;
  assign finish_d = finish_ctrl;
  assign finish_o = finish_q;
  assign ack_d = ack_ctrl;
  assign ack_o = ack_q;
  
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      req_q <= '0;
      we_q <= '0;
      ready_q <= '0;
      finish_q <= '0;
      ack_q <= '0;
    end else begin
      req_q <= req_d;
      we_q <= we_d;
      ready_q <= ready_d;
      finish_q <= finish_d;
      ack_q <= ack_d;
    end
  end
  
  // ------------------------------------ SIGNALS USED IN SRAM & GEMM Controller ------------------------------------------
  // Control Signals for Encoding
  logic	[ENCODING_SCHEME_WIDTH-1 : 0]		encode_enable;
  logic [SRAM_DATA_WIDTH-1:0] 			encoded_wdata;
  
  // Control Signals for Padding
  logic						pad_load;
  logic						pad_enable;
  logic [63:0] 					final_data_padded; // 64 bits
  // Control Signals for Shift Register
  logic 					sr_inp_enable;
  logic 					sr_out_load;
  
  // Control Signals for SRAM Macros
  logic [3 - 1 :0] 				sram_req, sram_we; // MSB is Highest index and is Output, [1]
  
  // Control Signals for GEMM Cores
  logic [GEMM_SELECT_WIDTH :0]			GEMM_ctrl_packet; // Communication signal from SRAM Controller to GEMM Controller
  logic 					done; // Communication signal from GEMM Controller to SRAM Controller
  logic	[GEMM_SELECT_WIDTH - 1:0]		GEMM_enable, GEMM_start;
  logic [SIZE_OF_FINAL_OUTPUT - 1 :0] 		GEMM_results [0:GEMM_SELECT_WIDTH-1]; 
  
  // Control Signals for MUX
  logic 					mux_sel;
  
  // Data registers for Shift Register
  logic [NUM_OF_STREAMING_PORTS-1:0]		streamed_wdata, streamed_rdata;
  logic [SRAM_DATA_WIDTH-1:0] 			final64_wdata, initial64_rdata;
  
  // SRAM Data Registers
  logic [INPUT_SRAM_ADDR_WIDTH - 1 :0] 		SRAM_gen_inp_sram_addr; // Generate Address for Input Loading
  logic [OUTPUT_SRAM_ADDR_WIDTH - 1 :0] 	SRAM_gen_out_sram_addr; // Generate Address for Input Loading
  logic [INPUT_SRAM_ADDR_WIDTH - 1 :0] 		GEMM_gen_inp_A_sram_addr; // Generate Address for Input Loading
  logic [INPUT_SRAM_ADDR_WIDTH - 1 :0] 		GEMM_gen_inp_B_sram_addr; // Generate Address for Input Loading
  logic [INPUT_SRAM_ADDR_WIDTH - 1 :0] 		generate_inp_A_sram_addr; // Generate Address for Input Loading
  logic [INPUT_SRAM_ADDR_WIDTH - 1 :0] 		generate_inp_B_sram_addr; // Generate Address for Input Loading
  
  logic [SRAM_DATA_WIDTH - 1 :0] 		sram_write; // Write data into input SRAMs
  logic [SRAM_DATA_WIDTH - 1 :0] 		sram_read; // Read data out from output SRAM
  logic [SRAM_DATA_WIDTH-1:0] 			SRAM_out_1, SRAM_out_2; // Data for GEMM operands A and B

  // Shared Registers between SRAM Controller and GEMM Controller, Using number first before using Parameters
  logic [SIZE_OF_FINAL_OUTPUT - 1 : 0]		final_results, final_data_q, final_data_d;
  logic [OUTPUT_SRAM_ADDR_WIDTH - 1 : 0]	result_addr, result_addr_q, result_addr_d;
  logic						result_valid, result_valid_q, result_valid_d;
  // ----------------------------------------------------------------------------------------------------------------------  
 
  // -----------------------------------------
  // Instantiating Encoding Block
  // -----------------------------------------  
  //encoder #(.WIDTH(64), .ENCODING_SCHEME_WIDTH(ENCODING_SCHEME_WIDTH)) encoder_main (.en_i(encode_enable), .data_i(final64_wdata), .encoded_o(encoded_wdata));
  
  // -----------------------------------------
  // Instantiating Padding Registers
  // -----------------------------------------
  pack14to16_signext u_pack14to16 (.clk_i(clk_i), .rst_ni(rst_ni), .en_i(pad_enable), .load_i(result_valid_q), .data_i(final_data_q), .data_o(final_data_padded));
  
  // -----------------------------------------
  // Instantiating MUX gates for Address Generation Selection
  // -----------------------------------------
  mux2to1 inp_A_sram_gen (.sel_i(mux_sel), .a_i(SRAM_gen_inp_sram_addr), .b_i(GEMM_gen_inp_A_sram_addr), .y_o(generate_inp_A_sram_addr));
  mux2to1 inp_B_sram_gen (.sel_i(mux_sel), .a_i(SRAM_gen_inp_sram_addr), .b_i(GEMM_gen_inp_B_sram_addr), .y_o(generate_inp_B_sram_addr));
  
  // -----------------------------------------
  // Instantiating SHIFT REGISTERS USED TO STREAM DATA IN
  // -----------------------------------------
  assign streamed_wdata = {
    streamed_wdata_15_i,
    streamed_wdata_14_i,
    streamed_wdata_13_i,
    streamed_wdata_12_i,
    streamed_wdata_11_i,
    streamed_wdata_10_i,
    streamed_wdata_9_i,
    streamed_wdata_8_i,
    streamed_wdata_7_i,
    streamed_wdata_6_i,
    streamed_wdata_5_i,
    streamed_wdata_4_i,
    streamed_wdata_3_i,
    streamed_wdata_2_i,
    streamed_wdata_1_i,
    streamed_wdata_0_i
  };
  shift_registers_in #(.BIT_WIDTH(SRAM_DATA_WIDTH), .NO_OF_PORTS(NUM_OF_STREAMING_PORTS)) sr_inp (.clk_i(clk_i), .rst_ni(rst_ni), .streamed_i(streamed_wdata), .enable_i(sr_inp_enable), .data_o(final64_wdata));
  
  assign sram_write = final64_wdata; // or encoded_wdata if enable encoding

  assign {
    streamed_rdata_15_o,
    streamed_rdata_14_o,
    streamed_rdata_13_o,
    streamed_rdata_12_o,
    streamed_rdata_11_o,
    streamed_rdata_10_o,
    streamed_rdata_9_o,
    streamed_rdata_8_o,
    streamed_rdata_7_o,
    streamed_rdata_6_o,
    streamed_rdata_5_o,
    streamed_rdata_4_o,
    streamed_rdata_3_o,
    streamed_rdata_2_o,
    streamed_rdata_1_o,
    streamed_rdata_0_o
  } = streamed_rdata;
  shift_registers_out #(.BIT_WIDTH(SRAM_DATA_WIDTH), .NO_OF_PORTS(NUM_OF_STREAMING_PORTS)) sr_out (.clk_i(clk_i), .rst_ni(rst_ni), .data_i(initial64_rdata), .load_i(sr_out_load), .data_o(streamed_rdata));
  assign initial64_rdata = sram_read;
  
  // -----------------------------------------
  // Instantiating SRAM Controller + SRAMs
  // -----------------------------------------
  SRAM_controller #(
    .INPUT_SRAM_NUM_WORDS(INPUT_SRAM_NUM_WORDS),
    .INPUT_NUM_BITS(INPUT_NUM_BITS),
    .OUTPUT_SRAM_NUM_WORDS(OUTPUT_SRAM_NUM_WORDS),
    .OUTPUT_NUM_BITS(OUTPUT_NUM_BITS),
    .NUM_OF_STREAMING_PORTS(NUM_OF_STREAMING_PORTS),
    
    .SRAM_DATA_WIDTH(SRAM_DATA_WIDTH),
    .MATRIX_DIMENSION(MATRIX_DIMENSION)
  ) ctrl (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .ctrl_packet_i(streamed_wdata),

    .encode_enable_o (encode_enable),

    .pad_load_o(pad_load),
    .pad_enable_o(pad_enable),

    .sr_inp_enable_o(sr_inp_enable),
    .sr_out_load_o(sr_out_load),
    
    .sram_req_o(sram_req),
    .sram_we_o(sram_we),
    .sram_inp_addr_o(SRAM_gen_inp_sram_addr),
    .sram_out_addr_o(SRAM_gen_out_sram_addr),
    .mux_sel_o(mux_sel),
    
    .GEMM_ctrl_packet_o(GEMM_ctrl_packet),
    
    .done_i(done),
    .result_valid_i(result_valid_q), 
    .result_addr_i(result_addr_q),
    
    .ext_req_i(req_ctrl),
    .ext_we_i(we_ctrl),
    
    .ext_ready_o(ready_ctrl),
    .ext_finish_o(finish_ctrl),
    .ext_ack_o(ack_ctrl)
  );
  
  // -----------------------------------------
  // GEMM Controller + GEMM Cores
  // -----------------------------------------
  GEMM_controller u_gemm_ctrl (
    .clk_i               (clk_i),
    .rst_ni              (rst_ni),

    // control from SRAM controller
    .GEMM_ctrl_packet_i  (GEMM_ctrl_packet),

    // control to GEMM core
    .enable_o		 (GEMM_enable),
    .start_o		 (GEMM_start),

    // addresses to SRAM
    .gemm_inp_A_addr_o   (GEMM_gen_inp_A_sram_addr),
    .gemm_inp_B_addr_o   (GEMM_gen_inp_B_sram_addr),

    // handshake back
    .done_o              (done),

    // result interface
    .result_valid_o      (result_valid),
    .gemm_out_Y_addr_o   (result_addr)
  );
  
  GEMM_CORE # (.SRAM_DATA_WIDTH(SRAM_DATA_WIDTH), .FINAL_DATA_WIDTH(SIZE_OF_FINAL_OUTPUT), .MATMUL_TYPE("TC_SKLANSKY_FUSED_SPEED")) mul0 (.clk_i(clk_i), .rst_ni(rst_ni), .enable_i(GEMM_enable[0]), .result_valid_i(result_valid), .done_i(done), .start_i(GEMM_start[0]), .operand_A_i(SRAM_out_1), .operand_B_i(SRAM_out_2), .final_results_o(GEMM_results[0]));
  
  GEMM_CORE # (.SRAM_DATA_WIDTH(SRAM_DATA_WIDTH), .FINAL_DATA_WIDTH(SIZE_OF_FINAL_OUTPUT), .MATMUL_TYPE("TC_SKLANSKY_FUSED_AREA")) mul1 (.clk_i(clk_i), .rst_ni(rst_ni), .enable_i(GEMM_enable[1]), .result_valid_i(result_valid), .done_i(done), .start_i(GEMM_start[1]), .operand_A_i(SRAM_out_1), .operand_B_i(SRAM_out_2), .final_results_o(GEMM_results[1]));
  
  mux_5to1_onehot #(.WIDTH(SIZE_OF_FINAL_OUTPUT)) select_final_result (.in(GEMM_results), .sel(GEMM_enable), .out(final_results));
  
  
  assign final_data_d = final_results;
  assign result_addr_d = result_addr;
  assign result_valid_d = result_valid;

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      result_valid_q <= '0;
    end else begin
      result_valid_q <= result_valid_d;
    end
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      result_addr_q <= '0;
      final_data_q <= '0;
    end else if (result_valid_d) begin
      result_addr_q <= result_addr_d;
      final_data_q <= final_data_d;
    end
  end
  
  
  // -----------------------------------------
  // Instantiating the SRAM of size 256 x 64
  // -----------------------------------------
  RM_IHPSG13_1P_64x64_c2_bm_bist inp_sram_1 ( // Assume Row-order
     .A_CLK   ( clk_i     ),
     .A_DLY   ( 1'b1     ),
     .A_ADDR  ( generate_inp_A_sram_addr ),
     .A_BM    ( 64'hFFFF_FFFF_FFFF_FFFF ),
     .A_MEN   ( sram_req[0]  ),
     .A_WEN   ( sram_we[0]   ),
     .A_REN   ( ~sram_we[0]  ),
     .A_DIN        ( sram_write ),
     .A_DOUT       ( SRAM_out_1  ),
     .A_BIST_CLK   (  1'b0 ),
     .A_BIST_ADDR  ( 11'd0 ),
     .A_BIST_DIN   ( 64'd0 ),
     .A_BIST_BM    ( 64'd0 ),
     .A_BIST_MEN   (  1'b0 ),
     .A_BIST_WEN   (  1'b0 ),
     .A_BIST_REN   (  1'b0 ),
     .A_BIST_EN    (  1'b0 )
  );
  
  RM_IHPSG13_1P_64x64_c2_bm_bist inp_sram_2 ( // Assume Column-order
     .A_CLK   ( clk_i     ),
     .A_DLY   ( 1'b1      ),
     .A_ADDR  ( generate_inp_B_sram_addr ),
     .A_BM    ( 64'hFFFF_FFFF_FFFF_FFFF ),
     .A_MEN   ( sram_req[1]  ),
     .A_WEN   ( sram_we[1]   ),
     .A_REN   ( ~sram_we[1]  ),
     .A_DIN        ( sram_write ),
     .A_DOUT       ( SRAM_out_2  ),
     .A_BIST_CLK   (  1'b0 ),
     .A_BIST_ADDR  ( 11'd0 ),
     .A_BIST_DIN   ( 64'd0 ),
     .A_BIST_BM    ( 64'd0 ),
     .A_BIST_MEN   (  1'b0 ),
     .A_BIST_WEN   (  1'b0 ),
     .A_BIST_REN   (  1'b0 ),
     .A_BIST_EN    (  1'b0 )
  );
  
  RM_IHPSG13_1P_256x64_c2_bm_bist out_sram (
     .A_CLK   ( clk_i     ),
     .A_DLY   ( 1'b1   ),
     .A_ADDR  ( SRAM_gen_out_sram_addr ),
     .A_BM    ( 64'hFFFF_FFFF_FFFF_FFFF ),
     .A_MEN   ( sram_req[2]  ),
     .A_WEN   ( sram_we[2]   ),
     .A_REN   ( ~sram_we[2]  ),
     .A_DIN        ( final_data_padded ),
     .A_DOUT       ( sram_read  ),
     .A_BIST_CLK   (  1'b0 ),
     .A_BIST_ADDR  ( 11'd0 ),
     .A_BIST_DIN   ( 64'd0 ),
     .A_BIST_BM    ( 64'd0 ),
     .A_BIST_MEN   (  1'b0 ),
     .A_BIST_WEN   (  1'b0 ),
     .A_BIST_REN   (  1'b0 ),
     .A_BIST_EN    (  1'b0 )
  );

endmodule
