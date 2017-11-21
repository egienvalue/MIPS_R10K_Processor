//*****************************************************************************
// Filename: core_tb.v
// Discription: testbench for core.v
// Author: group 5
// Version History
//   <11/5> initial creation: without BR, LSQ, Dcache
//*****************************************************************************
`timescale 1ns/100ps

module BTB_test_p;

	logic			clk;
	logic			rst;

	logic	[63:0]	if_pc_i;		// [IF] PC from IF stage to see if it's a branch. Read only, never write. 
	logic			ex_is_br_i;		// [EX] If in the last cycle at the EX stage there's a branch insn, then at this cycle BTB must do something.
	logic			ex_is_cond_i;	// [EX] Save whether it's a conditional branch.
	logic			ex_is_taken_i;	// [EX] 1 is taken, 0 not taken.
	logic	[63:0]	ex_pc_i;		// [EX] Branch PC from EX stage. If taken, add entry or maintain. If not-taken, remove entry or maintain empty.  	
	logic	[63:0]	ex_br_target_i; // [EX] Target address computed out in EX stage. Non-zero only if taken!
	logic			is_hit_o;		// [btb] Tell btb if this pc is a branch or not.
	logic			is_cond_o;		// [IF] Used to select prediction results.
	logic	[63:0]	target_pc_o;	// [IF]	Prediction of target pc.
		
	logic	[31:0]	clock_count;
	logic	[31:0]	instr_count;
	int				btb_fileno;

	logic	[`BTB_SEL_W-1:0]	if_pc_sel, ex_pc_sel;
	logic	[`BTB_VAL_W-1:0]	ex_target_val;
	logic	[`BTB_TAG_W-1:0]	if_pc_tag, ex_pc_tag;
	assign if_pc_sel = if_pc_i[`BTB_SEL_W+1:2];
	assign ex_pc_sel = ex_pc_i[`BTB_SEL_W+1:2];
	assign ex_target_val = ex_br_target_i[`BTB_VAL_W+1:2];
	assign if_pc_tag = if_pc_i[`BTB_TAG_W+1+`BTB_SEL_W:`BTB_SEL_W+2];
	assign ex_pc_tag = ex_pc_i[`BTB_TAG_W+1+`BTB_SEL_W:`BTB_SEL_W+2];
	

	BTB btb0(
		.clk,
		.rst,
		.if_pc_i,			// [IF] PC from IF stage to see if it's a branch. Read only, never write. 
		.ex_is_br_i,		// [EX] If in the last cycle at the EX stage there's a branch insn, then at this cycle BTB must do something.
		.ex_is_cond_i,		// [EX] Save whether it's a conditional branch.
		.ex_is_taken_i,		// [EX] 1 is taken, 0 not taken.
		.ex_pc_i,			// [EX] Branch PC from EX stage. If taken, add entry or maintain. If not-taken, remove entry or maintain empty.  	
		.ex_br_target_i,	// [EX] Target address computed out in EX stage. Non-zero only if taken!
		.is_hit_o,			// [btb] Tell btb if this pc is a branch or not.
		.is_cond_o,			// [IF] Used to select prediction results.
		.target_pc_o		// [IF]	Prediction of target pc.
	);

	task clear_inputs;
		if_pc_i			= 0;	  
		ex_is_br_i		= 0; 
		ex_is_cond_i	= 0;
		ex_is_taken_i	= 0;
		ex_pc_i			= 0;
		ex_br_target_i	= 0;
	endtask

	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clk = ~clk;
	end

	initial
	begin
		clk = 1'b0;
		rst = 1'b0;
		clear_inputs;
		// Pulse the reset signal
		$display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
		rst = 1'b1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		`SD;
		// This reset is at an odd time to avoid the pos & neg clock edges
		rst = 1'b0;
		$display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);
		btb_fileno = $fopen("btb.out");
		
		// Case 1: random fill the btb.	
		//			PC random. Cond_i random(because cond do not take part in
		//			deciding whether to update the content, but will be saved 
		//			as part of the btb content. 
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@ Case1");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");


		@(posedge clk);
		@(negedge clk);
		#2;	
		ex_is_br_i = 1;
		ex_is_taken_i = 1;
		for (int i = 0;i<100;i++) begin
			ex_pc_i = {$random,$random};
			ex_br_target_i = {$random,$random};
			ex_is_cond_i = ex_pc_i[57];
			@(negedge clk);
			#2;
		end

		// Case 2: test reading out the content. 
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@ Case2");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		ex_is_br_i = 0;
		ex_is_taken_i = 0;
		for (int i =0;i<10;i++) begin
			if_pc_i = {$random,$random};
			@(negedge clk);
			#2;
		end

		// Case 3: test cornor case. when the ex forward content to reading.
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@ Case3");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		ex_is_br_i = 1;
		ex_is_taken_i = 1;
		for (int i =0;i<10;i++) begin
			ex_pc_i = {$random,$random};
			if_pc_i = ex_pc_i;
			ex_br_target_i = {$random,$random};
			ex_is_cond_i = ex_pc_i[57];
			@(negedge clk);
			#2;
		end
		
		clear_inputs;
	
		$finish;
	end

	// task for printing rs
	task print_btb;
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@ At cycle%-1d:", clock_count);
		$fdisplay(btb_fileno, "@@@ if_pc_i:%b", if_pc_i);
		$fdisplay(btb_fileno, "@@@ ex_is_br_i:%1b", ex_is_br_i);
		$fdisplay(btb_fileno, "@@@ ex_is_cond_i:%1b", ex_is_cond_i);
		$fdisplay(btb_fileno, "@@@ ex_is_taken_i:%b", ex_is_taken_i);
		$fdisplay(btb_fileno, "@@@ ex_pc_i:%b", ex_pc_i);
		$fdisplay(btb_fileno, "@@@ ex_br_target_i:%b", ex_br_target_i);

		$fdisplay(btb_fileno, "@@@");
	
		$fdisplay(btb_fileno, "@@@ if_pc_sel:%d", if_pc_sel);
		$fdisplay(btb_fileno, "@@@ ex_pc_sel:%d", ex_pc_sel);
		$fdisplay(btb_fileno, "@@@ if_pc_tag:%b", if_pc_tag);
		$fdisplay(btb_fileno, "@@@ ex_pc_tag:%b", ex_pc_tag);
		$fdisplay(btb_fileno, "@@@ ex_target_val:%d", ex_target_val);

		$fdisplay(btb_fileno, "@@@ The content of BTB is:");
		$fdisplay(btb_fileno, "@@@ |		Index	|    TAGS		|	VALS		|	CONDS|");
		for (int i = 0; i < `BTB_NUM; i = i + 1) begin
			$fdisplay(btb_fileno, "@@@	|%d	|	%b	|	%b	|	%1b	|", i, btb0.TAGS[i], btb0.VALS[i], btb0.CONDS[i]);
		end
		$fdisplay(btb_fileno, "@@@");
		
		$fdisplay(btb_fileno, "@@@ is_hit_o:%1b", is_hit_o);
		$fdisplay(btb_fileno, "@@@ is_cond_o:%1b", is_cond_o);
		$fdisplay(btb_fileno, "@@@ target_pc_o:%b", target_pc_o);
		$fdisplay(btb_fileno, "@@@");
		$fdisplay(btb_fileno, "@@@");

	endtask // task print_btb


	// Count the number of posedges and number of instructions completed
	// till simulation ends
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			clock_count <= `SD 0;
		end
		else
		begin
			clock_count <= `SD (clock_count + 1);
		end
	end 

	always @(negedge clk)
	begin
		if(rst)
			$display(	"@@\n@@  %t : System STILL at reset, can't show anything\n@@",
						$realtime);
		else
		begin
			// print rs and rob at every cycle during negedge
			`SD
			print_btb;
		  	`SD;
		end  
	end


endmodule

