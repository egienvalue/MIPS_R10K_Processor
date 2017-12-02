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
// 	<11/14> remove count, fifo full empty signal should rely on pointer
// 	itself.
// 	***************************************************************************

//`define FL_DEBUG
module free_list(
		input						clk,
		input						rst,					//|From where|
		input						dispatch_en_i,			//[Decoder]		If true, output head entry and head++
		input						retire_en_i,			//[ROB]			If true, write new retired preg to tail, and tail++
		input	[`PRF_IDX_W-1:0]	retire_preg_i,			//[ROB]			New retired preg.
		input	[`BR_STATE_W-1:0]	branch_state_i,			//[ROB]			Branch prediction wrong or correct?
		input	[`FL_PTR_W:0]		rc_head_i,			//[Br_stack]			Recover head to some point

		//`ifdef FL_DEBUG
		//output	[`PRF_IDX_W-1:0]	cnt,
		//output	[`LRF_IDX_W-1:0]	hd,
		//output  [`LRF_IDX_W-1:0]	tl,
		//`endif
												//|To where|
		output						free_preg_vld_o,		//[ROB, Map Table, RS]	Is output valid? // Meaning changed since 11/06 to "not empty". "1" means "not empty" and "0" vice-versa.
		output	[`PRF_IDX_W-1:0]	free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
		output	[`FL_PTR_W:0]		free_preg_cur_head_o	//[ROB]			Current head pointer.
		);
		
		logic	[`FL_NUM-1:0][`PRF_IDX_W-1:0]	FL;
		//logic	[`LRF_IDX_W-1:0]				count;
		logic	[`FL_PTR_W-1:0]					head;
		logic	[`FL_PTR_W-1:0]					tail;
		logic									head_msb;
		logic									tail_msb;

		logic	[`FL_PTR_W:0]					head_conc_nxt;
		logic	[`FL_PTR_W:0]					tail_conc_nxt;

		logic									full,empty;
		logic									recover_en;

		assign recover_en	= (branch_state_i == `BR_PR_WRONG);
		
		//`ifdef FL_DEBUG
		//assign cnt			= count;
		//assign hd			= head;
		//assign tl			= tail;
		//`endif

		assign empty		= (head == tail) && (head_msb != tail_msb);
		assign full			= (head == tail) && (head_msb == tail_msb);

		assign free_preg_vld_o	=	~empty;	// Modified 11/06. This output is functioned as "not empty" instead. 
									/*~dispatch_en_i	? 0 : 
									~empty			? 1 : 
									retire_en_i		? 1 : 0;
									*/
		assign free_preg_o		=	~dispatch_en_i	? `ZERO_REG		: // Modidied by hengfei. 
									~empty			? FL[head]		:
									retire_en_i		? retire_preg_i : 0;

		//assign free_preg_cur_head_o = dispatch_en_i ? head : 5'b00000;
		assign free_preg_cur_head_o = head_conc_nxt; //<12/2> {head_msb,head};

		assign head_conc_nxt = recover_en ? rc_head_i : 
							   dispatch_en_i ? {head_msb,head} + 1 : {head_msb,head};
		assign tail_conc_nxt = (retire_en_i && retire_preg_i != 6'd31) ? {tail_msb,tail} + 1 : {tail_msb,tail};
		

		//write FL
		always_ff @(posedge clk) begin
			if (rst) begin
				for (int i=0;i<`FL_NUM;i++) begin
					FL[i] <= `SD `FL_NUM+i;
				end
			end else if (retire_en_i && retire_preg_i != 6'd31/*&& ~full*/) begin	// Modified 11/06. No need to check full or not. 
				FL[tail] <= `SD retire_preg_i;
			end
		end
		
		// read head ptr and write tail ptr update
		// synopsys sync_set_reset "rst"
		always_ff @(posedge clk) begin
			if (rst) begin
				{head_msb, head}	<= `SD 0;
				{tail_msb, tail}	<= `SD 0;
			end else begin
				{head_msb, head}	<= `SD head_conc_nxt;
				{tail_msb, tail}	<= `SD tail_conc_nxt;
			end
		end

/*		//write count
		always_ff @(posedge clk) begin
			if (rst) begin
				count <= `SD `FL_NUM-1;
			end else if (dispatch_en_i && ~retire_en_i) begin
				count <= `SD count - 1;
			end else if (~dispatch_en_i && retire_en_i) begin
				count <= `SD count + 1;
			end else begin
				count <= `SD count;
			end
		end
*/

endmodule
