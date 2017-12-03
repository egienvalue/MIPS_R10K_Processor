
module fu_main(
		input 								clk,
		input 								rst,
		                                	
		input		[63:0]					rob2fu_NPC_i,
		input 		[`ROB_IDX_W:0]			rs2fu_rob_idx_i,
		input 		[63:0]					prf2fu_ra_value_i,
		input		[63:0]					prf2fu_rb_value_i,
		input		[`PRF_IDX_W-1:0]		rs2fu_dest_tag_i,
		input		[31:0]					rs2fu_IR_i,
		input		[`FU_SEL_W-1:0]			rs2fu_sel_i,
		input								rs2fu_iss_vld_i,

		input		[`SQ_IDX_W-1:0]			rs2lsq_sq_idx_i,
		input								rob2lsq_st_retire_en_i,
		input								st_dp_en_i,
		input		[`SQ_IDX_W-1:0]			rs_ld_position_i,
		input		[`SQ_IDX_W-1:0]			rs_iss_ld_position_i,

		input		[`BR_MASK_W-1:0]		rs2fu_br_mask_i,
		input								rob_br_pred_correct_i,
		input								rob_br_recovery_i,
		input		[`BR_MASK_W-1:0]		rob_br_tag_fix_i,

		input		[`SQ_IDX_W:0]          	bs_sq_tail_recovery_i,
	
		input								Dcache_hit_i,
		input		[63:0]					Dcache_data_i,
		input		[63:0]					Dcache_mshr_addr_i,
		input								Dcache_mshr_ld_ack_i,
		input								Dcache_mshr_st_ack_i,
		input								Dcache_mshr_vld_i,
		input								Dcache_mshr_stall_i,

		// ------------------ Output -----------------------
		output	logic						fu2preg_wr_en_o,
		output 	logic	[`PRF_IDX_W-1:0]	fu2preg_wr_idx_o,
		output 	logic	[63:0]				fu2preg_wr_value_o,
		output	logic						fu2rob_done_o,
		output	logic	[`ROB_IDX_W:0]		fu2rob_idx_o,
		output	logic						fu2rob_br_taken_o,

		output	logic						fu2rob_br_recovery_taken_o,
		output	logic	[63:0]				fu2rob_br_recovery_target_o,
		output	logic	[`ROB_IDX_W:0]		fu2rob_br_recovery_idx_o,
		output	logic						fu2rob_br_recovery_done_o,
        //outputlogic	[63:0]              fu2br_pre_br_pc_o,//branch address to branch predictor 
		output 	logic	[`PRF_IDX_W-1:0]	fu_cdb_broad_o,
        output  logic	                    fu_cdb_vld_o,

		output	logic	[`SQ_IDX_W:0]		lsq_sq_tail_o,
		output	logic						lsq_ld_iss_en_o,
		output	logic	[63:0]				lsq2Dcache_ld_addr_o,
		output	logic						lsq2Dcache_ld_en_o,
		output	logic	[63:0]				lsq2Dcache_st_addr_o,
		output	logic	[63:0]				lsq2Dcache_st_data_o,
		output	logic						lsq2Dcache_st_en_o,

		output	logic						lsq_lq_com_rdy_stall_o, // stall??
		output	logic						lsq_sq_full_o,

		output	logic						bp_br_done_o,
		output	logic	[63:0]				bp_br_pc_o,
		output	logic						bp_br_cond_o
	);

    logic                           cdb_vld;// cdb_vld_r_nxt;
	logic		[`PRF_IDX_W-1:0]	cdb_tag;// cdb_tag_r_nxt;
	logic		[`BR_MASK_W-1:0]	cdb_br_mask_r, cdb_br_mask_r_nxt;
	logic		[63:0]				fu2preg_wr_value;
	logic		[`EX_UNIT_W-1:0]	ex_unit_en;
	
	logic		[63:0]				alu_result;
	logic							alu_done_pre;
	logic							alu_done;
	logic		[`PRF_IDX_W-1:0]	alu_dest_tag;
	logic		[`ROB_IDX_W:0]		alu_rob_idx;
	logic		[`BR_MASK_W-1:0]	alu_br_mask;
	
	logic							br2rob_done;
	logic							br_done;
	//logic		[63:0]				br_target;
	logic							br_taken;
	logic							br_wr_en;
	logic		[`PRF_IDX_W-1:0]	br_dest_tag;
	logic		[`ROB_IDX_W:0] 		br_rob_idx;
    logic       [63:0]              br_pc;
	
	logic		[63:0]				mult_result;
	logic							mult_done_pre;
	logic							mult_done;
	logic		[`ROB_IDX_W:0]		mult_rob_idx;
	logic		[`PRF_IDX_W-1:0]	mult_dest_tag;
	logic		[`BR_MASK_W-1:0]	mult_br_mask;

	logic		[63:0]				ld_result;
	logic							ld_done_pre;
	logic							ld_done;
	logic							st_done_pre;
	logic							st_done;
	logic		[`ROB_IDX_W:0]		ldst_rob_idx;
	logic		[`PRF_IDX_W-1:0]	ld_dest_tag;
	logic							lsq_lq_com_rdy;
	logic							lsq_lq_com_rdy_delay1;
	logic		[`BR_MASK_W-1:0]	ld_br_mask;
	logic							lsq_lq_com_rdy_stall;

	assign bp_br_pc_o	= br_pc;
	assign bp_br_done_o = br_done;
	//wire [63:0] mem_disp = { {48{rs2fu_IR_i[15]}}, rs2fu_IR_i[15:0] };
	//wire [63:0] br_disp  = { {41{rs2fu_IR_i[20]}}, rs2fu_IR_i[20:0], 2'b00 };

	assign fu2rob_br_recovery_done_o = br2rob_done;

	assign fu2rob_done_o 		= (alu_done | br_done | mult_done | st_done | ld_done | lsq_lq_com_rdy_delay1) && 
								  ~rob_br_recovery_i; // lsq	
	assign fu2rob_idx_o			= br_done ? br_rob_idx : 
								  lsq_lq_com_rdy_delay1 ? ldst_rob_idx :
	   							  alu_done ? alu_rob_idx :
								  mult_done ? mult_rob_idx : 
								  (ld_done | st_done) ? ldst_rob_idx : 0;
	assign fu2rob_br_taken_o	= br2rob_done ? br_taken : 0;
	//assign fu2rob_br_target_o	= br2rob_done ? br_target : 0;
    //assign fu2br_pre_br_pc_o    = br_alu_done ? br_pc : 0;
	assign fu_cdb_broad_o		= cdb_tag;
    assign fu_cdb_vld_o         = cdb_vld & ~rob_br_recovery_i;
    assign fu2preg_wr_en_o      = cdb_vld & ~rob_br_recovery_i;
	assign fu2preg_wr_idx_o		= cdb_tag;
	assign fu2preg_wr_value_o	= fu2preg_wr_value;

	assign lsq_lq_com_rdy_stall = lsq_lq_com_rdy & (alu_done_pre | mult_done_pre | ex_unit_en[3] | ex_unit_en[4]);
	assign lsq_lq_com_rdy_stall_o = lsq_lq_com_rdy_stall;

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			lsq_lq_com_rdy_delay1 <= `SD 1'b0;
		end else begin
			lsq_lq_com_rdy_delay1 <= `SD lsq_lq_com_rdy;
		end
	end

	always_comb begin
		if (br_wr_en) begin
			cdb_tag				= br_dest_tag;
			cdb_vld				= 1;
			fu2preg_wr_value	= br_pc;
		end else if (lsq_lq_com_rdy_delay1) begin
			cdb_tag				= ld_dest_tag;
			cdb_vld				= 1;
			fu2preg_wr_value	= ld_result;
        end else if (alu_done) begin
			cdb_tag				= alu_dest_tag;
            cdb_vld       		= 1;
            fu2preg_wr_value	= alu_result;
        end else if (mult_done) begin
			cdb_tag				= mult_dest_tag;
            cdb_vld       		= 1;
            fu2preg_wr_value	= mult_result;
		end else if (ld_done) begin
			cdb_tag				= ld_dest_tag;
			cdb_vld				= 1;
			fu2preg_wr_value	= ld_result;
        end else begin
			cdb_tag				= `ZERO_REG;
            cdb_vld       		= 0;
            fu2preg_wr_value	= 0;
        end
	end
	
	always_comb begin
		if (~rs2fu_iss_vld_i) begin
			ex_unit_en = `EX_UNIT_W'b00000;
		end else begin
			case (rs2fu_sel_i)
				`FU_SEL_NONE:	ex_unit_en = `EX_UNIT_W'b00000;
				`FU_SEL_ALU :	ex_unit_en = `EX_UNIT_W'b00001;
				`FU_SEL_UNCOND_BRANCH,`FU_SEL_COND_BRANCH:
								ex_unit_en = `EX_UNIT_W'b00010;
				`FU_SEL_MULT:	ex_unit_en = `EX_UNIT_W'b00100;
				`FU_SEL_LOAD:	ex_unit_en = `EX_UNIT_W'b01000;
				`FU_SEL_STORE:	ex_unit_en = `EX_UNIT_W'b10000;
				default:		ex_unit_en = `EX_UNIT_W'b00000;
			endcase
		end
	end		

	fu_alu fu_alu (
			.clk					(clk),
			.rst					(rst),
			.start_i				(ex_unit_en[0]),
			.opa_i					(prf2fu_ra_value_i),
			.opb_i					(prf2fu_rb_value_i),
			.inst_i					(rs2fu_IR_i),
			.dest_tag_i				(rs2fu_dest_tag_i),
			.rob_idx_i				(rs2fu_rob_idx_i),
			.br_mask_i				(rs2fu_br_mask_i),
			.rob_br_recovery_i		(rob_br_recovery_i),
			.rob_br_pred_correct_i	(rob_br_pred_correct_i),
			.rob_br_tag_fix_i		(rob_br_tag_fix_i),
			.stall_i				(lsq_lq_com_rdy_stall),
			.result_o				(alu_result),
			.dest_tag_o				(alu_dest_tag),
			.rob_idx_o				(alu_rob_idx),
			.br_mask_o				(alu_br_mask),
			.done_pre_o				(alu_done_pre),
			.done_o					(alu_done)
	);
	
	
	fu_br fu_br (
			.clk					(clk),
			.rst					(rst),
			.start_i				(ex_unit_en[1]),
			.npc_i					(rob2fu_NPC_i),
			.opa_i					(prf2fu_ra_value_i),
			.opb_i					(prf2fu_rb_value_i),
			.inst_i					(rs2fu_IR_i),
			.dest_tag_i				(rs2fu_dest_tag_i),
			.rob_idx_i				(rs2fu_rob_idx_i),
			.rob_br_recovery_i		(rob_br_recovery_i),
			.done_o					(br_done),
			//.br_target_o			(br_target),
			.br_result_o			(br_taken),
			.br_wr_en_o				(br_wr_en),
			.dest_tag_o				(br_dest_tag),
			.rob_idx_o				(br_rob_idx),
            .br_pc_o				(br_pc),

			.br_recovery_taken_o	(fu2rob_br_recovery_taken_o),
			.br_recovery_target_o	(fu2rob_br_recovery_target_o),
			.br2rob_done_o			(br2rob_done),
			.br2rob_recovery_idx_o	(fu2rob_br_recovery_idx_o),
			.bp_br_cond_o			(bp_br_cond_o)
	);
	
	fu_mult fu_mult (
			.clk					(clk),
			.rst					(rst),
			.start_i				(ex_unit_en[2]),
			.opa_i					(prf2fu_ra_value_i),
			.opb_i					(prf2fu_rb_value_i),
			.inst_i					(rs2fu_IR_i),
			.rob_idx_i				(rs2fu_rob_idx_i),
			.dest_tag_i				(rs2fu_dest_tag_i),
			.br_mask_i				(rs2fu_br_mask_i),
			.rob_br_recovery_i		(rob_br_recovery_i),
			.rob_br_pred_correct_i	(rob_br_pred_correct_i),
			.rob_br_tag_fix_i		(rob_br_tag_fix_i),
			.stall_i				(lsq_lq_com_rdy_stall),
			.product_o				(mult_result),
			.rob_idx_o				(mult_rob_idx),
            .dest_tag_o				(mult_dest_tag),
			.br_mask_o				(mult_br_mask),
			.done_pre_o				(mult_done_pre),
			.done_o					(mult_done)
	);

	fu_ldst fu_ldst (
		.clk					(clk),
		.rst					(rst),

		.opa_i					(prf2fu_ra_value_i),
		.opb_i					(prf2fu_rb_value_i),
		.inst_i					(rs2fu_IR_i),
		.dest_tag_i				(rs2fu_dest_tag_i),
		.rob_idx_i				(rs2fu_rob_idx_i),

		.st_vld_i				(ex_unit_en[4]),
		.ld_vld_i				(ex_unit_en[3]),
		.sq_idx_i				(rs2lsq_sq_idx_i),
		.rob_st_retire_en_i		(rob2lsq_st_retire_en_i),
		.dp_en_i				(st_dp_en_i),
		.rs_ld_position_i		(rs_ld_position_i),
		.ex_ld_position_i		(rs_iss_ld_position_i),

		.Dcache_hit_i			(Dcache_hit_i),
		.Dcache_data_i			(Dcache_data_i),
		.Dcache_mshr_addr_i		(Dcache_mshr_addr_i),
		.Dcache_mshr_ld_ack_i	(Dcache_mshr_ld_ack_i),
		.Dcache_mshr_st_ack_i	(Dcache_mshr_st_ack_i),
		.Dcache_mshr_vld_i		(Dcache_mshr_vld_i),
		.Dcache_mshr_stall_i	(Dcache_mshr_stall_i),

		.bs_br_mask_i			(rs2fu_br_mask_i),
		.bs_sq_tail_recovery_i	(bs_sq_tail_recovery_i),
		.rob_br_recovery_i		(rob_br_recovery_i),
		.rob_br_pred_correct_i	(rob_br_pred_correct_i),
		.rob_br_tag_fix_i		(rob_br_tag_fix_i),
		.fu_br_done_i			(br2rob_done),

		.stall_i				(lsq_lq_com_rdy_stall),

		.result_o				(ld_result),
		.dest_tag_o				(ld_dest_tag),
		.rob_idx_o				(ldst_rob_idx),

		.lsq_sq_tail_o			(lsq_sq_tail_o),
		.lsq_ld_iss_en_o		(lsq_ld_iss_en_o),
		.lsq2Dcache_ld_addr_o	(lsq2Dcache_ld_addr_o),
		.lsq2Dcache_ld_en_o		(lsq2Dcache_ld_en_o),
		.lsq2Dcache_st_addr_o	(lsq2Dcache_st_addr_o),
		.lsq2Dcache_st_data_o	(lsq2Dcache_st_data_o),
		.lsq2Dcache_st_en_o		(lsq2Dcache_st_en_o),
		.lsq_lq_com_rdy_o		(lsq_lq_com_rdy),
		.lsq_sq_full_o			(lsq_sq_full_o),

		.br_mask_o				(ld_br_mask),
		.st_done_o				(st_done),
		.ld_done_o				(ld_done)
	);
	
endmodule	  
