// ****************************************************************************
// Filename: lsq_tb.v
// Discription: 
// Author: Shijing, Lu Liu
// Version History:
// intial creation: 11/16/2017
// ***************************************************************************
module lsq_tb;

	logic						clk;
	logic						rst;

	// store signals
	logic	[`ADDR_W-1:0]		addr;
	logic	[63:0]				st_data;
	logic						st_vld;
	logic	[`SQ_IDX_W-1:0]		sq_idx;
	logic						rob_st_retire_en;
	logic						dp_en;

	// load signals
	logic	[`ROB_IDX_W-1:0]	rob_idx;
	logic	[`PRF_IDX_W-1:0]	dest_tag;
	logic						ld_vld;
	logic	[`SQ_IDX_W-1:0]		rs_ld_position;
	logic	[`SQ_IDX_W-1:0]		ex_ld_position;

	// Dcache signals
	logic						Dcache_hit;
	logic	[63:0]				Dcache_data;
	logic	[`ADDR_W-1:0]		Dcache_mshr_addr;
	logic						Dcache_mshr_vld;
	logic						Dcache_mshr_stall;

	// output signals
	logic	[`SQ_IDX_W-1:0]		lsq_sq_tail;
	logic						lsq_ld_iss_en;
	logic	[`ADDR_W-1:0]		lsq2Dcache_ld_addr;
	logic						lsq2Dcache_ld_en;
	logic	[63:0]				lsq_ld_data;
	logic	[`ROB_IDX_W-1:0]	lsq_ld_rob_idx;
	logic	[`PRF_IDX_W-1:0]	lsq_ld_dest_tag;
	logic						lsq_lq_com_rdy;
	logic						lsq_sq_full;

	logic						dispatch;
	logic						load_insn;
	logic						store_vld;
	
	integer						cycle_counter;
	
	assign dispatch = ~lsq_sq_full & dp_en;
	assign store_vld = st_vld;


	lsq lsq0(
		.clk(clk),
		.rst(rst),

		.addr_i(addr),
		.st_data_i(st_data),
		.st_vld_i(store_vld),
		.sq_idx_i(sq_idx),
		.rob_st_retire_en_i(rob_st_retire_en),
		.dp_en_i(dispatch),

		.rob_idx_i(rob_idx),
		.dest_tag_i(dest_tag),
		.ld_vld_i(ld_vld),
		.rs_ld_position_i(rs_ld_position),
		.ex_ld_position_i(ex_ld_position),

		.Dcache_hit_i(Dcache_hit),
		.Dcache_data_i(Dcache_data),
		.Dcache_mshr_addr_i(Dcache_mshr_addr),
		.Dcache_mshr_vld_i(Dcache_mshr_vld),
		.Dcache_mshr_stall_i(Dcache_mshr_stall),

		.lsq_sq_tail_o(lsq_sq_tail),
		.lsq_ld_iss_en_o(lsq_ld_iss_en),
		.lsq2Dcache_ld_addr_o(lsq2Dcache_ld_addr),
		.lsq2Dcache_ld_en_o(lsq2Dcache_ld_en),
		.lsq_ld_data_o(lsq_ld_data),
		.lsq_ld_rob_idx_o(lsq_ld_rob_idx),
		.lsq_ld_dest_tag_o(lsq_ld_dest_tag),
		.lsq_lq_com_rdy_o(lsq_lq_com_rdy),
		.lsq_sq_full_o(lsq_sq_full)
		);

	always begin
		#5;
		clk=~clk;
	end

	always @(posedge clk) begin
		if (rst)
			cycle_counter	<= `SD 0;
		else
			cycle_counter	<= `SD cycle_counter + 1;
	end

	integer i,j;

	task print_sq;
		$display("@@@  SQ_IDX |  VLD  |       ADDR       |  DATA");
		for (i=0; i<`SQ_ENT_NUM ;i++) begin
			$display("@@@   %-5d |   %d   | %h | %h",i,
			lsq0.st_addr_vld_r[i], lsq0.st_addr_r[i],
			lsq0.st_data_r[i]);
		end
	endtask

	task print_lq;
		$display("@@@  LQ_IDX |       ADDR       | RDY |       DATA       | ROB_IDX | DEST ");
		for (i=0; i<`LQ_ENT_NUM ;i++) begin
			$display("@@@   %-5d | %h |  %h  | %h |    %d   | %d",i,
			lsq0.lq_addr_r[i], lsq0.lq_rdy_r[i],
			lsq0.lq_data_r[i], lsq0.lq_rob_idx_r[i],
			lsq0.lq_dest_tag_r[i]);
		end
	endtask

	task print_lsq;
		#1;
		$display("@@@");
		$display("@@@");
		$display("@@@ At cycle %3d:", cycle_counter);
		$display("@@@ The content of SQ is:");
		print_sq;
		$display("@@@ HEAD:%d  TAIL:%d",lsq0.sq_head_r,lsq0.sq_tail_r);
		if(dispatch) begin
			$display("@@@ dispatch STORE, allocate SQ entry");
		end
		if(st_vld) begin
			$display("@@@ execute STORE, set VLD");
		end
		if(lsq_sq_full) begin
			$display("@@@ SQ full, stall dispatch");
		end
		if(rob_st_retire_en) begin
			$display("@@@ retire SQ HEAD");
		end
		$display("@@@");
		$display("@@@");
		$display("@@@ The content of LQ is:");
		print_lq;
		$display("@@@ HEAD:%d  TAIL:%d",lsq0.lq_head_r,lsq0.lq_tail_r);
		if(load_insn & lsq_ld_iss_en) begin
			$display("@@@ current LOAD can be issued");
		end if(load_insn & ~lsq_ld_iss_en)	begin
			$display("@@@ current LOAD cannot be issued");
		end
		if(ld_vld &&(~lsq.ld_miss)) begin
			$display("@@@ current LOAD data is available");
		end if(ld_vld && lsq.ld_miss)begin
			$display("@@@ current LOAD data is not available, save to LQ");
		end
	endtask

	initial begin
		rst = 1'b1;
		clk = 0;
		addr = {$random,$random};
		st_data = {$random,$random};
		st_vld = 0;
		sq_idx = 0;
		rob_st_retire_en = 0;
		dp_en = 1;

		rob_idx = 0;
		dest_tag = 0;
		ld_vld = 0;
		rs_ld_position = 0;
		ex_ld_position = 0;
		load_insn = 0;
		
		Dcache_hit = 0;
		Dcache_data = 0;
		Dcache_mshr_addr = 0;
		Dcache_mshr_vld = 0;
		Dcache_mshr_stall = 0;

		//@(negedge clk);
		@(negedge clk);
		rst = 1'b0;
		print_lsq;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		
		
		for(j=0 ; j<7 ; j++) begin
			addr = j;
			st_data = {$random,$random};
			//st_vld = 1;
			//if(j>5) rob_st_retire_en = 1;
			@(negedge clk);
			sq_idx = 5-j;
			st_vld = 1;
			print_lsq;
		end

		st_vld = 0;
		for(j=0 ; j<5 ; j++) begin
			addr = j+5;
			ld_vld = 1;
			ex_ld_position = 8;
			rob_st_retire_en = 1;
			//dp_en = 0;
			@(negedge clk);
			print_lsq;
		end
		@(negedge clk);
		Dcache_mshr_addr = 9;
		Dcache_mshr_vld = 1;
		Dcache_data = {$random,$random};
		print_lsq;
		@(negedge clk);
		print_lsq;
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);

		



/*
		@(negedge clk);
		for(j=0 ; j<3 ; j++) begin
			rob_st_retire_en = 1;
			@(negedge clk);
			print_lsq;
		end
*/
		
		$finish;


	end
endmodule




