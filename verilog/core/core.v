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


	//---------------------------------------------------------------
	// signals for map table and free list
	//---------------------------------------------------------------
	// Maptable
	logic	[4:0]				opa_areg_idx_i,			//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.	
	logic	[4:0]				opb_areg_idx_i,		    //[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
	logic	[4:0]				dest_areg_idx_i,		//[Decoder]		A logic register index to read the old dest physical reg, and to write a new dest physical reg.
	logic	[5:0]				new_free_preg_i,		//[Free-List]	New physical register name from Free List.
	logic						dispatch_en_i,			//[Decoder]		Enabling all inputs above. 
	logic	[5:0]				cdb_set_rdy_bit_preg_i, //[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
	logic						cdb_set_rdy_bit_en_i,	//[CDB]			Enabling setting ready bit. 
	logic	[`BR_STATE_W-1:0]	branch_state_i,		    //[ROB]			Branch prediction wrong or correct?
	logic	[31:0][6:0]			rc_mt_all_data_i,		//[Br_stack]	Recovery data for map table.	Highest bit [6] is RDY.
	logic	[5:0]				opa_preg_o,			    //[RS]			Oprand A physical reg output.
	logic	[5:0]				opb_preg_o,			    //[RS]			Oprand B physical reg output.
	logic		 				opa_preg_rdy_bit_o,	    //[RS]			Oprand A physical reg ready bit output. 
	logic		 				opb_preg_rdy_bit_o,	    //[RS]			Oprand B physical reg ready bit output.
	logic	[5:0]				dest_old_preg_o,		//[ROB]			Old dest physical reg output. 
	logic	[31:0][6:0]			bak_data_o				//[Br_stack]	Back up data to branch stack.
	//Signal
	logic						dispatch_en_i,			//[Decoder]		If true, output head entry and head++
	logic						retire_en_i,			//[ROB]			If true, write new retired preg to tail, and tail++
	logic	[5:0]				retire_preg_i,			//[ROB]			New retired preg.
	logic	[`BR_STATE_W-1:0]	branch_state_i,			//[ROB]			Branch prediction wrong or correct?
	logic	[4:0]				rc_head_i,				//[Br_stack]			Recover head to some point
	logic						free_preg_vld_o,		//[ROB, Map Table, RS]	Is output valid?
	logic	[5:0]				free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
	logic	[4:0]				free_preg_cur_head_o	//[ROB]			Current head pointer.





	//---------------------------------------------------------------
	// signals for fu
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for early branch recovery (br stack)
	//---------------------------------------------------------------

	logic						is_branch_i,			//[Dispatch]	A new branch is dispatched, mask should be updated.
	logic	[`BR_STATE_W-1:0]	branch_state_i,			//[ROB]			Branch prediction wrong or correct?		
	logic	[`BR_MASK_W-1:0]	branch_dep_mask_i,		//[ROB]			The mask of currently resolved branch.
	logic	[31:0][6:0]			bak_mp_next_data_i,		//[Map Table]	Back up data from map table.
	logic	[4:0]				bak_fl_head_i,			//[Free List]	Back up head of free list.
	logic	[`BR_MASK_W-1:0]	branch_mask_o,			//[ROB]			Send current mask value to ROB to save in an ROB entry.
	logic	[`BR_MASK_W-1:0]	branch_bit_o,			//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
	logic	[31:0][6:0]			rc_mt_all_data_o,		//[Map Table]	Recovery data for map table.
	logic	[4:0]				rc_fl_head_o,			//[Free List]	Recovery head value for free list.
	logic						full_o					//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 

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
	// map table and free list instantiation
	//===============================================================

	map_table	map_table0 (
			.clk,
			.rst,						//|From where|									
			.opa_areg_idx_i,			//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.
			.opb_areg_idx_i,			//[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
			.dest_areg_idx_i,			//[Decoder]		A logic register index to read the old dest physical reg, and to write a new dest physical reg.
			.new_free_preg_i,			//[Free-List]	New physical register name from Free List.
			.dispatch_en_i,				//[Decoder]		Enabling all inputs above. 
			.cdb_set_rdy_bit_preg_i,	//[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
			.cdb_set_rdy_bit_en_i,		//[CDB]			Enabling setting ready bit. 
			.branch_state_i,			//[ROB]			Branch prediction wrong or correct?
			.rc_mt_all_data_i,			//[Br_stack]	Recovery data for map table.	Highest bit [6] is RDY.
			.opa_preg_o,				//[RS]			Oprand A physical reg output.
			.opb_preg_o,				//[RS]			Oprand B physical reg output.
			.opa_preg_rdy_bit_o,		//[RS]			Oprand A physical reg ready bit output. 
			.opb_preg_rdy_bit_o,		//[RS]			Oprand B physical reg ready bit output.
			.dest_old_preg_o,			//[ROB]			Old dest physical reg output. 
			.bak_data_o					//[Br_stack]	Back up data to branch stack.
		);

	free_list free_list0(
			.clk,
			.rst,						//|From where|
			.dispatch_en_i,				//[Decoder]		If true, output head entry and head++
			.retire_en_i,				//[ROB]			If true, write new retired preg to tail, and tail++
			.retire_preg_i,				//[ROB]			New retired preg.
			.branch_state_i,			//[ROB]			Branch prediction wrong or correct?
			.rc_head_i,					//[Br_stack]			Recover head to some point
			.free_preg_vld_o,			//[ROB, Map Table, RS]	Is output valid?
			.free_preg_o,				//[ROB, Map Table, Rs]	Output new free preg.
			.free_preg_cur_head_o		//[ROB]			Current head pointer.
		);























	//===============================================================
	// fu instantiation
	//===============================================================
	fu_main(
		.clk,
		.rst,
		
		.rob2fu_PC_i,
		.rs2fu_rob_idx_i,
		.rs2fu_ra_value_i,
		.rs2fu_rb_value_i,
		.rs2fu_dest_tag_i,
		.rs2fu_IR_i,
		.rs2fu_sel_i,

		.fu2preg_wr_en_o,
		.fu2preg_wr_idx_o,
		.fu2preg_wr_value_o,
		.fu2rob_done_o,
		.fu2rob_idx_o,
		.fu2rob_br_taken_o,
		.fu2rob_br_target_o,
		.fu_cdb_broad_o
	);

	//===============================================================
	// early branch recovery instantiation
	//===============================================================
	branch_stack branch_stack0(
			.clk, 
			.rst,
			.is_branch_i,			//[Dispatch]	A new branch is dispatched, mask should be updated.
			.branch_state_i,		//[ROB]			Branch prediction wrong or correct?		
			.branch_dep_mask_i,		//[ROB]			The mask of currently resolved branch.
			.bak_mp_next_data_i,	//[Map Table]	Back up data from map table.
			.bak_fl_head_i,			//[Free List]	Back up head of free list.
			.branch_mask_o,			//[ROB]			Send current mask value to ROB to save in an ROB entry.
			.branch_bit_o,			//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
			.rc_mt_all_data_o,		//[Map Table]	Recovery data for map table.
			.rc_fl_head_o,			//[Free List]	Recovery head value for free list.
			.full_o					//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
		);
	





	//===============================================================
	// LSQ instantiation
	//===============================================================
	

	//===============================================================
	// Dcache instantiation
	//===============================================================
	


