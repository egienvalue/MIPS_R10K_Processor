// ****************************************************************************
// Filename: rs.v
// Discription: reservation station
// Author: Lu Liu
// Version History:
// 10/25/2017 - initially created, with scheduler at issue to avoid conflicts 
// 		during completion
// 10/28/2017 - added branch recovery function
// 11/12/2017 - added register output
// 11/19/2017 - added issue to dispatch forwarding, oldest first issue policy,
//              and ports and entries for lsq.
// intial creation: 10/25/2017
// ***************************************************************************
//

`define		SCHEDULE_VEC_ALU	1 << (`EX_CYCLES_MAX - `EX_CYCLES_ALU)
`define		SCHEDULE_VEC_BRANCH	1 << (`EX_CYCLES_MAX - `EX_CYCLES_BRANCH)
`define		SCHEDULE_VEC_LOAD	1 << (`EX_CYCLES_MAX - `EX_CYCLES_LOAD)
`define		SCHEDULE_VEC_STORE	1 << (`EX_CYCLES_MAX - `EX_CYCLES_STORE)
`define		SCHEDULE_VEC_MULT	1 << (`EX_CYCLES_MAX - `EX_CYCLES_MULT)
`define		DEBUG

module rs (
		input			clk,
		input			rst,

		input		[`PRF_IDX_W-1:0]	rat_dest_tag_i,
		input		[`PRF_IDX_W-1:0]	rat_opa_tag_i,
		input		[`PRF_IDX_W-1:0]	rat_opb_tag_i,
		input					rat_opa_rdy_i,
		input					rat_opb_rdy_i,

		input					id_inst_vld_i,		
		input		[`FU_SEL_W-1:0]		id_fu_sel_i,
		input		[31:0]			id_IR_i,

		input		[`ROB_IDX_W:0]		rob_idx_i,
	
		input		[`PRF_IDX_W-1:0]	cdb_tag_i,
		input					cdb_vld_i,

		input		[`SQ_IDX_W-1:0]		lsq_sq_tail_i,
		input					lsq_ld_iss_en_i,
		input					lsq_lq_com_rdy_stall_i,

		input					stall_dp_i,

		input		[`BR_MASK_W-1:0]	bmg_br_mask_i,
		input					rob_br_pred_correct_i,
		input					rob_br_recovery_i,
		input		[`BR_MASK_W-1:0]	rob_br_tag_fix_i,

		// ----------------- Output -----------------
		output	logic	[`SQ_IDX_W-1:0]		rs_sq_position_o,

		output	logic				rs_iss_vld_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o,
		output	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel_o,
		output	logic	[31:0]			rs_iss_IR_o,
		output	logic	[`ROB_IDX_W:0]		rs_iss_rob_idx_o,
		output	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask_o,
		output	logic	[`SQ_IDX_W-1:0]		rs_iss_sq_position_o,

		output	logic				rs_full_o
	);

	logic						dp_en;

	logic	[`RS_ENT_NUM-1:0]			avail_vec;
	logic	[`RS_ENT_NUM-1:0]			load_vec;
	logic	[`RS_ENT_NUM-1:0]			load_vec_without_forward;
	logic	[`RS_ENT_NUM-1:0]			iss_vec;
	logic	[`RS_ENT_NUM-1:0]			iss_vec_non_ld;
	logic	[`RS_ENT_NUM-1:0]			iss_vec_ld;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	opa_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	opb_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	dest_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`FU_SEL_W-1:0]	fu_sel_vec;
	logic	[`RS_ENT_NUM-1:0] [31:0]		IR_vec;
	logic	[`RS_ENT_NUM-1:0] [`ROB_IDX_W:0]	rob_idx_vec;
	logic	[`RS_ENT_NUM-1:0] [`ROB_IDX_W:0]	rob_idx_vec_reordered;
	logic	[`RS_ENT_NUM-1:0] [`BR_MASK_W-1:0]	br_mask_vec;
	logic	[`RS_ENT_NUM-1:0] [`SQ_IDX_W-1:0]	sq_position_vec;
	`ifdef DEBUG
	logic	[`RS_ENT_NUM-1:0]			opa_rdy_vec;
	logic	[`RS_ENT_NUM-1:0]			opb_rdy_vec;
	`endif

	logic	[`EX_CYCLES_MAX-1:0]			exunit_schedule_r;
	logic	[`EX_CYCLES_MAX-1:0]			exunit_schedule_r_nxt;
	logic	[`RS_ENT_NUM-1:0] [`EX_CYCLES_MAX-1:0]	rs_ent_schedule_vec;
	logic	[`RS_ENT_NUM-1:0]			allow_schedule_vec;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec_scheduled_non_ld;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec_scheduled_ld;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec_ld_mask;
	logic	[`ROB_IDX_W:0]				rob_idx_prev;
	logic						rob_idx_ovf_r;
	logic						rob_idx_ovf_r_nxt; // used in oldest finder logic
	logic						ld_iss_en;
	logic	[`RS_IDX_W-1:0]				iss_idx;
	logic	[`RS_IDX_W-1:0]				iss_idx_non_ld;
	logic	[`RS_IDX_W-1:0]				iss_idx_ld;
	logic						iss_vld_non_ld;
	logic						iss_vld_ld;
	logic						rs_iss_vld;
	logic	[`PRF_IDX_W-1:0]			rs_iss_opa_tag;
	logic	[`PRF_IDX_W-1:0]			rs_iss_opb_tag;
	logic	[`PRF_IDX_W-1:0]			rs_iss_dest_tag;
	logic	[`FU_SEL_W-1:0]				rs_iss_fu_sel;
	logic	[31:0]					rs_iss_IR;;
	logic	[`ROB_IDX_W:0]				rs_iss_rob_idx;
	logic	[`BR_MASK_W-1:0]			rs_iss_br_mask;
	logic	[`SQ_IDX_W-1:0]				rs_iss_sq_position;
	logic						rs_full;

	assign	rs_iss_opa_tag		= opa_tag_vec[iss_idx];
	assign	rs_iss_opb_tag		= opb_tag_vec[iss_idx];
	assign	rs_iss_dest_tag		= dest_tag_vec[iss_idx];
	assign	rs_iss_fu_sel		= fu_sel_vec[iss_idx];
	assign	rs_iss_IR		= IR_vec[iss_idx];
	assign	rs_iss_rob_idx		= rob_idx_vec[iss_idx];
	assign	rs_iss_br_mask		= br_mask_vec[iss_idx];
	assign	rs_iss_sq_position	= sq_position_vec[iss_idx];
	assign	rs_full			= ~(|avail_vec);
	assign	rs_full_o		= rs_full & ~rs_iss_vld;
	assign	rs_sq_position_o	= sq_position_vec[iss_idx_ld];

	// register output
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			rs_iss_vld_o		<= `SD 1'b0;
			rs_iss_opa_tag_o	<= `SD 0;
			rs_iss_opb_tag_o	<= `SD 0;
			rs_iss_dest_tag_o	<= `SD 0;
			rs_iss_fu_sel_o		<= `SD `FU_SEL_NONE;
			rs_iss_IR_o		<= `SD 0;
			rs_iss_rob_idx_o	<= `SD 0;
			rs_iss_br_mask_o	<= `SD 0;
			rs_iss_sq_position_o	<= `SD 0;
		end else if (~lsq_lq_com_rdy_stall_i & ~rob_br_recovery_i) begin
			rs_iss_vld_o		<= `SD rs_iss_vld;
			rs_iss_opa_tag_o	<= `SD rs_iss_opa_tag;
			rs_iss_opb_tag_o	<= `SD rs_iss_opb_tag;
			rs_iss_dest_tag_o	<= `SD rs_iss_dest_tag;
			rs_iss_fu_sel_o		<= `SD rs_iss_fu_sel;
			rs_iss_IR_o		<= `SD rs_iss_IR;
			rs_iss_rob_idx_o	<= `SD rs_iss_rob_idx;
			rs_iss_br_mask_o	<= `SD rs_iss_br_mask;
			rs_iss_sq_position_o	<= `SD rs_iss_sq_position;
		end
	end

	// Instantiate reservation station entries
	genvar i;
	generate
		for (i = 0; i < `RS_ENT_NUM; i = i + 1) begin : rs_ent_gen
			rs1 rs_ent (
				.clk			(clk),
				.rst			(rst),

				.rs1_dest_tag_i		(rat_dest_tag_i),
				.rs1_cdb_tag_i		(cdb_tag_i),
				.rs1_cdb_vld_i		(cdb_vld_i),
				.rs1_opa_tag_i		(rat_opa_tag_i),
				.rs1_opb_tag_i		(rat_opb_tag_i),
				.rs1_opa_rdy_i		(rat_opa_rdy_i),
				.rs1_opb_rdy_i		(rat_opb_rdy_i),
				.rs1_fu_sel_i		(id_fu_sel_i),
				.rs1_IR_i		(id_IR_i),
				.rs1_rob_idx_i		(rob_idx_i),
				.rs1_br_mask_i		(bmg_br_mask_i),
				.rs1_sq_position_i	(lsq_sq_tail_i),
				.rs1_load_i		(load_vec[i]),
				.rs1_iss_en_i		(iss_vec[i]),
				.rs1_br_pred_correct_i	(rob_br_pred_correct_i),
				.rs1_br_recovery_i	(rob_br_recovery_i),
				.rs1_br_tag_fix_i	(rob_br_tag_fix_i),

				.rs1_rdy_o		(rdy_vec[i]),
				.rs1_opa_tag_o		(opa_tag_vec[i]),
				.rs1_opb_tag_o		(opb_tag_vec[i]),
				.rs1_dest_tag_o		(dest_tag_vec[i]),
				.rs1_fu_sel_o		(fu_sel_vec[i]),
				.rs1_IR_o		(IR_vec[i]),
				.rs1_rob_idx_o		(rob_idx_vec[i]),
				.rs1_br_mask_o		(br_mask_vec[i]),
				.rs1_sq_position_o	(sq_position_vec[i]),
				.rs1_avail_o		(avail_vec[i])
				`ifdef DEBUG
				,.rs1_opa_rdy_o		(opa_rdy_vec[i]),
				.rs1_opb_rdy_o		(opb_rdy_vec[i])
				`endif
			);
		end //rs_ent_gen
	endgenerate

	// -------------------------- Dispatch --------------------------------
	assign dp_en = ~stall_dp_i & ~rob_br_recovery_i;

	assign load_vec = ~dp_en ? 0 :
			  rs_full ? iss_vec : load_vec_without_forward;

	// generate rob_idx_ovf for oldest finder logic
	// rob_idx_ovf == 1'b0 means rob_idx with MSB of 1 is younger, and vice versa
	assign rob_idx_ovf_r_nxt = ((rob_idx_prev == {1'b0, {`ROB_IDX_W{1'b1}}}) && (rob_idx_i == {1'b1, {`ROB_IDX_W{1'b0}}})) ? 1'b0 :
				   ((rob_idx_prev == {(`ROB_IDX_W+1){1'b1}}) && (rob_idx_i == {(`ROB_IDX_W+1){1'b0}})) ? 1'b1 : rob_idx_ovf_r;

	// synopsys sync_set_reset "rst"
	always @(posedge clk) begin
		if (rst) begin
			rob_idx_ovf_r		<= `SD 1'b0;
			rob_idx_prev		<= `SD 1'b0;
		end else begin
			rob_idx_ovf_r		<= `SD rob_idx_ovf_r_nxt;
			rob_idx_prev		<= `SD rob_idx_i;
		end
	end
	
	ps # (
		.NUM_BITS	(`RS_ENT_NUM)
	)
	dp_selector (
		.req		(avail_vec),
		.en		(dp_en),

		.gnt		(load_vec_without_forward),
		.req_up		()
	);

	// ---------------------------- Issue ---------------------------------
	// scheduler logic
	integer j;
	always_comb begin
		rdy_vec_ld_mask = 0;
		for (j = 0; j < `RS_ENT_NUM; j = j + 1) begin
			case (fu_sel_vec[j])
				`FU_SEL_NONE:		rs_ent_schedule_vec[j] = 0;
				`FU_SEL_ALU:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_ALU;
				`FU_SEL_UNCOND_BRANCH, `FU_SEL_COND_BRANCH:	
							rs_ent_schedule_vec[j] = `SCHEDULE_VEC_BRANCH;
				`FU_SEL_LOAD: begin
							rs_ent_schedule_vec[j] = `SCHEDULE_VEC_LOAD;
							rdy_vec_ld_mask[j] = 1'b1;
				end
				`FU_SEL_STORE:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_STORE;
				`FU_SEL_MULT:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_MULT;
				default:		rs_ent_schedule_vec[j] = {`EX_CYCLES_MAX{1'b1}};
			endcase

			allow_schedule_vec[j] = ((rs_ent_schedule_vec[j][`EX_CYCLES_MAX-1:1] & exunit_schedule_r[`EX_CYCLES_MAX-2:0]) == 0) ? 1'b1 : 1'b0;
		end
	end

	assign rdy_vec_scheduled_non_ld	= rdy_vec & allow_schedule_vec & ~rdy_vec_ld_mask;
	assign rdy_vec_scheduled_ld	= rdy_vec & allow_schedule_vec & rdy_vec_ld_mask;
	assign exunit_schedule_r_nxt	= (rob_br_recovery_i | lsq_lq_com_rdy_stall_i) ? exunit_schedule_r :
					  rs_iss_vld ? ({exunit_schedule_r[`EX_CYCLES_MAX-2:0], 1'b0} | rs_ent_schedule_vec[iss_idx]) :
					               {exunit_schedule_r[`EX_CYCLES_MAX-2:0], 1'b0};

	// adjust the MSB of rob_idx for use by oldest_finder logic
	integer k;
	always_comb begin
		for (k = 0; k < `RS_ENT_NUM; k = k + 1) begin
			if (~rob_idx_ovf_r)
				rob_idx_vec_reordered[k] = rob_idx_vec[k];
			else
				rob_idx_vec_reordered[k] = {~rob_idx_vec[k][`ROB_IDX_W], rob_idx_vec[k][`ROB_IDX_W-1:0]};
		end
	end

	// issue logic
	// oldest first
	oldest_finder # (
		.NUM_ENT	(`RS_ENT_NUM)
	)
	non_ld_selector (
		.req		(rdy_vec_scheduled_non_ld),
		.order		(rob_idx_vec_reordered),
		.en		(~rob_br_recovery_i & ~lsq_lq_com_rdy_stall_i),
		.gnt		(iss_vec_non_ld),
		.req_up		(),
		.order_up	()
	);

	oldest_finder # (
		.NUM_ENT	(`RS_ENT_NUM)
	)
	ld_selector (
		.req		(rdy_vec_scheduled_ld),
		.order		(rob_idx_vec_reordered),
		.en		(~rob_br_recovery_i & ~lsq_lq_com_rdy_stall_i),
		.gnt		(iss_vec_ld),
		.req_up		(),
		.order_up	()
	);

	/*
	// simply find one instrution that can be issued
	ps # (
		.NUM_BITS	(`RS_ENT_NUM)
	)
	iss_selector (
		.req		(rdy_vec_scheduled),
		.en		(~rob_br_recovery_i),

		.gnt		(iss_vec),
		.req_up		()
	);
	*/

	pe # (
		.OUT_WIDTH	(`RS_IDX_W)
	)
	iss_non_ld_encoder (
		.gnt		(iss_vec_non_ld),
		.enc		(iss_idx_non_ld)
	);

	pe # (
		.OUT_WIDTH	(`RS_IDX_W)
	)
	iss_ld_encoder (
		.gnt		(iss_vec_ld),
		.enc		(iss_idx_ld)
	);

	assign iss_vld_non_ld = |iss_vec_non_ld;
	assign iss_vld_ld = |iss_vec_ld;
	assign ld_iss_en = iss_vld_ld & lsq_ld_iss_en_i;
	assign iss_vec = ld_iss_en ? iss_vec_ld : iss_vec_non_ld;
	assign iss_idx = ld_iss_en ? iss_idx_ld : iss_idx_non_ld;
	assign rs_iss_vld = ld_iss_en | iss_vld_non_ld;

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst)
			exunit_schedule_r <= `SD 0;
		else
			exunit_schedule_r <= exunit_schedule_r_nxt;
	end

endmodule
