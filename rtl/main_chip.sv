module main_chip #() (
  input wire 						clk_i,
  input wire 						rst_ni,
  
  input wire 						req_i, 
  input wire 						we_i, 
  input wire 						streamed_wdata_0_i, // LSB
  input wire 						streamed_wdata_1_i,
  input wire 						streamed_wdata_2_i,
  input wire 						streamed_wdata_3_i,
  input wire 						streamed_wdata_4_i,
  input wire 						streamed_wdata_5_i,
  input wire 						streamed_wdata_6_i,
  input wire 						streamed_wdata_7_i,
  input wire 						streamed_wdata_8_i,
  input wire 						streamed_wdata_9_i,
  input wire 						streamed_wdata_10_i,
  input wire 						streamed_wdata_11_i,
  input wire 						streamed_wdata_12_i,
  input wire 						streamed_wdata_13_i,
  input wire 						streamed_wdata_14_i,
  input wire 						streamed_wdata_15_i, // MSB
  
  output wire 						ready_o,
  output wire 						finish_o,
  output wire 						ack_o,
  output wire  						streamed_rdata_0_o, // LSB
  output wire  						streamed_rdata_1_o,  
  output wire  						streamed_rdata_2_o,
  output wire  						streamed_rdata_3_o,
  output wire  						streamed_rdata_4_o,
  output wire  						streamed_rdata_5_o,  
  output wire  						streamed_rdata_6_o,
  output wire  						streamed_rdata_7_o,
  output wire  						streamed_rdata_8_o,
  output wire  						streamed_rdata_9_o,  
  output wire  						streamed_rdata_10_o,
  output wire  						streamed_rdata_11_o,
  output wire  						streamed_rdata_12_o,
  output wire  						streamed_rdata_13_o,  
  output wire  						streamed_rdata_14_o,
  output wire  						streamed_rdata_15_o, // MSB  
  
  inout wire VDD,
  inout wire VSS,
  inout wire VDDIO,
  inout wire VSSIO
);

  // -------------------- Unused SoC Signals --------------------
  logic unused0_o, unused1_o, unused2_o, unused3_o, unused4_o;
  logic unused5_o, unused6_o, unused7_o, unused8_o;
  logic soc_unused0_o, soc_unused1_o, soc_unused2_o, soc_unused3_o, soc_unused4_o;
  logic soc_unused5_o, soc_unused6_o, soc_unused7_o, soc_unused8_o;
  assign soc_unused0_o = 1'b0;
  assign soc_unused1_o = 1'b0;
  assign soc_unused2_o = 1'b0;
  assign soc_unused3_o = 1'b0;
  assign soc_unused4_o = 1'b0;
  assign soc_unused5_o = 1'b0;
  assign soc_unused6_o = 1'b0;
  assign soc_unused7_o = 1'b0;
  assign soc_unused8_o = 1'b0;

  // -------------------- Internal SoC Signals --------------------
  logic soc_clk_i, soc_rst_ni;
  logic soc_req_i, soc_we_i;

  logic soc_streamed_wdata_0_i;
  logic soc_streamed_wdata_1_i;
  logic soc_streamed_wdata_2_i;
  logic soc_streamed_wdata_3_i;
  logic soc_streamed_wdata_4_i;
  logic soc_streamed_wdata_5_i;
  logic soc_streamed_wdata_6_i;
  logic soc_streamed_wdata_7_i;
  logic soc_streamed_wdata_8_i;
  logic soc_streamed_wdata_9_i;
  logic soc_streamed_wdata_10_i;
  logic soc_streamed_wdata_11_i;
  logic soc_streamed_wdata_12_i;
  logic soc_streamed_wdata_13_i;
  logic soc_streamed_wdata_14_i;
  logic soc_streamed_wdata_15_i;

  logic soc_ready_o, soc_finish_o, soc_ack_o;

  logic soc_streamed_rdata_0_o;
  logic soc_streamed_rdata_1_o;
  logic soc_streamed_rdata_2_o;
  logic soc_streamed_rdata_3_o;
  logic soc_streamed_rdata_4_o;
  logic soc_streamed_rdata_5_o;
  logic soc_streamed_rdata_6_o;
  logic soc_streamed_rdata_7_o;
  logic soc_streamed_rdata_8_o;
  logic soc_streamed_rdata_9_o;
  logic soc_streamed_rdata_10_o;
  logic soc_streamed_rdata_11_o;
  logic soc_streamed_rdata_12_o;
  logic soc_streamed_rdata_13_o;
  logic soc_streamed_rdata_14_o;
  logic soc_streamed_rdata_15_o;

  // -------------------- Input Pads --------------------
  sg13cmos5l_IOPadIn pad_clk_i        (.pad(clk_i),        .p2c(soc_clk_i));
  sg13cmos5l_IOPadIn pad_rst_ni       (.pad(rst_ni),       .p2c(soc_rst_ni));

  sg13cmos5l_IOPadIn pad_req_i        (.pad(req_i),        .p2c(soc_req_i));
  sg13cmos5l_IOPadIn pad_we_i         (.pad(we_i),         .p2c(soc_we_i));

  sg13cmos5l_IOPadIn pad_wdata_0_i    (.pad(streamed_wdata_0_i),  .p2c(soc_streamed_wdata_0_i));
  sg13cmos5l_IOPadIn pad_wdata_1_i    (.pad(streamed_wdata_1_i),  .p2c(soc_streamed_wdata_1_i));
  sg13cmos5l_IOPadIn pad_wdata_2_i    (.pad(streamed_wdata_2_i),  .p2c(soc_streamed_wdata_2_i));
  sg13cmos5l_IOPadIn pad_wdata_3_i    (.pad(streamed_wdata_3_i),  .p2c(soc_streamed_wdata_3_i));
  sg13cmos5l_IOPadIn pad_wdata_4_i    (.pad(streamed_wdata_4_i),  .p2c(soc_streamed_wdata_4_i));
  sg13cmos5l_IOPadIn pad_wdata_5_i    (.pad(streamed_wdata_5_i),  .p2c(soc_streamed_wdata_5_i));
  sg13cmos5l_IOPadIn pad_wdata_6_i    (.pad(streamed_wdata_6_i),  .p2c(soc_streamed_wdata_6_i));
  sg13cmos5l_IOPadIn pad_wdata_7_i    (.pad(streamed_wdata_7_i),  .p2c(soc_streamed_wdata_7_i));
  sg13cmos5l_IOPadIn pad_wdata_8_i    (.pad(streamed_wdata_8_i),  .p2c(soc_streamed_wdata_8_i));
  sg13cmos5l_IOPadIn pad_wdata_9_i    (.pad(streamed_wdata_9_i),  .p2c(soc_streamed_wdata_9_i));
  sg13cmos5l_IOPadIn pad_wdata_10_i   (.pad(streamed_wdata_10_i), .p2c(soc_streamed_wdata_10_i));
  sg13cmos5l_IOPadIn pad_wdata_11_i   (.pad(streamed_wdata_11_i), .p2c(soc_streamed_wdata_11_i));
  sg13cmos5l_IOPadIn pad_wdata_12_i   (.pad(streamed_wdata_12_i), .p2c(soc_streamed_wdata_12_i));
  sg13cmos5l_IOPadIn pad_wdata_13_i   (.pad(streamed_wdata_13_i), .p2c(soc_streamed_wdata_13_i));
  sg13cmos5l_IOPadIn pad_wdata_14_i   (.pad(streamed_wdata_14_i), .p2c(soc_streamed_wdata_14_i));
  sg13cmos5l_IOPadIn pad_wdata_15_i   (.pad(streamed_wdata_15_i), .p2c(soc_streamed_wdata_15_i));

  // -------------------- Output Pads --------------------
  sg13cmos5l_IOPadOut16mA pad_ready_o   (.pad(ready_o),   .c2p(soc_ready_o));
  sg13cmos5l_IOPadOut16mA pad_finish_o  (.pad(finish_o),  .c2p(soc_finish_o));
  sg13cmos5l_IOPadOut16mA pad_ack_o     (.pad(ack_o),     .c2p(soc_ack_o));

  sg13cmos5l_IOPadOut16mA pad_rdata_0_o  (.pad(streamed_rdata_0_o),  .c2p(soc_streamed_rdata_0_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_1_o  (.pad(streamed_rdata_1_o),  .c2p(soc_streamed_rdata_1_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_2_o  (.pad(streamed_rdata_2_o),  .c2p(soc_streamed_rdata_2_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_3_o  (.pad(streamed_rdata_3_o),  .c2p(soc_streamed_rdata_3_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_4_o  (.pad(streamed_rdata_4_o),  .c2p(soc_streamed_rdata_4_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_5_o  (.pad(streamed_rdata_5_o),  .c2p(soc_streamed_rdata_5_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_6_o  (.pad(streamed_rdata_6_o),  .c2p(soc_streamed_rdata_6_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_7_o  (.pad(streamed_rdata_7_o),  .c2p(soc_streamed_rdata_7_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_8_o  (.pad(streamed_rdata_8_o),  .c2p(soc_streamed_rdata_8_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_9_o  (.pad(streamed_rdata_9_o),  .c2p(soc_streamed_rdata_9_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_10_o (.pad(streamed_rdata_10_o), .c2p(soc_streamed_rdata_10_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_11_o (.pad(streamed_rdata_11_o), .c2p(soc_streamed_rdata_11_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_12_o (.pad(streamed_rdata_12_o), .c2p(soc_streamed_rdata_12_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_13_o (.pad(streamed_rdata_13_o), .c2p(soc_streamed_rdata_13_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_14_o (.pad(streamed_rdata_14_o), .c2p(soc_streamed_rdata_14_o));
  sg13cmos5l_IOPadOut16mA pad_rdata_15_o (.pad(streamed_rdata_15_o), .c2p(soc_streamed_rdata_15_o));

  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused0_o (.pad(unused0_o), .c2p(soc_unused0_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused1_o (.pad(unused1_o), .c2p(soc_unused1_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused2_o (.pad(unused2_o), .c2p(soc_unused2_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused3_o (.pad(unused3_o), .c2p(soc_unused3_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused4_o (.pad(unused4_o), .c2p(soc_unused4_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused5_o (.pad(unused5_o), .c2p(soc_unused5_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused6_o (.pad(unused6_o), .c2p(soc_unused6_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused7_o (.pad(unused7_o), .c2p(soc_unused7_o));
  (* dont_touch = "true" *) sg13cmos5l_IOPadOut16mA pad_unused8_o (.pad(unused8_o), .c2p(soc_unused8_o));

  (* dont_touch = "true" *)sg13cmos5l_IOPadVdd pad_vdd0();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVdd pad_vdd1();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVdd pad_vdd2();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVdd pad_vdd3();

  (* dont_touch = "true" *)sg13cmos5l_IOPadVss pad_vss0();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVss pad_vss1();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVss pad_vss2();
  (* dont_touch = "true" *)sg13cmos5l_IOPadVss pad_vss3();

  (* dont_touch = "true" *)sg13cmos5l_IOPadIOVdd pad_vddio0();
  (* dont_touch = "true" *)sg13cmos5l_IOPadIOVdd pad_vddio1();
  (* dont_touch = "true" *)sg13cmos5l_IOPadIOVdd pad_vddio2();
  (* dont_touch = "true" *)sg13cmos5l_IOPadIOVdd pad_vddio3();

    (* dont_touch = "true" *)sg13cmos5l_IOPadIOVss pad_vssio0();
    (* dont_touch = "true" *)sg13cmos5l_IOPadIOVss pad_vssio1();
    (* dont_touch = "true" *)sg13cmos5l_IOPadIOVss pad_vssio2();
    (* dont_touch = "true" *)sg13cmos5l_IOPadIOVss pad_vssio3();

  main #(
    .INPUT_SRAM_NUM_WORDS   (64),
    .INPUT_NUM_BITS         (4),
    .OUTPUT_SRAM_NUM_WORDS  (256),
    .OUTPUT_NUM_BITS        (16),
    .NUM_OF_STREAMING_PORTS (16),
    .SRAM_DATA_WIDTH        (64),
    .MATRIX_DIMENSION       (32*32),
    .INPUT_SRAM_ADDR_WIDTH  (8),
    .OUTPUT_SRAM_ADDR_WIDTH (8)
  ) u_main (
    .clk_i               (soc_clk_i),
    .rst_ni              (soc_rst_ni),

    .req_i               (soc_req_i),
    .we_i                (soc_we_i),

    .streamed_wdata_0_i  (soc_streamed_wdata_0_i),
    .streamed_wdata_1_i  (soc_streamed_wdata_1_i),
    .streamed_wdata_2_i  (soc_streamed_wdata_2_i),
    .streamed_wdata_3_i  (soc_streamed_wdata_3_i),
    .streamed_wdata_4_i  (soc_streamed_wdata_4_i),
    .streamed_wdata_5_i  (soc_streamed_wdata_5_i),
    .streamed_wdata_6_i  (soc_streamed_wdata_6_i),
    .streamed_wdata_7_i  (soc_streamed_wdata_7_i),
    .streamed_wdata_8_i  (soc_streamed_wdata_8_i),
    .streamed_wdata_9_i  (soc_streamed_wdata_9_i),
    .streamed_wdata_10_i (soc_streamed_wdata_10_i),
    .streamed_wdata_11_i (soc_streamed_wdata_11_i),
    .streamed_wdata_12_i (soc_streamed_wdata_12_i),
    .streamed_wdata_13_i (soc_streamed_wdata_13_i),
    .streamed_wdata_14_i (soc_streamed_wdata_14_i),
    .streamed_wdata_15_i (soc_streamed_wdata_15_i),

    .ready_o             (soc_ready_o),
    .finish_o            (soc_finish_o),
    .ack_o               (soc_ack_o),

    .streamed_rdata_0_o  (soc_streamed_rdata_0_o),
    .streamed_rdata_1_o  (soc_streamed_rdata_1_o),
    .streamed_rdata_2_o  (soc_streamed_rdata_2_o),
    .streamed_rdata_3_o  (soc_streamed_rdata_3_o),
    .streamed_rdata_4_o  (soc_streamed_rdata_4_o),
    .streamed_rdata_5_o  (soc_streamed_rdata_5_o),
    .streamed_rdata_6_o  (soc_streamed_rdata_6_o),
    .streamed_rdata_7_o  (soc_streamed_rdata_7_o),
    .streamed_rdata_8_o  (soc_streamed_rdata_8_o),
    .streamed_rdata_9_o  (soc_streamed_rdata_9_o),
    .streamed_rdata_10_o (soc_streamed_rdata_10_o),
    .streamed_rdata_11_o (soc_streamed_rdata_11_o),
    .streamed_rdata_12_o (soc_streamed_rdata_12_o),
    .streamed_rdata_13_o (soc_streamed_rdata_13_o),
    .streamed_rdata_14_o (soc_streamed_rdata_14_o),
    .streamed_rdata_15_o (soc_streamed_rdata_15_o)
  );
endmodule
