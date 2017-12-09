// ****************************************************************************
// Filename: id_stage.v
// Discription: Instruction Decode Pipeline Stage
// Author: Lu Liu
// Version History:
// 10/25/2017 - initially created, with scheduler at issue to avoid conflicts 
// 		during completion
// intial creation: 10/25/2017
// ***************************************************************************
//

`timescale 1ns/100ps

module decoder(// Inputs

				  input [31:0] inst,
				  input valid_inst_in,  // ignore inst when low, outputs will
										// reflect noop (except valid_inst)

				  output logic [1:0] opa_select, opb_select, dest_reg, // mux selects
				  output logic [4:0] alu_func,
				  output logic [`FU_SEL_W-1:0] fu_sel, // functional unit select
				  output logic rd_mem, wr_mem, ldl_mem, stc_mem, cond_branch, uncond_branch,
				  output logic halt,           // non-zero on a halt
				  output logic cpuid,          // get CPUID instruction
				  output logic illegal,        // non-zero on an illegal instruction
				  output logic valid_inst      // for counting valid instructions executed
									           // and for making the fetch stage die on halts/
									           // keeping track of when to allow the next
									           // instruction out of fetch
									           // 0 for HALT and illegal instructions (die on halt)

				);

	assign valid_inst = valid_inst_in & ~illegal;

	always_comb
	begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//   opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = 0;
		opb_select = 0;
		alu_func = 0;
		dest_reg = `DEST_NONE;
		fu_sel = `FU_SEL_NONE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		ldl_mem = `FALSE;
		stc_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		cpuid = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in)
		begin
			case ({inst[31:29], 3'b0})
				6'h0:
					case (inst[31:26])
						`PAL_INST: begin
							if (inst[25:0] == `PAL_HALT)
								halt = `TRUE;
							else if (inst[25:0] == `PAL_WHAMI) begin
								cpuid = `TRUE;
								dest_reg = `DEST_IS_REGA;   // get cpuid writes to r0
							end else
								illegal = `TRUE;
							end
						default: illegal = `TRUE;
					endcase // case(inst[31:26])
			 
				6'h10:
				begin
					opa_select = `ALU_OPA_IS_REGA;
					opb_select = inst[12] ? `ALU_OPB_IS_ALU_IMM : `ALU_OPB_IS_REGB;
					dest_reg = `DEST_IS_REGC;
					case (inst[31:26])
						`INTA_GRP: begin
							fu_sel = `FU_SEL_ALU;
							case (inst[11:5])
								`CMPULT_INST:  alu_func = `ALU_CMPULT;
								`ADDQ_INST:    alu_func = `ALU_ADDQ;
								`SUBQ_INST:    alu_func = `ALU_SUBQ;
								`CMPEQ_INST:   alu_func = `ALU_CMPEQ;
								`CMPULE_INST:  alu_func = `ALU_CMPULE;
								`CMPLT_INST:   alu_func = `ALU_CMPLT;
								`CMPLE_INST:   alu_func = `ALU_CMPLE;
								default:        illegal = `TRUE;
							endcase // case(inst[11:5])
						end
						`INTL_GRP: begin
							fu_sel = `FU_SEL_ALU;
							case (inst[11:5])

								`AND_INST:    alu_func = `ALU_AND;
								`BIC_INST:    alu_func = `ALU_BIC;
								`BIS_INST:    alu_func = `ALU_BIS;
								`ORNOT_INST:  alu_func = `ALU_ORNOT;
								`XOR_INST:    alu_func = `ALU_XOR;
								`EQV_INST:    alu_func = `ALU_EQV;
								default:       illegal = `TRUE;
							endcase // case(inst[11:5])
						end
						`INTS_GRP: begin
							fu_sel = `FU_SEL_ALU;
							case (inst[11:5])
								`SRL_INST:  alu_func = `ALU_SRL;
								`SLL_INST:  alu_func = `ALU_SLL;
								`SRA_INST:  alu_func = `ALU_SRA;
								default:    illegal = `TRUE;
							endcase // case(inst[11:5])
						end
						`INTM_GRP: begin
							fu_sel = `FU_SEL_MULT;
							case (inst[11:5])
								`MULQ_INST:       alu_func = `ALU_MULQ;
								default:          illegal = `TRUE;
							endcase // case(inst[11:5])
						end
						`ITFP_GRP:       illegal = `TRUE;       // unimplemented
						`FLTV_GRP:       illegal = `TRUE;       // unimplemented
						`FLTI_GRP:       illegal = `TRUE;       // unimplemented
						`FLTL_GRP:       illegal = `TRUE;       // unimplemented
					endcase // case(inst[31:26])
				end
				   
				6'h18:
					case (inst[31:26])
						`MISC_GRP:       illegal = `TRUE; // unimplemented
						`JSR_GRP:
						begin
							// JMP, JSR, RET, and JSR_CO have identical semantics
							opa_select = `ALU_OPA_IS_NOT3;
							opb_select = `ALU_OPB_IS_REGB;
							alu_func = `ALU_AND; // clear low 2 bits (word-align)
							dest_reg = `DEST_IS_REGA;
							uncond_branch = `TRUE;
							fu_sel = `FU_SEL_UNCOND_BRANCH;
						end
						`FTPI_GRP:       illegal = `TRUE;       // unimplemented
					endcase // case(inst[31:26])
				   
				6'h08, 6'h20, 6'h28:
				begin
					opa_select = `ALU_OPA_IS_MEM_DISP;
					opb_select = `ALU_OPB_IS_REGB;
					alu_func = `ALU_ADDQ;
					dest_reg = `DEST_IS_REGA;
					case (inst[31:26])
						`LDA_INST:
							fu_sel = `FU_SEL_ALU;
						`LDQ_INST:
						begin
							rd_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
							fu_sel = `FU_SEL_LOAD;
						end // case: `LDQ_INST
						`LDQ_L_INST:
						begin
							rd_mem = `TRUE;
							ldl_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
							fu_sel = `FU_SEL_LOAD;
						end // case: `LDQ_L_INST
						`STQ_INST:
						begin
							wr_mem = `TRUE;
							opa_select = `ALU_OPA_IS_REGA;
							dest_reg = `DEST_NONE;
							fu_sel = `FU_SEL_STORE;
						end // case: `STQ_INST
						`STQ_C_INST:
						begin
							wr_mem = `TRUE;
							stc_mem = `TRUE;
							dest_reg = `DEST_IS_REGA;
							fu_sel = `FU_SEL_STORE;
						end // case: `STQ_INST
						default:       illegal = `TRUE;
					endcase // case(inst[31:26])
				end
				   
				6'h30, 6'h38:
				begin
					opa_select = `ALU_OPA_IS_REGA;
					opb_select = `ALU_OPB_IS_BR_DISP;
					alu_func = `ALU_ADDQ;
					case (inst[31:26])
						`FBNE_INST: // <12/6> for 2-core program jump
						begin
							cond_branch = `TRUE;
							fu_sel = `FU_SEL_UNCOND_BRANCH;
						end
						`FBEQ_INST, `FBLT_INST, `FBLE_INST,
						`FBGE_INST, `FBGT_INST:
						begin
							// FP conditionals not implemented
							illegal = `TRUE;
						end

						`BR_INST, `BSR_INST:
						begin
							dest_reg = `DEST_IS_REGA;
							uncond_branch = `TRUE;
							fu_sel = `FU_SEL_UNCOND_BRANCH;
						end

						default: begin
							cond_branch = `TRUE; // all others are conditional
							fu_sel = `FU_SEL_COND_BRANCH;
						end
					endcase // case(inst[31:26])
				end
			endcase // case(inst[31:29] << 3)
		end // if(~valid_inst_in)
	end // always
   
endmodule // decoder


module id_stage(
             
				  input         clk,                // system clock
				  input         rst,                // system reset
				  input  [31:0] if_id_IR_i,             // incoming instruction
				  input         if_id_valid_inst_i,

				  output logic  [4:0]			id_ra_idx_o,      // reg A value
				  output logic  [4:0]			id_rb_idx_o,      // reg B value
				  output logic  [4:0]			id_dest_idx_o,    // destination (writeback) register index (zero-reg if no writeback)
				  output logic	[`FU_SEL_W-1:0]		id_fu_sel_o,      // functional unit selection
				  output logic	[31:0]			id_IR_o,	  // instruction
				  output logic				id_rd_mem_o,
				  output logic				id_wr_mem_o,
				  output logic				id_cond_branch_o,
				  output logic				id_uncond_branch_o,

				  // currently unused					
				  output logic        id_ldl_mem_o,       // load-lock inst?
				  output logic        id_stc_mem_o,       // store-conditional inst?								
				  output logic        id_halt_o,
				  output logic        id_cpuid_o,         // get CPUID inst?
				  output logic        id_illegal_o,
				  output logic        id_valid_inst_o     // is inst a valid instruction to be 
              );
   
	logic	[1:0] opa_select;
	logic	[1:0] opb_select;
	logic   [1:0] dest_reg_select;

	// instruction fields read from IF/ID pipeline register
	wire    [4:0] ra_idx = if_id_IR_i[25:21];   // inst operand A register index
	wire    [4:0] rb_idx = if_id_IR_i[20:16];   // inst operand B register index
	wire    [4:0] rc_idx = if_id_IR_i[4:0];     // inst operand C register index

	assign id_IR_o = if_id_IR_i;

	// instantiate the instruction decoder
	decoder decoder_0 (// Input
					 .inst(if_id_IR_i),
					 .valid_inst_in(if_id_valid_inst_i),

					 // Outputs
					 .opa_select(opa_select),
					 .opb_select(opb_select),
					 .alu_func(),
					 .dest_reg(dest_reg_select),
					 .fu_sel(id_fu_sel_o),
					 .rd_mem(id_rd_mem_o),
					 .wr_mem(id_wr_mem_o),
					 .ldl_mem(id_ldl_mem_o),
					 .stc_mem(id_stc_mem_o),
					 .cond_branch(id_cond_branch_o),
					 .uncond_branch(id_uncond_branch_o),
					 .halt(id_halt_o),
					 .cpuid(id_cpuid_o),
					 .illegal(id_illegal_o),
					 .valid_inst(id_valid_inst_o)
					);

	// mux to generate proper id_ra_idx_o, id_rb_idx_o
	always_comb begin
		case (opa_select)
			`ALU_OPA_IS_REGA:	id_ra_idx_o = ra_idx;
			default:		id_ra_idx_o = `ZERO_REG; // set to zero register because zero register is always ready
		endcase
	end

	always_comb begin
		case (opb_select)
			`ALU_OPB_IS_REGB:	id_rb_idx_o = rb_idx;
			default:		id_rb_idx_o = `ZERO_REG; // set to zero register because zero register is always ready
		endcase
	end

	// mux to generate dest_reg_idx based on
	// the dest_reg_select output from decoder
	always_comb begin
		case (dest_reg_select)
			`DEST_IS_REGC: id_dest_idx_o = rc_idx;
			`DEST_IS_REGA: id_dest_idx_o = ra_idx;
			`DEST_NONE:    id_dest_idx_o = `ZERO_REG;
			default:       id_dest_idx_o = `ZERO_REG; 
		endcase
	end
   
endmodule // module id_stage
