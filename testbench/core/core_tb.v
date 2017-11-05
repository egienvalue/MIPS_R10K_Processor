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
			.clk				(clk),
			.proc2mem_command	(proc2mem_command),
			.proc2mem_addr		(proc2mem_addr),
			.proc2mem_data		(proc2mem_data),

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


	// Show contents of a range of Unified Memory, in both hex and decimal
	task show_mem_with_decimal;
		input [31:0] start_addr;
		input [31:0] end_addr;
		int showing_data;
		begin
			$display("@@@");
			showing_data=0;
			for(int k=start_addr;k<=end_addr; k=k+1)
				if (memory.unified_memory[k] != 0)
				begin
					$display("@@@ mem[%5d] = %x : %0d", k*8,	memory.unified_memory[k], 
																memory.unified_memory[k]);
					showing_data=1;
				end
				else if(showing_data!=0)
				begin
					$display("@@@");
					showing_data=0;
				end
			$display("@@@");
		end
	endtask  // task show_mem_with_decimal

	
	initial
	begin
		`ifdef DUMP
		  $vcdplusdeltacycleon;
		  $vcdpluson();
		  $vcdplusmemon(memory.unified_memory);
		`endif
		  
		clock = 1'b0;
		reset = 1'b0;

		// Pulse the reset signal
		$display("@@\n@@\n@@  %t  Asserting System reset......", $realtime);
		reset = 1'b1;
		@(posedge clock);
		@(posedge clock);

		$readmemh("program.mem", memory.unified_memory);

		@(posedge clock);
		@(posedge clock);
		`SD;
		// This reset is at an odd time to avoid the pos & neg clock edges

		reset = 1'b0;
		$display("@@  %t  Deasserting System reset......\n@@\n@@", $realtime);

		wb_fileno = $fopen("writeback.out");

		//Open header AFTER throwing the reset otherwise the reset state is displayed
		//print_header("                                                                            D-MEM Bus &\n");
		//print_header("Cycle:      IF      |     ID      |     EX      |     MEM     |     WB      Reg Result");
	end

	// Count the number of posedges and number of instructions completed
	// till simulation ends
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			clock_count <= `SD 0;
			instr_count <= `SD 0;
		end
		else
		begin
			clock_count <= `SD (clock_count + 1);
			instr_count <= `SD (instr_count + core_retired_instrs);
		end
	end 

	always @(negedge clk)
	begin
		if(rst)
			$display(	"@@\n@@  %t : System STILL at reset, can't show anything\n@@",
						$realtime);
		else
		begin
		  `SD;
		  `SD;
		  
		   // print the piepline stuff via c code to the pipeline.out

			// print the writeback information to writeback.out
			if(core_retired_instrs>0) begin
				if(core_retire_wr_en)
					$fdisplay(	wb_fileno, "PC=%x, REG[%d]=%x",
								core_retire_NPC-4,
								core_retire_wr_idx,
								core_retire_wr_data);
				else
					$fdisplay(wb_fileno, "PC=%x, ---",core_retire_NPC-4);
			end

			// deal with any halting conditions
			if(core_error_status!=`NO_ERROR)
			begin
				$display(	"@@@ Unified Memory contents hex on left, decimal on right: ");
							show_mem_with_decimal(0,`MEM_64BIT_LINES - 1); 
				// 8Bytes per line, 16kB total

				$display("@@  %t : System halted\n@@", $realtime);

				case(core_error_status)
					`HALTED_ON_MEMORY_ERROR:  
						$display(	"@@@ System halted on memory error");
					`HALTED_ON_HALT:          
						$display(	"@@@ System halted on HALT instruction");
					`HALTED_ON_ILLEGAL:
						$display(	"@@@ System halted on illegal instruction");
					default: 
						$display(	"@@@ System halted on unknown error code %x",
									core_error_status);
				endcase
				$display("@@@\n@@");
				show_clk_count;
				print_close(); // close the pipe_print output file
				$fclose(wb_fileno);
				#100 $finish;
			end
		end  // if(rst)
	end



