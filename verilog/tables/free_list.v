// ****************************************************************************
// Filename: free_list.v
// Discription: Free List
//				Four cases: 1. read
//								Output head immediately. Head++.
//							2. write
//								Write to tail sequentially. Tail++.
//							3. read & write & status==empty
//								Read takes writing value and output immediately.
//								Head&tail remain unmoved.
//							4. restore
//								Move head back to some point. 
// Author: Chuan Cen
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************

`define DEBUG
module free_list(
		input						clk,
		input						rst,					//|From where|
		input						dispatch_en_i,			//[Decoder]		If true, output head entry and head++
		input						retire_en_i,			//[ROB]			If true, write new retired preg to tail, and tail++
		input	[PRF_IDX_W-1:0]		retire_preg_i,			//[ROB]			New retired preg.
		input	[`BR_STATE_W-1:0]	branch_state_i,			//[ROB]			Branch prediction wrong or correct?
		input	[LRF_IDX_W-1:0]		rc_head_i,			//[Br_stack]			Recover head to some point

		`ifdef DEBUG
		output	[PRF_IDX_W-1:0]		cnt,
		output	[LRF_IDX_W-1:0]		hd,
		output  [LRF_IDX_W-1:0]		tl,
		`endif
												//|To where|
		output						free_preg_vld_o,		//[ROB, Map Table, RS]	Is output valid? // Meaning changed since 11/06 to "not empty". "1" means "not empty" and "0" vice-versa.
		output	[PRF_IDX_W-1:0]		free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
		output	[LRF_IDX_W-1:0]		free_preg_cur_head_o	//[ROB]			Current head pointer.
		);
		
		logic	[FL_NUM-1:0][PRF_IDX_W-1:0]	FL;
		logic	[PRF_IDX_W-1:0]				count;
		logic	[LRF_IDX_W-1:0]				head;
		logic	[LRF_IDX_W-1:0]				tail;
		logic								full,empty;
		logic								recover_en;

		assign recover_en	= (branch_state_i == `BR_PR_WRONG);
		assign cnt			= count;
		assign hd			= head;
		assign tl			= tail;

		assign empty		= (count == 0);
		assign full			= (count >= FL_NUM);

		assign free_preg_vld_o	=	~empty;						// Modified 11/06. This output is functioned as "not empty" instead. 
									/*~dispatch_en_i	? 0 : 
									~empty			? 1 : 
									retire_en_i		? 1 : 0;
									*/
		assign free_preg_o		=	~dispatch_en_i	? `ZERO_REG		: // Modidied by hengfei. 
									~empty			? FL[head]		:
									retire_en_i		? retire_preg_i : 0;

		assign free_preg_cur_head_o = dispatch_en_i ? head : 5'b00000;

		//write FL and tail
		always_ff @(posedge clk) begin
			if (rst) begin
				for (int i=0;i<FL_NUM;i++) begin
					FL[i] <= `SD FL_NUM+i;
				end
				tail <= `SD 0;
			end else if (retire_en_i && ~(empty && dispatch_en_i) /*&& ~full*/) begin	// Modified 11/06. No need to check full or not. 
				tail <=	`SD (tail + 1 >= FL_NUM) ? (tail - FL_NUM - 1) : (tail + 1);
				FL[tail] <= `SD retire_preg_i;
			end else begin
				tail <= `SD tail;
			end
		end
		
		//write head
		always_ff @(posedge clk) begin
			if (rst) begin
				head <= `SD 0;
			end else if (dispatch_en_i /*&& ~empty*/) begin		// Modified 11/06. No need to check empty or not. 
				head <= `SD (head + 1 >= FL_NUM) ? (head + 1 - FL_NUM) : (head + 1);
			end else if (recover_en) begin
				head <= `SD rc_head_i;
			end else begin
				head <= `SD head;
			end
		end

		//write count
		always_ff @(posedge clk) begin
			if (rst) begin
				count <= `SD FL_NUM;
			end else if (dispatch_en_i && ~retire_en_i) begin
				count <= `SD count - 1;
			end else if (~dispatch_en_i && retire_en_i) begin
				count <= `SD count + 1;
			end else begin
				count <= `SD count;
			end
		end

endmodule
