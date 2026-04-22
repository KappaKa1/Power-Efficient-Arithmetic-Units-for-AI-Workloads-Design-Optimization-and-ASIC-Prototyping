// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`define TRACE_WAVE
`timescale 1ns/1ps

module tb_main_chip #(
    parameter time         ClkPeriod     = 10ns,
    parameter time         ClkPeriodRef  = 30518ns,
    parameter time         TAppl         = 0.2*ClkPeriod,
    parameter time         TTest         = 0.8*ClkPeriod,
    parameter int unsigned RstCycles     = 1,

    localparam int unsigned ClkFrequency = 1s / ClkPeriod,
    localparam int unsigned NO_OF_TEST              = 128
)();

    ///////////////////
    //  DUT signals  //
    ///////////////////

    logic clk_i;
    logic rst_ni;

    logic req_i;
    logic we_i;

    logic ack_o;
    logic ready_o;
    logic finish_o;

    logic [15:0] streamed_wdata_i;
    logic [15:0] streamed_rdata_o;

    //////////////////
    //  TB signals  //
    //////////////////

    logic [63:0] Operand_A [0:NO_OF_TEST/2 -1];
    logic [63:0] Operand_B [0:NO_OF_TEST/2 -1];
    logic [63:0] test_data [0:NO_OF_TEST-1];
    logic [63:0] rx_word;
    logic [63:0] expected_data [0:255];
    logic [63:0] actual_data   [0:255];
    //////////////////
    //  Clock Gen   //
    //////////////////

    // system clock
    initial clk_i = 1'b0;
    always #(ClkPeriod/2) clk_i = ~clk_i;
    
    
    //////////////////
    //  Reset Gen   //
    //////////////////

    initial begin
        rst_ni = 1'b0;

        // hold reset for RstCycles clock cycles
        repeat (RstCycles) @(posedge clk_i);

        // small delay to align with application phase (optional, like VIP style)
        #TAppl;
        rst_ni = 1'b1;
    end

    ////////////
    //  DUT   //
    ////////////
  `ifdef TARGET_NETLIST_YOSYS
    \main$main_chip.u_main i_dut(
  `else
    main_chip i_dut (
  `endif
      .clk_i                                 ( clk_i       ),
      .rst_ni                                ( rst_ni      ),
      .req_i                                 ( req_i       ),

      .ack_o                                 ( ack_o       ),
      .ready_o                               ( ready_o     ),
      .finish_o                              ( finish_o    ),

      .streamed_wdata_0_i                    ( streamed_wdata_i[0]  ),
      .streamed_wdata_1_i                    ( streamed_wdata_i[1]  ),
      .streamed_wdata_2_i                    ( streamed_wdata_i[2]  ),
      .streamed_wdata_3_i                    ( streamed_wdata_i[3]  ),
      .streamed_wdata_4_i                    ( streamed_wdata_i[4]  ),
      .streamed_wdata_5_i                    ( streamed_wdata_i[5]  ),
      .streamed_wdata_6_i                    ( streamed_wdata_i[6]  ),
      .streamed_wdata_7_i                    ( streamed_wdata_i[7]  ),
      .streamed_wdata_8_i                    ( streamed_wdata_i[8]  ),
      .streamed_wdata_9_i                    ( streamed_wdata_i[9]  ),
      .streamed_wdata_10_i                   ( streamed_wdata_i[10] ),
      .streamed_wdata_11_i                   ( streamed_wdata_i[11] ),
      .streamed_wdata_12_i                   ( streamed_wdata_i[12] ),
      .streamed_wdata_13_i                   ( streamed_wdata_i[13] ),
      .streamed_wdata_14_i                   ( streamed_wdata_i[14] ),
      .streamed_wdata_15_i                   ( streamed_wdata_i[15] ),

      .streamed_rdata_0_o                    ( streamed_rdata_o[0]  ),
      .streamed_rdata_1_o                    ( streamed_rdata_o[1]  ),
      .streamed_rdata_2_o                    ( streamed_rdata_o[2]  ),
      .streamed_rdata_3_o                    ( streamed_rdata_o[3]  ),
      .streamed_rdata_4_o                    ( streamed_rdata_o[4]  ),
      .streamed_rdata_5_o                    ( streamed_rdata_o[5]  ),
      .streamed_rdata_6_o                    ( streamed_rdata_o[6]  ),
      .streamed_rdata_7_o                    ( streamed_rdata_o[7]  ),
      .streamed_rdata_8_o                    ( streamed_rdata_o[8]  ),
      .streamed_rdata_9_o                    ( streamed_rdata_o[9]  ),
      .streamed_rdata_10_o                   ( streamed_rdata_o[10] ),
      .streamed_rdata_11_o                   ( streamed_rdata_o[11] ),
      .streamed_rdata_12_o                   ( streamed_rdata_o[12] ),
      .streamed_rdata_13_o                   ( streamed_rdata_o[13] ),
      .streamed_rdata_14_o                   ( streamed_rdata_o[14] ),
      .streamed_rdata_15_o                   ( streamed_rdata_o[15] ),

      .we_i                                  ( we_i )
  );

    //////////////////////
    //  VCD Generation  //
    //////////////////////

    initial begin
	
	#5205;
        $display("@%t | [VCD] Start dump", $time);
        $dumpfile("main_chip.vcd");
        $dumpvars(0, i_dut);
        
        // keep dumping for duration = 10,315- 5,205 = 5110 ns
        #5110;

        $display("@%t | [VCD] Stop dump", $time);
        $dumpoff;
    end

    final begin
        $dumpflush;
    end

    ////////////////////////
    //  Task for Testing  //
    ////////////////////////

  task automatic send_data64(input logic [63:0] data);
    begin
      // Send 64 bits as 4 chunks of 16 bits, MSB first
      #TAppl;
      streamed_wdata_i = data[63:48];
      @(posedge clk_i);

      #TAppl;
      streamed_wdata_i = data[47:32];
      @(posedge clk_i);

      #TAppl;
      streamed_wdata_i = data[31:16];
      @(posedge clk_i);

      #TAppl;
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

      #TAppl;
      chunk0 = streamed_rdata_o;
      @(posedge clk_i);

      #TAppl;
      chunk1 = streamed_rdata_o;
      @(posedge clk_i);

      #TAppl;
      chunk2 = streamed_rdata_o;
      @(posedge clk_i);

      #TAppl;
      chunk3 = streamed_rdata_o;
      @(posedge clk_i);

      data = {chunk0, chunk1, chunk2, chunk3};
    end
  endtask

  task automatic do_write_transaction(input bit invert_data);
    logic [63:0] curr_word;
    begin
      #TAppl;
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

      #TAppl;
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


    /////////////////
    //  Testbench  //
    /////////////////

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
