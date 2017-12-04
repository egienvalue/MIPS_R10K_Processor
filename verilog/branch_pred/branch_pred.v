
module branch_pred(
	input			clk,
    input			rst,
    input	[63:0]	if_pc_i,		
    input			ex_is_br_i,		
    input			ex_is_cond_i,	
    input			ex_is_taken_i,	
    input	[63:0]	ex_pc_i,		
    input	[63:0]	ex_br_target_i,
    //output			is_hit_o,		
    //output			is_cond_o,		
	output	logic	[63:0]	btb_target_o,
    output	logic			pred_o
	);

	logic	is_hit;
	logic	is_cond;
	logic	dirp_pred;
	//logic	PCp_four = if_pc_i + 4;

	// comb assign to btb_target_o, pred_o
	always_comb begin
		if (is_hit) begin
			if (is_cond) begin
				pred_o = dirp_pred;
			end else begin
				pred_o = 1'b1;
			end
		end else begin
			pred_o = 1'b0;
		end
	end


	PAg_DIRP dirp0(
		.clk,
    	.rst,
    	.if_pc_i,		
    	.ex_is_br_i,		
    	.ex_is_cond_i,	
    	.ex_is_taken_i,	
    	.ex_pc_i,
		.pred_o(dirp_pred)
	);

	BTB btb0(
		.clk,
    	.rst,
    	.if_pc_i,		
    	.ex_is_br_i,		
    	.ex_is_cond_i,	
    	.ex_is_taken_i,	
    	.ex_pc_i,		
    	.ex_br_target_i, 
    	.is_hit_o(is_hit),		
    	.is_cond_o(is_cond),		
    	.btb_target_o(btb_target_o)
	);

endmodule
