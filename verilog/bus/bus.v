// ****************************************************************************
// Filename: bus.v
// Discription: pipelined coherence bus, Atomic requests, Atomic Transactions
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 11/26/2017
// ****************************************************************************

`timescale 1ns/100ps

module bus (
		input											clk,
		input											rst,

		// core0 signals
		input											core0_req_en_i,
		input			[`DCACHE_TAG_W-1:0]				core0_req_tag_i,
		input			[`DCACHE_IDX_W-1:0]				core0_req_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		core0_req_data_i,
		input	message_t								core0_req_message_i,
		input											core0_rsp_vld_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		core0_rsp_data_i,
		input											core0_rsp_ack_i,
		output	logic									bus2core0_req_ack_o,

		// core1 signals
		input											core1_req_en_i,
		input			[`DCACHE_TAG_W-1:0]				core1_req_tag_i,
		input			[`DCACHE_IDX_W-1:0]				core1_req_idx_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		core1_req_data_i,
		input	message_t								core1_req_message_i,
		input											core1_rsp_vld_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		core1_rsp_data_i,
		input											core1_rsp_ack_i,
		output	logic									bus2core1_req_ack_o,

		// memory controller signals
		input											Dmem_ctrl_rsp_ack_i,
		input											Dmem_ctrl_rsp_vld_i,
		input			[`RSP_Q_PTR_W-1:0]				Dmem_ctrl_rsp_ptr_i,
		input			[`DCACHE_WORD_IN_BITS-1:0]		Dmem_ctrl_rsp_data_i,
		output	logic	[`RSP_Q_PTR_W-1:0]				bus2Dmem_ctrl_rsp_ptr_o,

		// request outputs
		output	logic									bus_req_id_o,
		output	logic	[`DCACHE_TAG_W-1:0]				bus_req_tag_o,
		output	logic	[`DCACHE_IDX_W-1:0]				bus_req_idx_o,
		output	message_t								bus_req_message_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus_req_data_o, // to Dmem_ctrl
		
		// response outputs
		output	logic									bus_rsp_vld_o,
		output	logic									bus_rsp_id_o,
		output	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus_rsp_data_o,
		output	logic	[63:0]							bus_rsp_addr_o // to Dmem_ctrl
	);

	// bus response queue registers
	logic	[`RSP_Q_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_r;
	logic	[`RSP_Q_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_r;
	logic	[`RSP_Q_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_r;
	logic	[`RSP_Q_NUM-1:0]							id_r;
	logic	[`RSP_Q_NUM-1:0]							vld_r;
	logic	[`RSP_Q_NUM-1:0]							rdy_r;

	logic	[`RSP_Q_NUM-1:0][`DCACHE_TAG_W-1:0]			tag_nxt;
	logic	[`RSP_Q_NUM-1:0][`DCACHE_IDX_W-1:0]			idx_nxt;
	logic	[`RSP_Q_NUM-1:0][`DCACHE_WORD_IN_BITS-1:0]	data_nxt;
	logic	[`RSP_Q_NUM-1:0]							id_nxt;
	logic	[`RSP_Q_NUM-1:0]							vld_nxt;
	logic	[`RSP_Q_NUM-1:0]							rdy_nxt;

	// pointers
	logic												rsp_full;
	logic												rsp_stall;

	logic	[`RSP_Q_PTR_W-1:0]							head_r;
	logic												head_msb_r;
	logic	[`RSP_Q_PTR_W-1:0]							tail_r;
	logic												tail_msb_r;

	logic	[`RSP_Q_PTR_W-1:0]							head_nxt;
	logic												head_msb_nxt;
	logic	[`RSP_Q_PTR_W-1:0]							tail_nxt;
	logic												tail_msb_nxt;
	
	// random priority bit to select between core0 and core1
	logic												sel_r;

	logic												bus_req_ack;
	logic												core0_req_gnt;
	logic												core1_req_gnt;

	logic												core0_req_pend_hit;
	logic												core1_req_pend_hit;

	// response data sent to core been accepted
	logic												core_rsp_ack;

	assign core_rsp_ack = core0_rsp_ack_i | core1_rsp_ack_i;

	//-----------------------------------------------------
	// To Dmem_ctrl, response entry ptr
	assign bus2Dmem_ctrl_rsp_ptr_o	= tail_r;

	
	//-----------------------------------------------------
	// request logic, include arbitration and acknowledge
	// request arbitration
	assign bus_req_id_o			= core1_req_gnt ? 1'b1 : 1'b0;
	assign bus_req_tag_o		= core1_req_gnt ? core1_req_tag_i : 
								  core0_req_gnt ? core0_req_tag_i : 0;
	assign bus_req_idx_o		= core1_req_gnt ? core1_req_idx_i : 
								  core0_req_gnt ? core0_req_idx_i : 0;
	assign bus_req_message_o	= core1_req_gnt ? core1_req_message_i : 
								  core0_req_gnt ? core0_req_message_i : NONE;
	assign bus_req_data_o		= core1_req_gnt ? core1_req_data_i : 
								  core0_req_gnt ? core0_req_data_i : 64'h0;

	assign bus_req_ack			= ~rsp_stall && // request acked, release bus for next
								  (core0_rsp_vld_i | core1_rsp_vld_i | Dmem_ctrl_rsp_ack_i);
	assign bus2core0_req_ack_o	= core0_req_gnt & bus_req_ack;
	assign bus2core1_req_ack_o	= core1_req_gnt & bus_req_ack;
	
	// request arbitration
	always_comb begin
		if (~sel_r) begin // core0 has priority
			if (core0_req_en_i && ~core0_req_pend_hit) begin
				core0_req_gnt	= 1'b1;
				core1_req_gnt	= 1'b0;
			end else if (core1_req_en_i && ~core1_req_pend_hit) begin
				core0_req_gnt	= 1'b0;
				core1_req_gnt	= 1'b1;
			end else begin
				core0_req_gnt	= 1'b0;
				core1_req_gnt	= 1'b0;
			end
		end else begin // core1 has priority
			if (core1_req_en_i && ~core1_req_pend_hit) begin
				core0_req_gnt	= 1'b0;
				core1_req_gnt	= 1'b1;
			end else if (core0_req_en_i && ~core0_req_pend_hit) begin
				core0_req_gnt	= 1'b1;
				core1_req_gnt	= 1'b0;
			end else begin
				core0_req_gnt	= 1'b0;
				core1_req_gnt	= 1'b0;
			end
		end
	end

	// check if there exists same block in pending transaction
	always_comb begin
		core0_req_pend_hit	= 1'b0;
		core1_req_pend_hit	= 1'b0;
		for (int i = 0; i < `RSP_Q_NUM; i++) begin
			if (core0_req_tag_i == tag_r[i] && core0_req_idx_i == idx_r[i] && vld_r[i])
				core0_req_pend_hit	= 1'b1;
			if (core1_req_tag_i == tag_r[i] && core1_req_idx_i == idx_r[i] && vld_r[i])
				core1_req_pend_hit	= 1'b1;
		end
	end


	//----------------------------------------------------
	// response logic, including outputs like vld, id, data
	assign bus_rsp_vld_o	= rdy_r[head_r];
	assign bus_rsp_id_o		= id_r[head_r];
	assign bus_rsp_data_o	= data_r[head_r];
	assign bus_rsp_addr_o	= {tag_r[head_r], idx_r[head_r], 3'h0};


	//-----------------------------------------------------
	// response queue, entry allocation when request acked
	// clear entry after response sent
	// full and stall signals
	assign rsp_full		= (head_msb_r != tail_msb_r) && (head_r == tail_r);
	assign rsp_stall	= rsp_full && ~core_rsp_ack;

	// pointers update
	assign head_msb_nxt	= (core_rsp_ack && (head_r == `RSP_Q_NUM-1)) ? ~head_msb_r : head_msb_r;
	assign head_nxt		= (core_rsp_ack && (head_r == `RSP_Q_NUM-1)) ? 0 : 
					  	  (core_rsp_ack) ? head_r + 1 : head_r;
	assign tail_msb_nxt	= ((bus_req_ack && bus_req_message_o == GET_S) &&
						   (tail_r == `RSP_Q_NUM-1)) ? ~tail_msb_r : tail_msb_r;
	assign tail_nxt		= ((bus_req_ack && bus_req_message_o == GET_S) &&
						   (tail_r == `RSP_Q_NUM-1)) ? 0 :
						  (bus_req_ack && bus_req_message_o == GET_S) ? tail_r + 1 : tail_r;

	// allocate and clear entry
	always_comb begin
		tag_nxt		= tag_r;
		idx_nxt		= idx_r;
		data_nxt	= data_r;
		id_nxt		= id_r;
		vld_nxt		= vld_r;
		rdy_nxt		= rdy_r;
		if (core_rsp_ack) begin // clear entry
			tag_nxt	[head_r]	= 0;
			idx_nxt	[head_r]	= 0;
			data_nxt[head_r]	= 64'h0;
			id_nxt	[head_r]	= 1'b0;
			vld_nxt	[head_r]	= 1'b0;
			rdy_nxt	[head_r]	= 1'b0;
		end
		// allocate entry, higher priority if head_r = tail_r
		if (Dmem_ctrl_rsp_vld_i) begin
			data_nxt[Dmem_ctrl_rsp_ptr_i]	= Dmem_ctrl_rsp_data_i;
			rdy_nxt[Dmem_ctrl_rsp_ptr_i]	= 1'b1;
		end
		if (core0_rsp_vld_i) begin // data rdy
			data_nxt[tail_r]	= core0_rsp_data_i;
			rdy_nxt	[tail_r]	= 1'b1;
		end
		if (core1_rsp_vld_i) begin
			data_nxt[tail_r]	= core1_rsp_data_i;
			rdy_nxt[tail_r]		= 1'b1;
		end
		if (bus_req_message_o == GET_S) begin
			if (bus2core0_req_ack_o) begin // request acked
				tag_nxt	[tail_r]	= core0_req_tag_i;
				idx_nxt	[tail_r]	= core0_req_idx_i;
				id_nxt	[tail_r]	= 1'b0; // requestor: core0
				vld_nxt	[tail_r]	= 1'b1;
			end
			if (bus2core1_req_ack_o) begin 
				tag_nxt	[tail_r]	= core1_req_tag_i;
				idx_nxt	[tail_r]	= core1_req_idx_i;
				id_nxt	[tail_r]	= 1'b1; // requestor: core1
				vld_nxt	[tail_r]	= 1'b1;
			end
		end
	end


	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			tag_r		<= `SD `DCACHE_TAG_W'b0;
			idx_r		<= `SD `DCACHE_IDX_W'b0;
			data_r		<= `SD {`RSP_Q_NUM{`DCACHE_WORD_IN_BITS'h0}};
			id_r		<= `SD `RSP_Q_NUM'b0;
			vld_r		<= `SD `RSP_Q_NUM'b0;
			rdy_r		<= `SD `RSP_Q_NUM'b0;
			sel_r		<= `SD 1'b0;
			head_r		<= `SD `RSP_Q_NUM'b0;
			head_msb_r	<= `SD 1'b0;
			tail_r		<= `SD `RSP_Q_NUM'b0;
			tail_msb_r	<= `SD 1'b0;
		end else begin
			tag_r		<= `SD tag_nxt;
			idx_r		<= `SD idx_nxt;
			data_r		<= `SD data_nxt;
			id_r		<= `SD id_nxt;
			vld_r		<= `SD vld_nxt;
			rdy_r		<= `SD rdy_nxt;
			sel_r		<= `SD ~sel_r;
			head_r		<= `SD head_nxt;
			head_msb_r	<= `SD head_msb_nxt;
			tail_r		<= `SD tail_nxt;
			tail_msb_r	<= `SD tail_msb_nxt;
		end
	end


endmodule: bus

