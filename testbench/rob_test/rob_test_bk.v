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

//-----------------------
//Mem Array
//-----------------------
logic [63:0] unified_memory [`MEM_64BIT_LINES - 1:0];
$readmemh("../../program.mem", unified_memory);


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
//------------------------------------------------------------------------------
//ID_STAGE
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//Input
//------------------------------------------------------------------------------

logic	[31:0]			if_id_IR_i;             // incoming instruction
logic       			if_id_valid_inst_i;

logic	[4:0]			id_ra_idx_o;      // reg A value
logic	[4:0]			id_rb_idx_o;      // reg B value
logic	[4:0]			id_dest_idx_o;    // destination (writeback) register index (zero-reg if no writeback)
logic	[`FU_SEL_W-1:0]	id_fu_sel_o;      // functional unit selection
logic	[31:0]			id_IR_o;	  // instruction
logic					id_rd_mem_o;
logic					id_wr_mem_o;
logic					id_cond_branch_o;
logic					id_uncond_branch_o;

   
logic        			id_ldl_mem_o;       // load-lock inst?
logic       			id_stc_mem_o;       // store-conditional inst?								
logic       			id_halt_o;
logic       			id_cpuid_o;         // get CPUID inst?
logic       			id_illegal_o;
logic       			id_valid_inst_o;     // is inst a valid instruction to be

id_stage id_stage0(
             
				 .clk,                // system clock
				 .rst,                // system reset
				 .if_id_IR_i,             // incoming instruction
				 .if_id_valid_inst_i,

				 .id_ra_idx_o,      // reg A value
				 .id_rb_idx_o,      // reg B value
				 .id_dest_idx_o,    // destination (writeback) register index (zero-reg if no writeback)
				 .id_fu_sel_o,      // functional unit selection
				 .id_IR_o,	  // instruction
				 .id_rd_mem_o,
				 .id_wr_mem_o,
				 .id_cond_branch_o,
				 .id_uncond_branch_o,
				 .id_ldl_mem_o,       // load-lock inst?
				 .id_stc_mem_o,       // store-conditional inst?								
				 .id_halt_o,
				 .id_cpuid_o,         // get CPUID inst?
				 .id_illegal_o,
				 .id_valid_inst_o     // is inst a valid instruction to be 
              );  

assign head_retire_en_i = rob_head_retire_rdy_o;
assign br_recovery_en_i = br_recovery_rdy_o;
integer i,j,m,n;
integer dispatch_count = 0;
integer PC_counter;	

always
	#5 clk=~clk;

task fetch;
	input PC;
	output insn;
	insn = PC[2]? unified_memory[PC][63:32] : unified_memory[PC][31:0];
endtask


task dispatch;
	input	[5:0]	T, Told;
	input	[4:0]	logic_dest; 
	input	[63:0]	PC;
	input			br_flag;
	input	[63:0]	br_target;
	input			rd_mem, wr_mem;
	
	if_id_IR = fetch(PC);

	fu_done_i = 0;
	fl2rob_tag_i = T;
	map2rob_tag_i = Told;
	decode2rob_logic_dest_i = id_dest_idx_o;
	decode2rob_PC_i = PC;
	decode2rob_br_flag_i = id_cond_branch_o | id_uncond_branch_o;
	decode2rob_br_pretaken_i = 0;
	decode2rob_br_target_i = 0;
	decode2rob_rd_mem_i = id_rd_mem_o;
	decode2rob_wr_mem_i = id_wr_mem_o;
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
			$display("@@|h:%2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else if (i==tail)
			$display("@@|t:%2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
				 i,T[i], Told[i], logic_dest[i], done[i], br_flag[i], br_pretaken[i], br_taken[i]);
		else
			$display("@@|  %2d| T:%d | Told:%d | A_dest:%d | Done:%d | br?:%d | br_pr:%d | br_taken:%d |",
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
