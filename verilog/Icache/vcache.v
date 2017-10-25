// ****************************************************************************
// Filename: vcache.v
// Description: victim cache for I-cache, 4-entry 
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/19/2017
// ****************************************************************************

module	vcache.v (
		input										clk,
		input										rst,

		input										wr_en_i,
		input		[`ICACHE_IDX_W-1:0]				wr_idx_i,
		input		[`ICACHE_IDX_W-1:0]				rd_idx_i,
		input		[`ICACHE_TAG_W-1:0]				wr_tag_i,
		input		[`ICACHE_TAG_W-1:0]				rd_tag_i,
		input		[`ICACHE_LINE_IN_BITS-1:0]		wr_data_i,
		input		[`ICACHE_IDX_W-1:0]				pf_idx_i,
		input		[`ICACHE_TAG_W-1:0]				pf_tag_i,

		output		[`ICACHE_DATA_IN_BITS-1:0]		rd_data_o,
		output										rd_hit_o,	
		output		[`ICACHE_DATA_IN_BITS-1:0]		pf_data_o,
		output										pf_hit_o	
	);

	logic	[3:0][`ICACHE_LINE_IN_BITS-1:0]			data_r;
	logic	[3:0][`ICACHE_TAG_W-1:0]				tag_r;
	logic	[3:0][`ICACHE_IDX_W-1:0]				idx_r;
	logic	[3:0]									vld_r;
	logic	[1:0]									w_ptr_r;

	logic	[`ICACHE_LINE_IN_BITS-1:0]				rd_data_line;
	logic	[`ICACHE_LINE_IN_BITS-1:0]				pf_data_line;

	// CAM read_out
	assign rd_data_o = rd_data_line;
	assign pf_data_o = pf_data_line;

	always_comb begin
		rd_hit_o		= 1'b0;
		rd_data_line	= `ICACHE_LINE_IN_BITS'b0;
		pf_hit_o		= 1'b0;
		pf_data_line	= `ICACHE_LINE_IN_BITS'b0;
		for (int i = 0; i < 4; i++) begin
			if ({rd_tag_i,rd_idx_i,1'b1} == {tag_r[i],idx_r[i],vld_r[i]}) begin
				rd_data_line	= data_r[i];
				rd_hit_o		= 1'b1;
			end
			if ({pf_tag_i,pf_idx_i,1'b1} == {tag_r[i],idx_r[i],vld_r[i]}) begin
				pf_data_line	= data_r[i];
				pf_hit_o		= 1'b1;
			end
		end
	end
		
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			vld_r	<= `SD 4'b0;
			w_ptr_r	<= `SD 2'b0;
		end else if (wr_en_i) begin
			w_ptr_r			<= `SD w_ptr_r + 1;
			vld_r[w_ptr_r]	<= `SD 1'b1;
			data_r[w_ptr_r]	<= `SD wr_data_i;
			tag_r[w_ptr_r]	<= `SD wr_tag_i;
			idx_r[w_ptr_r]	<= `SD wr_idx_i;
		end
	end

endmodule
