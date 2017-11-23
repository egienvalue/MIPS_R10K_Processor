module perceptron_bp (
	input					clk,
    input					rst,
    input			[63:0]	if2bp_PC_i,
	input					if2bp_PC_vld_i,	
	input					fu2bp_br_cond_i,
    input					fu2bp_br_taken_i,		
    input					fu2bp_br_PC_i,	
    input			[63:0]	fu2bp_br_target_i,
	input					fu2bp_br_done_i,
	
	output	logic	[63:0]	btb_target_o,
    output	logic			bp_pred_o
	
	);

	//logic for perceptron 
	logic				pt_pred_o;	
	
	//logic for BTB
	logic				btb_is_hit_o;		// [DIRP] Tell DIRP if this pc is a branch or not.
	logic				btb_is_cond_o;		// [IF] Used to select prediction results.
	logic		[63:0]	btb_target_pc_o;		// [IF]	Prediction of target pc.

	//instantiate perceptron 
	perceptron perceptron (
			.clk,
			.rst,
			.if2pt_PC_vld_i(if2bp_PC_vld_i),
			.if2pt_PC_i(if2bp_PC_i),
			.fu2pt_br_taken_i(fu2bp_br_taken_i),
			.fu2pt_br_PC_i(fu2bp_br_PC_i),
			.fu2pt_br_cond_i(fu2bp_br_cond_i),
			.fu2pt_br_done_i(fu2bp_br_done_i),

			.pt_pred_o(pt_pred_o)
	);

	BTB BTB(
			.clk,
			.rst,
			.if_pc_i(if2bp_PC_i),				// [IF] PC from IF stage to see if it's a branch. Read only, never write. 
			.ex_is_br_i(fu2bp_br_done_i),		// [EX] If in the last cycle at the EX stage there's a branch insn, then at this cycle BTB must do something.
			.ex_is_cond_i(fu2bp_br_cond_i),		// [EX] Save whether it's a conditional branch.
			.ex_is_taken_i(fu2bp_br_taken_i),	// [EX] 1 is taken, 0 not taken.
			.ex_pc_i(fu2bp_br_PC_i),			// [EX] Branch PC from EX stage. If taken, add entry or maintain. If not-taken, remove entry or maintain empty.  	
			.ex_br_target_i(fu2bp_br_target_i), // [EX] Target address computed out in EX stage. Non-zero only if taken!
			.is_hit_o(btb_is_hit_o),			// [DIRP] Tell DIRP if this pc is a branch or not.
			.is_cond_o(btb_is_cond_o),			// [IF] Used to select prediction results.
			.btb_target_o(btb_target_pc_o)		// [IF]	Prediction of target pc.
	);

	assign 	btb_target_o = btb_target_pc_o;

	always_comb begin
		if (btb_is_hit_o&if2bp_PC_vld_i) begin
			if (btb_is_cond_o) begin
				bp_pred_o = pt_pred_o;
			end else begin
				bp_pred_o = 1'b1;
			end
		end else begin
			bp_pred_o = 1'b0;
		end
	end

endmodule
