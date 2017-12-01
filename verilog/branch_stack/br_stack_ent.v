// ****************************************************************************
// Filename: br_stack_ent.v
// Discription: branch stack entry. 
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
// 	<11/14> ready bit in check point should update along with map table,
// 	according to cdb_tag
// 	***************************************************************************




module br_stack_ent(
		input								clk,
		input								rst,
		input								mask_bit_i,
		input								cdb_vld_i,
		input	[`PRF_IDX_W-1:0]			cdb_tag_i,
		input	[`MT_NUM-1:0][`PRF_IDX_W:0]	bak_mp_next_data_i,	//[Map Table]	Back up data from map table.
		input	[`FL_PTR_W:0]				bak_fl_head_i,		//[Free List]	Back up head of free list.
		input	[`LSQ_P_W-1:0]				bak_lsq_p_i,

		output	[`MT_NUM-1:0][`PRF_IDX_W:0]	rc_mt_all_data_o,	//[Map Table]	Recovery data for map table.
		output	[`FL_PTR_W:0]				rc_fl_head_o,		//[Free List]	Recovery head value for free list.
		output	[`LSQ_P_W-1:0]				rc_lsq_p_o
	);

	logic	[`MT_NUM-1:0][`PRF_IDX_W:0]		map_table_stack, fixed_nxt_mts;			// Branch Stack
	logic	[`FL_PTR_W:0]					fl_head_stack, fixed_nxt_fhs;
	logic	[`LSQ_P_W-1:0]					lsq_p_stack, fixed_nxt_lsqp;

	assign rc_mt_all_data_o = map_table_stack; 
	assign rc_fl_head_o		= fl_head_stack; 
	assign rc_lsq_p_o		= lsq_p_stack;

	assign fixed_nxt_mts	= map_table_stack;
	assign fixed_nxt_fhs	= fl_head_stack;
	assign fixed_nxt_lsqp	= lsq_p_stack;

	always_ff@(posedge clk) begin						// Always fresh copies whose mask is 0
		if (rst) begin
			map_table_stack	<= `SD 0;
			fl_head_stack	<= `SD 0;
			lsq_p_stack		<= `SD 0;
		end else if (mask_bit_i == 1'b0) begin
			map_table_stack	<= `SD bak_mp_next_data_i;
			fl_head_stack	<= `SD bak_fl_head_i;
			lsq_p_stack		<= `SD bak_lsq_p_i;
		end else if (cdb_vld_i) begin // if fixed, update matched tag's rdy bit
			for (int i = 0; i < `MT_NUM; i++) begin
				if (cdb_tag_i == map_table_stack[i][`PRF_IDX_W-1:0])
					map_table_stack[i][`PRF_IDX_W] <= `SD 1'b1;
			end
		end
	end

endmodule

