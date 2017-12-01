// ****************************************************************************
// Filename: fu_alu.v
// Discription: alu for integer calculation but not for branch
// Author: Jun
// Version History:
// 	intial creation: 10/26/2017
// 	***************************************************************************
//
module fu_alu (

		input				clk,
		input				rst,
		
		input							start_i,
		input		[63:0]				opa_i,
		input		[63:0]				opb_i,
		input		[31:0]				inst_i,
		input		[`PRF_IDX_W-1:0]	dest_tag_i,
		input		[`ROB_IDX_W:0]		rob_idx_i,
		input		[`BR_MASK_W-1:0]	br_mask_i,
		input							rob_br_recovery_i,
		input							rob_br_pred_correct_i,
		input		[`BR_MASK_W-1:0]	rob_br_tag_fix_i,
		input							stall_i,

		output	logic	[63:0]			result_o,
		output	logic	[`PRF_IDX_W-1:0]dest_tag_o,
		output	logic	[`ROB_IDX_W:0]	rob_idx_o,
		output	logic	[`BR_MASK_W-1:0]br_mask_o,
		output	logic					done_pre_o,
		output	logic					done_o
	
		);	


logic	[63:0]				result_o_nxt;
logic	[63:0]				opb,opa;


wire [63:0] alu_imm  = { 56'b0, inst_i[20:13]};
wire [63:0] mem_disp = { {48{inst_i[15]}}, inst_i[15:0] };

assign done_pre_o = start_i;

function signed_lt;
	input [63:0] a, b;

	if (a[63] == b[63]) 
		signed_lt = (a < b); // signs match: signed compare same as unsigned
	else
		signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
endfunction

// opa, opb
always_comb begin
	opa = opa_i;
	opb = opb_i;
	case ({inst_i[31:29], 3'b0})
		6'h10: begin
			opb	= inst_i[12] ? alu_imm : opb_i;
			opa	= opa_i;
		end
		6'h08, 6'h20, 6'h28: begin
			opb	= opb_i;
			opa = mem_disp;
		end
	endcase
end

always_comb begin
	case ({inst_i[31:29], 3'b0})
		6'h10: begin
			case(inst_i[31:26])	
				`INTA_GRP: begin
					case (inst_i[11:5])
		        		`CMPULT_INST: result_o_nxt = { 63'd0, (opa < opb) }; // alu_func = ALU_CMPULT;
		        		`ADDQ_INST:   result_o_nxt = opa + opb;// alu_func = ALU_ADDQ;
		        		`SUBQ_INST:   result_o_nxt = opa - opb;// alu_func = ALU_SUBQ;
		        		`CMPEQ_INST:  result_o_nxt = { 63'd0, (opa == opb) }; // alu_func = ALU_CMPEQ;
		        		`CMPULE_INST: result_o_nxt = { 63'd0, (opa <= opb) };// alu_func = ALU_CMPULE;
		        		`CMPLT_INST:  result_o_nxt = { 63'd0, signed_lt(opa, opb) };
		        		`CMPLE_INST:  result_o_nxt = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
						default: 	  result_o_nxt = 64'hdeadbeefbaadbeef;
					endcase
				end
				`INTL_GRP: begin
					case (inst_i[11:5])
						`AND_INST:		result_o_nxt = opa & opb; // `ALU_AND
						`BIC_INST:		result_o_nxt = opa & ~opb; // `ALU_BIC
						`BIS_INST:		result_o_nxt = opa | opb; // `ALU_BIS
						`ORNOT_INST:	result_o_nxt = opa | ~opb; // `ALU_ORNOT
						`XOR_INST:		result_o_nxt = opa ^ opb; // `ALU_XOR
						`EQV_INST:		result_o_nxt = opa ^ ~opb; // `ALU_EQV
						default:		result_o_nxt = 64'hdeadbeefbaadbeef;
					endcase
				end
				`INTS_GRP: begin
					case (inst_i[11:5])
						`SRL_INST:		result_o_nxt = opa >> opb[5:0]; // `ALU_SRL
						`SLL_INST:		result_o_nxt = opa << opb[5:0]; // `ALU_SLL
						`SRA_INST:		result_o_nxt = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 - opb[5:0])); // `ALU_SRA
						default:		result_o_nxt = 64'hdeadbeefbaadbeef;
					endcase
				end
				default: result_o_nxt = 64'hdeadbeefbaadbeef;	
			endcase
		end
		6'h08, 6'h20, 6'h28: begin
			case(inst_i[31:26])
				`LDA_INST:	result_o_nxt = opa + opb;
				default:	result_o_nxt = 64'hdeadbeefbaadbeef;
			endcase
		end
		default: result_o_nxt = 64'hdeadbeefbaadbeef;
	endcase
end

always_ff @(posedge clk) begin
	if (rst) begin
		done_o		<= `SD 0;		
		result_o	<= `SD 0;
		dest_tag_o	<= `SD 0;
		rob_idx_o	<= `SD 0;
		br_mask_o	<= `SD 0;
	end else if (rob_br_recovery_i && ((br_mask_o & rob_br_tag_fix_i) != 0)) begin
		done_o		<= `SD 0;		
		result_o	<= `SD 0;
		dest_tag_o	<= `SD 0;
		rob_idx_o	<= `SD 0;
		br_mask_o	<= `SD 0;
	end else if (~rob_br_recovery_i & ~stall_i) begin
		done_o		<= `SD start_i;	
		result_o	<= `SD result_o_nxt;
		dest_tag_o	<= `SD dest_tag_i;
		rob_idx_o	<= `SD rob_idx_i;
		br_mask_o	<= `SD rob_br_pred_correct_i ? (br_mask_i & ~rob_br_tag_fix_i) : br_mask_i;	
	end
end


endmodule 
