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
// 	***************************************************************************


module branch_stack(
		input						clk, 
		input						rst,
														//From where
		input						is_branch_i,		//[Dispatch]	A new branch is dispatched, mask should be updated.
		input	[`BR_STATE_W-1:0]	branch_state_i,		//[ROB]			Branch prediction wrong or correct?		
		input	[`BR_MASK_W-1:0]	branch_dep_mask_i,	//[ROB]			The mask of currently resolved branch.
		input	[31:0][5:0]			bak_mp_next_data_i,	//[Map Table]	Back up data from map table.
		input	[4:0]				bak_fl_head_i,		//[Free List]	Back up head of free list.
														//To where
		output	[`BR_MASK_W-1:0]	branch_mask_o,		//[ROB]			Send current mask value to ROB to save in an ROB entry.
		output	[`BR_MASK_W-1:0]	branch_bit_o,		//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
		output	[31:0][5:0]			rc_mt_all_data_o,	//[Map Table]	Recovery data for map table.
		output	[4:0]				rc_fl_head_o,		//[Free List]	Recovery head value for free list.
		output						full_o				//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
		);

		task first_zero_idx;							// Task finding the first zero in a mask
			input	[`BR_MASK_W-1:0]	br_mask;
			output	[3:0]				idx;			// Return the index of the first zero (example:4'b0010)
			output	[`BR_MASK_W-1:0]	br_bit;			// Return an bit array in one-hot style (example:5'b00010)
			begin
				for (int i=0;i<`BR_MASK_W;i++) begin
					if (br_mask[i] == 0) begin
						idx = i;
						break;
					end
				end
				br_bit = `BR_MASK_W'b1 << idx;
			end
		endtask

		logic	[`BR_MASK_W-1:0]			mask;						// Mask
		logic	[`BR_MASK_W-1:0][31:0][5:0]	map_table_stack;			// Branch Stack
		logic	[`BR_MASK_W-1:0][4:0]		fl_head_stack;
		logic	[`BR_MASK_W-1:0]			next_mask;					// Next mask
		logic	[3:0]						branch_bit_idx,	temp_bit_idx;           // Branch bit index number
		logic 	[`BR_MASK_W-1:0]			branch_bit, temp_bit;		// branch_bit_o intermedia variable
		logic								full;

		assign full = (mask == {`BR_MASK_W{1'b1}}) ? 1:0;
		assign full_o = full;
		assign branch_mask_o = mask;									// Assign current branch mask output
		assign branch_bit_o = branch_bit;
		assign rc_mt_all_data_o = (branch_state_i == `BR_PR_WRONG) ? map_table_stack[branch_bit_idx] : 0;		// Assign output data if wrong. 
		assign rc_fl_head_o = (branch_state_i == `BR_PR_WRONG) ? fl_head_stack[branch_bit_idx] : 0;

		always_comb begin									// Assign branch_bit_idx and next_mask. Assign next_mask under the condition of branch_state_i (wrong or correct?)
			if (branch_state_i == `BR_PR_WRONG) begin
				first_zero_idx(branch_dep_mask_i, branch_bit_idx, branch_bit); 
				next_mask = branch_dep_mask_i;
			end else if (branch_state_i == `BR_PR_CORRECT && ~is_branch_i) begin
				first_zero_idx(branch_dep_mask_i, branch_bit_idx, branch_bit); 
				next_mask = mask ^ branch_bit;				
			end else if (branch_state_i == `BR_PR_CORRECT && is_branch_i) begin
				first_zero_idx(branch_dep_mask_i, branch_bit_idx, branch_bit); 
				first_zero_idx(mask ^ branch_bit, temp_bit_idx, temp_bit); 
				next_mask = mask ^ branch_bit ^ temp_bit);
			end else if (is_branch_i&&~full) begin
				first_zero_idx(mask, temp_bit_idx, temp_bit);
				next_mask = mask ^ temp_bit;
			end else begin
				next_mask = mask;
			end
		end
		
		always_ff@(posedge clk) begin						// Always fresh copies whose mask is 0
			if (rst) begin
				map_table_stack <= `SD 0;
				fl_head_stack <= `SD 0;
			end else begin
				for (int i=0;i<`BR_MASK_W;i++) begin
					if (mask[i] == 0) begin
						map_table_stack[i] <= `SD bak_mp_next_data_i;
						fl_head_stack[i] <= `SD bak_fl_head_i;
					end else begin
					end
				end
			end
		end

		always_ff @(posedge clk) begin						// Always_ff assign mask
			if (rst) begin
				mask <= `SD 0;
			end else begin
				mask <= `SD next_mask;
			end
		end

endmodule

