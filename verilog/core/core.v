//*****************************************************************************
// Filename: core.v
// Discription: core top level integration, instantiate new feature modules
// 				here
// Author: group 5
// Version History
//   <11/5> initial creation: integrate without br_predictor, LSQ
//   <11/30> added LSQ, Dcache -Hengfei
//*****************************************************************************
`timescale 1ns/100ps

module core (
		input											clk,
		input											rst,

		input											cpu_id_i,

		input			[3:0]							mem2proc_response_i,
		input			[63:0]							mem2proc_data_i,
		input			[3:0]							mem2proc_tag_i,
	
		output	logic	[1:0]							proc2mem_command_o,
		output	logic	[63:0]							proc2mem_addr_o,
		output	logic	[63:0]							proc2mem_data_o,

		// may need more ports for testbench!!!
		output	logic	[3:0]							core_retired_instrs,
		output	logic	[3:0]							core_error_status,

		//-----------------------------------------------
		// network(or bus) side signals
		input											bus2Dcache_req_ack_i,
		input											bus2Dcache_req_id_i,
		input			[`DCACHE_TAG_W-1:0]				bus2Dcache_req_tag_i,
		input			[`DCACHE_IDX_W-1:0]				bus2Dcache_req_idx_i,
		input	message_t								bus2Dcache_req_message_i,
		input											bus2Dcache_rsp_vld_i,
		input											bus2Dcache_rsp_id_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		bus2Dcache_rsp_data_i,

		output	logic									Dcache2bus_req_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache2bus_req_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache2bus_req_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_req_data_o,
		output	message_t								Dcache2bus_req_message_o,

		output	logic									Dcache2bus_rsp_ack_o,
		// response to other request
		output	logic									Dcache2bus_rsp_vld_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_rsp_data_o,

		// Icache ports
		input			[3:0]							Imem2proc_response_i,
		input			[63:0]							Imem2Icache_data_i,
		input			[3:0]							Imem2proc_tag_i,

		output			[63:0]							proc2Imem_addr_o,
		output			[1:0]							proc2Imem_command_o
	);



	//---------------------------------------------------------------
	// signals for Icache
	//---------------------------------------------------------------
	//logic	[3:0]							Imem2proc_response_i;
	//logic	[63:0]							Imem2Icache_data_i;
	//logic	[3:0]							Imem2proc_tag_i;

	logic	[63:0]							if2Icache_addr_i;
	logic									if2Icache_req_i;
	logic									if2Icache_flush_i;

	//logic	[63:0]							proc2Imem_addr_o;
	//logic	[1:0]							proc2Imem_command_o;

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
	logic						if2Icache_req_o;
	logic [63:0]				if_PC_o;			
	logic [63:0]				if_target_PC_o;	
	logic						if_pred_bit_o;
	logic [31:0]				if_IR_o;
	logic       				if_valid_inst_o;	
	logic [63:0]				if2bp_pc_o;
	//---------------------------------------------------------------
	// signals for branch predictor
	//---------------------------------------------------------------
	//TODO: add pred here.
	logic	[63:0]	if_pc_i;		
    logic			ex_is_br_i;		
    logic			ex_is_cond_i;	
    logic			ex_is_taken_i;	
    logic	[63:0]	ex_pc_i;	
    logic	[63:0]	ex_br_target_i;
	logic	[63:0]	btb_target_o;
    logic			pred_o;

	`ifdef PERCEPTRON
		logic	if_PC_vld_i;
	`endif	


	//---------------------------------------------------------------
	// signals for dispatch
	//---------------------------------------------------------------
	// dispatch
	logic						dispatch_rs_stall;
	logic						dispatch_rob_stall;
	logic						dispatch_fl_stall;
	logic						dispatch_br_stk_stall;
	logic						dispatch_lq_stall;
	logic						dispatch_sq_stall;

	logic						dispatch_norm_en;
	logic						dispatch_br_en;
	logic						dispatch_ld_en;
	logic						dispatch_st_en;
	logic						dispatch_en;
	logic						dispatch_fl_en;

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
	logic	[`ROB_IDX_W:0]		rob_idx_i;
	logic	[`PRF_IDX_W-1:0]	cdb_tag_i;
	logic						cdb_vld_i;
	logic	[`SQ_IDX_W-1:0]		lsq_sq_tail_i;
	logic						lsq_ld_iss_en_i;
	logic						lsq_lq_com_rdy_stall_i;
	logic						stall_dp_i;
	logic	[`BR_MASK_W-1:0]	bmg_br_mask_i;
	logic						rob2rs_pred_correct_i;
	logic						rob2rs_br_recovery_i;
	logic	[`BR_MASK_W-1:0]	br_stack_tag_fix_i;

	logic	[`SQ_IDX_W-1:0]		rs_sq_position_o;
	logic						rs_iss_vld_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o;
	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel_o;
	logic	[31:0]				rs_iss_IR_o;
	logic	[`ROB_IDX_W:0]		rs_iss_rob_idx_o;
	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask_o;
	logic	[`SQ_IDX_W-1:0]		rs_iss_sq_position_o;
	logic						rs_full_o;


	//---------------------------------------------------------------
	// signals for ROB
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
	logic						id2rob_halt_i;
	logic						id2rob_illegal_i;
	logic	[31:0]				id2rob_IR_i;

	logic	[`ROB_IDX_W:0]		fu2rob_idx_i;//tag sent from
	logic						fu2rob_done_signal_i;//done 
	logic						fu2rob_br_taken_i;//branck t
	//logic	[63:0]				fu2rob_br_target_i;

	logic						br_recovery_taken_i;
	logic	[63:0]				br_recovery_target_i;
	logic	[`ROB_IDX_W:0]		br_recovery_idx_i;
	logic						br_recovery_done_i;
	
	logic	[`ROB_IDX_W:0]		rs2rob_rd_idx_i;
	logic	[63:0]				rob2fu_rd_NPC_o;

	logic	[`HT_W:0]			rob2rs_tail_idx_o;//tail # s
	logic	[`PRF_IDX_W-1:0]	rob2fl_tag_o;//tag from ROB 
	logic	[`PRF_IDX_W-1:0]	rob2arch_map_tag_o;//tag fro
	logic	[`PRF_IDX_W-2:0]	rob2arch_map_logic_dest_o;//
	logic						rob_stall_dp_o;//signal show
	logic						rob_head_retire_rdy_o;//the 

	logic						br_recovery_rdy_o;//ready to
	logic	[`PRF_IDX_W-2:0]	rob2fl_recover_head_o;
	logic	[`BR_MASK_W-1:0]	br_recovery_mask_o;
	//logic						br_wrong_o;
	logic						br_right_o;
	
	logic						rob_halt_o;
	logic						rob_illegal_o;


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
	logic	[31:0][6:0]			bak_data_o;			//[Br_stack]	
	
	// Freelist
	//logic						dispatch_en_i;			//[Decoder]		
	logic						retire_en_i;			//[ROB]			
	logic	[5:0]				retire_preg_i;			//[ROB]			
	//logic	[`BR_STATE_W-1:0]	branch_state_i;			//[ROB]			
	logic	[`FL_PTR_W:0]		rc_head_i;				//[Br_stack]
	
	logic						free_preg_vld_o;		//[ROB, Map Table, RS]	
	logic	[5:0]				free_preg_o;			//[ROB, Map Table, Rs]	
	logic	[`FL_PTR_W:0]		free_preg_cur_head_o;	//[ROB]	


	//---------------------------------------------------------------
	// signals for fu
	//---------------------------------------------------------------
	logic	[63:0]				rob2fu_NPC_i;
	logic	[`ROB_IDX_W:0]		rs2fu_rob_idx_i;
	logic	[63:0]				prf2fu_ra_value_i;
	logic	[63:0]				prf2fu_rb_value_i;
	logic	[`PRF_IDX_W-1:0]	rs2fu_dest_tag_i;
	logic	[31:0]				rs2fu_IR_i;
	logic	[`FU_SEL_W-1:0]		rs2fu_sel_i;
	logic						rs2fu_iss_vld_i;

	logic	[`SQ_IDX_W-1:0]		rs2lsq_sq_idx_i;
	logic						rob2lsq_st_retire_en_i;
	logic						st_dp_en_i;
	logic	[`SQ_IDX_W-1:0]		rs_ld_position_i;
	logic	[`SQ_IDX_W-1:0]		rs_iss_ld_position_i;

	logic	[`BR_MASK_W-1:0]	rs2fu_br_mask_i;
	logic						rob2fu_pred_correct_i;
	logic						rob2fu_br_recovery_i;
	logic	[`BR_MASK_W-1:0]	rob_br_tag_fix_i;

	logic	[`SQ_IDX_W:0]		bs_sq_tail_recovery_i;

	logic						Dcache_hit_i;
	logic	[63:0]				Dcache_data_i;
	logic	[63:0]				Dcache_mshr_addr_i;
	logic						Dcache_mshr_ld_ack_i;
	logic						Dcache_mshr_st_ack_i;
	logic						Dcache_mshr_vld_i;
	logic						Dcache_mshr_stall_i;

	logic						fu2preg_wr_en_o;
	logic 	[`PRF_IDX_W-1:0]	fu2preg_wr_idx_o;
	logic 	[63:0]				fu2preg_wr_value_o;
	logic						fu2rob_done_o;
	logic	[`ROB_IDX_W:0]		fu2rob_idx_o;
	logic						fu2rob_br_taken_o;

	//logic	[63:0]				fu2rob_br_target_o;
	logic						fu2rob_br_recovery_taken_o;
	logic	[63:0]				fu2rob_br_recovery_target_o;
	logic	[`ROB_IDX_W:0]		fu2rob_br_recovery_idx_o;
	logic						fu2rob_br_recovery_done_o;


	logic 	[`PRF_IDX_W-1:0]	fu_cdb_broad_o;
	logic						fu_cdb_vld_o;

	logic	[`SQ_IDX_W:0]		lsq_sq_tail_o;
	logic						lsq_ld_iss_en_o;
	logic	[63:0]				lsq2Dcache_ld_addr_o;
	logic						lsq2Dcache_ld_en_o;
	logic	[63:0]				lsq2Dcache_st_addr_o,
	logic	[63:0]				lsq2Dcache_st_data_o,
	logic						lsq2Dcache_st_en_o,

	logic						lsq_lq_com_rdy_stall_o;
	logic						lsq_sq_full_o;

	logic						bp_br_done_o;
	logic	[63:0]				bp_br_pc_o;
	logic						bp_br_cond_o;
	//---------------------------------------------------------------
	// signals for preg file
	//---------------------------------------------------------------
	logic						wr_en_i;
	logic	[`PRF_IDX_W-1:0]	rda_idx_i,rdb_idx_i, wr_idx_i;
	logic	[63:0]				wr_data_i;

	logic	[63:0]				rda_data_o, rdb_data_o;

	//---------------------------------------------------------------
	// signals for early branch recovery (br stack)
	//---------------------------------------------------------------
	logic						is_br_i;			//[Dispatch]
	logic						is_cond_i;
	logic						is_taken_i;
	logic	[`BR_STATE_W-1:0]	br_state_i;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	br_dep_mask_i;		//[ROB]			
	logic	[31:0][6:0]			bak_mp_next_data_i;		//[Map Table]	
	logic	[`FL_PTR_W:0]		bak_fl_head_i;			//[Free List]

	logic	[`BR_MASK_W-1:0]	br_mask_o;			//[ROB]			
	logic	[`BR_MASK_W-1:0]	br_bit_o;			//[RS]			
	logic	[31:0][6:0]			rc_mt_all_data_o;		//[Map Table]
	logic	[`FL_PTR_W:0]		rc_fl_head_o;			//[Free List]
	logic						br_stack_full_o;

