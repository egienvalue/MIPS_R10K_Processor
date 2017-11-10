typedef enum {
  STRONG_T	= 2'b11,
  WEAK_T	= 2'b10,
  WEAK_NT   = 2'b01,
  STRONG_NT = 2'b00
} P_STATE;

   
module DIRP(
	input						clk;
	input						rst;
	input						is_br_i,
	input	[`BR_STATE_W-1:0]	reslv_i, 
	input						is_taken_i;
	input	[`BHR_W-1:0]		recrv_BHR_i,

	output						pred_o,
	output	[`BHR_W-1:0]		save_BHR_o
	);

	localparam 
	
	P_STATE	PHT [`PHT_NUM-1:0];	// Use bimodal/saturation counter.		
	logic	[`BHR_W-1:0]		BHR;
	logic	[`BHR_W-1:0]		next_BHR;
	logic						pred;

	// Comb assign pred.
	assign pred = PHT[BHR][1];
	assign pred_o = pred;
	
	// Comb assign next_BHR
	always_comb	begin
		if (reslv_i == `BR_PR_CORRECT) begin
			next_BHR = {recrv_BHR_i[`BHR_W-2:0], 0};
		end else if (is_br_i) begin
			next_BHR = {BHR[`BHR_W-2:0], pred};
		end else begin
			next_BHR = BHR;
		end
	end

	// Seq assign BHR.
	always_ff @(posedge clk) begin
		if (rst) begin
			BHR <= `SD `BHR_W'b0;
		end else begin
			BHR <= `SD next_BHR;
		end
	end

	// Seq change the state of resolved PHT entry
	always_ff @(posedge clk) begin
		if (rst) begin
			PHT <=`SD 0;
		end else if (reslv_i != `BR_NONE) begin
			if (is_taken) begin
				case(PHT[recrv_BHR_i]) 
					STRONG_T :   PHT[recrv_BHR_i] <= `SD STRONG_T;  
			        WEAK_T   :   PHT[recrv_BHR_i] <= `SD STRONG_T
			        WEAK_NT  :   PHT[recrv_BHR_i] <= `SD WEAK_T;
			        STRONG_NT:   PHT[recrv_BHR_i] <= `SD WEAK_NT;
				endcase
			end else begin
				case(PHT[recrv_BHR_i]) 
            		STRONG_T :   PHT[recrv_BHR_i] <= `SD WEAK_T;  
                    WEAK_T   :   PHT[recrv_BHR_i] <= `SD WEAK_NT
                    WEAK_NT  :   PHT[recrv_BHR_i] <= `SD STRONG_NT;
                    STRONG_NT:   PHT[recrv_BHR_i] <= `SD STRONG_NT;
				endcase
			end
		end else begin
			PHT <= `SD PHT;
		end
	end
endmodule
