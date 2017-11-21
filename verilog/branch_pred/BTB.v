
module BTB(
	input			clk,
	input			rst,
	input	[63:0]	if_pc_i,		// [IF] PC from IF stage to see if it's a branch. Read only, never write. 
	input			ex_is_br_i,		// [EX] If in the last cycle at the EX stage there's a branch insn, then at this cycle BTB must do something.
	input			ex_is_cond_i,	// [EX] Save whether it's a conditional branch.
	input			ex_is_taken_i,	// [EX] 1 is taken, 0 not taken.
	input	[63:0]	ex_pc_i,		// [EX] Branch PC from EX stage. If taken, add entry or maintain. If not-taken, remove entry or maintain empty.  	
	input	[63:0]	ex_br_target_i, // [EX] Target address computed out in EX stage. Non-zero only if taken!
	output	logic	is_hit_o,		// [DIRP] Tell DIRP if this pc is a branch or not.
	output	logic	is_cond_o,		// [IF] Used to select prediction results.
	output	logic	[63:0]	target_pc_o		// [IF]	Prediction of target pc.
	);

	logic	[`BTB_NUM-1:0][`BTB_TAG_W-1:0]	TAGS, VALS, CONDS;

	logic	[`BTB_SEL_W-1:0]	if_pc_sel, ex_pc_sel;
	logic	[`BTB_TAG_W-1:0]	if_pc_tag, ex_pc_tag;
	logic	[`BTB_VAL_W-1:0]	ex_target_val;
	logic						is_hit_buffer, is_cond_buffer;
	logic	[63:0]				target_pc_buffer;	// Buffer two outputs because the inputs from EX at the same cycle would possibilly change the two outputs.
	
	assign if_pc_sel = if_pc_i[`BTB_SEL_W+1:2];
	assign if_pc_tag = if_pc_i[`BTB_TAG_W+1+`BTB_SEL_W:`BTB_SEL_W+2];

	assign ex_pc_sel = ex_pc_i[`BTB_SEL_W+1:2];
	assign ex_pc_tag = ex_pc_i[`BTB_TAG_W+1+`BTB_SEL_W:`BTB_SEL_W+2];
	
	assign ex_target_val = ex_br_target_i[`BTB_VAL_W+1:2];

	// Comb assign is_hit_buffer and target_pc_buffer.
	always_comb begin
		if((TAGS[if_pc_sel] == if_pc_tag)) begin
			is_hit_buffer	 = 1;
			target_pc_buffer = {if_pc_i[63:`BTB_VAL_W+2], VALS[if_pc_sel], if_pc_tag[1:0]};
			is_cond_buffer	 = CONDS[if_pc_sel];
		end else begin
			is_hit_buffer	 = 0;
			target_pc_buffer = 0;
			is_cond_buffer	 = 0;
		end
	end

	// Comb assign is_hit_o and target_pc_o.
	always_comb begin
		if (ex_is_br_i && (if_pc_i == ex_pc_i)) begin
			if(ex_is_taken_i) begin 
				is_hit_o	=  1'b1;	// If 0 then the DIRP is disabled and PC+4(not taken) is automatically chosen.	
				target_pc_o =  ex_br_target_i;
				is_cond_o   =  ex_is_cond_i;
			end else begin
				is_hit_o	=  0;
                target_pc_o =  0;
                is_cond_o   =  0;
			end
		end else begin
			is_hit_o	= is_hit_buffer;
			target_pc_o = target_pc_buffer;
			is_cond_o	= is_cond_buffer;
		end
	end
	

	// Writing part.
	// Seq write TAGS and VALS
	always_ff @(posedge clk) begin
		if (rst) begin
			TAGS <= `SD 0;
			VALS <= `SD 0;
			CONDS <= `SD 0;
		end else if (ex_is_br_i && ex_is_taken_i) begin
			TAGS[ex_pc_sel] <= `SD ex_pc_tag;
			VALS[ex_pc_sel] <= `SD ex_target_val;
			CONDS[ex_pc_sel] <= `SD ex_is_cond_i;
		end else begin
			TAGS <= `SD TAGS;
			VALS <= `SD VALS;
			CONDS <= `SD CONDS;
		end
	end

endmodule
