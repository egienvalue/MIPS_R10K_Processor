// ****************************************************************************
// Filename: Dcache_ctrl.v
// Discription: D-cache controller, support cache coherence, instantiate MSHR
// 				here
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/23/2017
// ****************************************************************************

module Dcache_ctrl (
		input											clk,
		input											rst,

		input											Dctrl_cpu_id_i,

		input											lq2Dctrl_en_i,
		input			[63:0]							lq2Dctrl_addr_i,
		output	logic									Dctrl2lq_ack_o,
		output	logic									Dctrl2lq_data_vld_o,
		output	logic									Dctrl2lq_mshr_data_vld_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dctrl2lq_data_o,

		input											sq2Dctrl_en_i,
		input			[63:0]							sq2Dctrl_addr_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		sq2Dctrl_data_i,
		output	logic									Dctrl2sq_ack_o,

		input											Dcache_sq_wr_hit_i,
		input											Dcache_sq_wr_dty_i,
		input			[`DCACHE_TAG_W-1:0]				Dcache_sq_wb_tag_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		Dcache_sq_wb_data_i,
		output	logic									Dcache_sq_wr_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache_sq_wr_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_sq_wr_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache_sq_wr_data_o,

		input			[`DCACHE_TAG_W-1:0]				Dcache_lq_rd_tag_i,
		input			[`DCACHE_IDX_W-1:0]				Dcache_lq_rd_data_i,
		input											Dcache_lq_rd_dty_i,
		input											Dcache_lq_rd_hit_i,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache_lq_rd_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_lq_rd_idx_o,

		// to cachemem
		output	logic									mshr_rsp_wr_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_rsp_wr_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_rsp_wr_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_rsp_wr_data_o,

		// from/to cachemem
		input											mshr_iss_hit_i,
		input											mshr_iss_dty_i,
		output	logic									mshr_iss_st_en_o,
		output	logic									mshr_iss_evict_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_iss_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_iss_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_data_o,

		// from/to cachemem bus signals
		input			[`DCACHE_WORD_IN_BITS-1:0]		Dcache_bus_data_i,
		input											Dcache_bus_hit_i,
		output	logic									Dcache_bus_invld_o,
		output	logic									Dcache_bus_downgrade_o,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache_bus_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_bus_idx_o,

		// Dctrl/bus request signals
		input											bus2Dctrl_req_ack_i,
		input											bus2Dctrl_req_id_i,
		input			[`DCACHE_TAG_W-1:0]				bus2Dctrl_req_tag_i,
		input			[`DCACHE_IDX_W-1:0]				bus2Dctrl_req_idx_i,
		input	message_t								bus2Dctrl_req_message_i,
		output	logic									Dctrl2bus_req_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				Dctrl2bus_req_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dctrl2bus_req_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dctrl2bus_req_data_o,
		output	message_t								Dctrl2bus_req_message_o,

		// Dctrl/bus response signals
		input											bus2Dctrl_rsp_vld_i,
		input											bus2Dctrl_rsp_id_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		bus2Dctrl_rsp_data_i,
		output	logic									Dctrl2bus_rsp_vld_o,
		//output	logic	[`DCACHE_TAG_W-1:0]				Dctrl2bus_rsp_tag_o,
		//output	logic	[`DCACHE_IDX_W-1:0]				Dctrl2bus_rsp_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dctrl2bus_rsp_data_o
	);

	// signals for mshr_iss
	logic									mshr_iss_alloc_en;
	logic		[`DCACHE_TAG_W-1:0]			mshr_iss_tag_i;
	logic		[`DCACHE_IDX_W-1:0]			mshr_iss_idx_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	mshr_iss_data_i;
	message_t								mshr_iss_message_i;
	logic									mshr_iss_ack;

	logic									mshr_iss_en;
	logic									mshr_iss_st_en;
	logic									mshr_iss_evict_en;
	message_t								mshr_iss_message_o;
	logic		[`MSHR_IDX_W-1:0]			mshr_iss_head;
	logic									mshr_iss_hit;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	mshr_iss_hit_data;
	message_t								mshr_iss_hit_message;
	logic									mshr_iss_full;

	logic									ld_alloc_wait_r;
	logic									st_alloc_wait_r;
	logic									ld_alloc_wait_r_nxt;
	logic									st_alloc_wait_r_nxt;

	// signals for mshr_rsp
	logic		[`DCACHE_TAG_W-1:0]			lq2mshr_rsp_tag;
	logic		[`DCACHE_IDX_W-1:0]			lq2mshr_rsp_idx;
	logic		[`DCACHE_TAG_W-1:0]			sq2mshr_rsp_tag;
	logic		[`DCACHE_IDX_W-1:0]			sq2mshr_rsp_idx;

	logic									mshr_rsp_alloc_en;
	logic		[`MSHR_IDX_W-1:0]			mshr_rsp_iss_head_i;

	logic									mshr_rsp_ack;
	logic									mshr_rsp_wr_en;

	logic		[`MSHR_IDX_W-1:0]			mshr_rsp_iss_head_o;
	logic									mshr_rsp_lq_hit;
	logic									mshr_rsp_lq_fwd;
	logic									mshr_rsp_sq_hit;
	logic									mshr_rsp_full;


	mshr_iss (
		.clk					(clk),
		.rst					(rst),

		.mshr_iss_alloc_en_i	(mshr_iss_alloc_en),
		.mshr_iss_tag_i			(mshr_iss_tag_i),
		.mshr_iss_idx_i			(mshr_iss_idx_i),
		.mshr_iss_data_i		(mshr_iss_data_i),
		.mshr_iss_message_i		(mshr_iss_message_i),

		.mshr_iss_ack_i			(mshr_iss_ack),
		.mshr_iss_hit_i			(mshr_iss_hit_i),
		.mshr_iss_dty_i			(mshr_iss_dty_i),
		.mshr_iss_en_o			(mshr_iss_en),
		.mshr_iss_st_en_o		(mshr_iss_st_en),
		.mshr_iss_evict_en_o	(mshr_iss_evict_en),
		.mshr_iss_tag_o			(mshr_iss_tag_o),
		.mshr_iss_idx_o			(mshr_iss_idx_o),
		.mshr_iss_data_o		(mshr_iss_data_o),
		.mshr_iss_message_o		(mshr_iss_message_o),
		.mshr_iss_head_o		(mshr_iss_head),

		.mshr_iss_hit_o			(mshr_iss_hit),
		.mshr_iss_hit_data_o	(mshr_iss_hit_data),
		.mshr_iss_hit_message_o	(mshr_iss_hit_message),
		.mshr_iss_full_o		(mshr_iss_full)
	);

	mshr_rsp (
		.clk					(clk),
		.rst					(rst),

		.lq2mshr_rsp_tag_i		(lq2mshr_rsp_tag),
		.lq2mshr_rsp_idx_i		(lq2mshr_rsp_idx),
		.sq2mshr_rsp_tag_i		(sq2mshr_rsp_tag),
		.sq2mshr_rsp_idx_i		(sq2mshr_rsp_idx),

		.mshr_rsp_alloc_en_i	(mshr_rsp_alloc_en),
		.mshr_rsp_tag_i			(mshr_iss_tag_o),
		.mshr_rsp_idx_i			(mshr_iss_idx_o),
		.mshr_rsp_message_i		(mshr_iss_message_o),
		.mshr_rsp_iss_head_i	(mshr_rsp_iss_head_i),
		
		.mshr_rsp_ack_i			(mshr_rsp_ack),
		.mshr_rsp_wr_en_o		(mshr_rsp_wr_en),
		.mshr_rsp_tag_o			(mshr_rsp_tag_o),
		.mshr_rsp_idx_o			(mshr_rsp_idx_o),
		.mshr_rsp_message_o		(mshr_rsp_message_o),
		.mshr_rsp_iss_head_o	(mshr_rsp_iss_head_o),

		.mshr_rsp_lq_hit_o		(mshr_rsp_lq_hit),
		.mshr_rsp_lq_fwd_o		(mshr_rsp_lq_fwd),
		.mshr_rsp_sq_hit_o		(mshr_rsp_sq_hit),
		.mshr_rsp_full_o		(mshr_rsp_full)
	);

	//-----------------------------------------------------
	// Dctrl to lq load signals
	Dctrl2lq_data_vld_o		 = Dcache_lq_rd_hit_i | (mshr_iss_hit && mshr_iss_hit_message == GET_M) |
							  (mshr_rsp_lq_fwd && mshr_rsp_wr_en);
	Dctrl2lq_mshr_data_vld_o = mshr_rsp_wr_en;
	Dctrl2lq_data_o			 = Dctrl2lq_mshr_data_vld_o ? bus2Dctrl_rsp_data_i : 
							   (mshr_iss_hit && mshr_iss_hit_message == GET_M) ? mshr_iss_hit_data : 
							   (Dcache_lq_rd_hit_i) ? Dcache_lq_rd_data_i : 64'h0;

	//-----------------------------------------------------
	// Dctrl to Dcache sq store signals
	assign Dcache_sq_wr_en_o	= sq2Dctrl_en_i && Dcache_sq_wr_hit_i && Dcache_sq_wr_dty_i;
	assign Dcache_sq_wr_tag_o	= sq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign Dcache_sq_wr_idx_o	= sq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	assign Dcache_sq_wr_data_o	= sq2Dctrl_data_i;

	//-----------------------------------------------------
	// Dctrl to Dcache lq load signals
	assign Dcache_lq_rd_tag_o	= lq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign Dcache_lq_rd_idx_o	= lq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];

	//-----------------------------------------------------
	// Dctrl to Dcache bus request signals
	assign Dcache_bus_invld_o		= (bus2Dctrl_req_id_i != Dctrl_cpu_id_i) && 
									  (bus2Dctrl_req_message_i == GET_M);
	assign Dcache_bus_downgrade_o	= (bus2Dctrl_req_id_i != Dctrl_cpu_id_i) && 
									  (bus2Dctrl_req_message_i == GET_S);
	assign Dcache_bus_tag_o			= bus2Dctrl_req_tag_i;
	assign Dcache_bus_idx_o			= bus2Dctrl_req_idx_i;


	//-----------------------------------------------------
	// mshr_rsp to Dcache write signals
	assign mshr_rsp_wr_en_o		= mshr_rsp_wr_en;
	assign mshr_rsp_wr_tag_o	= mshr_rsp_tag_o;
	assign mshr_rsp_wr_idx_o	= mshr_rsp_idx_o;
	assign mshr_rsp_wr_data_o	= bus2Dctrl_rsp_data_i;

	//-----------------------------------------------------
	// mshr_iss to Dcache write signals
	assign mshr_iss_st_en_o		= mshr_iss_st_en;
	assign mshr_iss_evict_en_o	= mshr_iss_evict_en;

	//-----------------------------------------------------
	// request issue logic
	assign Dctrl2bus_req_en_o		= mshr_iss_en && ~mshr_rsp_full;
	assign Dctrl2bus_req_tag_o		= mshr_iss_tag_o;
	assign Dctrl2bus_req_idx_o		= mshr_iss_idx_o;
	assign Dctrl2bus_req_data_o		= mshr_iss_data_o;
	assign Dctrl2bus_req_message_o	= mshr_iss_message_o;

	//-----------------------------------------------------
	// response to other request logic
	assign Dctrl2bus_rsp_vld_o	= Dcache_bus_hit_i && (bus2Dctrl_req_message_i == GET_S);
	assign Dctrl2bus_rsp_data_o	= Dcache_bus_data_i;

	//-----------------------------------------------------
	// mshr_iss request entry allocation
	always_comb begin
		Dctrl2lq_ack_o		= 1'b0;
		Dctrl2sq_ack_o		= 1'b0;
		mshr_iss_alloc_en	= 1'b0;
		mshr_iss_tag_i		= `DCACHE_TAG_W'b0;
		mshr_iss_idx_i		= `DCACHE_IDX_W'b0;
		mshr_iss_data_i		= 64'h0;
		mshr_iss_message_i	= NONE;
		ld_alloc_wait_r_nxt	= ld_alloc_wait_r;
		st_alloc_wait_r_nxt = st_alloc_wait_r;
		if (lq2Dctrl_en_i) begin
			if (Dcache_lq_rd_hit_i | mshr_iss_hit | mshr_rsp_lq_hit) begin
				Dctrl2lq_ack_o		= (mshr_rsp_lq_fwd && mshr_rsp_wr_en) ? 1'b0 : 1'b1;
				mshr_iss_alloc_en	= 1'b0;
			end else if (~mshr_iss_full) begin // load miss
				if (Dcache_lq_rd_dty_i && ld_alloc_wait_r) begin // PUT_M first
					Dctrl2lq_ack_o		= 1'b0;
					mshr_iss_alloc_en	= 1'b1;
					mshr_iss_tag_i		= Dcache_lq_rd_tag_i;
					mshr_iss_idx_i		= Dcache_lq_rd_idx_o;
					mshr_iss_data_i		= Dcache_lq_rd_data_i;
					mshr_iss_message_i	= PUT_M;
					ld_alloc_wait_r_nxt	= 1'b0;
				end else begin // GET_S
					Dctrl2lq_ack_o		= 1'b1;
					mshr_iss_alloc_en	= 1'b1;
					mshr_iss_tag_i		= Dcache_lq_rd_tag_o;
					mshr_iss_idx_i		= Dcache_lq_rd_idx_o;
					mshr_iss_data_i		= 64'h0;
					mshr_iss_message_i	= GET_S;
					ld_alloc_wait_r_nxt	= 1'b1;
				end
			end
		end
		if (sq2Dctrl_en_i && ~(lq2Dctrl_en_i && ~Dcache_lq_rd_hit_i && ~mshr_iss_hit)) begin
			if (mshr_rsp_sq_hit) begin // Waiting for data response, stall
				Dctrl2sq_ack_o		= 1'b0;
				mshr_iss_alloc_en	= 1'b0;
			end else if ((Dcache_sq_wr_hit_i && Dcache_sq_wr_dty_i) | mshr_iss_hit) begin
				Dctrl2sq_ack_o		= 1'b1;
				mshr_iss_alloc_en	= 1'b0;
			end else if (~mshr_iss_full) begin
				if (~Dcache_sq_wr_hit_i && Dcache_sq_wr_dty_i && st_alloc_wait_r) begin // PUT_M
					Dctrl2sq_ack_o		= 1'b0;
					mshr_iss_alloc_en	= 1'b1;
					mshr_iss_tag_i		= Dcache_sq_wb_tag_i;
					mshr_iss_idx_i		= Dcache_sq_wr_idx_o;
					mshr_iss_data_i		= Dcache_sq_wb_data_i;
					mshr_iss_message_i	= PUT_M;
					st_alloc_wait_r_nxt	= 1'b0;
				end else begin // GET_M
					Dctrl2sq_ack_o		= 1'b1;
					mshr_iss_alloc_en	= 1'b1;
					mshr_iss_tag_i		= Dcache_sq_wr_tag_o;
					mshr_iss_idx_i		= Dcache_sq_wr_idx_o;
					mshr_iss_data_i		= Dcache_sq_wr_data_o;
					mshr_iss_message_i	= GET_M;
					st_alloc_wait_r_nxt	= 1'b1;
				end
			end
		end
	end


	//-----------------------------------------------------
	// mshr_rsp signals
	// inputs signals
	assign lq2mshr_rsp_tag	= lq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];;
	assign lq2mshr_rsp_idx	= lq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	assign sq2mshr_rsp_tag	= sq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign sq2mshr_rsp_idx	= sq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	
	assign mshr_rsp_ack		= bus2Dctrl_rsp_vld_i && (Dctrl_cpu_id_i == bus2Dctrl_rsp_id_i);

	// entry allocation
	always_comb begin
		mshr_rsp_alloc_en	= 1'b0;
		mshr_iss_tag_i		= mshr_iss_tag_o;
		mshr_iss_idx_i		= mshr_iss_idx_o;
		mshr_iss_message_i	= mshr_iss_message_o;
		mshr_rsp_iss_head_i	= mshr_iss_head;
		if (Dctrl2bus_req_en_o && bus2Dctrl_req_ack_i && mshr_iss_message_o == GET_S) begin
			mshr_rsp_alloc_en = 1'b1;
		end
	end
	
	// synopsys sync_set_reset "rst"
	always_comb begin
		if (rst) begin
			ld_alloc_wait_r	<= `SD 1'b1;
			st_alloc_wait_r	<= `SD 1'b1;
		end else begin
			ld_alloc_wait_r	<= `SD ld_alloc_wait_r_nxt;
			st_alloc_wait_r	<= `SD st_alloc_wait_r_nxt;
		end
	end


endmodule: Dcache_ctrl

