// ****************************************************************************
// Filename: bus.v
// Discription: pipelined coherence bus, Atomic requests, Atomic Transactions
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/26/2017
// ****************************************************************************

module Dmem_ctrl(
		input										clk,
		input										rst,

		// bus interface
		input			[`DCACHE_TAG_W-1:0]			bus_req_tag_i,
		input			[`DCACHE_IDX_W-1:0]			bus_req_idx_i,
		input	message_t							bus_req_message_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]	bus_req_data_i,
		input			[`RSP_Q_PTR_W-1:0]			bus_rsp_ptr_i,

		output	logic								Dmem_ctrl_rsp_ack_o,
		output	logic								Dmem_ctrl_rsp_vld_o,
		output	logic	[`RSP_Q_PTR_W-1:0]			Dmem_ctrl_rsp_ptr_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]	Dmem_ctrl_rsp_data_o,

		// memory interface
		input			[3:0]						Dmem2proc_response_i,
		input			[63:0]						Dmem2Dcache_data_i,
		input			[3:0]						Dmem2proc_tag_i,

		output	logic	[63:0]						proc2Dmem_addr_o,
		output	logic	[63:0]						proc2Dmem_data_o,
		output	logic	[1:0]						proc2Dmem_command_o
	);

endmodule

