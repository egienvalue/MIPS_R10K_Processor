module test_rs();

	logic				clk;
	logic				rst;
	
	logic	[`PRF_IDX_W-1:0]	rat_dest_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opa_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opb_tag_i;
	logic				rat_opa_rdy_i;
	logic				rat_opb_rdy_i;
		
	logic				id_inst_vld_i;		
	logic	[`RS_OPCODE_W-1:0]	id_opcode_i;
		
	logic	[`PRF_IDX_W-1:0]	cdb_tag_i;
	logic				cdb_vld_i;
		
	logic				stall_dp_i;
	
	logic				rs_iss_vld_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o;
	logic	[`RS_OPCODE_W-1:0]	rs_iss_opcode_o;
		
	logic				rs_full_o;

	rs rs(
		.clk,
		.rst,
		.rat_dest_tag_i,
		.rat_opa_tag_i,
		.rat_opb_tag_i,
		.rat_opa_rdy_i,
		.rat_opb_rdy_i,
		.id_inst_vld_i,
		.id_opcode_i,
		.cdb_tag_i,
		.cdb_vld_i,
		.stall_dp_i,
		.rs_iss_vld_o,
		.rs_iss_opa_tag_o,
		.rs_iss_opb_tag_o,
		.rs_iss_dest_tag_o,
		.rs_iss_opcode_o,
		.rs_full_o
	);

endmodule
