//*****************************************************************************
// Filename: core_tb.v
// Discription: testbench for core.v
// Author: group 5
// Version History
//   <11/5> initial creation: 
//*****************************************************************************
`timescale 1ns/100ps

module core_tb;

	logic			clk;
	logic			rst;

	logic	[31:0]	clock_count;
	logic	[31:0]	instr_count;
	int				wb_fileno;

	logic	[1:0]	proc2mem_command;
	logic	[63:0]	proc2mem_addr;
	logic	[63:0]	proc2mem_data;
	logic 	[3:0]	mem2proc_response;
	logic	[63:0]	mem2proc_data;
	logic 	[3:0]	mem2proc_tag;

	logic	[3:0]	core_retired_instrs;
	logic	[3:0]	core_error_status;
	logic	[4:0]	core_retire_wr_idx;
	logic	[63:0]	core_retire_wr_data; // or complete?
	logic			core_retire_wr_en;
	logic	[63:0]	core_retire_NPC;

	// DUT
	core core_0	(


	);

	// instantiate main memory
	mem memory	(
			// Inputs
			.clk			(clk),
			.proc2mem_command  (proc2mem_command),
			.proc2mem_addr     (proc2mem_addr),
			.proc2mem_data     (proc2mem_data),

			 // Outputs
			.mem2proc_response (mem2proc_response),
			.mem2proc_data     (mem2proc_data),
			.mem2proc_tag      (mem2proc_tag)
		   );

	// Generate System Clock
	always
	begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clk = ~clk;
	end

	// Task to display # of elapsed clock edges
	task show_clk_count;
		real cpi;

		begin
			cpi = (clock_count + 1.0) / instr_count;
			$display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
			clock_count+1, instr_count, cpi);
			$display("@@  %4.2f ns total time to execute\n@@\n",
			clock_count*`VIRTUAL_CLOCK_PERIOD);
		end
	endtask  // task show_clk_count 



