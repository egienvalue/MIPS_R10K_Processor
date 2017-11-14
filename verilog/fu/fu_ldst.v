// ****************************************************************************
// Filename: fu_ldst.v
// Discription: 
// Author: Shijing, Lu Liu
// Version History:
// intial creation: 11/06/2017
// ***************************************************************************

module fu_ldst(
		input								clk,
		input								rst,

		input			[63:0]				opa_i,
		input			[63:0]				opb_i,
		input			[31:0]				inst_i,
		input			[`PRF_IDX_W-1:0]	dest_tag_i,
		input			[`ROB_IDX_W-1:0]	rob_idx_i,

		input								st_vld_i,
		input								ld_vld_i,
		input			[`SQ_IDX_W-1:0]		sq_idx_i,
		input								rob_st_retire_en_i,
		input								dp_en_i,
		input			[`SQ_IDX_W-1:0]		rs_ld_position_i,
		input			[`SQ_IDX_W-1:0]		ex_ld_position_i,

		input								Dcache_hit_i,
		input			[63:0]				Dcache_data_i,
		input			[63:0]				Dcache_mshr_addr_i,
		input								Dcache_mshr_vld_i,
		input								Dcache_mshr_stall_i,

		output	logic	[63:0]				result_o,
		output	logic	[`PRF_IDX_W-1:0]	dest_tag_o,
		output	logic	[`ROB_IDX_W-1:0]	rob_idx_o,
		output	logic	[`SQ_IDX_W-1:0]		lsq_sq_tail_o,
		output	logic						lsq_ld_iss_en_o,
		output	logic	[63:0]				lsq2Dcache_ld_addr_o,
		output	logic						lsq2Dcache_ld_en_o,
		output	logic						lsq_lq_com_rdy_o,
		output	logic						lsq_sq_full_o,
		output	logic						st_done_o,
		output	logic						ld_done_o
);

		logic	[63:0]						mem_disp;
		logic	[63:0]						addr;
		logic								lsq_ld_com_rdy;

		assign mem_disp = { {48{inst_i[15]}}, inst_i[15:0] };
		assign addr = opb_i + mem_disp;
		assign ld_done_o = lsq_lq_com_rdy_o | Dcache_hit_i;
		assign st_done_o = st_vld_i;

		lsq lsq(
				.clk					(clk),
				.rst					(rst),

				.addr_i					(addr),
				.st_data_i				(opa_i),
				.st_vld_i				(st_vld_i),
				.sq_idx_i				(sq_idx_i),
				.rob_st_retire_en_i		(rob_st_retire_en_i),
				.dp_en_i				(dp_en_i),

				.ld_rob_idx_i			(rob_idx_i),
				.ld_dest_tag_i			(dest_tag_i),
				.ld_vld_i				(ld_vld_i),
				.rs_ld_position_i		(rs_ld_position_i),
				.ex_ld_position_i		(ex_ld_position_i),

				.Dcache_hit_i			(Dcache_hit_i),
				.Dcache_data_i			(Dcache_data_i),
				.Dcache_mshr_addr_i		(Dcache_mshr_addr_i),
				.Dcache_mshr_vld_i		(Dcache_mshr_vld_i),
				.Dcache_mshr_stall_i	(Dcache_mshr_stall_i),

				.lsq_sq_tail_o			(lsq_sq_tail_o),
				.lsq_ld_iss_en_o		(lsq_ld_iss_en_o),
				.lsq2Dcache_ld_addr_o	(lsq2Dcache_ld_adr_o),
				.lsq2Dcache_ld_en_o		(lsq2Dcache_ld_en_o),
				.lsq_ld_data_o			(result_o),
				.lsq_ld_rob_idx_o		(rob_idx_o),
				.lsq_ld_dest_tag_o		(dest_tag_o),
				.lsq_lq_com_rdy_o		(lsq_lq_com_rdy_o),
				.lsq_sq_full_o			(lsq_sq_full_o)
		);

endmodule

