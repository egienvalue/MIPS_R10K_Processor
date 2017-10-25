// ****************************************************************************
// Filename: Icache_ctrl.v
// Description: Controller for I-cache 
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/18/2017
// ****************************************************************************

module Icache_ctrl (
		input										clk,
		input										rst,
		
		input		[3:0]							Imem2proc_tag_i,
		input		[3:0]							Imem2proc_response_i,

		input		[`ICACHE_DATA_IN_BITS:0]		cachemem_data_i,
		input										cachemem_hit_i,
		input										cachemem_pf_hit_i,

		input		[63:0]							if2Icache_addr_i,
		input										if2Icache_rd_req_i,

		output										Icache2if_vld_o,
		output		[`ICACHE_DATA_IN_BITS:0]		Icache2if_data_o,

		output										Ictrl2Icache_wr_en_o,
		output		[`ICACHE_IDX_W-1:0]				Ictrl2Icache_wr_idx_o,
		output		[`ICACHE_TAG_W-1:0]				Ictrl2Icache_wr_tag_o,
		output		[`ICACHE_IDX_W-1:0]				Ictrl2Icache_rd_idx_o,
		output		[`ICACHE_TAG_W-1:0]				Ictrl2Icache_rd_tag_o,
		
		output										Ictrl2Icache_pf_wr_en_o,
		output		[`ICACHE_IDX_W-1:0]				Ictrl2Icache_pf_idx_o,
		output		[`ICACHE_TAG_W-1:0]				Ictrl2Icache_pf_tag_o,

		output		[63:0]							proc2Imem_addr_o,
		output		[1:0]							proc2Imem_command_o
	);

/*	// state definition
	typedef enum logic [2:0] {
		IDLE		= 3'h0,
		FETCH_WR	= 3'h1,
		PFETCH_WR	= 3'h2
		//MISS	= 3'h3,
		//HIT		= 3'h4,
		//S_MISS	= 3'h5
	} state_t;

	state_t		state, state_nxt;
*/
	// mem 
	wire									Imem_ack_w;

	//-----------------------------------------------------
	// IF signals
	//-----------------------------------------------------
	logic		[`ICACHE_TAG_W-1:0]			if2Icache_tag;
	logic		[`ICACHE_IDX_W-1:0]			if2Icache_idx;
	logic		[`ICACHE_BLK_OFFSET_W-1:0]	if2Icache_off;

	//-----------------------------------------------------
	// I-cache signals
	//-----------------------------------------------------
	logic									cache_hit_pf; // cache access addr
														  // hit on pending pf
	logic		[`MEM_TAG_W-1]				cache_hit_pf_tag;
	logic		[63:0]						cache_hit_pf_PC;
	logic									cache_hit_pf_sent;
	logic									cache_hit_pf_vld;
	
	//-----------------------------------------------------
	// fetch signals
	//-----------------------------------------------------
	logic		[`MEM_TAG_W-1:0]			ft_tag_r;
	logic		[63:0]						ft_PC_r;
	logic									ft_sent_r; // update by response
	logic									ft_vld_r;
	
	logic		[`MEM_TAG_W-1:0]			ft_tag_r_nxt;
	logic		[63:0]						ft_PC_r_nxt;
	logic									ft_sent_r_nxt; // update by response
	logic									ft_vld_r_nxt;

	logic									ft_send_en;
	logic									ft_data_rdy;

	wire		[`ICACHE_BLK_OFFSET_W-1:0]	ft_PC_off;

	//-----------------------------------------------------
	// Prefetch
	//-----------------------------------------------------
	logic		[3:0][`MEM_TAG_W-1:0]		pf_tag_r;
	logic		[3:0][63:0]					pf_PC_r;
	logic		[3:0]						pf_sent_r;
	logic		[3:0]						pf_vld_r;
	logic		[1:0]						pf_head_r; // oldest, MSB represent the round
	logic		[1:0]						pf_tail_r;
	logic									pf_hmsb_r;
	logic									pf_tmsb_r;
	wire									pf_full;
	wire		[`ICACHE_BLK_OFFSET_W-1:0]	pf_PC_off;

	logic		[3:0][`MEM_TAG_W-1:0]		pf_tag_r_nxt;
	logic		[3:0][63:0]					pf_PC_r_nxt;
	logic		[3:0]						pf_sent_r_nxt;
	logic		[3:0]						pf_vld_r_nxt;
	logic		[1:0]						pf_head_r_nxt; 
	logic		[1:0]						pf_tail_r_nxt;
	logic									pf_hmsb_r_nxt;
	logic									pf_tmsb_r_nxt;

	logic									pf_head_done;
	logic									pf_outstanding;
	logic									pf_hit; // prefetch addr hit on cache
	// arbiter signals
	logic		[3:0]						pf_response_mask;
	logic									pf_send_en;
	logic		[3:0]						pf_send_req;
	logic		[3:0]						pf_send_ptr;
	logic		[3:0]						pf_send_gnt;
	//logic									pf_gtag_en;
	//logic		[3:0]						pf_gtag_req;
	//logic		[3:0]						pf_gtag_ptr;
	logic		[3:0]						pf_gtag_gnt_r;
	
