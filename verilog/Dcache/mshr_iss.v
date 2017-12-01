// ****************************************************************************
// Filename: mshr_iss.v
// Discription: Miss Status Holding Register for non-blocking D-cache controller
// 				for request issue
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/19/2017
// ****************************************************************************

module mshr_iss (
		input											clk,
		input											rst,

		input											mshr_iss_alloc_en_i,
		input			[`DCACHE_TAG_W-1:0]				mshr_iss_tag_i,
		input			[`DCACHE_IDX_W-1:0]				mshr_iss_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_data_i,
		input	message_t								mshr_iss_message_i,

		input											mshr_iss_ack_i,
		output	logic									mshr_iss_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_iss_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_iss_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_data_o,
		output	message_t								mshr_iss_message_o,
		output	logic	[`MSHR_IDX_W-1:0]				mshr_iss_head_o,

		input			[`DCACHE_TAG_W-1:0]				lq2mshr_iss_tag_i,
		input			[`DCACHE_IDX_W-1:0]				lq2mshr_iss_idx_i,
		output	logic									mshr_iss_lq_hit_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_lq_hit_data_o,
		output	message_t								mshr_iss_lq_hit_message_o,
		output	logic									mshr_iss_full_o
	);

	// registers
	logic	[`MSHR_NUM-1:0]								vld_r;
	logic	[`MSHR_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_r;
	logic	[`MSHR_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_r;
	logic	[`MSHR_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_r;
	message_t	[`MSHR_NUM-1:0]							message_r;

	logic	[`MSHR_NUM-1:0]								vld_r_nxt;
	logic	[`MSHR_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_r_nxt;
	logic	[`MSHR_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_r_nxt;
	logic	[`MSHR_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_r_nxt;
	message_t	[`MSHR_NUM-1:0]							message_r_nxt;

	// pointers: tail_r is for allocate, head_r is for issue
	logic	[`MSHR_IDX_W-1:0]							head_r;
	logic	[`MSHR_IDX_W-1:0]							tail_r;
	logic												head_msb_r;
	logic												tail_msb_r;

	logic	[`MSHR_IDX_W-1:0]							head_r_nxt;
	logic	[`MSHR_IDX_W-1:0]							tail_r_nxt;
	logic												head_msb_r_nxt;
	logic												tail_msb_r_nxt;

	//-----------------------------------------------------
	// check input if input tag and index hit on mshr !!! loop
	always_comb begin
		mshr_iss_lq_hit_o			= 1'b0;
		mshr_iss_lq_hit_data_o		= 64'h0;
		mshr_iss_lq_hit_message_o	= NONE;
		for (int i = 0; i < `MSHR_NUM; i++) begin
			if (vld_r[i] && tag_r[i] == lq2mshr_iss_tag_i && idx_r[i] == lq2mshr_iss_idx_i)
				mshr_iss_lq_hit_o			= 1'b1;
				mshr_iss_lq_hit_data_o		= data_r[i];
				mshr_iss_lq_hit_message_o	= message_r[i];
		end
	end


	//-----------------------------------------------------
	// issue logic, when entry is valid @head_r
	assign mshr_iss_en_o		= vld_r[head_r];
	assign mshr_iss_tag_o		= tag_r[head_r];
	assign mshr_iss_idx_o		= idx_r[head_r];
	assign mshr_iss_data_o		= data_r[head_r];
	assign mshr_iss_message_o	= message_r[head_r];
	assign mshr_iss_head_o		= head_r;


	//-----------------------------------------------------
	// allocate to tail pointer, and issue from head pointer
	// if issue be acknowledged, clear mshr entry
	assign mshr_iss_full_o	= (head_r == tail_r) & (head_msb_r != tail_msb_r);
	assign head_r_nxt		= (mshr_iss_ack_i) ? head_r + 1 : head_r;
	assign head_msb_r_nxt	= (mshr_iss_ack_i &&
							  (head_r == `MSHR_NUM-1)) ? ~head_msb_r : head_msb_r;
	assign tail_r_nxt		= mshr_iss_alloc_en_i ? tail_r + 1 : tail_r;
	assign tail_msb_r_nxt	= (mshr_iss_alloc_en_i &&
							  (tail_r == `MSHR_NUM-1)) ? ~tail_msb_r : tail_msb_r;

	always_comb begin
		vld_r_nxt		= vld_r;
		tag_r_nxt		= tag_r;
		idx_r_nxt		= idx_r;
		data_r_nxt		= data_r;
		message_r_nxt	= message_r;
		if (mshr_iss_alloc_en_i) begin // allocate mshr entry
			vld_r_nxt[tail_r]		= 1'b1;
			tag_r_nxt[tail_r]		= mshr_iss_tag_i;
			idx_r_nxt[tail_r]		= mshr_iss_idx_i;
			data_r_nxt[tail_r]		= mshr_iss_data_i;
			message_r_nxt[tail_r]	= mshr_iss_message_i;
		end
		if (mshr_iss_ack_i) begin // clear mshr entry
			vld_r_nxt[head_r]		= 1'b0;
			tag_r_nxt[head_r]		= `DCACHE_TAG_W'b0;
			idx_r_nxt[head_r]		= `DCACHE_IDX_W'b0;
			data_r_nxt[head_r]		= `DCACHE_WORD_IN_BITS'b0;
			message_r_nxt[head_r]	= NONE;
		end
	end
	

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			vld_r		<= `SD `MSHR_NUM'b0;
			tag_r		<= `SD {`MSHR_NUM{`DCACHE_TAG_W'h0}};
			idx_r		<= `SD {`MSHR_NUM{`DCACHE_IDX_W'b0}};
			data_r		<= `SD {`MSHR_NUM{`DCACHE_WORD_IN_BITS'b0}};
			message_r	<= `SD {`MSHR_NUM{NONE}};
			head_r		<= `SD 0;
			tail_r		<= `SD 0;
			head_msb_r	<= `SD 1'b0;
			tail_msb_r	<= `SD 1'b0;
		end else begin
			vld_r		<= `SD vld_r_nxt;
			tag_r		<= `SD tag_r_nxt;
			idx_r		<= `SD idx_r_nxt;
			data_r		<= `SD data_r_nxt;
			message_r	<= `SD message_r_nxt;
			head_r		<= `SD head_r_nxt;
			tail_r		<= `SD tail_r_nxt;
			head_msb_r	<= `SD head_msb_r_nxt;
			tail_msb_r	<= `SD tail_msb_r_nxt;
		end
	end


endmodule: mshr_iss
	