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

		input			[3:0]					mem2proc_response_i,
		input			[63:0]					mem2proc_data_i,
		input			[3:0]					mem2proc_tag_i,
	
		output	logic	[1:0]					proc2mem_command_o,
		output	logic	[63:0]					proc2mem_addr_o,
		output	logic	[63:0]					proc2mem_data_o,

		// need more ports for testbench!!!


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
	logic  [63:0]				Imem2proc_data;
	logic        				Imem_valid;
	logic						br_flush_en_i;
	logic						id_request_i;

	logic [63:0]				proc2Imem_addr;		
	logic [63:0]				if_NPC_o;			
	logic [31:0]				if_IR_o;
	logic       				if_valid_inst_o;	
	
	//---------------------------------------------------------------
	// signals for branch predictor
	//---------------------------------------------------------------


	//---------------------------------------------------------------
	// signals for dispatch
	//---------------------------------------------------------------
	// dispatch
	logic						dispatch_en;

	// decoder
	logic	[31:0]				if_id_IR_i;
	logic						if_id_valid_inst_i;

	logic	[4:0]				id_ra_idx_o;
	logic	[4:0]				id_rb_idx_o;
	logic	[4:0]				id_dest_idx_o;
	logic	[`FU_SEL_W-1:0]		id_fu_sel_o;
	logic	[31:0]				id_IR_o;
	logic						id_rd_mem_o;
	logic						id_wr_mem_o;
	logic						id_cond_branch_o;
	logic						id_uncond_branch_o;
	logic						id_valid_inst_o;

	// currently unused
	logic						id_ldl_mem_o;
	logic						id_stc_mem_o;
	logic						id_halt_o;
	logic						id_cpuid_o;
	logic						id_illegal_o;

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
	logic	[`PRF_IDX_W-1:0]	fl2rob_tag_i;
	logic	[`PRF_IDX_W-2:0]	fl2rob_cur_head_i;
	logic	[`PRF_IDX_W-1:0]	map2rob_tag_i;
	logic	[`PRF_IDX_W-2:0]	decode2rob_logic_dest_i;//lo
	logic	[63:0]				decode2rob_PC_i;//instructio
	logic						decode2rob_br_flag_i;//flag 
	logic						decode2rob_br_pretaken_i;//b
	logic	[63:0]				decode2rob_br_target_i;//bra
	logic						decode2rob_rd_mem_i;//flag s
	logic						decode2rob_wr_mem_i;//flag s
	logic						rob_dispatch_en_i;//signal f
	logic	[`BR_MASK_W-1:0]	decode2rob_br_mask_i;

	logic	[`ROB_IDX_W:0]		fu2rob_idx_i;//tag sent from
	logic						fu2rob_done_signal_i;//done 
	logic						fu2rob_br_taken_i;//branck t

	logic	[`HT_W-1:0]			rob2rs_tail_idx_o;//tail # s
	logic	[`PRF_IDX_W-1:0]	rob2fl_tag_o;//tag from ROB 
	logic	[`PRF_IDX_W-1:0]	rob2arch_map_tag_o;//tag fro
	logic	[`PRF_IDX_W-2:0]	rob2arch_map_logic_dest_o;//
	logic						rob_stall_dp_o;//signal show
	logic						rob_head_retire_rdy_o;//the 

	logic						br_recovery_rdy_o;//ready to
	logic	[`PRF_IDX_W-2:0]	rob2fl_recover_head_o;
	logic	[`BR_MASK_W-1:0]	br_recovery_mask_o;
	logic	[`BR_STATE_W-1:0]	br_state_o;


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
	//logic	[`BR_STATE_W-1:0]	branch_state_i;		    //[ROB]			
	logic	[31:0][6:0]			rc_mt_all_data_i;		//[Br_stack]
	
	logic	[5:0]				opa_preg_o;			    //[RS]			
	logic	[5:0]				opb_preg_o;			    //[RS]			
	logic		 				opa_preg_rdy_bit_o;	    //[RS]			
	logic		 				opb_preg_rdy_bit_o;	    //[RS]			
	logic	[5:0]				dest_old_preg_o;		//[ROB]			
	logic	[31:0][6:0]			bak_data_o				//[Br_stack]	
	
	// Freelist
	//logic						dispatch_en_i;			//[Decoder]		
	logic						retire_en_i;			//[ROB]			
	logic	[5:0]				retire_preg_i;			//[ROB]			
	//logic	[`BR_STATE_W-1:0]	branch_state_i;			//[ROB]			
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
	// signals for preg file
	//---------------------------------------------------------------
	logic						wr_en_i;
	logic	[`P_REG_SIZE:0]		rda_idx_i,rdb_idx_i, wr_idx_i;
	logic						wr_data_i;

	logic	[63:0]				rda_data_o, rdb_data_o;

	//---------------------------------------------------------------
	// signals for early branch recovery (br stack)
	//---------------------------------------------------------------
	logic						is_branch_i;			//[Dispatch]	
	logic	[`BR_STATE_W-1:0]	branch_state_i;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	branch_dep_mask_i;		//[ROB]			
	logic	[31:0][6:0]			bak_mp_next_data_i;		//[Map Table]	
	logic	[4:0]				bak_fl_head_i;			//[Free List]

	logic	[`BR_MASK_W-1:0]	br_mask_o;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	br_bit_o;			//[RS]			
	logic	[31:0][6:0]			rc_mt_all_data_o;		//[Map Table]
	logic	[4:0]				rc_fl_head_o;			//[Free List]
	logic						br_stack_full_o;	 

	//---------------------------------------------------------------
	// signals for LSQ
	//---------------------------------------------------------------
	
	
	//---------------------------------------------------------------
	// signals for Dcache
	//---------------------------------------------------------------
	
	

	//===============================================================
	// Icache instantiation
	//===============================================================
	assign Imem2proc_response_i = mem2proc_response_i;
	assign Imem2Icache_data_i	= mem2proc_data_i;
	assign Imem2proc_tag_i		= mem2proc_tag_i;
	assign if2Icache_addr_i		= proc2Imem_addr;
	assign if2Icache_flush_i	= br_recovery_rdy_o; // from rob
	
	Icache Icache0 (
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
	assign bp2if_predict_i			= 1'b0; // bp not added, always non-taken
	assign br_predict_target_PC_i	= 64'h0; // bp not added
	assign br_flush_target_PC_i		= fu2rob_br_target_o;
	assign Imem2proc_data			= Icache2if_data_o;
	assign Imem_valid				= Icache2if_vld_o;
	assign br_flush_en_i			= br_recovery_rdy_o; // from rob
	assign id_request_i				= dispatch_en; // dispatch_en

	if_stage if_stage (
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
			.if_NPC_o				(if_NPC_o),	
			.if_IR_o				(if_IR_o),		
			.if_valid_inst_o		(if_valid_inst_o)
			//output logic		  if2id_empty_o
	);


	//===============================================================
	// branch predictor instantiation
	//===============================================================
	                
                    
	//===============================================================
	// dispatch instantiation
	//===============================================================
	assign dispatch_en 			= ; // !!! no structural hazard
	assign if_id_IR_i			= if_IR_o;
	assign if_id_valid_inst_i	= if_valid_inst_o;
	
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


	//===============================================================
	// rs instantiation
	//===============================================================
	assign rat_dest_tag_i		= free_preg_o; // from freelist
	assign rat_opa_tag_i		= opa_preg_o;
	assign rat_opb_tag_i		= opb_preg_o;
	assign rat_opa_rdy_i		= opa_preg_rdy_bit_o;
	assign rat_opb_rdy_i		= opb_preg_rdy_bit_o;
	assign id_inst_vld_i		= id_valid_inst_o;
	assign id_fu_sel_i			= id_fu_sel_o;
	assign id_IR_i				= id_IR_o;
	assign rob_idx_i			= rob2rs_tail_idx_o;
	assign cdb_tag_i			= fu_cdb_broad_o;
	assign cdb_vld_i			= ; // !!! fu should add cdb_vld_o, when
									// dest_areg != `ZERO_REG
	assign stall_dp_i			= ~dispatch_en;
	assign bmg_br_mask_i		= br_mask_o;
	assign rob_br_pred_correct_i= br_state_o[1]; // !!! one of the br_state_o in rob
	assign rob_br_recovery_i	= br_state_o[0]; // !!! one of the br_state_o in rob
	assign rob_br_tag_fix_i		= br_bit_o; // from branch stack

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
	assign fl2rob_tag_i				= free_preg_o; // Tnew
	assign fl2rob_cur_head_i		= free_preg_cur_head_o;
	assign map2rob_tag_i			= dest_old_preg_o; // Told
	assign decode2rob_logic_dest_i	= id_dest_idx_o;
	assign decode2rob_PC_i			= if_NPC_o; // !!! Next PC, from if_stage?
	assign decode2rob_br_flag_i		= id_cond_branch_o | id_uncond_branch_o;
	assign decode2rob_br_pretaken_i	= 1'b0; // !! from BP, non-taken for now
	assign decode2rob_br_target_i	= 64'h0; // !! from BP, non-taken for now
	assign decode2rob_rd_mem_i		= id_rd_mem_o;
	assign decode2rob_wr_mem_i		= id_wr_mem_o;
	assign rob_dispatch_en_i		= dispatch_en;
	assign decode2rob_br_mask_i		= br_mask_o; // !! from br stack
	assign fu2rob_idx_i				= fu2rob_idx_o;
	assign fu2rob_done_signal_i		= fu2rob_done_o;
	assign fu2rob_br_taken_i		= fu2rob_br_taken_o;

	rob rob (
		.clk						(clk),
		.rst						(rst),									
		.fl2rob_tag_i				(fl2rob_tag_i),
		.fl2rob_cur_head_i			(fl2rob_cur_head_i),
		.map2rob_tag_i				(map2rob_tag_i),
		.decode2rob_logic_dest_i	(decode2rob_logic_dest_i),
		.decode2rob_PC_i			(decode2rob_PC_i),
		.decode2rob_br_flag_i		(decode2rob_br_flag_i),
		.decode2rob_br_pretaken_i	(decode2rob_br_pretaken_i),
		.decode2rob_br_target_i		(decode2rob_br_target_i),
		.decode2rob_rd_mem_i		(decode2rob_rd_mem_i),
		.decode2rob_wr_mem_i		(decode2rob_wr_mem_i),
		.rob_dispatch_en_i			(rob_dispatch_en_i),
		.decode2rob_br_mask_i		(decode2rob_br_mask_i),

		.fu2rob_idx_i				(fu2rob_idx_i),
		.fu2rob_done_signal_i		(fu2rob_done_signal_i),
		.fu2rob_br_taken_i			(fu2rob_br_taken_i),

		.rob2rs_tail_idx_o			(rob2rs_tail_idx_o),
		.rob2fl_tag_o				(rob2fl_tag_o),
		.rob2arch_map_tag_o			(rob2arch_map_tag_o),
		.rob2arch_map_logic_dest_o	(rob2arch_map_logic_dest_o),
		.rob_stall_dp_o				(rob_stall_dp_o),
		.rob_head_retire_rdy_o		(rob_head_retire_rdy_o),

		.br_recovery_rdy_o			(br_recovery_rdy_o),
		.rob2fl_recover_head_o		(rob2fl_recover_head_o),
		.br_recovery_mask_o			(br_recovery_mask_o),
		.br_state_o					(br_state_o)
	);	

	//===============================================================
	// map table and free list instantiation
	//===============================================================
	assign opa_areg_idx_i			= id_ra_idx_o;
	assign opb_areg_idx_i			= id_rb_idx_o;
	assign dest_areg_idx_i			= id_dest_idx_o;
	assign new_free_preg_i			= free_preg_o; // !! Tnew from freelist
	assign cdb_set_rdy_bit_preg_i	= fu_cdb_broad_o;
	assign cdb_set_rdy_bit_en_i		= ; // !!! same as in rs, fu should add
	//assign branch_state_i			= br_state_o;
	assign rc_mt_all_data_i			= rc_mt_all_data_o;

	map_table	map_table0 (
		.clk					(clk),
		.rst					(rst),	//|From where|	
								
		.opa_areg_idx_i			(opa_areg_idx_i),	//[Decoder]		
		.opb_areg_idx_i			(opb_areg_idx_i),	//[Decoder]		
		.dest_areg_idx_i		(dest_areg_idx_i),	//[Decoder]		
		.new_free_preg_i		(new_free_preg_i),	//[Free-List]	
		.dispatch_en_i			(dispatch_en), //[Decoder]		
		.cdb_set_rdy_bit_preg_i	(cdb_set_rdy_bit_preg_i), //[CDB]			 
		.cdb_set_rdy_bit_en_i	(cdb_set_rdy_bit_en_i),	//[CDB]			
		.branch_state_i			(br_state_o), //[ROB]			
		.rc_mt_all_data_i		(rc_mt_all_data_i), //[Br_stack]

		.opa_preg_o				(opa_preg_o), //[RS]			
		.opb_preg_o				(opb_preg_o), //[RS]			
		.opa_preg_rdy_bit_o		(opa_preg_rdy_bit_o), //[RS]			
		.opb_preg_rdy_bit_o		(opb_preg_rdy_bit_o), //[RS]			
		.dest_old_preg_o		(dest_old_preg_o), //[ROB]			
		.bak_data_o				(bak_data_o)  //[Br_stack]	
	);

	// free list
	assign retire_en_i			= rob_head_retire_rdy_o;
	assign retire_preg_i		= rob2fl_tag_o; // !! Told from rob
	assign rc_head_i			= rc_fl_head_o;

	free_list free_list0(
		.clk					(clk),
		.rst					(rst), //|From where|

		.dispatch_en_i			(dispatch_en),	//[Decoder]		
		.retire_en_i			(retire_en_i),	//[ROB]			
		.retire_preg_i			(retire_preg_i),	//[ROB]			
		.branch_state_i			(br_state_o), //[ROB]			
		.rc_head_i				(rc_head_i), //[Br_stack]

		.free_preg_vld_o		(free_preg_vld_o), //[ROB, Map Table, RS]
		.free_preg_o			(free_preg_o),	//[ROB, Map Table, Rs]
		.free_preg_cur_head_o	(free_preg_cur_head_o) //[ROB]
	);

	//===============================================================
	// fu instantiation
	//===============================================================
	assign rob2fu_PC_i			= ; // !!! what for?
	assign rs2fu_rob_idx_i		= rs_iss_rob_idx_o;
	assign rs2fu_ra_value_i		= rda_data_o; // !! from preg_file
	assign rs2fu_rb_value_i		= rdb_data_o; // !!
	assign rs2fu_dest_tag_i		= rs_iss_dest_tag_o; //  why we need here?
	assign rs2fu_IR_i			= rs_iss_IR_o; //  why we need here?
	assign rs2fu_sel_i			= rs_iss_fu_sel_o;

	fu_main fu_main0(
		.clk				(clk),
		.rst				(rst),
		
		.rob2fu_PC_i		(rob2fu_PC_i),
		.rs2fu_rob_idx_i	(rs2fu_rob_idx_i),
		.rs2fu_ra_value_i	(rs2fu_ra_value_i),
		.rs2fu_rb_value_i	(rs2fu_rb_value_i),
		.rs2fu_dest_tag_i	(rs2fu_dest_tag_i),
		.rs2fu_IR_i			(rs2fu_IR_i),
		.rs2fu_sel_i		(rs2fu_sel_i),

		.fu2preg_wr_en_o	(fu2preg_wr_en_o), //!!! same as cdb_vld??
		.fu2preg_wr_idx_o	(fu2preg_wr_idx_o),
		.fu2preg_wr_value_o	(fu2preg_wr_value_o),
		.fu2rob_done_o		(fu2rob_done_o),
		.fu2rob_idx_o		(fu2rob_idx_o),
		.fu2rob_br_taken_o	(fu2rob_br_taken_o),
		.fu2rob_br_target_o	(fu2rob_br_target_o),
		.fu_cdb_broad_o		(fu_cdb_broad_o)
	);

	//===============================================================
	// fu instantiation
	//===============================================================
	assign wr_en_i		= fu2preg_wr_en_o; // from rob. !!! rob should add complete_en signal
							// or same as cdb_vld
	assign rda_idx_i	= rs_iss_opa_tag_o; // !! from rs issue
	assign rdb_idx_i	= rs_iss_opb_tag_o; // !! from rs issue
	assign wr_idx_i		= fu2preg_wr_idx_o; // !! Tnew from rob, wr preg
	assign wr_data_i	= fu2preg_wr_value_o; // need value from fu

	Preg_file preg_file (
		.clk		(clk),
		.rst		(rst),
		.wr_en_i	(wr_en_i),
		.rda_idx_i	(rda_idx_i),
		.rdb_idx_i	(rdb_idx_i),
		.wr_idx_i	(wr_idx_i),
		.wr_data_i	(wr_data_i),

		.rda_data_o	(rda_data_o), 
		.rdb_data_o	(rdb_data_o)
	);


	//===============================================================
	// early branch recovery instantiation
	//===============================================================
	assign is_br_i				= disp2br_en;
	assign br_state_i			= br_state_o; // from rob
	assign br_dep_mask_i		= br_recovery_mask_o; // from rob
	assign bak_mp_next_data_i	= bak_data_o;
	assign bak_fl_head_i		= rc_head_i;

	branch_stack branch_stack0(
		.clk				(clk), 
		.rst				(rst),

		.is_br_i			(is_br_i),			
		.br_state_i			(br_state_i),
		.br_dep_mask_i		(br_dep_mask_i),
		.bak_mp_next_data_i	(bak_mp_next_data_i),	
		.bak_fl_head_i		(bak_fl_head_i),

		.br_mask_o			(br_mask_o),
		.br_bit_o			(br_bit_o),
		.rc_mt_all_data_o	(rc_mt_all_data_o),
		.rc_fl_head_o		(rc_fl_head_o),
		.full_o				(br_stack_full_o)
	);
	
	//===============================================================
	// LSQ instantiation
	//===============================================================
	

	//===============================================================
	// Dcache instantiation
	//===============================================================
	



endmodule: core
