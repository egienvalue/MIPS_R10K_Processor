`timescale 1ns/100ps
module predict (
		input								predict_en_i,
		input	signed	[`WEIGHT_W-1:0]	sel_pt_weight_i[`BHR_W:0],
		input	[`BHR_W-1:0]				BHR_i,

		output	logic						predict_result_o,
		output	logic	signed	[`WEIGHT_W-1:0]	sum_o
	//	output	[`WEIGHT_W-1:0]				m_o
	);
	
	logic	[`BHR_W:0]		x;
	logic	signed	[`WEIGHT_W-1:0]	temp_weight[`BHR_W:0];
	logic	signed	[`WEIGHT_W-1:0]				result;
	assign x		= {1'b1,BHR_i};
	assign sum_o	= predict_en_i ? result : 0 ;
	assign predict_result_o	= predict_en_i ? (result>0) : 0;
	always_comb begin
		for(int i=0;i<=`BHR_W;i++) begin
				temp_weight[i]= (~predict_en_i) ? 0: 
								(x[i]==0) ? -sel_pt_weight_i[i] : sel_pt_weight_i[i];
		end
	end
	assign result = ((temp_weight[0]+temp_weight[1])+(temp_weight[2]+temp_weight[3]))+((temp_weight[4]+temp_weight[5])+((temp_weight[6]+temp_weight[7])+temp_weight[8]));
	
endmodule
