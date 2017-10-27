// ****************************************************************************
// Filename: rob1.v
// Discription: one entry for reorder buffer
// Author: Jun, Shijing
// Version History: add early recovery 
// 	intial creation: 10/17/2017
// 	***************************************************************************
//
module	rob (
		input					clk,
		input					rst,

		input		[5:0]		fl2rob_tag_i,//tag sent from freelist
		input		[5:0]		map2rob_tag_i,//tag sent from maptable
		input		[4:0]		decode2rob_logic_dest_i,//logic dest sent from decode
		input		[63:0]		decode2rob_PC_i,//instruction's PC sent from decode
		input					decode2rob_br_flag_i,//flag show whether the instruction is a branch
		input					decode2rob_br_pretaken_i,//branch predictor result sent from decode
		input					decode2rob_br_target_i,//branch target sent from decode 
		input					decode2rob_rd_mem_i,//flag shows whether this instruction read memory
		input					decode2rob_wr_mem_i,//flag shows whether this instruction write memory
		input					rob_dispatch_en_i,//signal from dispatch to allocate entry in rob

		input		[5:0]		fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		input					fu2rob_done_signal_i,//done signal from functional unit 
		input					fu2rob_br_taken_i,//branck taken result sent from functional unit
		input					head_retire_en_i,//retire the head of rob entry and free the entry 

		input					br_recovery_en_i,

		output		[`HT_W-1:0]	rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		output		[5:0]		rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		output		[5:0]		rob2arch_map_tag_o,//tag from ROB to Arch map
		output		[4:0]		rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		output					rob_full_o,//signal show if the ROB is full
		output					rob_head_retire_rdy_o,//the head of ROb is ready to retire
		output					br_recovery_rdy_o//ready to start early branch recovery


	);

	logic	[`HT_W:0]			head_r;
	logic	[`HT_W:0]			tail_r;
	logic	[`ROB_W-1:0][5:0]	old_dest_tag_r, dest_tag_r;
	logic	[`ROB_W-1:0]		done_r;
	logic	[`ROB_W-1:0][4:0]	logic_dest_r;
	logic	[`ROB_W-1:0][63:0]	PC_r;
	logic	[`ROB_W-1:0]		br_flag_r;
	logic	[`ROB_W-1:0]		br_taken_r;
	logic	[`ROB_W-1:0]		br_pretaken_r;
	logic	[`ROB_W-1:0]		br_target_r;
	logic	[`ROB_W-1:0]		wr_mem_r;
	logic	[`ROB_W-1:0]		rd_mem_r;

	logic						t_br_target_r_nxt;
	logic						t_br_pretaken_r_nxt;
	logic						t_br_flag_r_nxt;
	logic						fu_br_taken_r_nxt;
	logic						h_br_flag_r_nxt;
	logic						h_br_taken_r_nxt;
	logic						h_br_pretaken_r;

	logic	[`HT_W:0]			head_r_nxt;
	logic	[`HT_W:0]			tail_r_nxt;
	logic	[5:0]				h_old_dest_tag_r_nxt, h_dest_tag_r_nxt;
	logic						h_done_r_nxt;
	logic	[4:0]				h_logic_dest_r_nxt;
	logic	[63:0]				h_PC_r_nxt;
	logic						h_rd_mem_r_nxt;
	logic						h_wr_mem_r_nxt;

	logic	[5:0]				t_old_dest_tag_r_nxt, t_dest_tag_r_nxt;
	logic	[4:0]				t_logic_dest_r_nxt;
	logic	[63:0]				t_PC_r_nxt;
	logic						t_rd_mem_r_nxt;
	logic						t_wr_mem_r_nxt;

	logic						fu_done_r_nxt;
	logic						dispatch_en;

	assign rob2rs_tail_idx_o			= tail_r[`HT_W-1:0];

	assign dispatch_en					= ~rob_full_o&rob_dispatch_en_i&~br_recovery_en_i;

	assign rob2fl_tag_o					= head_retire_en_i ? old_dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_tag_o			= head_retire_en_i ? dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_logic_dest_o	= head_retire_en_i ? logic_dest_r[head_r[`HT_W-1:0]] : 0;
	assign rob_head_retire_rdy_o 		= (done_r[head_r[`HT_W-1:0]]==1);
	assign rob_full_o					= (head_r^tail_r)==6'b100000;//(head_r[`HT_W]!=tail_r[`HT_W])&&(head_r[`HT_W-1:0]==tail_r[`HT_W-1:0]);

	assign br_recovery_rdy_o			= ~fu2rob_done_signal_i ? 0 : br_flag_r[fu2rob_idx_i]&&br_pretaken_r[fu2rob_idx_i]!=fu2rob_br_taken_i;
	
	assign head_r_nxt					= head_retire_en_i ? (head_r+1) : head_r;
	assign tail_r_nxt 					= br_recovery_en_i ? (fu2rob_idx_i) : 
										  	   dispatch_en ? (tail_r+1) : tail_r;
	assign t_old_dest_tag_r_nxt 		= dispatch_en ? fl2rob_tag_i : old_dest_tag_r[tail_r[`HT_W-1:0]];
	assign t_dest_tag_r_nxt 			= dispatch_en ? map2rob_tag_i : dest_tag_r[tail_r[`HT_W-1:0]];
	assign t_logic_dest_r_nxt 			= dispatch_en ? decode2rob_logic_dest_i : logic_dest_r[tail_r[`HT_W-1:0]];
	assign t_PC_r_nxt					= dispatch_en ? decode2rob_PC_i : PC_r[tail_r[`HT_W-1:0]];
	assign t_br_pretaken_r_nxt			= dispatch_en ? decode2rob_br_pretaken_i : br_pretaken_r[tail_r[`HT_W-1:0]];
	assign t_br_flag_r_nxt				= dispatch_en ? decode2rob_br_flag_i : br_flag_r[tail_r[`HT_W-1:0]];
	assign t_br_target_r_nxt			= dispatch_en ? decode2rob_br_target_i : br_target_r[tail_r[`HT_W-1:0]];


	assign h_old_dest_tag_r_nxt			= head_retire_en_i ? 0 : old_dest_tag_r[head_r[`HT_W-1:0]];
	assign h_dest_tag_r_nxt				= head_retire_en_i ? 0 : dest_tag_r[head_r[`HT_W-1:0]];
	assign h_logic_dest_r_nxt			= head_retire_en_i ? `ZERO_REG : logic_dest_r[head_r[`HT_W-1:0]];
	assign h_done_r_nxt					= head_retire_en_i ? 0 : done_r[head_r[`HT_W-1:0]];
	assign h_PC_r_nxt					= head_retire_en_i ? 0 : PC_r[head_r[`HT_W-1:0]];
	assign h_br_flag_r_nxt				= head_retire_en_i ? 0 : br_flag_r[head_r[`HT_W-1:0]];
	assign h_br_taken_r_nxt				= head_retire_en_i ? 0 : br_taken_r[head_r[`HT_W-1:0]];
	assign h_br_pretaken_r_nxt			= head_retire_en_i ? 0 : br_pretaken_r[head_r[`HT_W-1:0]];
	assign h_br_target_r_nxt			= head_retire_en_i ? 0 : br_target_r[head_r[`HT_W-1:0]];

	assign fu_done_r_nxt				= fu2rob_done_signal_i;
	assign fu_br_taken_r_nxt			= fu2rob_br_taken_i;

	always_ff @(posedge clk) begin
		if (rst) begin
			head_r			<= `SD 0;
			tail_r			<= `SD 0;
			old_dest_tag_r	<= `SD 0;
			dest_tag_r		<= `SD 0;
			logic_dest_r	<= `SD `ZERO_REG;
			done_r			<= `SD 0;
			PC_r			<= `SD 0;
			br_flag_r		<= `SD 0;
			br_taken_r		<= `SD 0;
			br_pretaken_r	<= `SD 0;
			br_target_r		<= `SD 0;
			rd_mem_r		<= `SD 0;
			wr_mem_r		<= `SD 0;
		end else begin
			head_r								<= `SD head_r_nxt;
			tail_r								<= `SD tail_r_nxt;
			
			old_dest_tag_r[head_r[`HT_W-1:0]]	<= `SD h_old_dest_tag_r_nxt;
			dest_tag_r[head_r[`HT_W-1:0]]		<= `SD h_dest_tag_r_nxt;
			logic_dest_r[head_r[`HT_W-1:0]]		<= `SD h_logic_dest_r_nxt;
			PC_r[head_r[`HT_W-1:0]]				<= `SD h_PC_r_nxt;
			done_r[head_r[`HT_W-1:0]]			<= `SD h_done_r_nxt;


			old_dest_tag_r[tail_r[`HT_W-1:0]]	<= `SD t_old_dest_tag_r_nxt;
			dest_tag_r[tail_r[`HT_W-1:0]]		<= `SD t_dest_tag_r_nxt;
			logic_dest_r[tail_r[`HT_W-1:0]]		<= `SD t_logic_dest_r_nxt;
			PC_r[tail_r[`HT_W-1:0]]				<= `SD t_PC_r_nxt;
			br_pretaken_r[tail_r[`HT_W-1:0]]	<= `SD t_br_pretaken_r_nxt;
			br_flag_r[tail_r[`HT_W-1:0]]		<= `SD t_br_flag_r_nxt;
			br_target_r[tail_r[`HT_W-1:0]]		<= `SD t_br_target_r_nxt;
			rd_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_rd_mem_r_nxt;
			wr_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_wr_mem_r_nxt;
			

			br_taken_r[fu2rob_idx_i]			<= `SD fu_br_taken_r_nxt;
			done_r[fu2rob_idx_i]				<= `SD fu_done_r_nxt;
			
		end 
	end

	
endmodule
