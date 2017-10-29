// ****************************************************************************
// Filename: br_tag_gen.v
// Discription: Branch tag generator
// Author: Lu Liu
// Version History:
// 10/28/2017 - initially created
// intial creation: 10/25/2017
// ***************************************************************************
//

module br_tag_gen (
		input				clk,
		input				rst,

		input					id_cond_branch_i,
		input					id_uncond_branch_i,
		input					if_id_br_pred_taken_i,
		input					rob_br_pred_correct_i,
		input					rob_br_recovery_i,

		output	logic	[`BR_TAG_W-1:0]		btg_br_tag_o,
		output	logic				btg_br_tag_stall_o
	);

	logic	[`BR_TAG_W-1:0]		br_tag_r;
	logic	[`BR_DEPTH_W-1:0]	br_depth_r;

	logic				br_is_speculation;
	logic	[`BR_TAG_W-1:0]		br_tag_r_nxt;
	logic	[`BR_DEPTH_W-1:0]	br_depth_r_nxt;
	
	// a tag need to be assigned to speculatively dispatched instructions following a branch that:
	// 1) is a conditional branch 
	// 2) is an unconditional branch but not predicted taken in IF stage, because BTB doesn't contain this branch yet
	assign br_is_speculation = id_cond_branch_i | (id_uncond_branch_i & ~if_id_br_pred_taken_i);

	// branch tag is a circular shift register
	assign br_tag_r_nxt = btg_br_tag_stall_o ? br_tag_r : {br_tag_r[`BR_TAG_W-2:0], br_tag_r[`BR_TAG_W-1]};

	assign br_depth_r_nxt = (br_is_speculation & rob_br_pred_correct_i) | ? br_depth_r :
				br_is_specualtion ? br_depth_r + 1 :
				rob_br_pred_correct_i ? br_depth_r - 1 : br_depth_r;

	assign btg_br_tag_stall_o = (br_is_speculation & rob_br_pred_correct_i) ? 1'b0 :
				    (br_is_speculation && (br_depth_r == `BR_TAG_W)) ? 1'b1 : 1'b0;
	
	assign btg_br_tag_o = br_is_speculation

	// synopsys sync_set_reset "rst"
	always @(posedge clk) begin
		if (rst) begin
			br_tag_r	<= `SD 1;
			br_depth_r	<= `SD 0;
		end else if (~rob_br_recovery_i) begin
			br_tag_r	<= `SD br_tag_r_nxt;
			br_depth_r	<= `SD br_depth_r_nxt;
		end
	end

endmodule
