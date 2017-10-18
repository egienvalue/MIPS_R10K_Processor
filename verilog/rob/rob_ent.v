// ****************************************************************************
// Filename: rob1.v
// Discription: one entry for reorder buffer
// Author: Jun, Shijing
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************
//

module	rob1 (
		input			clk,
		input			rst,

		input		[4:0]	rob1_logic_dest_i;//logc register destination of instruction
		input		[4:0]	rob1_dest_tag_i;//destnation tag sent from free list
		input		[4:0]	rob1_old_dest_tag_i;//destination tag sent from maptable
		input				rob1_ex_done_signal_i;//if excution unit finished the work, sent the signal back to rob set the done flag to 1
		input				rob1_dest_tag_vld_i;//signal that whether the free list have requested to write the dest_tag
		input				rob1_old_dest_tag_vld_i;//signal that whether the maptable have requested to write the old_dest_tag
		input				rob1_if_wr_req_i;//if_stage signal that whether it will fill the decoded instrution in rob
		input				rob1_retire_signal_i;//signal to retire this instruction


		output		[4:0]	rob1_dest_tag_o;
		output		[4:0]	rob1_old_dest_tag_o;
		output		[4:0]	rob1_logic_dest_o;
		output				rob1_done_o;
	);

	logic		[4:0]	logic_dest_r;
	logic		[4:0]	dest_tag_r;
	logic		[4:0]	old_dest_tag_r;
	logic				done_r;

	logic		[4:0]	logic_dest_r_nxt;
	logic		[4:0]	dest_tag_r_nxt;
	logic		[4:0]	old_dest_tag_r_nxt;
	logic				done__r_nxt
	
	assign rob1_logic_dest_o	= logic_dest_r;
	assign rob1_dest_tag_o		= dest_tag_r;
	assign rob1_old_dest_tag_o	= old_dest_tag_r;
	assign rob1_done_o			= done_r;

	assign logic_dest_r_nxt		= rob1_if_wr_req_i ? rob1_logic_dest_i : logic_dest_r;
	assign dest_tag_r_nxt		= rob1_dest_tag_vld_i ? rob1_dest_tag_i : dest_tag_r;
	assign old_dest_tag_r_nxt	= rob1_old_dest_tag_vld_i ? rob1_old_dest_tag_i : old_dest_tag_r;
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
