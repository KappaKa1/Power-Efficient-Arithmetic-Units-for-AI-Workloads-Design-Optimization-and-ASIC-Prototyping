`timescale 1ns/1ps

module main_tb;

  localparam int unsigned INPUT_SRAM_NUM_WORDS    = 64;
  localparam int unsigned INPUT_NUM_BITS          = 4;
  localparam int unsigned OUTPUT_SRAM_NUM_WORDS   = 256;
  localparam int unsigned OUTPUT_NUM_BITS         = 16;
  localparam int unsigned NUM_OF_STREAMING_PORTS  = 16;
  localparam int unsigned SRAM_DATA_WIDTH         = 64;
  localparam int unsigned MATRIX_DIMENSION        = 32*32;
  localparam int unsigned INPUT_SRAM_ADDR_WIDTH   = $clog2(INPUT_SRAM_NUM_WORDS);
  localparam int unsigned OUTPUT_SRAM_ADDR_WIDTH  = $clog2(OUTPUT_SRAM_NUM_WORDS);
  localparam int unsigned NO_OF_TEST              = 128;

  logic clk_i;
  logic rst_ni;

  logic req_i;
  logic we_i;

  logic [15:0] streamed_wdata_i;
  logic [15:0] streamed_rdata_o;

  logic ready_o;
  logic finish_o;
  logic ack_o;

  logic [63:0] Operand_A [0:NO_OF_TEST/2 -1];
  logic [63:0] Operand_B [0:NO_OF_TEST/2 -1];
  logic [63:0] test_data [0:NO_OF_TEST-1];
  logic [63:0] rx_word;
  logic [63:0] expected_data [0:255];
  logic [63:0] actual_data   [0:255];
  
main #(
    .INPUT_SRAM_NUM_WORDS (INPUT_SRAM_NUM_WORDS),
    .INPUT_NUM_BITS       (INPUT_NUM_BITS),
    .OUTPUT_SRAM_NUM_WORDS(OUTPUT_SRAM_NUM_WORDS),
    .OUTPUT_NUM_BITS      (OUTPUT_NUM_BITS),
    .NUM_OF_STREAMING_PORTS(NUM_OF_STREAMING_PORTS),
    .SRAM_DATA_WIDTH      (SRAM_DATA_WIDTH),
    .MATRIX_DIMENSION     (MATRIX_DIMENSION)
  ) dut (
    .clk_i              (clk_i),
    .rst_ni             (rst_ni),
    .req_i              (req_i),
    .we_i               (we_i),

    .streamed_wdata_0_i (streamed_wdata_i[0]),
    .streamed_wdata_1_i (streamed_wdata_i[1]),
    .streamed_wdata_2_i (streamed_wdata_i[2]),
    .streamed_wdata_3_i (streamed_wdata_i[3]),
    .streamed_wdata_4_i (streamed_wdata_i[4]),
    .streamed_wdata_5_i (streamed_wdata_i[5]),
    .streamed_wdata_6_i (streamed_wdata_i[6]),
    .streamed_wdata_7_i (streamed_wdata_i[7]),
    .streamed_wdata_8_i (streamed_wdata_i[8]),
    .streamed_wdata_9_i (streamed_wdata_i[9]),
    .streamed_wdata_10_i(streamed_wdata_i[10]),
    .streamed_wdata_11_i(streamed_wdata_i[11]),
    .streamed_wdata_12_i(streamed_wdata_i[12]),
    .streamed_wdata_13_i(streamed_wdata_i[13]),
    .streamed_wdata_14_i(streamed_wdata_i[14]),
    .streamed_wdata_15_i(streamed_wdata_i[15]),

    .ready_o            (ready_o),
    .finish_o           (finish_o),
    .ack_o              (ack_o),

    .streamed_rdata_0_o (streamed_rdata_o[0]),
    .streamed_rdata_1_o (streamed_rdata_o[1]),
    .streamed_rdata_2_o (streamed_rdata_o[2]),
    .streamed_rdata_3_o (streamed_rdata_o[3]),
    .streamed_rdata_4_o (streamed_rdata_o[4]),
    .streamed_rdata_5_o (streamed_rdata_o[5]),
    .streamed_rdata_6_o (streamed_rdata_o[6]),
    .streamed_rdata_7_o (streamed_rdata_o[7]),
    .streamed_rdata_8_o (streamed_rdata_o[8]),
    .streamed_rdata_9_o (streamed_rdata_o[9]),
    .streamed_rdata_10_o(streamed_rdata_o[10]),
    .streamed_rdata_11_o(streamed_rdata_o[11]),
    .streamed_rdata_12_o(streamed_rdata_o[12]),
    .streamed_rdata_13_o(streamed_rdata_o[13]),
    .streamed_rdata_14_o(streamed_rdata_o[14]),
    .streamed_rdata_15_o(streamed_rdata_o[15])
  );
  
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, main_tb);
  end

  initial clk_i = 1'b0;
  always #5 clk_i = ~clk_i;

  task automatic send_data64(input logic [63:0] data);
    begin
      // Send 64 bits as 4 chunks of 16 bits, MSB first
      #1
      streamed_wdata_i = data[63:48];
      @(posedge clk_i);

      #1
      streamed_wdata_i = data[47:32];
      @(posedge clk_i);

      #1
      streamed_wdata_i = data[31:16];
      @(posedge clk_i);

      #1
      streamed_wdata_i = data[15:0];
      @(posedge clk_i);
    end
  endtask

  task automatic read_data64(output logic [63:0] data);
    logic [15:0] chunk0, chunk1, chunk2, chunk3;
    begin
      chunk0 = '0;
      chunk1 = '0;
      chunk2 = '0;
      chunk3 = '0;

      #1
      chunk0 = streamed_rdata_o;
      @(posedge clk_i);

      #1
      chunk1 = streamed_rdata_o;
      @(posedge clk_i);

      #1
      chunk2 = streamed_rdata_o;
      @(posedge clk_i);

      #1
      chunk3 = streamed_rdata_o;
      @(posedge clk_i);

      data = {chunk0, chunk1, chunk2, chunk3};
    end
  endtask

  task automatic do_write_transaction(input bit invert_data);
    logic [63:0] curr_word;
    begin
      #2 
      req_i = 1'b1;
      we_i  = 1'b1;

      wait (ack_o == 1'b1);
      wait (ack_o != 1'b1);

      for (int i = 0; i < NO_OF_TEST; i++) begin
        curr_word = invert_data ? ~test_data[i] : test_data[i];
        send_data64(curr_word);
      end

      @(negedge clk_i);
      req_i            = 1'b0;
      we_i             = 1'b0;
      streamed_wdata_i = 16'h0000;
      
      fork
        begin
          wait (finish_o == 1'b1);
        end
        begin
          repeat (2000) @(posedge clk_i);
          $fatal(1, "Timeout waiting for finish_o after write/compute");
        end
      join_any
      disable fork;

      #2 
      req_i = 1'b1;
      we_i  = 1'b0;

      wait (ack_o == 1'b1);
      wait (ack_o != 1'b1);

      // DUT note: wait 1 more cycle after ACK
      @(negedge clk_i);
      @(posedge clk_i);
      
      for (int i = 0; i < 256; i++) begin
        read_data64(rx_word);
        actual_data[i] = rx_word;
      end

      @(negedge clk_i);
      req_i = 1'b0;
      we_i  = 1'b0;
    end
  endtask

  task automatic compare_results(input string filename);
    int error_count;
    begin
      $readmemh(filename, expected_data);

      error_count = 0;

      for (int i = 0; i < 256; i++) begin
        if (actual_data[i] !== expected_data[i]) begin
          $display("MISMATCH at [%0d]: expected=0x%016h actual=0x%016h",
                   i, expected_data[i], actual_data[i]);
          error_count++;
        end
      end

      if (error_count == 0)
        $display("PASS: all outputs match expected results");
      else
        $display("FAIL: %0d mismatches found", error_count);
    end
  endtask

  initial begin
    // Read files
    $readmemh("Golden_Model/A.hex", Operand_A);
    $readmemh("Golden_Model/B.hex", Operand_B);

    // Concatenate into test_data
    for (int i = 0; i < NO_OF_TEST/2; i++) begin
      test_data[i] = Operand_A[i];
      test_data[i + NO_OF_TEST/2] = Operand_B[i];
    end
  end

  initial begin
    rst_ni           = 1'b0;
    req_i            = 1'b0;
    we_i             = 1'b0;
    streamed_wdata_i = 16'h0000;

    repeat (3) @(posedge clk_i);
    rst_ni = 1'b1;

    do_write_transaction(1'b0);
    compare_results("Golden_Model/Golden_Model_Out_0.hex");

    repeat (20) @(posedge clk_i);

    do_write_transaction(1'b1);
    compare_results("Golden_Model/Golden_Model_Out_1.hex");

    $display("\n=== WRITE TRANSACTION DONE ===");

    repeat (20) @(posedge clk_i);
    $finish;
  end

endmodule