/*	//---------------------------------------------------------------
	// signals for LSQ
	//---------------------------------------------------------------
	// store signals
	logic		[`ADDR_W-1:0]			addr_i;
	logic		[63:0]					st_data_i;
	logic								st_vld_i;
	logic		[`SQ_IDX_W-1:0]			sq_idx_i;
	logic								rob_st_retire_en_i;
	logic								dp_en_i;

	// load signals
	logic		[`ROB_IDX_W:0]			rob_idx_i;
	logic		[`PRF_IDX_W-1:0]		dest_tag_i;
	logic								ld_vld_i;
	logic		[`SQ_IDX_W-1:0]			rs_ld_position_i;
	logic		[`SQ_IDX_W-1:0]			ex_ld_position_i;

	// Dcache signals
	logic								Dcache_hit_i;
	logic		[63:0]					Dcache_data_i;
	logic		[`ADDR_W-1:0]			Dcache_mshr_addr_i;
	logic								Dcache_mshr_ld_ack_i;
	logic								Dcache_mshr_st_ack_i;
	logic								Dcache_mshr_vld_i;
	logic								Dcache_mshr_stall_i;

	// branch recovery signals
	logic		[`BR_MASK_W-1:0]		bs_br_mask_i;
	logic		[`SQ_IDX_W:0]			bs_sq_tail_recovery_i;
	logic								rob_br_recovery_i;
	logic								rob_br_pred_correct_i;
	logic		[`BR_MASK_W-1:0]		rob_br_tag_fix_i;

	// output signals
	logic		[`SQ_IDX_W:0]			lsq_sq_tail_o;
	logic								lsq_ld_iss_en_o;
	logic		[`ADDR_W-1:0]			lsq2Dcache_ld_addr_o;
	logic								lsq2Dcache_ld_en_o;
	logic		[63:0]					lsq2Dcache_st_addr_o;
	logic		[63:0]					lsq2Dcache_st_data_o;
	logic								lsq2Dcache_st_en_o;
	logic		[63:0]					lsq_ld_data_o;
	logic		[`ROB_IDX_W:0]			lsq_ld_rob_idx_o;
	logic		[`PRF_IDX_W-1:0]		lsq_ld_dest_tag_o;
	logic								lsq_lq_com_rdy_o;
	logic								lsq_sq_full_o;
*/	

	//---------------------------------------------------------------
	// signals for Dcache
	//---------------------------------------------------------------
	// core side signals
	logic									cpu_id_i;

	logic									lq2Dcache_en_i;
	logic	[63:0]							lq2Dcache_addr_i;
	logic									sq2Dcache_en_i;
	logic	[63:0]							sq2Dcache_addr_i;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		sq2Dcache_data_i;
		
	logic									Dcache2lq_ack_o;
	logic									Dcache2lq_data_vld_o;
	logic									Dcache2lq_mshr_data_vld_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2lq_data_o;
	logic	[63:0]							Dcache2lq_addr_o
	logic									Dcache2sq_ack_o;

	logic									Dmshr2lq_data_vld_o;
	logic	[63:0]							Dmshr2lq_addr_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dmshr2lq_data_o;

	// network(or bus) side signals
