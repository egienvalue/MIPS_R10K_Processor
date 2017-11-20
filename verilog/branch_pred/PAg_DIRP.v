

module PAg_DIRP(
	input						clk,
    input						rst,
	input	[63:0]				if_pc_i,			//[IF]
    input						ex_is_br_i,			//[EX]
	input						ex_is_cond_i,	//[EX]
	input						ex_is_taken_i,		//[EX]
    input	[63:0]				ex_pc_i,			//[EX]
    
    output						pred_o
	);
	
	logic	[`PHT_NUM-1:0][1:0]	 PHT;	// Use bimodal/saturation counter.	
	logic	[`BHT_NUM-1:0][`BHT_W-1:0]	BHT;
	logic	[`BHT_NUM-1:0][`BHT_W-1:0]	next_BHT;
	logic	[`PC_IDX_W-1:0] if_pc_idx, ex_pc_idx;

	assign	if_pc_idx = if_pc_i[`PC_IDX_W+1:2];
	assign	ex_pc_idx = ex_pc_i[`PC_IDX_W+1:2];
	assign  pred_o	  = PHT[BHT[if_pc_idx]];

	// Comb assign next_BHT
	always_comb begin
		next_BHT = BHT;
		if (ex_is_cond_i) begin
			next_BHT[ex_pc_idx] = {BHT[ex_pc_idx][`BHT_W-2:0], ex_is_taken_i};
		end	
	end

	// Seq assign BHT
	always_ff @(posedge clk) begin
		if (rst) begin
			BHT <= `SD 0;
		end else begin
			BHT <= `SD next_BHT;
		end
	end

	// Seq change the state of resolved PHT entry
	always_ff @(posedge clk) begin
		if (rst) begin
			PHT <=`SD 0;
		end else if (ex_is_br_i && ex_is_cond_i) begin
			if (ex_is_taken_i) begin
				case(PHT[ex_pc_idx]) 
					2'b11 :   PHT[ex_pc_idx] <= `SD 2'b11;  
			        2'b10   :   PHT[ex_pc_idx] <= `SD 2'b11;
			        2'b01  :   PHT[ex_pc_idx] <= `SD 2'b10;
			        2'b00:   PHT[ex_pc_idx] <= `SD 2'b01;
				endcase
			end else begin
				case(PHT[ex_pc_idx]) 
            		2'b11 :   PHT[ex_pc_idx] <= `SD 2'b10;  
                    2'b10   :   PHT[ex_pc_idx] <= `SD 2'b01;
                    2'b01  :   PHT[ex_pc_idx] <= `SD 2'b00;
                    2'b00:   PHT[ex_pc_idx] <= `SD 2'b00;
				endcase
			end
		end else begin
			PHT <= `SD PHT;
		end
	end
endmodule




