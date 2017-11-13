typedef enum {
  STRONG_T	= 2'b11,
  WEAK_T	= 2'b10,
  WEAK_NT   = 2'b01,
  STRONG_NT = 2'b00
} P_STATE;

  

module PAg_DIRP(
	input						clk,
    input						rst,
	input	[63:0]				if_pc_i,			//[IF]
    //input						btb_is_cond_br_i,	//[BTB] 
    //input	[`BR_STATE_W-1:0]	ex_reslv_i,			//[EX]
    input						ex_is_br_i,			//[EX]
	input						ex_is_cond_i,	//[EX]
	input						ex_is_taken_i,		//[EX]
    input	[63:0]				ex_pc_i,			//[EX]
    
    output						pred_o
	);
	
	P_STATE	PHT [`PHT_NUM-1:0];	// Use bimodal/saturation counter.	
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
			next_BHT[if_pc_idx] = {BHT[if_pec_idx][`BHT_W-2:0], ex_is_taken_i};
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
			if (ex_is_taken) begin
				case(PHT[ex_pc_idx]) 
					STRONG_T :   PHT[ex_pc_idx] <= `SD STRONG_T;  
			        WEAK_T   :   PHT[ex_pc_idx] <= `SD STRONG_T
			        WEAK_NT  :   PHT[ex_pc_idx] <= `SD WEAK_T;
			        STRONG_NT:   PHT[ex_pc_idx] <= `SD WEAK_NT;
				endcase
			end else begin
				case(PHT[ex_pc_idx]) 
            		STRONG_T :   PHT[ex_pc_idx] <= `SD WEAK_T;  
                    WEAK_T   :   PHT[ex_pc_idx] <= `SD WEAK_NT
                    WEAK_NT  :   PHT[ex_pc_idx] <= `SD STRONG_NT;
                    STRONG_NT:   PHT[ex_pc_idx] <= `SD STRONG_NT;
				endcase
			end
		end else begin
			PHT <= `SD PHT;
		end
	end
endmodule




