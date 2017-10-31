// test mem model, see how it response
`timescale 1ns/100ps

`define			CLK_P		10


module mem_tb;

	// inputs
	logic			clk;
	logic	[63:0]	proc2mem_addr;
	logic	[63:0]	proc2mem_data;
	logic	[1:0]	proc2mem_command;
	
	// outputs
	wire	[3:0]	mem2proc_response;
	wire	[63:0]	mem2proc_data;
	wire	[3:0]	mem2proc_tag;

	logic			rd_wr;

	// DUT
	mem (
			.clk(clk),              // Memory clock
			.proc2mem_addr(proc2mem_addr),    // address for current command
			.proc2mem_data(proc2mem_data),    // address for current command
			.proc2mem_command(proc2mem_command), // `BUS_NONE `BUS_LOAD or `BUS_STORE

			.mem2proc_response(mem2proc_response), // 0 = can't accept, other=tag of transaction
			.mem2proc_data(mem2proc_data),     // data resulting from a load
			.mem2proc_tag(mem2proc_tag)       // 0 = no value, other=tag of transaction
	);

	always	#(`CLK_P/2)	clk = ~clk;


	// signals initiation and tb
	initial begin
		clk = 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		proc2mem_addr = 64'h0;
		proc2mem_data = 64'h0;
		proc2mem_command = `BUS_NONE;
		rd_wr = 1;
		$monitor ("time: %4f proc2mem_addr:%h proc2mem_data:%h proc2mem_cmd:%h mem2proc_response:%h mem2proc_data:%h mem2proc_tag:%h",$time,proc2mem_addr,proc2mem_data,proc2mem_command,mem2proc_response,mem2proc_data,mem2proc_tag);
		for (int i = 7; i < 15; i = i+1) begin
			@(posedge clk);
			`SD
			if (rd_wr) begin
				proc2mem_addr = proc2mem_addr+8;
				proc2mem_data = i;
				proc2mem_command = `BUS_STORE;
			end else begin
				proc2mem_addr = proc2mem_addr;
				proc2mem_data = 64'hx;
				proc2mem_command = `BUS_LOAD;
			end
			rd_wr = ~rd_wr;
		end
		for (int i = 0; i < 15; i++) begin
			@(posedge clk);
		end

		$finish;
	end

endmodule	
