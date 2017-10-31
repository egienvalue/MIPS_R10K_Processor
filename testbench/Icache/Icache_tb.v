// ****************************************************************************
// Filename: Icache_tb.v
// Description: testbench for Icache.v
// Author: Hengfei Zhong
// Version History:
// 	<10/27> initial creation
// ****************************************************************************

`timescale 1ns/100ps

`define		CLK_P		10


module Icache_tb;

	// inputs
	logic				clk;
	logic				rst;
	
	logic	[3:0]		Imem2proc_response_i;
	logic	[63:0]		Imem2Icache_data_i;
	logic	[3:0]		Imem2proc_tag_i;

	logic	[63:0]		if2Icache_addr_i;
	logic				if2Icache_flush_i;

	// outputs
	wire	[63:0]		proc2Imem_addr_o;
	wire	[1:0]		proc2Imem_command_o;

	wire				Icache2if_vld_o;
	wire	[63:0]		Icache2if_data_o;

	mem mem0 (
		.clk(clk),              // Memory clock
		.proc2mem_addr(proc2Imem_addr_o),    // address for current command
		.proc2mem_data(),    // address for current command
		.proc2mem_command(proc2Imem_command_o), // `BUS_NONE `BUS_LOAD or `BUS_STORE

		.mem2proc_response(Imem2proc_response_i), // 0 = can't accept, other=tag of transaction
		.mem2proc_data(Imem2Icache_data_i),     // data resulting from a load
		.mem2proc_tag(Imem2proc_tag_i)       // 0 = no value(), other=tag of transaction
	);

	Icache Icache0 (
		.clk(clk),
		.rst(rst),
		
		.Imem2proc_response_i(Imem2proc_response_i),
		.Imem2Icache_data_i(Imem2Icache_data_i),
		.Imem2proc_tag_i(Imem2proc_tag_i),

		.if2Icache_addr_i(if2Icache_addr_i),
		.if2Icache_flush_i(if2Icache_flush_i),

		.proc2Imem_addr_o(proc2Imem_addr_o),
		.proc2Imem_command_o(proc2Imem_command_o),

		.Icache2if_vld_o(Icache2if_vld_o),
		.Icache2if_data_o(Icache2if_data_o)
	);

	// 
	always	#(`CLK_P/2)	clk = ~clk;

	//
	task wait_for_hit;
		forever begin: wait_loop
			@(negedge clk);
			if (Icache2if_vld_o) begin
				disable wait_for_hit;
			end
		end
	endtask

	initial begin
		$readmemh("../../program.mem", mem0.unified_memory);
		clk = 1'b0;
		rst = 1'b1;
		if2Icache_flush_i = 0;
		@(negedge clk);
		@(negedge clk);
		rst = 1'b0;
		// start
		$display("TESTBENTCH STARTING!!!");
		@(negedge clk);
		if2Icache_addr_i = 0;
		wait_for_hit();

		@(negedge clk);
		if2Icache_addr_i = if2Icache_addr_i + 4;
		wait_for_hit();
		
		// hit refill
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);

		// miss on cache, hit on pfetch
		@(negedge clk);
		if2Icache_addr_i = if2Icache_addr_i + 4;
		wait_for_hit();

		// miss, move victim cache
		@(negedge clk);
		if2Icache_addr_i = 2048;
		wait_for_hit();
		@(negedge clk);
		if2Icache_addr_i = 2048 + 8;
		wait_for_hit();

		// check victim cache hit
		@(negedge clk);
		if2Icache_addr_i = 0;
		wait_for_hit();
		@(negedge clk);
		if2Icache_addr_i = 8;
		wait_for_hit();

		
		// flush
		@(negedge clk);
		if2Icache_addr_i = 0;
		if2Icache_flush_i = 1;
		@(negedge clk);
		if2Icache_flush_i = 0;
		wait_for_hit();
		for (int i = 0; i < 16; i++) begin	
			@(negedge clk);
		end
		
		$finish;
	end

endmodule
		
	
