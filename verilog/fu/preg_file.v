module preg_file(
		input						clk,
		input						rst,
		input						wr_en_i,
		input	[`PRF_IDX_W-1:0]	rda_idx_i,rdb_idx_i, wr_idx_i,
		input						wr_data_i,


		output	logic	[63:0]		rda_data_o, rdb_data_o
	
		);

	logic	[`PRF_NUM-1:0][63:0]	reg_data_r;
		
	wire	[63:0]		rda_reg = reg_data_r[rda_idx_i];
	wire	[63:0]		rdb_reg = reg_data_r[rdb_idx_i];
	
	always_comb begin
		if(rda_idx_i == `ZERO_REG)
			rda_data_o = 0;
		else if (wr_en_i && (wr_idx_i == rda_idx_i))
			rda_data_o = wr_data_i;
		else
			rda_data_o = rda_reg;
	end
	
		
	always_comb begin
		if(rdb_idx_i == `ZERO_REG)
			rdb_data_o = 0;
		else if (wr_en_i && (wr_idx_i == rdb_idx_i))
			rdb_data_o = wr_data_i;
		else
			rdb_data_o = rdb_reg;
	end

	always_ff @(posedge clk) begin
		if(rst)
			reg_data_r <= `SD 0;
		else if (wr_en_i)
			reg_data_r[wr_idx_i] <= `SD wr_data_i;
	end


endmodule
