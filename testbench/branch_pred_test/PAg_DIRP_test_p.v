//*****************************************************************************
// Filename: core_tb.v
// Discription: testbench for core.v
// Author: group 5
// Version History
//   <11/5> initial creation: without BR, LSQ, Dcache
//*****************************************************************************
`timescale 1ns/100ps

module PAg_DIRP_test_p;

	logic			clk;
	logic			rst;

	logic  [63:0]	if_pc_i;			//[IF]
	logic  			ex_is_br_i;			//[EX]
	logic  			ex_is_cond_i;	//[EX]
	logic  			ex_is_taken_i;		//[EX]
	logic  [63:0]	ex_pc_i;			//[EX]
	logic			pred_o;

	logic	[`PC_IDX_W-1:0] ex_pc_idx;
	
	logic	[31:0]	clock_count;
	logic	[31:0]	instr_count;
	int				dirp_fileno;

	assign	ex_pc_idx = ex_pc_i[`PC_IDX_W+1:2];

	PAg_DIRP dirp0(
		.clk,
		.rst,
		.if_pc_i,		
		.ex_is_br_i,		
		.ex_is_cond_i,				
		.ex_is_taken_i,	
		.ex_pc_i,		
		.pred_o
	);

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
		dirp_fileno = $fopen("dirp.out");
		
		// TODO: Random sequential inputs
		@(negedge clk);
		#2;	
		if_pc_i = 64'b1;
		ex_is_br_i = 1;
		ex_is_cond_i = 1;
		// Case1:random pc, always taken
		ex_is_taken_i = 1;
		for(int i=0;i<100;i++) begin
			ex_pc_i = {$random,$random}; 
			@(negedge clk);
			#2;	
		end
		
		ex_is_br_i = 0;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		#2;	
		ex_is_br_i = 1;
		ex_is_taken_i = 0;
		// Case2:random pc, always untaken
		for(int i=0;i<100;i++) begin
			ex_pc_i = {$random,$random}; 
			@(negedge clk);
			#2;	
		end
		
		
		ex_is_br_i = 0;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		#2;	
		ex_is_br_i = 1;
		// Case2:random pc, always untaken
		for(int i=0;i<100;i++) begin
			ex_pc_i = {$random,$random}; 
			ex_is_taken_i = ex_pc_i[57];
			@(negedge clk);
			#2;	
		end

		$finish;
	end

	// task for printing rs
	task print_dirp;
		$fdisplay(dirp_fileno, "@@@");
		$fdisplay(dirp_fileno, "@@@");
		$fdisplay(dirp_fileno, "@@@ At cycle%-1d:", clock_count);
		$fdisplay(dirp_fileno, "@@@ The content of DIRP BHT is:");
		$fdisplay(dirp_fileno, "@@@ |    Index	|	History	|");
		for (int i = 0; i < `BHT_NUM; i = i + 1) begin
			$fdisplay(dirp_fileno, "@@@	|		%-3d	|	%b	|", i, dirp0.BHT[i]);
		end
		$fdisplay(dirp_fileno, "@@@");
		$fdisplay(dirp_fileno, "@@@");
		
		$fdisplay(dirp_fileno, "@@@ The content of DIRP PHT is:");
		$fdisplay(dirp_fileno, "@@@ |    Index	|	Patern	|");
		for (int i = 0; i < `PHT_NUM; i = i + 1) begin
			$fdisplay(dirp_fileno, "@@@	|		%-3d	|	%d	|", i, dirp0.PHT[i]);
		end


		$fdisplay(dirp_fileno, "@@@");
		$fdisplay(dirp_fileno, "@@@ Current ex_PC:%64b", ex_pc_i);
		$fdisplay(dirp_fileno, "@@@ Current index from ex_PC:%d", ex_pc_idx);
		$fdisplay(dirp_fileno, "@@@ Current taken:%1b", ex_is_taken_i);


	endtask // task print_dirp


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
			print_dirp;
		  	`SD;
		end  
	end


endmodule

