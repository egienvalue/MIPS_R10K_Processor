// ****************************************************************************
// Filename: fu_br.v
// Discription: alu for branch condition calculation
// Author: Shijing
// Version History:
// 	intial creation: 10/31/2017
// 	***************************************************************************
module brcond(// Inputs
              input [63:0] opa,        // Value to check against condition
              input  [2:0] func,       // Specifies which condition to check
			
			  output logic cond        // 0/1 condition br_result_nxt (False/True)
             );

	always_comb
	begin
		case (func[1:0]) // 'full-case'  All cases covered, no need for a default
			2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
			2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
			2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
			2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
		endcase

		 // negate cond if func[2] is set
		if (func[2])
			cond = ~cond;
	end
endmodule // brcond

module fu_br (

		input						clk,
		input						rst,
		input						start_i,
		input		[63:0]  		npc_i,
		input		[63:0]  		opa_i,//reg A value
		input		[63:0]			opb_i,//reg B value
		input		[31:0]  		inst_i,
		input		[`PRF_IDX_W-1:0]dest_tag_i,
		input		[`ROB_IDX_W:0]	rob_idx_i,
		input		[`BR_MASK_W-1:0]br_mask_i,
		input						rob_br_recovery_i,
		input		[`BR_MASK_W-1:0]rob_br_tag_fix_i,

		output	logic					done_o,
		//output	logic	[63:0]		br_target_o,
		output	logic					br_result_o,
		output	logic					br_wr_en_o,
		output	logic	[`PRF_IDX_W-1:0]dest_tag_o,
		output	logic	[`ROB_IDX_W:0]	rob_idx_o,
		output	logic	[`BR_MASK_W-1:0]br_mask_o,
        output  logic   [63:0]      	br_pc_o,

		output	logic					br_recovery_taken_o,
		output	logic	[63:0]			br_recovery_target_o,
		output	logic					br2rob_done_o,
		output	logic	[`ROB_IDX_W:0]	br2rob_recovery_idx_o,
		
		output	logic					bp_br_cond_o
		);
		logic	[63:0]	br_disp;
		logic			done_nxt;
		logic			cond_br;
		logic	[63:0]	br_target_nxt;
		logic   		br_result_nxt;
		logic			br_wr_en_nxt;
		logic			brcond_result;
		//logic	[`ROB_IDX_W-1:0]	rob_idx_r;
		logic	[`ROB_IDX_W:0]		rob_idx_nxt;

		assign bp_br_cond_o			= cond_br;

		assign br_recovery_target_o = br_result_nxt ? br_target_nxt : npc_i;//!!the recovery target should be npc_i if the branch is not taken edited by Jun. 
		assign br_recovery_taken_o	= br_result_nxt;
		assign br2rob_done_o 		= start_i;
		assign br2rob_recovery_idx_o= rob_idx_nxt;


		assign br_disp = { {41{inst_i[20]}}, inst_i[20:0], 2'b00 };
		assign br_result_nxt = (~cond_br) ? 1 : brcond_result;
		assign rob_idx_nxt = rob_idx_i;

	always_comb begin
        
		br_wr_en_nxt = 0;
        br_target_nxt = npc_i;
        cond_br = 0;
		if (start_i) begin
			case({inst_i[31:29], 3'b0})
				6'h18:// JMP, JSR, RET, and JSR_CO
					begin
						br_target_nxt = {opb_i[63:2], 2'b00};
						br_wr_en_nxt = (dest_tag_i == `ZERO_REG) ? 1'b0 : 1'b1;
						cond_br  = 0;
					end
				6'h30, 6'h38:
					begin
						br_target_nxt = npc_i + br_disp;
						case (inst_i[31:26])
							`BR_INST, `BSR_INST: 
								begin
									cond_br  = 0;
									br_wr_en_nxt = (dest_tag_i == `ZERO_REG) ? 1'b0 : 1'b1;
								end
							default: 
								begin
									cond_br  = 1;
								end
							endcase
					end            
			endcase
		end
	end
			
	brcond brcond (// Inputs
		.opa(opa_i),       // always check regA value
		.func(inst_i[28:26]), // inst bits to determine check
		// Output
		.cond(brcond_result)
		);
		
	always_ff @(posedge clk) begin
		if(rst) begin
			done_o 		<= `SD 0;
			br_result_o <= `SD 0;
			br_wr_en_o	<= `SD 0;
			//br_target_o <= `SD 0;
			dest_tag_o	<= `SD 0;
			rob_idx_o	<= `SD 0;
            br_pc_o     <= `SD 0;
			br_mask_o	<= `SD 0;
		end else if (rob_br_recovery_i && ((br_mask_o & rob_br_tag_fix_i) != 0)) begin
			done_o 		<= `SD 0;
			br_result_o <= `SD 0;
			br_wr_en_o	<= `SD 0;
			//br_target_o <= `SD 0;
			dest_tag_o	<= `SD 0;
			rob_idx_o	<= `SD 0;
            br_pc_o     <= `SD 0;
			br_mask_o	<= `SD 0;
		end else if (~rob_br_recovery_i) begin
			done_o 		<= `SD start_i;
			br_result_o <= `SD br_result_nxt;
			br_wr_en_o	<= `SD br_wr_en_nxt;
			//br_target_o <= `SD br_target_nxt;
			dest_tag_o	<= `SD dest_tag_i;
			rob_idx_o	<= `SD rob_idx_nxt;
            br_pc_o     <= `SD npc_i;
			br_mask_o	<= `SD br_mask_i;
		end
	end


endmodule

