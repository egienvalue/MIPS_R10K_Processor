
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
	logic			clk;
	logic			rst;

												//|From where|
	logic			dispatch_en_i;			//[Decoder]		If true, output head entry and head++
	logic			retire_en_i;			//[ROB]			If true, write new retired preg to tail, and tail++
	logic	[5:0]	retire_preg_i;			//[ROB]			New retired preg.
	logic			recover_en_i;			//[ROB]			Enabling early branch single cycle recovery
	logic   [4:0]	recover_head_i;			//[ROB]			Recover head to some point

	logic	[5:0]	cnt;
	logic	[4:0]	hd;
	logic   [4:0]	tl;
		  								//|To where|
	logic			free_preg_vld_o;		//[ROB, Map Table, RS]	Is output valid?
	logic	[5:0]	free_preg_o;		//[ROB, Map Table, Rs]	Output new free preg.
	logic	[4:0]	free_preg_cur_head_o;	//[ROB]			Current head pointer.

	logic	[11:0]	clock_count;

	// 2. Module instantiation. 
	free_list free_list0(	
		.clk						(clk				),  	
		.rst						(rst				),  	
		.dispatch_en_i				(dispatch_en_i		),		
		.retire_en_i				(retire_en_i		),
		.retire_preg_i				(retire_preg_i		),	
		.recover_en_i				(recover_en_i		),
		.recover_head_i				(recover_head_i		),
		
		.cnt						(cnt				),
		.hd							(hd					),
		.tl							(tl					),
		.free_preg_vld_o			(free_preg_vld_o	),
		.free_preg_o				(free_preg_o		),
		.free_preg_cur_head_o		(free_preg_cur_head_o)
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
			dispatch_en_i	= 0;
			retire_en_i		= 0;
			retire_preg_i	= 6'b000000;
			recover_en_i	= 0;
			recover_head_i	= 5'b00000;
		end
	endtask
	
	// 5. Initial
	initial begin
		clock_count = 0;
		clk = 1'b0;
		rst = 1'b0;
		
		clear_inputs;

		$monitor("clock_count: %d, count: %d, head: %d, tail:%d, free_preg_vld_o:%d, free_preg_o:%d, free_preg_cur_head_o:%d",clock_count, cnt, hd, tl, free_preg_vld_o, free_preg_o, free_preg_cur_head_o);
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
		// Case 1: dispatch 32 entries
		$display("@@@ Case 1");
		dispatch_en_i = 1;
		for(int i=0;i<32;i++) begin
			@(posedge clk);
			#4
			if(hd!=(i+1)%32 || tl!=0 || cnt!=32-i-1) begin
				$display("@@@ Failed.");
				$finish;
			end
			@(negedge clk);
		end

		// Case 2: retire 32
		$display("@@@ Case 2");
		dispatch_en_i = 0;
		retire_en_i = 1;
		for(int i=0;i<32;i++) begin
			retire_preg_i = i;
			@(posedge clk);
			#4
			if(hd!=0 || tl!=(i+1)%32 || cnt!=i+1) begin
				$display("@@@ Failed.");
				$finish;
			end
			@(negedge clk);
		end
		retire_en_i = 0;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);

		// Case 3: dispatch 32 again 
		$display("@@@ Case 3");
		retire_en_i = 0;
		dispatch_en_i = 1;
		for(int i=0;i<32;i++) begin
			@(posedge clk);
			#4
			if(hd!=(i+1)%32 || tl!=0 || cnt!=32-i-1) begin
				$display("@@@ Failed.");
				$finish;
			end
			@(negedge clk);
		end
		
		// Case 4: fill&retrieve at the same time
		$display("@@@ Case 4");
		retire_en_i = 1;
		retire_preg_i = 25;
		`SD;
		if(hd!=0||tl!=0||cnt!=0||free_preg_o!=25) begin				// Output before posedge of clk.
			$display("@@@ Failed.");
			$finish;
		end 
		@(posedge clk);	
		@(negedge clk);
		dispatch_en_i = 0;
		retire_en_i = 0;
		`SD;
		if(hd!=0||tl!=0||cnt!=0||free_preg_o!=0) begin				// Output before posedge of clk.
			$display("@@@ Failed.");
			$finish;
		end 
		@(posedge clk);
		if(hd!=0||tl!=0||cnt!=0||free_preg_o!=0) begin				// Output before posedge of clk.
			$display("@@@ Failed.");
			$finish;
		end 
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
