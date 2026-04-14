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

  logic [63:0] test_data [0:NO_OF_TEST-1];
  logic [63:0] rx_word;
  
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
        $display("Received data[%0d] = 0x%016h", i, rx_word);
      end

      @(negedge clk_i);
      req_i = 1'b0;
      we_i  = 1'b0;
    end
  endtask

  initial begin
    test_data[0]   = 64'hFEDC_BA98_7654_3210;
    test_data[1]   = 64'h2222_2222_0000_0002;
    test_data[2]   = 64'h3333_0000_3333_0003;
    test_data[3]   = 64'h4444_0044_4400_0004;
    test_data[4]   = 64'h5555_5500_0055_0005;
    test_data[5]   = 64'h6666_0600_6000_0006;
    test_data[6]   = 64'h7777_0777_0700_0007;
    test_data[7]   = 64'h8888_0080_0800_0008;
    test_data[8]   = 64'h9999_9999_9999_0009;
    test_data[9]   = 64'hAAAA_AAAA_0000_000A;
    test_data[10]  = 64'hBBBB_0000_BBBB_000B;
    test_data[11]  = 64'hCCCC_00CC_CC00_000C;
    test_data[12]  = 64'hDDDD_DD00_00DD_000D;
    test_data[13]  = 64'hEEEE_0E00_E000_000E;
    test_data[14]  = 64'hFFFF_0FFF_0F00_000F;
    test_data[15]  = 64'h1111_1111_1111_0010;
    test_data[16]  = 64'h2222_2222_0000_0011;
    test_data[17]  = 64'h3333_0000_3333_0012;
    test_data[18]  = 64'h4444_0044_4400_0013;
    test_data[19]  = 64'h5555_5500_0055_0014;
    test_data[20]  = 64'h6666_0600_6000_0015;
    test_data[21]  = 64'h7777_0777_0700_0016;
    test_data[22]  = 64'h8888_0080_0800_0017;
    test_data[23]  = 64'h9999_9999_9999_0018;
    test_data[24]  = 64'hAAAA_AAAA_0000_0019;
    test_data[25]  = 64'hBBBB_0000_BBBB_001A;
    test_data[26]  = 64'hCCCC_00CC_CC00_001B;
    test_data[27]  = 64'hDDDD_DD00_00DD_001C;
    test_data[28]  = 64'hEEEE_0E00_E000_001D;
    test_data[29]  = 64'hFFFF_0FFF_0F00_001E;
    test_data[30]  = 64'h1111_1111_1111_001F;
    test_data[31]  = 64'h2222_2222_0000_0020;
    test_data[32]  = 64'h3333_0000_3333_0021;
    test_data[33]  = 64'h4444_0044_4400_0022;
    test_data[34]  = 64'h5555_5500_0055_0023;
    test_data[35]  = 64'h6666_0600_6000_0024;
    test_data[36]  = 64'h7777_0777_0700_0025;
    test_data[37]  = 64'h8888_0080_0800_0026;
    test_data[38]  = 64'h9999_9999_9999_0027;
    test_data[39]  = 64'hAAAA_AAAA_0000_0028;
    test_data[40]  = 64'hBBBB_0000_BBBB_0029;
    test_data[41]  = 64'hCCCC_00CC_CC00_002A;
    test_data[42]  = 64'hDDDD_DD00_00DD_002B;
    test_data[43]  = 64'hEEEE_0E00_E000_002C;
    test_data[44]  = 64'hFFFF_0FFF_0F00_002D;
    test_data[45]  = 64'h1111_1111_1111_002E;
    test_data[46]  = 64'h2222_2222_0000_002F;
    test_data[47]  = 64'h3333_0000_3333_0030;
    test_data[48]  = 64'h4444_0044_4400_0031;
    test_data[49]  = 64'h5555_5500_0055_0032;
    test_data[50]  = 64'h6666_0600_6000_0033;
    test_data[51]  = 64'h7777_0777_0700_0034;
    test_data[52]  = 64'h8888_0080_0800_0035;
    test_data[53]  = 64'h9999_9999_9999_0036;
    test_data[54]  = 64'hAAAA_AAAA_0000_0037;
    test_data[55]  = 64'hBBBB_0000_BBBB_0038;
    test_data[56]  = 64'hCCCC_00CC_CC00_0039;
    test_data[57]  = 64'hDDDD_DD00_00DD_003A;
    test_data[58]  = 64'hEEEE_0E00_E000_003B;
    test_data[59]  = 64'hFFFF_0FFF_0F00_003C;
    test_data[60]  = 64'h1111_1111_1111_003D;
    test_data[61]  = 64'h2222_2222_0000_003E;
    test_data[62]  = 64'h3333_0000_3333_003F;
    test_data[63]  = 64'h4444_0044_4400_0040;
    test_data[64]  = 64'h5555_5500_0055_0041;
    test_data[65]  = 64'h6666_0600_6000_0042;
    test_data[66]  = 64'h7777_0777_0700_0043;
    test_data[67]  = 64'h8888_0080_0800_0044;
    test_data[68]  = 64'h9999_9999_9999_0045;
    test_data[69]  = 64'hAAAA_AAAA_0000_0046;
    test_data[70]  = 64'hBBBB_0000_BBBB_0047;
    test_data[71]  = 64'hCCCC_00CC_CC00_0048;
    test_data[72]  = 64'hDDDD_DD00_00DD_0049;
    test_data[73]  = 64'hEEEE_0E00_E000_004A;
    test_data[74]  = 64'hFFFF_0FFF_0F00_004B;
    test_data[75]  = 64'h1111_1111_1111_004C;
    test_data[76]  = 64'h2222_2222_0000_004D;
    test_data[77]  = 64'h3333_0000_3333_004E;
    test_data[78]  = 64'h4444_0044_4400_004F;
    test_data[79]  = 64'h5555_5500_0055_0050;
    test_data[80]  = 64'h6666_0600_6000_0051;
    test_data[81]  = 64'h7777_0777_0700_0052;
    test_data[82]  = 64'h8888_0080_0800_0053;
    test_data[83]  = 64'h9999_9999_9999_0054;
    test_data[84]  = 64'hAAAA_AAAA_0000_0055;
    test_data[85]  = 64'hBBBB_0000_BBBB_0056;
    test_data[86]  = 64'hCCCC_00CC_CC00_0057;
    test_data[87]  = 64'hDDDD_DD00_00DD_0058;
    test_data[88]  = 64'hEEEE_0E00_E000_0059;
    test_data[89]  = 64'hFFFF_0FFF_0F00_005A;
    test_data[90]  = 64'h1111_1111_1111_005B;
    test_data[91]  = 64'h2222_2222_0000_005C;
    test_data[92]  = 64'h3333_0000_3333_005D;
    test_data[93]  = 64'h4444_0044_4400_005E;
    test_data[94]  = 64'h5555_5500_0055_005F;
    test_data[95]  = 64'h6666_0600_6000_0060;
    test_data[96]  = 64'h7777_0777_0700_0061;
    test_data[97]  = 64'h8888_0080_0800_0062;
    test_data[98]  = 64'h9999_9999_9999_0063;
    test_data[99]  = 64'hAAAA_AAAA_0000_0064;
    test_data[100] = 64'hBBBB_0000_BBBB_0065;
    test_data[101] = 64'hCCCC_00CC_CC00_0066;
    test_data[102] = 64'hDDDD_DD00_00DD_0067;
    test_data[103] = 64'hEEEE_0E00_E000_0068;
    test_data[104] = 64'hFFFF_0FFF_0F00_0069;
    test_data[105] = 64'h1111_1111_1111_006A;
    test_data[106] = 64'h2222_2222_0000_006B;
    test_data[107] = 64'h3333_0000_3333_006C;
    test_data[108] = 64'h4444_0044_4400_006D;
    test_data[109] = 64'h5555_5500_0055_006E;
    test_data[110] = 64'h6666_0600_6000_006F;
    test_data[111] = 64'h7777_0777_0700_0070;
    test_data[112] = 64'h8888_0080_0800_0071;
    test_data[113] = 64'h9999_9999_9999_0072;
    test_data[114] = 64'hAAAA_AAAA_0000_0073;
    test_data[115] = 64'hBBBB_0000_BBBB_0074;
    test_data[116] = 64'hCCCC_00CC_CC00_0075;
    test_data[117] = 64'hDDDD_DD00_00DD_0076;
    test_data[118] = 64'hEEEE_0E00_E000_0077;
    test_data[119] = 64'hFFFF_0FFF_0F00_0078;
    test_data[120] = 64'h1111_1111_1111_0079;
    test_data[121] = 64'h2222_2222_0000_007A;
    test_data[122] = 64'h3333_0000_3333_007B;
    test_data[123] = 64'h4444_0044_4400_007C;
    test_data[124] = 64'h5555_5500_0055_007D;
    test_data[125] = 64'h6666_0600_6000_007E;
    test_data[126] = 64'h7777_0777_0700_007F;
    test_data[127] = 64'h8888_0080_0800_0080;
  end

  initial begin
    rst_ni           = 1'b0;
    req_i            = 1'b0;
    we_i             = 1'b0;
    streamed_wdata_i = 16'h0000;

    repeat (3) @(posedge clk_i);
    rst_ni = 1'b1;

    do_write_transaction(1'b0);

    repeat (20) @(posedge clk_i);

    do_write_transaction(1'b1);

    $display("\n=== WRITE TRANSACTION DONE ===");

    repeat (20) @(posedge clk_i);
    $finish;
  end

endmodule
