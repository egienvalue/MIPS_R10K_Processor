module testbench();
	logic clk , rst ;
	logic branch_i;
	logic br_dirp_i;
	logic return_i;
	logic [63:0] ras_target_i;
	logic [63:0] br_predict_target_PC_i;
	logic [63:0] br_flush_target_PC_i;
	logic [63:0] Imem2proc_data;
	logic Imem_valid;
	logic br_flush_en_i;
	logic id_request_i;
	logic [63:0] proc2Imem_addr;
	logic [63:0] if_NPC_out;
	logic [31:0] if_IR_out;
	logic if_valid_inst_out;

	integer i;


	
	if_stage if0(
	.clk,
   	.rst,
	.branch_i,
	.br_dirp_i,
	.return_i,
	.ras_target_i,
	.br_predict_target_PC_i,
	.br_flush_target_PC_i,
	.Imem2proc_data,
	.Imem_valid,
	.br_flush_en_i,
	.id_request_i,
	.proc2Imem_addr,
	.if_NPC_out,
	.if_IR_out,
	.if_valid_inst_out
	);

	always begin
			#5;
			clk=~clk;
	end

	initial begin

		//$vcdpluson;
		$monitor("Time:%4.0f rst:%b Imem_valid:%b id_request_i:%b if_NPC_out:%h if_IR_out:%h if_valid_inst_out:%d",$time,rst,Imem_valid,id_request_i,if_NPC_out,if_IR_out,if_valid_inst_out);
		clk = 0;
		rst=1;
		Imem_valid=0;
		branch_i=0;
		br_dirp_i=0;
		return_i=0;
		ras_target_i={$random,$random};
		br_predict_target_PC_i={$random,$random};
		br_flush_target_PC_i={$random,$random};
		br_flush_en_i=0;
		id_request_i=0;

		//specific corner cases
		@(negedge clk);
		//ifcontrol=1;
		@(negedge clk);
		//rst=0;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		Imem2proc_data = {$random,$random};

		for (i = 0; i < 80; i = i+1) begin 
			//ifcontrol=1;
			@(posedge clk);
			rst=0;
			//PC = 4*i;
			id_request_i=1;
			Imem_valid=1;
		//	Imem2proc_data = {$random,$random};
		end
		//br_flush_en_i=1;
		@(negedge clk);
		@(negedge clk);
		//flush=1;
		for (i = 0; i < 80; i = i+1) begin 
			//ifcontrol=1;
			@(negedge clk);
			//id_request_i=1;
			//decontrol=1;
			//PC = 4*i;
			//insn = {$random};
       	end

		@(negedge clk);
		@(negedge clk);
		@(negedge clk);

		@(negedge clk);
		@(negedge clk);
		@(negedge clk);

		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		$finish;
	end

endmodule
