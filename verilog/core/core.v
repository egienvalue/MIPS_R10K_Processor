//*****************************************************************************
// Filename: core.v
// Discription: core top level integration, instantiate new feature modules
// 				here
// Author: group 5
// Version History
//   <11/5> initial creation: integrate without br_stack, br_predictor, LSQ
//*****************************************************************************
`timescale 1ns/100ps

module core (
		input									clk,
		input									rst,

		input			[3:0]					mem2proc_response,
		input			[63:0]					mem2proc_data,
		input			[3:0]					mem2proc_tag,
	
		output	logic	[1:0]					proc2mem_command,
		output	logic	[63:0]					proc2mem_addr,
		output	logic	[63:0]					proc2mem_data,




	);



	//---------------------------------------------------------------
	// signals for Icache
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for if_stage
	//---------------------------------------------------------------
	
	
	//---------------------------------------------------------------
	// signals for branch predictor
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for dispatch
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for rs
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for rob
	//---------------------------------------------------------------
	logic	[`PRF_IDX_W-1:0]		fl2rob_tag_i;//tag sent from freelist
	logic	[`PRF_IDX_W-2:0]		fl2rob_cur_head_i;//freelist head
	logic	[`PRF_IDX_W-1:0]		map2rob_tag_i;//tag sent from maptable
	logic	[`PRF_IDX_W-2:0]		decode2rob_logic_dest_i;//logic dest sent from decode
	logic	[63:0]					decode2rob_PC_i;//instruction's PC sent from decode
	logic							decode2rob_br_flag_i;//flag show whether the instruction is a branch
	logic							decode2rob_br_pretaken_i;//branch predictor result sent from decode
	logic	[63:0]					decode2rob_br_target_i;//branch target sent from decode 
	logic							decode2rob_rd_mem_i;//flag shows whether this instruction read memory
	logic							decode2rob_wr_mem_i;//flag shows whether this instruction write memory
	logic							rob_dispatch_en_i;//signal from dispatch to allocate entry in rob
	logic	[`BR_MASK_W-1:0]		decode2rob_br_mask_i;

	logic	[`ROB_IDX_W:0]			fu2rob_idx_i;//tag sent from functional unit to know which entry's done register needed to be set 
	logic							fu2rob_done_signal_i;//done signal from functional unit 
	logic							fu2rob_br_taken_i;//branck taken result sent from functional unit

	logic	[`HT_W-1:0]				rob2rs_tail_idx_o;//tail # sent to rs to record which entry the instruction is 
	logic	[`PRF_IDX_W-1:0]		rob2fl_tag_o;//tag from ROB to freelist for returning the old tag to freelist 
	logic	[`PRF_IDX_W-1:0]		rob2arch_map_tag_o;//tag from ROB to Arch map
	logic	[`PRF_IDX_W-2:0]		rob2arch_map_logic_dest_o;//logic dest from ROB to Arch map
	logic							rob_stall_dp_o;//signal show if the ROB is full
	logic							rob_head_retire_rdy_o;//the head of ROb is ready to retire

	logic							br_recovery_rdy_o;//ready to start early branch recovery
	logic	[`PRF_IDX_W-2:0]		rob2fl_recover_head_o;
	logic	[`BR_MASK_W-1:0]		br_recovery_mask_o;
	logic	[`BR_STATE_W-1:0]		br_state_o;//branch state signal to branch mask


	//---------------------------------------------------------------
	// signals for map table and free list
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for fu
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for early branch recovery (br stack)
	//---------------------------------------------------------------
	

	//---------------------------------------------------------------
	// signals for LSQ
	//---------------------------------------------------------------
	
	
	//---------------------------------------------------------------
	// signals for Dcache
	//---------------------------------------------------------------
	
	

	//===============================================================
	// Icache instantiation
	//===============================================================
	

	//===============================================================
	// if_stage instantiation
	//===============================================================
	if_stage(
				  .clk,                      // system clk
				  .rst,                      // system rst
				  					        // makes pipeline behave as single-cycle
				  .branch_i,
				  .br_dirp_i,
				  .return_i,
				  .ras_target_i,
				  .br_predict_target_PC_i,
				  .br_flush_target_PC_i,
				  .Imem2proc_data,		        // Data coming back from instruction-memory
				  .Imem_valid,
				  .br_flush_en_i,
				  .id_request_i,

				  .proc2Imem_addr,		// Address sent to Instruction memory
				  .if_NPC_out,			// PC of instruction after fetched (PC+4).
				  .if_IR_out,			// fetched instruction out
				  .if_valid_inst_out	    // when low, instruction is garbage
				  //output logic		  if2id_empty_o
           );


	//===============================================================
	// branch predictor instantiation
	//===============================================================
	

	//===============================================================
	// dispatch instantiation
	//===============================================================
	

	//===============================================================
	// rs instantiation
	//===============================================================
	

	//===============================================================
	//rob instantiation
	//===============================================================
	rob rob1 (
		.fl2rob_tag_i,//tag sent from freelist
		.fl2rob_cur_head_i,//freelist head
		.map2rob_tag_i,//tag sent from maptable
		.decode2rob_logic_dest_i,//logic dest sent from decode
		.decode2rob_PC_i,//instruction's PC sent from decode
		.decode2rob_br_flag_i,//flag show whether the instruction is a branch
		.decode2rob_br_pretaken_i,//branch predictor result sent from decode
		.decode2rob_br_target_i,//branch target sent from decode 
		.decode2rob_rd_mem_i,//flag shows whether this instruction read memory
		.decode2rob_wr_mem_i,//flag shows whether this instruction write memory
		.rob_dispatch_en_i,//signal from dispatch to allocate entry in rob
		.decode2rob_br_mask_i,

		//----------------------------------------------------------------------
		//Functional Unit Signal Input
		//----------------------------------------------------------------------
		.fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		.fu2rob_done_signal_i,//done signal from functional unit 
		.fu2rob_br_taken_i,//branck taken result sent from functional unit


		.rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		.rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		.rob2arch_map_tag_o,//tag from ROB to Arch map
		.rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		.rob_stall_dp_o,//signal show if the ROB is full
		.rob_head_retire_rdy_o,//the head of ROb is ready to retire

		//----------------------------------------------------------------------
		//Early Recovery Signal Ouput
		//----------------------------------------------------------------------
		.br_recovery_rdy_o,//ready to start early branch recovery
		.rob2fl_recover_head_o,
		.br_recovery_mask_o,
		.br_state_o//branch state signal to branch mask
	);	

	//===============================================================
	// map table and free list instantiation
	//===============================================================
	

	//===============================================================
	// fu instantiation
	//===============================================================
		

	//===============================================================
	// early branch recovery instantiation
	//===============================================================
	

	//===============================================================
	// LSQ instantiation
	//===============================================================
	

	//===============================================================
	// Dcache instantiation
	//===============================================================
	


