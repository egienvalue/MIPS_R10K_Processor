// ****************************************************************************
// Filename: cachemem.v
// Description: 1KB memory for I-cache 
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/17/2017, one-way design.
// ****************************************************************************

module cachemem (
		input										clk,
		input										rst,

		input										wr_en_i,
		input		[`ICACHE_IDX_W-1:0]				wr_idx_i,
		input		[`ICACHE_TAG_W-1:0]				wr_tag_i,
		input		[`ICACHE_LINE_IN_BITS-1:0]		wr_data_i,
		input		[`ICACHE_IDX_W-1:0]				rd_idx_i,
		input		[`ICACHE_TAG_W-1:0]				rd_tag_i,
		
		input		[`ICACHE_IDX_W-1:0]				pf_idx_i,
		input		[`ICACHE_TAG_W-1:0]				pf_tag_i,

		output		[`ICACHE_DATA_IN_BITS-1:0]		rd_data_o,
		output										rd_hit_o,
		output										pf_hit_o	
	);

	cache1way way0 (
		.clk		(clk		),
		.rst		(rst		),

		.wr_en_i		(wr_en_i		),
		.wr_idx_i		(wr_idx_i		),
		.wr_tag_i		(wr_tag_i		),
		.wr_data_i		(wr_data_i		),
		.rd_idx_i		(rd_idx_i		),
		.rd_tag_i		(rd_tag_i		),
		
		.pf_idx_i		(pf_idx_i		),
		.pf_tag_i		(pf_tag_i		),

		.rd_data_o		(rd_data_o		),
		.rd_hit_o		(rd_hit_o		),
		.pf_hit_o		(pf_hit_o		)
	);

endmodule

