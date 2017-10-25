// ****************************************************************************
// Filename: rob1.v
// Discription: one entry for reorder buffer
// Author: Jun, Shijing
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************
//
/*
module	rob1 (
		input			clk,
		input			rst,

		input		[4:0]	rob1_logic_dest_i;//logc register destination of instruction
		input		[4:0]	rob1_dest_tag_i;//destnation tag sent from free list
		input		[4:0]	rob1_old_dest_tag_i;//destination tag sent from maptable
		input				rob1_ex_done_signal_i;//if excution unit finished the work, sent the signal back to rob set the done flag to 1
		input				rob1_load_i;//if_stage signal to load data to this entry
		input				rob1_retire_signal_i;//signal to retire this entry and free


		output		[4:0]	rob1_dest_tag_o;
		output		[4:0]	rob1_old_dest_tag_o;
		output		[4:0]	rob1_logic_dest_o;
		output				rob1_done_o;
		output				rob1_retire_rdy_o;//signal this entry is ready to retire
	);

	logic		[4:0]	logic_dest_r;
	logic		[4:0]	dest_tag_r;
	logic		[4:0]	old_dest_tag_r;
	logic				done_r;

	logic		[4:0]	logic_dest_r_nxt;
	logic		[4:0]	dest_tag_r_nxt;
	logic		[4:0]	old_dest_tag_r_nxt;
	logic				done__r_nxt
	
	assign rob1_retire_rdy_o	= 

	assign rob1_logic_dest_o	= logic_dest_r;
	assign rob1_dest_tag_o		= dest_tag_r;
	assign rob1_old_dest_tag_o	= old_dest_tag_r;
	assign rob1_done_o			= done_r;

	assign logic_dest_r_nxt		= rob1_load_i ? rob1_logic_dest_i : logic_dest_r;
	assign dest_tag_r_nxt		= rob1_load_i ? rob1_dest_tag_i : dest_tag_r;
	assign old_dest_tag_r_nxt	= rob1_load_i ? rob1_old_dest_tag_i : old_dest_tag_r;
	assign done_r_nxt			= rob1_ex_done_signal_i;

	assign logic_dest_nxt		= 
	always_ff @(posedge clock) begin
		if(rst|rob1_retire_signal_i) begin
			logic_dest_r	<= `SD `ZERO_REG;
			dest_rag_r		<= `SD 0;
			old_dest_tag_r	<= `SD 0;
			done_r			<= `SD 0;
		end else begin
			logic_dest_r	<= `SD logic_dest_r_nxt;
			dest_tag_r		<= `SD dest_tag_r_nxt;
			old_dest_tag_r	<= `SD old_dest_tag_r_nxt;
			done_r			<= `SD done_r_nxt;
		end
	end

endmodule
*/
module	rob (
		input			clk,
		input			rst,
	
		input		[5:0]	rob_fl_tag_i;//tag sent from freelist
		input		[5:0]	rob_maptable_tag_i;//tag sent from maptable
		input		[4:0]	rob_logic_dest_i;//logic dest sent from decode
		input		[5:0]	rob_ex_done_tag_i;//tag sent from excution unit to set the done bit 
		input				rob_ex_done_wr_en_i;//done signal from excution unit 
		input				rob_load_i;//signal from fitch to flip tags;
		input				rob_head_retire_i;//retire the head of rob entry and free the entry 

		output		[5:0]	rob2fl_tag_o;//tag from ROB to freelist for returning the old tag to freelist 
		output				rob2fl_tag_vld_o;//rob entry retire signal to freelist 
		output		[5:0]	rob2arch_map_tag_o;//tag from ROB to Arch map
		output				rob2arch_map_tag_vld_o;//rob entry retire signal to Arch map
		output		[4:0]	rob2arch_map_logic_dest_o;//logic dest from ROB to Arch map
		output				rob_full_o;
		output				rob_head_retire_rdy_o;


	);

	logic	[`HT_W:0]			head_r;
	logic	[`HT_W:0]			tail_r;
	logic	[`ROB_W-1:0][5:0]	old_dest_tag_r, dest_tag_r;
	logic	[`ROB_W-1:0]		done_r;
	logic	[`ROB_W-1:0][4:0]	logic_dest_r;

	logic	[`HT_W:0]			head_r_nxt;
	logic	[`HT_W:0]			tail_r_nxt;
	logic	[`ROB_W-1:0][5:0]	old_dest_tag_r_nxt, dest_tag_r_nxt;
	logic	[`ROB_W-1:0]		done_r_nxt;
	logic	[`ROB_W-1:0][4:0]	logic_dest_r_nxt;

	logic						rob_empty_w;

	assign rob2fl_tag_o					= ~rob_head_retire_i ? 0 : old_dest_tag_r[head_r[`HT_W-1:0]];
	assign rob2fl_tag_vld_o				= rob_head_retire_i;
	assign rob2arch_map_tag_o			= ~rob_head_retire_i ? 0 : dest_tag_r[head_r[`HT_W-1:0]];
	assign rob2arch_map_tag_vld_o		= rob_head_retire_i;
	assign rob2arch_map_logic_dest_o	= ~rob_head_retire_i ? 0 : logic_dest_tag_r[head_r[`HT_W-1:0]];
	assign rob_head_retire_rdy_o 		= (done_r[head_r]==1);
	assign rob_full_o					= (head_r^tail_r == 6'b100000);
	assign rob_empty_w					= (head_r^tail_r == 6'b000000);
	
	assign head_r_nxt								= rob_head_retire_i ? head_r+1 : head_r;
	assign tail_r_nxt 								= (~rob_full_o&rob_load_i) ? (tail_r+1) : tail_r;
	assign old_dest_tag_r_nxt[tail_r[`HT_W-1:0]] 	= (~rob_full_o&rob_load_i) ? rob_fl_tag_in : old_dest_tag_r[tail_r[`HT_W-1:0]];
	assign dest_tag_r_nxt[tail_r[`HT_W-1:0]] 		= (~rob_full_o&rob_load_i) ? rob_maptable_tag_i : dest_tag_r[tail_r[`HT_W-1:0]];
	assign logic_dest_r_nxt[tail_r[`HT_W-1:0]] 		= (~rob_full_o&rob_load_i) ? rob_logic_dest_i : logic_dest_r[tail_r[`HT_W-1:0]];

	assign old_dest_tag_r_nxt[head_r[`HT_W-1:0]]	= rob_head_retire_i ? 0 : old_dest_tag_r[head_r[`HT_W-1:0]];
	assign dest_tag_r_nxt[head_r[`HT_W-1:0]]		= rob_head_retire_i ? 0 : dest_tag_r[head_r[`HT_W-1:0]];
	assign logic_dest_r_nxt[head_r[`HT_W-1:0]]		= rob_head_retire_i ? `ZERO_REG : logic_dest_r[head_r[`HT_W-1:0]];
	assign done_r_nxt[head_r[`HT_W-1:0]]			= rob_head_retire_i ? 0 : done_r[head_r[`HT_W-1:0]];


	always_ff @(posedge clock) begin
		if (reset) begin
			head_r			<= `SD 0;
			tail_r			<= `SD 0;
			old_dest_tag_r	<= `SD 0;
			dest_tag_r		<= `SD 0;
			logic_dest_r	<= `SD `ZERO_REG;
			done_r			<= `SD 0;
		end else begin
			head_r								<= `SD head_r_nxt;
			tail_r								<= `SD tail_r_nxt;
			old_dest_tag_r[tail_r[`HT_W-1:0]]	<= `SD old_dest_tag_r_nxt[tail_r[`HT_W-1:0]];
			dest_tag_r[tail_r[`HT_W-1:0]]		<= `SD dest_tag_r_nxt[tail_r[`HT_W-1:0]];
			logic_dest_r[tail_r[`HT_W-1:0]]		<= `SD logic_dest_r_nxt[tail_r[`HT_W-1:0]];
			
			old_dest_tag_r[head_r[`HT_W-1:0]]	<= `SD old_dest_tag_r_nxt[head_r[`HT_W-1:0]];
			dest_tag_r[head_r[`HT_W-1:0]]		<= `SD dest_tag_r_nxt[head_r[`HT_W-1:0]]
			logic_dest_r[head_r[`HT_W-1:0]]		<= `SD logic_dest_r_nxt[head_r[`HT_W-1:0]];

			if (rob_ex_done_wr_en_i) begin
				for (int i=0;i<`ROB_W;i++) begin
					if (dest_tag_r[i]==rob_ex_done_tag_i) begin
						done_r[i]				<= `SD 1;
						break;
					end
				end
			end

		end 
	end

	
endmodule
