//*****************************************************************************
// Filename: rps4.v
// Description: 4-to-1 Round-robin porioty selector for 4 prefetch entry
//              selection
// Author: Hengfei Zhong
// Version History:
//   intial creation: 10/20/2017
//*****************************************************************************
`define LENGTH  8
 
module rpsN (
		input								en_i,
		input		[`LENGTH-1:0]			req_i,
		input		[$clog2(`LENGTH)-1:0]	ptr_i,
		output		[`LENGTH-1:0]			gnt_o
	);

	// Three-assign coding style for a simple priority selector
	// assign higher_pri_req[N-1:1] = higher_pri_req[N-2:0] | req[N-2:0];
	// assign higher_pri_req[0]		= 1'b0;
	// assign grant[N-1:0]			= req[N-1:0] & ~higher_pri_req[N-1:0];
	
	wire		[`LENGTH-1:0]		mask_higher_pri_req_w;
	wire		[`LENGTH-1:0]		req_masked;
	wire		[`LENGTH-1:0]		gnt_masked;

	logic		[`LENGTH-1:0]		mask_vector;

	wire		[`LENGTH-1:0]		unmask_higher_pri_req_w;
	wire		[`LENGTH-1:0]		gnt_unmasked;

	wire							no_req_masked;

	wire		[`LENGTH-1:0]		gnt_selected;

	// mask_vector
	always_comb begin
		mask_vector = {`LENGTH{1'b1}};
		for (int i = 0; i < $clog2(`LENGTH); i++) begin
			if (ptr_i[i] == 1'b1) begin
				mask_vector = mask_vector << (2**i);	
			end
		end
	end

	// simple priority selector for masked portion
	assign req_masked 							= req_i & mask_vector;
	assign mask_higher_pri_req_w[`LENGTH-1:1]	= mask_higher_pri_req_w[`LENGTH-2:0] | req_masked[`LENGTH-2:0];
	assign mask_higher_pri_req_w[0]				= 1'b0;
	assign gnt_masked							= req_masked & ~mask_higher_pri_req_w;

	// simple priority selector for unmasked portion
	assign unmask_higher_pri_req_w[`LENGTH-1:1]	= unmask_higher_pri_req_w[`LENGTH-2:0] | req_i[`LENGTH-2:0];
	assign unmask_higher_pri_req_w[0]			= 1'b0;
	assign gnt_unmasked							= req_i & ~unmask_higher_pri_req_w;

	// Select between gnt_masked & gnt_unmasked
	assign no_req_masked = ~(|req_masked);
	assign gnt_selected	 = ({`LENGTH{no_req_masked}} & gnt_unmasked) | gnt_masked;
	assign gnt_o		 = (en_i) ? gnt_selected :  `LENGTH'b0;

endmodule
