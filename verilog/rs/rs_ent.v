// ****************************************************************************
// Filename: rs1.v
// Discription: one entry for reservation station
// Author: Group 5
// Version History:
// 	intial creation: 10/16/2017
// 	***************************************************************************
//

module	rs1 (
		input				clk,
		input				rst,
		
		input		[4:0]				rs1_dest_tag_i,
		input		[4:0]				rs1_cdb_tag_i,
		input							rs1_cdb_vld_i,
		input		[4:0]   			rs1_opa_tag_i,
		input		[4:0]				rs1_opb_tag_i,
		input							rs1_opa_rdy_i,
		input							rs1_opb_rdy_i,
		input		[`RS_OPCODE_W-1:0]	rs1_opcode_i,
		input							rs1_load_i,
		input							rs1_iss_en_i,
		
		output							rs1_rdy_o,
		output		[4:0]				rs1_opa_tag_o,
		output		[4:0]				rs1_opb_tag_o,
		output		[4:0]				rs1_dest_tag_o,
		output							rs1_avail_o	
	);
	
	logic		[4:0]				opa_tag_r;
	logic		[4:0]				opb_tag_r;
	logic							opa_rdy_r;
	logic 							opb_rdy_r;
	logic		[4:0]				dest_tag_r;
	logic		[`RS_OPCODE_W-1:0]	opcode_r;
	logic							avail_r;

	logic							opa_rdy_r_nxt;
	logic 							opb_rdy_r_nxt;
	logic		[4:0]				dest_tag_r_nxt;
	logic		[`RS_OPCODE_W-1:0]	opcode_r_nxt;
	logic							avail_r_nxt;
	

	assign rs1_rdy_o 		= (avail_r) ? 1'b0 : 
							  (opa_rdy_r && opb_rdy_r) ? 1'b1 : 
							  (~opa_rdy_r && opb_rdy_r && (rs1_cdb_vld_i & (opa_tag_r == rs1_cdb_tag_i))) ? 1'b1 : 
							  (opa_rdy_r && ~opb_rdy_r && (rs1_cdb_vld_i & (opb_tag_r == rs1_cdb_tag_i))) ? 1'b1 : 
							  (rs1_cdb_vld_i & (opa_tag_r == rs1_cdb_tag_i) & (opb_tag_r == rs1_cdb_tag_i)) ? 1'b1 : 1'b0;

	assign rs1_opa_tag_o 	= opa_tag_r;
	assign rs1_opb_tag_o 	= opb_tag_r;
	assign rs1_dest_tag_o	= dest_tag_r;
	assign rs1_avail_o 		= avail_r;

	assign opa_tag_r_nxt	= (rs1_iss_en_i) ? 5'h1f :
							  (rs1_load_i)   ? rs1_opa_tag_i : opa_tag_r;

	assign opb_tag_r_nxt	= (rs1_iss_en_i) ? 5'h1f :
							  (rs1_load_i)   ? rs1_opb_tag_i : opb_tag_r;

	assign dest_tag_r_nxt	= (rs1_iss_en_i) ? 5'h1f :
							  (rs1_load_i)   ? rs1_dest_tag_i : dest_tag_r;

	assign opcode_r_nxt		= (rs1_iss_en_i) ? `RS_OPCODE_W'0 :
							  (rs1_load_i)	 ? rs1_opcode_i : opcode_r;

	assign avail_r_nxt		= (rs1_iss_en_i) ? 1'b1 :
							  (rs1_load_i)   ? 1'b0 : avail_r;

	assign opa_rdy_r_nxt	= (rs1_iss_en_i) 									 ? 1'b0 :
							  (rs1_cdb_vld_i & (rs1_opa_tag_i == rs1_cdb_tag_i)) ? 1'b1 :
							  										(rs1_load_i) ? rs1_opa_rdy_i : opa_rdy_r;
	assign opb_rdy_r_nxt	= (rs1_iss_en_i)									 ? 1'b0 :
							  (rs1_cdb_vld_i & (rs1_opb_tag_i == rs1_cdb_tag_i)) ? 1'b1 :
																	(rs1_load_i) ? rs1_opb_rdy_i : opb_rdy_r;

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			opa_tag_r  <= `SD 5'h1f;
			opb_tag_r  <= `SD 5'h1f;
			opa_rdy_r  <= `SD 1'b0;
			opb_rdy_r  <= `SD 1'b0;
			dest_tag_r <= `SD 5'h1f;
			opcode_r   <= `SD `RS_OPCODE_W'b0;
			avail_r    <= `SD 1'b1;
		end else begin
			opa_tag_r  <= `SD opa_tag_r_nxt;
			opb_tag_r  <= `SD opb_tag_r_nxt;
			opa_rdy_r  <= `SD opa_rdy_r_nxt;
			opb_rdy_r  <= `SD opb_rdy_r_nxt;
			dest_tag_r <= `SD dest_tag_r_nxt;
			opcode_r   <= `SD opcode_r_nxt;
			avail_r    <= `SD avail_r_nxt;
		end
	end

endmodule	
