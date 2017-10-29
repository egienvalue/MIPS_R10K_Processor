`define DEBUG_OUT
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
logic	[5:0]		fl2rob_tag_i;//tag sent from freelist
logic	[5:0]		map2rob_tag_i;//tag sent from maptable
logic	[4:0]		decode2rob_logic_dest_i;//logic dest sent from decode
logic	[63:0]		decode2rob_PC_i;//instruction's PC sent from decode
logic				decode2rob_br_flag_i;
logic				decode2rob_br_pretaken_i;
logic				decode2rob_br_target_i;
logic				decode2rob_rd_mem_i;
logic				decode2rob_wr_mem_i;
logic				dispatch_en;//signal from dispatch to allocate entry in rob;

logic	[5:0]		fu2rob_idx_i;//tag sent from functional unit to know which entry's done register needed to be set 
logic				fu_done_i;//done signal from functional unit 
logic				fu2rob_br_taken_i;
logic				head_retire_en_i;//retire the head of rob entry and free the entry 

logic				br_recovery_en_i;
//------------------------------------------------------------------------------
//Outputs
//------------------------------------------------------------------------------

logic	[`HT_W-1:0] rob2rs_tail_idx_o;//tail # sent to rs to record which entry the instruction is 
logic	[5:0]		rob2fl_tag_o;//tag from ROB to freelist for returning the old tag to freelist 
logic	[5:0]		rob2arch_map_tag_o;//tag from ROB to Arch map
logic	[4:0]		rob2arch_map_logic_dest_o;//logic dest from ROB to Arch map
logic				rob_full_o;
logic				rob_head_retire_rdy_o;
logic				br_recovery_rdy_o;

