// ****************************************************************************
// Filename: rob1.v
// Discription: one entry for reorder buffer
// Author: Jun, Shijing
// Version History: add early recovery 
// 	intial creation: 10/17/2017
// ****************************************************************************
// Some logic regarding early branch recovery and LSQ has not been added
//
`define DEBUG_OUT

module	rob (
		input					clk,
		input					rst,

		//----------------------------------------------------------------------
		//Dispatch Signal Input
		//----------------------------------------------------------------------
		input		[`PRF_IDX_W-1:0]		fl2rob_tag_i,//tag sent from freelist
		input		[`PRF_IDX_W-2:0]		fl2rob_cur_head_i,//freelist head
		input		[`PRF_IDX_W-1:0]		map2rob_tag_i,//tag sent from maptable
		input		[`PRF_IDX_W-2:0]		decode2rob_logic_dest_i,//logic dest sent from decode
		input		[63:0]					decode2rob_PC_i,//instruction's PC sent from decode
		input								decode2rob_br_flag_i,//flag show whether the instruction is a branch
		input								decode2rob_br_pretaken_i,//branch predictor result sent from decode
		input								decode2rob_br_target_i,//branch target sent from decode 
		input								decode2rob_rd_mem_i,//flag shows whether this instruction read memory
		input								decode2rob_wr_mem_i,//flag shows whether this instruction write memory
		input								rob_dispatch_en_i,//signal from dispatch to allocate entry in rob
		input		[`BR_MASK_W-1:0]		decode2rob_br_mask_i,

		//----------------------------------------------------------------------
		//Functional Unit Signal Input
		//----------------------------------------------------------------------
		input		[`ROB_IDX_W:0]			fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		input								fu2rob_done_signal_i,//done signal from functional unit 
		input								fu2rob_br_taken_i,//branck taken result sent from functional unit


		output		[`HT_W-1:0]				rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		output		[`PRF_IDX_W-1:0]		rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		output		[`PRF_IDX_W-1:0]		rob2arch_map_tag_o,//tag from ROB to Arch map
		output		[`PRF_IDX_W-2:0]		rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		output								rob_full_o,//signal show if the ROB is full
		output								rob_head_retire_rdy_o,//the head of ROb is ready to retire

		//----------------------------------------------------------------------
		//Early Recovery Signal Ouput
		//----------------------------------------------------------------------
		output								br_recovery_rdy_o,//ready to start early branch recovery
		output		[`PRF_IDX_W-2:0]		rob2fl_recover_head_o,
		output		[`BR_MASK_W-1:0]		rob2rs_recover_br_mask_o
	
		//----------------------------------------------------------------------
		//ROB data output for debug
		//---------------------------------------------------------------------
		
		`ifdef	DEBUG_OUT
		
		,output logic	[`HT_W:0]			head_o,
		output logic	[`HT_W:0]			tail_o,
		output logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag_o, 
		output logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	dest_tag_o,
		output logic	[`ROB_W-1:0]		done_o,
		output logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest_o,
		output logic	[`ROB_W-1:0][63:0]	PC_o,
		output logic	[`ROB_W-1:0]		br_flag_o,
		output logic	[`ROB_W-1:0]		br_taken_o,
		output logic	[`ROB_W-1:0]		br_pretaken_o,
		output logic	[`ROB_W-1:0]		br_target_o,
		output logic	[`ROB_W-1:0][`BR_MASK_W-1:0]	br_mask_o,
		output logic	[`ROB_W-1:0]		wr_mem_o,
		output logic	[`ROB_W-1:0]		rd_mem_o,
		output logic	[4:0]				fl_cur_head_o
		
	   	//,output debug_t debug_o
		`endif


	);

	//--------------------------------------------------------------------------
	//Register storing the data of ROB
	//--------------------------------------------------------------------------
	logic	[`HT_W:0]						head_r;
	logic	[`HT_W:0]						tail_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag_r, dest_tag_r;
	logic	[`ROB_W-1:0]					done_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest_r;
	logic	[`ROB_W-1:0][63:0]				PC_r;
	logic	[`ROB_W-1:0]					br_flag_r;
	logic	[`ROB_W-1:0]					br_taken_r;
	logic	[`ROB_W-1:0]					br_pretaken_r;
	logic	[`ROB_W-1:0]					br_target_r;
	logic	[`ROB_W-1:0]					wr_mem_r;
	logic	[`ROB_W-1:0]					rd_mem_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	fl_cur_head_r;
	logic	[`ROB_W-1:0][`BR_MASK_W-1:0]		br_mask_r;

	//--------------------------------------------------------------------------
	//Register for updating the head and tail
	//--------------------------------------------------------------------------
	
	logic	[`PRF_IDX_W-2:0]				t_fl_cur_head_r_nxt;
	logic	[`PRF_IDX_W-2:0]				h_fl_cur_head_r_nxt;	

	logic						t_br_mask_r_nxt;
	logic						t_br_target_r_nxt;
	logic						t_br_pretaken_r_nxt;
	logic						t_br_flag_r_nxt;

	logic						h_br_mask_r_nxt;
	logic						h_br_flag_r_nxt;
	logic						h_br_taken_r_nxt;
	logic						h_br_pretaken_r;

	logic	[`HT_W:0]			head_r_nxt;
	logic	[`HT_W:0]			tail_r_nxt;
	logic	[`PRF_IDX_W-1:0]				h_old_dest_tag_r_nxt, h_dest_tag_r_nxt;
	logic						h_done_r_nxt;
	logic	[`PRF_IDX_W-2:0]				h_logic_dest_r_nxt;
	logic	[63:0]				h_PC_r_nxt;
	logic						h_rd_mem_r_nxt;
	logic						h_wr_mem_r_nxt;

	logic	[`PRF_IDX_W-1:0]				t_old_dest_tag_r_nxt, t_dest_tag_r_nxt;
	logic	[`PRF_IDX_W-2:0]				t_logic_dest_r_nxt;
	logic	[63:0]				t_PC_r_nxt;
	logic						t_rd_mem_r_nxt;
	logic						t_wr_mem_r_nxt;

	logic						fu_br_taken_r_nxt;
	logic						fu_done_r_nxt;
	logic						dispatch_en;
	logic						dispatch_br;
	assign rob2rs_tail_idx_o			= tail_r[`HT_W-1:0];

	assign dispatch_en					= rob_dispatch_en_i;
	assign dispatch_br					= ~rob_full_o&rob_dispatch_en_i&~br_recovery_rdy_o&decode2rob_br_flag_i;

	assign rob2fl_tag_o					= rob_head_retire_rdy_o ? old_dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_tag_o			= rob_head_retire_rdy_o ? dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_logic_dest_o	= rob_head_retire_rdy_o ? logic_dest_r[head_r[`HT_W-1:0]] : 0;
	assign rob_head_retire_rdy_o 		= (done_r[head_r[`HT_W-1:0]]==1);
	assign rob_full_o					= ((head_r^tail_r)==6'b100000)&&(~rob_head_retire_rdy_o);//(head_r[`HT_W]!=tail_r[`HT_W])&&(head_r[`HT_W-1:0]==tail_r[`HT_W-1:0]);
	assign br_recovery_rdy_o			= ~fu2rob_done_signal_i ? 0 : br_flag_r[fu2rob_idx_i]&&(br_pretaken_r[fu2rob_idx_i]!=fu2rob_br_taken_i);
	assign rob2fl_recover_head_o		= ~br_recovery_rdy_o ? 0 : fl_cur_head_r[fu2rob_idx_i];
	assign rob2rs_recover_br_mask_o		= ~br_recovery_rdy_o ? 0 : br_mask_r[fu2rob_idx_i];



	assign head_r_nxt					= rob_head_retire_rdy_o ? (head_r+1) : head_r;
	assign tail_r_nxt 					= br_recovery_rdy_o ? (fu2rob_idx_i) : 
										  	   dispatch_en ? (tail_r+1) : tail_r;
	assign t_old_dest_tag_r_nxt 		= dispatch_en ? map2rob_tag_i : old_dest_tag_r[tail_r[`HT_W-1:0]];
	assign t_dest_tag_r_nxt 			= dispatch_en ? fl2rob_tag_i : dest_tag_r[tail_r[`HT_W-1:0]];
	assign t_logic_dest_r_nxt 			= dispatch_en ? decode2rob_logic_dest_i : logic_dest_r[tail_r[`HT_W-1:0]];
	assign t_PC_r_nxt					= dispatch_en ? decode2rob_PC_i : PC_r[tail_r[`HT_W-1:0]];
	assign t_br_pretaken_r_nxt			= dispatch_br ? decode2rob_br_pretaken_i : br_pretaken_r[tail_r[`HT_W-1:0]];
	assign t_br_flag_r_nxt				= dispatch_br ? decode2rob_br_flag_i : br_flag_r[tail_r[`HT_W-1:0]];
	assign t_br_target_r_nxt			= dispatch_br ? decode2rob_br_target_i : br_target_r[tail_r[`HT_W-1:0]];
	assign t_br_mask_r_nxt				= dispatch_br ? decode2rob_br_mask_i : br_mask_r[tail_r[`HT_W-1:0]];
	assign t_fl_cur_head_r_nxt			= dispatch_br ? fl2rob_cur_head_i : fl_cur_head_r[tail_r[`HT_W-1:0]]; 
	assign t_rd_mem_r_nxt				= dispatch_en ? decode2rob_rd_mem_i : rd_mem_r[tail_r[`HT_W-1:0]];
	assign t_wr_mem_r_nxt				= dispatch_en ? decode2rob_wr_mem_i : wr_mem_r[tail_r[`HT_W-1:0]];

	assign h_old_dest_tag_r_nxt			= rob_head_retire_rdy_o ? 0 : old_dest_tag_r[head_r[`HT_W-1:0]];
	assign h_dest_tag_r_nxt				= rob_head_retire_rdy_o ? 0 : dest_tag_r[head_r[`HT_W-1:0]];
	assign h_logic_dest_r_nxt			= rob_head_retire_rdy_o ? 0 : logic_dest_r[head_r[`HT_W-1:0]];
	assign h_done_r_nxt					= rob_head_retire_rdy_o ? 0 : done_r[head_r[`HT_W-1:0]];
	assign h_PC_r_nxt					= rob_head_retire_rdy_o ? 0 : PC_r[head_r[`HT_W-1:0]];
	assign h_br_flag_r_nxt				= rob_head_retire_rdy_o ? 0 : br_flag_r[head_r[`HT_W-1:0]];
	assign h_br_taken_r_nxt				= rob_head_retire_rdy_o ? 0 : br_taken_r[head_r[`HT_W-1:0]];
	assign h_br_pretaken_r_nxt			= rob_head_retire_rdy_o ? 0 : br_pretaken_r[head_r[`HT_W-1:0]];
	assign h_br_target_r_nxt			= rob_head_retire_rdy_o ? 0 : br_target_r[head_r[`HT_W-1:0]];
	assign h_br_mask_r_nxt				= rob_head_retire_rdy_o ? 0 : br_mask_r[head_r[`HT_W-1:0]];
	assign h_fl_cur_head_r_nxt			= rob_head_retire_rdy_o ? 0 : fl_cur_head_r[head_r[`HT_W-1:0]];
	assign h_rd_mem_r_nxt				= rob_head_retire_rdy_o ? 0 : rd_mem_r[head_r[`HT_W-1:0]];
	assign h_wr_mem_r_nxt				= rob_head_retire_rdy_o ? 0 : wr_mem_r[head_r[`HT_W-1:0]];

	assign fu_done_r_nxt				= fu2rob_done_signal_i ? 1 : done_r[fu2rob_idx_i] ;
	assign fu_br_taken_r_nxt			= fu2rob_done_signal_i ? fu2rob_br_taken_i : br_taken_r[fu2rob_idx_i];

	`ifdef DEBUG_OUT
	
	always_comb begin
		head_o			= head_r;
		tail_o			= tail_r;
		old_dest_tag_o  = old_dest_tag_r;
		dest_tag_o		= dest_tag_r;
		done_o			= done_r;
		logic_dest_o	= logic_dest_r;
		PC_o			= PC_r;
		br_flag_o		= br_flag_r;
		br_taken_o		= br_taken_r;
		br_pretaken_o	= br_pretaken_r;
		br_target_o		= br_target_r;
		br_mask_o		= br_mask_r;
		wr_mem_o		= wr_mem_r;
		rd_mem_o		= rd_mem_r;
		fl_cur_head_o   = fl_cur_head_r;

	end
	
	`endif

	always_ff @(posedge clk) begin
		if (rst) begin
			head_r			<= `SD 0;
			tail_r			<= `SD 0;
			old_dest_tag_r	<= `SD 0;
			dest_tag_r		<= `SD 0;
			logic_dest_r	<= `SD 0;
			done_r			<= `SD 0;
			PC_r			<= `SD 0;
			br_flag_r		<= `SD 0;
			br_taken_r		<= `SD 0;
			br_pretaken_r	<= `SD 0;
			br_target_r		<= `SD 0;
			br_mask_r		<= `SD 0;
			rd_mem_r		<= `SD 0;
			wr_mem_r		<= `SD 0;
			fl_cur_head_r	<= `SD 0;	
		end else if(rob_full_o|~dispatch_en) begin
			head_r								<= `SD head_r_nxt;
			tail_r								<= `SD tail_r_nxt;
			
			old_dest_tag_r[head_r[`HT_W-1:0]]	<= `SD h_old_dest_tag_r_nxt;
			dest_tag_r[head_r[`HT_W-1:0]]		<= `SD h_dest_tag_r_nxt;
			logic_dest_r[head_r[`HT_W-1:0]]		<= `SD h_logic_dest_r_nxt;
			PC_r[head_r[`HT_W-1:0]]				<= `SD h_PC_r_nxt;
			done_r[head_r[`HT_W-1:0]]			<= `SD h_done_r_nxt;
			fl_cur_head_r[head_r[`HT_W-1:0]]	<= `SD h_fl_cur_head_r_nxt;
			br_flag_r[head_r[`HT_W-1:0]]		<= `SD h_br_flag_r_nxt;
			br_taken_r[head_r[`HT_W-1:0]]		<= `SD h_br_taken_r_nxt;
			br_pretaken_r[head_r[`HT_W-1:0]]	<= `SD h_br_pretaken_r_nxt;
			br_target_r[head_r[`HT_W-1:0]]		<= `SD h_br_target_r_nxt;
			br_mask_r[head_r[`HT_W-1:0]]			<= `SD h_br_mask_r_nxt;
			wr_mem_r[head_r[`HT_W-1:0]]			<= `SD h_wr_mem_r_nxt;
			rd_mem_r[head_r[`HT_W-1:0]]			<= `SD h_rd_mem_r_nxt;	

			if (fu2rob_done_signal_i) begin
				br_taken_r[fu2rob_idx_i]			<= `SD fu_br_taken_r_nxt;
				done_r[fu2rob_idx_i]				<= `SD fu_done_r_nxt;
			end
		end else if(~rob_full_o&dispatch_en) begin
			head_r								<= `SD head_r_nxt;
			tail_r								<= `SD tail_r_nxt;
			
			old_dest_tag_r[head_r[`HT_W-1:0]]	<= `SD h_old_dest_tag_r_nxt;
			dest_tag_r[head_r[`HT_W-1:0]]		<= `SD h_dest_tag_r_nxt;
			logic_dest_r[head_r[`HT_W-1:0]]		<= `SD h_logic_dest_r_nxt;
			PC_r[head_r[`HT_W-1:0]]				<= `SD h_PC_r_nxt;
			done_r[head_r[`HT_W-1:0]]			<= `SD h_done_r_nxt;
			fl_cur_head_r[head_r[`HT_W-1:0]]	<= `SD h_fl_cur_head_r_nxt;
			br_flag_r[head_r[`HT_W-1:0]]		<= `SD h_br_flag_r_nxt;
			br_taken_r[head_r[`HT_W-1:0]]		<= `SD h_br_taken_r_nxt;
			br_pretaken_r[head_r[`HT_W-1:0]]	<= `SD h_br_pretaken_r_nxt;
			br_target_r[head_r[`HT_W-1:0]]		<= `SD h_br_target_r_nxt;
			br_mask_r[head_r[`HT_W-1:0]]		<= `SD h_br_mask_r_nxt;
			wr_mem_r[head_r[`HT_W-1:0]]			<= `SD h_wr_mem_r_nxt;
			rd_mem_r[head_r[`HT_W-1:0]]			<= `SD h_rd_mem_r_nxt;
			

			
			old_dest_tag_r[tail_r[`HT_W-1:0]]	<= `SD t_old_dest_tag_r_nxt;
			dest_tag_r[tail_r[`HT_W-1:0]]		<= `SD t_dest_tag_r_nxt;
			logic_dest_r[tail_r[`HT_W-1:0]]		<= `SD t_logic_dest_r_nxt;
			PC_r[tail_r[`HT_W-1:0]]				<= `SD t_PC_r_nxt;
			br_pretaken_r[tail_r[`HT_W-1:0]]	<= `SD t_br_pretaken_r_nxt;
			br_flag_r[tail_r[`HT_W-1:0]]		<= `SD t_br_flag_r_nxt;
			br_target_r[tail_r[`HT_W-1:0]]		<= `SD t_br_target_r_nxt;
			br_mask_r[tail_r[`HT_W-1:0]]		<= `SD t_br_mask_r_nxt;
			rd_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_rd_mem_r_nxt;
			wr_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_wr_mem_r_nxt;
			fl_cur_head_r[tail_r[`HT_W-1:0]]	<= `SD t_fl_cur_head_r_nxt;
			
			if (fu2rob_done_signal_i) begin
				br_taken_r[fu2rob_idx_i]		<= `SD fu_br_taken_r_nxt;
				done_r[fu2rob_idx_i]			<= `SD fu_done_r_nxt;
			end
			
		end 
	end

	
endmodule
