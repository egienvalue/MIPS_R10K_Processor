module train (
		input			clk,
		input			rst,
		input									br_outcome_i,
		input	[63:0]							if_br_PC_i,
		input	[63:0]							fu_br_PC_i,
		input									y_out_i,
		input									training_en_i,
		input									BHR_i,
		input	[`BHR_W:0][`WEIGHT_W-1:0]		selected_weight_i,
			
		output	[`BHR_W:0][`WEIGHT_W-1:0]		new_weight_o,
		output	[`PT_IDX_W-1:0]					tr2pt_wr_idx_o,
		output									tr2pt_wr_en_o			
	
	);

	logic	signed	[`PT_W-1:0][`WEIGHT_W-1:0]	y_out;
	logic	signed	[`WEIGHT_W-1:0]				y_out_nxt;

	assign tr2pt_wr_en_o	= training_en_i;
	assign y_out_nxt	= y_out_i;
	assign tr2pt_wr_idx_o	= fu_br_PC_i[`PT_W-1:0];

	always_comb begin
		if (y_out[fu_br_PC_i[`PT_IDX_W-1:0]]<`THRESHOLD) begin
			for (int i;i<`BHR_W;i++) begin
				if(br_outcome_i==BHR_i[i])
					new_weight_o[i] = selected_weight[i]+1;
			else
					new_weight_o[i] = selected_weight[i]-1;
			end
		end	else begin
			new_weight_o	= selected_weight_i;
		end
	end
	
	always_ff @(posedge clk) begin
		if(rst)
			y_out	<= `SD 0;
		else 
			y_out[if_br_PC_i[`PT_IDX_W-1:0]]	<= `SD y_out_nxt;
	end



endmodule
