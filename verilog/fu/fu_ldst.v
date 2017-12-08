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
		input			[`ROB_IDX_W:0]		rob_idx_i,
		input								id_stc_mem_i,

		input								st_vld_i,
		input								ld_vld_i,
		input			[`SQ_IDX_W-1:0]		sq_idx_i,
		input								rob_st_retire_en_i,
		input			[`ROB_IDX_W:0]		rob_head_i,
		input								dp_en_i,
		input			[`SQ_IDX_W-1:0]		rs_ld_position_i,
		input			[`SQ_IDX_W-1:0]		ex_ld_position_i,

		input								Dcache_hit_i,
		input			[63:0]				Dcache_data_i,
		input			[63:0]				Dcache_mshr_addr_i,
		input								Dcache_mshr_ld_ack_i,
		input								Dcache_mshr_st_ack_i,
		input								Dcache_mshr_vld_i,
		input								Dcache_mshr_stall_i,
		input								Dcache_stc_success_i,
		input								Dcache_stc_fail_i,

		// branch recovery signals
		input			[`BR_MASK_W-1:0]	bs_br_mask_i,
		input			[`SQ_IDX_W:0]		bs_sq_tail_recovery_i,
		input								rob_br_recovery_i,
		input								rob_br_pred_correct_i,
		input			[`BR_MASK_W-1:0]	rob_br_tag_fix_i,
		input								fu_br_done_i,

		input								stall_i,

		output	logic	[63:0]				result_o,
		output	logic	[`PRF_IDX_W-1:0]	dest_tag_o,
		output	logic	[`ROB_IDX_W:0]		rob_idx_o,

		output	logic	[`SQ_IDX_W:0]		lsq_sq_tail_o,
		output	logic						lsq_ld_iss_en_o,
		output	logic	[63:0]				lsq2Dcache_ld_addr_o,
		output	logic						lsq2Dcache_ld_en_o,
		output	logic	[63:0]				lsq2Dcache_st_addr_o,
		output	logic	[63:0]				lsq2Dcache_st_data_o,
		output	logic						lsq2Dcache_st_en_o,
		output	logic						lsq2Dcache_stc_flag_o,
		output	logic						lsq_lq_com_rdy_o,
		output	logic						lsq_stc_com_rdy_o,
		output	logic						lsq_sq_full_o,
		output	logic	[`BR_MASK_W-1:0]	br_mask_o,
		output	logic						st_done_o,
		output	logic						ld_done_o,
		output	logic						lq_done_o,
		output	logic						stc_done_o
);

		logic	[63:0]						mem_disp;
		logic	[63:0]						addr;
		logic	[63:0]						result;
		logic	[`PRF_IDX_W-1:0]			dest_tag;
		logic	[`ROB_IDX_W:0]				rob_idx;
		logic								ld_done;
		logic								st_done;
		logic	[`BR_MASK_W-1:0]			br_mask;

		assign mem_disp			= { {48{inst_i[15]}}, inst_i[15:0] };
		assign addr				= opb_i + mem_disp;

		// synopsys sync_set_reset "rst"
		always_ff @(posedge clk) begin
				if (rst) begin
					result_o		<= `SD 0;
					dest_tag_o		<= `SD 0;
					rob_idx_o		<= `SD 0;
					ld_done_o		<= `SD 1'b0;
					st_done_o		<= `SD 1'b0;
					lq_done_o		<= `SD 1'b0;
					stc_done_o		<= `SD 1'b0;
					br_mask_o		<= `SD 0;
				end else if (rob_br_recovery_i && ((br_mask_o & rob_br_tag_fix_i) != 0)) begin
					result_o		<= `SD 0;
					dest_tag_o		<= `SD 0;
					rob_idx_o		<= `SD 0;
					ld_done_o		<= `SD 1'b0;
					st_done_o		<= `SD 1'b0;
					lq_done_o		<= `SD 1'b0;
					stc_done_o		<= `SD 1'b0;
					br_mask_o		<= `SD 0;
				end else if (~rob_br_recovery_i) begin
					result_o		<= `SD result;
					dest_tag_o		<= `SD dest_tag;
					rob_idx_o		<= `SD rob_idx;
					ld_done_o		<= `SD ld_done;
					st_done_o		<= `SD st_done;
					lq_done_o		<= `SD lsq_lq_com_rdy_o;
					stc_done_o		<= `SD lsq_stc_com_rdy_o;
					br_mask_o		<= `SD rob_br_pred_correct_i ? (br_mask & ~rob_br_tag_fix_i) : br_mask;
				end
		end		

		lsq lsq(
				.clk					(clk),
				.rst					(rst),

				.addr_i					(addr),
				.st_data_i				(opa_i),
				.st_vld_i				(st_vld_i),
				.sq_idx_i				(sq_idx_i),
				.rob_st_retire_en_i		(rob_st_retire_en_i),
				.rob_head_i				(rob_head_i),
				.dp_en_i				(dp_en_i),
				.id_stc_mem_i			(id_stc_mem_i),

				.rob_idx_i				(rob_idx_i),
				.dest_tag_i				(dest_tag_i),
				.ld_vld_i				(ld_vld_i),
				.rs_ld_position_i		(rs_ld_position_i),
				.ex_ld_position_i		(ex_ld_position_i),

				.Dcache_hit_i			(Dcache_hit_i),
				.Dcache_data_i			(Dcache_data_i),
				.Dcache_mshr_addr_i		(Dcache_mshr_addr_i),
				.Dcache_mshr_ld_ack_i	(Dcache_mshr_ld_ack_i),
				.Dcache_mshr_st_ack_i	(Dcache_mshr_st_ack_i),
				.Dcache_mshr_vld_i		(Dcache_mshr_vld_i),
				.Dcache_mshr_stall_i	(Dcache_mshr_stall_i),
				.Dcache_stc_success_i	(Dcache_stc_success_i),
				.Dcache_stc_fail_i		(Dcache_stc_fail_i),

				.bs_br_mask_i			(bs_br_mask_i),
				.bs_sq_tail_recovery_i	(bs_sq_tail_recovery_i),
				.rob_br_recovery_i		(rob_br_recovery_i),
				.rob_br_pred_correct_i	(rob_br_pred_correct_i),
				.rob_br_tag_fix_i		(rob_br_tag_fix_i),
				.fu_br_done_i			(fu_br_done_i),

				.lsq_sq_tail_o			(lsq_sq_tail_o),
				.lsq_ld_iss_en_o		(lsq_ld_iss_en_o),
				.lsq2Dcache_ld_addr_o	(lsq2Dcache_ld_addr_o),
				.lsq2Dcache_ld_en_o		(lsq2Dcache_ld_en_o),
				.lsq2Dcache_st_addr_o	(lsq2Dcache_st_addr_o),
				.lsq2Dcache_st_data_o	(lsq2Dcache_st_data_o),
				.lsq2Dcache_st_en_o		(lsq2Dcache_st_en_o),
				.lsq2Dcache_stc_flag_o	(lsq2Dcache_stc_flag_o),
				.lsq_ld_done_o			(ld_done),
				.lsq_st_done_o			(st_done),
				.lsq_data_o				(result),
				.lsq_rob_idx_o			(rob_idx),
				.lsq_dest_tag_o			(dest_tag),
				.lsq_br_mask_o			(br_mask),
				.lsq_lq_com_rdy_o		(lsq_lq_com_rdy_o),
				.lsq_stc_com_rdy_o		(lsq_stc_com_rdy_o),
				.lsq_sq_full_o			(lsq_sq_full_o)
		);

endmodule

