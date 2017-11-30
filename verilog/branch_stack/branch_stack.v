// ****************************************************************************
// Filename: branch_stack.v
// Discription: branch_stack
//				Three cases: 1.	A new branch insn is dispatched.
//								Update the current mask value to change the
//								first (low to high) '0' to '1'. 
//								*Do nothing if full. 
//								*Do updating after a branch resolved as
//								CORRECT (if any).
//							 2.	A branch resolved as WRONG.
//								Override the current mask value with the mask of
//								the wrong branch. Send the content of the 
//								corresponding copy out for data recovery.
//								*No branch dispatch would be handled at the
//								moment when wrong branch happens.
//							 3. A branch resolved as CORRECT.
//								Simple update current mask value by clearing
//								the corresponding bit.
// Author: Chuan Cen
// Version History:
// 	intial creation: 11/04/2017
// 	<11/14> added update for rdy bit after freezed
// 	***************************************************************************

module branch_stack(
		input										clk, 
		input										rst,
		input										is_br_i,			//[Dispatch]	A new branch is dispatched, mask should be updated.
		input										is_cond_i,			//[Dispatch]
		input										is_taken_i,			//[Dispatch]
		input	[`BR_STATE_W-1:0]					br_state_i,			//[ROB]			Branch prediction wrong or correct?		
		input	[`BR_MASK_W-1:0]					br_dep_mask_i,		//[ROB]			The mask of currently resolved branch.
		input	[`MT_NUM-1:0][`PRF_IDX_W:0]			bak_mp_next_data_i,	//[Map Table]	Back up data from map table.
		input	[`FL_PTR_W:0]						bak_fl_head_i,		//[Free List]	Back up head of free list.

		// <11/14>
		input										cdb_vld_i,
		input	[`PRF_IDX_W-1:0]					cdb_tag_i,
		
		output	logic	[`BR_MASK_W-1:0]			br_mask_o,			//[ROB]			Send current mask value to ROB to save in an ROB entry.
		output	logic	[`BR_MASK_W-1:0]			br_bit_o,			//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
		output	logic								full_o,				//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
		output	logic	[`MT_NUM-1:0][`PRF_IDX_W:0]	rc_mt_all_data_o,	//[Map Table]	Recovery data for map table.
		output	logic	[`FL_PTR_W:0]				rc_fl_head_o		//[Free List]	Recovery head value for free list.
	);


	logic [`BR_MASK_W-1:0]								br_mask;

	logic [`BR_MASK_W-1:0][`MT_NUM-1:0][`PRF_IDX_W:0]	unslctd_mt_data;
	logic [`BR_MASK_W-1:0][`FL_PTR_W:0]					unslctd_fl_data;

	assign br_mask_o = br_mask;

	// This is a Selector. Select one stack data out when predict wrong.
	always_comb begin
		rc_mt_all_data_o =	0;
        rc_fl_head_o	 =	0;
		if (br_state_i == `BR_PR_WRONG) begin
			for (int i=0;i<`BR_MASK_W;i++) begin
				if (br_bit_o[i] == 1) begin
					rc_mt_all_data_o = unslctd_mt_data[i];
					rc_fl_head_o	 = unslctd_fl_data[i];
					//break;
				end
			end
		end else begin
			rc_mt_all_data_o =	0;
            rc_fl_head_o	 =	0;
		end
	end
		
	br_mask_ctrl br_mask_ctrl0(
		.clk(clk), 
    	.rst(rst),
    	.is_br_i(is_br_i),
		.is_cond_i(is_cond_i),
		.is_taken_i(is_taken_i),
    	.br_state_i(br_state_i),		
    	.br_dep_mask_i(br_dep_mask_i),	
    	.br_mask_o(br_mask),		
    	.br_bit_o(br_bit_o),		
    	.full_o(full_o)
	);

	br_stack_ent bse [`BR_MASK_W-1:0] (
		.clk(clk),
        .rst(rst),
        .mask_bit_i(br_mask),

		.cdb_vld_i	(cdb_vld_i),
		.cdb_tag_i	(cdb_tag_i),
		
        .bak_mp_next_data_i(bak_mp_next_data_i),	
        .bak_fl_head_i(bak_fl_head_i),
        .rc_mt_all_data_o(unslctd_mt_data),	
        .rc_fl_head_o(unslctd_fl_data)
	);

endmodule
