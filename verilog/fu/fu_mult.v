// This is an 8 stage (9 depending on how you look at it) pipelined 
// multiplier that multiplies 2 64-bit integers and returns the low 64 bits 
// of the result.  This is not an ideal multiplier but is sufficient to 
// allow a faster clock period than straight *
// This module instantiates 8 pipeline stages as an array of submodules.
// 
module mult_stage (
					input clock, reset, start,
					input [63:0] product_in, mplier_in, mcand_in,
					input rob_br_recovery_i,
					input rob_br_pred_correct_i,
					input [`ROB_IDX_W:0]   rob_idx_i,
					input [`PRF_IDX_W-1:0] dest_tag_i,
					input [`BR_MASK_W-1:0] br_mask_i,
					input [`BR_MASK_W-1:0] rob_br_tag_fix_i,
					input				   stall_i,

					output logic done,
					output logic [63:0] product_out, mplier_out, mcand_out,
					output logic [`ROB_IDX_W:0]   rob_idx_o,
					output logic [`PRF_IDX_W-1:0] dest_tag_o,
					output logic [`BR_MASK_W-1:0] br_mask_o
				);


	parameter BITS_OF_STAGE = 16;

	logic [63:0] prod_in_reg, partial_prod_reg;
	logic [63:0] partial_product, next_mplier, next_mcand;
	logic [BITS_OF_STAGE-1:0] tmp;
	assign tmp=0; 
	assign product_out = prod_in_reg + partial_prod_reg;

	assign partial_product = mplier_in[BITS_OF_STAGE-1:0] * mcand_in;

	assign next_mplier = {tmp, mplier_in[63:BITS_OF_STAGE]};
	assign next_mcand = {mcand_in[63-BITS_OF_STAGE:0], tmp};

	//synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset) begin
			done			 <= `SD 1'b0;
			prod_in_reg		 <= `SD 0;
			partial_prod_reg <= `SD 0;
			mplier_out		 <= `SD 0;
			mcand_out		 <= `SD 0;
			rob_idx_o		 <= `SD 0;
			dest_tag_o		 <= `SD `ZERO_REG;
			br_mask_o		 <= `SD 0;
		end else if (rob_br_recovery_i && ((br_mask_o & rob_br_tag_fix_i) != 0)) begin
			done			 <= `SD 1'b0;
			prod_in_reg		 <= `SD 0;
			partial_prod_reg <= `SD 0;
			mplier_out		 <= `SD 0;
			mcand_out		 <= `SD 0;
			rob_idx_o		 <= `SD 0;
			dest_tag_o	 	 <= `SD `ZERO_REG;
			br_mask_o		 <= `SD 0;
		end else if (~rob_br_recovery_i & ~stall_i) begin
			done			 <= `SD start;
			prod_in_reg      <= `SD product_in;
			partial_prod_reg <= `SD partial_product;
			mplier_out       <= `SD next_mplier;
			mcand_out        <= `SD next_mcand;
			rob_idx_o		 <= `SD rob_idx_i;
			dest_tag_o		 <= `SD dest_tag_i;
			br_mask_o		 <= `SD rob_br_pred_correct_i ? (br_mask_i ^ rob_br_tag_fix_i) : br_mask_i;
		end
	end

	/*
	// synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if(reset)
			done <= `SD 1'b0;
		else
			done <= `SD start;
	end
	*/

endmodule

module fu_mult (
				input 						clk, 
				input						rst,
				input	[63:0]				opa_i, 
				input	[63:0]				opb_i,
				input						start_i,
				input	[31:0]				inst_i,
				input	[`ROB_IDX_W:0]		rob_idx_i,
				input	[`PRF_IDX_W-1:0]	dest_tag_i,
				input	[`BR_MASK_W-1:0]	br_mask_i,
				input						rob_br_recovery_i,
				input						rob_br_pred_correct_i,
				input	[`BR_MASK_W-1:0]	rob_br_tag_fix_i,
				input						stall_i,
				
				output	[63:0]				product_o,
				output	logic	[`ROB_IDX_W:0]	rob_idx_o,
				output	logic	[`PRF_IDX_W-1:0]	dest_tag_o,
				output	logic	[`BR_MASK_W-1:0]	br_mask_o,
				output	logic				done_pre_o,
				output						done_o
			);

	parameter NUM_OF_STAGE = 4;

	logic [63:0] mcand_out, mplier_out;
	logic [(NUM_OF_STAGE-1)*64-1:0] internal_products, internal_mcands, internal_mpliers;
	logic [NUM_OF_STAGE-2:0] internal_dones;
	logic [(NUM_OF_STAGE-1)*(`ROB_IDX_W+1)-1:0] internal_rob_idxs;
	logic [(NUM_OF_STAGE-1)*`PRF_IDX_W-1:0] internal_dest_tags;
	logic [(NUM_OF_STAGE-1)*`BR_MASK_W-1:0] internal_br_masks;

	wire [63:0] mult_imm  = { 56'b0, inst_i[20:13] };
	wire [63:0] mcand = opa_i;
	wire [63:0] mplier;
	assign mplier = inst_i[12] ? mult_imm : opb_i;

	assign done_pre_o = internal_dones[NUM_OF_STAGE-2];

	mult_stage #(.BITS_OF_STAGE(64/NUM_OF_STAGE)) mstage[NUM_OF_STAGE-1:0]  (
		.clock(clk),
		.reset(rst),
		.product_in({internal_products,64'h0}),
		.mplier_in({internal_mpliers,mplier}),
		.mcand_in({internal_mcands,mcand}),
		.start({internal_dones,start_i}),
		.rob_br_recovery_i(rob_br_recovery_i),
		.rob_br_pred_correct_i(rob_br_pred_correct_i),
		.rob_idx_i({internal_rob_idxs, rob_idx_i}),
		.dest_tag_i({internal_dest_tags, dest_tag_i}),
		.br_mask_i({internal_br_masks, br_mask_i}),
		.rob_br_tag_fix_i(rob_br_tag_fix_i),
		.stall_i(stall_i),
		.product_out({product_o,internal_products}),
		.mplier_out({mplier_out,internal_mpliers}),
		.mcand_out({mcand_out,internal_mcands}),
		.rob_idx_o({rob_idx_o, internal_rob_idxs}),
		.dest_tag_o({dest_tag_o, internal_dest_tags}),
		.br_mask_o({br_mask_o, internal_br_masks}),
		.done({done_o, internal_dones})
	);

endmodule
