// ****************************************************************************
// Filename: br_mask_ctrl.v
// Discription: branch mask controller
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


module br_mask_ctrl(
		input						clk, 
		input						rst,
		input						is_br_i,		//[Dispatch]	A new branch is dispatched, mask should be updated.
		input	[`BR_STATE_W-1:0]	br_state_i,		//[ROB]			Branch prediction wrong or correct?		
		input	[`BR_MASK_W-1:0]	br_dep_mask_i,	//[ROB]			The mask of currently resolved branch.
		
		output	[`BR_MASK_W-1:0]	br_mask_o,		//[ROB][Stacks]			Send current mask value to ROB to save in an ROB entry.
		output	[`BR_MASK_W-1:0]	br_bit_o,		//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
		output						full_o			//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
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
		logic	[`BR_MASK_W-1:0]			next_mask;					// Next mask
		logic	[3:0]						br_bit_idx,	temp_bit_idx;	// Branch bit index number
		logic 	[`BR_MASK_W-1:0]			br_bit, temp_bit;			// in which "br_bit" is assigned to br_bit_o. 
		logic								full;

		assign full = (mask == {`BR_MASK_W{1'b1}}) ? 1:0;
		assign full_o = full;
		assign br_mask_o = mask;										// Assign current branch mask output
		assign br_bit_o = br_bit;

		always_comb begin												// Assign br_bit_idx and next_mask. Assign next_mask under the condition of br_state_i (wrong or correct?)
			if (br_state_i == `BR_PR_WRONG) begin
				first_zero_idx(br_dep_mask_i, br_bit_idx, br_bit); 
				next_mask = br_dep_mask_i;
			end else if (br_state_i == `BR_PR_CORRECT && ~is_br_i) begin
				first_zero_idx(br_dep_mask_i, br_bit_idx, br_bit); 
				next_mask = mask ^ br_bit;				
			end else if (br_state_i == `BR_PR_CORRECT && is_br_i) begin
				first_zero_idx(br_dep_mask_i, br_bit_idx, br_bit); 
				first_zero_idx(mask ^ br_bit, temp_bit_idx, temp_bit); 
				next_mask = mask ^ br_bit ^ temp_bit);
			end /*else if (is_br_i&&~full) begin
				first_zero_idx(mask, temp_bit_idx, temp_bit);
				next_mask = mask ^ temp_bit;
			end */else begin
				next_mask = mask;
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

