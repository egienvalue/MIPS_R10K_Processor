module perceptron_bp (
	input					clk,
    input					rst,
    input			[63:0]	if2bp_PC_i,
	input					if2bp_PC_vld_i,	
	input					fu2bp_br_cond_i,
    input					fu2bp_br_taken_i,		
    input			[63:0]	fu2bp_br_PC_i,	
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

	BTB btb0(
		.clk,
    	.rst,
    	.if_pc_i(if2bp_PC_i),		
    	.ex_is_br_i(fu2bp_br_done_i),		
    	.ex_is_cond_i(fu2bp_br_cond_i),	
    	.ex_is_taken_i(fu2bp_br_taken_i),	
    	.ex_pc_i(fu2bp_br_PC_i),		
    	.ex_br_target_i(fu2bp_br_target_i), 
    	.is_hit_o(btb_is_hit_o),		
    	.is_cond_o(btb_is_cond_o),		
    	.btb_target_o(btb_target_pc_o)
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
