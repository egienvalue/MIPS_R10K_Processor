/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module if_stage(
				  input			clk,                      // system clk
				  input			rst,                      // system rst
													        // makes pipeline behave as single-cycle
				  input			bp2if_predict_i,
				  
				  input	[63:0]	br_predict_target_PC_i,
				  input	[63:0]	br_flush_target_PC_i,
				  input	[63:0]	Imem2proc_data,		        // Data coming back from instruction-memory
				  input			Imem_valid,
				  input			br_flush_en_i,
				  input			id_request_i,

				  output logic	[63:0]	proc2Imem_addr,		// Address sent to Instruction memory
				  output logic			if2Icache_req_o,
				  output logic	[63:0]	if_PC_o,			// PC of instruction.
				  output logic	[63:0]	if_target_PC_o,
				  output logic	[31:0]	if_IR_o,			// fetched instruction out
				  output logic			if_pred_bit_o,
				  output logic			if_valid_inst_o,	    // when low, instruction is garbage
				  output logic	[63:0]	if2bp_pc_o
               );

	logic    [63:0] PC_reg;               // PC we are currently fetching

	logic    [63:0] PC_plus_4;
	logic    [63:0] next_PC;
	logic			PC_enable;
	logic			ifb_en;
	logic	 [31:0]	if_IR_in;
	logic    [63:0] ifb2if_PC_reg;
	logic			ifb2if_full;
	logic			ifb2if_empty;

	//logic    [63:0] target_PC;

	assign ifb_en = ~ifb2if_full && Imem_valid;


	ifb ifb0(
		.clk(clk),
		.rst(rst),
		.ifb_en_i(ifb_en),
		.if_insn_i(if_IR_in),
		.if_PC_i(PC_reg),
		.if_target_PC_i(next_PC),
		.bp2if_pred_bit_i(bp2if_predict_i),
		.flush_en_i(br_flush_en_i),
		.decode_en_i(id_request_i),

		.ifb_2if_full_o(ifb2if_full),
		.ifb_2id_empty_o(ifb2if_empty),
		.ifb_insn_o(if_IR_o),
		.ifb_PC_o(ifb2if_PC_reg),
		.ifb_target_PC_o(if_target_PC_o),
		.ifb_pred_bit_o(if_pred_bit_o)

	);

	assign if2bp_pc_o = PC_reg;

	assign proc2Imem_addr = {PC_reg[63:3], 3'b0};
	assign if2Icache_req_o= ~ifb2if_full | ~Imem_valid;

	// this mux is because the Imem gives us 64 bits not 32 bits
	assign if_IR_in = PC_reg[2] ? Imem2proc_data[63:32] : Imem2proc_data[31:0];

	// default next PC value
	assign PC_plus_4 = PC_reg + 4;

	// next PC is target_PC if there is a taken branch or
	// the next sequential PC (PC+4) if no branch
	// (halting is handled with the enable PC_enable;
	assign next_PC = br_flush_en_i ? br_flush_target_PC_i :
					 (bp2if_predict_i) ? br_predict_target_PC_i : PC_plus_4;


	// The take-branch signal must override stalling (otherwise it may be lost)
	assign PC_enable = (~ifb2if_full&& Imem_valid) | br_flush_en_i;
	//(Imem_valid | br_dirp_i | return_i | br_flush_en_i )&& ~ifb2if_full;

	// Pass PC down pipeline w/instruction
	assign if_PC_o			= ifb2if_PC_reg;

	assign if_valid_inst_o = ~ifb2if_empty; //&& Imem_valid;//ready_for_valid & Imem_valid;


	// This register holds the PC value
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk)
	begin
		if(rst)
			PC_reg <= `SD 0;       // initial PC value is 0
		else if(PC_enable)
			PC_reg <= `SD next_PC; // transition to next PC
	end  // always
/*
	// This FF controls the stall signal that artificially forces
	// fetch to stall until the previous instruction has completed
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk)
	begin
		if (rst)
			ready_for_valid <= `SD 1;  // must start with something
		else
			ready_for_valid <= `SD next_ready_for_valid;
	end
  */
endmodule  // module if_stage
