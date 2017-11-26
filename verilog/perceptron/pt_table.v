module pt_table (
        
        input   clk,
        input   rst,

        input                       pt_wr_en_i,
		input	[`PT_IDX_W-1:0]		pt_rd2_idx_i,
        input   [`PT_IDX_W-1:0]     pt_rd1_idx_i,
        input   [`PT_IDX_W-1:0]     pt_wr_idx_i,
        input	signed	[`WEIGHT_W-1:0]   	pt_wr_weight_i[`BHR_W:0],

        output  logic	signed	[`WEIGHT_W-1:0] pt_rd2_weight_o[`BHR_W:0],
		output	logic	signed	[`WEIGHT_W-1:0]	pt_rd1_weight_o[`BHR_W:0]

    );


    logic	signed	[`WEIGHT_W-1:0]	pt_weight_r[`PT_W-1:0][`BHR_W:0];
	logic	signed	[`WEIGHT_W-1:0]	pt_weight_r_nxt[`BHR_W:0];

	assign	pt_weight_r_nxt = (pt_wr_en_i) ? pt_wr_weight_i : pt_weight_r[pt_wr_idx_i];
	assign	pt_rd2_weight_o	= pt_weight_r[pt_rd2_idx_i];
	assign	pt_rd1_weight_o = pt_weight_r[pt_rd1_idx_i];

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			for(int i=0;i<`PT_W;i++) begin
				for (int j=0;j<=`BHR_W;j++) begin
					pt_weight_r[i][j]	<= `SD 0;
				end
			end
		end	else 
			for(int j=0;j<=`BHR_W;j++) begin
				pt_weight_r[pt_wr_idx_i][j]	<= `SD pt_weight_r_nxt[j];
			end
	end


endmodule
