// ****************************************************************************
// Filename: Icache_ctrl.v
// Description: Controller for I-cache 
// Author: Hengfei Zhong
// Version History:
// 	intial creation: 10/18/2017
// 	<10/25> move prefetch logic to prefetch module
// ****************************************************************************

module Icache_ctrl (
		input											clk,
		input											rst,
		
		input			[3:0]							Imem2proc_tag_i,
		input			[3:0]							Imem2proc_response_i,

		input			[`ICACHE_DATA_IN_BITS-1:0]		cachemem_data_i,
		input											cachemem_hit_i,

		input			[63:0]							if2Icache_addr_i,
		input											if2Icache_flush_i, // wrong BP

		input											pfetch2Ictrl_hit_i,

		output	logic									Icache2if_vld_o,
		output	logic	[`ICACHE_DATA_IN_BITS-1:0]		Icache2if_data_o,

		output	logic									Ictrl2Icache_wr_en_o,
		output	logic	[`ICACHE_IDX_W-1:0]				Ictrl2Icache_wr_idx_o,
		output	logic	[`ICACHE_TAG_W-1:0]				Ictrl2Icache_wr_tag_o,
		output	logic	[`ICACHE_IDX_W-1:0]				Ictrl2Icache_rd_idx_o,
		output	logic	[`ICACHE_TAG_W-1:0]				Ictrl2Icache_rd_tag_o,
		
		output	logic	[63:0]							Ictrl2pfetch_addr_o,
		output	logic									Ictrl2pfetch_en_o,

		output	logic	[63:0]							Ictrl2Imem_addr_o,
		output	logic	[1:0]							Ictrl2Imem_command_o
	);

	// state definition
	typedef enum logic [2:0] {
		IDLE	= 3'h0,
		FETCH	= 3'h1,
		WAIT	= 3'h2
	} state_t;

	state_t		state, state_nxt;

	// mem 
	wire									Imem_ack_w;
	wire									Imem_data_rdy;

	//-----------------------------------------------------
	// IF signals
	//-----------------------------------------------------
	logic		[`ICACHE_TAG_W-1:0]			if2Icache_tag;
	logic		[`ICACHE_IDX_W-1:0]			if2Icache_idx;
	logic		[`ICACHE_BLK_OFFSET_W-1:0]	if2Icache_off;

	//-----------------------------------------------------
	// fetch signals
	//-----------------------------------------------------
	logic		[`MEM_TAG_W-1:0]			ft_tag_r;
	logic		[`MEM_TAG_W-1:0]			ft_tag_r_nxt;

	// outputs for IF stage
	assign Icache2if_vld_o 	= cachemem_hit_i;
	assign Icache2if_data_o = cachemem_data_i;

	// outputs for cache read and fetch write
	assign {if2Icache_tag,if2Icache_idx,if2Icache_off} = if2Icache_addr_i;
	assign Ictrl2Icache_rd_tag_o = if2Icache_tag;
	assign Ictrl2Icache_rd_idx_o = if2Icache_idx;
	assign Ictrl2Icache_wr_tag_o = if2Icache_tag;
	assign Ictrl2Icache_wr_idx_o = if2Icache_idx;
	assign Ictrl2Icache_wr_en_o = Imem_data_rdy;

	// Imem
	assign Ictrl2Imem_addr_o= if2Icache_addr_i;
	assign Imem_ack_w		= (Imem2proc_response_i != 0);
	assign Imem_data_rdy	= (Imem2proc_tag_i == ft_tag_r) &&
							  (Imem2proc_tag_i != 0);

	// I control to prefetch signals
	assign Ictrl2pfetch_addr_o = if2Icache_addr_i;

	//-------------------------------------------------//
	// state machine
	//-------------------------------------------------//
	// state transition
	always_comb begin
		case (state)
			IDLE: begin
				if (if2Icache_flush_i)
					state_nxt =  state;
				else if (cachemem_hit_i) // hit on cache
					state_nxt = state;
				else if (pfetch2Ictrl_hit_i) // miss on cache but hit on prefetch
					state_nxt = WAIT;
				else // hard miss: miss on both cache and pending prefetch
					state_nxt = FETCH;
			end
			FETCH: begin
				if (if2Icache_flush_i)
					state_nxt = IDLE;
				else if (Imem_ack_w)
					state_nxt = WAIT;
				else
					state_nxt = state;
			end
			WAIT: state_nxt = if2Icache_flush_i ? IDLE :
							  cachemem_hit_i ? IDLE : state;
			default: state_nxt = IDLE;
		endcase
	end

	// outputs in each state
	always_comb begin
		case (state)
			IDLE: begin
				Ictrl2Imem_command_o = `BUS_NONE;
				Ictrl2pfetch_en_o= 1'b1;
			end
			FETCH: begin
				Ictrl2Imem_command_o = `BUS_LOAD;
				Ictrl2pfetch_en_o= 1'b0;
			end
			WAIT: begin
				Ictrl2Imem_command_o = `BUS_NONE;
				Ictrl2pfetch_en_o= 1'b1;
			end
			default: begin
				Ictrl2Imem_command_o = `BUS_NONE;
				Ictrl2pfetch_en_o= 1'b1;
			end
		endcase
	end		

	///////////////////////////////////////////////////
	// fetch tag, more like fething state
	///////////////////////////////////////////////////
	always_comb begin
		case (state)
			IDLE: begin
				ft_tag_r_nxt = `MEM_TAG_W'b0;
			end
			FETCH: begin
				if (if2Icache_flush_i)
					ft_tag_r_nxt = `MEM_TAG_W'b0;
				else
					ft_tag_r_nxt = Imem_ack_w ? Imem2proc_response_i : ft_tag_r;
			end
			WAIT: begin
				if (if2Icache_flush_i)
					ft_tag_r_nxt = `MEM_TAG_W'b0;
				else
					ft_tag_r_nxt = Imem_data_rdy ? `MEM_TAG_W'b0 : ft_tag_r;
			end
			default: begin
				ft_tag_r_nxt = `MEM_TAG_W'b0;
			end
		endcase
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
		end else begin
			ft_tag_r	<= `SD ft_tag_r_nxt;
		end
	end


endmodule:Icache_ctrl

