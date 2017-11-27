// ****************************************************************************
// Filename: test_rs.v
// Discription: testbench for reservation station
// Author: Lu Liu
// Version History:
// 10/31/2017 - initially created
// intial creation: 10/31/2017
// ***************************************************************************
//

module test_rs();

	class Fu_Sel;
		randc	logic	[`FU_SEL_W-1:0]		fu_sel;

		constraint c_fu { fu_sel >= 0;
				  fu_sel <= `FU_NUM;}
	endclass

	logic				clk;
	logic				rst;
	
	logic	[`PRF_IDX_W-1:0]	rat_dest_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opa_tag_i;
	logic	[`PRF_IDX_W-1:0]	rat_opb_tag_i;
	logic				rat_opa_rdy_i;
	logic				rat_opb_rdy_i;
		
	logic				id_inst_vld_i;		
	logic	[`FU_SEL_W-1:0]		id_fu_sel_i;
	logic	[31:0]			id_IR_i;
	logic	[`ROB_IDX_W:0]		rob_idx_i;
		
	logic	[`PRF_IDX_W-1:0]	cdb_tag_i;
	logic				cdb_vld_i;

	logic	[`SQ_IDX_W-1:0]		lsq_sq_tail_i;
	logic				lsq_ld_iss_en_i;
		
	logic				stall_dp_i;

	logic	[`BR_MASK_W-1:0]	bmg_br_mask_i;
	logic				rob_br_pred_correct_i;
	logic				rob_br_recovery_i;
	logic	[`BR_MASK_W-1:0]	rob_br_tag_fix_i;
	
	logic	[`SQ_IDX_W-1:0]		rs_sq_position_o;
	logic				rs_iss_vld_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opa_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_opb_tag_o;
	logic	[`PRF_IDX_W-1:0]	rs_iss_dest_tag_o;
	logic	[`FU_SEL_W-1:0]		rs_iss_fu_sel_o;
	logic	[31:0]			rs_iss_IR_o;
	logic	[`ROB_IDX_W:0]	rs_iss_rob_idx_o;
	logic	[`BR_MASK_W-1:0]	rs_iss_br_mask_o;
	logic	[`SQ_IDX_W-1:0]		rs_iss_sq_position_o;
		
	logic				rs_full_o;

	// testbench signals
	int				cycle_counter;
	Fu_Sel				fu_sel_gen;

	assign	stall_dp_i = rs_full_o;

	rs dut(
		.clk,
		.rst,
		.rat_dest_tag_i,
		.rat_opa_tag_i,
		.rat_opb_tag_i,
		.rat_opa_rdy_i,
		.rat_opb_rdy_i,
		.id_inst_vld_i,
		.id_fu_sel_i,
		.id_IR_i,
		.rob_idx_i,
		.cdb_tag_i,
		.cdb_vld_i,
		.lsq_sq_tail_i,
		.lsq_ld_iss_en_i,
		.stall_dp_i,
		.bmg_br_mask_i,
		.rob_br_pred_correct_i,
		.rob_br_recovery_i,
		.rob_br_tag_fix_i,
		.rs_sq_position_o,
		.rs_iss_vld_o,
		.rs_iss_opa_tag_o,
		.rs_iss_opb_tag_o,
		.rs_iss_dest_tag_o,
		.rs_iss_fu_sel_o,
		.rs_iss_IR_o,
		.rs_iss_rob_idx_o,
		.rs_iss_br_mask_o,
		.rs_iss_sq_position_o,
		.rs_full_o
	);

	initial begin
		clk = 1'b1;
		forever #20 clk = ~clk;
	end

	always @(posedge clk) begin
		if (rst) begin
			cycle_counter	<= `SD 0;
		end else begin
			cycle_counter	<= `SD cycle_counter + 1;
		end
	end

	task dispatch;
		input	[`PRF_IDX_W-1:0]	opa_tag;
		input	[`PRF_IDX_W-1:0]	opb_tag;
		input				opa_rdy;
		input				opb_rdy;
		input	[`ROB_IDX_W:0]		rob_idx;
		input	[`BR_MASK_W-1:0]	br_mask;

		if (!fu_sel_gen.randomize())
			$finish;

		rat_dest_tag_i	= $random;
		rat_opa_tag_i	= opa_tag;
		rat_opb_tag_i	= opb_tag;
		rat_opa_rdy_i	= opa_rdy;
		rat_opb_rdy_i	= opb_rdy;
		id_fu_sel_i	= fu_sel_gen.fu_sel;
		id_IR_i		= $random;
		rob_idx_i	= rob_idx;
		bmg_br_mask_i	= br_mask;
		lsq_sq_tail_i	= $random;
	endtask

	integer i;
	task print_rs;
		$display("@@@       TAGA  | RDYA |  TAGB  | RDYB |DEST_TAG| FU_SEL|   IR     |ROB_IDX|BR_MASK|SQ_POS| AVAIL");
		for (i = 0; i < `RS_ENT_NUM; i = i + 1) begin
			$display("@@@ %-3d: %b |  %b   | %b |  %b   | %b |   %d   | %h |  %d   | %b |   %d  |  %b", i, dut.opa_tag_vec[i], dut.opa_rdy_vec[i],
				dut.opb_tag_vec[i], dut.opb_rdy_vec[i], dut.dest_tag_vec[i], dut.fu_sel_vec[i],
				dut.IR_vec[i], dut.rob_idx_vec[i], dut.br_mask_vec[i], dut.sq_position_vec[i], dut.avail_vec[i]);
		end
	endtask

	task print_task;
		#1;
		$display("@@@");
		$display("@@@");
		$display("@@@ At cycle %3d:", cycle_counter);
		$display("@@@ The content of RS is:");
		print_rs;
		$display("@@@ Status of schedule vector: %b", dut.exunit_schedule_r);
		$display("@@@ CDB status: valid = %b, tag = %b", cdb_vld_i, cdb_tag_i);
		$display("@@@ rs_full_o = %b", rs_full_o);
		if (dut.rs_iss_vld) begin
			$display("@@@ RS index of issued instruction is: %d", dut.iss_idx);
			$display("@@@ opa_tag = %b, opb_tag = %b, dest_tag = %b, fu_sel = %d, IR = %h, rob_idx = %3d, br_mask = %b, sq_position = %d",
				dut.rs_iss_opa_tag, dut.rs_iss_opb_tag, dut.rs_iss_dest_tag, dut.rs_iss_fu_sel, dut.rs_iss_IR,
				dut.rs_iss_rob_idx, dut.rs_iss_br_mask, dut.rs_iss_sq_position);
			$display("@@@ Schedule vector of issued instruction: %b", dut.rs_ent_schedule_vec[dut.iss_idx]);
		end else
			$display("@@@ No instructions can be issued this cycle");
	endtask

	initial begin
		rst		= 1'b1;
		rat_dest_tag_i	= 0;
		rat_opa_tag_i	= 0;
		rat_opb_tag_i	= 0;
		rat_opa_rdy_i	= 0;
		rat_opb_rdy_i	= 0;
		id_inst_vld_i	= 1'b1;
		id_fu_sel_i	= 0;
		id_IR_i		= 0;
		rob_idx_i	= 0;
		cdb_tag_i	= 0;
		cdb_vld_i	= 0;
		bmg_br_mask_i	= 0;
		rob_br_pred_correct_i = 0;
		rob_br_recovery_i = 0;
		rob_br_tag_fix_i = 0;
		lsq_ld_iss_en_i = 1'b1;

		fu_sel_gen = new();
		
		// basic dispatch and full test
		@(negedge clk);
		@(negedge clk);
		rst = 1'b0;
		dispatch(0, 1, 1, 0, 56, 5'b10000);
		print_task;
		@(negedge clk);
		dispatch(2, 3, 0, 1, 57, 5'b10000);
		print_task;
		@(negedge clk);
		dispatch(4, 5, 1, 0, 58, 5'b10000);
		print_task;
		@(negedge clk);
		dispatch(6, 7, 0, 1, 59, 5'b11000);
		print_task;
		@(negedge clk);
		dispatch(0, 1, 1, 0, 60, 5'b11000);
		print_task;
		@(negedge clk);
		dispatch(2, 3, 0, 1, 61, 5'b11000);
		print_task;
		@(negedge clk);
		dispatch(8, 8, 0, 0, 62, 5'b11100);
		print_task;
		@(negedge clk);
		dispatch(9, 10, 1, 0, 63, 5'b11100);
		print_task;
		@(negedge clk);
		id_inst_vld_i = 1'b0;
		cdb_vld_i = 1'b1;
		cdb_tag_i = 1;
		print_task;
		@(negedge clk);
		cdb_tag_i = 2;
		print_task;
		@(negedge clk);
		id_inst_vld_i = 1'b1;
		dispatch(9, 10, 1, 0, 0, 5'b11100);
		print_task;
		@(negedge clk);
		id_inst_vld_i = 1'b0;
		cdb_tag_i = 10;
		print_task;
		@(negedge clk);
		id_inst_vld_i = 1'b1;
		dispatch(6, 7, 0, 1, 1, 5'b11100);
		print_task;
		@(negedge clk);
		dispatch(8, 11, 0, 0, 2, 5'b11100);
		print_task;
		@(negedge clk);
		dispatch(8, 12, 0, 1, 3, 5'b11100);
		print_task;
		@(negedge clk);
		dispatch(11, 12, 0, 1, 4, 5'b11100);
		print_task;
		@(negedge clk);
		dispatch(13, 14, 0, 1, 5, 5'b11100);
		print_task;
		@(negedge clk);
		cdb_tag_i = 8;
		dispatch(13, 8, 0, 0, 6, 5'b11100);
		print_task;
		@(negedge clk);
		id_inst_vld_i = 1'b0;
		cdb_tag_i = 6;
		print_task;
		@(negedge clk);
		cdb_tag_i = 13;
		print_task;
		@(negedge clk);
		print_task;
		@(negedge clk);
		cdb_tag_i = 11;
		print_task;
		@(negedge clk);
		cdb_tag_i = 5;
		print_task;
		@(negedge clk);
		print_task;
		@(negedge clk);
		print_task;
		@(negedge clk);
		print_task;
		@(negedge clk);
		print_task;
		$finish;

		/*
		// test CDB
		cdb_tag_i	= 5;
		cdb_vld_i	= 1'b1;
		print_task;
		@(negedge clk);
		cdb_tag_i	= 1;
		print_task;
		@(negedge clk);
		cdb_tag_i	= 8;
		print_task;
		@(negedge clk);
		dispatch(13, 14, 0, 0, 5'b11110);
		cdb_tag_i	= 13;
		print_task;
		@(negedge clk);
		dispatch(15, 15, 0, 0, 5'b11110);
		cdb_tag_i	= 15;
		print_task;
		@(negedge clk);
		cdb_vld_i	= 1'b0;
		print_task;
		$finish;
		*/
		
		/*
		// test scheduler
		cdb_vld_i	= 1'b1;
		cdb_tag_i	= 8;
		print_task;
		@(negedge clk);
		cdb_tag_i	= 2;
		print_task;
		@(negedge clk);
		print_task;
		@(negedge clk);
		print_task;
		$finish;
		*/

		/*
		// test branch mask
		rob_br_pred_correct_i	= 1'b1;
		rob_br_tag_fix_i	= 5'b10000;
		cdb_vld_i	= 1'b1;
		cdb_tag_i	= 1;
		print_task;
		@(negedge clk);
		cdb_vld_i	= 1'b0;
		rob_br_pred_correct_i	= 1'b0;
		rob_br_recovery_i	= 1'b1;
		rob_br_tag_fix_i	= 5'b01000;
		print_task;
		@(negedge clk);
		rob_br_recovery_i	= 1'b0;
		print_task;
		@(negedge clk);
		print_task;
		$finish;
		*/
	end

endmodule
