// Get value from the technology file

// Input Values 2 * 32 * 32 * 4
// The mismatch between sram_inp_addr_o and input_sram_cnt_q is intentional, the code will work nonetheless.
`timescale 1ns/1ps

module SRAM_controller #(
  // Individual Parameters depending on the inputs, can potentially calculate the number of OUTPUT bits from INPUT bits.
  parameter int unsigned INPUT_SRAM_NUM_WORDS   	= 64,
  parameter int unsigned INPUT_NUM_BITS  		= 4,
  parameter int unsigned OUTPUT_SRAM_NUM_WORDS  	= 256,
  parameter int unsigned OUTPUT_NUM_BITS	  	= 16, 		// Actually 13, but round to upper 2^x.
  parameter int unsigned NUM_OF_STREAMING_PORTS		= 16,
  
  // Common Parameters
  parameter int unsigned SRAM_DATA_WIDTH        	= 64,
  parameter int unsigned MATRIX_DIMENSION 		= 32*32, 	// What size of matrix is being inputted
  
  // Calculated Parameters, DO NOT TOUCH !!
  parameter int unsigned INPUT_SRAM_ADDR_WIDTH        	= 8,
  parameter int unsigned OUTPUT_SRAM_ADDR_WIDTH        	= 8,
  parameter int unsigned GEMM_SELECT_WIDTH        	= 5,
  parameter int unsigned ENCODING_SCHEME_WIDTH        	= 3
)(
  // Global Signals
  input logic 						clk_i,
  input logic 						rst_ni,
  
  // Control Packet from Testing Device
  input logic [NUM_OF_STREAMING_PORTS - 1:0]		ctrl_packet_i,
  
  // Padding Register control signals
  output logic 						pad_load_o,
  output logic 				 		pad_enable_o,
  
  // Shift Register control signals
  output logic 						sr_inp_enable_o,
  output logic						sr_out_load_o,
  
  // SRAM control signals
  output logic [3 - 1:0]				sram_req_o, 
  output logic [3 - 1:0]				sram_we_o,
  output logic [INPUT_SRAM_ADDR_WIDTH -1 :0] 	 	sram_inp_addr_o, 
  output logic [OUTPUT_SRAM_ADDR_WIDTH -1 :0] 	 	sram_out_addr_o, 
  output logic 						mux_sel_o,
  
  // Controller to GEMM Core
  output logic [GEMM_SELECT_WIDTH :0]			GEMM_ctrl_packet_o, // contains GEMM select information + Start signal
  
  // GEMM Core to Controller
  input logic 						done_i,
  input logic 					 	result_valid_i, 
  input logic [OUTPUT_SRAM_ADDR_WIDTH - 1:0]		result_addr_i,
   
  // Controller to External Device (input)
  input logic 						ext_req_i,  	// Waits for request from external device
  input logic 						ext_we_i,   	// WE = 1 is writing, WE = 0 is reading
  
  // Controller to External Device (output)
  output logic						ext_ready_o,
  output logic 						ext_finish_o,
  output logic 						ext_ack_o
);

  typedef enum logic [3:0] {IDLE, LATENCY_FROM_REG, READ_CONTROL, WRITE_SRAM, ENCODE_DATA, GET_DATA_GEMM, COMPUTE_DONE, READ_SRAM, FINAL_DATA} sram_ctrl_state; // ENABLE/DISABLE CHECK_INPUT

  localparam int unsigned SHIFT_REG_CYCLES = SRAM_DATA_WIDTH / NUM_OF_STREAMING_PORTS;
  localparam int unsigned SHIFT_REG_CNT_WIDTH = (SHIFT_REG_CYCLES <= 1) ? 1 : $clog2(SHIFT_REG_CYCLES);
  localparam int unsigned INPUT_SRAM_ACCESS_CYCLES = (INPUT_NUM_BITS * MATRIX_DIMENSION / SRAM_DATA_WIDTH) * 2; 
  localparam int unsigned OUTPUT_SRAM_ACCESS_CYCLES = (OUTPUT_NUM_BITS * MATRIX_DIMENSION / SRAM_DATA_WIDTH); 

  sram_ctrl_state state_q, state_d;
  
  // Internal Flags
  logic active_loading_q, active_loading_d; 
  logic done_pending_q, done_pending_d;
  
  // Internal Signals
  logic [GEMM_SELECT_WIDTH-1:0] select_GEMM_q, select_GEMM_d;
  logic [ENCODING_SCHEME_WIDTH-1:0] encoding_scheme_q, encoding_scheme_d;
  logic pad_load_q, pad_load_d;
  logic pad_enable_q, pad_enable_d;
  
  logic [SHIFT_REG_CNT_WIDTH - 1:0]     shift_reg_cnt_q, shift_reg_cnt_d;
  logic sr_inp_enable_q, sr_inp_enable_d;
  logic sr_out_load_q, sr_out_load_d;
  
  logic [INPUT_SRAM_ADDR_WIDTH - 1:0]  input_sram_cnt_q, input_sram_cnt_d;
  logic [INPUT_SRAM_ADDR_WIDTH - 1:0]  input_sram_addr_q, input_sram_addr_d;
  logic [OUTPUT_SRAM_ADDR_WIDTH - 1:0] output_sram_cnt_q, output_sram_cnt_d;
  logic [OUTPUT_SRAM_ADDR_WIDTH - 1:0] output_sram_addr_q, output_sram_addr_d;
  logic [3 - 1:0] sram_req_q, sram_req_d;
  logic [3 - 1:0] sram_we_q, sram_we_d;
  logic mux_sel_q, mux_sel_d;
  
  logic [GEMM_SELECT_WIDTH :0] GEMM_ctrl_packet_q, GEMM_ctrl_packet_d;
  
  assign pad_load_o = pad_load_q;
  assign pad_enable_o = pad_enable_q;
  
  assign sr_inp_enable_o = sr_inp_enable_q;
  assign sr_out_load_o = sr_out_load_q;
 
  assign input_sram_addr_d = input_sram_cnt_q;
  assign output_sram_addr_d = output_sram_cnt_q;
  
  assign sram_inp_addr_o = input_sram_addr_q % (INPUT_SRAM_ACCESS_CYCLES/2);
  assign sram_out_addr_o = output_sram_addr_q;
  assign sram_req_o = sram_req_q;
  assign sram_we_o = sram_we_q;
  assign mux_sel_o = mux_sel_q;
  assign GEMM_ctrl_packet_o = GEMM_ctrl_packet_q;
  
  always_comb begin
  
    // Control Signals for External Device
    ext_ready_o = '0;
    ext_finish_o = '0;
    ext_ack_o = '0;
    
    pad_load_d = '0;
    pad_enable_d = '0;
    sram_req_d = '0;
    sram_we_d = '0;
    mux_sel_d = '0;
    sr_inp_enable_d = '0;
    sr_out_load_d = '0;
    GEMM_ctrl_packet_d = '0;
    
    select_GEMM_d = select_GEMM_q;
    encoding_scheme_d = encoding_scheme_q;
    shift_reg_cnt_d = shift_reg_cnt_q;
    input_sram_cnt_d = input_sram_cnt_q;
    output_sram_cnt_d = output_sram_cnt_q;
    state_d = state_q;
    
    active_loading_d = active_loading_q;
    done_pending_d = done_pending_q;
    case(state_q) 
    
      IDLE: begin
        ext_ready_o = '1;
        if(ext_req_i && ext_we_i) begin
          ext_ack_o = '1;
          state_d = LATENCY_FROM_REG;
        end
      end      
        
     LATENCY_FROM_REG: begin
       sr_inp_enable_d = '1;
       shift_reg_cnt_d = '0;
       select_GEMM_d = '0;
       encoding_scheme_d = '0;
       input_sram_cnt_d = '0;
       state_d = READ_CONTROL;
     end
      
     READ_CONTROL: begin
       sr_inp_enable_d = '1;
       {select_GEMM_d, encoding_scheme_d, input_sram_cnt_d} = ctrl_packet_i;
       state_d = WRITE_SRAM;
     end
      
     WRITE_SRAM: begin 
       mux_sel_d = '0;
       sr_inp_enable_d = '1;
        
       if(shift_reg_cnt_q == SHIFT_REG_CYCLES - 1) begin
         shift_reg_cnt_d = '0;
         if(input_sram_cnt_q < (INPUT_SRAM_ACCESS_CYCLES/2)) begin
           sram_req_d[0] = '1;
           sram_we_d[0] = '1;
         end else begin
           sram_req_d[1] = '1;
           sram_we_d[1] = '1;
         end
          
	 if(input_sram_cnt_q == INPUT_SRAM_ACCESS_CYCLES - 1) begin 
	   input_sram_cnt_d = '0;
	   state_d = ENCODE_DATA;

	 end else begin
	   input_sram_cnt_d = input_sram_cnt_q + 1;
	 end
      end else begin
        shift_reg_cnt_d = shift_reg_cnt_q + 1;
      end
    end  
      
    ENCODE_DATA: begin
    
      GEMM_ctrl_packet_d = {select_GEMM_q, 1'b1};
      state_d = GET_DATA_GEMM;
    end
      
    GET_DATA_GEMM: begin
      if(done_i || done_pending_q) begin
        done_pending_d = '1;
        mux_sel_d = '0;
      end else begin
        mux_sel_d = '1;
        sram_req_d = 3'b011;
        sram_we_d = 3'b000;
      end
        
      if(result_valid_i) begin
        pad_load_d = '1;
        active_loading_d = '1;
        output_sram_cnt_d = result_addr_i;          
      end
        
      if (active_loading_q) begin
        sram_req_d[2] = '1;
        sram_we_d[2] = '1;
        pad_enable_d = '1;
        if (output_sram_cnt_q == result_addr_i + 3) begin
          active_loading_d = '0;
        end else begin 
          output_sram_cnt_d = output_sram_cnt_q + 1;
        end
      end else if (done_pending_q || output_sram_cnt_q == OUTPUT_SRAM_ACCESS_CYCLES - 1) begin
        state_d = COMPUTE_DONE;
        done_pending_d = '0;
        output_sram_cnt_d = '0;
      end
    end
      
    COMPUTE_DONE: begin
      ext_finish_o = '1;
      sram_req_d[2] = '1;
      sram_we_d[2] = '0;
      output_sram_cnt_d = '0;
        
      if(ext_req_i && !ext_we_i) begin
        ext_ack_o = '1;
        shift_reg_cnt_d = SHIFT_REG_CYCLES - 1;
        output_sram_cnt_d = 1'b1;
        state_d = READ_SRAM;
      end
    end
      
    READ_SRAM: begin 
      if(shift_reg_cnt_q == SHIFT_REG_CYCLES - 1) begin
        shift_reg_cnt_d = '0;
        sr_out_load_d = '1;
        sram_req_d[2] = '1;
        sram_we_d[2] = '0;
          
	if(output_sram_cnt_q == OUTPUT_SRAM_ACCESS_CYCLES - 1) begin 
	  output_sram_cnt_d = '0;
	  state_d = FINAL_DATA;
	end else begin
	  output_sram_cnt_d = output_sram_cnt_q + 1;
	end
      end else begin 
	shift_reg_cnt_d = shift_reg_cnt_q + 1;
      end
    end
      
    FINAL_DATA: begin 
      if(shift_reg_cnt_q == SHIFT_REG_CYCLES - 1) begin
        shift_reg_cnt_d = '0;
        sr_out_load_d = '1;
        sram_req_d[2] = '1;
        sram_we_d[2] = '0;
        state_d = IDLE;
      end else begin  
 	shift_reg_cnt_d = shift_reg_cnt_q + 1;
      end         
    end
          
    default: begin
      state_d = IDLE;
    end
      
  endcase
end
  
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_d;
    end
  end
  
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      select_GEMM_q <= '0;
      encoding_scheme_q <= '0;
      input_sram_cnt_q <= '0;
      input_sram_addr_q <= '0;
      output_sram_cnt_q <= '0;
      output_sram_addr_q <= '0;
      shift_reg_cnt_q <= '0;
      pad_load_q <= '0;
      pad_enable_q <= '0;
      sr_inp_enable_q <= '0;
      sr_out_load_q <= '0;
      sram_req_q <= '0;
      sram_we_q <= '0;
      mux_sel_q <= '0;
      GEMM_ctrl_packet_q <= '0;
      active_loading_q <= '0;
      done_pending_q <= '0;
    end else begin
      select_GEMM_q <= select_GEMM_d;
      encoding_scheme_q <= encoding_scheme_d;
      input_sram_cnt_q <= input_sram_cnt_d;
      input_sram_addr_q <= input_sram_addr_d;
      output_sram_cnt_q <= output_sram_cnt_d;
      output_sram_addr_q <= output_sram_addr_d;
      shift_reg_cnt_q <= shift_reg_cnt_d;
      pad_load_q <= pad_load_d;
      pad_enable_q <= pad_enable_d;
      sr_inp_enable_q <= sr_inp_enable_d;
      sr_out_load_q <= sr_out_load_d;
      sram_req_q <= sram_req_d;
      sram_we_q <= sram_we_d;
      mux_sel_q <= mux_sel_d;
      GEMM_ctrl_packet_q <= GEMM_ctrl_packet_d;
      active_loading_q <= active_loading_d;
      done_pending_q <= done_pending_d;
    end
  end  
  
endmodule
