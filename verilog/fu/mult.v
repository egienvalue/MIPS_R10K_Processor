// This is an 8 stage (9 depending on how you look at it) pipelined 
// multiplier that multiplies 2 64-bit integers and returns the low 64 bits 
// of the result.  This is not an ideal multiplier but is sufficient to 
// allow a faster clock period than straight *
// This module instantiates 8 pipeline stages as an array of submodules.
// 
module mult_stage (
					input clock, reset, start,
					input [63:0] product_in, mplier_in, mcand_in,

					output logic done,
					output logic [63:0] product_out, mplier_out, mcand_out
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
		prod_in_reg      <= #1 product_in;
		partial_prod_reg <= #1 partial_product;
		mplier_out       <= #1 next_mplier;
		mcand_out        <= #1 next_mcand;
	end

	// synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if(reset)
			done <= #1 1'b0;
		else
			done <= #1 start;
	end

endmodule

module mult (
				input 						clk, 
				input						rst,
				input	[63:0]				opa_i, 
				input	[63:0]				opb_i,
				input						start_i,
				input	[31:0]				inst_i,
				input	[`ROB_IDX_W-1:0]	rob_idx_i,
				input	[`PRF_IDX_W-1:0]	dest_tag_i,
				
				output	[63:0]				product,
				output	logic	[`ROB_IDX_W-1:0]	rob_idx_o,
				output	logic	[`PRF_IDX_W-1:0]	dest_tag_o,
				output						done
			);

	parameter NUM_OF_STAGE = 4;
    logic   [`PRF_IDX_W-1:0]    dest_tag_r;
    logic   [`PRF_IDX_W-1:0]    dest_tag_r_nxt;
    logic   [`ROB_IDX_W-1:0]    rob_idx_r_nxt;
    logic   [`ROB_IDX_W-1:0]    rob_idx_r;

	logic [63:0] mcand_out, mplier_out;
	logic [(NUM_OF_STAGE-1)*64-1:0] internal_products, internal_mcands, internal_mpliers;
	logic [NUM_OF_STAGE-2:0] internal_dones;
	wire [63:0] mult_imm  = { 56'b0, inst_i[20:13] };
	wire [63:0] mcand = opa_i;
	wire [63:0] mplier;
	assign mplier = inst_i[12] ? mult_imm : opb_i;
    assign dest_tag_r_nxt   = start_i ? dest_tag_i : 
                              done ? `ZERO_REG : dest_tag_r;
    assign rob_idx_r_nxt    = start_i ? dest_tag_i : 
                              done ? 0 : dest_tag_r;
    assign dest_tag_o       = dest_tag_r;
    assign rob_idx_o        = rob_idx_r;
	mult_stage #(.BITS_OF_STAGE(64/NUM_OF_STAGE)) mstage[NUM_OF_STAGE-1:0]  (
		.clock(clk),
		.reset(rst),
		.product_in({internal_products,64'h0}),
		.mplier_in({internal_mpliers,mplier}),
		.mcand_in({internal_mcands,mcand}),
		.start({internal_dones,start_i}),
		.product_out({product,internal_products}),
		.mplier_out({mplier_out,internal_mpliers}),
		.mcand_out({mcand_out,internal_mcands}),
		.done({done,internal_dones})
	);

	always_ff @(posedge clk) begin
		if (rst) begin
			rob_idx_r <= `SD 0;
			dest_tag_r <= `SD 0;
		end else begin
			rob_idx_r <= `SD rob_idx_r_nxt;
			dest_tag_r <= `SD dest_tag_r_nxt;
		end
	end

endmodule
