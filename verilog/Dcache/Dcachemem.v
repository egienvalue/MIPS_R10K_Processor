// ****************************************************************************
// Filename: Dcachemem.v
// Discription: cachemem for 1KB D-cache. Associativity  = 1 or 2 for analysis
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/16/2017
// 	<11/29> Modified evict during st iss and ld rsp
// ****************************************************************************

module Dcachemem (
		input											clk,
		input											rst,

		input											sq_wr_en_i,
		input			[`DCACHE_TAG_W-1:0]				sq_wr_tag_i,
		input			[`DCACHE_IDX_W-1:0]				sq_wr_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		sq_wr_data_i,
		output	logic									sq_wr_hit_o,
		output	logic									sq_wr_dty_o,

		input											mshr_rsp_wr_en_i,
		input			[`DCACHE_TAG_W-1:0]				mshr_rsp_wr_tag_i,
		input			[`DCACHE_IDX_W-1:0]				mshr_rsp_wr_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		mshr_rsp_wr_data_i,
		output	logic									mshr_rsp_wr_dty_o,

		input											mshr_iss_st_en_i,
		input			[`DCACHE_TAG_W-1:0]				mshr_iss_tag_i,
		input			[`DCACHE_IDX_W-1:0]				mshr_iss_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		mshr_iss_data_i,
		output	logic									mshr_iss_dty_o,

		input											mshr_evict_en_i,
		input			[`DCACHE_IDX_W-1:0]				mshr_evict_idx_i,
		output	logic	[`DCACHE_TAG_W-1:0]				mshr_evict_tag_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		mshr_evict_data_o,
		
		input			[`DCACHE_TAG_W-1:0]				lq_rd_tag_i,
		input			[`DCACHE_IDX_W-1:0]				lq_rd_idx_i,
		output	logic									lq_rd_hit_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		lq_rd_data_o,

		input											bus_invld_i,
		input											bus_downgrade_i,
		input			[`DCACHE_TAG_W-1:0]				bus_rd_tag_i,
		input			[`DCACHE_IDX_W-1:0]				bus_rd_idx_i,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus_rd_data_o,
		output	logic									bus_rd_hit_o
	);

	// cache array
	logic	[`DCACHE_SET_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_r[`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0][`DCACHE_TAG_W-1:0]		tag_r [`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0]							vld_r [`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0]							dty_r [`DCACHE_WAY_NUM-1:0];
	
	logic	[`DCACHE_SET_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_r_nxt[`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0][`DCACHE_TAG_W-1:0]		tag_r_nxt [`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0]							vld_r_nxt [`DCACHE_WAY_NUM-1:0];
	logic	[`DCACHE_SET_NUM-1:0]							dty_r_nxt [`DCACHE_WAY_NUM-1:0];

	//`ifdef	TWO_WAY
	logic	[`DCACHE_SET_NUM-1:0]							sel_r;
	logic	[`DCACHE_SET_NUM-1:0]							sel_r_nxt;
	//`endif

	logic	[`DCACHE_WAY_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	sq_data_w;
	logic	[`DCACHE_WAY_NUM-1:0]							sq_wr_hit_w;

	logic	[`DCACHE_WAY_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	lq_data_w;
	logic	[`DCACHE_WAY_NUM-1:0]							lq_rd_hit_w;

	logic	[`DCACHE_WAY_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	mshr_iss_data_w;
	logic	[`DCACHE_WAY_NUM-1:0]							mshr_iss_hit_w;
	logic													mshr_iss_hit;
	
	logic	[`DCACHE_WAY_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	mshr_rsp_data_w;
	logic	[`DCACHE_WAY_NUM-1:0]							mshr_rsp_hit_w;
	logic													mshr_rsp_hit;

	logic	[`DCACHE_WAY_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	bus_data_w;
	logic	[`DCACHE_WAY_NUM-1:0]							bus_rd_hit_w;

	//-----------------------------------------------------
	// load queue read port
	// combinational hit
	assign lq_rd_hit_o	= lq_rd_hit_w != 0;

	always_comb begin
		for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
			lq_data_w[i]	= data_r[i][lq_rd_idx_i];
			lq_rd_hit_w[i]	= vld_r[i][lq_rd_idx_i] && 
							  (tag_r[i][lq_rd_idx_i] == lq_rd_tag_i);
		end
	end
	
	always_comb begin
		lq_rd_data_o	= 64'h0;
		if (lq_rd_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (lq_rd_hit_w[i])
					lq_rd_data_o	= lq_data_w[i];
			end
		end
/*		end else begin
			lq_rd_tag_o		= tag_r[sel_r][lq_rd_idx_i];
			lq_rd_data_o	= data_r[sel_r][lq_rd_idx_i];
			lq_rd_dty_o		= dty_r[sel_r][lq_rd_idx_i];
			`ifdef TWO_WAY
			if (vld_r[0][lq_rd_idx_i] && vld_r[1][lq_rd_idx_i]) begin
				lq_rd_tag_o		= tag_r[sel_r][lq_rd_idx_i];
				lq_rd_data_o	= data_r[sel_r][lq_rd_idx_i];
				lq_rd_dty_o		= dty_r[sel_r][lq_rd_idx_i];
			end
			`else
			if (vld_r[0][lq_rd_idx_i]) begin
				lq_rd_tag_o		= tag_r[0][lq_rd_idx_i];
				lq_rd_data_o	= data_r[0][lq_rd_idx_i];
				lq_rd_dty_o		= dty_r[0][lq_rd_idx_i];
			end
			`endif
		end */
	end

	//-----------------------------------------------------
	// store queue write port out, evict data due to miss
	// combinational write back data out, tag, evict_en, hit
	assign sq_wr_hit_o	= sq_wr_hit_w != 0;
	assign sq_wr_dty_o	= dty_r[sel_r[sq_wr_idx_i]][sq_wr_idx_i];

	always_comb begin
		for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
			sq_data_w[i]	= data_r[i][sq_wr_idx_i];
			sq_wr_hit_w[i]	= vld_r[i][sq_wr_idx_i] && 
							  (tag_r[i][sq_wr_idx_i] == sq_wr_tag_i);
		end
	end

/*	always_comb begin
		sq_wb_tag_o		= `DCACHE_TAG_W'h0;
		sq_wb_data_o	= 64'h0;
		sq_wr_hit_o		= sq_wr_hit_w != 0;
		sq_wr_dty_o		= 1'b0;
		if (sq_wr_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (sq_wr_hit_w[i]) begin
					sq_wb_data_o	= sq_data_w[i];
					sq_wr_dty_o		= dty_r[i];
				end
			end
		end else begin
			sq_wb_tag_o		= tag_r[sel_r][sq_wr_idx_i];
			sq_wb_data_o	= data_r[sel_r][sq_wr_idx_i];
			sq_wr_dty_o		= dty_r[sel_r][sq_wr_idx_i];
		end
	end
*/

	//-----------------------------------------------------
	// bus read portmshr_wr_data_i
	// send requested block in S or M state
	always_comb begin
		for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
			bus_data_w[i]	= data_r[i][bus_rd_idx_i];
			bus_rd_hit_w[i]	= vld_r[i][bus_rd_idx_i] &&
							  (tag_r[i][bus_rd_idx_i] == bus_rd_tag_i);
		end
	end

	always_comb begin
		bus_rd_data_o	= 64'h0;
		bus_rd_hit_o	= bus_rd_hit_w != 0;
		if (bus_rd_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (bus_rd_hit_w[i])
					bus_rd_data_o	= bus_data_w[i];
			end
		end
	end


	//-----------------------------------------------------
	// mshr_iss port
	// check if the dty of the issuing block
	//assign mshr_iss_dty_o		= dty_r[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i];

	always_comb begin
		for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
			mshr_iss_data_w[i]	= data_r[i][mshr_iss_idx_i];
			mshr_iss_hit_w[i]	= vld_r[i][mshr_iss_idx_i] &&
								  (tag_r[i][mshr_iss_idx_i] == mshr_iss_tag_i);		
		end
	end

	always_comb begin
		mshr_iss_hit	= mshr_iss_hit_w != 0;
		mshr_iss_dty_o	= dty_r[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i];
		if (mshr_iss_hit) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (mshr_iss_hit_w[i]) 
					mshr_iss_dty_o	= dty_r[i][mshr_iss_idx_i];
			end
		end
	end

	//-----------------------------------------------------
	// mshr_rsp wr port
	// check if the dty of the ld block, evict if dty
	// assign mshr_rsp_wr_dty_o	= dty_r[sel_r[mshr_rsp_wr_idx_i]][mshr_rsp_wr_idx_i];
	
	always_comb begin
		for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
			mshr_rsp_data_w[i]	= data_r[i][mshr_rsp_wr_idx_i];
			mshr_rsp_hit_w[i]	= vld_r[i][mshr_rsp_wr_idx_i] &&
								  (tag_r[i][mshr_rsp_wr_idx_i] == mshr_rsp_wr_tag_i);		
		end
	end

	always_comb begin
		mshr_rsp_hit		= mshr_rsp_hit_w != 0;
		mshr_rsp_wr_dty_o	= dty_r[sel_r[mshr_rsp_wr_idx_i]][mshr_rsp_wr_idx_i];
		if (mshr_rsp_hit) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (mshr_rsp_hit_w[i]) 
					mshr_rsp_wr_dty_o	= dty_r[i][mshr_rsp_wr_idx_i];
			end
		end
	end


	//-----------------------------------------------------
	// mshr evict port
	assign mshr_evict_tag_o	= tag_r[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i];
	assign mshr_evict_data_o= data_r[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i];


	//-----------------------------------------------------
	// vld_r update, vld_r_nxt
	always_comb begin
		vld_r_nxt	= vld_r;
		// invld vld bit can be overwrite by others
		if (bus_invld_i && bus_rd_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (bus_rd_hit_w[i])
					vld_r_nxt[i][bus_rd_idx_i]	= 1'b0;
			end
		end
		if (mshr_rsp_wr_en_i) begin
			if (mshr_rsp_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_rsp_hit_w[i]) 
						vld_r_nxt[i][mshr_rsp_wr_idx_i] = 1'b1;
				end
			end else begin
				vld_r_nxt[sel_r[mshr_rsp_wr_idx_i]][mshr_rsp_wr_idx_i] = 1'b1;
			end
			/*`ifdef TWO_WAY
			if (vld_r[0][mshr_rsp_wr_idx_i] && vld_r[1][mshr_rsp_wr_idx_i])
				vld_r_nxt[sel_r][mshr_rsp_wr_idx_i] = 1'b1;
			else if (~vld_r[0][mshr_rsp_wr_idx_i])
				vld_r_nxt[0][mshr_rsp_wr_idx_i] = 1'b1;
			else
				vld_r_nxt[1][mshr_rsp_wr_idx_i] = 1'b1;
			`else
			vld_r_nxt[0][mshr_rsp_wr_idx_i] = 1'b1;
			`endif */
		end
		if (mshr_iss_st_en_i) begin
			if (mshr_iss_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_iss_hit_w[i]) 
						vld_r_nxt[i][mshr_iss_idx_i] = 1'b1;
				end
			end else begin
				vld_r_nxt[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i] = 1'b1;
			end
		end
		if (mshr_evict_en_i) begin
			vld_r_nxt[sel_r[mshr_evict_idx_i]][mshr_evict_idx_i] = 1'b0;
		end
	end
	
	//-----------------------------------------------------
	// dty_r update, dty_r_nxt	
	always_comb begin
		dty_r_nxt	 = dty_r;
		// invld and down grade can be overwrite if block
		// conflict in cachemem, bus_rd_idx_i = mshr_iss_idx_i
		if (bus_downgrade_i && bus_rd_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (bus_rd_hit_w[i])
					dty_r_nxt[i][bus_rd_idx_i]	= 1'b0;
			end
		end
		if (bus_invld_i && bus_rd_hit_o) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (bus_rd_hit_w[i])
					dty_r_nxt[i][bus_rd_idx_i]	= 1'b0;
			end
		end
		if (mshr_evict_en_i) begin
			dty_r_nxt[sel_r[mshr_evict_idx_i]][mshr_evict_idx_i] = 1'b0;
		end
		if (mshr_iss_st_en_i) begin
			if (mshr_iss_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_iss_hit_w[i]) 
						dty_r_nxt[i][mshr_iss_idx_i] = 1'b1;
				end
			end else begin
				dty_r_nxt[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i] = 1'b1;
			end
		end
	end

	//-----------------------------------------------------
	// data_r, tag_r update -> data_r_nxt, tag_r_nxt
	always_comb begin
		data_r_nxt	= data_r;
		tag_r_nxt	= tag_r;
		if (sq_wr_en_i) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (sq_wr_hit_w[i]) begin
					data_r_nxt[i][sq_wr_idx_i]	= sq_wr_data_i;
					tag_r_nxt[i][sq_wr_idx_i]	= sq_wr_tag_i;
				end
			end
		end
		if (mshr_rsp_wr_en_i) begin
			if (mshr_rsp_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_rsp_hit_w[i]) begin
						data_r_nxt[i][mshr_rsp_wr_idx_i]= mshr_rsp_wr_data_i;
						tag_r_nxt[i][mshr_rsp_wr_idx_i]	= mshr_rsp_wr_tag_i;
					end 
				end
			end else begin
				data_r_nxt[sel_r[mshr_rsp_wr_idx_i]][mshr_rsp_wr_idx_i]	= mshr_rsp_wr_data_i;
				tag_r_nxt[sel_r[mshr_rsp_wr_idx_i]][mshr_rsp_wr_idx_i]	= mshr_rsp_wr_tag_i;
			end
		end
		if (mshr_iss_st_en_i) begin // higher priority
			if (mshr_iss_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_iss_hit_w[i]) 
						data_r_nxt[i][mshr_iss_idx_i]	= mshr_iss_data_i;
						tag_r_nxt[i][mshr_iss_idx_i]	= mshr_iss_tag_i;
				end
			end else begin
				data_r_nxt[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i]	= mshr_iss_data_i;
				tag_r_nxt[sel_r[mshr_iss_idx_i]][mshr_iss_idx_i]	= mshr_iss_tag_i;
			end
		end
	end

	//-----------------------------------------------------
	// sel_r -> sel_r_nxt
	// priority matters !!!
	always_comb begin
		sel_r_nxt	= sel_r;
		`ifdef TWO_WAY
		if (lq_rd_hit_o) begin // hit
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (lq_rd_hit_w[i])
					sel_r_nxt[lq_rd_idx_i]	= (i == 0) ? 1'b1 : 1'b0;
			end
		end
		if (mshr_rsp_wr_en_i) begin // miss and ~dty
			if (mshr_rsp_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_rsp_hit_w[i])
						sel_r_nxt[mshr_rsp_wr_idx_i] = (i == 0) ? 1'b1 : 1'b0;
				end
			end else begin
				sel_r_nxt[mshr_rsp_wr_idx_i]	= ~sel_r[mshr_rsp_wr_idx_i];
			end
		end
		if (sq_wr_en_i) begin // hit and dty
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				if (sq_wr_hit_w[i])
					sel_r_nxt[sq_wr_idx_i]	= (i == 0) ? 1'b1 : 1'b0;
			end
		end
		if (mshr_iss_st_en_i) begin // miss and ~dty
			if (mshr_iss_hit) begin
				for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
					if (mshr_iss_hit_w[i]) 
						sel_r_nxt[mshr_iss_idx_i] = (i == 0) ? 1'b1 : 1'b0;
				end
			end else begin
				sel_r_nxt[mshr_iss_idx_i] = ~sel_r[mshr_iss_idx_i];
			end
		end
		`else
		sel_r_nxt	= 1'b0;
		`endif
	end

	// synopsys sync_set_rest "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			for (int i = 0; i < `DCACHE_WAY_NUM; i++) begin
				vld_r[i]	<= `SD 0;
				dty_r[i]	<= `SD 0;
				tag_r[i]	<= `SD {`DCACHE_SET_NUM{`DCACHE_TAG_W'h0}};
				data_r[i]	<= `SD {`DCACHE_SET_NUM{64'h0}};
			end
			sel_r	<= `SD {`DCACHE_SET_NUM{1'b0}};
		end else begin
			vld_r	<= `SD vld_r_nxt;
			dty_r	<= `SD dty_r_nxt;
			tag_r	<= `SD tag_r_nxt;
			data_r	<= `SD data_r_nxt;
			sel_r	<= `SD sel_r_nxt;
		end	
	end	


endmodule: Dcachemem
		
