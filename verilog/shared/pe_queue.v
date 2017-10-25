/////////////////////////////////////////////////////////////////////
//	File Name : pe_queue.v
//	
//	Author: Hengfei Zhong
//
//	Date: 3/1/2017
//
//	Version History:
//	<3/1> Initial creation
/////////////////////////////////////////////////////////////////////


//`include "parameter_def.vh"

module pe_queue
(
	// System signals
	input											clk			,
	input											rstn		,

	// Signals from/to CCU
	input			[`ACT_WIDTH-1:0]				act_value_i	,
	input			[`INDEX_WIDTH-1:0]				index_i		,
	input											we_i		,
	output											full_o		,

	// Signals from/to PE
	input											re_i		,
	output	reg		[`ACT_WIDTH-1:0]				act_value_o	,
	output	reg		[`INDEX_WIDTH-1:0]				index_o		,
	output											empty_o		
);

	// Write domain signals
	reg		[`PTR_WIDTH-1:0]					rW_ptr	;
	reg											rW_round;
	
	// Read domain signals
	reg		[`PTR_WIDTH-1:0]					rR_ptr	;
	reg											rR_round;
	//reg		[`ACT_WIDTH+`INDEX_WIDTH-1:0]		rR_data;

	// Queue array
	reg		[`ACT_WIDTH+`INDEX_WIDTH-1:0]		rQueueArr [`QUEUE_DEPTH-1:0];

	// Full signal
	assign full_o =  ((rW_round != rR_round) &&
					  (rW_ptr == rR_ptr)) ? 1'b1:1'b0;
	
	// Empty signal
	assign empty_o = ((rW_round == rR_round) &&
					  (rW_ptr == rR_ptr)) ? 1'b1:1'b0;
	
	// Write data to queue
	always @(posedge clk) begin
		if (~rstn) begin
			for (int i = 0; i < `QUEUE_DEPTH; i++) begin
				rQueueArr[i] <= {(`ACT_WIDTH+`INDEX_WIDTH){1'b0}};
			end
		end
		else begin
			if (we_i) begin
				rQueueArr[rW_ptr] <= {act_value_i, index_i};
			end
		end
	end

	// Read data from queue
	always @(posedge clk) begin
		if (~rstn) begin
			{act_value_o, index_o} <= 'b0;
		end
		else begin
			if (re_i) begin
				{act_value_o, index_o} <= rQueueArr[rR_ptr];
			end
		end
	end

	// Write pointer
	always @(posedge clk) begin
		if (~rstn) begin
			rW_ptr   <= {`PTR_WIDTH{1'b0}};
			rW_round <= 1'b0;
		end
		else if (we_i) begin
			if (rW_ptr == `QUEUE_DEPTH - 1) begin
				rW_ptr   <= {`PTR_WIDTH{1'b0}};
				rW_round <= ~rW_round;
			end
			else begin
				rW_ptr   <= rW_ptr + 1;
			end
		end
	end
		
	// Read pointer
	always @(posedge clk) begin
		if (~rstn) begin
			rR_ptr   <= {`PTR_WIDTH{1'b0}};
			rR_round <= 1'b0;
		end
		else if (re_i) begin
			if (rR_ptr == `QUEUE_DEPTH -1) begin
				rR_ptr   <= {`PTR_WIDTH{1'b0}};
				rR_round <= ~rR_round;
			end
			else begin
				rR_ptr	 <= rR_ptr + 1;
			end
		end
	end

endmodule: pe_queue		
	