`ifdef DEBUG_OUT
logic	[`HT_W:0]			head;
logic	[`HT_W:0]			tail;
logic	[`ROB_W-1:0][5:0]	Told, T;
logic	[`ROB_W-1:0]		done;
logic	[`ROB_W-1:0][4:0]	logic_dest;
logic	[`ROB_W-1:0][63:0]	PC;
logic	[`ROB_W-1:0]		br_flag;
logic	[`ROB_W-1:0]		br_taken;
logic	[`ROB_W-1:0]		br_pretaken;
logic	[`ROB_W-1:0]		br_target;
logic	[`ROB_W-1:0]		wr_mem;
logic	[`ROB_W-1:0]		rd_mem;
`endif
//------------------------------------------------------------------------------
//Module
//------------------------------------------------------------------------------
rob rob_test1(
		.clk,
		.rst,
		
		.fl2rob_tag_i,//tag sent from freelist
		.map2rob_tag_i,//tag sent from maptable
		.decode2rob_logic_dest_i,//logic dest sent from decode
		.decode2rob_PC_i,//instruction's PC sent from decode
		.decode2rob_br_flag_i,
		.decode2rob_br_pretaken_i,
		.decode2rob_br_target_i,
		.decode2rob_rd_mem_i,
		.decode2rob_wr_mem_i,
		.rob_dispatch_en_i(dispatch_en),//signal from dispatch to allocate entry in rob;
		
		.fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		.fu2rob_done_signal_i(fu_done_i),//done signal from functional unit 
		.fu2rob_br_taken_i,
		.head_retire_en_i,//retire the head of rob entry and free the entry 
		
		.br_recovery_en_i,
		
		.rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		.rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		.rob2arch_map_tag_o,//tag from ROB to Arch map
		.rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		.rob_full_o,
		.rob_head_retire_rdy_o,
		.br_recovery_rdy_o


		//----------------------------------------------------------------------
		//data of ROB
		//----------------------------------------------------------------------
		`ifdef DEBUG_OUT
		,.head_o(head),
		.tail_o(tail),
		.old_dest_tag_o(Told), 
		.dest_tag_o(T),
		.done_o(done),
		.logic_dest_o(logic_dest),
		.PC_o(PC),
		.br_flag_o(br_flag),
		.br_taken_o(br_taken),
		.br_pretaken_o(br_pretaken),
		.br_target_o(br_target),
		.wr_mem_o(wr_mem),
		.rd_mem_o(rd_mem)
		`endif
		);
`ifdef MAP_AND_FL
//******************************************************************************
//*MapT																		   *
//******************************************************************************


//------------------------------------------------------------------------------
//Inputs
//------------------------------------------------------------------------------
logic	[4:0]		opa_areg_idx_i;				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.
logic	[4:0]		opb_areg_idx_i;				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
logic	[4:0]		dest_areg_idx_i;			//[Decoder]		A logic register index to read the old dest physical reg; and to write a new dest physical reg.
logic	[5:0]		new_free_preg_i;			//[Free-List]	New physical register name from Free List.
logic	[5:0]		cdb_set_rdy_bit_preg_i;		//[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
logic				cdb_set_rdy_bit_en_i;			//[CDB]			Enabling setting ready bit. 
logic	[31:0][5:0] preg_restore_dump_i;	//[??]			Dump check-point copy from somewhere when early branch single cycle recovery.
logic				preg_restore_dump_en_i;		//[ROB]			Enabling dumping.
		
//------------------------------------------------------------------------------
//Outputs
//------------------------------------------------------------------------------

logic	[5:0]		opa_preg_o,					//[RS]			Oprand A physical reg output.
logic	[5:0]		opb_preg_o,					//[RS]			Oprand B physical reg output.
logic				opa_preg_rdy_bit_o,			//[RS]			Oprand A physical reg ready bit output. 
logic				opb_preg_rdy_bit_o,			//[RS]			Oprand B physical reg ready bit output.
logic	[5:0]		dest_old_preg_o				//[ROB]			Old dest physical reg output. 


//------------------------------------------------------------------------------
//Module
//------------------------------------------------------------------------------
map_table mapT(
		.clk,
		.rst,						//|From where|									
		.opa_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.
		.opb_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
		.dest_areg_idx_i,			//[Decoder]		A logic register index to read the old dest physical reg, and to write a new dest physical reg.
		.new_free_preg_i,			//[Free-List]	New physical register name from Free List.
		.dispatch_en_i(dispatch_en),				//[Decoder]		Enabling all inputs above. 
		.cdb_set_rdy_bit_preg_i,		//[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
		.cdb_set_rdy_bit_en_i,			//[CDB]			Enabling setting ready bit. 
		.preg_restore_dump_i,	//[??]			Dump check-point copy from somewhere when early branch single cycle recovery.
		.preg_restore_dump_en_i,		//[ROB]			Enabling dumping.
		
														//|To where|
		.opa_preg_o,					//[RS]			Oprand A physical reg output.
		.opb_preg_o,					//[RS]			Oprand B physical reg output.
		.opa_preg_rdy_bit_o,			//[RS]			Oprand A physical reg ready bit output. 
		.opb_preg_rdy_bit_o,			//[RS]			Oprand B physical reg ready bit output.
		.dest_old_preg_o				//[ROB]			Old dest physical reg output. 
		);


//******************************************************************************
//*FREELIST																	   *
//******************************************************************************

//------------------------------------------------------------------------------
//Inputs
//------------------------------------------------------------------------------
logic			dispatch_en_i;			//[Decoder]		If true, output head entry and head++
logic			rob2fl_retire_en_i;			//[ROB]			If true, write new retired preg to tail, and tail++
logic	[5:0]	rob2fl_retire_preg_i;			//[ROB]			New retired preg.
logic			rob2fl_recover_en_i;			//[ROB]			Enabling early branch single cycle recovery
logic	[4:0]	rob2fl_recover_head_i;			//[ROB]			Recover head to some point



//------------------------------------------------------------------------------
//Outputs
//------------------------------------------------------------------------------
logic			free_preg_vld_o,		//[ROB, Map Table, RS]	Is logic valid?
logic	[5:0]	free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
logic	[4:0]	free_preg_cur_head_o	//[ROB]			Current head pointer.
//------------------------------------------------------------------------------
//module
//------------------------------------------------------------------------------
free_list freelist(
		.clk,
		.rst,					//|From where|
		.dispatch_en_i,			//[Decoder]		If true, output head entry and head++
		.retire_en_i(rob2fl_retire_en_i),			//[ROB]			If true, write new retired preg to tail, and tail++
		.retire_preg_i(rob2fl_retire_preg_i),			//[ROB]			New retired preg.
		.recover_en_i(rob2fl_recover_en_i),			//[ROB]			Enabling early branch single cycle recovery
		.recover_head_i(rob2fl_recover_head_i),			//[ROB]			Recover head to some point
		.		//|To where|
		.free_preg_vld_o,		//[ROB, Map Table, RS]	Is output valid?
		.free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
		.free_preg_cur_head_o	//[ROB]			Current head pointer.

		);


assign rob2fl_retire_en_i	= rob_head_retire_rdy_o;
assign rob2fl_retire_preg_i	= rob2fl_tag_o;
assign rob2fl_recover_en_i	= br_recovery_rdy_o;
assign rob2fl_recover_head_i = 
`endif

/*
decoder decoder_0 (
    	// Input
    	.inst(if_id_IR),
    	.valid_inst_in(if_id_valid_inst),

    	// Outputs
    	.opa_select(decoder_opa_select_out),
    	.opb_select(decoder_opb_select_out),
    	.alu_func(id_alu_func_out),
    	.dest_reg(dest_reg_select),
    	.rd_mem(id_rd_mem_out),
    	.wr_mem(id_wr_mem_out),
    	.cond_branch(id_cond_branch_out),
    	.uncond_branch(id_uncond_branch_out),
    	.halt(id_halt_out),
    	.illegal(id_illegal_out),
    	.valid_inst(decoder_valid_inst_out)
		);
  
*/
assign head_retire_en_i = rob_head_retire_rdy_o;
assign br_recovery_en_i = br_recovery_rdy_o;
integer i,j,m,n;
integer dispatch_count = 0;
	
always
	#5 clk=~clk;

task dispatch;
	input	[5:0]	T, Told;
	input	[4:0]	logic_dest; 
	input	[63:0]	PC;
	input			br_flag, br_pre; 
	input	[63:0]	br_target;
	input			rd_mem, wr_mem;
	
	fu_done_i = 0;
	fl2rob_tag_i = T;
	map2rob_tag_i = Told;
	decode2rob_logic_dest_i = logic_dest;
	decode2rob_PC_i = PC;
	decode2rob_br_flag_i = br_flag;
	decode2rob_br_pretaken_i = br_pre;
	decode2rob_br_target_i = br_target;
	decode2rob_rd_mem_i = rd_mem;
	decode2rob_wr_mem_i = wr_mem;
	dispatch_count++;
	$display("@@Dispatch Instruction #%d", dispatch_count);
	$display("@@ T:%d Told:%d Loic_reg:%d br:%d br_pr:%d ", T, Told, logic_dest
			 ,br_flag,br_pre);
endtask

task fu_done;
	input	[5:0]	preg_idx;
	input			br_taken;
	
	fu_done_i = 1;
	fu2rob_idx_i = preg_idx;
	fu2rob_br_taken_i = br_taken;
	$display("@@ ROB# %d done=1", preg_idx);

endtask 


task print_rob;
	$display("State of ROB");
	for(i=0;i<32;i++)
		if(i==head)	
			$display("@@|h:%2d| T:%d | Told:%d | Log_D:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else if (i==tail)
			$display("@@|t:%2d| T:%d | Told:%d | Log_D:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else
			$display("@@|  %2d| T:%d | Told:%d | Log_D:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
	
endtask


initial begin

	clk = 0;	
	rst=1;
	@(negedge clk);
	rst=1;
	@(negedge clk);
	rst=0;
	for(i=1;i<10;i++) begin
		dispatch_en = 1;
		dispatch(31+i,i,i,i*4,0,0,i*8,0,0);
		@(negedge clk);
		dispatch_en = 0;
	end
	@(negedge clk);
	print_rob;

	fu_done(3,0);
	@(negedge clk);
	fu_done_i = 0;
	print_rob;
	@(negedge clk);
	fu_done(0,0);
	@(negedge clk);
	fu_done_i = 0 ;
	print_rob;
	@(negedge clk);
	for(i=1;i<6;i++) begin
		dispatch_en = 1;
		dispatch(40+i,9+i,i,i*4,0,0,i*8,0,0);
		fu_done(i,0);
		@(negedge clk);
		dispatch_en = 0;
		fu_done_i = 0;
		//print_rob;
	end
	print_rob;
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
