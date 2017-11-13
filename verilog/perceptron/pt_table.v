module pt_table (
        
        input   clk,
        input   rst,

        input                               				pt_wr_en_i,
		input	[`PT_IDX_W-1:0]								pt_rd2_idx_i,
        input   [`PT_IDX_W-1:0]             				pt_rd1_idx_i,
        input   [`PT_IDX_W-1:0]             				pt_wr_idx_i,
        input   [`BHR_W:0][`WEIGHT_W-1:0]   				pt_wr_weight_i,

        output  logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]   pt_rd1_weight_o,
		output	logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]	pt_rd2_weight_o

    );
    

    logic	signed	[`PT_W-1:0][`BHR_W:0][`WEIGHT_W-1:0]    pt_weight_r;
	logic	signed				[`BHR_W:0][`WEIGHT_W-1:0]	pt_weight_r_nxt;

    always_comb begin
		if (pt_wr_en_i) begin
			if(pt_rd1_idx_i==pt_wr_idx_i)
				pt_rd1_weight_o=pt_wr_weight_i;
			else
				pt_rd1_weight_o=pt_weight_r[pt_rd1_idx_i];
		end else 
			pt_rd1_weight_o=pt_weight_r[pt_rd1_idx_i];
    end

	always_comb begin
		if (pt_wr_en_i) begin
			if(pt_rd2_idx_i==pt_wr_idx_i)
				pt_rd2_weight_o=pt_wr_weight_i;
			else
				pt_rd2_weight_o=pt_weight_r[pt_rd2_idx_i];
		end else 
			pt_rd2_weight_o=pt_weight_r[pt_rd2_idx_i];
    end

	always_comb begin
		if (pt_wr_en_i) begin
			pt_weight_r_nxt = pt_wr_weight_i;
		else
			pt_weight_r_nxt	= pt_weight_r[pt_wr_idx_i];

	end
	
	always_ff @(posedge clk) begin
		if (rst)
			pt_weight_r	<= `SD 0;
		else 
			pt_weight_r[pt_wr_idx_i]	<= `SD pt_weight_r_nxt;
	end


endmodule

