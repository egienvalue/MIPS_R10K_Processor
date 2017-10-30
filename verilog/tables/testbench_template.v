
`timescale 1ns/100ps

// C library for file printing.
extern void print_header(string str);
extern void print_cycles();
extern void print_stage(string div, int inst, int npc, int valid_inst);
extern void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo,
                      int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
extern void print_membus(int proc2mem_command, int mem2proc_response,
                         int proc2mem_addr_hi, int proc2mem_addr_lo,
                         int proc2mem_data_hi, int proc2mem_data_lo);
extern void print_close();

// Module starts here.
module testbench;

	// 1. Variables used in the testbench
	//	  (1)Inputs
	logic				clk;
	logic				rst;
	logic	[4:0]		opa_areg_idx_i;			
	logic	[4:0]		opb_areg_idx_i;			
	logic	[4:0]		dest_areg_idx_i;		
	logic	[5:0]		new_free_preg_i;		
	logic				dispatch_en_i;			
	logic	[5:0]		cdb_set_RDYit_preg_i;	
	logic				cdb_set_RDYit_en_i;		
	logic	[31:0][5:0] preg_restore_dump_i;	
	logic				preg_restore_dump_en_i;							
	//	  (2)Outputs											
	logic	[5:0]		opa_preg_o;				
	logic	[5:0]		opb_preg_o;				
	logic				opa_preg_RDYit_o;		
	logic				opb_preg_RDYit_o;		
	logic	[5:0]		dest_old_preg_o;			

	// 2. Module instantiation. 
	map_table map_table_0(
		.clk					(clk					),  	
		.rst					(rst					),  	
		.opa_areg_idx_i			(opa_areg_idx_i			),  
		.opb_areg_idx_i			(opb_areg_idx_i			),  
		.dest_areg_idx_i		(dest_areg_idx_i		),
		.new_free_preg_i		(new_free_preg_i		),
		.dispatch_en_i			(dispatch_en_i			),
		.cdb_set_RDYit_preg_i	(cdb_set_RDYit_preg_i	),
		.cdb_set_RDYit_en_i		(cdb_set_RDYit_en_i		),
		.preg_restore_dump_i	(preg_restore_dump_i	),
		.preg_restore_dump_en_i	(preg_restore_dump_en_i	),
		.opa_preg_o				(opa_preg_o				),
		.opb_preg_o				(opb_preg_o				),
		.opa_preg_RDYit_o		(opa_preg_RDYit_o		),
		.opb_preg_RDYit_o		(opb_preg_RDYit_o		),
		.dest_old_preg_o		(dest_old_preg_o		)
	);

	// 3. Generate System clk
	always begin
		#(`VERILOG_clk_PERIOD/2.0);
		clk = ~clk;
	end

	// 4. Tasks
	//    An example:
	task show_clk_count;
		real cpi;

		begin
			cpi = (clk_count + 1.0) / instr_count;
			$display("@@  %0d cycles / %0d instrs = %f CPI\n@@",
                clk_count+1, instr_count, cpi);
			$display("@@  %4.2f ns total time to execute\n@@\n",
                clk_count*`VIRTUAL_clk_PERIOD);
		end
	endtask 


	// 5. Initial block
	initial begin
  
		clk = 1'b0;
		rst = 1'b0;
	
		// Pulse the rst signal
		$display("@@\n@@\n@@  %t  Asserting System rst......", $realtime);
		rst = 1'b1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		`SD;
		// This rst is at an odd time to avoid the pos & neg clk edges
		rst = 1'b0;
		$display("@@  %t  Deasserting System rst......\n@@\n@@", $realtime);
		
		// Get a file handler.
		wb_fileno = $fopen("writeback.out");

		// Case 1
	

		// Case 2
	
		
		// Case 3

		// ...


	end

	// 6. Periodical assignment (sequentially) procedure. Assignments always happen
	//    at the posedge of clk. 
	always @(posedge clk) begin
		if (rst) begin
			//... <= 0
		else begin
			//... <= ...
		end
	end

	// 7. Print procedure. Always print at the negedge of clk.
	always @(negedge clk) begin
		// Handle rst.
		if(rst)
			$display("@@\n@@  %t : System STILL at rst, can't show anything\n@@",
        		       	$realtime);
		else begin
			`SD;
			`SD;
      
			// print the piepline stuff via c code to the pipeline.out
			print_cycles();
			print_stage(" ", if_IR_out, if_NPC_out[31:0], {31'b0,if_valid_inst_out});
			
			if (pipeline_commit_wr_en) begin
				$fdisplay(wb_fileno, "PC=%x, REG[%d]=%x",		// Print to file
                     			pipeline_commit_NPC-4,
                     			pipeline_commit_wr_idx,
                    		 	pipeline_commit_wr_data);
				$display("@@  %t : System halted\n@@", $realtime);	// Print to terminal.
			end else begin
				$fdisplay(wb_fileno, "PC=%x, ---",pipeline_commit_NPC-4);
				$display("@@  %t : System halted\n@@", $realtime);
			end
		end
	end
endmodule
