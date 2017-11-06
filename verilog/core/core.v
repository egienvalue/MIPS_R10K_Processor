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
<<<<<<< HEAD
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
=======
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
>>>>>>> 92927c82b21f3d66ce19e61c6169fef6b49e18c9
	
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
<<<<<<< HEAD
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


=======
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
                    
                    
>>>>>>> 92927c82b21f3d66ce19e61c6169fef6b49e18c9
	//===============================================================
	// branch predictor instantiation
	//===============================================================
	                
                    
	//===============================================================
	// dispatch instantiation
	//===============================================================
	id_stage id_stage(
			.clk				(clk),
			.rst				(rst),
<<<<<<< HEAD

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
=======
                    	
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
>>>>>>> 92927c82b21f3d66ce19e61c6169fef6b49e18c9
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 92927c82b21f3d66ce19e61c6169fef6b49e18c9
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
	


