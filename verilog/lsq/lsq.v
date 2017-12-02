// ****************************************************************************
// Filename: lsq.v
// Discription: 
// Author: Shijing, Lu Liu
// Version History: 
// intial creation: 11/06/2017
// ***************************************************************************

module lsq (
		input								clk,
		input								rst,

		// store signals
		input			[`ADDR_W-1:0]		addr_i,
		input			[63:0]				st_data_i,
		input								st_vld_i,
		input			[`SQ_IDX_W-1:0]		sq_idx_i,
		input								rob_st_retire_en_i,
		input								dp_en_i,

		// load signals
		input			[`ROB_IDX_W:0]		rob_idx_i,
		input			[`PRF_IDX_W-1:0]	dest_tag_i,
		input								ld_vld_i,
		input			[`SQ_IDX_W-1:0]		rs_ld_position_i,
		input			[`SQ_IDX_W-1:0]		ex_ld_position_i,

		// Dcache signals
		input								Dcache_hit_i,
		input			[63:0]				Dcache_data_i,
		input			[`ADDR_W-1:0]		Dcache_mshr_addr_i,
		input								Dcache_mshr_ld_ack_i,
		input								Dcache_mshr_st_ack_i,
		input								Dcache_mshr_vld_i,
		input								Dcache_mshr_stall_i,

		// branch recovery signals
		input			[`BR_MASK_W-1:0]	bs_br_mask_i,
		input			[`SQ_IDX_W:0]		bs_sq_tail_recovery_i,
		input								rob_br_recovery_i,
		input								rob_br_pred_correct_i,
		input			[`BR_MASK_W-1:0]	rob_br_tag_fix_i,
		input								fu_br_done_i,

		// output signals
		output	logic	[`SQ_IDX_W:0]		lsq_sq_tail_o,
		output	logic						lsq_ld_iss_en_o,
		output	logic	[`ADDR_W-1:0]		lsq2Dcache_ld_addr_o,
		output	logic						lsq2Dcache_ld_en_o,
		output	logic	[63:0]				lsq2Dcache_st_addr_o,
		output	logic	[63:0]				lsq2Dcache_st_data_o,
		output	logic						lsq2Dcache_st_en_o,
		output	logic	[63:0]				lsq_ld_data_o,
		output	logic	[`ROB_IDX_W:0]		lsq_ld_rob_idx_o,
		output	logic	[`PRF_IDX_W-1:0]	lsq_ld_dest_tag_o,
		output	logic	[`BR_MASK_W-1:0]	lsq_ld_br_mask_o,
		output	logic						lsq_lq_com_rdy_o,
		output	logic						lsq_sq_full_o
);

	// ------------------ Internal Signals ---------------------
	parameter IDLE = 1'b0,
			  BUSY = 1'b1;
	// store queue registers
	logic	[`SQ_ENT_NUM-1:0][`ADDR_W-1:0]		st_addr_r;
	logic	[`SQ_ENT_NUM-1:0]					st_addr_vld_r;
	logic	[`SQ_ENT_NUM-1:0][63:0]				st_data_r;
	logic	[`SQ_ENT_NUM-1:0]					st_retire_rdy_r;
	logic	[`SQ_IDX_W:0]						sq_head_q_r;
	logic	[`SQ_IDX_W:0]						sq_retire_head_q_r;
	logic	[`SQ_IDX_W:0]						sq_tail_q_r;
	logic	[`SQ_IDX_W-1:0]						sq_head_r;
	logic	[`SQ_IDX_W-1:0]						sq_retire_head_r;
	logic	[`SQ_IDX_W-1:0]						sq_tail_r;
	logic										sq_head_msb_r;
	logic										sq_retire_head_msb_r;
	logic										sq_tail_msb_r;

	// load queue registers
	logic	[`LQ_IDX_W:0]						lq_head_q_r;
	logic	[`LQ_IDX_W:0]						lq_tail_q_r;
	logic	[`LQ_IDX_W-1:0]						lq_head_r;
	logic	[`LQ_IDX_W-1:0]						lq_tail_r;
	logic										lq_head_msb_r;
	logic										lq_tail_msb_r;
	logic	[`LQ_ENT_NUM-1:0][`ADDR_W-1:0]		lq_addr_r;
	logic	[`LQ_ENT_NUM-1:0][63:0]				lq_data_r;
	logic	[`LQ_ENT_NUM-1:0]					lq_vld_r;
	logic	[`LQ_ENT_NUM-1:0]					lq_rdy_r;
	logic	[`LQ_ENT_NUM-1:0][`ROB_IDX_W:0]		lq_rob_idx_r;
	logic	[`LQ_ENT_NUM-1:0][`PRF_IDX_W-1:0]	lq_dest_tag_r;
	logic	[`LQ_ENT_NUM-1:0][`BR_MASK_W-1:0]	lq_br_mask_r;

	logic	[63:0]								ld_addr_hold_r;
	logic	[63:0]								ld_addr_hold_r_nxt;
	logic										ld_addr_hold_r_state;
	logic										ld_addr_hold_r_state_nxt;

	// store queue signals
	logic	[`SQ_IDX_W:0]						sq_head_q_r_nxt;
	logic	[`SQ_IDX_W:0]						sq_retire_head_q_r_nxt;
	logic	[`SQ_IDX_W:0]						sq_tail_q_r_nxt;
	logic	[`SQ_ENT_NUM-1:0]					st_addr_vld_r_nxt;
	logic	[`SQ_ENT_NUM-1:0]					st_retire_rdy_r_nxt;
	logic										sq_retire_en;
	logic	[63:0]								st2ld_forward_data;
	logic	[63:0]								st2ld_forward_data1;
	logic	[63:0]								st2ld_forward_data2;
	logic										st2ld_forward_vld;
	logic										st2ld_forward_vld1;
	logic										st2ld_forward_vld2;
	logic										ld_iss_en;

	// load queue signals
	logic	[`LQ_IDX_W:0]						lq_head_q_r_nxt;
	logic	[`LQ_IDX_W:0]						lq_tail_q_r_nxt;
	logic	[`LQ_ENT_NUM-1:0]					lq_vld_r_nxt;
	logic	[`LQ_ENT_NUM-1:0]					lq_rdy_r_nxt;
	logic	[`LQ_ENT_NUM-1:0][63:0]				lq_data_r_nxt;
	logic	[`LQ_ENT_NUM-1:0][`BR_MASK_W-1:0]	lq_br_mask_r_nxt;
	logic										lq_head_match;
	logic										lq_full;
	logic										ld_miss;
	logic										lq_com_rdy;

	// --------------------- Store Queue ------------------------------
	assign sq_head_msb_r = sq_head_q_r[`SQ_IDX_W];
	assign sq_head_r = sq_head_q_r[`SQ_IDX_W-1:0];
	assign sq_retire_head_msb_r = sq_retire_head_q_r[`SQ_IDX_W];
	assign sq_retire_head_r = sq_retire_head_q_r[`SQ_IDX_W-1:0];
	assign sq_tail_msb_r = sq_tail_q_r[`SQ_IDX_W];
	assign sq_tail_r = sq_tail_q_r[`SQ_IDX_W-1:0];

	assign sq_head_q_r_nxt = sq_retire_en ? (sq_head_q_r + 1) : sq_head_q_r;

	assign sq_retire_head_q_r_nxt = rob_st_retire_en_i ? (sq_retire_head_q_r + 1) : sq_retire_head_q_r;

	assign sq_tail_q_r_nxt = rob_br_recovery_i ? bs_sq_tail_recovery_i :
							 dp_en_i ? (sq_tail_q_r + 1) : sq_tail_q_r;

	assign lsq_sq_tail_o = sq_tail_r;

	assign lsq_ld_iss_en_o = ld_iss_en && ~lq_full && ~Dcache_mshr_stall_i && (ld_addr_hold_r_state_nxt != BUSY);

	assign lsq2Dcache_st_addr_o = st_addr_r[sq_head_r];

	assign lsq2Dcache_st_data_o = st_data_r[sq_head_r];

	assign lsq2Dcache_st_en_o = rob_st_retire_en_i | st_retire_rdy_r[sq_head_r];

	assign sq_retire_en = lsq2Dcache_st_en_o & Dcache_mshr_st_ack_i;

	assign lsq_sq_full_o = ((sq_head_r == sq_tail_r) && (sq_head_msb_r != sq_tail_msb_r));

	always_comb begin
		st_addr_vld_r_nxt = st_addr_vld_r;
		if (dp_en_i)
			st_addr_vld_r_nxt[sq_tail_r] = 1'b0;
		
		if (st_vld_i)
			st_addr_vld_r_nxt[sq_idx_i] = 1'b1;

		if (sq_retire_en)
			st_addr_vld_r_nxt[sq_head_r] = 1'b0;

	end

	always_comb begin
		st_retire_rdy_r_nxt = st_retire_rdy_r;

		if (rob_st_retire_en_i & ~Dcache_mshr_st_ack_i)
			st_retire_rdy_r_nxt[sq_retire_head_r] = 1'b1;

		if (sq_retire_en)
			st_retire_rdy_r_nxt[sq_head_r] = 1'b0;
	end

	always_ff @(posedge clk) begin
		if (st_vld_i) begin
			st_addr_r[sq_idx_i]		<= `SD addr_i;
			st_data_r[sq_idx_i]		<= `SD st_data_i;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			sq_head_q_r			<= `SD 0;
			sq_tail_q_r			<= `SD 0;
			sq_retire_head_q_r	<= `SD 0;//
			st_addr_vld_r		<= `SD 0;
			st_retire_rdy_r		<= `SD 0;
		end else begin
			sq_head_q_r			<= `SD sq_head_q_r_nxt;
			sq_tail_q_r			<= `SD sq_tail_q_r_nxt;
			sq_retire_head_q_r	<= `SD sq_retire_head_q_r_nxt;//
			st_addr_vld_r		<= `SD st_addr_vld_r_nxt;
			st_retire_rdy_r		<= `SD st_retire_rdy_r_nxt;
		end
	end

	// age logic
	// generate ld_iss_en (check the addresses of all older stores are known)
	integer i;
	always_comb begin
		ld_iss_en = 1'b1;


		for (i = 0; i < `SQ_ENT_NUM; i = i + 1) begin
			if ((rs_ld_position_i >= sq_head_r) && (~lsq_sq_full_o || (rs_ld_position_i != sq_tail_r))) begin
				if ((i >= sq_head_r) && (i < rs_ld_position_i) && ~st_addr_vld_r[i])
					ld_iss_en = 1'b0;
			end else begin
				if (((i < rs_ld_position_i) || (i >= sq_head_r)) && ~st_addr_vld_r[i])
					ld_iss_en = 1'b0;
			end
		end
	end

	// generate forward_vld and forward_data
	integer j;
	always_comb begin
		st2ld_forward_data1 = 32'b0;
		st2ld_forward_data2 = 32'b0;
		st2ld_forward_vld1 = 1'b0;
		st2ld_forward_vld2 = 1'b0;
		
		for (j = 0; j < `SQ_ENT_NUM; j = j + 1) begin
			if ((ex_ld_position_i >= sq_head_r) && (~lsq_sq_full_o || (ex_ld_position_i != sq_tail_r))) begin
				if ((j >= sq_head_r) && (j < ex_ld_position_i) && (addr_i == st_addr_r[j])) begin
					st2ld_forward_data1 = st_data_r[j];
					st2ld_forward_vld1 = 1'b1;
				end
			end else begin
				if ((j < ex_ld_position_i) && (addr_i == st_addr_r[j])) begin
					st2ld_forward_data1 = st_data_r[j];
					st2ld_forward_vld1 = 1'b1;
				end else if ((j >= sq_head_r) && (addr_i == st_addr_r[j])) begin
					st2ld_forward_data2 = st_data_r[j];
					st2ld_forward_vld2 = 1'b1;
				end
			end
		end
		st2ld_forward_data = st2ld_forward_vld1 ? st2ld_forward_data1 : st2ld_forward_data2;
		st2ld_forward_vld = st2ld_forward_vld1 | st2ld_forward_vld2;
	end

	// ---------------------- Load Queue ----------------------------
	always_comb begin
		if (ld_vld_i & ~Dcache_hit_i & ~Dcache_mshr_ld_ack_i) begin
			ld_addr_hold_r_state_nxt = BUSY;
			ld_addr_hold_r_nxt = addr_i;
		end else if (Dcache_mshr_ld_ack_i) begin
			ld_addr_hold_r_state_nxt = IDLE;
			ld_addr_hold_r_nxt = 0;
		end else begin
			ld_addr_hold_r_state_nxt = ld_addr_hold_r_state;
			ld_addr_hold_r_nxt = ld_addr_hold_r;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			ld_addr_hold_r_state	<= `SD IDLE;
			ld_addr_hold_r			<= `SD 0;
		end else begin
			ld_addr_hold_r_state	<= `SD ld_addr_hold_r_state_nxt;
			ld_addr_hold_r			<= `SD ld_addr_hold_r_nxt;
		end
	end

	assign lq_head_msb_r = lq_head_q_r[`LQ_IDX_W];
	assign lq_head_r = lq_head_q_r[`LQ_IDX_W-1:0];
	assign lq_tail_msb_r = lq_tail_q_r[`LQ_IDX_W];
	assign lq_tail_r = lq_tail_q_r[`LQ_IDX_W-1:0];

	assign lq_head_q_r_nxt = (lq_com_rdy & ~fu_br_done_i | ~lq_vld_r[lq_head_r]) ? lq_head_q_r + 1 : lq_head_q_r;//

	assign lq_tail_q_r_nxt = rob_br_recovery_i ? lq_tail_q_r :
							 ld_miss ? lq_tail_q_r + 1 : lq_tail_q_r;

	assign lq_head_match = Dcache_mshr_vld_i && (Dcache_mshr_addr_i == lq_addr_r[lq_head_r]);

	assign lq_com_rdy = (lq_head_match || lq_rdy_r[lq_head_r]) && (lq_head_q_r != lq_tail_q_r);

	assign lsq_lq_com_rdy_o = lq_com_rdy & lq_vld_r[lq_head_r];

	assign ld_miss = ld_vld_i & ~Dcache_hit_i & ~st2ld_forward_vld;//

	assign lsq2Dcache_ld_addr_o = ld_vld_i ? addr_i : ld_addr_hold_r;

	assign lsq2Dcache_ld_en_o = (ld_vld_i || (ld_addr_hold_r_state == BUSY)) && ~Dcache_mshr_vld_i;

	assign lsq_ld_data_o = (lq_head_match & lq_vld_r[lq_head_r]) ? Dcache_data_i :
		                   (lq_rdy_r[lq_head_r] & lq_vld_r[lq_head_r]) ? lq_data_r[lq_head_r] :
						   st2ld_forward_vld ? st2ld_forward_data :
						   Dcache_hit_i ? Dcache_data_i : 32'b0;

	assign lsq_ld_rob_idx_o = lsq_lq_com_rdy_o ? lq_rob_idx_r[lq_head_r] : rob_idx_i;

	assign lsq_ld_dest_tag_o = lsq_lq_com_rdy_o ? lq_dest_tag_r[lq_head_r] : dest_tag_i;

	assign lsq_ld_br_mask_o = lsq_lq_com_rdy_o ? lq_br_mask_r[lq_head_r] : bs_br_mask_i;

	assign lq_full = (lq_head_r == lq_tail_r) && (lq_head_msb_r != lq_tail_msb_r);

	always_comb begin
		lq_vld_r_nxt = lq_vld_r;
		lq_rdy_r_nxt = lq_rdy_r;
		lq_data_r_nxt = lq_data_r;

		if (rob_br_recovery_i) begin
			for (int k = 0; k < `LQ_ENT_NUM; k = k + 1) begin
				if (((lq_br_mask_r[k] & rob_br_tag_fix_i) != 0) && lq_vld_r[k])
					lq_vld_r_nxt[k]		= 1'b0;
			end
		end else if (ld_miss) begin
			lq_rdy_r_nxt[lq_tail_r]		= 1'b0;
			lq_vld_r_nxt[lq_tail_r]		= 1'b1;
		end
		if (Dcache_mshr_vld_i) begin
			for (int k = 0; k < `LQ_ENT_NUM; k = k + 1) begin
				if ((lq_addr_r[k] == Dcache_mshr_addr_i) && lq_vld_r[k]) begin
					lq_rdy_r_nxt[k] 	= 1'b1;
					lq_data_r_nxt[k]	= Dcache_data_i;
				end
			end
		end
	end

	always_comb begin
		lq_br_mask_r_nxt = lq_br_mask_r;

		if (rob_br_recovery_i)
			for (int k = 0; k < `LQ_ENT_NUM; k = k + 1)
				if ((lq_br_mask_r[k] & rob_br_tag_fix_i) != 0)
					lq_br_mask_r_nxt[k]		= 0;
		else if (rob_br_pred_correct_i)
			for (int k = 0; k < `LQ_ENT_NUM; k = k + 1)
				lq_br_mask_r_nxt[k]		= lq_br_mask_r[k] & ~rob_br_tag_fix_i;
		else if (ld_miss)
			lq_br_mask_r_nxt[lq_tail_r]	= bs_br_mask_i;
	end


	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			lq_head_q_r		<= `SD 0;
			lq_tail_q_r		<= `SD 0;
		end else begin
			lq_head_q_r		<= `SD lq_head_q_r_nxt;
			lq_tail_q_r		<= `SD lq_tail_q_r_nxt;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			lq_vld_r		<= `SD {`LQ_ENT_NUM{1'b1}};
			lq_rdy_r		<= `SD 0;
			lq_data_r		<= `SD 'b0;
			lq_br_mask_r	<= `SD 'b0;
		end else begin
			lq_vld_r		<= `SD lq_vld_r_nxt;
			lq_rdy_r		<= `SD lq_rdy_r_nxt;
			lq_data_r		<= `SD lq_data_r_nxt;
			lq_br_mask_r	<= `SD lq_br_mask_r_nxt;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (ld_miss) begin
			lq_addr_r[lq_tail_r]		<= `SD addr_i;
			lq_rob_idx_r[lq_tail_r]		<= `SD rob_idx_i;
			lq_dest_tag_r[lq_tail_r]	<= `SD dest_tag_i;
		end
	end

endmodule


