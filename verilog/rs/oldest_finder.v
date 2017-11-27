// ****************************************************************************
// Filename: oldest_finder.v
// Discription: oldest finder issue logic
// Author: Lu Liu
// Version History:
// 11/19/2017 - initially created
// intial creation: 11/19/2017
// ***************************************************************************

module oldest_finder2 (
		input			[1:0]					req,
		input			[1:0][`ROB_IDX_W:0]		order,
		input									en,

		output	logic	[1:0]					gnt,
		output	logic							req_up,
		output	logic	[`ROB_IDX_W:0]			order_up
	);

	assign gnt[0] = en && req[0] && ((req[1] && (order[0] <= order[1])) || ~req[1]);
	assign gnt[1] = en && req[1] && ((req[0] && (order[1] < order[0])) || ~req[0]);

	assign req_up = req[1] | req[0];
	assign order_up = (req[0] && ((req[1] && (order[0] <= order[1])) || ~req[1])) ? order[0] :
					  (req[1] && ((req[0] && (order[1] < order[0])) || ~req[0])) ? order[1] : 0;

endmodule

module oldest_finder #(parameter NUM_ENT = 8)(
		input			[NUM_ENT-1:0]					req,
		input			[NUM_ENT-1:0][`ROB_IDX_W:0]		order,
		input											en,

		output	logic	[NUM_ENT-1:0]					gnt,
		output	logic									req_up,
		output	logic	[`ROB_IDX_W:0]					order_up
	);

	logic	[NUM_ENT-2:0]					req_ups;
	logic	[NUM_ENT-2:0][`ROB_IDX_W:0]	order_ups;
	logic	[NUM_ENT-2:0]					enables;

	genvar i,j;
	generate
		if (NUM_ENT == 2) begin
			oldest_finder2 of1(
				.req		(req),
				.order		(order),
				.en			(en),
				.gnt		(gnt),
				.req_up		(req_up),
				.order_up	(order_up)
			);
		end else begin
			assign req_up = req_ups[NUM_ENT-2];
			assign enables[NUM_ENT-2] = en;
			assign order_up = order_ups[NUM_ENT-2];

			for (i = 0; i < NUM_ENT/2; i = i + 1) begin : base_of
				oldest_finder2 base(
					.req		(req[2*i+1:2*i]),
					.order		(order[2*i+1:2*i]),
					.en			(enables[i]),
					.gnt		(gnt[2*i+1:2*i]),
					.req_up		(req_ups[i]),
					.order_up	(order_ups[i])
				);
			end

			for (j = NUM_ENT/2; j <= NUM_ENT-2; j = j + 1) begin : top_of
				oldest_finder2 top(
					.req		(req_ups[2*j-NUM_ENT+1:2*j-NUM_ENT]),
					.order		(order_ups[2*j-NUM_ENT+1:2*j-NUM_ENT]),
					.en			(enables[j]),
					.gnt		(enables[2*j-NUM_ENT+1:2*j-NUM_ENT]),
					.req_up		(req_ups[j]),
					.order_up	(order_ups[j])
				);
			end
		end
	endgenerate

endmodule
