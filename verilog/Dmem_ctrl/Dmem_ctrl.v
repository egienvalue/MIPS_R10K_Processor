// ****************************************************************************
// Filename: Dmem_ctrl.v
// Discription: Data memory controller for cache coherence
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
	
		input										bus_rsp_vld_i,	
		input			[`DCACHE_WORD_IN_BITS-1:0]	bus_rsp_data_i,
		input			[63:0]						bus_rsp_addr_i,
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

	// vld and dty registers for each block
	logic	[`MEM_64BIT_LINES - 1:0]				vld_r;	
	logic	[`MEM_64BIT_LINES - 1:0]				dty_r;	

	logic	[`MEM_64BIT_LINES - 1:0]				vld_nxt;	
	logic	[`MEM_64BIT_LINES - 1:0]				dty_nxt;	

	// mshr issue registers, issue command to Dmem
	logic	[`DMEM_MSHR_NUM-1:0]					mshr_iss_vld_r;
	logic	[`DMEM_MSHR_NUM-1:0]					mshr_iss_rdy_r; // 0 if waiting data
	logic	[`DMEM_MSHR_NUM-1:0][1:0]				mshr_iss_cmd_r;
	logic	[`DMEM_MSHR_NUM-1:0][63:0]				mshr_iss_data_r;
	logic	[`DMEM_MSHR_NUM-1:0][63:0]				mshr_iss_addr_r;
	logic	[`DMEM_MSHR_NUM-1:0][`RSP_Q_PTR_W-1:0]	mshr_iss_ptr_r; // BUS queue ptr

	logic	[`DMEM_MSHR_NUM-1:0]					mshr_iss_vld_nxt;
	logic	[`DMEM_MSHR_NUM-1:0]					mshr_iss_rdy_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][1:0]				mshr_iss_cmd_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][63:0]				mshr_iss_data_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][63:0]				mshr_iss_addr_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][`RSP_Q_PTR_W-1:0]	mshr_iss_ptr_nxt; // BUS queue ptr

	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_iss_head_r;
	logic											mshr_iss_hmsb_r;
	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_iss_tail_r;
	logic											mshr_iss_tmsb_r;

	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_iss_head_nxt;
	logic											mshr_iss_hmsb_nxt;
	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_iss_tail_nxt;
	logic											mshr_iss_tmsb_nxt;

	logic											mshr_iss_wr_en;
	logic											mshr_iss_full;
	logic											mshr_iss_stall;
	//logic											mshr_iss_req_hit; // !!! for load fwd

	// mshr response registers, receive data from Dmem
	logic	[`DMEM_MSHR_NUM-1:0]					mshr_rsp_vld_r;
	logic	[`DMEM_MSHR_NUM-1:0][1:0]				mshr_rsp_tag_r;
	logic	[`DMEM_MSHR_NUM-1:0][`RSP_Q_PTR_W-1:0]	mshr_rsp_ptr_r; // BUS queue ptr
	
	logic	[`DMEM_MSHR_NUM-1:0]					mshr_rsp_vld_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][1:0]				mshr_rsp_tag_nxt;
	logic	[`DMEM_MSHR_NUM-1:0][`RSP_Q_PTR_W-1:0]	mshr_rsp_ptr_nxt; // BUS queue ptr

	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_rsp_head_r;
	logic											mshr_rsp_hmsb_r;
	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_rsp_tail_r;
	logic											mshr_rsp_tmsb_r;

	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_rsp_head_nxt;
	logic											mshr_rsp_hmsb_nxt;
	logic	[`DMEM_MSHR_IDX_W-1:0]					mshr_rsp_tail_nxt;
	logic											mshr_rsp_tmsb_nxt;

	logic											mshr_rsp_wr_en;
	logic											mshr_rsp_full;
	logic											mshr_rsp_stall;

	// Dmem signals
	logic											Dmem_ack;
	logic											Dmem_data_rdy;
	
	// request block state signals
	logic	[63:0]									bus_req_addr;
	logic											bus_req_vld;
	logic											bus_req_dty;


	//-----------------------------------------------------
	// bus requesting block state signals assign
	assign bus_req_addr	= {bus_req_tag_i, bus_req_idx_i, 3'b0};
	assign bus_req_vld	= vld_r[bus_req_addr];
	assign bus_req_dty	= dty_r[bus_req_addr];
	

	//-----------------------------------------------------
	// Dmem controller response ready data outputs logic
	assign Dmem_ctrl_rsp_vld_o	= Dmem_data_rdy;
	assign Dmem_ctrl_rsp_ptr_o	= mshr_rsp_ptr_r[mshr_rsp_head_r];
	assign Dmem_ctrl_rsp_data_o	= Dmem2Dcache_data_i;


	//-----------------------------------------------------
	assign proc2Dmem_addr_o		= mshr_iss_addr_r[mshr_iss_head_r];
	assign proc2Dmem_data_o		= mshr_iss_data_r[mshr_iss_head_r];
	assign proc2Dmem_command_o	= (mshr_iss_vld_r[mshr_iss_head_r] && 
								   mshr_iss_rdy_r[mshr_iss_head_r] &&
								   ~mshr_rsp_stall) ? mshr_iss_cmd_r[mshr_iss_head_r] :
													  `BUS_NONE;


	//-----------------------------------------------------
	// Dmem signals
	assign Dmem_ack		= Dmem2proc_response_i != 0;
	assign Dmem_data_rdy= (Dmem2proc_tag_i == mshr_rsp_tag_r[mshr_rsp_head_r]) &&
						  (Dmem2proc_tag_i != 0);


	//-----------------------------------------------------
	// mshr_iss pointers full logic, and entry allocate
	assign mshr_iss_full		= (mshr_iss_hmsb_r != mshr_iss_tmsb_r) &&
								  (mshr_iss_head_r == mshr_iss_tail_r);
	assign mshr_iss_stall		= mshr_iss_full && ~Dmem_ack;
	assign mshr_iss_hmsb_nxt	= (Dmem_ack && (mshr_iss_head_r == `DMEM_MSHR_NUM-1)) ? 
								   ~mshr_iss_hmsb_r : mshr_iss_hmsb_r;
	assign mshr_iss_head_nxt	= (Dmem_ack && (mshr_iss_head_r == `DMEM_MSHR_NUM-1)) ? 0 : 
								  (Dmem_ack) ? mshr_iss_head_r + 1 : mshr_iss_head_r;
	assign mshr_iss_tmsb_nxt	= (mshr_iss_wr_en && (mshr_iss_tail_r == `DMEM_MSHR_NUM-1)) ? 
								   ~mshr_iss_tmsb_r : mshr_iss_tmsb_r;
	assign mshr_iss_tail_nxt	= (mshr_iss_wr_en && (mshr_iss_tail_r == `DMEM_MSHR_NUM-1)) ? 0 : 
								  (mshr_iss_wr_en) ? mshr_iss_tail_r + 1 : mshr_iss_tail_r;

	// mshr_iss allocate/clear entry

	always_comb begin
		mshr_iss_vld_nxt	= mshr_iss_vld_r;
		mshr_iss_rdy_nxt	= mshr_iss_rdy_r;
		mshr_iss_cmd_nxt	= mshr_iss_cmd_r;
		mshr_iss_data_nxt	= mshr_iss_data_r;
		mshr_iss_addr_nxt	= mshr_iss_addr_r;
		mshr_iss_ptr_nxt	= mshr_iss_ptr_r;
		if (Dmem_ack) begin
			mshr_iss_vld_nxt[mshr_iss_head_r]	= 1'b0;
			mshr_iss_rdy_nxt[mshr_iss_head_r]	= 1'b0;
			mshr_iss_cmd_nxt[mshr_iss_head_r]	= `BUS_NONE;
			mshr_iss_data_nxt[mshr_iss_head_r]	= 64'h0;
			mshr_iss_addr_nxt[mshr_iss_head_r]	= 64'h0;
			mshr_iss_ptr_nxt[mshr_iss_head_r]	= 0;
		end
		if (mshr_iss_wr_en) begin // higher piority
			if (~bus_req_vld) begin
				mshr_iss_vld_nxt[mshr_iss_tail_r]	= 1'b1;
				mshr_iss_rdy_nxt[mshr_iss_tail_r]	= 1'b1;
				mshr_iss_cmd_nxt[mshr_iss_tail_r]	= `BUS_LOAD;
				mshr_iss_data_nxt[mshr_iss_tail_r]	= 64'h0;
				mshr_iss_addr_nxt[mshr_iss_tail_r]	= bus_req_addr;
				mshr_iss_ptr_nxt[mshr_iss_tail_r]	= bus_rsp_ptr_i;
			end else begin
				mshr_iss_vld_nxt[mshr_iss_tail_r]	= 1'b1;
				mshr_iss_rdy_nxt[mshr_iss_tail_r]	= 1'b0; // wait for data
				mshr_iss_cmd_nxt[mshr_iss_tail_r]	= `BUS_STORE;
				mshr_iss_data_nxt[mshr_iss_tail_r]	= bus_req_data_i;
				mshr_iss_addr_nxt[mshr_iss_tail_r]	= bus_req_addr;
				mshr_iss_ptr_nxt[mshr_iss_tail_r]	= bus_rsp_ptr_i;
			end
		end
		if (bus_rsp_vld_i) begin
			for (int i = 0; i < `DMEM_MSHR_NUM; i++) begin
				if (bus_rsp_addr_i == mshr_iss_addr_r[i] && mshr_iss_vld_r[i]) begin
					mshr_iss_rdy_nxt[i]		= 1'b1;
					mshr_iss_data_nxt[i]	= bus_rsp_data_i;
				end
			end
		end
	end

	// mshr_iss_wr_en, and Dmem controller response ack outputs to bus
	always_comb begin
		vld_nxt	= vld_r;
		dty_nxt	= dty_r;
		// State I
		if (~bus_req_vld) begin
			if (bus_req_message_i == GET_S) begin
				Dmem_ctrl_rsp_ack_o	= ~mshr_iss_stall; // I->S, send data
				mshr_iss_wr_en		= ~mshr_iss_stall; // allocate a LD entry
				
				vld_nxt[bus_req_addr]	= ~mshr_iss_stall;
			end else if (bus_req_message_i == GET_M) begin
				Dmem_ctrl_rsp_ack_o = 1'b1; // I->M
				mshr_iss_wr_en		= 1'b0;

				vld_nxt[bus_req_addr]	= 1'b1;
				dty_nxt[bus_req_addr]	= 1'b1;
			end else begin
				Dmem_ctrl_rsp_ack_o = 1'b0;
				mshr_iss_wr_en		= 1'b0;
			end
		// State S
		end else if (bus_req_vld && ~bus_req_dty) begin
			if (bus_req_message_i == GET_M) begin 
				Dmem_ctrl_rsp_ack_o	= 1'b1; // S->M
				mshr_iss_wr_en		= 1'b0;

				dty_nxt[bus_req_addr]	= 1'b1;
			end else begin
				Dmem_ctrl_rsp_ack_o	= 1'b0;
				mshr_iss_wr_en		= 1'b0;
			end
		// State M
		end else if (bus_req_dty) begin
			if (bus_req_message_i == PUT_M) begin
				Dmem_ctrl_rsp_ack_o	= ~mshr_iss_stall; // M->I_D, wait data
				mshr_iss_wr_en		= ~mshr_iss_stall; // allocate a ST entry

				vld_nxt[bus_req_addr]	= mshr_iss_stall;
				dty_nxt[bus_req_addr]	= mshr_iss_stall;
			end else if (bus_req_message_i == GET_S) begin
				Dmem_ctrl_rsp_ack_o	= ~mshr_iss_stall; // M->S_D, wait data
				mshr_iss_wr_en		= ~mshr_iss_stall; // allocate a ST entry

				dty_nxt[bus_req_addr]	= mshr_iss_stall;
			end else begin
				Dmem_ctrl_rsp_ack_o	= 1'b0;
				mshr_iss_wr_en		= 1'b0;
			end
		end else begin
			Dmem_ctrl_rsp_ack_o = 1'b0;
			mshr_iss_wr_en		= 1'b0;
		end
	end

	
	//-----------------------------------------------------
	// mshr_rsp pointers full logic, and entry allocate
	assign mshr_rsp_full		= (mshr_rsp_hmsb_r != mshr_rsp_tmsb_r) &&
								  (mshr_rsp_head_r == mshr_rsp_tail_r);
	assign mshr_rsp_stall		= mshr_rsp_full && ~Dmem_data_rdy;
	assign mshr_rsp_hmsb_nxt	= (Dmem_data_rdy && (mshr_rsp_head_r == `DMEM_MSHR_NUM-1)) ? 
								   ~mshr_rsp_hmsb_r : mshr_rsp_hmsb_r;
	assign mshr_rsp_head_nxt	= (Dmem_data_rdy && (mshr_rsp_head_r == `DMEM_MSHR_NUM-1)) ? 0 : 
								  (Dmem_data_rdy) ? mshr_rsp_head_r + 1 : mshr_rsp_head_r;
	assign mshr_rsp_tmsb_nxt	= (mshr_rsp_wr_en && (mshr_rsp_tail_r == `DMEM_MSHR_NUM-1)) ? 
								   ~mshr_rsp_tmsb_r : mshr_rsp_tmsb_r;
	assign mshr_rsp_tail_nxt	= (mshr_rsp_wr_en && (mshr_rsp_tail_r == `DMEM_MSHR_NUM-1)) ? 0 : 
								  (mshr_rsp_wr_en) ? mshr_rsp_tail_r + 1 : mshr_rsp_tail_r;
	assign mshr_rsp_wr_en		= Dmem_ack && proc2Dmem_command_o == `BUS_LOAD;

	// mshr_rsp entry allocate
	always_comb begin
		mshr_rsp_vld_nxt	= mshr_rsp_vld_r; 
        mshr_rsp_tag_nxt	= mshr_rsp_tag_r; 
	    mshr_rsp_ptr_nxt	= mshr_rsp_ptr_r; 
		if (Dmem_data_rdy) begin
			mshr_rsp_vld_nxt[mshr_rsp_head_r]	= 1'b0;
            mshr_rsp_tag_nxt[mshr_rsp_head_r]	= 4'd0;
            mshr_rsp_ptr_nxt[mshr_rsp_head_r]	= `RSP_Q_PTR_W'd0;
		end
		if (mshr_rsp_wr_en) begin
			mshr_rsp_vld_nxt[mshr_rsp_tail_r]	= 1'b1;
            mshr_rsp_tag_nxt[mshr_rsp_tail_r]	= Dmem2proc_response_i;
            mshr_rsp_ptr_nxt[mshr_rsp_tail_r]	= mshr_iss_ptr_r[mshr_rsp_head_r];
		end

	end


	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin 
		if (rst) begin
			vld_r			<= `SD 0;
			dty_r			<= `SD 0;
			mshr_iss_vld_r	<= `SD `DMEM_MSHR_NUM'b0;
			mshr_iss_rdy_r	<= `SD `DMEM_MSHR_NUM'b0;
			mshr_iss_cmd_r	<= `SD {`DMEM_MSHR_NUM{`BUS_NONE}};
			mshr_iss_data_r	<= `SD {`DMEM_MSHR_NUM{64'b0}};
			mshr_iss_addr_r	<= `SD {`DMEM_MSHR_NUM{64'b0}};
			mshr_iss_ptr_r	<= `SD {`DMEM_MSHR_NUM{`RSP_Q_PTR_W'd0}};
			mshr_rsp_vld_r	<= `SD `DMEM_MSHR_NUM'b0;
			mshr_rsp_tag_r	<= `SD {`DMEM_MSHR_NUM{4'd0}};
			mshr_rsp_ptr_r	<= `SD {`DMEM_MSHR_NUM{`RSP_Q_PTR_W'd0}};
			mshr_iss_head_r	<= `SD 0;
			mshr_iss_hmsb_r	<= `SD 0;
			mshr_iss_tail_r	<= `SD 0;
			mshr_iss_tmsb_r	<= `SD 0;
			mshr_rsp_head_r	<= `SD 0;
			mshr_rsp_hmsb_r	<= `SD 0;
			mshr_rsp_tail_r	<= `SD 0;
			mshr_rsp_tmsb_r	<= `SD 0;
		end else begin
			vld_r			<= `SD vld_nxt;
			dty_r			<= `SD dty_nxt;
			mshr_iss_vld_r	<= `SD mshr_iss_vld_nxt;
			mshr_iss_rdy_r	<= `SD mshr_iss_rdy_nxt;
			mshr_iss_cmd_r	<= `SD mshr_iss_cmd_nxt;
			mshr_iss_data_r	<= `SD mshr_iss_data_nxt;
			mshr_iss_addr_r	<= `SD mshr_iss_addr_nxt;
			mshr_iss_ptr_r	<= `SD mshr_iss_ptr_nxt;
			mshr_rsp_vld_r	<= `SD mshr_rsp_vld_nxt;
			mshr_rsp_tag_r	<= `SD mshr_rsp_tag_nxt;
			mshr_rsp_ptr_r	<= `SD mshr_rsp_ptr_nxt;
			mshr_iss_head_r	<= `SD mshr_iss_head_nxt;
			mshr_iss_hmsb_r	<= `SD mshr_iss_hmsb_nxt;
			mshr_iss_tail_r	<= `SD mshr_iss_tail_nxt;
			mshr_iss_tmsb_r	<= `SD mshr_iss_tmsb_nxt;
			mshr_rsp_head_r	<= `SD mshr_rsp_head_nxt;
			mshr_rsp_hmsb_r	<= `SD mshr_rsp_hmsb_nxt;
			mshr_rsp_tail_r	<= `SD mshr_rsp_tail_nxt;
			mshr_rsp_tmsb_r	<= `SD mshr_rsp_tmsb_nxt;
		end
	end


endmodule