//	rps4 rps4_gtag (
//		.en_i (pf_gtag_en),
//		.req_i(pf_gtag_req),
//		.ptr_i(pf_gtag_ptr),
//		.gnt_o(pf_gtag_gnt)
//	);
	
	rps4 rps4_send (
		.en_i (pf_send_en),
		.req_i(pf_send_req),
		.ptr_i(pf_send_ptr),
		.gnt_o(pf_send_gnt)
	);

	// arbiter
	//assign pf_response_mask = (Imem2proc_response_i != 0) ? ~pf_gtag_gnt : 4'b1;
	//assign pf_gtag_en	= 1'b0; // always waiting
	//assign pf_gtag_req 	= pf_vld_r & ~pf_sent_r;
	//assign pf_gtag_ptr	= pf_head_r;
	assign pf_send_en	= ~ft_send_en; // no pending fetching
	assign pf_send_req 	= pf_vld_r & ~pf_sent_r & pf_response_mask;
	assign pf_send_ptr	= pf_head_r;

	// outputs for IF stage
	assign Icache2if_vld_o 	= cachemem_hit_i;
	assign Icache2if_data_o = cachemem_data_i;

	// outputs for cache read and fetch write
	assign {if2Icache_tag,if2Icache_idx,if2Icache_off} = if2Icache_addr_i;
	assign Ictrl2Icache_rd_idx_o = if2Icache_idx;
	assign Ictrl2Icache_rd_tag_o = if2Icache_tag;
	assign {Ictrl2Icache_wr_tag_o,Ictrl2Icache_wr_idx_o,ft_PC_off} = ft_PC_r;
	assign Ictrl2Icache_wr_en_o = ft_data_rdy;

	// outputs for prefetch, write I-cache
	assign {Ictrl2Icache_pf_tag_o,Ictrl2Icache_pf_idx_o,pf_PC_off} = pf_PC_r[pf_head_r];
	assign Ictrl2Icache_pf_wr_en_o = pf_head_done;

	// Imem
	assign Imem_ack_w = (Imem2proc_response_i != 0);

	// I-cache signals assignments
	assign Icache2if_vld_o = cachemem_hit_i;

	// Fetch signals assignments
	assign ft_send_en = ft_vld_r && ~ft_sent_r && ~Imem_ack_w;
	assign ft_data_rdy= (ft_tag_r == Imem2proc_tag_i);
		
	always_comb begin
		cache_hit_pf = 1'b0;
		//cache_hit_pf_tag = `MEM_TAG_W'b0;
		//cache_hit_pf_PC	 = 64'b0;
		//cache_hit_pf_sent= 1'b0;
		//cache_hit_pf_vld = 1'b0;
		for (int i = 0; i < 4; i++) begin
			if (pf_vld_r[i] && (pf_PC_r[i] == if2Icache_addr_i)) begin
				cache_hit_pf = 1'b1;
				//cache_hit_pf_tag = pf_tag_r[i];
				//cache_hit_pf_PC	 = pf_PC_r[i];
				//cache_hit_pf_sent= pf_sent_r[i];
				//cache_hit_pf_vld = pf_vld_r[i];
			end
		end
	end

	///////////////////////////////////////////////////
	// fetch signals
	///////////////////////////////////////////////////
	always_comb begin
		//ft_tag_r_nxt	= ft_tag_r;
		//ft_PC_r_nxt		= ft_PC_r;
		//ft_sent_r_nxt	= ft_sent_r;
		//ft_vld_r_nxt	= ft_vld_r;
		if (if2Icache_rq_req_i) begin
			if (cachemem_hit_i) begin
				ft_tag_r_nxt	= `MEM_TAG_W'b0;
				ft_PC_r_nxt		= 64'h0;
				ft_sent_r_nxt	= 1'b0;
				ft_vld_r_nxt	= 1'b0;
			end else if (cache_hit_pf) begin // hit on prefetch
				ft_tag_r_nxt 	= `MEM_TAG_W'b0;
				ft_PC_r_nxt	 	= 64'h0;
				ft_sent_r_nxt	= 1'b0;
				ft_vld_r_nxt 	= 1'b0;
			end else begin // hard miss
				if (!ft_vld_r) begin
					ft_tag_r_nxt 	= `MEM_TAG_W'b0;
					ft_PC_r_nxt	 	= if2Icache_addr_i;
					ft_sent_r_nxt	= 1'b0;
					ft_vld_r_nxt 	= 1'b1;
				end else if (!ft_sent_r) begin // sending
					ft_tag_r_nxt	= Imem_ack_w ? Imem2proc_response_i : ft_tag_r;
					ft_PC_r_nxt		= ft_PC_r;
					ft_sent_r_nxt	= Imem_ack_w ? 1'b1 : ft_sent_r;
					ft_vld_r_nxt	= ft_vld_r;
				end else begin // sent, wait for data coming back
					ft_tag_r_nxt	= ft_data_rdy ? `MEM_TAG_W'b0 : ft_tag_r;
					ft_PC_r_nxt		= ft_data_rdy ? 64'h0 : ft_PC_r;
					ft_sent_r_nxt	= ft_data_rdy ? 1'b0 : ft_sent_r;
					ft_vld_r_nxt	= ft_data_rdy ? 1'b0 : ft_vld_r;
				end
			end
		end else begin // not reading cache
			ft_tag_r_nxt	= ft_tag_r;
			ft_PC_r_nxt		= ft_PC_r;
			ft_sent_r_nxt	= ft_sent_r;
			ft_vld_r_nxt	= ft_vld_r;
		end
	end

	///////////////////////////////////////////////////////
	// Prefetch signals assignments	
	///////////////////////////////////////////////////////
	assign pf_outstanding	= |pf_vld_r;
	assign pf_full			= (pf_hmsb_r != pf_tmsb_r) && 
							  (pf_head_r[1:0] == pf_tail_r[1:0]);
	assign pf_head_done		= pf_vld_r[pf_head_r] && pf_sent_r[pf_head_r] &&
							  (pf_tag_r[pf_head_r] == Imem2proc_tag_i);
	// prefetch signals
	always_comb begin
		pf_tag_r_nxt	= pf_tag_r;
		pf_PC_r_nxt		= pf_PC_r;
		pf_sent_r_nxt	= pf_sent_r;
		pf_vld_r_nxt	= pf_vld_r;
		pf_head_r_nxt	= pf_head_r;
		pf_tail_r_nxt	= pf_tail_r;
		pf_hmsb_r_nxt	= pf_hmsb_r;
		pf_tmsb_r_nxt	= pf_hmsb_r;
		// free head entry if data received
		if (pf_head_done) begin
			{pf_hmsb_r_nxt,pf_head_r_nxt}	= {pf_hmsb_r_nxt,pf_head_r_nxt} + 1;
			pf_tag_r_nxt [pf_head_r]		= `MEM_TAG_W'b0;
			pf_PC_r_nxt	 [pf_head_r]		= 64'h0;
			pf_sent_r_nxt[pf_head_r]		= 1'b0;
			pf_vld_r_nxt [pf_head_r]		= 1'b0;
		end
		// mark entry if sent
		for (int i = 0; i < 4; i++) begin
			if (pf_gtag_gnt_r[i] && Imem_ack_w) begin
				pf_tag_r_nxt [i] = Imem2proc_response_i;
                pf_sent_r_nxt[i] = 1'b1;
			end
		end
		// add prefetch entry when accessing I-cache
		if (if2Icache_rd_req_i) begin
			if (cachemem_hit_i) begin // if hit, add one entry;
				if (~pf_full) begin
					{pf_tmsb_r_nxt,pf_tail_r_nxt}	= {pf_tmsb_r_nxt,pf_tail_r_nxt} + 1;
					pf_tag_r_nxt [pf_tail_r]		= `MEM_TAG_W'b0;
					pf_PC_r_nxt  [pf_tail_r]		= (pf_outstanding) ?
													  pf_PC_r[pf_tail_r-1] + 64'h8 : 
													  if2Icache_addr_i + 64'h8;
					pf_sent_r_nxt[pf_tail_r]		= 1'b0;
					pf_vld_r_nxt [pf_tail_r]		= 1'b1;
				end
			end else if (!cache_hit_pf) begin // hard miss, don't do anything on soft miss
				pf_tag_r_nxt	= {4{`MEM_TAG_W'b0}}; // add 4 prefetches
				pf_sent_r_nxt	= 4'b0;
				pf_vld_r_nxt	= 4'b1;
				pf_head_r_nxt	= 2'b0;
				pf_tail_r_nxt	= 2'b0;
				pf_hmsb_r_nxt	= 1'b0;
				pf_tmsb_r_nxt	= 1'b1;
				for (int i = 0; i < 4; i++) begin
					pf_PC_r_nxt[i] = if2Icache_addr_i + 8*i + 8;
				end	
			end
		end
	end
	
	// current state update every cycle
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			state	<= `SD IDLE;
		end else begin
			state	<= `SD state_nxt;
		end
	end
	
	// fetch regs sequential
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			ft_tag_r	<= `SD `MEM_TAG_W'b0;
			ft_PC_r		<= `SD 64'h0;
			ft_sent_r	<= `SD 1'b0;
			ft_vld_r	<= `SD 1'b0;
		end else begin
			ft_tag_r	<= `SD ft_tag_r_nxt;
			ft_PC_r		<= `SD ft_PC_r_nxt;
			ft_sent_r	<= `SD ft_sent_r_nxt;
			ft_vld_r	<= `SD ft_vld_r_nxt;
		end
	end

	// prefetch regs sequential
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			pf_tag_r		<= {4{`MEM_TAG_W'b0}};
			pf_PC_r			<= {4{64'h0};
			pf_sent_r		<= 4'b0;
			pf_vld_r		<= 4'b0;
			pf_head_r		<= 3'b0;
			pf_tail_r		<= 3'b0;
			pf_gtag_gnt_r	<= 4'b0;
		end else begin
			pf_tag_r		<= pf_tag_r_nxt;
			pf_PC_r			<= pf_PC_r_nxt;
			pf_sent_r		<= pf_sent_r_nxt;
			pf_vld_r		<= pf_vld_r_nxt;
			pf_head_r		<= pf_head_r_nxt;
			pf_tail_r		<= pf_tail_r_nxt;
			pf_gtag_gnt_r	<= pf_send_gnt;
		end
	end


endmodule:Icache_ctrl

/*	// state transition logic
	always_comb begin
		case (state)
			IDLE: begin
				if (if2Icache_rd_req_i) begin
					if (cachemem_hit_i) begin
						state_nxt = PFETCH;
					end else if (cache_hit_pf) begin // soft miss
						state_nxt = SFETCH;
					end else begin // hard miss
						state_nxt = FETCH;
					end
				end else begin
					state_nxt = IDLE;
				end
			end
			FETCH: begin
				if () begin
					state_nxt = PFETCH;
				end else begin
					state_nxt = SFETCH;
				end
			SFETCH: begin
				if (ft_sent_r) begin
					state_nxt = PFETCH;
				end else begin
					state_nxt = SFETCH;
				end
			end
			PFETCH: begin
				if (if2Icache_rd_req_i) begin
					if (cachemem_hit_i) begin
						state_nxt = PFETCH;
					end else if (cache_hit_pf) begin // soft miss
						state_nxt = FETCH;
					end else begin
						state_nxt = FETCH; // hard miss
					end
				end else begin
					if (!pf_outstanding) begin
						state_nxt = IDLE;
					end else begin
						state_nxt = PFETCH;
					end
				end
			end
			default: state_nxt = IDLE;
		endcase
	end
*/

/*	always_comb begin
		case (state)
			IDLE: begin
				ft_tag_r_nxt = ft_tag_r;
				ft_PC_r_nxt	 = ft_PC_r;
				ft_sent_r_nxt= ft_sent_r;
				ft_vld_r_nxt = ft_vld_r;
				if (if2Icache_rd_req_i) begin
					if (cachemem_hit_i) begin
						ft_tag_r_nxt = ft_tag_r;
						ft_PC_r_nxt	 = ft_PC_r;
						ft_sent_r_nxt= ft_sent_r;
						ft_vld_r_nxt = ft_vld_r;
					end else if (cache_hit_pf) begin
						if (Imem2proc_response_i == cache_hit_pf_tag) begin
							ft_tag_r_nxt = `MEM_TAG_W'b0;
							ft_PC_r_nxt	 = 64'h0;
							ft_sent_r_nxt= 1'b0;
							ft_vld_r_nxt = 1'b0;
						end else begin
							ft_tag_r_nxt = cache_hit_pf_tag;
							ft_PC_r_nxt	 = cache_hit_pf_PC;
							ft_sent_r_nxt= cache_hit_pf_sent;
							ft_vld_r_nxt = cache_hit_pf_vld;
						end
					end else begin // hard miss
						ft_tag_r_nxt = ft_tag_r; // not sent request to Imem yet
						ft_PC_r_nxt	 = if2Icache_addr_i; // get missed PC
						ft_sent_r_nxt= 1'b0;
						ft_vld_r_nxt = 1'b1;
					end
				end else begin
					ft_tag_r_nxt = ft_tag_r;
					ft_PC_r_nxt	 = ft_PC_r;
					ft_sent_r_nxt= ft_sent_r;
					ft_vld_r_nxt = ft_vld_r;
				end
			end
			FETCH: begin
				if (ft_sent_r) begin
					if (ft_tag_r != Imem2proc_tag_i) begin
						ft_tag_r_nxt = ft_tag_r;
						ft_PC_r_nxt	 = ft_PC_r;
						ft_sent_r_nxt= ft_sent_r;
						ft_vld_r_nxt = ft_vld_r;
					end else if (Imem2proc_tag_i != 0) begin
						ft_tag_r_nxt = ft_tag_r;
						ft_PC_r_nxt	 = ft_PC_r;
						ft_sent_r_nxt= ft_sent_r;
						ft_vld_r_nxt = 1'b0;
				end else begin
					ft_tag_r_nxt = (Imem2proc_response_i != 0) ?
									Imem2proc_response_i : ft_tag_r;
					ft_PC_r_nxt	 = ft_PC_r;
					ft_sent_r_nxt= (Imem2proc_response_i != 0) ? 1'b1 : ft_sent_r;
					ft_vld_r_nxt = ft_vld_r;
				end	
			end
			PFETCH: begin
				ft_tag_r_nxt = ft_tag_r;
				ft_PC_r_nxt	 = ft_PC_r;
				ft_sent_r_nxt= ft_sent_r;
				ft_vld_r_nxt = (ft_vld_r && (ft_tag_r == Imem2proc_tag_i)) ?
								1'b0 : ft_vld_r;
			end
			default: begin
				ft_tag_r_nxt = ft_tag_r;
				ft_PC_r_nxt	 = ft_PC_r;
				ft_sent_r_nxt= ft_sent_r;
				ft_vld_r_nxt = ft_vld_r;
			end
		endcase
	end
*/
