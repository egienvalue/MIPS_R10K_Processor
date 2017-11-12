module predict (
		input	signed 	[`BHR_W:0][`WEIGHT_W-1:0]	sel_pt_weight_i,
		input	[`BHR_W-1:0]				BHR_i,

		output								predict_result_o,
		output	signed	[`WEIGHT_W-1:0]		sum_o
	);
	
	logic	[`BHR_W:0]		x;
	lgoci	signed	[`BHR_W:0][`WEIGHT_W-1:0]	temp_weight;
	logic	signed	[`WEIGHT_W-1:0]				pre_result;

	assign x		= {BHR_i,1'b1};
	assign sum_o	= pre_result;
	assign predict_result_o	= pre_result[`WEIGHT_W-1];
	always_comb begin
		for(int i;i<`BHR_W;i++) begin
			if (x[i]==0)
				temp_weight[i]=sel_pt_weight_i[i];
			else
				temp_weight[i]=-sel_pt_weight_i[i];
		end
	end
	always_comb begin
		pre_result = 0;
		for(int i;i<`BHR_W;i++) begin
			pre_result = present+temp_weight[i];
		end
	end
	
endmodule

