// ****************************************************************************
// Filename: rs.v
// Discription: reservation station
// Author: Lu Liu
// Version History:
// 10/25/2017 - initially created, with scheduler at issue to avoid conflicts 
// 		during completion
// 10/28/2017 - added branch recovery function
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

		input		[`ROB_IDX_W-1:0]	rob_idx_i,
	
		input		[`PRF_IDX_W-1:0]	cdb_tag_i,
		input					cdb_vld_i,

		input					stall_dp_i,

		input		[`BR_MASK_W-1:0]	bmg_br_mask_i,
		input					rob_br_pred_correct_i,
		input					rob_br_recovery_i,
		input		[`BR_MASK_W-1:0]	rob_br_tag_fix_i,

		// ------------- Output -----------------
		output	logic				rs_iss_vld_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o,
		output	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o,
		output	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel_o,
		output	logic	[31:0]			rs_iss_IR_o,
		output	logic	[`ROB_IDX_W-1:0]	rs_iss_rob_idx_o,
		output	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask_o,

		output	logic				rs_full_o
	);

	logic						dp_en;

	logic	[`RS_ENT_NUM-1:0]			avail_vec;
	logic	[`RS_ENT_NUM-1:0]			load_vec;
	logic	[`RS_ENT_NUM-1:0]			iss_vec;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	opa_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	opb_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`PRF_IDX_W-1:0]	dest_tag_vec;
	logic	[`RS_ENT_NUM-1:0] [`FU_SEL_W-1:0]	fu_sel_vec;
	logic	[`RS_ENT_NUM-1:0] [31:0]		IR_vec;
	logic	[`RS_ENT_NUM-1:0] [`ROB_IDX_W-1:0]	rob_idx_vec;
	logic	[`RS_ENT_NUM-1:0] [`BR_MASK_W-1:0]	br_mask_vec;
	`ifdef DEBUG
	logic	[`RS_ENT_NUM-1:0]			opa_rdy_vec;
	logic	[`RS_ENT_NUM-1:0]			opb_rdy_vec;
	`endif

	logic	[`EX_CYCLES_MAX-1:0]			exunit_schedule_r;
	logic	[`EX_CYCLES_MAX-1:0]			exunit_schedule_r_nxt;
	logic	[`RS_ENT_NUM-1:0] [`EX_CYCLES_MAX-1:0]	rs_ent_schedule_vec;
	logic	[`RS_ENT_NUM-1:0]			allow_schedule_vec;
	logic	[`RS_ENT_NUM-1:0]			rdy_vec_scheduled;
	logic	[`RS_IDX_W-1:0]				iss_idx;

	assign	rs_iss_vld_o		= |iss_vec;
	assign	rs_iss_opa_tag_o	= opa_tag_vec[iss_idx];
	assign	rs_iss_opb_tag_o	= opb_tag_vec[iss_idx];
	assign	rs_iss_dest_tag_o	= dest_tag_vec[iss_idx];
	assign	rs_iss_fu_sel_o		= fu_sel_vec[iss_idx];
	assign	rs_iss_IR_o			= IR_vec[iss_idx];
	assign	rs_iss_rob_idx_o	= rob_idx_vec[iss_idx];
	assign	rs_iss_br_mask_o	= br_mask_vec[iss_idx];
	assign	rs_full_o			= ~(|avail_vec);

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
				.rs1_avail_o		(avail_vec[i])
				`ifdef DEBUG
				,.rs1_opa_rdy_o		(opa_rdy_vec[i]),
				.rs1_opb_rdy_o		(opb_rdy_vec[i])
				`endif
			);
		end //rs_ent_gen
	endgenerate

	// Dispatch
	assign dp_en = id_inst_vld_i & ~stall_dp_i & ~rob_br_recovery_i;

	ps # (
		.NUM_BITS	(`RS_ENT_NUM)
	)
	dp_selector (
		.req		(avail_vec),
		.en		(dp_en),

		.gnt		(load_vec),
		.req_up		()
	);

	// Issue
	integer j;

	always_comb begin
		for (j = 0; j < `RS_ENT_NUM; j = j + 1) begin
			case (fu_sel_vec[j])
				`FU_SEL_NONE:		rs_ent_schedule_vec[j] = 0;
				`FU_SEL_ALU:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_ALU;
				`FU_SEL_UNCOND_BRANCH, `FU_SEL_COND_BRANCH:	
									rs_ent_schedule_vec[j] = `SCHEDULE_VEC_BRANCH;
				`FU_SEL_LOAD:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_LOAD;
				`FU_SEL_STORE:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_STORE;
				`FU_SEL_MULT:		rs_ent_schedule_vec[j] = `SCHEDULE_VEC_MULT;
				default:		rs_ent_schedule_vec[j] = {`EX_CYCLES_MAX{1'b1}};
			endcase

			allow_schedule_vec[j] = ((rs_ent_schedule_vec[j][`EX_CYCLES_MAX-1:1] & exunit_schedule_r[`EX_CYCLES_MAX-2:0]) == 0) ? 1'b1 : 1'b0;
		end
	end

	assign rdy_vec_scheduled	= rdy_vec & allow_schedule_vec;
	assign exunit_schedule_r_nxt	= rs_iss_vld_o ? ({exunit_schedule_r[`EX_CYCLES_MAX-2:0], 1'b0} | rs_ent_schedule_vec[iss_idx]) :
							 {exunit_schedule_r[`EX_CYCLES_MAX-2:0], 1'b0};

	ps # (
		.NUM_BITS	(`RS_ENT_NUM)
	)
	iss_selector (
		.req		(rdy_vec_scheduled),
		.en		(~rob_br_recovery_i),

		.gnt		(iss_vec),
		.req_up		()
	);

	pe # (
		.OUT_WIDTH	(`RS_IDX_W)
	)
	iss_encoder (
		.gnt		(iss_vec),
		.enc		(iss_idx)
	);

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst)
			exunit_schedule_r <= `SD 0;
		else
			exunit_schedule_r <= exunit_schedule_r_nxt;
	end

endmodule
