// ****************************************************************************
// Filename: rs1.v
// Discription: one entry for reservation station
// Author: Group 5, Lu Liu
// Version History: 
// 10/16/2017 - Initially created.
// 10/28/2017 - Added several entries and branch recovery signals
// 11/19/2017 - Added issue to dispatch forward logic
// intial creation: 10/16/2017
// ***************************************************************************
//

`define		DEBUG

module	rs1 (
		input				clk,
		input				rst,
		
		input		[`PRF_IDX_W-1:0]	rs1_dest_tag_i,
		input		[`PRF_IDX_W-1:0]	rs1_cdb_tag_i,
		input					rs1_cdb_vld_i,
		input		[`PRF_IDX_W-1:0]   	rs1_opa_tag_i,
		input		[`PRF_IDX_W-1:0]	rs1_opb_tag_i,
		input					rs1_opa_rdy_i,
		input					rs1_opb_rdy_i,
		input		[`FU_SEL_W-1:0]		rs1_fu_sel_i,
		input		[31:0]			rs1_IR_i,
		input		[`ROB_IDX_W:0]		rs1_rob_idx_i,
		input		[`BR_MASK_W-1:0]	rs1_br_mask_i,
		input		[`SQ_IDX_W-1:0]		rs1_sq_position_i,
		input					rs1_ldl_i,
		input					rs1_load_i,
		input					rs1_iss_en_i,
		// branch recovery
		input					rs1_br_pred_correct_i,
		input					rs1_br_recovery_i,
		input		[`BR_MASK_W-1:0]	rs1_br_tag_fix_i,
		
		output					rs1_rdy_o,
		output		[`PRF_IDX_W-1:0]	rs1_opa_tag_o,
		output		[`PRF_IDX_W-1:0]	rs1_opb_tag_o,
		output		[`PRF_IDX_W-1:0]	rs1_dest_tag_o,
		output		[`FU_SEL_W-1:0]		rs1_fu_sel_o,
		output		[31:0]			rs1_IR_o,
		output		[`ROB_IDX_W:0]		rs1_rob_idx_o,
		output		[`BR_MASK_W-1:0]	rs1_br_mask_o,
		output		[`SQ_IDX_W-1:0]		rs1_sq_position_o,
		output					rs1_ldl_o,
		output					rs1_avail_o

		`ifdef DEBUG
		,output					rs1_opa_rdy_o,
		output					rs1_opb_rdy_o
		`endif
	);
	
	logic		[`PRF_IDX_W-1:0]		opa_tag_r;
	logic		[`PRF_IDX_W-1:0]		opb_tag_r;
	logic						opa_rdy_r;
	logic 						opb_rdy_r;
	logic		[`PRF_IDX_W-1:0]		dest_tag_r;
	logic		[`FU_SEL_W-1:0]			fu_sel_r;
	logic		[31:0]				IR_r;
	logic		[`ROB_IDX_W:0]			rob_idx_r;
	logic		[`BR_MASK_W-1:0]		br_mask_r;
	logic		[`SQ_IDX_W-1:0]			sq_position_r;
	logic						ldl_r;
	logic						avail_r;

	logic		[`PRF_IDX_W-1:0]		opa_tag_r_nxt;
	logic		[`PRF_IDX_W-1:0]		opb_tag_r_nxt;
	logic						opa_rdy_r_nxt;
	logic 						opb_rdy_r_nxt;
	logic		[`PRF_IDX_W-1:0]		dest_tag_r_nxt;
	logic		[`FU_SEL_W-1:0]			fu_sel_r_nxt;
	logic		[31:0]				IR_r_nxt;
	logic		[`ROB_IDX_W:0]			rob_idx_r_nxt;
	logic		[`BR_MASK_W-1:0]		br_mask_r_nxt;
	logic		[`SQ_IDX_W-1:0]			sq_position_r_nxt;
	logic						ldl_r_nxt;
	logic						avail_r_nxt;

	logic						br_prmiss_fix;

	assign opa_rdy_r_nxt	= br_prmiss_fix ? 1'b0 :
				  (rs1_load_i && rs1_cdb_vld_i && (rs1_opa_tag_i == rs1_cdb_tag_i)) ? 1'b1 :
				  rs1_load_i ? rs1_opa_rdy_i :
				  rs1_iss_en_i ? 1'b0 :
				  (~avail_r & rs1_cdb_vld_i & (opa_tag_r == rs1_cdb_tag_i)) ? 1'b1 : opa_rdy_r;
				  
	assign opb_rdy_r_nxt	= br_prmiss_fix ? 1'b0 :
				  (rs1_load_i && rs1_cdb_vld_i && (rs1_opb_tag_i == rs1_cdb_tag_i)) ? 1'b1 :
				  rs1_load_i ? rs1_opb_rdy_i :
				  rs1_iss_en_i ? 1'b0 :
				  (~avail_r & rs1_cdb_vld_i & (opb_tag_r == rs1_cdb_tag_i)) ? 1'b1 : opb_rdy_r;

	assign rs1_rdy_o	= avail_r ? 1'b0 :
				  (opa_rdy_r && opb_rdy_r) ? 1'b1 :
				  (~opa_rdy_r && opb_rdy_r && rs1_cdb_vld_i && (opa_tag_r == rs1_cdb_tag_i)) ? 1'b1 :
				  (~opb_rdy_r && opa_rdy_r && rs1_cdb_vld_i && (opb_tag_r == rs1_cdb_tag_i)) ? 1'b1 :
				  (rs1_cdb_vld_i && (opa_tag_r == rs1_cdb_tag_i) && (opb_tag_r == rs1_cdb_tag_i)) ? 1'b1 : 1'b0;

	assign rs1_br_mask_o	= rs1_br_pred_correct_i ? (br_mask_r & ~rs1_br_tag_fix_i) : br_mask_r;

	assign br_mask_r_nxt	= br_prmiss_fix ? 0 :
				  (rs1_load_i & rs1_br_pred_correct_i) ? (rs1_br_mask_i & ~rs1_br_tag_fix_i) :
				  rs1_load_i ? rs1_br_mask_i :
				  rs1_iss_en_i ? 0 :
				  rs1_br_pred_correct_i ? (br_mask_r & ~rs1_br_tag_fix_i) : br_mask_r;
				  
	assign br_prmiss_fix	= rs1_br_recovery_i && ((rs1_br_tag_fix_i & br_mask_r) != 0);

	assign rs1_opa_tag_o 		= opa_tag_r;
	assign rs1_opb_tag_o 		= opb_tag_r;
	assign rs1_dest_tag_o		= dest_tag_r;
	assign rs1_fu_sel_o		= fu_sel_r;
	assign rs1_IR_o			= IR_r;
	assign rs1_rob_idx_o		= rob_idx_r;
	assign rs1_sq_position_o	= sq_position_r;
	assign rs1_ldl_o		= ldl_r;
	assign rs1_avail_o 		= avail_r;
	`ifdef DEBUG
	assign rs1_opa_rdy_o		= opa_rdy_r;
	assign rs1_opb_rdy_o		= opb_rdy_r;
	`endif
	
	always_comb begin
		if (br_prmiss_fix) begin
			opa_tag_r_nxt		= 0;
			opb_tag_r_nxt		= 0;
			dest_tag_r_nxt		= 0;
			fu_sel_r_nxt		= `FU_SEL_NONE;
			IR_r_nxt		= 32'b0;
			rob_idx_r_nxt		= 0;
			sq_position_r_nxt	= 0;
			ldl_r_nxt		= 1'b0;
			avail_r_nxt		= 1'b1;
		end else if (rs1_load_i) begin
			opa_tag_r_nxt		= rs1_opa_tag_i;
			opb_tag_r_nxt		= rs1_opb_tag_i;
			dest_tag_r_nxt		= rs1_dest_tag_i;
			fu_sel_r_nxt		= rs1_fu_sel_i;
			IR_r_nxt		= rs1_IR_i;
			rob_idx_r_nxt		= rs1_rob_idx_i;
			sq_position_r_nxt	= rs1_sq_position_i;
			ldl_r_nxt		= rs1_ldl_i;
			avail_r_nxt		= 1'b0;
		end else if (rs1_iss_en_i) begin
			opa_tag_r_nxt		= 0;
			opb_tag_r_nxt		= 0;
			dest_tag_r_nxt		= 0;
			fu_sel_r_nxt		= `FU_SEL_NONE;
			IR_r_nxt		= 32'b0;
			rob_idx_r_nxt		= 0;
			sq_position_r_nxt	= 0;
			ldl_r_nxt		= 1'b0;
			avail_r_nxt		= 1'b1;
		end else begin
			opa_tag_r_nxt		= opa_tag_r;
			opb_tag_r_nxt		= opb_tag_r;
			dest_tag_r_nxt		= dest_tag_r;
			fu_sel_r_nxt		= fu_sel_r;
			IR_r_nxt		= IR_r;
			rob_idx_r_nxt		= rob_idx_r;
			sq_position_r_nxt	= sq_position_r;
			ldl_r_nxt		= ldl_r;
			avail_r_nxt		= avail_r;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			opa_tag_r  	<= `SD 0;
			opb_tag_r  	<= `SD 0;
			opa_rdy_r  	<= `SD 1'b0;
			opb_rdy_r  	<= `SD 1'b0;
			dest_tag_r 	<= `SD 0;
			fu_sel_r   	<= `SD `FU_SEL_NONE;
			avail_r    	<= `SD 1'b1;
			IR_r	   	<= `SD 32'b0;
			rob_idx_r  	<= `SD 0;
			br_mask_r  	<= `SD 0;
			sq_position_r	<= `SD 0;
			ldl_r		<= `SD 1'b0;
		end else begin
			opa_tag_r  	<= `SD opa_tag_r_nxt;
			opb_tag_r  	<= `SD opb_tag_r_nxt;
			opa_rdy_r  	<= `SD opa_rdy_r_nxt;
			opb_rdy_r  	<= `SD opb_rdy_r_nxt;
			dest_tag_r 	<= `SD dest_tag_r_nxt;
			fu_sel_r   	<= `SD fu_sel_r_nxt;
			avail_r    	<= `SD avail_r_nxt;
			IR_r       	<= `SD IR_r_nxt;
			rob_idx_r  	<= `SD rob_idx_r_nxt;
			br_mask_r  	<= `SD br_mask_r_nxt;
			sq_position_r	<= `SD sq_position_r_nxt;
			ldl_r		<= `SD ldl_r_nxt;
		end
	end

endmodule	
