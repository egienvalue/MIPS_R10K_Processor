`define DEBUG_OUT
typedef	struct	{
		logic	[`HT_W:0]			head_o;
		logic	[`HT_W:0]			tail_o;
		logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag_o; 
		logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	dest_tag_o;
		logic	[`ROB_W-1:0]		done_o;
		logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest_o;
		logic	[`ROB_W-1:0][63:0]	PC_o;
		logic	[`ROB_W-1:0]		br_flag_o;
		logic	[`ROB_W-1:0]		br_taken_o;
		logic	[`ROB_W-1:0]		br_pretaken_o;
		logic	[`ROB_W-1:0]		br_target_o;
		logic	[`ROB_W-1:0][`BR_MASK_W-1:0]	br_mask_o;
		logic	[`ROB_W-1:0]		wr_mem_o;
		logic	[`ROB_W-1:0]		rd_mem_o;
		logic	[`PRF_IDX_W-2:0]				fl_cur_head_o;
	} debug_t;

module test_rob;

logic	[31:0]		clock_count;
logic				clk;
logic				rst;
//******************************************************************************
//*ROB																		   *
//******************************************************************************
//------------------------------------------------------------------------------
//Inputs
//------------------------------------------------------------------------------
logic	[`PRF_IDX_W-1:0]		fl2rob_tag_i;//tag sent from freelist
logic	[`PRF_IDX_W-2:0]		fl2rob_cur_head_i;
logic	[`PRF_IDX_W-1:0]		map2rob_tag_i;//tag sent from maptable
logic	[`PRF_IDX_W-2:0]		decode2rob_logic_dest_i;//logic dest sent from decode
logic	[63:0]		            decode2rob_PC_i;//instruction's PC sent from decode
logic				            decode2rob_br_flag_i;
logic				            decode2rob_br_pretaken_i;
logic	[63:0]		            decode2rob_br_target_i;
logic				            decode2rob_rd_mem_i;
logic				            decode2rob_wr_mem_i;
logic				            dispatch_en;//signal from dispatch to allocate entry in rob;
logic	[`BR_MASK_W-1:0]        decode2rob_br_mask_i;

logic	[`ROB_IDX_W-1:0]		fu2rob_idx_i;//tag sent from functional unit to know which entry's done register needed to be set 
logic				            fu_done_i;//done signal from functional unit 
logic				            fu2rob_br_taken_i;
logic   [63:0]                  fu2rob_br_target_i;
logic   [`ROB_IDX_W-1:0]        rs2rob_rd_idx_i;
logic   [63:0]                  rob2fu_rd_NPC_o;
logic				            br_recovery_en_i;
//------------------------------------------------------------------------------
//Outputs
//------------------------------------------------------------------------------

logic	[`HT_W-1:0]             rob2rs_tail_idx_o;//tail # sent to rs to record which entry the instruction is 
logic	[`PRF_IDX_W-1:0]		rob2fl_tag_o;//tag from ROB to freelist for returning the old tag to freelist 
logic	[`PRF_IDX_W-1:0]		rob2arch_map_tag_o;//tag from ROB to Arch map
logic	[`PRF_IDX_W-2:0]		rob2arch_map_logic_dest_o;//logic dest from ROB to Arch map
logic				            rob_stall_dp_o;
logic				            rob_head_retire_rdy_o;
logic				            br_recovery_rdy_o;
logic	[`PRF_IDX_W-2:0]	    rob2fl_recover_head_o;
logic	[`BR_MASK_W-1:0]	    br_recovery_mask_o;
logic                           br_right_o;

`ifdef DEBUG_OUT
//debug_t debug_o;
debug_t debug_tb_o;

	// golden outputs
logic   [`HT_W-1:0] 	        rob2rs_tail_idx_tb_o;//tail # sent to rs to record which entry the instruction is 
logic	[`PRF_IDX_W-1:0]	    rob2fl_tag_tb_o;//tag from ROB to freelist for returning the old tag to freelist 
logic	[`PRF_IDX_W-1:0]	    rob2arch_map_tag_tb_o;//tag from ROB to Arch map
logic	[`PRF_IDX_W-2:0]	    rob2arch_map_logic_dest_tb_o;//logic dest from ROB to Arch map
logic					        rob_full_tb_o;//signal show if the ROB is full
logic					        rob_head_retire_rdy_tb_o;//the head of ROb is ready to retire
logic					        br_recovery_rdy_tb_o;//ready to start early branch recovery
logic	[`PRF_IDX_W-2:0]		rob2fl_recover_head_tb_o;
logic	[`BR_MASK_W-1:0]	    br_recovery_mask_tb_o;
logic   [`BR_STATE_W-1:0]       br_state_tb_o;          
logic					        mispredict;
logic					        retire_tb_en;


assign retire_tb_en = (debug_tb_o.done_o[debug_tb_o.head_o]==1);

assign rob2rs_tail_idx_tb_o			= debug_tb_o.tail_o[`HT_W-1:0];
assign rob2fl_tag_tb_o				= rob_head_retire_rdy_tb_o ? 
									  debug_tb_o.old_dest_tag_o[debug_tb_o.head_o[`HT_W-1:0]] : 0;
assign rob2arch_map_tag_tb_o		= rob_head_retire_rdy_tb_o ? debug_tb_o.dest_tag_o[debug_tb_o.head_o[`HT_W-1:0]] : 0;
assign rob2arch_map_logic_dest_tb_o	= rob_head_retire_rdy_tb_o ? debug_tb_o.logic_dest_o[debug_tb_o.head_o[`HT_W-1:0]] : 0;
assign rob_head_retire_rdy_tb_o 	= (debug_tb_o.done_o[debug_tb_o.head_o[`HT_W-1:0]]==1);
assign rob_full_tb_o				= (debug_tb_o.head_o^debug_tb_o.tail_o)==6'b100000&&~rob_head_retire_rdy_tb_o;
assign br_recovery_rdy_tb_o			= ~fu_done_i ? 0 : debug_tb_o.br_flag_o[fu2rob_idx_i]&&(debug_tb_o.br_pretaken_o[fu2rob_idx_i]!=fu2rob_br_taken_i);
assign rob2fl_recover_head_tb_o		= ~br_recovery_rdy_tb_o ? 0 : debug_tb_o.fl_cur_head_o[fu2rob_idx_i];
assign br_recovery_mask_tb_o	    = ~br_recovery_rdy_tb_o ? 0 : debug_tb_o.br_mask_o[fu2rob_idx_i];	
/*
assign br_predict_wrong            = (debug_tb_o.br_pretaken_o[fu2rob_idx_i]!=fu2rob_br_taken_i)|(fu2rob_br_target_i!=br_target_r[fu2rob_idx_i]);

always_comb begin
	if(debug_tb_o.br_flag_o[fu2rob_idx_i]&fu_done_i)
		if(br_predict_wrong_tb) begin
            br_state_tb_o          = `BR_PR_WRONG;
			br_recovery_mask_tb_o  = debug_tb_o.br_mask_o[fu2rob_idx_i];
			br_recovery_rdy_tb_o   = 1;
		end else begin
            br_state_tb_o          = `BR_PR_RIGHT;
			br_recovery_mask_tb_o  = debug_tb_o.br_mask_o[fu2rob_idx_i];
            br_recovery_rdy_tbo   = 0;
		end
	else begin
		br_state_tb_o          = `BR_NONE;
		br_recovery_rdy_tb_o   = 0;
		br_recovery_mask_tb_o  = 0;
	end
end
*/
logic	[`HT_W:0]			head;
logic	[`HT_W:0]			tail;
logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag, dest_tag;
logic	[`ROB_W-1:0]		done;
logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest;
logic	[`ROB_W-1:0][63:0]	PC;
logic	[`ROB_W-1:0]		br_flag;
logic	[`ROB_W-1:0]		br_taken;
logic	[`ROB_W-1:0]		br_pretaken;
logic	[`ROB_W-1:0][63:0]		br_target;
logic	[`ROB_W-1:0][`BR_MASK_W-1:0]	br_mask;
logic	[`ROB_W-1:0]		wr_mem;
logic	[`ROB_W-1:0]		rd_mem;
logic	[`PRF_IDX_W-2:0]				fl_cur_head;
`endif

//------------------------------------------------------------------------------
//Module
//------------------------------------------------------------------------------
rob rob_test1(
		.clk,
		.rst,
		
		.fl2rob_tag_i,//tag sent from freelist
		.fl2rob_cur_head_i,
		.map2rob_tag_i,//tag sent from maptable
		.decode2rob_logic_dest_i,//logic dest sent from decode
		.decode2rob_PC_i,//instruction's PC sent from decode
		.decode2rob_br_flag_i,
		.decode2rob_br_pretaken_i,
		.decode2rob_br_target_i,
		.decode2rob_rd_mem_i,
		.decode2rob_wr_mem_i,
		.rob_dispatch_en_i(dispatch_en),//signal from dispatch to allocate entry in rob;
		.decode2rob_br_mask_i(decode2rob_br_mask_i),
		
		.fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		.fu2rob_done_signal_i(fu_done_i),//done signal from functional unit 
		.fu2rob_br_taken_i,
        .fu2rob_br_target_i,
	
        .rs2rob_rd_idx_i,
        .rob2fu_rd_NPC_o,    
		
		.rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		.rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		.rob2arch_map_tag_o,//tag from ROB to Arch map
		.rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		.rob_stall_dp_o,
		.rob_head_retire_rdy_o,
		.br_recovery_rdy_o,
		.rob2fl_recover_head_o,
		.br_recovery_mask_o,
		.br_right_o

		//----------------------------------------------------------------------
		//data of ROB
		//----------------------------------------------------------------------
		`ifdef DEBUG_OUT
		//,.debug_o
		
		,.head_o(head),
		.tail_o(tail),
		.old_dest_tag_o(old_dest_tag), 
		.dest_tag_o(dest_tag),
		.done_o(done),
		.logic_dest_o(logic_dest),
		.PC_o(PC),
		.br_flag_o(br_flag),
		.br_taken_o(br_taken),
		.br_pretaken_o(br_pretaken),
		.br_target_o(br_target),
		.br_mask_o(br_mask),
		.wr_mem_o(wr_mem),
		.rd_mem_o(rd_mem),
		.fl_cur_head_o(fl_cur_head)
		
		`endif
		);

//------------------------------------------------------------------------------
//ID_STAGE
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//Input
//------------------------------------------------------------------------------



integer i,j,m,n;
integer dispatch_count = 0;
integer PC_counter;	

always
	#5 clk=~clk;

task set_input;
	input [2:0] input_control;
	dispatch_en = input_control[2];


endtask
task fu_set;
	input	[`PRF_IDX_W-1:0]	preg_idx;
	input			br_taken;
    input           br_target;    
	fu2rob_idx_i = preg_idx;
	fu2rob_br_taken_i = br_taken;
    fu2rob_br_target_i  = br_target;
	//$display("@@ ROB# %d done=1", preg_idx);
endtask 

task dispatch;
	input	[`PRF_IDX_W-1:0]	T, Told;
	input	[`PRF_IDX_W-2:0]	logic_dest; 
	input	[63:0]	PC;
	input			br_flag;
	input	[63:0]	br_target;
	input			rd_mem, wr_mem;
	
	//if_id_IR = fetch(PC);
	fl2rob_tag_i = T;
	map2rob_tag_i = Told;
	decode2rob_logic_dest_i = logic_dest;
	decode2rob_PC_i = PC;
	decode2rob_br_flag_i = br_flag;
	decode2rob_br_pretaken_i = 0;
	decode2rob_br_target_i = 0;
	decode2rob_rd_mem_i = rd_mem;
	decode2rob_wr_mem_i = wr_mem;
	decode2rob_br_mask_i = 0;
	fl2rob_cur_head_i = 0;
	dispatch_count++;
	//$display("@@Dispatch Instruction #%d", dispatch_count);
	//$display("@@ T:%d Told:%d Loic_reg:%d br:%d br_pr:%d ", T, Told, logic_dest
			 //,br_flag,0);
endtask

task debug_tb_dispatch;
	input	[`PRF_IDX_W-1:0]	T; 
	input   [`PRF_IDX_W-1:0]	Told;
	input	[`PRF_IDX_W-2:0]	logic_dest; 
	input	[63:0]	PC;
	input			br_flag;
	input	[63:0]	br_target;
	input			rd_mem, wr_mem;

	debug_tb_o.old_dest_tag_o[debug_tb_o.tail_o[`HT_W-1:0]]=Told; 
	debug_tb_o.dest_tag_o[debug_tb_o.tail_o[`HT_W-1:0]] = T;
	debug_tb_o.done_o[debug_tb_o.tail_o[`HT_W-1:0]] = 0;
	debug_tb_o.logic_dest_o[debug_tb_o.tail_o[`HT_W-1:0]] = logic_dest;
	debug_tb_o.PC_o[debug_tb_o.tail_o[`HT_W-1:0]] = PC;
	debug_tb_o.br_flag_o[debug_tb_o.tail_o[`HT_W-1:0]] = br_flag;
	debug_tb_o.br_taken_o[debug_tb_o.tail_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_pretaken_o[debug_tb_o.tail_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_target_o[debug_tb_o.tail_o[`HT_W-1:0]] = br_target;
	debug_tb_o.br_mask_o[debug_tb_o.tail_o[`HT_W-1:0]] = 0;
	debug_tb_o.wr_mem_o[debug_tb_o.tail_o[`HT_W-1:0]] = rd_mem;
	debug_tb_o.rd_mem_o[debug_tb_o.tail_o[`HT_W-1:0]] = wr_mem;
	debug_tb_o.fl_cur_head_o[debug_tb_o.tail_o[`HT_W-1:0]] = 0;
	debug_tb_o.tail_o++;

endtask

task debug_tb_retire;

	debug_tb_o.old_dest_tag_o[debug_tb_o.head_o[`HT_W-1:0]]=0; 
	debug_tb_o.dest_tag_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.done_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.logic_dest_o[debug_tb_o.head_o[`HT_W-1:0]] = `ZERO_REG;
	debug_tb_o.PC_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_flag_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_taken_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_pretaken_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_target_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.br_mask_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.wr_mem_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.rd_mem_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.fl_cur_head_o[debug_tb_o.head_o[`HT_W-1:0]] = 0;
	debug_tb_o.head_o++;

endtask

task debug_tb_setdone;
	input	[`PRF_IDX_W-1:0]	preg_idx;
	debug_tb_o.done_o[preg_idx] = 1;
endtask

task debug_tb_br_miss;
	input	[`PRF_IDX_W-1:0]	preg_idx;	
	input			br_taken;
	debug_tb_o.br_taken_o[preg_idx] = debug_tb_o.br_flag_o[preg_idx] ? br_taken : 0;
	debug_tb_o.tail_o = preg_idx+1;
endtask

/*
task print_rob;
	$display("State of ROB");
	for(i=0;i<32;i++)
		if(i==head)	
			$display("@@|h:%2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else if (i==tail)
			$display("@@|t:%2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else
			$display("@@|  %2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);	
endtask
*/

task print_valid_rob;
   	$display("@@@    Tnew | Told | dest | Done | rd_wr | br | br p&t |        PC        |      t-PC        | br_mask | ");
	for (i = head[`HT_W-1:0]; i!=tail[`HT_W-1:0]; i++) begin
        if(i>=`ROB_W)
            i = i%`ROB_W;
		$display("@@@ %-2d: p%d |  p%d |  r%d |   %b  |  %b %b  |  %b |   %b%b   | %h | %h |  %b  |", i, 
			dest_tag[i], old_dest_tag[i], logic_dest[i], 
			done[i], rd_mem[i], wr_mem[i], br_flag[i],
			br_pretaken[i], br_taken[i], PC[i], br_target[i], 
			br_mask[i]);
	end

    // print head and tail pointer
	$display("@@@ #pointer# head: %d | tail: %d | disp_en: %b", rob_test1.head_r[`HT_W-1:0], 
		rob_test1.tail_r[`HT_W-1:0], rob_test1.rob_dispatch_en_i);
	$display("@@@ #done# fu done: %d | rob done entry: %d", fu_done_i,
		fu2rob_idx_i);
	if (rob_test1.rob_head_retire_rdy_o)
		$display("@@@ #retire# retiring rob head at this cycle");
	if (rob_test1.br_recovery_rdy_o)
		$display("@@@ #br_recovery# recovering to rob entry: %d", rob_test1.tail_r_nxt);

    

endtask

task check;
	if(head			 == debug_tb_o.head_o			 &&
	   tail			 == debug_tb_o.tail_o			 &&
	   old_dest_tag	 == debug_tb_o.old_dest_tag_o	 &&
	   dest_tag		 == debug_tb_o.dest_tag_o		 &&
	   done			 == debug_tb_o.done_o			 &&
	   logic_dest    == debug_tb_o.logic_dest_o		 &&
	   PC			 == debug_tb_o.PC_o				 &&
	   br_flag		 == debug_tb_o.br_flag_o		 &&
	   br_taken		 == debug_tb_o.br_taken_o		 &&
	   br_pretaken	 == debug_tb_o.br_pretaken_o	 &&
	   br_target     == debug_tb_o.br_target_o		 &&
	   br_mask       == debug_tb_o.br_mask_o		 &&
	   wr_mem		 == debug_tb_o.wr_mem_o			 &&
	   rd_mem		 == debug_tb_o.rd_mem_o			 
		) begin
	end else begin
		$display ("@@@Failed Reg time:%f",$time);
		$finish;
	end

endtask

task check_output;
	if(
	rob2rs_tail_idx_o 		== rob2rs_tail_idx_tb_o				&&
	rob2fl_tag_o 				== rob2fl_tag_tb_o				&&
	rob2arch_map_tag_o		== rob2arch_map_tag_tb_o			&&
	rob2arch_map_logic_dest_o	== rob2arch_map_logic_dest_tb_o	&&
	rob_stall_dp_o					== rob_full_tb_o				&&
	rob_head_retire_rdy_o		== rob_head_retire_rdy_tb_o		&&
	br_recovery_rdy_o			== br_recovery_rdy_tb_o			&&
	rob2fl_recover_head_o		== rob2fl_recover_head_tb_o		&&
	br_recovery_mask_o	== br_recovery_mask_tb_o	) begin
	end else begin
		$display ("@@@Failed Output time:%f",$time);
		$finish;
	end

endtask

task debug_tb_reset;
	debug_tb_o.head_o			=0;	
	debug_tb_o.tail_o			=0;
	debug_tb_o.old_dest_tag_o	=0;
	debug_tb_o.dest_tag_o		=0;
	debug_tb_o.done_o			=0;
	debug_tb_o.logic_dest_o		=`ZERO_REG;
	debug_tb_o.PC_o				=0;
	debug_tb_o.br_flag_o		=0;
	debug_tb_o.br_taken_o		=0;
	debug_tb_o.br_pretaken_o	=0;
	debug_tb_o.br_target_o		=0;
	debug_tb_o.br_mask_o		=0;
	debug_tb_o.wr_mem_o			=0;
	debug_tb_o.rd_mem_o			=0;
	debug_tb_o.fl_cur_head_o	=0;

endtask

initial begin
	debug_tb_reset;
	dispatch_en=0;
	mispredict=0;
	fu_done_i=0;
	clk = 0;	
	rst=1;
	@(negedge clk);
	rst=1;
	@(negedge clk);
	rst=0;
	
	$display("Testbench Start!!!");
	//--------------------------------------------------------------------------
	//Dispatch Test: including full stall
	//--------------------------------------------------------------------------
	for(i=0;i<40;i++) begin
		if(~rob_stall_dp_o) begin
			@(negedge clk);
			dispatch_en = 1;
			dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end
		if (~rob_full_tb_o) begin	
			debug_tb_dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end 
		@(posedge clk);
		#4
		dispatch_en = 0;
		check;
		//check_output;
			//$display("Reoder buffer is full");
	end
	//print_rob;
	$display("@@@Test1 passed");
	@(negedge clk);
	//--------------------------------------------------------------------------
	//Retire Test: including empty case
	//--------------------------------------------------------------------------
	for(i=0;i<40;i++) begin
		if(head!=tail) begin
			fu_done_i = 1;
			fu_set(i,0,0);
		end
		if(debug_tb_o.head_o != debug_tb_o.tail_o) begin
			debug_tb_setdone(i);
		end
		@(posedge clk);
		#2
		check;
		//check_output;
		fu_done_i=0;
		@(posedge clk);
		if(debug_tb_o.head_o != debug_tb_o.tail_o) begin
			debug_tb_retire;
		end
		#5
		check;
		//check_output;
		@(negedge clk);

	end
	$display("@@@Test2 passed");

	//--------------------------------------------------------------------------
	//Reset and dispatch 10 instructions
	/*
	@(negedge clk);
	rst=1;
	@(negedge clk);
	rst=0;
	debug_tb_reset;
	*/
	@(negedge clk);
	for(i=0;i<10;i++) begin
		if(~rob_stall_dp_o) begin
			@(negedge clk);
			dispatch_en = 1;
			dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end
		if (~rob_full_tb_o) begin	
			debug_tb_dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end 
		@(posedge clk);
		#4
		dispatch_en = 0;
		check;
		//check_output;
			//$display("Reoder buffer is full");
	end
	$display("@@@Test3 passed");
	//--------------------------------------------------------------------------
	//Dispatch and retire at the same time
	//--------------------------------------------------------------------------
	for(i=0;i<14;i++) begin
		@(negedge clk)
		if(~rob_stall_dp_o) begin
			dispatch_en = 1;
			dispatch(42+i,i,i,i*4,0,i*8,0,0);
		end
			fu_done_i = 1;
			fu_set(head[`HT_W-1:0],0,0);
		@(posedge clk);
		if (~rob_full_tb_o) begin	
			debug_tb_dispatch(42+i,i,i,i*4,0,i*8,0,0);
		end
		debug_tb_setdone(debug_tb_o.head_o[`HT_W-1:0]);
		#3
		dispatch_en = 0;
		fu_done_i = 0;
		check;
		//check_output;
		@(posedge clk);
		debug_tb_retire;
		@(negedge clk);
		check;
		//check_output;
	end
	$display("@@@Test4 passed");
	@(negedge clk);
	//print_rob;

	//--------------------------------------------------------------------------
	//Mispredicted recovery(not fully tested, waiting for branch recovery module
	//to be added)
	//--------------------------------------------------------------------------

	@(negedge clk);
	for(i=0;i<10;i++) begin
		if(~rob_stall_dp_o) begin
			@(negedge clk);
			dispatch_en = 1;
			dispatch(32+i,i,i,i*4,(i==5),i*8,0,0);
		end
		if (~rob_full_tb_o) begin	
			debug_tb_dispatch(32+i,i,i,i*4,(i==5),i*8,0,0);
		end 
		@(negedge clk);
		dispatch_en = 0;
		check;
		//check_output;
			//$display("Reoder buffer is full");
	end
	$display("start recover");
	@(negedge clk);
	fu_done_i = 1;
	fu_set(29,1,0);
	@(posedge clk);
	debug_tb_setdone(29);
	debug_tb_br_miss(29,1);
	@(negedge clk);
	fu_done_i=0;
	#3
	check;
	//check_output;

	$display("@@@Test5 passed");

	$display("@@@Passed");

    for(i=0;i<10;i++) begin
		if(~rob_stall_dp_o) begin
			@(negedge clk);
			dispatch_en = 1;
			dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end
		if (~rob_full_tb_o) begin	
			debug_tb_dispatch(32+i,i,i,i*4,0,i*8,0,0);
		end 
		@(posedge clk);
		#4
		dispatch_en = 0;
		check;
		//check_output;
			//$display("Reoder buffer is full");
	end

    print_valid_rob;

	$finish;

end



always @(posedge clk) begin
    if(rst) begin
      clock_count <= `SD 0;
    end else begin
      clock_count <= `SD (clock_count + 1);
    end
end  

endmodule
