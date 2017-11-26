module train (
		input			clk,
		input			rst,
		input									br_outcome_i,
		input	[63:0]							if_br_PC_i,
		input	[63:0]							fu_br_PC_i,
		input									y_vld_i,						
		input	signed	[`WEIGHT_W-1:0]			y_out_i,
		input									training_en_i,
		input	[`BHR_W-1:0]					BHR_i,
		input	signed	[`WEIGHT_W-1:0]			sel_weight_i[`BHR_W:0],
			
		output	logic	signed	[`WEIGHT_W-1:0]	new_weight_o[`BHR_W:0],
		output	logic	[`PT_IDX_W-1:0]			tr2pt_wr_idx_o,
		output	logic							tr2pt_wr_en_o			
	
	);

	logic	signed	[`WEIGHT_W-1:0]	y_out[`PT_W-1:0];
	logic	signed	[`WEIGHT_W-1:0]	y_out_nxt;
	logic	[`BHR_W:0]	x;	
	logic	traning_stop;
	assign tr2pt_wr_en_o	= training_en_i;
	assign y_out_nxt		= (y_vld_i) ? y_out_i : y_out[if_br_PC_i[`PT_IDX_W-1:0]];
	assign tr2pt_wr_idx_o	= fu_br_PC_i[`PT_W-1:0];
	assign	x	= {1'b1,BHR_i};
	assign training_stop = ((y_out[fu_br_PC_i[`PT_IDX_W-1:0]]>`THRESHOLD) || (-y_out[fu_br_PC_i[`PT_IDX_W-1:0]]>`THRESHOLD));
	always_comb begin
		for (int i=0;i<=`BHR_W;i++) begin
			new_weight_o[i] = (~training_en_i) ? sel_weight_i[i] : 
							  (training_stop) ? sel_weight_i[i] : 
							  (br_outcome_i==x[i])? (sel_weight_i[i]+1) : (sel_weight_i[i]-1);
							  //(sel_weight_i[i]==0)? (sel_weight_i[i]) : (sel_weight_i[i]-1);
		end
	end
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if(rst) begin
			for (int i=0;i<`PT_W;i++) begin
				y_out[i]	<= `SD 0;
			end
		end
		else 
			y_out[if_br_PC_i[`PT_IDX_W-1:0]]	<= `SD y_out_nxt;
	end
endmodule
