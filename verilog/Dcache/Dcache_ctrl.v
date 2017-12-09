// ****************************************************************************
// Filename: Dcache_ctrl.v
// Discription: D-cache controller, support cache coherence, instantiate MSHR
// 				here
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/23/2017
// 	<12/6> Added STQ_C instr success and failure bits
// ****************************************************************************

module Dcache_ctrl (
		input											clk,
		input											rst,

		input											Dctrl_cpu_id_i,

		// <12/6> STQ_C instructions
		input											sq2Dctrl_is_stq_c_i,
		output	logic									Dctrl2sq_stq_c_fail_o,
		output	logic									Dctrl2sq_stq_c_succ_o,

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
		output	logic									Dcache_sq_wr_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache_sq_wr_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_sq_wr_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache_sq_wr_data_o,

		input											Dcache_lq_rd_hit_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		Dcache_lq_rd_data_i,
		output	logic	[`DCACHE_TAG_W-1:0]				Dcache_lq_rd_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_lq_rd_idx_o,

		// from/to cachemem
		input											mshr_rsp_wr_dty_i,
		output	logic									mshr_rsp_wr_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_rsp_wr_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_rsp_wr_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_rsp_wr_data_o,

		// from/to cachemem
		input											mshr_iss_hit_i,
		input											mshr_iss_dty_i,
		output	logic									mshr_iss_st_en_o,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_iss_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				mshr_iss_idx_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_data_o,
		
		// evict from/to cachemem
		input			[`DCACHE_TAG_W-1:0]				Dcache_evict_tag_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		Dcache_evict_data_i,
		output	logic									Dcache_evict_en_o,
		output	logic	[`DCACHE_IDX_W-1:0]				Dcache_evict_idx_o,

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
		output	logic									Dctrl2bus_rsp_ack_o, // !!! to rsp queue
		// response to other requests
		output	logic									Dctrl2bus_rsp_vld_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dctrl2bus_rsp_data_o
	);

	// 
	logic									sq_st_silent_en;


	// signals for mshr_iss
	logic									mshr_iss_alloc_en;
	logic		[`DCACHE_TAG_W-1:0]			mshr_iss_tag_i;
	logic		[`DCACHE_IDX_W-1:0]			mshr_iss_idx_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	mshr_iss_data_i;
	logic									mshr_iss_stq_c_flag_i;
	message_t								mshr_iss_message_i;

	logic									mshr_iss_req_ack;
	logic									mshr_iss_en;
	message_t								mshr_iss_message_o;
	logic									mshr_iss_stq_c_flag_o;
	logic		[`MSHR_IDX_W-1:0]			mshr_iss_head;

	// <12/8>
	logic									mshr_iss_sq_hit;

	logic									mshr_iss_lq_hit;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	mshr_iss_lq_hit_data;
	message_t								mshr_iss_lq_hit_message;
	logic									mshr_iss_full;

	// signals for mshr_rsp
	logic		[`DCACHE_TAG_W-1:0]			lq2mshr_rsp_tag;
	logic		[`DCACHE_IDX_W-1:0]			lq2mshr_rsp_idx;
	logic		[`DCACHE_TAG_W-1:0]			sq2mshr_rsp_tag;
	logic		[`DCACHE_IDX_W-1:0]			sq2mshr_rsp_idx;

	logic									mshr_rsp_alloc_en;

	logic									mshr_rsp_ack;
	logic		[`DCACHE_TAG_W-1:0]			mshr_rsp_tag_o;
	logic		[`DCACHE_IDX_W-1:0]			mshr_rsp_idx_o;
	message_t								mshr_rsp_message_o;

	logic		[`MSHR_IDX_W-1:0]			mshr_rsp_iss_head_o;
	logic									mshr_rsp_lq_hit;
	logic									mshr_rsp_lq_fwd;
	logic									mshr_rsp_sq_hit;
	logic									mshr_rsp_full;

	// signals for evict
	logic									mshr_iss_evict_en;
	logic									mshr_rsp_evict_en;
	logic									mshr_iss_silent_st_en;

	wire									lq_addr_hit;


	// <12/4> lq and st address check
	logic									lq_addr_vld;
	logic									sq_addr_vld;


	// <12/7> st address hit bus input requesting addr
	// to avoid 2 different events on the same block:
	// Own silent st, and OtherGetS
	logic									sq_bus_addr_match;
	logic									mshr_iss_bus_addr_match;


	mshr_iss mshr_iss (
		.clk						(clk),
		.rst						(rst),

		.mshr_iss_alloc_en_i		(mshr_iss_alloc_en),
		.mshr_iss_tag_i				(mshr_iss_tag_i),
		.mshr_iss_idx_i				(mshr_iss_idx_i),
		.mshr_iss_data_i			(mshr_iss_data_i),
		.mshr_iss_message_i			(mshr_iss_message_i),
		.mshr_iss_stq_c_flag_i		(mshr_iss_stq_c_flag_i),

		.mshr_iss_ack_i				(mshr_iss_req_ack),
		.mshr_iss_en_o				(mshr_iss_en),
		.mshr_iss_tag_o				(mshr_iss_tag_o),
		.mshr_iss_idx_o				(mshr_iss_idx_o),
		.mshr_iss_data_o			(mshr_iss_data_o),
		.mshr_iss_message_o			(mshr_iss_message_o),
		.mshr_iss_stq_c_flag_o		(mshr_iss_stq_c_flag_o),
		.mshr_iss_head_o			(mshr_iss_head),

		.sq2mshr_iss_tag_i			(Dcache_sq_wr_tag_o),
		.sq2mshr_iss_idx_i			(Dcache_sq_wr_idx_o),
		.mshr_iss_sq_hit_o			(mshr_iss_sq_hit),
		.lq2mshr_iss_tag_i			(Dcache_lq_rd_tag_o),
		.lq2mshr_iss_idx_i			(Dcache_lq_rd_idx_o),
		.mshr_iss_lq_hit_o			(mshr_iss_lq_hit),
		.mshr_iss_lq_hit_data_o		(mshr_iss_lq_hit_data),
		.mshr_iss_lq_hit_message_o	(mshr_iss_lq_hit_message),
		.mshr_iss_full_o			(mshr_iss_full)
	);

	mshr_rsp mshr_rsp (
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
		.mshr_rsp_iss_head_i	(mshr_iss_head),
		
		.mshr_rsp_ack_i			(mshr_rsp_ack),
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
	// SQ input addr hit on the bus input request addr
	assign sq_bus_addr_match		= (Dcache_sq_wr_tag_o == bus2Dctrl_req_tag_i) &&
									  (Dcache_sq_wr_idx_o == bus2Dctrl_req_idx_i);
	assign mshr_iss_bus_addr_match	= (mshr_iss_tag_o == bus2Dctrl_req_tag_i) &&
									  (mshr_iss_idx_o == bus2Dctrl_req_idx_i);

	//-----------------------------------------------------
	// LSQ addr vld check
	assign lq_addr_vld	= (lq2Dctrl_addr_i[2:0]==3'b0) &&
						 (lq2Dctrl_addr_i<`MEM_SIZE_IN_BYTES);
	assign sq_addr_vld	= (sq2Dctrl_addr_i[2:0]==3'b0) &&
						 (sq2Dctrl_addr_i<`MEM_SIZE_IN_BYTES);


	//-----------------------------------------------------
	// Dctrl to lq load signals
	assign Dctrl2lq_data_vld_o		= Dcache_lq_rd_hit_i | (mshr_iss_lq_hit && mshr_iss_lq_hit_message == GET_M) |
	 								 (mshr_rsp_lq_fwd && mshr_rsp_wr_en_o);
	assign Dctrl2lq_mshr_data_vld_o = mshr_rsp_wr_en_o;
	assign Dctrl2lq_data_o			= (mshr_iss_lq_hit && mshr_iss_lq_hit_message == GET_M) ? mshr_iss_lq_hit_data : 
									  Dctrl2lq_mshr_data_vld_o ? bus2Dctrl_rsp_data_i :
									 (Dcache_lq_rd_hit_i) ? Dcache_lq_rd_data_i : 64'h0;
	

	//-----------------------------------------------------
	// Dctrl to Dcache sq store signals
	assign sq_st_silent_en		= Dcache_sq_wr_hit_i && Dcache_sq_wr_dty_i && 
								 ~sq2Dctrl_is_stq_c_i && ~sq_bus_addr_match && ~mshr_iss_sq_hit;
	assign Dcache_sq_wr_en_o	= sq2Dctrl_en_i && sq_st_silent_en;
	assign Dcache_sq_wr_tag_o	= sq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign Dcache_sq_wr_idx_o	= sq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	assign Dcache_sq_wr_data_o	= sq2Dctrl_data_i;


	//-----------------------------------------------------
	// Dctrl to Dcache lq load signals
	assign Dcache_lq_rd_tag_o	= lq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign Dcache_lq_rd_idx_o	= lq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];


	//-----------------------------------------------------
	// mshr_rsp to Dcache write signals
	assign mshr_rsp_wr_en_o		= bus2Dctrl_rsp_vld_i && (Dctrl_cpu_id_i == bus2Dctrl_rsp_id_i) &&
								 ~mshr_rsp_evict_en; // stall if evict, <12/4> modified from ~mshr_iss_st_en_o
	assign mshr_rsp_wr_tag_o	= mshr_rsp_tag_o;
	assign mshr_rsp_wr_idx_o	= mshr_rsp_idx_o;
	assign mshr_rsp_wr_data_o	= bus2Dctrl_rsp_data_i;


	//-----------------------------------------------------
	// mshr_iss to Dcache write signals
	assign mshr_iss_silent_st_en	= mshr_iss_hit_i && mshr_iss_dty_i && mshr_iss_en && ~mshr_iss_bus_addr_match;
	assign mshr_iss_st_en_o			= (bus2Dctrl_req_ack_i && (bus2Dctrl_req_message_i == GET_M)) | mshr_iss_silent_st_en;


	//-----------------------------------------------------
	// mshr to Dcache evict logic
	assign Dcache_evict_en_o	= bus2Dctrl_req_ack_i && (bus2Dctrl_req_message_i == PUT_M);
	assign Dcache_evict_idx_o	= mshr_rsp_evict_en ? mshr_rsp_idx_o : mshr_iss_idx_o;


	//-----------------------------------------------------
	// Dctrl to Dcache bus request signals
	assign Dcache_bus_invld_o		= (bus2Dctrl_req_id_i != Dctrl_cpu_id_i) && 
									  (bus2Dctrl_req_message_i == GET_M);
	assign Dcache_bus_downgrade_o	= (bus2Dctrl_req_id_i != Dctrl_cpu_id_i) && 
									  (bus2Dctrl_req_message_i == GET_S);
	assign Dcache_bus_tag_o			= bus2Dctrl_req_tag_i;
	assign Dcache_bus_idx_o			= bus2Dctrl_req_idx_i;


	//-----------------------------------------------------
	// Dctrl to bus request issue logic
	// and mshr_iss_evict_en, mshr_rsp_evict_en
	always_comb begin
		mshr_rsp_evict_en		= 1'b0;
		mshr_iss_evict_en		= 1'b0;
		Dctrl2bus_req_en_o		= 1'b0;
		Dctrl2bus_req_tag_o		= 0;
		Dctrl2bus_req_idx_o		= 0;
		Dctrl2bus_req_data_o	= 0;
		Dctrl2bus_req_message_o	= NONE;
		if (bus2Dctrl_rsp_vld_i && (bus2Dctrl_rsp_id_i == Dctrl_cpu_id_i) &&
			mshr_rsp_wr_dty_i) begin // mshr_rsp wr cause evict
			mshr_rsp_evict_en		= 1'b1;
			Dctrl2bus_req_en_o		= 1'b1;
			Dctrl2bus_req_tag_o		= Dcache_evict_tag_i;
			Dctrl2bus_req_idx_o		= Dcache_evict_idx_o;
			Dctrl2bus_req_data_o	= Dcache_evict_data_i;
			Dctrl2bus_req_message_o = PUT_M;
		end else if (mshr_iss_en && mshr_iss_message_o == GET_M && mshr_iss_dty_i) begin
			if (~mshr_iss_hit_i) begin // <12/5>
				mshr_iss_evict_en		= 1'b1;
				Dctrl2bus_req_en_o		= 1'b1;
				Dctrl2bus_req_tag_o		= Dcache_evict_tag_i;
				Dctrl2bus_req_idx_o		= Dcache_evict_idx_o;
				Dctrl2bus_req_data_o	= Dcache_evict_data_i;
				Dctrl2bus_req_message_o = PUT_M;
			end else begin // <12/5> silent
				Dctrl2bus_req_en_o		= 1'b0;
				Dctrl2bus_req_tag_o		= 0;
				Dctrl2bus_req_idx_o		= 0;
				Dctrl2bus_req_data_o	= 0;
				Dctrl2bus_req_message_o = NONE;
			end
		end else begin
			Dctrl2bus_req_en_o		= mshr_iss_en && (~mshr_rsp_full | mshr_iss_message_o != GET_S);
			Dctrl2bus_req_tag_o		= mshr_iss_tag_o;
			Dctrl2bus_req_idx_o		= mshr_iss_idx_o;
			Dctrl2bus_req_data_o	= mshr_iss_data_o;
			Dctrl2bus_req_message_o = mshr_iss_message_o;
		end
		// <12/6> store fail, no message
		if (Dctrl2sq_stq_c_fail_o) begin
			Dctrl2bus_req_en_o		= 1'b0;
			Dctrl2bus_req_tag_o		= 0;
			Dctrl2bus_req_idx_o		= 0;
			Dctrl2bus_req_data_o	= 0;
			Dctrl2bus_req_message_o = NONE;
		end
	end


	//-----------------------------------------------------
	// Dctrl to bus response ack signals
	assign Dctrl2bus_rsp_ack_o	= mshr_rsp_wr_en_o;
	

	//-----------------------------------------------------
	// Dctrl response to other request logic
	assign Dctrl2bus_rsp_vld_o	= Dcache_bus_hit_i && (bus2Dctrl_req_message_i == GET_S) &&
								 (bus2Dctrl_req_id_i != Dctrl_cpu_id_i);
	assign Dctrl2bus_rsp_data_o	= Dcache_bus_data_i;


	//-----------------------------------------------------
	// mshr_iss request entry allocation, and clear @head
	assign mshr_iss_req_ack	= (bus2Dctrl_req_ack_i && (bus2Dctrl_req_message_i != PUT_M)) | 
							  (mshr_iss_silent_st_en && mshr_iss_message_o == GET_M) | 
							   Dctrl2sq_stq_c_fail_o;
	assign lq_addr_hit		= Dcache_lq_rd_hit_i | mshr_iss_lq_hit | mshr_rsp_lq_hit;

	assign mshr_iss_stq_c_flag_i	= sq2Dctrl_is_stq_c_i;

	always_comb begin
		Dctrl2lq_ack_o		= 1'b0;
		Dctrl2sq_ack_o		= 1'b0;
		mshr_iss_alloc_en	= 1'b0;
		mshr_iss_tag_i		= `DCACHE_TAG_W'b0;
		mshr_iss_idx_i		= `DCACHE_IDX_W'b0;
		mshr_iss_data_i		= 64'h0;
		mshr_iss_message_i	= NONE;
		if (lq2Dctrl_en_i && (~sq2Dctrl_en_i || sq_st_silent_en)) begin
			if (lq_addr_hit) begin
				Dctrl2lq_ack_o		= (mshr_rsp_lq_fwd && mshr_rsp_wr_en_o) ? 1'b0 : 1'b1;
				//mshr_iss_alloc_en	= 1'b0; // <12/4> commented
			end else if (~mshr_iss_full) begin // load miss, GET_S
				Dctrl2lq_ack_o		= 1'b1;
				mshr_iss_alloc_en	= lq_addr_vld;
				mshr_iss_tag_i		= Dcache_lq_rd_tag_o;
				mshr_iss_idx_i		= Dcache_lq_rd_idx_o;
				mshr_iss_data_i		= 64'h0;
				mshr_iss_message_i	= GET_S;
			end
		end
		if (sq2Dctrl_en_i) begin // sq retire st insn has higher priority
			/*if (mshr_rsp_sq_hit) begin // Waiting for data response, stall
				Dctrl2sq_ack_o		= 1'b0;
				mshr_iss_alloc_en	= 1'b0;
			end else */
			if (sq_st_silent_en) begin
				Dctrl2sq_ack_o			= 1'b1;		
				//mshr_iss_alloc_en	= 1'b0; <12/4> commented
			end else if (~mshr_iss_full) begin  // GET_M
				Dctrl2sq_ack_o		= 1'b1;
				mshr_iss_alloc_en	= sq_addr_vld;
				mshr_iss_tag_i		= Dcache_sq_wr_tag_o;
				mshr_iss_idx_i		= Dcache_sq_wr_idx_o;
				mshr_iss_data_i		= Dcache_sq_wr_data_o;
				mshr_iss_message_i	= GET_M;
			end
		end
	end

	
	//-----------------------------------------------------
	// <12/6> stq_c insn hardware
	always_comb begin
		// <12/6> stq_c
		Dctrl2sq_stq_c_fail_o	= 1'b0;
		Dctrl2sq_stq_c_succ_o	= 1'b0;
		if (mshr_iss_en && mshr_iss_stq_c_flag_o) begin
			if (~mshr_iss_hit_i) begin // fail
				Dctrl2sq_stq_c_fail_o	= 1'b1;
				Dctrl2sq_stq_c_succ_o	= 1'b0;
			end else begin
				if (mshr_iss_dty_i && ~mshr_iss_bus_addr_match) begin
					Dctrl2sq_stq_c_fail_o	= 1'b0;
					Dctrl2sq_stq_c_succ_o	= 1'b1;
				end else if (bus2Dctrl_req_message_i == GET_M && 
							 bus2Dctrl_req_id_i == Dctrl_cpu_id_i) begin // hit and request wins the arbitration
					Dctrl2sq_stq_c_fail_o	= 1'b0;
					Dctrl2sq_stq_c_succ_o	= 1'b1;
				end
			end
		end
	end


	//-----------------------------------------------------
	// mshr_rsp signals
	// inputs signals
	assign lq2mshr_rsp_tag	= lq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign lq2mshr_rsp_idx	= lq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	assign sq2mshr_rsp_tag	= sq2Dctrl_addr_i[63:63-`DCACHE_TAG_W+1];
	assign sq2mshr_rsp_idx	= sq2Dctrl_addr_i[63-`DCACHE_TAG_W:63-`DCACHE_TAG_W-`DCACHE_IDX_W+1];
	
	assign mshr_rsp_ack		= mshr_rsp_wr_en_o;

	// entry allocation
	always_comb begin
		mshr_rsp_alloc_en	= 1'b0;
		if (bus2Dctrl_req_ack_i && bus2Dctrl_req_message_i == GET_S) begin
			mshr_rsp_alloc_en = 1'b1;
		end
	end
	

endmodule: Dcache_ctrl