/*	logic									bus2Dcache_req_ack_i;
	logic									bus2Dcache_req_id_i;
	logic	[`DCACHE_TAG_W-1:0]				bus2Dcache_req_tag_i;
	logic	[`DCACHE_IDX_W-1:0]				bus2Dcache_req_idx_i;
	message_t								bus2Dcache_req_message_i;
	logic									bus2Dcache_rsp_vld_i;
	logic									bus2Dcache_rsp_id_i;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus2Dcache_rsp_data_i;

	logic									Dcache2bus_req_en_o;
	logic	[`DCACHE_TAG_W-1:0]				Dcache2bus_req_tag_o;
	logic	[`DCACHE_IDX_W-1:0]				Dcache2bus_req_idx_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_req_data_o;
	message_t								Dcache2bus_req_message_o;

	logic									Dcache2bus_rsp_ack_o;
	// response to other request
	logic									Dcache2bus_rsp_vld_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_rsp_data_o;	
*/

	//===============================================================
	// core output assignments
	//===============================================================
	//assign proc2mem_command_o	= proc2Imem_command_o; // Dcache not added
	//assign proc2mem_addr_o		= proc2Imem_addr_o;
	//assign proc2mem_data_o		= 64'h0;

	//===============================================================
	// outputs for core_tb.v
	//===============================================================
	assign core_retired_instrs	= {3'b0,(rob_head_retire_rdy_o | rob_halt_o)};
	assign core_error_status	= (rob_illegal_o) ? `HALTED_ON_ILLEGAL : 
								  (rob_halt_o) ? `HALTED_ON_HALT : `NO_ERROR;

	//===============================================================
	// Icache instantiation
	//===============================================================
	//assign Imem2proc_response_i = mem2proc_response_i;
	//assign Imem2Icache_data_i	= mem2proc_data_i;
	//assign Imem2proc_tag_i		= mem2proc_tag_i;

	assign if2Icache_addr_i		= proc2Imem_addr;
	assign if2Icache_req_i		= if2Icache_req_o;
	assign if2Icache_flush_i	= br_recovery_rdy_o; // from rob
	
	Icache Icache (
		.clk					(clk),
		.rst					(rst),
		
		.Imem2proc_response_i	(Imem2proc_response_i),
		.Imem2Icache_data_i		(Imem2Icache_data_i),
		.Imem2proc_tag_i		(Imem2proc_tag_i),

		.if2Icache_addr_i		(if2Icache_addr_i),
		.if2Icache_req_i		(if2Icache_req_i),
		.if2Icache_flush_i		(if2Icache_flush_i),

		.proc2Imem_addr_o		(proc2Imem_addr_o),
		.proc2Imem_command_o	(proc2Imem_command_o),

		.Icache2if_vld_o		(Icache2if_vld_o),
		.Icache2if_data_o		(Icache2if_data_o)
	);

	//===============================================================
	// if_stage instantiation
	//===============================================================
	assign bp2if_predict_i			= pred_o;
	assign br_predict_target_PC_i	= btb_target_o;
	assign br_flush_target_PC_i		= fu2rob_br_recovery_target_o;
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

			.if2Icache_req_o		(if2Icache_req_o),
			.proc2Imem_addr			(proc2Imem_addr),
			.if_PC_o				(if_PC_o),	
			.if_target_PC_o			(if_target_PC_o),	
			.if_IR_o				(if_IR_o),
			.if_pred_bit_o			(if_pred_bit_o),
			.if_valid_inst_o		(if_valid_inst_o),
			.if2bp_pc_o				(if2bp_pc_o)
			//output logic		  if2id_empty_o
	);

	


	//===============================================================
	// branch predictor instantiation
	//===============================================================
	assign	if_pc_i			= 	if2bp_pc_o;	
	assign	ex_is_br_i		=	fu2rob_br_recovery_done_o;
	assign	ex_is_cond_i	=	bp_br_cond_o;	
	assign	ex_is_taken_i	=	fu2rob_br_recovery_taken_o;	
	assign	ex_pc_i			=   rob2fu_rd_NPC_o-4;	
	assign	ex_br_target_i	=	fu2rob_br_recovery_target_o;
	
	`ifdef PERCEPTRON
		assign if_PC_vld_i	=	1;
		//I am not sure whether to add this signal or not, set it to 1,the perceptron will always be enabled
		
		perceptron_bp perceptron_bp (
			.clk(clk),
    		.rst(rst),
    		.if2bp_PC_i(if_pc_i),
			.if2bp_PC_vld_i(if_PC_vld_i),	
			.fu2bp_br_cond_i(ex_is_cond_i),
    		.fu2bp_br_taken_i(ex_is_taken_i),		
    		.fu2bp_br_PC_i(ex_pc_i),	
    		.fu2bp_br_target_i(ex_br_target_i),
			.fu2bp_br_done_i(ex_is_br_i),

			.btb_target_o(btb_target_o),
    		.bp_pred_o(pred_o)	
		);
		
	`else
		branch_pred bp (
			.clk,
			.rst,
			.if_pc_i,		
			.ex_is_br_i,		
			.ex_is_cond_i,	
			.ex_is_taken_i,	
			.ex_pc_i,		
			.ex_br_target_i,
			.btb_target_o,
			.pred_o
		);

	`endif      

	//===============================================================
	// dispatch instantiation
	//===============================================================
	assign dispatch_rs_stall	= rs_full_o; //&& ~rs_iss_vld_o;
	assign dispatch_rob_stall	= rob_stall_dp_o;
	assign dispatch_fl_stall	= ~free_preg_vld_o && ~rob_head_retire_rdy_o;
	assign dispatch_br_stk_stall= br_stack_full_o && ~br_right_o;
	assign dispatch_lq_stall	= 1'b0; // LQ !!!
	assign dispatch_sq_stall	= lsq_sq_full_o;
	
	assign dispatch_norm_en		= ~(dispatch_rs_stall | dispatch_rob_stall | 
									dispatch_fl_stall | ~if_valid_inst_o) && ~br_recovery_rdy_o;
	assign dispatch_br_en		= ~(dispatch_rs_stall | dispatch_rob_stall | dispatch_br_stk_stall) &&
								   (id_cond_branch_o | id_uncond_branch_o) && ~br_recovery_rdy_o;
	assign dispatch_ld_en		= dispatch_norm_en && ~dispatch_lq_stall && id_rd_mem_o &&
								 ~br_recovery_rdy_o;
	assign dispatch_st_en		= ~(dispatch_rs_stall | dispatch_rob_stall | dispatch_sq_stall) && 
									id_wr_mem_o && ~br_recovery_rdy_o;

	assign dispatch_en			= //(id_illegal_o) ? 1'b0 :
								  (id_cond_branch_o | id_uncond_branch_o) ? dispatch_br_en :
								  (id_rd_mem_o) ? dispatch_ld_en : 
								  (id_wr_mem_o) ? dispatch_st_en : dispatch_norm_en;

	assign dispatch_fl_en		= dispatch_en && (id_dest_idx_o != `ZERO_REG);

	assign if_id_IR_i			= if_IR_o;
	assign if_id_valid_inst_i	= if_valid_inst_o;
	
	id_stage id_stage (
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
	assign cdb_vld_i			= fu_cdb_vld_o;
	assign lsq_sq_tail_i		= lsq_sq_tail_o[`SQ_IDX_W-1:0];
	assign lsq_ld_iss_en_i		= lsq_ld_iss_en_o;
	assign lsq_lq_com_rdy_stall_i = lsq_lq_com_rdy_stall_o;
	assign stall_dp_i			= ~dispatch_en;
	assign bmg_br_mask_i		= br_mask_o;
	assign rob2rs_pred_correct_i= br_right_o;
	assign rob2rs_br_recovery_i	= br_recovery_rdy_o;
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
			.lsq_sq_tail_i			(lsq_sq_tail_i),
			.lsq_ld_iss_en_i		(lsq_ld_iss_en_i),
			.lsq_lq_com_rdy_stall_i	(lsq_lq_com_rdy_stall_i),
			.stall_dp_i				(stall_dp_i),
			.bmg_br_mask_i			(bmg_br_mask_i), //	branch recovery latter
			.rob_br_pred_correct_i	(rob2rs_pred_correct_i),
			.rob_br_recovery_i		(rob2rs_br_recovery_i),
			.rob_br_tag_fix_i		(rob_br_tag_fix_i),

			.rs_sq_position_o		(rs_sq_position_o),
			.rs_iss_vld_o			(rs_iss_vld_o),
			.rs_iss_opa_tag_o		(rs_iss_opa_tag_o),
			.rs_iss_opb_tag_o		(rs_iss_opb_tag_o),
			.rs_iss_dest_tag_o		(rs_iss_dest_tag_o),
			.rs_iss_fu_sel_o		(rs_iss_fu_sel_o),
			.rs_iss_IR_o			(rs_iss_IR_o),
			.rs_iss_rob_idx_o		(rs_iss_rob_idx_o),
			.rs_iss_br_mask_o		(rs_iss_br_mask_o),
			.rs_iss_sq_position_o	(rs_iss_sq_position_o),
			.rs_full_o				(rs_full_o)
	);

	//===============================================================
	//rob instantiation
	//===============================================================
	assign fl2rob_tag_i				= free_preg_o; // Tnew
	assign fl2rob_cur_head_i		= free_preg_cur_head_o[`FL_PTR_W-1:0];
	assign map2rob_tag_i			= dest_old_preg_o; // Told
	assign decode2rob_logic_dest_i	= id_dest_idx_o;
	assign decode2rob_PC_i			= if_PC_o;
	assign decode2rob_br_flag_i		= id_cond_branch_o | id_uncond_branch_o;
	assign decode2rob_br_pretaken_i	= if_pred_bit_o; // if insn buffer
	assign decode2rob_br_target_i	= if_target_PC_o; //non-taken for now
	assign decode2rob_rd_mem_i		= id_rd_mem_o;
	assign decode2rob_wr_mem_i		= id_wr_mem_o;
	assign rob_dispatch_en_i		= dispatch_en;
	assign decode2rob_br_mask_i		= br_mask_o; // !! from br stack
	assign id2rob_halt_i			= id_halt_o;
	assign id2rob_illegal_i			= id_illegal_o;
	assign id2rob_IR_i				= id_IR_o;
	assign fu2rob_idx_i				= fu2rob_idx_o;
	assign fu2rob_done_signal_i		= fu2rob_done_o;
	assign fu2rob_br_taken_i		= fu2rob_br_taken_o;
	//assign fu2rob_br_target_i		= fu2rob_br_recovery_taken_o;
	
	assign br_recovery_taken_i		= fu2rob_br_recovery_taken_o;
	assign br_recovery_target_i		= fu2rob_br_recovery_target_o;
	assign br_recovery_idx_i		= fu2rob_br_recovery_idx_o;
	assign br_recovery_done_i		= fu2rob_br_recovery_done_o;
	
	assign rs2rob_rd_idx_i			= rs_iss_rob_idx_o;

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
		.id2rob_halt_i				(id2rob_halt_i),
		.id2rob_illegal_i			(id2rob_illegal_i),
		.id2rob_IR_i				(id2rob_IR_i),

		.fu2rob_idx_i				(fu2rob_idx_i),
		.fu2rob_done_signal_i		(fu2rob_done_signal_i),
		.fu2rob_br_taken_i			(fu2rob_br_taken_i),
		//.fu2rob_br_target_i			(fu2rob_br_target_i),
		
		.br_recovery_taken_i		(br_recovery_taken_i),
		.br_recovery_target_i		(br_recovery_target_i),
		.br_recovery_idx_i			(br_recovery_idx_i),
		.br_recovery_done_i			(br_recovery_done_i),

		.rs2rob_rd_idx_i			(rs2rob_rd_idx_i),
		.rob2fu_rd_NPC_o			(rob2fu_rd_NPC_o),

		.rob2rs_tail_idx_o			(rob2rs_tail_idx_o),
		.rob2fl_tag_o				(rob2fl_tag_o),
		.rob2arch_map_tag_o			(rob2arch_map_tag_o),
		.rob2arch_map_logic_dest_o	(rob2arch_map_logic_dest_o),
		.rob_stall_dp_o				(rob_stall_dp_o),
		.rob_head_retire_rdy_o		(rob_head_retire_rdy_o),

		.br_recovery_rdy_o			(br_recovery_rdy_o),
		.rob2fl_recover_head_o		(rob2fl_recover_head_o),
		.br_recovery_mask_o			(br_recovery_mask_o),
		.br_right_o					(br_right_o),

		.rob_halt_o					(rob_halt_o),
		.rob_illegal_o				(rob_illegal_o)
	);	

	//===============================================================
	// map table and free list instantiation
	//===============================================================
	assign opa_areg_idx_i			= id_ra_idx_o;
	assign opb_areg_idx_i			= id_rb_idx_o;
	assign dest_areg_idx_i			= id_dest_idx_o;
	assign new_free_preg_i			= free_preg_o; // !! Tnew from freelist
	assign cdb_set_rdy_bit_preg_i	= fu_cdb_broad_o;
	assign cdb_set_rdy_bit_en_i		= fu_cdb_vld_o;
	assign rc_mt_all_data_i			= rc_mt_all_data_o;

	map_table	map_table (
		.clk					(clk),
		.rst					(rst),	//|From where|	
								
		.opa_areg_idx_i			(opa_areg_idx_i),	//[Decoder]		
		.opb_areg_idx_i			(opb_areg_idx_i),	//[Decoder]		
		.dest_areg_idx_i		(dest_areg_idx_i),	//[Decoder]		
		.new_free_preg_i		(new_free_preg_i),	//[Free-List]	
		.dispatch_en_i			(dispatch_en), //[Decoder]		
		.cdb_set_rdy_bit_preg_i	(cdb_set_rdy_bit_preg_i), //[CDB]			 
		.cdb_set_rdy_bit_en_i	(cdb_set_rdy_bit_en_i),	//[CDB]			
		.branch_state_i			(br_state_i), //[ROB]			
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

	free_list free_list (
		.clk					(clk),
		.rst					(rst), //|From where|

		.dispatch_en_i			(dispatch_fl_en),	//[Decoder]		
		.retire_en_i			(retire_en_i),	//[ROB]			
		.retire_preg_i			(retire_preg_i),	//[ROB]			
		.branch_state_i			(br_state_i), //[ROB]			
		.rc_head_i				(rc_head_i), //[Br_stack]

		.free_preg_vld_o		(free_preg_vld_o), //[ROB, Map Table, RS]
		.free_preg_o			(free_preg_o),	//[ROB, Map Table, Rs]
		.free_preg_cur_head_o	(free_preg_cur_head_o) //[ROB]
	);

	//===============================================================
	// fu instantiation
	//===============================================================
	assign rob2fu_NPC_i			= rob2fu_rd_NPC_o; // !!!
	assign rs2fu_rob_idx_i		= rs_iss_rob_idx_o;
	assign prf2fu_ra_value_i	= rda_data_o; // !! from preg_file
	assign prf2fu_rb_value_i	= rdb_data_o; // !!
	assign rs2fu_dest_tag_i		= rs_iss_dest_tag_o; //  why we need here?
	assign rs2fu_IR_i			= rs_iss_IR_o; //  why we need here?
	assign rs2fu_sel_i			= rs_iss_fu_sel_o;
	assign rs2fu_iss_vld_i		= rs_iss_vld_o;

	assign rs2lsq_sq_idx_i			= rs_iss_sq_position_o;
	assign rob2lsq_st_retire_en_i	= 0; // !!! need this from rob
	assign st_dp_en_i				= dispatch_en; // !!
	assign rs_ld_position_i			= rs_sq_position_o;
	assign rs_iss_ld_position_i		= rs_iss_sq_position_o;

	assign rs2fu_br_mask_i			= rs_iss_br_mask_o;
	assign rob2fu_pred_correct_i	= br_right_o;
	assign rob2fu_br_recovery_i		= br_recovery_rdy_o;
	assign br_stack_tag_fix_i		= br_bit_o; // from br_stack

	assign bs_sq_tail_recovery_i	= ; // !!! from br_stack

	assign Dcache_hit_i				= Dcache2lq_data_vld_o;
	assign Dcache_data_i			= Dcache2lq_data_o;	
	assign Dcache_mshr_addr_i		= Dcache2lq_addr_o;
	assign Dcache_mshr_ld_ack_i		= Dcache2lq_ack_o;
	assign Dcache_mshr_st_ack_i		= Dcache2sq_ack_o;
	assign Dcache_mshr_vld_i		= Dcache2lq_mshr_data_vld_o;
	assign Dcache_mshr_stall_i		= 1'b0; // never stall

	fu_main fu_main (
		.clk					(clk),
		.rst					(rst),
		
		.rob2fu_NPC_i			(rob2fu_NPC_i),
		.rs2fu_rob_idx_i		(rs2fu_rob_idx_i),
		.prf2fu_ra_value_i		(prf2fu_ra_value_i),
		.prf2fu_rb_value_i		(prf2fu_rb_value_i),
		.rs2fu_dest_tag_i		(rs2fu_dest_tag_i),
		.rs2fu_IR_i				(rs2fu_IR_i),
		.rs2fu_sel_i			(rs2fu_sel_i),
		.rs2fu_iss_vld_i		(rs2fu_iss_vld_i),

		.rs2lsq_sq_idx_i		(rs2lsq_sq_idx_i),
		.rob2lsq_st_retire_en_i	(rob2lsq_st_retire_en_i),
		.st_dp_en_i				(st_dp_en_i),
		.rs_ld_position_i		(rs_ld_position_i),
		.rs_iss_ld_position_i	(rs_iss_ld_position_i),

		.rs2fu_br_mask_i		(rs2fu_br_mask_i),
		.rob_br_pred_correct_i	(rob2fu_pred_correct_i),
		.rob_br_recovery_i		(rob2fu_br_recovery_i),
		.rob_br_tag_fix_i		(br_stack_tag_fix_i), // from br_stack

		.bs_sq_tail_recovery_i	(bs_sq_tail_recovery_i),
 
		.Dcache_hit_i			(Dcache_hit_i),
		.Dcache_data_i			(Dcache_data_i),
		.Dcache_mshr_addr_i		(Dcache_mshr_addr_i),
		.Dcache_mshr_ld_ack_i	(Dcache_mshr_ld_ack_i),
		.Dcache_mshr_st_ack_i	(Dcache_mshr_st_ack_i),
		.Dcache_mshr_vld_i		(Dcache_mshr_vld_i),
		.Dcache_mshr_stall_i	(Dcache_mshr_stall_i),

		.fu2preg_wr_en_o		(fu2preg_wr_en_o),
		.fu2preg_wr_idx_o		(fu2preg_wr_idx_o),
		.fu2preg_wr_value_o		(fu2preg_wr_value_o),
		.fu2rob_done_o			(fu2rob_done_o),
		.fu2rob_idx_o			(fu2rob_idx_o),
		.fu2rob_br_taken_o		(fu2rob_br_taken_o),

		//.fu2rob_br_target_o		(fu2rob_br_target_o),
		.fu2rob_br_recovery_taken_o	(fu2rob_br_recovery_taken_o),
		.fu2rob_br_recovery_target_o(fu2rob_br_recovery_target_o),
		.fu2rob_br_recovery_idx_o	(fu2rob_br_recovery_idx_o),
		.fu2rob_br_recovery_done_o	(fu2rob_br_recovery_done_o),

		.fu_cdb_broad_o			(fu_cdb_broad_o),
		.fu_cdb_vld_o			(fu_cdb_vld_o),

		.lsq_sq_tail_o			(lsq_sq_tail_o),
		.lsq_ld_iss_en_o		(lsq_ld_iss_en_o),
		.lsq2Dcache_ld_addr_o	(lsq2Dcache_ld_addr_o),
		.lsq2Dcache_ld_en_o		(lsq2Dcache_ld_en_o),
		.lsq2Dcache_st_addr_o	(lsq2Dcache_st_addr_o),
		.lsq2Dcache_st_data_o	(lsq2Dcache_st_data_o),
		.lsq2Dcache_st_en_o		(lsq2Dcache_st_en_o),

		.lsq_lq_com_rdy_stall_o	(lsq_lq_com_rdy_stall_o),
		.lsq_sq_full_o			(lsq_sq_full_o),

		.bp_br_done_o			(bp_br_done_o),
		.bp_br_pc_o				(bp_br_pc_o),
		.bp_br_cond_o			(bp_br_cond_o)
	);

	//===============================================================
	// physical regfile instantiation
	//===============================================================
	assign wr_en_i		= fu2preg_wr_en_o; //
	assign rda_idx_i	= rs_iss_opa_tag_o; // !! from rs issue
	assign rdb_idx_i	= rs_iss_opb_tag_o; // !! from rs issue
	assign wr_idx_i		= fu2preg_wr_idx_o; // !! Tnew from rob, wr preg
	assign wr_data_i	= fu2preg_wr_value_o; // need value from fu

	preg_file preg_file (
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
	assign is_br_i				= dispatch_br_en;
	assign is_cond_i			= id_cond_branch_o;
	assign is_taken_i			= if_pred_bit_o; // from if pb prediction
	assign br_state_i			= br_recovery_rdy_o ? `BR_PR_WRONG : 
								  br_right_o ? `BR_PR_CORRECT : `BR_NONE; // 
	assign br_dep_mask_i		= br_recovery_mask_o; // from rob
	assign bak_mp_next_data_i	= bak_data_o;
	assign bak_fl_head_i		= free_preg_cur_head_o;

	branch_stack branch_stack (
		.clk				(clk), 
		.rst				(rst),

		.is_br_i			(is_br_i),
		.is_cond_i			(is_cond_i),
		.is_taken_i			(is_taken_i),
		.br_state_i			(br_state_i),
		.br_dep_mask_i		(br_dep_mask_i),
		.bak_mp_next_data_i	(bak_mp_next_data_i),	
		.bak_fl_head_i		(bak_fl_head_i),

		// <11/14>
		.cdb_vld_i			(fu_cdb_vld_o),
		.cdb_tag_i			(fu_cdb_broad_o),

		.br_mask_o			(br_mask_o),
		.br_bit_o			(br_bit_o),
		.rc_mt_all_data_o	(rc_mt_all_data_o),
		.rc_fl_head_o		(rc_fl_head_o),
		.full_o				(br_stack_full_o)
	);


	//===============================================================
	// Dcache instantiation
	//===============================================================
	assign lq2Dcache_en_i			= lsq2Dcache_ld_en_o;
	assign lq2Dcache_addr_i			= lsq2Dcache_ld_addr_o;
	assign sq2Dcache_en_i			= lsq2Dcache_st_en_o;
	assign sq2Dcache_addr_i			= lsq2Dcache_st_addr_o;
	assign sq2Dcache_data_i			= lsq2Dcache_st_data_o;
	
	Dcache Dcache (
		.clk						(clk),
		.rst						(rst),

		// core side signals
		.cpu_id_i					(cpu_id_i),

		.lq2Dcache_en_i				(lq2Dcache_en_i),
		.lq2Dcache_addr_i			(lq2Dcache_addr_i),
		.sq2Dcache_en_i				(sq2Dcache_en_i),
		.sq2Dcache_addr_i			(sq2Dcache_addr_i),
		.sq2Dcache_data_i			(sq2Dcache_data_i),
		
		.Dcache2lq_ack_o			(Dcache2lq_ack_o),
		.Dcache2lq_data_vld_o		(Dcache2lq_data_vld_o),
		.Dcache2lq_mshr_data_vld_o	(Dcache2lq_mshr_data_vld_o),
		.Dcache2lq_data_o			(Dcache2lq_data_o),
		.Dcache2lq_addr_o			(Dcache2lq_addr_o),
		.Dcache2sq_ack_o			(Dcache2sq_ack_o),

		.Dmshr2lq_data_vld_o		(Dmshr2lq_data_vld_o),
		.Dmshr2lq_addr_o			(Dmshr2lq_addr_o),
		.Dmshr2lq_data_o			(Dmshr2lq_data_o),

		// network(or bus) side signals
		.bus2Dcache_req_ack_i		(bus2Dcache_req_ack_i),
		.bus2Dcache_req_id_i		(bus2Dcache_req_id_i),
		.bus2Dcache_req_tag_i		(bus2Dcache_req_tag_i),
		.bus2Dcache_req_idx_i		(bus2Dcache_req_idx_i),
		.bus2Dcache_req_message_i	(bus2Dcache_req_message_i),
		.bus2Dcache_rsp_vld_i		(bus2Dcache_rsp_vld_i),
		.bus2Dcache_rsp_id_i		(bus2Dcache_rsp_id_i),
		.bus2Dcache_rsp_data_i		(bus2Dcache_rsp_data_i),

		.Dcache2bus_req_en_o		(Dcache2bus_req_en_o),
		.Dcache2bus_req_tag_o		(Dcache2bus_req_tag_o),
		.Dcache2bus_req_idx_o		(Dcache2bus_req_idx_o),
		.Dcache2bus_req_data_o		(Dcache2bus_req_data_o),
		.Dcache2bus_req_message_o	(Dcache2bus_req_message_o),

		.Dcache2bus_rsp_ack_o		(Dcache2bus_rsp_ack_o),
		// response to other request
		.Dcache2bus_rsp_vld_o		(Dcache2bus_rsp_vld_o),
		.Dcache2bus_rsp_data_o		(Dcache2bus_rsp_data_o)
	);


endmodule: core

