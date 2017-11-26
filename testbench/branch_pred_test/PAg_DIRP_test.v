
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

// Module start here.
module testbench;

	// 1. Variables used in the testbench
	//	  Inputs
	logic						clk;
	logic						rst;
	
	logic						is_br_i;		//[Dispatch]	A new branch is dispatched, mask should be updated.
	logic	[`BR_STATE_W-1:0]	br_state_i;		//[ROB]			Branch prediction wrong or correct?		
	logic	[`BR_MASK_W-1:0]	br_dep_mask_i;	//[ROB]			The mask of currently resolved branch.

	logic	[`BR_MASK_W-1:0]	br_mask_o;		//[ROB][Stacks]			Send current mask value to ROB to save in an ROB entry.
	logic	[`BR_MASK_W-1:0]	br_bit_o;		//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
	logic						full_o;		//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
	
	logic	[11:0]				clock_count;

	logic	[`BR_MASK_W-1:0]	temp_bits;
	// 2. Module instantiation. 
	br_mask_ctrl mask_ctrl0 (
		.clk, 
		.rst,
		.is_br_i,			//[Dispatch]	A new branch is dispatched, mask should be updated.
		.br_state_i,		//[ROB]			Branch prediction wrong or correct?		
		.br_dep_mask_i,		//[ROB]			The mask of currently resolved branch.
		.br_mask_o,			//[ROB][Stacks]			Send current mask value to ROB to save in an ROB entry.
		.br_bit_o,			//[RS]			Output corresponding branch bit immediately after knowing wrong or correct. 
		.full_o				//[ROB]			Tell ROB that stack is full and no further branch dispatch is allowed. 
	);
	

	// 3. Generate System Clock
	always begin
		#(`VERILOG_CLOCK_PERIOD/2.0);
		clk = ~clk;
	end

	// 4. Tasks
	//    an example:
	task clear_inputs;
		begin
			is_br_i			=	0; 	 
            br_state_i		=	2'b00;
            br_dep_mask_i	=	`BR_MASK_W'b0;
		end
	endtask
	
	// 5. Initial
	initial begin
		clock_count = 0;
		clk = 1'b0;
		rst = 1'b0;
		
		clear_inputs;

		$monitor("clock_count: %d, br_mask_o: %b, br_bit_o: %b, full_o:%d",clock_count, br_mask_o, br_bit_o, full_o);
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
	

		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		//---------------------------------Cases start------------
		temp_bits = 5'b00000;
		// Case 1: 5 branches come
		$display("@@@ Case 1");
		is_br_i = 1'b1;
		for(int i=0;i<5;i++) begin
			@(posedge clk);
			#4
			temp_bits[i] = 1;
			if (br_mask_o!= temp_bits|| full_o!= (i==4) || br_bit_o!=0) begin
				$display("@@@ Failed.");
				$display("@@@ br_mask_o: %b, br_bit_o: %5b, full_o:%d.", temp_bits, 0,1);
				$finish;
			end
			@(negedge clk);
		end

		is_br_i = 1'b0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		// Case 2: idx 2 branch correct

		@(negedge clk);
		br_state_i = `BR_PR_CORRECT;
		br_dep_mask_i = 5'b00011;
		@(posedge clk);
		@(negedge clk);
		br_dep_mask_i = 5'b01111;
		@(posedge clk);
		@(negedge clk);
		br_state_i = `BR_PR_WRONG;
		br_dep_mask_i = 5'b00001;
		@(posedge clk);
		@(negedge clk);
		br_state_i = 0;
		br_dep_mask_i = 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		


		// It's better at every loop check output manually first and check
		// through mem table second(write a simulation function above)...  
		$display("@@@ Passed!");
		$finish;
	end

	// Count the number of posedges and number of instructions completed
	 // till simulation ends
	always @(posedge clk) begin
		if(rst) begin
			clock_count <= `SD 0;
		end else begin
			clock_count <= `SD (clock_count + 1);
		end
	end  
endmodule
