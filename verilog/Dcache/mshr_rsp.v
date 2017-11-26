// ****************************************************************************
// Filename: mshr_rsp.v
// Discription: Miss Status Holding Register for non-blocking D-cache controller
// 				dealing with response message and data
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/19/2017
// ****************************************************************************

module mshr_rsp (
		input											clk,
		input											rst,

		input			[`DCACHE_TAG_W-1:0]				lq2mshr_rsp_tag_i,
		input			[`DCACHE_IDX_W-1:0]				lq2mshr_rsp_idx_i,
		input			[`DCACHE_TAG_W-1:0]				sq2mshr_rsp_tag_i,
		input			[`DCACHE_IDX_W-1:0]				sq2mshr_rsp_idx_i,

		input											mshr_rsp_alloc_en_i,
		input			[`DCACHE_TAG_W-1:0]				mshr_rsp_tag_i,
		input			[`DCACHE_IDX_W-1:0]				mshr_rsp_idx_i,
		input	message_t								mshr_rsp_message_i,
		input			[`MSHR_IDX_W-1:0]				mshr_rsp_iss_head_i,
		
		input											mshr_rsp_ack_i,
		output	logic									mshr_rsp_wr_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_rsp_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_rsp_idx_o,
		output	message_t								mshr_rsp_message_o,
		output	logic	[`MSHR_IDX_W-1:0]				mshr_rsp_iss_head_o,

		output	logic									mshr_rsp_lq_hit_o,
		output	logic									mshr_rsp_lq_fwd_o,
		output	logic									mshr_rsp_sq_hit_o,
		output	logic									mshr_rsp_full_o
	);

	logic	[`MSHR_NUM-1:0]								vld_r;
	logic	[`MSHR_NUM-1:0][`MSHR_IDX_W-1:0]			iss_head_r;
	logic	[`MSHR_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_r;
	logic	[`MSHR_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_r;
	message_t	[`MSHR_NUM-1:0]							message_r;

	logic	[`MSHR_NUM-1:0]								vld_r_nxt;
	logic	[`MSHR_NUM-1:0][`MSHR_IDX_W-1:0]			iss_head_r_nxt;
	logic	[`MSHR_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_r_nxt;
	logic	[`MSHR_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_r_nxt;
	message_t	[`MSHR_NUM-1:0]							message_r_nxt;

	// pointers: tail_r is for allocate, head_r is for release
	logic	[`MSHR_IDX_W-1:0]							head_r;
	logic	[`MSHR_IDX_W-1:0]							tail_r;
	logic												head_msb_r;
	logic												tail_msb_r;

	logic	[`MSHR_IDX_W-1:0]							head_r_nxt;
	logic	[`MSHR_IDX_W-1:0]							tail_r_nxt;
	logic												head_msb_r_nxt;
	logic												tail_msb_r_nxt;

	//-----------------------------------------------------
	// check input if input tag and index hit on mshr
	always_comb begin
		mshr_rsp_lq_hit_o	= 1'b0;
		mshr_rsp_lq_fwd_o	= 1'b0;
		for (int i = 0; i < `MSHR_NUM; i++) begin
			if (vld_r[i] && tag_r[i] == lq2mshr_rsp_tag_i &&
				idx_r[i] == lq2mshr_rsp_idx_i)
				mshr_rsp_lq_hit_o = 1'b1;
				mshr_rsp_lq_fwd_o = (head_r == i);
		end
	end

	always_comb begin
		mshr_rsp_sq_hit_o	= 1'b0;
		for (int i = 0; i < `MSHR_NUM; i++) begin
			if (vld_r[i] && tag_r[i] == sq2mshr_rsp_tag_i &&
				idx_r[i] == lq2mshr_rsp_idx_i)
				mshr_rsp_sq_hit_o = 1'b1;
		end
	end

	//-----------------------------------------------------
	// response logic, when entry is valid @head_r
	assign mshr_rsp_wr_en_o		= mshr_rsp_ack_i;
	assign mshr_rsp_tag_o		= tag_r[head_r];
	assign mshr_rsp_idx_o		= idx_r[head_r];
	assign mshr_rsp_message_o	= message_r[head_r];
	assign mshr_rsp_iss_head_o	= iss_head_r[head_r];

	
	//-----------------------------------------------------
	// allocate to tail pointer, and release from head pointer
	// if response be acknowledged, clear mshr entry
	assign mshr_rsp_full_o = (head_r == tail_r) & (head_msb_r != tail_msb_r);
	assign head_r_nxt		= mshr_rsp_ack_i ? head_r + 1 : head_r;
	assign head_msb_r_nxt	= (mshr_rsp_ack_i &&
							  (head_r == `MSHR_NUM-1)) ? ~head_msb_r : head_msb_r;
	assign tail_r_nxt		= mshr_rsp_alloc_en_i ? tail_r + 1 : tail_r;
	assign tail_msb_r_nxt	= (mshr_rsp_alloc_en_i &&
							  (tail_r == `MSHR_NUM-1)) ? ~tail_msb_r : tail_msb_r;

	always_comb begin
		vld_r_nxt		= vld_r;
		tag_r_nxt		= tag_r;
		idx_r_nxt		= idx_r;
		message_r_nxt	= message_r;
		iss_head_r_nxt	= iss_head_r;
		if (mshr_rsp_alloc_en_i) begin // allocate mshr entry
			vld_r_nxt[tail_r]		= 1'b1;
			tag_r_nxt[tail_r]		= mshr_rsp_tag_i;
			idx_r_nxt[tail_r]		= mshr_rsp_idx_i;
			message_r_nxt[tail_r]	= mshr_rsp_message_i;
			iss_head_r_nxt[tail_r]	= mshr_rps_iss_head_i;
		end
		if (mshr_rsp_ack_i) begin // clear mshr entry
			vld_r_nxt[head_r]		= 1'b0;
			tag_r_nxt[head_r]		= `DCACHE_TAG_W'b0;
			idx_r_nxt[head_r]		= `DCACHE_IDX_W'b0;
			message_r_nxt[head_r]	= NONE;
			iss_head_r_nxt[head_r]	= `MSHR_IDX_W'b0;
		end
	end


	// synopsys sync_set_reset "rst"
	always_ff (posedge clk) begin
		if (rst) begin
			vld_r		<= `SD `MSHR_NUM'b0;
			tag_r		<= `SD {`MSHR_NUM{`DCACHE_TAG_W'b0}};
			idx_r		<= `SD {`MSHR_NUM{`DCACHE_IDX_W'b0}};
			message_r	<= `SD {`MSHR_NUM{NONE}};
			iss_head_r	<= `SD {`MSHR_NUM{`MSHR_IDX_W'b0}};
			head_r		<= `SD `MSHR_IDX_W'b0;
			tail_r		<= `SD `MSHR_IDX_W'b0;
			head_msb_r	<= `SD 1'b0;
			tail_msb_r	<= `SD 1'b0;
		end else begin
			vld_r		<= `SD vld_r_nxt;
			tag_r		<= `SD tag_r_nxt;
			idx_r		<= `SD idx_r_nxt;
			message_r	<= `SD message_r_nxt;
			iss_head_r	<= `SD iss_head_r_nxt;
			head_r		<= `SD head_r_nxt;
			tail_r		<= `SD tail_r_nxt;
			head_msb_r	<= `SD head_msb_r_nxt;
			tail_msb_r	<= `SD tail_msb_r_nxt;
		end
	end


endmodule: mshr_rsp

