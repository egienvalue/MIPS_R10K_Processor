// ****************************************************************************
// Filename: cachemem.v
// Discription: 1-way for 1KB I-cache with 4-entry victim cache
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/17/2017
// 	edited: 10/21/2017, merge victim cache with main cache (1-way)
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
		input										pf_prefetching_i,

		output		[`ICACHE_DATA_IN_BITS-1:0]		rd_data_o,
		output										rd_hit_o,
		output										pf_hit_o
	);
	
	// cache array
	logic	[`ICACHE_D-1:0][`ICACHE_LINE_IN_BITS-1:0]	data_r;
	logic	[`ICACHE_D-1:0][`ICACHE_TAG_W-1:0]			tag_r;
	logic	[`ICACHE_D-1:0]								vld_r;
	wire												main_rd_hit;

	// victim cache 4-entry
	logic	[3:0][`ICACHE_LINE_IN_BITS-1:0]			vt_data_r;
	logic	[3:0][`ICACHE_TAG_W-1:0]				vt_tag_r;
	logic	[3:0][`ICACHE_IDX_W-1:0]				vt_idx_r;
	logic	[3:0]									vt_vld_r;
	logic	[1:0]									vt_wr_ptr_r;

	logic	[3:0][`ICACHE_LINE_IN_BITS-1:0]			vt_data_line_w;
	logic	[`ICACHE_LINE_IN_BITS-1:0]				vt_data_line;
	logic	[`ICACHE_LINE_IN_BITS-1:0]				vt_pf_data_line;

	wire											vt_update;
	wire											vt_wr_en;

	logic	[3:0]									vt_rd_hit_w;
	logic											vt_rd_hit;

	// prefetch
	logic	[3:0]									pf_vt_hit_w;
	logic											pf_vt_hit;
	wire											pf_main_hit;
	wire											pf_vt_wr_en;

	// combinational read out
	assign rd_data_o = main_rd_hit ? data_r[rd_idx_i] : vt_data_line;
	assign rd_hit_o	 = main_rd_hit | vt_rd_hit;
	assign main_rd_hit = vld_r[rd_idx_i] && (tag_r[rd_idx_i]==rd_tag_i);

	// victim cache signals
	// <11/15> vt_rd_hit initiation has glitches
	// 		   can use vt_rd_hit = |vt_match[3:0] -> done <12/7>
	assign vt_rd_hit	= |vt_rd_hit_w;
	assign pf_vt_hit	= |pf_vt_hit_w;

	always_comb begin
		for (int i = 0; i < 4; i++) begin
			vt_rd_hit_w[i]	= {rd_tag_i,rd_idx_i,1'b1} ==
							   {vt_tag_r[i],vt_idx_r[i],vt_vld_r[i]};
			pf_vt_hit_w[i]	= {pf_tag_i,pf_idx_i,1'b1} ==
							  {vt_tag_r[i],vt_idx_r[i],vt_vld_r[i]};
			vt_data_line_w[i]= vt_data_r[i];
		end
	end

	always_comb begin
		vt_data_line	= vt_data_line_w[0];
		vt_pf_data_line	= vt_data_line_w[0];
		for (int i = 0; i < 4; i++) begin
			if (vt_rd_hit_w[i])
				vt_data_line	= vt_data_line_w[i];
			if (pf_vt_hit_w[i])
				vt_pf_data_line	= vt_data_line_w[i];
		end
	end

	
	assign vt_update	= wr_en_i && vld_r[wr_idx_i];
	assign vt_wr_en		= ~main_rd_hit && vt_rd_hit;

	// prefetch hit?
	assign pf_hit_o		= pf_main_hit | pf_vt_hit;
	assign pf_main_hit	= vld_r[pf_idx_i] && (tag_r[pf_idx_i] == pf_tag_i);
	assign pf_vt_wr_en	= ~pf_main_hit && pf_vt_hit && pf_prefetching_i;

	// main cache date update sequential logic	
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			vld_r		<= `SD 0;
			data_r		<= `SD {`ICACHE_D{64'h0}};
			tag_r		<= `SD {`ICACHE_D{`ICACHE_TAG_W'b0}};
		end else begin
			if (wr_en_i) begin // data from maim memory
				vld_r[wr_idx_i]		<= `SD 1'b1;
				data_r[wr_idx_i]	<= `SD wr_data_i;
				tag_r[wr_idx_i]		<= `SD wr_tag_i;
			end if (vt_wr_en) begin // move from vcache to main cache
				vld_r[rd_idx_i]		<= `SD 1'b1;
				data_r[rd_idx_i]	<= `SD vt_data_line;
				tag_r[rd_idx_i]		<= `SD rd_tag_i;
			end if (pf_vt_wr_en) begin
				vld_r[pf_idx_i]		<= `SD 1'b1;
				data_r[pf_idx_i]	<= `SD vt_pf_data_line;
				tag_r[pf_idx_i]		<= `SD pf_tag_i;
			end	
		end
	end

	// victim update sequential logic
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			vt_wr_ptr_r	<= `SD 2'b0;
			vt_vld_r	<= `SD 4'b0;
			vt_data_r	<= `SD {4{64'h0}};
			vt_tag_r	<= `SD {4{`ICACHE_TAG_W'b0}};
			vt_idx_r	<= `SD {4{`ICACHE_IDX_W'b0}};
		end else if (vt_update) begin // vcache capture date evicted
			vt_wr_ptr_r				<= `SD vt_wr_ptr_r + 1;
			vt_vld_r[vt_wr_ptr_r]	<= `SD 1'b1;
			vt_data_r[vt_wr_ptr_r]	<= `SD data_r[wr_idx_i];
			vt_tag_r[vt_wr_ptr_r]	<= `SD tag_r[wr_idx_i];
			vt_idx_r[vt_wr_ptr_r]	<= `SD wr_idx_i;
		end
	end
			

endmodule


