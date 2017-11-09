// ****************************************************************************
// Filename: br_alu.v
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

module br_alu (

		input						clk,
		input						rst,
		input						start_i,
		input		[63:0]  		npc_i,
		input		[63:0]  		opa_i,//reg A value
		input		[31:0]  		inst_i,
		input		[`ROB_IDX_W-1:0]rob_idx_i,

		output	logic				done_o,
		output	logic	[63:0]		br_target_o,
		output	logic				br_result_o,
		output	logic	[`ROB_IDX_W-1:0]	rob_idx_o,
        output  logic   [63:0]      br_pc_o
	
		);
		logic	[63:0]	br_disp;
		logic			done_nxt;
		logic			cond_br;
		logic	[63:0]	br_target_nxt;
		logic   		br_result_nxt;
		logic			brcond_result;
		//logic	[`ROB_IDX_W-1:0]	rob_idx_r;
		logic	[`ROB_IDX_W-1:0]	rob_idx_nxt;

		assign br_disp = { {41{inst_i[20]}}, inst_i[20:0], 2'b00 };
		assign br_result_nxt = (~cond_br) ? 1 : brcond_result;
		assign rob_idx_nxt = rob_idx_i;
		wire    [4:0] rb_idx = inst_i[20:16];	

	always_comb begin
        
        br_target_nxt = npc_i;
        cond_br = 0;
		case({inst_i[31:29], 3'b0})
			6'h18:// JMP, JSR, RET, and JSR_CO
				begin
					br_target_nxt = {rb_idx[4:2],2'b00};
					cond_br  = 0;
				end
			6'h30, 6'h38:
				begin
					br_target_nxt = npc_i + br_disp;
					case (inst_i[31:26])
						`BR_INST, `BSR_INST: 
							begin
								cond_br  = 0;
							end
						default: 
							begin
								cond_br  = 1;
							end
						endcase
				end            
			endcase
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
			br_target_o <= `SD 0;
			rob_idx_o	<= `SD 0;
            br_pc_o     <= `SD 0;
		end else begin
			done_o 		<= `SD start_i;
			br_result_o <= `SD br_result_nxt;
			br_target_o <= `SD br_target_nxt;
			rob_idx_o	<= `SD rob_idx_nxt;
            br_pc_o     <= `SD npc_i;
		end
	end


endmodule

