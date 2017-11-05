// This is an 8 stage (9 depending on how you look at it) pipelined 
// multiplier that multiplies 2 64-bit integers and returns the low 64 bits 
// of the result.  This is not an ideal multiplier but is sufficient to 
// allow a faster clock period than straight *
// This module instantiates 8 pipeline stages as an array of submodules.
// 

module mult(
				input clk, rst,
				input [63:0] opa_i, opb_i,
				input start_i,
				input [31:0] inst_i,
				input [`HT_W-1:0]rob_idx_i,
				input [`PRF_IDX_W-1:0]dest_tag_i,
				
				output [63:0] product,
				output [`HT_W-1:0] rob_idx_o,
				output [`PRF_IDX_W-1:0] dest_tag_o,
				output done
			);
	parameter NUM_OF_STAGE = 4;
	logic [`HT_W-1:0] rob_idx_r;
	logic [`PRF_IDX_W-1:0] dest_tag_r;
   logic [63:0] mcand_out, mplier_out;
  logic [(NUM_OF_STAGE-1)*64-1:0] internal_products, internal_mcands, internal_mpliers;
  logic [NUM_OF_STAGE-2:0] internal_dones;
  wire [63:0] mult_imm  = { 56'b0, inst_i[20:13] };
  wire [63:0] mcand = opa_i;
  wire [63:0] mplier;
  assign mplier = inst_i[12] ? mult_imm : opb_i;
  assign rob_idx_o = rob_idx_r;
  assign dest_tag_o = dest_tag_r;

	mult_stage #(.BITS_OF_STAGE(64/NUM_OF_STAGE)) mstage[NUM_OF_STAGE-1:0]  (
		.clock(clk),
		.reset(rst),
		.product_in({internal_products,64'h0}),
		.mplier_in({internal_mpliers,mplier}),
		.mcand_in({internal_mcands,mcand}),
		.start({internal_dones,start}),
		.product_out({product,internal_products}),
		.mplier_out({mplier_out,internal_mpliers}),
		.mcand_out({mcand_out,internal_mcands}),
		.done({done,internal_dones})
	);

always_ff @(posedge clk) begin
	if (rst) begin
		rob_idx_r <= `SD 0;
		dest_tag_r <= `SD 0;
	end else if (start) begin
		rob_idx_r <= `SD rob_idx_i;
		dest_tag_r <= `SD dest_tag_i;
	end
end

endmodule
