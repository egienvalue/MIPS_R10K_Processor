// ****************************************************************************
// Filename: bmg.v
// Discription: Branch Mask Generator. Manages the assignment and correct prediction
// 		and misprediction handling of branch masks.
// Author: Lu Liu
// Version History:
// 10/28/2017 - initially created
// intial creation: 10/25/2017
// ***************************************************************************
//

module bmg (
		input					clk,
		input					rst,

		input					id_cond_branch_i,
		input					id_uncond_branch_i,
		input					if_id_br_pred_taken_i,
		input					rob_br_pred_correct_i,
		input					rob_br_recovery_i,
		input		[`BR_MASK_W-1:0]	rob_br_mask_i,
		input		[`BR_MASK_W-1:0]	rob_br_tag_i,

		output	logic	[`BR_MASK_W-1:0]	bmg_br_mask_o,
		output	logic	[`BR_MASK_W-1:0]	bmg2rob_br_mask_o,
		output	logic				bmg_br_mask_stall_o
	);

	logic	[`BR_MASK_W-1:0]			br_mask_r;

	logic						br_is_speculation;
	logic	[`BR_MASK_W-1:0]			next_free_tag;
	logic	[`BR_MASK_W-1:0]			br_mask_r_nxt;

	// priority selector to select a currently available tag
	integer i;
	always_comb begin
		next_free_tag = 0;
		for (i = 0; i < `BR_MASK_W; i = i + 1) begin
			if (br_mask_r[i] == 1'b0) begin
				next_free_tag[i] = 1'b1;
				break;
			end
		end
	end

	// a tag needs to be assigned to speculatively dispatched instructions following a branch that:
	// 1) is a conditional branch 
	// 2) is an unconditional branch but not predicted taken in IF stage, because BTB doesn't contain this branch yet
	assign br_is_speculation = id_cond_branch_i | (id_uncond_branch_i & ~if_id_br_pred_taken_i);

	assign br_mask_r_nxt = rob_br_recovery_i ? rob_br_mask_i :

			       (br_is_speculation && (~br_mask_r != 0) && rob_br_pred_correct_i) ? br_mask_r ^ rob_br_tag_i | next_free_tag :
			       // when there is a new speculative branch and correct prediction in the same cycle, clear the retired branch tag bit 
			       // in mask by xor and set the next free tag bit (e.g, current mask = 01101, next_free_tag = 00010, retired tag
			       // is 00001, next mask = 01110). However, when branch mask register is all 1's at the same time, retired branch tag 
			       // is directly forwarded to the new branch, and branch mask stays the same next cyle (this case will fall through
			       // to the next line which is ok)

			       br_is_speculation ? br_mask_r | next_free_tag :

			       rob_br_pred_correct_i ? br_mask_r ^ rob_br_tag_i : br_mask_r;

	assign bmg_br_mask_o = br_mask_r_nxt;

	// rob should save the branch mask before being changed by the current speculative branch
	assign bmg2rob_br_mask_o = (br_is_speculation && (~br_mask_r == 0) && rob_br_pred_correct_i) ? (br_mask_r ^ rob_br_tag_i) : br_mask_r;
				   // special situation where there is a new speculative branch and correct prediction in the same cycle while
				   // branch depth has reached maximum, in which case the retired branch tag is directly forwarded to the 
				   // current branch. Otherwise registered mask goes to output.

	assign bmg_br_mask_stall_o = ((~br_mask_r == 0) && br_is_speculation && ~rob_br_pred_correct_i) ? 1'b1 : 1'b0;

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			br_mask_r	<= `SD 0;
		end else begin
			br_mask_r	<= `SD br_mask_r_nxt;
		end
	end

endmodule

