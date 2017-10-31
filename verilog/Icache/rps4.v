//*****************************************************************************
// Filename: rps4.v
// Description: 4-to-1 Round-robin porioty selector for 4 prefetch entry
//              selection
// Author: Hengfei Zhong
// Version History:
//   intial creation: 10/20/2017
//*****************************************************************************

module rps4 (
		input					en_i,
		input		[3:0]		req_i,
		input		[1:0]		ptr_i,
		output		[3:0]		gnt_o
	);

	// Three-assign coding style for a simple priority selector
	// assign higher_pri_req[N-1:1] = higher_pri_req[N-2:0] | req[N-2:0];
	// assign higher_pri_req[0]		= 1'b0;
	// assign grant[N-1:0]			= req[N-1:0] & ~higher_pri_req[N-1:0];
	
	wire		[3:0]		mask_higher_pri_req_w;
	wire		[3:0]		req_masked;
	wire		[3:0]		gnt_masked;
	logic		[3:0]		mask_vector;

	wire		[3:0]		unmask_higher_pri_req_w;
	wire		[3:0]		gnt_unmasked;

	wire					no_req_masked;

	wire		[3:0]		gnt_selected;

	// mask_vector
	always_comb begin
		case (ptr_i)
			2'b00: mask_vector = 4'b1111;
			2'b01: mask_vector = 4'b1110;
			2'b10: mask_vector = 4'b1100;
			2'b11: mask_vector = 4'b1000;
		endcase
	end

	// simple priority selector for masked portion
	assign req_masked 					= req_i & mask_vector;
	assign mask_higher_pri_req_w[3:1]	= mask_higher_pri_req_w[2:0] | req_masked[2:0];
	assign mask_higher_pri_req_w[0]		= 1'b0;
	assign gnt_masked					= req_masked & ~mask_higher_pri_req_w;

	// simple priority selector for unmasked portion
	assign unmask_higher_pri_req_w[3:1]	= unmask_higher_pri_req_w[2:0] | req_i[2:0];
	assign unmask_higher_pri_req_w[0]	= 1'b0;
	assign gnt_unmasked					= req_i & ~unmask_higher_pri_req_w;

	// Select between gnt_masked & gnt_unmasked
	assign no_req_masked = ~(|req_masked);
	assign gnt_selected	 = ({4{no_req_masked}} & gnt_unmasked) | gnt_masked;
	assign gnt_o		 = (en_i) ? gnt_selected :  4'b0;

endmodule
