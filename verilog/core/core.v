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
	logic			clk,                      // system clk
	logic			rst,                      // system rst
								        // makes pipeline behave as single-cycle
	logic			bp2if_predict_i,
	logic	[63:0]	br_predict_target_PC_i,
	logic	[63:0]	br_flush_target_PC_i,
	logic	[63:0]	Imem2proc_data,		        // Data coming back from instruction-memory
	logic			Imem_valid,
	logic			br_flush_en_i,
	logic			id_request_i,

	logic	[63:0]	proc2Imem_addr,		// Address sent to Instruction memory
	logic	[63:0]	if_NPC_o,			// PC of instruction after fetched (PC+4).
	logic	[31:0]	if_IR_o,			// fetched instruction out
	logic			if_valid_inst_o	
	
	//---------------------------------------------------------------
	// signals for branch predictor
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for dispatch
	//---------------------------------------------------------------
	logic	[31:0]			if_id_IR;
	logic				if_id_valid_inst;
	logic	[4:0]			id_ra_idx;
	logic	[4:0]			id_rb_idx;
	logic	[4:0]			id_dest_idx;
	logic	[`FU_SEL_W-1:0]		id_fu_sel;
	logic	[31:0]			id_IR;
	logic				id_rd_mem;
	logic				id_wr_mem;
	logic				id_cond_branch;
	logic				id_uncond_branch;
	logic				id_valid_inst;

	// currently unused
	logic				id_ldl_mem;
	logic				id_stc_mem;
	logic				id_halt;
	logic				id_cpuid;
	logic				id_illegal;

	// branch mask generator signals
	logic				if_id_br_pred_taken;
	logic	[`BR_MASK_W-1:0]	bmg_br_mask;
	logic				bmg_br_mask_stall;

	//---------------------------------------------------------------
	// signals for rs
	//---------------------------------------------------------------
	logic	[`PRF_IDX_W-1:0]	rat_dest_tag;
	logic	[`PRF_IDX_W-1:0]	rat_opa_tag;
	logic	[`PRF_IDX_W-1:0]	rat_opb_tag;
	logic				rat_opa_rdy;
	logic				rat_opb_rdy;
	logic				id_inst_vld;
	logic	[`FU_SEL_W-1:0]		id_fu_sel;
	logic	[31:0]			id_IR;
	logic	[`ROB_IDX_W-1:0]	rob_idx;
	logic	[`RPF_IDX_W-1:0]	cdb_tag;
	logic				cdb_vld;
	logic				stall_dp;
	logic	[`BR_MASK_W-1:0]	bmg_br_mask;
	logic				rob_br_pred_correct;
	logic				rob_br_recovery;
	logic	[`BR_MASK_W-1:0]	rob_br_tag_fix;
	logic				rs_iss_vld;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag;
	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag;
	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel;
	logic	[31:0]			rs_iss_IR;
	logic	[`ROB_IDX_W-1:0]	rs_iss_rob_idx;
	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask;
	logic				rs_full;

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
	logic	[63:0]				rob2fu_PC_i,
	logic	[`ROB_IDX_W-1:0]	rs2fu_rob_idx_i,
	logic	[63:0]				rs2fu_ra_value_i,
	logic	[63:0]				rs2fu_rb_value_i,
	logic	[`PRF_IDX_W-1:0]	rs2fu_dest_tag_i,
	logic	[31:0]				rs2fu_IR_i,
	logic	[`FU_SEL_W-1:0]		rs2fu_sel_i,

	logic						fu2preg_wr_en_o,
	logic 	[`PRF_IDX_W-1:0]	fu2preg_wr_idx_o,
	logic 	[63:0]				fu2preg_wr_value_o,
	logic						fu2rob_done_o,
	logic	[`ROB_IDX_W-1:0]	fu2rob_idx_o,
	logic						fu2rob_br_taken_o,
	logic	[63:0]				fu2rob_br_target_o,
	logic 	[`PRF_IDX_W-1:0]	fu_cdb_broad_o

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
	if_stage if_stage0(
			.clk,                      // system clk
			.rst,                      // system rst
								        // makes pipeline behave as single-cycle
			.branch_i,
			.br_dirp_i,
			.bp2if_predict_i,
			.br_predict_target_PC_i,
			.br_flush_target_PC_i,
			.Imem2proc_data,		        // Data coming back from instruction-memory
			.Imem_valid,
			.br_flush_en_i,
			.id_request_i,
			.proc2Imem_addr,		// Address sent to Instruction memory
			.if_NPC_o,			// PC of instruction after fetched (PC+4).
			.if_IR_o,			// fetched instruction out
			.if_valid_inst_o	    // when low, instruction is garbage
           );       
                    
                    
	//===============================================================
	// branch predictor instantiation
	//===============================================================
	                
                    
	//===============================================================
	// dispatch instantiation
	//===============================================================
	id_stage id_stage(
			.clk				(clk),
			.rst				(rst),
                    	
			.if_id_IR_i		(if_id_IR),
			.if_id_valid_inst_i	(if_id_valid_inst),

			.id_ra_idx_o		(id_ra_idx),
			.id_rb_idx_o		(id_rb_idx),
			.id_dest_idx_o		(id_dest_idx),
			.id_fu_sel_o		(id_fu_sel),
			.id_IR_o		(id_IR),
			.id_rd_mem_o		(id_rd_mem),
			.id_wr_mem_o		(id_wr_mem),
			.id_cond_branch_o	(id_cond_branch),
			.id_uncond_branch_o	(id_uncond_branch),
			.id_ldl_mem_o		(id_ldl_mem),
			.id_stc_mem_o		(id_stc_mem),
			.id_halt_o		(id_halt),
			.id_cpuid_o		(id_cpuid),
			.id_illegal_o		(id_illegal),
			.id_valid_inst_o	(id_valid_inst)
	);

	bmg bmg(
			.clk			(clk),
			.rst			(rst),

			.id_cond_branch_i	(id_cond_branch),
			.id_uncond_branch_i	(id_uncond_branch),
			.if_id_br_pred_taken_i	(if_id_br_pred_taken),
			.rob_br_pred_correct_i	(rob_br_pred_correct),
			.rob_br_recovery_i	(rob_br_recovery),
			.rob_br_mask_i		(rob_br_mask),
			.rob_br_tag_i		(rob_br_tag),

			.bmg_br_mask_o		(bmg_br_mask),
			.bmg_br_mask_stall_o	(bmg_br_mask_stall)
	);

	//===============================================================
	// rs instantiation
	//===============================================================
	rs rs(
			.clk			(clk),
			.rst			(rst),

			.rat_dest_tag_i		(rat_dest_tag),
			.rat_opa_tag_i		(rat_opa_tag),
			.rat_opb_tag_i		(rat_opb_tag),
			.rat_opa_rdy_i		(rat_opa_rdy),
			.rat_opb_rdy_i		(rat_opb_rdy),
			.id_inst_vld_i		(id_inst_vld),
			.id_fu_sel_i		(id_fu_sel),
			.id_IR_i		(id_IR),
			.rob_idx_i		(rob_idx),
			.cdb_tag_i		(cdb_tag),
			.cdb_vld_i		(cdb_vld),
			.stall_dp_i		(stall_dp),
			.bmg_br_mask_i		(bmg_br_mask),
			.rob_br_pred_correct_i	(rob_br_pred_correct),
			.rob_br_recovery_i	(rob_br_recovery),
			.rob_br_tag_fix_i	(rob_br_tag_fix),

			.rs_iss_vld_o		(rs_iss_vld),
			.rs_iss_opa_tag_o	(rs_iss_opa_tag),
			.rs_iss_opb_tag_o	(rs_iss_opb_tag),
			.rs_iss_dest_tag_o	(rs_iss_dest_tag),
			.rs_iss_fu_sel_o	(rs_iss_fu_sel),
			.rs_iss_IR_o		(rs_iss_IR),
			.rs_iss_rob_idx_o	(rs_iss_rob_idx),
			.rs_iss_br_mask_o	(rs_iss_br_mask),
			.rs_full_o		(rs_full)
	);

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
	fu_main fu_main0(
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
	


