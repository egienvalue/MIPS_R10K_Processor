// ****************************************************************************
// Filename: lsq.v
// Discription: 
// Author: Shijing, Lu Liu
// Version History:
// 	intial creation: 11/06/2017
// 	***************************************************************************

module lsq(
		input								clk,
		input								rst,

		input			[`ADDR_W-1:0]		st_addr_i,
		input			[31:0]				st_data_i,
		input								st_vld_i,
		input			[`SQ_IDX-1:0]		st_idx_i,
		input			[`ADDR_W-1:0]		ld_addr_i,
		input			[`ROB_IDX_W-1:0]	ld_rob_idx_i,
		input			[`PRF_IDX_W-1:0]	ld_dest_tag_i,
		input			[`SQ_IDX-1:0]		rs_ld_position_i,
		input			[`SQ_IDX-1:0]		ex_ld_position_i,
		input								rob_st_retire_en_i,
		input								dp_en_i,

		input								Dcache_hit_i,
		input			[31:0]				Dcache_data_i,
		input			[`ADDR_W-1:0]		Dcache_mshr_addr_i,
		input			[31:0]				Dcache_mshr_data_i,
		input								Dcache_mshr_vld_i,
		input								Dcache_mshr_stall_i,

		output	logic	[`SQ_IDX-1:0]		lsq_sq_tail_o,
		output	logic						lsq_ld_iss_en_o,
		output	logic	[`ADDR_W-1:0]		lsq2Dcache_ld_addr_o,
		output	logic	[31:0]				lsq_ld_data_o,
		output	logic	[`ROB_IDX_W-1:0]	lsq_ld_rob_idx_o,
		output	logic	[`PRF_IDX_W-1:0]	lsq_ld_dest_tag_o,

		output	logic						lsq_full_o


);

	logic	[`SQ_ENT_NUM-1:0][`ADDR_W-1:0]		st_addr_r;
	logic	[`SQ_ENT_NUM-1:0]					st_addr_vld_r;
	logic	[`SQ_ENT_NUM-1:0][31:0]				st_data_r;
	logic	[`SQ_IDX-1:0]						sq_head_r;
	logic	[`SQ_IDX-1:0]						sq_tail_r;
	logic										sq_head_msb_r;
	logic										sq_tail_msb_r;
	logic	[`SQ_IDX:0]							sq_sq_head_q_r;
	logic	[`SQ_IDX:0]							sq_sq_tail_q_r;
	logic	[`LQ_IDX-1:0]						lq_head_r;
	logic	[`LQ_IDX-1:0]						lq_tail_r;
	logic										lq_head_msb_r;
	logic										lq_tail_msb_r;
	logic	[`LQ_IDX:0]							lq_head_q_r;
	logic	[`LQ_IDX:0]							lq_tail_q_r;
	logic	[`LQ_ENT_NUM-1:0][`ADDR_W-1:0]		lq_addr_r;
	logic	[`LQ_ENT_NUM-1:0][31:0]				lq_data_r;
	logic	[`LQ_ENT_NUM-1:0]					lq_rdy_r;
	logic	[`LQ_ENT_NUM-1:0][`ROB_IDX_W-1:0]	lq_rob_idx_r;
	logic	[`LQ_ENT_NUM-1:0][`PRF_IDX_W-1:0]	lq_dest_tag_r;
                                            	
	logic	[`SQ_IDX:0]							sq_head_q_r_nxt;
	logic	[`SQ_IDX:0]							sq_tail_q_r_nxt;
	logic	[`LQ_IDX:0]							lq_head_q_r_nxt;
	logic	[`LQ_IDX:0]							lq_tail_q_r_nxt;
	logic	[`SQ_IDX-1:0]						st_addr_vld_r_nxt;
	logic	[31:0]								st2ld_forward_data;
	logic	[31:0]								st2ld_forward_data1;
	logic	[31:0]								st2ld_forward_data2;
	logic										st2ld_forward_vld;
	logic										st2ld_forward_vld1;
	logic										st2ld_forward_vld2;
                                    	    	
	logic										lq_head_match;
	logic										lq_com_rdy;

	assign sq_head_q_r = {sq_head_msb_r, sq_head_r};
	assign sq_tail_q_r = {sq_tail_msb_r, sq_tail_r};
	assign lq_head_q_r = {lq_head_msb_r, lq_head_r};
	assign lq_tail_q_r = {lq_tail_msb_r, sq_head_r};

	assign lsq_sq_tail_o = sq_tail_r;

	assign lsq_ld_data_o = lq_head_match ? Dcache_mshr_data_i :
		                   lq_rdy_r[lq_head_r] ? lq_data_r[lq_head_r] :
						   st2ld_forward_vld ? st2ld_forward_data :
						   Dcache_hit_i ? Dcache_data_i : 32'b0;

	assign lsq_ld_rob_idx_o = lq_com_rdy ? lq_rob_idx_r[lq_head_r] : ld_rob_idx_i;

	assign lsq_ld_dest_tag_o = lq_com_rdy ? lq_dest_tag_r[lq_head_r] : ld_dest_tag_i;

	assign lsq_full_o = ((sq_head_r == sq_tail_r) && (sq_head_msb_r != sq_tail_msb_r));

	assign sq_head_q_r_nxt = rob_st_retire_en_i ? (sq_head_q_r + 1) : sq_head_q_r;
	assign sq_tail_q_r_nxt = dp_en_i ? (sq_tail_q_r + 1) : sq_tail_q_r;

	always_comb begin
		st_addr_vld_r_nxt = st_addr_vld_r;
		if (st_vld_i)
			st_addr_vld_r_nxt[st_idx_i] = 1'b1;

		if (rob_st_retire_en_i)
			st_addr_vld_r_nxt[sq_head_r] = 1'b0;
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (st_vld_i) begin
			st_addr_r[st_idx_i]		<= `SD st_addr_i;
			st_data_r[st_idx_i]		<= `SD st_data_i;
		end
	end

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			sq_head_q_r		<= `SD 0;
			sq_tail_q_r		<= `SD 0;	logic	[`SQ_IDX-1:0]				sq_head_r;
	logic	[`SQ_IDX-1:0]				sq_tail_r;
	logic								sq_head_msb_r;
	logic								sq_tail_msb_r;
	logic	[`SQ_IDX:0]					sq_head_q_r;
	logic	[`SQ_IDX:0]					sq_tail_q_r;

			st_addr_vld_r	<= `SD 0;
		end else begin
			sq_head_q_r		<= `SD sq_head_q_r_nxt;
			sq_tail_q_r		<= `SD sq_tail_q_r_nxt;
			st_addr_vld_r	<= `SD st_addr_vld_r_nxt;
		end
	end

	// age logic
	// generate lsq_ld_iss_en_o
	integer i;
	always_comb begin
		lsq_ld_iss_en_o = 1'b1;

		for (i = 0; i < `SQ_ENT_NUM; i = i + 1) begin
			if ((rs_ld_position_i >= sq_head_r) && (~lsq_full_o || (rs_ld_position_i != sq_tail_r))) begin
				if ((i >= sq_head_r) && (i < rs_ld_position_i) && ~st_addr_vld_r[i])
					lsq_ld_iss_en_o = 1'b0;
			end else begin
				if (((i < rs_ld_position_i) || (i >= sq_head_r)) && ~st_addr_vld_r[i])
					lsq_ld_iss_en_o = 1'b0;
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
			if ((ex_ld_position_i >= sq_head_r) && (~lsq_full_o || (ex_ld_position_i != sq_tail_r))) begin
				if ((j >= sq_head_r) && (j < ex_ld_postion_i) && (ld_addr_i == st_addr_r[j])) begin
					st2ld_forward_data1 = st_data_r[j];
					st2ld_forward_vld1 = 1'b1;
				end
			end else begin
				if ((j < ex_ld_position_i) && (ld_addr_i == st_addr_r[j])) begin
					st2ld_forward_data1 = st_data_r[j];
					st2ld_forward_vld1 = 1'b1;
				end else if ((j >= sq_head_r) && (ld_addr_i == st_addr_r[j])) begin
					st2ld_forward_data2 = st_data_r[j];
					st2ld_forward_vld2 = 1'b1;
			end
		end

		st2ld_forward_data = st2ld_forward_vld1 ? st2ld_forward_data1 : st2ld_forward_data2;
		st2ld_forward_vld = st2ld_forward_vld1 | st2ld_forward_vld2;
	end

	// load queue
	assign lq_head_match = Dcache_mshr_vld_i && (Dcache_mshr_addr_i == lq_addr_r[lq_head_r]);
	assign lq_com_rdy = (lq_head_match || lq_rdy_r[lq_head_r]) && (lq_head_q_r != lq_tail_q_r);
	assign ld_miss = ~Dcache_hit_i & ~st2ld_forward_vld;

	assign lq_head_q_r_nxt = lq_com_rdy ? lq_head_q_r + 1 : lq_head_q_r;

	assign lq_tail_q_r_nxt = ld_miss ? lq_tail_q_r + 1 : lq_tail_q_r;

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

	integer k;
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (Dcache_mshr_vld_i) begin
			for(k = 0; k < `LQ_ENT_NUM; k = k + 1) begin
				if (lq_addr_r[k] == Dcache_mshr_addr_i) begin
					lq_rdy_r[k]		<= `SD 1'b1;
					lq_data_r[k]	<= `SD Dcache_mshr_data_i;
				end
			end
		end else if (ld_miss) begin
			lq_addr_r[lq_tail_r]		<= `SD ld_addr_i;
			lq_rob_idx_r[lq_tail_r]		<= `SD ld_rob_idx_i;
			lq_dest_tag_r[lq_tail_r]	<= `SD ld_dest_tag_i;
			lq_rdy_r[lq_tail_r]			<= `SD 1'b0;
		end
	end

endmodule






