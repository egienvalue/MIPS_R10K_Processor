// ****************************************************************************
// Filename: Icache.v
// Description: top level module for Icache system, including 'cachemem',
// 		'prefetch', 'Icache_ctrl'
// Author: Hengfei Zhong
// Version History:
// 	<10/27> initial creation
// ****************************************************************************

`timescale 1ns/100ps

module Icache (
		input											clk,
		input											rst,
		
		input			[3:0]							Imem2proc_response_i,
		input			[63:0]							Imem2Icache_data_i,
		input			[3:0]							Imem2proc_tag_i,

		input			[63:0]							if2Icache_addr_i,
		input											if2Icache_flush_i,

		output			[63:0]							proc2Imem_addr_o,
		output			[1:0]							proc2Imem_command_o,

		output											Icache2if_vld_o,
		output			[`ICACHE_DATA_IN_BITS-1:0]		Icache2if_data_o
	);

	// signals for cachemem connection
	logic								cache_wr_en;
	logic		[`ICACHE_TAG_W-1:0]		cache_wr_tag;
	logic		[`ICACHE_IDX_W-1:0]		cache_wr_idx;
	logic		[`ICACHE_TAG_W-1:0]		cache_rd_tag;
	logic		[`ICACHE_IDX_W-1:0]		cache_rd_idx;
	logic		[`ICACHE_TAG_W-1:0]		cache_pf_tag;
	logic		[`ICACHE_IDX_W-1:0]		cache_pf_idx;
	logic								cache_prefetching;
	logic		[63:0]					cache_rd_data;
	logic								cache_rd_hit;
	logic								cache_pf_hit;

	// signals for Ictrl
	logic								Ictrl2Icache_wr_en;
	logic		[`ICACHE_TAG_W-1:0]		Ictrl2Icache_wr_tag;
	logic		[`ICACHE_IDX_W-1:0]		Ictrl2Icache_wr_idx;
	logic		[63:0]					Ictrl2pfetch_addr;
	logic								Ictrl2pfetch_en;
	logic		[63:0]					Ictrl2Imem_addr;
	logic		[1:0]					Ictrl2Imem_command;
	
	// pfetch signals
	logic								pfetch2Icache_wr_en;
	logic		[`ICACHE_TAG_W-1:0]		pfetch2Icache_wr_tag;
	logic		[`ICACHE_IDX_W-1:0]		pfetch2Icache_wr_idx;
	logic								pfetch2Ictrl_hit;
	logic		[63:0]					pfetch2Imem_addr;
	logic		[1:0]					pfetch2Imem_command;
	
	// cache write
	assign cache_wr_en = Ictrl2Icache_wr_en | pfetch2Icache_wr_en;
	assign cache_wr_tag= pfetch2Icache_wr_en ? pfetch2Icache_wr_tag : Ictrl2Icache_wr_tag;
	assign cache_wr_idx= pfetch2Icache_wr_en ? pfetch2Icache_wr_idx : Ictrl2Icache_wr_idx;

	// addr and command to Imem
	assign proc2Imem_addr_o = Ictrl2pfetch_en ? pfetch2Imem_addr : Ictrl2Imem_addr;
	assign proc2Imem_command_o = Ictrl2pfetch_en ? pfetch2Imem_command : Ictrl2Imem_command;

	// Module instantiation
	cachemem cachemem0 (
		.clk		(clk		),
		.rst		(rst	),

		.wr_en_i		(cache_wr_en		),
		.wr_idx_i		(cache_wr_idx		),
		.wr_tag_i		(cache_wr_tag		),
		.wr_data_i		(Imem2Icache_data_i	),
		.rd_idx_i		(cache_rd_idx		),
		.rd_tag_i		(cache_rd_tag		),
		
		.pf_idx_i		(cache_pf_idx		),
		.pf_tag_i		(cache_pf_tag		),
		.pf_prefetching_i(cache_prefetching	),

		.rd_data_o		(cache_rd_data		),
		.rd_hit_o		(cache_rd_hit		),
		.pf_hit_o		(cache_pf_hit		)
	);


	Icache_ctrl Icache_ctrl0 (
		.clk		(clk		),
		.rst		(rst		),
		
		.Imem2proc_tag_i		(Imem2proc_tag_i		),
		.Imem2proc_response_i	(Imem2proc_response_i		),

		.cachemem_data_i	(cache_rd_data		),
		.cachemem_hit_i		(cache_rd_hit		),

		.if2Icache_addr_i		(if2Icache_addr_i		),
		.if2Icache_flush_i		(if2Icache_flush_i		), // wrong BP

		.pfetch2Ictrl_hit_i		(pfetch2Ictrl_hit		),

		.Icache2if_vld_o		(Icache2if_vld_o		),
		.Icache2if_data_o		(Icache2if_data_o	),
		
		.Ictrl2Icache_wr_en_o		(Ictrl2Icache_wr_en	),
		.Ictrl2Icache_wr_idx_o		(Ictrl2Icache_wr_idx),
		.Ictrl2Icache_wr_tag_o		(Ictrl2Icache_wr_tag),
		.Ictrl2Icache_rd_idx_o		(cache_rd_idx		),
		.Ictrl2Icache_rd_tag_o		(cache_rd_tag		),
		
		.Ictrl2pfetch_addr_o		(Ictrl2pfetch_addr		),
		.Ictrl2pfetch_en_o			(Ictrl2pfetch_en		),

		.Ictrl2Imem_addr_o		(Ictrl2Imem_addr		),
		.Ictrl2Imem_command_o	(Ictrl2Imem_command		)
	);


	prefetch prefetch0 (
		.clk		(clk		),
		.rst		(rst	),
		
		.Imem2proc_tag_i		(Imem2proc_tag_i		),
		.Imem2proc_response_i	(Imem2proc_response_i		),

		.cachemem_hit_i			(cache_rd_hit		), // fetch hit on cache
		.Icache2pfetch_hit_i	(cache_pf_hit		), // pfetch hit on cache

		.if2pfetch_flush_i		(if2Icache_flush_i		),

		.Ictrl2pfetch_addr_i	(Ictrl2pfetch_addr		),
		.Ictrl2pfetch_en_i		(Ictrl2pfetch_en		),

		.pfetch2Ictrl_hit_o		(pfetch2Ictrl_hit		), // fetch hit on pfetch
		
		.pfetch2Icache_prefetching_o(cache_prefetching		),
		.pfetch2Icache_wr_en_o		(pfetch2Icache_wr_en	),
		.pfetch2Icache_wr_tag_o		(pfetch2Icache_wr_tag	),
		.pfetch2Icache_wr_idx_o		(pfetch2Icache_wr_idx	),
		.pfetch2Icache_rd_tag_o		(cache_pf_tag			),
		.pfetch2Icache_rd_idx_o		(cache_pf_idx			),
		//.pfetch2Icache_data_o		(		),

		.pfetch2Imem_addr_o		(pfetch2Imem_addr		),
		.pfetch2Imem_command_o	(pfetch2Imem_command		)
	);

endmodule
