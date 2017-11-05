// ****************************************************************************
// Filename: alu2.v
// Discription: alu for integer calculation but not for branch
// Author: Jun
// Version History:
// 	intial creation: 10/26/2017
// 	***************************************************************************
//
module int_alu (

		input				clk,
		input				rst,
		
		input							start_i,
		input		[63:0]				opa_i,
		input		[63:0]				opb_i,
		input		[31:0]				inst_i,
		input		[`PRF_IDX_W-1:0]	dest_tag_i,
		input		[`ROB_IDX_W-1:0]	rob_idx_i,

		output	logic	[63:0]			result_o,
		output	logic	[`PRF_IDX_W-1:0]dest_tag_o,
		output	logic	[`ROB_IDX_W-1:0]rob_idx_o;
		output	logic					done_o
	
		);	


logic	[63:0]				result_o_nxt;
logic	[63:0]				opb,opa;


wire [63:0] alu_imm  = { 56'b0, inst_i[20:13]};

assign opb				= inst_i[12] ? alu_imm : opb_i;
assign opa				= opa_i;
assign result_o			= result_r;

function signed_lt;
	input [63:0] a, b;

	if (a[63] == b[63]) 
		signed_lt = (a < b); // signs match: signed compare same as unsigned
	else
		signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
endfunction

always_comb begin
	case (inst_i[11:5])
		`CMPULT_INST:	result_o_nxt = { 63'd0, (opa < opb) };
		`ADDQ_INST:		result_o_nxt = opa + opb;
		`SUBQ_INST:		result_o_nxt = opa - opb;
		`CMPEQ_INST:	result_o_nxt = { 63'd0, (opa == opb) };
		`CMPULE_INST:	result_o_nxt = { 63'd0, (opa <= opb) };
		`CMPLT_INST:	result_o_nxt = { 63'd0, signed_lt(opa, opb) };
		`CMPLE_INST:	result_o_nxt = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
		`AND_INST:		result_o_nxt = opa & opb;
		`BIC_INST:		result_o_nxt = opa & ~opb;
		`BIS_INST:		result_o_nxt = opa | opb;
		`ORNOT_INST:	result_o_nxt = opa | ~opb;
		`XOR_INST:		result_o_nxt = opa ^ opb;
		`EQV_INST:		result_o_nxt = opa ^ ~opb;
		`SRL_INST:		result_o_nxt = opa >> opb[5:0];
		`SLL_INST:		result_o_nxt = opa << opb[5:0];
		`SRA_INST:		result_o_nxt = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
							 opb[5:0]));
		default:     result_o_nxt = 64'hdeadbeefbaadbeef;	
	endcase
end

always_ff @(posedge clk) begin
	if (rst) begin
		done_o		<= `SD 0;		
		result_o	<= `SD 0;
		dest_tag_o	<= `SD 0;
		rob_idx_o	<= `SD 0;
	end else (start_i) begin
		done_o		<= `SD start_i;	
		result_o	<= `SD result_o_nxt;
		dest_tag_o	<= `SD dest_tag_i;
		rob_idx_o	<= `SD rob_idx_i;	
	end
end



end
endmodule 
