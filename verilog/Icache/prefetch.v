// ****************************************************************************
// Filename: prefetch.v
// Description: prefetching for I-cache during every miss and hit
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/18/2017
// 	<10/25> move prefetch logic to seperate module here
// 	<11/10> added forward allocate during pfetch_head_data_rdy (vld_r, PC_r, head_r,
// 	tail_r)
// ****************************************************************************

module prefetch (
		input											clk,
		input											rst,
		
		input			[3:0]							Imem2proc_tag_i,
		input			[3:0]							Imem2proc_response_i,

		input											cachemem_hit_i, // fetch hit on cache
		input											Icache2pfetch_hit_i, // pfetch hit on cache

		input											if2Icache_req_i,
		input											if2pfetch_flush_i,

		input			[63:0]							Ictrl2pfetch_addr_i,
		input											Ictrl2pfetch_en_i,

		output logic									pfetch2Ictrl_hit_o, // fetch hit on pfetch
		
		output logic									pfetch2Icache_prefetching_o,
		output logic									pfetch2Icache_wr_en_o,
		output logic	[`ICACHE_TAG_W-1:0]				pfetch2Icache_wr_tag_o,
		output logic	[`ICACHE_IDX_W-1:0]				pfetch2Icache_wr_idx_o,
		output logic	[`ICACHE_TAG_W-1:0]				pfetch2Icache_rd_tag_o,
		output logic	[`ICACHE_IDX_W-1:0]				pfetch2Icache_rd_idx_o,
		//output logic	[`ICACHE_LINE_IN_BITS-1:0]		pfetch2Icache_data_o,

		output logic	[63:0]							pfetch2Imem_addr_o,
		output logic	[1:0]							pfetch2Imem_command_o
	);

	// Imem signals
	wire											Imem_ack_w;
	logic											Imem_data_rdy;
	logic		[$clog2(`PFETCH_NUM)-1:0]			Imem_rdy_ptr;

	//-------------------------------------------------------//
	// prefetch status registers, 4-entry
	//-------------------------------------------------------//
	logic		[`PFETCH_NUM-1:0][`MEM_TAG_W-1:0]	mem_tag_r;
	logic		[`PFETCH_NUM-1:0][63:0]				PC_r;
	logic		[`PFETCH_NUM-1:0]					vld_r;
	logic		[`PFETCH_NUM-1:0]					sent_r;
	logic		[$clog2(`PFETCH_NUM)-1:0]			head_r;
	logic		[$clog2(`PFETCH_NUM)-1:0]			tail_r;
	logic											head_msb_r;
	logic											tail_msb_r;

	logic		[`PFETCH_NUM-1:0][`MEM_TAG_W-1:0]	mem_tag_r_nxt;
	logic		[`PFETCH_NUM-1:0][63:0]				PC_r_nxt;
	logic		[`PFETCH_NUM-1:0]					vld_r_nxt;
	logic		[`PFETCH_NUM-1:0]					sent_r_nxt;
	logic		[$clog2(`PFETCH_NUM)-1:0]			head_r_nxt;
	logic		[$clog2(`PFETCH_NUM)-1:0]			tail_r_nxt;
	logic											head_msb_r_nxt;
	logic											tail_msb_r_nxt;

	wire											pfetch_full;
	wire											pfetch_empty;
	wire											pfetch_head_data_rdy;
	
	// signals
	logic		[63:0]								pfetch2Icache_wr_addr; 
	logic		[63:0]								PC_selected;
	logic											pfetching; // requesting

	// signals for priority selection
	logic		[`PFETCH_NUM-1:0]					pfetch_req;
	logic		[`PFETCH_NUM-1:0]					pfetch_gnt;
	logic		[`PFETCH_NUM-1:0]					pfetch_smiss_gnt;
	logic		[`PFETCH_NUM-1:0]					pfetch_smiss_gnt_r;
	logic		[`PFETCH_NUM-1:0]					pfetch_selected_gnt;


	rps4 rps4_send (
		.en_i (1'b1),
		.req_i(pfetch_req),
		.ptr_i(head_r),
		.gnt_o(pfetch_gnt)
	);


	// Imem signals
	assign Imem_ack_w		= (Imem2proc_response_i != 0);

	always_comb begin
		Imem_data_rdy	= 1'b0;
		Imem_rdy_ptr	= 0;
		pfetch2Icache_wr_addr = 64'h0;
		for (int i = 0; i < `PFETCH_NUM; i++) begin
			if (Imem2proc_tag_i != 0) begin
				if (mem_tag_r[i] == Imem2proc_tag_i && vld_r[i]) begin
					Imem_data_rdy 	= 1'b1;
					Imem_rdy_ptr	= i;
					pfetch2Icache_wr_addr = PC_r[i];
				end
			end
		end
	end


	//---------------------------------------------------------------
	// Output signals
	//---------------------------------------------------------------
	assign pfetch2Icache_wr_en_o = Imem_data_rdy;
	assign {pfetch2Icache_wr_tag_o,pfetch2Icache_wr_idx_o} = 
								pfetch2Icache_wr_addr[63:`ICACHE_BLK_OFFSET_W]; 
	assign {pfetch2Icache_rd_tag_o,pfetch2Icache_rd_idx_o} = 
								PC_selected[63:`ICACHE_BLK_OFFSET_W];
	assign pfetch2Icache_prefetching_o = pfetching;
	// outputs assignments to Imem
	assign pfetch2Imem_addr_o	= PC_selected;
	// sending command and checking pfetch hit in parallell. If check
	// first and then send command in next cycle, command should be 
	// FF out, which will delay on cycle.
	assign pfetch2Imem_command_o= pfetching ? `BUS_LOAD : `BUS_NONE;
	assign pfetching	= (|pfetch_selected_gnt) &&
						  Ictrl2pfetch_en_i && ~if2pfetch_flush_i;
	
	
	//--------------------------------------------------------------------//
	// Use priority selector, select one of valid outstanding prefetch PC //
	//--------------------------------------------------------------------//
	assign pfetch_req		= vld_r & ~sent_r;
	// cache access miss hit on prefetch PC (soft miss), has highest priority
	always_comb begin
		pfetch2Ictrl_hit_o = 1'b0;
		for (int i = 0; i < `PFETCH_NUM; i++) begin
			if (Ictrl2pfetch_addr_i == PC_r[i] && vld_r[i])
				pfetch2Ictrl_hit_o = 1'b1;
		end
	end

	// if no soft hit, chose the oldest unsent prefetch according to head_r
	always_comb begin
		pfetch_smiss_gnt = `PFETCH_NUM'b0;
		if (~cachemem_hit_i && pfetch2Ictrl_hit_o) begin
			for (int i = 0; i < `PFETCH_NUM; i++) begin
				if (PC_r[i] == Ictrl2pfetch_addr_i && vld_r[i] && ~sent_r[i])
					pfetch_smiss_gnt[i] = 1'b1;
			end
		end
	end

	// gnt selection
	always_comb begin
		if (|pfetch_smiss_gnt_r)
			pfetch_selected_gnt = pfetch_smiss_gnt_r;
		else
			pfetch_selected_gnt = pfetch_gnt;
	end

	// select PC
	always_comb begin
		PC_selected = 64'h1; // initiate to a invalid address
		if (|pfetch_selected_gnt) begin
			for (int i = 0; i < `PFETCH_NUM; i++) begin
				if (pfetch_selected_gnt[i] == 1)
					PC_selected = PC_r[i];
			end
		end
	end


	//--------------------------------------------------------------------//
	// prefetch status register updating 								  //
	//--------------------------------------------------------------------//
	// Entry full and empty
	assign pfetch_full			= (head_msb_r != tail_msb_r) && (head_r == tail_r);
	assign pfetch_empty			= ({head_msb_r,head_r} == {tail_msb_r,tail_r});
	assign pfetch_head_data_rdy = (Imem2proc_tag_i != 0) && 
								  (mem_tag_r[head_r] == Imem2proc_tag_i) && vld_r[head_r];

	// prefetch PC
	always_comb begin
		PC_r_nxt = PC_r;
		if (~Ictrl2pfetch_en_i | if2pfetch_flush_i) begin
			for (int i = 0; i < `PFETCH_NUM; i++) begin
				PC_r_nxt[i] = Ictrl2pfetch_addr_i + 8 + i*8;
			end
		end else if (if2Icache_req_i)/*if (cachemem_hit_i)*/ begin
			if (pfetch_empty) begin
				PC_r_nxt[tail_r] = Ictrl2pfetch_addr_i + 8;
			end else if (~pfetch_full | pfetch_head_data_rdy) begin
				if (tail_r == 0)
					PC_r_nxt[tail_r] = PC_r[`PFETCH_NUM-1] + 8;
				else
					PC_r_nxt[tail_r] = PC_r[tail_r-1] + 8;
			end
		end
	end

	// prefetch entries' valid bits
	always_comb begin
		vld_r_nxt = vld_r;
		if (~Ictrl2pfetch_en_i | if2pfetch_flush_i) begin
			for (int i = 0; i < `PFETCH_NUM; i++) begin
				vld_r_nxt[i] = 1'b1;
			end
		end else begin
			if (Icache2pfetch_hit_i) begin
				for (int i = 0; i < `PFETCH_NUM; i++) begin
					if (pfetch_selected_gnt[i] == 1)
						vld_r_nxt[i] = 1'b0;
				end
			end
			if (Imem2proc_tag_i != 0) begin
				for (int i = 0; i < `PFETCH_NUM; i++) begin
					if (mem_tag_r[i] == Imem2proc_tag_i && vld_r[i])
						vld_r_nxt[i] = 1'b0; // data back, clear entry 
				end
			end
			if (/*cachemem_hit_i &&*/if2Icache_req_i && (~pfetch_full | pfetch_head_data_rdy)) begin
				vld_r_nxt[tail_r] = 1'b1;
			end
		end
	end

	// prefetch entries' mem_tag_r and sent_r bits
	always_comb begin
		mem_tag_r_nxt	= mem_tag_r;
		sent_r_nxt		= sent_r;
		if (~Ictrl2pfetch_en_i | if2pfetch_flush_i) begin
			mem_tag_r_nxt	= {`PFETCH_NUM{`MEM_TAG_W'b0}};
			sent_r_nxt		= `PFETCH_NUM'b0;
		end else begin
			if (Icache2pfetch_hit_i) begin
				for (int i = 0; i < `PFETCH_NUM; i++) begin
					if (pfetch_selected_gnt[i] == 1) begin
						mem_tag_r_nxt[i]	= `MEM_TAG_W'b0;
						sent_r_nxt[i]		= 1'b0;
					end
				end
			end
			else if (Imem_ack_w) begin
				for (int i = 0; i < `PFETCH_NUM; i++) begin
					if (pfetch_selected_gnt[i] == 1) begin
						mem_tag_r_nxt[i]	= Imem2proc_response_i;
						sent_r_nxt[i]		= 1'b1;
					end
				end
			end
			if (Imem_data_rdy) begin
				mem_tag_r_nxt[Imem_rdy_ptr] = `MEM_TAG_W'b0;
				sent_r_nxt	 [Imem_rdy_ptr] = 1'b0;
			end
		end 
	end

	// head_r, tail_r, head_msb_r and tail_msb_r
	always_comb begin
		head_r_nxt	= head_r;
		tail_r_nxt	= tail_r;
		head_msb_r_nxt= head_msb_r;
		tail_msb_r_nxt= tail_msb_r;
		if (~Ictrl2pfetch_en_i | if2pfetch_flush_i) begin
			head_r_nxt	= 0;
			tail_r_nxt	= 0;
			head_msb_r_nxt= 0;
			tail_msb_r_nxt= 1; // full
		end else begin
			if ((~pfetch_empty && ~vld_r[head_r]) | pfetch_head_data_rdy) begin // free head move
				head_r_nxt		= (head_r == `PFETCH_NUM-1) ? 0 : head_r + 1;
				head_msb_r_nxt	= (head_r == `PFETCH_NUM-1) ? ~head_msb_r : head_msb_r;
			end
			if (/*cachemem_hit_i &&*/if2Icache_req_i && (~pfetch_full | pfetch_head_data_rdy)) begin // allocate, tail move
				tail_r_nxt		= (tail_r == `PFETCH_NUM-1) ? 0 : tail_r + 1;
				tail_msb_r_nxt	= (tail_r == `PFETCH_NUM-1) ? ~tail_msb_r : tail_msb_r;
			end
		end
	end
	

	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			mem_tag_r			<= `SD {`PFETCH_NUM{`MEM_TAG_W'b0}};
			PC_r				<= `SD {`PFETCH_NUM{64'h0}};
			vld_r				<= `SD 4'b0;
			sent_r				<= `SD 4'b0;
			head_r				<= `SD 0;
			tail_r				<= `SD 0;
			head_msb_r			<= `SD 0;
			tail_msb_r			<= `SD 0;
			pfetch_smiss_gnt_r	<= `SD `PFETCH_NUM'b0;
		end else begin
			mem_tag_r			<= `SD mem_tag_r_nxt;
			PC_r				<= `SD PC_r_nxt;
			vld_r				<= `SD vld_r_nxt;
			sent_r				<= `SD sent_r_nxt;
			head_r				<= `SD head_r_nxt;
			tail_r				<= `SD tail_r_nxt;
			head_msb_r			<= `SD head_msb_r_nxt;
			tail_msb_r			<= `SD tail_msb_r_nxt;
			pfetch_smiss_gnt_r	<= `SD pfetch_smiss_gnt;
		end
	end

endmodule: prefetch

