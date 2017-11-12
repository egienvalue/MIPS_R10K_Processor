module perceptron (
	input			clk,
	input			rst,
	input	[63:0]	if2pt_PC_i,
	input			fu2pt_br_taken_i,
	input			fu2pt_br_PC_i,
	input			fu2pt_cond_br_i,
	input			fu2pt_done_i,

	output			prediction_o
	
	
	);

	logic									clk;
	logic									rst;
	
	logic	[`BHR_W-1:0]					BHR, BHR_nxt;

	//training
	logic									br_outcome_i;
	logic	[63:0]							if_br_PC_i;fu2pt_cond_br_i
	logic	[63:0]							fu_br_PC_i;
	logic									y_out_i;
	logic									training_en_i;
	logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]		selected_weight_i;
	
	logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]		new_weight_o;
	logic	[`PT_IDX_W-1:0]					tr2pt_wr_idx_o;
	logic									tr2pt_wr_en_o;	
	//pt_table
    logic                               		pt_wr_en_i;
	logic   [`PT_IDX_W-1:0]						pt_rd2_idx_i;
    logic   [`PT_IDX_W-1:0]             		pt_rd1_idx_i;
    logic   [`PT_IDX_W-1:0]             		pt_wr_idx_i;
    logic   signed	[`BHR_W:0][`WEIGHT_W-1:0]   pt_wr_weight_i;

    logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]   pt_rd1_weight_o;
	logic	signed	[`BHR_W:0][`WEIGHT_W-1:0]	pt_rd2_weight_o;

	//predict
	logic	signed 	[`BHR_W:0][`WEIGHT_W-1:0]	sel_pt_weight_i;
	logic			[`BHR_W-1:0]				BHR_i;

	logic										predict_result_o;
	logic	signed	[`WEIGHT_W-1:0]				sum_o;


	assign BHR_nxt		= ~fu2pt_done_i ? BHR : 
							fu2pt_cond_br_i ? {BHR[`BHR_W-2:0],fu2pt_br_taken_i} : BHR;

	assign prediction_o	= predict_result_o;

	//instantiation 
	
	assign br_outcome_i	= fu2pt_br_taken;
	assign if_br_PC_i	= if2pt_PC_i;
	assign fu_br_PC_i	= fu2pt_br_PC_i;
	assign y_out_i		= sum_o;
	assign training_en_i= fu2pt_br_done_i&fu2pt_cond_br_i;
	assign BHR_i		= BHR;
	assign selected_weight_i	= pt_rd2_weight_o;	
	train train1 (
		.clk,
		.rst,
		.br_outcome_i,
		.if_br_PC_i,
		.fu_br_PC_i,
		.y_out_i,
		.training_en_i,
		.BHR_i,
		.selected_weight_i,
		.new_weight_o,
		.tr2pt_wr_idx_o,
		.tr2pt_wr_en_o	
	);

	assign pt_wr_en_i	= tr2pt_wr_en_o;
	assign pt_rd1_idx_i	= if2pt_PC_i[`PT_IDX_W-1:0];
	assign pt_rd2_idx_i	= fu2pt_br_PC_i[`PT_IDX_W-1:0];
	assign pt_wr_idx_i	= tr2pt_wr_idx_o;
	assign pt_wr_weight_i	= new_weight_o;	
	pt_table (
		.clk,
        .rst,

        .pt_wr_en_i,
		.pt_rd2_idx_i,
        .pt_rd1_idx_i,
        .pt_wr_idx_i,
        .pt_wr_weight_i,

        .pt_rd1_weight_o,
		.pt_rd2_weight_o

	);
	
	assign sel_pt_weight_t	= pt_rd1_weight_o;

	predict (
		.sel_pt_weight_i,
		.BHR_i,
		.predict_result_o,
		.sum_o

	);


	always_ff @(posedge clk) begin
		if(rst)
			BHR = 0;
		else
			BHR = BHR_nxt;
	end	
endmodule
