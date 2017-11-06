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
	logic	[3:0]							Imem2proc_response_i;
	logic	[63:0]							Imem2Icache_data_i;
	logic	[3:0]							Imem2proc_tag_i;

	logic	[63:0]							if2Icache_addr_i;
	logic									if2Icache_flush_i;

	logic	[63:0]							proc2Imem_addr_o;
	logic	[1:0]							proc2Imem_command_o;

	logic									Icache2if_vld_o;
	logic	[`ICACHE_DATA_IN_BITS-1:0]		Icache2if_data_o;	

	//---------------------------------------------------------------
	// signals for if_stage
	//---------------------------------------------------------------
	logic						bp2if_predict_i;
	logic  [63:0]				br_predict_target_PC_i;
	logic  [63:0]				br_flush_target_PC_i;
	logic  [63:0]				Imem2proc_data;		        // Data coming back from instruction-memory
	logic        				Imem_valid;
	logic						br_flush_en_i;
	logic						id_request_i;

	logic [63:0]				proc2Imem_addr;		// Address sent to Instruction memory
	logic [63:0]				if_NPC_out;			// PC of instruction after fetched (PC+4).
	logic [31:0]				if_IR_out;			// fetched instruction out
	logic       				if_valid_inst_out;	
	
	//---------------------------------------------------------------
	// signals for branch predictor
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for dispatch
	//---------------------------------------------------------------
	logic	[31:0]				if_id_IR_o;
	logic						if_id_valid_inst_o;

	logic	[4:0]				id_ra_idx_i;
	logic	[4:0]				id_rb_idx_i;
	logic	[4:0]				id_dest_idx_i;
	logic	[`FU_SEL_W-1:0]		id_fu_sel_i;
	logic	[31:0]				id_IR_i;
	logic						id_rd_mem_i;
	logic						id_wr_mem_i;
	logic						id_cond_branch_i;
	logic						id_uncond_branch_i;
	logic						id_valid_inst_i;

	// currently unused
	logic						id_ldl_mem_i;
	logic						id_stc_mem_i;
	logic						id_halt_i;
	logic						id_cpuid_i;
	logic						id_illegal_i;

	// branch mask generator signals
	//logic						if_id_br_pred_taken;
	//logic	[`BR_MASK_W-1:0]	bmg_br_mask;
	//logic						bmg_br_mask_stall;

	//---------------------------------------------------------------
	// signals for rs
	//---------------------------------------------------------------
	logic	[`PRF_IDX_W-1:0]	rat_dest_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opa_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opb_tag_i;
	logic						rat_opa_rdy_i;
	logic						rat_opb_rdy_i;
	logic						id_inst_vld_i;
	logic	[`FU_SEL_W-1:0]		id_fu_sel_i;
	logic	[31:0]				id_IR_i;
	logic	[`ROB_IDX_W-1:0]	rob_idx_i;
	logic	[`RPF_IDX_W-1:0]	cdb_tag_i;
	logic						cdb_vld_i;
	logic						stall_dp_i;
	logic	[`BR_MASK_W-1:0]	bmg_br_mask_i;
	logic						rob_br_pred_correct_i;
	logic						rob_br_recovery_i;
	logic	[`BR_MASK_W-1:0]	rob_br_tag_fix_i;

	logic						rs_iss_vld_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o;
	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel_o;
	logic	[31:0]				rs_iss_IR_o;
	logic	[`ROB_IDX_W-1:0]	rs_iss_rob_idx_o;
	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask_o;
	logic						rs_full_o;


	//---------------------------------------------------------------
	// signals for rob
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for map table and free list
	//---------------------------------------------------------------
	// Maptable
	logic	[4:0]				opa_areg_idx_i;			//[Decoder]		
	logic	[4:0]				opb_areg_idx_i;		    //[Decoder]		
	logic	[4:0]				dest_areg_idx_i;		//[Decoder]		
	logic	[5:0]				new_free_preg_i;		//[Free-List]	
	//logic						dispatch_en_i;			//[Decoder]		
	logic	[5:0]				cdb_set_rdy_bit_preg_i; //[CDB]			
	logic						cdb_set_rdy_bit_en_i;	//[CDB]			
	logic	[`BR_STATE_W-1:0]	branch_state_i;		    //[ROB]			
	logic	[31:0][6:0]			rc_mt_all_data_i;		//[Br_stack]
	
	logic	[5:0]				opa_preg_o;			    //[RS]			
	logic	[5:0]				opb_preg_o;			    //[RS]			
	logic		 				opa_preg_rdy_bit_o;	    //[RS]			
	logic		 				opb_preg_rdy_bit_o;	    //[RS]			
	logic	[5:0]				dest_old_preg_o;		//[ROB]			
	logic	[31:0][6:0]			bak_data_o				//[Br_stack]	
	//Signal
	//logic						dispatch_en_i;			//[Decoder]		
	logic						retire_en_i;			//[ROB]			
	logic	[5:0]				retire_preg_i;			//[ROB]			
	logic	[`BR_STATE_W-1:0]	branch_state_i;			//[ROB]			
	logic	[4:0]				rc_head_i;				//[Br_stack]	
	logic						free_preg_vld_o;		//[ROB, Map Table, RS]	
	logic	[5:0]				free_preg_o;			//[ROB, Map Table, Rs]	
	logic	[4:0]				free_preg_cur_head_o;	//[ROB]	


	//---------------------------------------------------------------
	// signals for fu
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for early branch recovery (br stack)
	//---------------------------------------------------------------
	logic						is_branch_i;			//[Dispatch]	
	logic	[`BR_STATE_W-1:0]	branch_state_i;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	branch_dep_mask_i;		//[ROB]			
	logic	[31:0][6:0]			bak_mp_next_data_i;		//[Map Table]	
	logic	[4:0]				bak_fl_head_i;			//[Free List]	
	logic	[`BR_MASK_W-1:0]	branch_mask_o;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	branch_bit_o;			//[RS]			
	logic	[31:0][6:0]			rc_mt_all_data_o;		//[Map Table]
	logic	[4:0]				rc_fl_head_o;			//[Free List]
	logic						full_o;					//[ROB]		 

	//---------------------------------------------------------------
	// signals for LSQ
	//---------------------------------------------------------------
	
	
	//---------------------------------------------------------------
	// signals for Dcache
	//---------------------------------------------------------------
	
	

	//===============================================================
	// Icache instantiation
	//===============================================================
	Icache (
		.clk					(clk),
		.rst					(rst),
		
		.Imem2proc_response_i	(Imem2proc_response_i),
		.Imem2Icache_data_i		(Imem2Icache_data_i),
		.Imem2proc_tag_i		(Imem2proc_tag_i),

		.if2Icache_addr_i		(if2Icache_addr_i),
		.if2Icache_flush_i		(if2Icache_flush_i),

		.proc2Imem_addr_o		(proc2Imem_addr_o),
		.proc2Imem_command_o	(proc2Imem_command_o),

		.Icache2if_vld_o		(Icache2if_vld_o),
		.Icache2if_data_o		(Icache2if_data_o)
	);

	//===============================================================
	// if_stage instantiation
	//===============================================================
	if_stage(
			.clk					(clk),                      
			.rst					(rst),                      
								                 
			.bp2if_predict_i		(bp2if_predict_i),
			.br_predict_target_PC_i	(br_predict_target_PC_i),
			.br_flush_target_PC_i	(br_flush_target_PC_i),
			.Imem2proc_data			(Imem2proc_data),
			.Imem_valid				(Imem_valid),
			.br_flush_en_i			(br_flush_en_i),
			.id_request_i			(id_request_i),

			.proc2Imem_addr			(proc2Imem_addr),
			.if_NPC_out				(if_NPC_out),	
			.if_IR_out				(if_IR_out),		
			.if_valid_inst_out		(if_valid_inst_out)	// when low, instruction is garbage
			//output logic		  if2id_empty_o
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

			.if_id_IR_i			(if_id_IR_i),
			.if_id_valid_inst_i	(if_id_valid_inst_i),

			.id_ra_idx_o		(id_ra_idx_o),
			.id_rb_idx_o		(id_rb_idx_o),
			.id_dest_idx_o		(id_dest_idx_o),
			.id_fu_sel_o		(id_fu_sel_o),
			.id_IR_o			(id_IR_o),
			.id_rd_mem_o		(id_rd_mem_o),
			.id_wr_mem_o		(id_wr_mem_o),
			.id_cond_branch_o	(id_cond_branch_o),
			.id_uncond_branch_o	(id_uncond_branch_o),
			.id_ldl_mem_o		(id_ldl_mem_o),
			.id_stc_mem_o		(id_stc_mem_o),
			.id_halt_o			(id_halt_o),
			.id_cpuid_o			(id_cpuid_o),
			.id_illegal_o		(id_illegal_o),
			.id_valid_inst_o	(id_valid_inst_o)
	);

/*	bmg bmg(
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
			.bmg_br_mask_stall_o(bmg_br_mask_stall)
	);*/

	//===============================================================
	// rs instantiation
	//===============================================================
	rs rs (
			.clk					(clk),
			.rst					(rst),

			.rat_dest_tag_i			(rat_dest_tag_i),
			.rat_opa_tag_i			(rat_opa_tag_i),
			.rat_opb_tag_i			(rat_opb_tag_i),
			.rat_opa_rdy_i			(rat_opa_rdy_i),
			.rat_opb_rdy_i			(rat_opb_rdy_i),
			.id_inst_vld_i			(id_inst_vld_i),
			.id_fu_sel_i			(id_fu_sel_i),
			.id_IR_i				(id_IR_i),
			.rob_idx_i				(rob_idx_i),
			.cdb_tag_i				(cdb_tag_i),
			.cdb_vld_i				(cdb_vld_i),
			.stall_dp_i				(stall_dp_i),
			.bmg_br_mask_i			(bmg_br_mask_i), //	branch recovery latter
			.rob_br_pred_correct_i	(rob_br_pred_correct_i),
			.rob_br_recovery_i		(rob_br_recovery_i),
			.rob_br_tag_fix_i		(rob_br_tag_fix_i),

			.rs_iss_vld_o			(rs_iss_vld_o),
			.rs_iss_opa_tag_o		(rs_iss_opa_tag_o),
			.rs_iss_opb_tag_o		(rs_iss_opb_tag_o),
			.rs_iss_dest_tag_o		(rs_iss_dest_tag_o),
			.rs_iss_fu_sel_o		(rs_iss_fu_sel_o),
			.rs_iss_IR_o			(rs_iss_IR_o),
			.rs_iss_rob_idx_o		(rs_iss_rob_idx_o),
			.rs_iss_br_mask_o		(rs_iss_br_mask_o),
			.rs_full_o				(rs_full_o)
	);

	//===============================================================
	// map table and free list instantiation
	//===============================================================
	map_table	map_table0 (
			.clk					(clk),
			.rst					(rst),	//|From where|									
			.opa_areg_idx_i			(opa_areg_idx_i),	//[Decoder]		
			.opb_areg_idx_i			(opb_areg_idx_i),	//[Decoder]		
			.dest_areg_idx_i		(dest_areg_idx_i),	//[Decoder]		
			.new_free_preg_i		(new_free_preg_i),	//[Free-List]	
			.dispatch_en_i			(), //[Decoder]		
			.cdb_set_rdy_bit_preg_i	(cdb_set_rdy_bit_preg_i), //[CDB]			 
			.cdb_set_rdy_bit_en_i	(cdb_set_rdy_bit_en_i),	//[CDB]			
			.branch_state_i			(branch_state_i), //[ROB]			
			.rc_mt_all_data_i		(rc_mt_all_data_i), //[Br_stack]
			.opa_preg_o				(opa_preg_o), //[RS]			
			.opb_preg_o				(opb_preg_o), //[RS]			
			.opa_preg_rdy_bit_o		(opa_preg_rdy_bit_o), //[RS]			
			.opb_preg_rdy_bit_o		(opb_preg_rdy_bit_o), //[RS]			
			.dest_old_preg_o		(dest_old_preg_o), //[ROB]			
			.bak_data_o				(bak_data_o)  //[Br_stack]	
		);

	free_list free_list0(
			.clk					(clk),
			.rst					(rst), //|From where|
			.dispatch_en_i			(),	//[Decoder]		
			.retire_en_i			(retire_en_i),	//[ROB]			
			.retire_preg_i			(retire_preg_i),	//[ROB]			
			.branch_state_i			(branch_state_i), //[ROB]			
			.rc_head_i				(rc_head_i), //[Br_stack]	
			.free_preg_vld_o		(free_preg_vld_o), //[ROB, Map Table, RS]
			.free_preg_o			(free_preg_o),	//[ROB, Map Table, Rs]
			.free_preg_cur_head_o	(free_preg_cur_head_o) //[ROB]
		);

	//===============================================================
	// fu instantiation
	//===============================================================
	fu_main(
		.clk				(clk),
		.rst				(rst),
		
		.rob2fu_PC_i		(rob2fu_PC_i),
		.rs2fu_rob_idx_i	(rs2fu_rob_idx_i),
		.rs2fu_ra_value_i	(rs2fu_ra_value_i),
		.rs2fu_rb_value_i	(rs2fu_rb_value_i),
		.rs2fu_dest_tag_i	(rs2fu_dest_tag_i),
		.rs2fu_IR_i			(rs2fu_IR_i),
		.rs2fu_sel_i		(rs2fu_sel_i),

		.fu2preg_wr_en_o	(fu2preg_wr_en_o),
		.fu2preg_wr_idx_o	(fu2preg_wr_idx_o),
		.fu2preg_wr_value_o	(fu2preg_wr_value_o),
		.fu2rob_done_o		(fu2rob_done_o),
		.fu2rob_idx_o		(fu2rob_idx_o),
		.fu2rob_br_taken_o	(fu2rob_br_taken_o),
		.fu2rob_br_target_o	(fu2rob_br_target_o),
		.fu_cdb_broad_o		(fu_cdb_broad_o)
	);

	//===============================================================
	// early branch recovery instantiation
	//===============================================================
	branch_stack branch_stack0(
			.clk, 
			.rst,
			.is_branch_i,			
			.branch_state_i,		
			.branch_dep_mask_i,		
			.bak_mp_next_data_i,	
			.bak_fl_head_i,			
			.branch_mask_o,			
			.branch_bit_o,			
			.rc_mt_all_data_o,		
			.rc_fl_head_o,			
			.full_o					
		);
	
	//===============================================================
	// LSQ instantiation
	//===============================================================
	

	//===============================================================
	// Dcache instantiation
	//===============================================================
	


