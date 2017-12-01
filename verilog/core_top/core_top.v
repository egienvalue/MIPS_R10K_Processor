//*****************************************************************************
// Filename: core_top.v
// Discription: single core top level, submission for correctness testing
// Author: Hengfei Zhong
// Version History
//   <11/30> initial creation: integrate with br_predictor, LSQ, Dcache
//*****************************************************************************

module core_top	(
		input									clk,
		input									rst,

		input			[3:0]					mem2proc_response_i,
		input			[63:0]					mem2proc_data_i,
		input			[3:0]					mem2proc_tag_i,
	
		output	logic	[1:0]					proc2mem_command_o,
		output	logic	[63:0]					proc2mem_addr_o,
		output	logic	[63:0]					proc2mem_data_o,

		//-------------------------------------------------
		// may need more ports for testbench!!!
		output	logic	[3:0]					core_retired_instrs,
		output	logic	[3:0]					core_error_status,

		// ports for writeback all dty data from Dcache to mem
		input			[`DCACHE_WAY_NUM-1:0]	Dcache_way_idx_tb_i,
		input			[`DCACHE_IDX_W-1:0]		Dcache_set_idx_tb_i,
		output	logic							Dcache_blk_dty_tb_o,
		output	logic	[`DCACHE_TAG_W-1:0]		Dcache_tag_tb_o,
		output	logic	[63:0]					Dcache_data_tb_o
	);

	//---------------------------------------------------------------
	// signals for core, without bus and Dmem_ctrl
	//---------------------------------------------------------------
	logic									bus2Dcache_req_ack_i;
	logic									bus2Dcache_req_id_i;
	logic	[`DCACHE_TAG_W-1:0]				bus2Dcache_req_tag_i;
	logic	[`DCACHE_IDX_W-1:0]				bus2Dcache_req_idx_i;
	message_t								bus2Dcache_req_message_i;
	logic									bus2Dcache_rsp_vld_i;
	logic									bus2Dcache_rsp_id_i;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus2Dcache_rsp_data_i;

	logic									Dcache2bus_req_en_o;
	logic	[`DCACHE_TAG_W-1:0]				Dcache2bus_req_tag_o;
	logic	[`DCACHE_IDX_W-1:0]				Dcache2bus_req_idx_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_req_data_o;
	message_t								Dcache2bus_req_message_o;

	logic									Dcache2bus_rsp_ack_o;
	// response to other request
	logic									Dcache2bus_rsp_vld_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache2bus_rsp_data_o;	

	logic	[3:0]							Imem2proc_response_i;
	logic	[63:0]							Imem2Icache_data_i;
	logic	[3:0]							Imem2proc_tag_i;

	logic	[63:0]							proc2Imem_addr_o;
	logic	[1:0]							proc2Imem_command_o;

	//---------------------------------------------------------------
	// signals for coherence bus
	//---------------------------------------------------------------
		// core0 signals
	logic										core0_req_en_i;
	logic		[`DCACHE_TAG_W-1:0]				core0_req_tag_i;
	logic		[`DCACHE_IDX_W-1:0]				core0_req_idx_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		core0_req_data_i;
	message_t									core0_req_message_i;
	logic										core0_rsp_vld_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		core0_rsp_data_i;
	logic										core0_rsp_ack_i;
	logic										bus2core0_req_ack_o;

	// core1 signals
	logic										core1_req_en_i;
	logic		[`DCACHE_TAG_W-1:0]				core1_req_tag_i;
	logic		[`DCACHE_IDX_W-1:0]				core1_req_idx_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		core1_req_data_i;
	message_t									core1_req_message_i;
	logic										core1_rsp_vld_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		core1_rsp_data_i;
	logic										core1_rsp_ack_i;
	logic										bus2core1_req_ack_o;

	// memory controller signals
	logic										Dmem_ctrl_rsp_ack_i;
	logic										Dmem_ctrl_rsp_vld_i;
	logic		[`RSP_Q_PTR_W-1:0]				Dmem_ctrl_rsp_ptr_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		Dmem_ctrl_rsp_data_i;
	logic		[`RSP_Q_PTR_W-1:0]				bus2Dmem_ctrl_rsp_ptr_o;

	// request outputs
	logic										bus_req_id_o;
	logic		[`DCACHE_TAG_W-1:0]				bus_req_tag_o;
	logic		[`DCACHE_IDX_W-1:0]				bus_req_idx_o;
	message_t									bus_req_message_o;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		bus_req_data_o; // to Dmem_ctrl
	
	// response outputs
	logic										bus_rsp_vld_o;
	logic										bus_rsp_id_o;
	logic		[`DCACHE_WORD_IN_BITS-1:0]		bus_rsp_data_o;
	logic		[63:0]							bus_rsp_addr_o; // to Dmem_ctrl

	
	//---------------------------------------------------------------
	// signals for Dmem_ctrl
	//---------------------------------------------------------------
	// bus interface
	logic		[`DCACHE_TAG_W-1:0]			bus_req_tag_i;
	logic		[`DCACHE_IDX_W-1:0]			bus_req_idx_i;
	message_t								bus_req_message_i;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	bus_req_data_i;

	logic									bus_rsp_vld_i;	
	logic		[`DCACHE_WORD_IN_BITS-1:0]	bus_rsp_data_i;
	logic		[63:0]						bus_rsp_addr_i;
	logic		[`RSP_Q_PTR_W-1:0]			bus_rsp_ptr_i;

	logic									Dmem_ctrl_rsp_ack_o;
	logic									Dmem_ctrl_rsp_vld_o;
	logic		[`RSP_Q_PTR_W-1:0]			Dmem_ctrl_rsp_ptr_o;
	logic		[`DCACHE_WORD_IN_BITS-1:0]	Dmem_ctrl_rsp_data_o;

	// memory interface
	logic		[3:0]						Dmem2proc_response_i;
	logic		[63:0]						Dmem2Dcache_data_i;
	logic		[3:0]						Dmem2proc_tag_i;

	logic		[63:0]						proc2Dmem_addr_o;
	logic		[63:0]						proc2Dmem_data_o;
	logic		[1:0]						proc2Dmem_command_o;

	
	//===============================================================
	// Dmem/Imem arbitration, winner sends command to memory
	//===============================================================
	logic		[`ID_MEM_ABT_VEC_W-1:0]		abt_vec_r;
	logic		[3:0]						Imem2proc_response;
	logic		[3:0]						Dmem2proc_response;

	assign proc2mem_data_o		= proc2Dmem_data_o; // only write to Dmem

	always_comb begin
		if (abt_vec_r[0]) begin // Imem first
			proc2mem_command_o	= (proc2Imem_command_o != `BUS_NONE) ?
								   proc2Imem_command_o : proc2Dmem_command_o;
			proc2mem_addr_o		= (proc2Imem_command_o != `BUS_NONE) ?
								   proc2Imem_addr_o : proc2Dmem_addr_o;
			Imem2proc_response	= (proc2Imem_command_o != `BUS_NONE) ?
								   mem2proc_response_i : 0;
			Dmem2proc_response	= (proc2Imem_command_o != `BUS_NONE) ?
								   0 : mem2proc_response_i;			
		end else begin // Dmem first
			proc2mem_command_o	= (proc2Dmem_command_o != `BUS_NONE) ?
								   proc2Dmem_command_o : proc2Imem_command_o;
			proc2mem_addr_o		= (proc2Dmem_command_o != `BUS_NONE) ?
								   proc2Dmem_addr_o : proc2Imem_addr_o;
			Imem2proc_response	= (proc2Dmem_command_o != `BUS_NONE) ?
								   0 : mem2proc_response_i;
			Dmem2proc_response	= (proc2Dmem_command_o != `BUS_NONE) ?
								   mem2proc_response_i : 0;
		end
	end


	//===============================================================
	// core instantiation
	//===============================================================
	assign bus2Dcache_req_ack_i		= bus2core0_req_ack_o;
	assign bus2Dcache_req_id_i		= bus_req_id_o;
	assign bus2Dcache_req_tag_i		= bus_req_tag_o;
	assign bus2Dcache_req_idx_i		= bus_req_idx_o;
	assign bus2Dcache_req_message_i	= bus_req_message_o;
	assign bus2Dcache_rsp_vld_i		= bus_rsp_vld_o;
	assign bus2Dcache_rsp_id_i		= bus_rsp_id_o;
	assign bus2Dcache_rsp_data_i	= bus_rsp_data_o;

	assign Imem2proc_response_i		= Imem2proc_response;
	assign Imem2Icache_data_i		= mem2proc_data_i;
	assign Imem2proc_tag_i			= mem2proc_tag_i;
	
	core core0 (
		.clk						(clk),
		.rst						(rst),

		.cpu_id_i					(1'b0),

		// may need more ports for testbench!!!
		.core_retired_instrs		(core_retired_instrs),
		.core_error_status			(core_error_status),

		// ports for writeback all dty data from Dcache to mem
		.Dcache_way_idx_tb_i			(Dcache_way_idx_tb_i),
		.Dcache_set_idx_tb_i			(Dcache_set_idx_tb_i),
		.Dcache_blk_dty_tb_o			(Dcache_blk_dty_tb_o),
		.Dcache_tag_tb_o				(Dcache_tag_tb_o),
		.Dcache_data_tb_o				(Dcache_data_tb_o),

		//-----------------------------------------------
		// network(or bus) side signals
		.bus2Dcache_req_ack_i		(bus2Dcache_req_ack_i),
		.bus2Dcache_req_id_i		(bus2Dcache_req_id_i),
		.bus2Dcache_req_tag_i		(bus2Dcache_req_tag_i),
		.bus2Dcache_req_idx_i		(bus2Dcache_req_idx_i),
		.bus2Dcache_req_message_i	(bus2Dcache_req_message_i),
		.bus2Dcache_rsp_vld_i		(bus2Dcache_rsp_vld_i),
		.bus2Dcache_rsp_id_i		(bus2Dcache_rsp_id_i),
		.bus2Dcache_rsp_data_i		(bus2Dcache_rsp_data_i),

		.Dcache2bus_req_en_o		(Dcache2bus_req_en_o),
		.Dcache2bus_req_tag_o		(Dcache2bus_req_tag_o),
		.Dcache2bus_req_idx_o		(Dcache2bus_req_idx_o),
		.Dcache2bus_req_data_o		(Dcache2bus_req_data_o),
		.Dcache2bus_req_message_o	(Dcache2bus_req_message_o),

		.Dcache2bus_rsp_ack_o		(Dcache2bus_rsp_ack_o),
		// response to other request
		.Dcache2bus_rsp_vld_o		(Dcache2bus_rsp_vld_o),
		.Dcache2bus_rsp_data_o		(Dcache2bus_rsp_data_o),

		//Icache ports
		.Imem2proc_response_i		(Imem2proc_response_i),
		.Imem2Icache_data_i			(Imem2Icache_data_i),
		.Imem2proc_tag_i			(Imem2proc_tag_i),

		.proc2Imem_addr_o			(proc2Imem_addr_o),
		.proc2Imem_command_o		(proc2Imem_command_o)
	);


	//===============================================================
	// bus instantiation
	//===============================================================
	assign core0_req_en_i		= Dcache2bus_req_en_o;
	assign core0_req_tag_i		= Dcache2bus_req_tag_o;
	assign core0_req_idx_i		= Dcache2bus_req_idx_o;
	assign core0_req_data_i		= Dcache2bus_req_data_o;
	assign core0_req_message_i	= Dcache2bus_req_message_o;
	assign core0_rsp_vld_i		= Dcache2bus_rsp_vld_o;
	assign core0_rsp_data_i		= Dcache2bus_rsp_data_o;
	assign core0_rsp_ack_i		= Dcache2bus_rsp_ack_o;

	assign core1_req_en_i		= 0;
	assign core1_req_tag_i		= 0;
	assign core1_req_idx_i		= 0;
	assign core1_req_message_i	= NONE;
	assign core1_req_data_i		= 0;
	assign core1_rsp_vld_i		= 0;
	assign core1_rsp_data_i		= 0;
	assign core1_rsp_ack_i		= 0;
 
	assign Dmem_ctrl_rsp_ack_i	= Dmem_ctrl_rsp_ack_o;
	assign Dmem_ctrl_rsp_vld_i	= Dmem_ctrl_rsp_vld_o;
	assign Dmem_ctrl_rsp_ptr_i	= Dmem_ctrl_rsp_ptr_o;
	assign Dmem_ctrl_rsp_data_i	= Dmem_ctrl_rsp_data_o;


	bus bus (
		.clk					(clk),
		.rst					(rst),
		
		// core0 signals
		.core0_req_en_i			(core0_req_en_i),
		.core0_req_tag_i		(core0_req_tag_i),
		.core0_req_idx_i		(core0_req_idx_i),
		.core0_req_data_i		(core0_req_data_i),
		.core0_req_message_i	(core0_req_message_i),
		.core0_rsp_vld_i		(core0_rsp_vld_i),
		.core0_rsp_data_i		(core0_rsp_data_i),
		.core0_rsp_ack_i		(core0_rsp_ack_i),
		.bus2core0_req_ack_o	(bus2core0_req_ack_o),

		// !!!
		// core1 signals
		.core1_req_en_i			(core1_req_en_i),
		.core1_req_tag_i		(core1_req_tag_i),
		.core1_req_idx_i		(core1_req_idx_i),
		.core1_req_data_i		(core1_req_data_i),
		.core1_req_message_i	(core1_req_message_i),
		.core1_rsp_vld_i		(core1_rsp_vld_i),
		.core1_rsp_data_i		(core1_rsp_data_i),
		.core1_rsp_ack_i		(core1_rsp_ack_i),
		.bus2core1_req_ack_o	(bus2core1_req_ack_o),

		// memory controller signals
		.Dmem_ctrl_rsp_ack_i	(Dmem_ctrl_rsp_ack_i),
		.Dmem_ctrl_rsp_vld_i	(Dmem_ctrl_rsp_vld_i),
		.Dmem_ctrl_rsp_ptr_i	(Dmem_ctrl_rsp_ptr_i),
		.Dmem_ctrl_rsp_data_i	(Dmem_ctrl_rsp_data_i),
		.bus2Dmem_ctrl_rsp_ptr_o(bus2Dmem_ctrl_rsp_ptr_o),

		// request outputs
		.bus_req_id_o			(bus_req_id_o),
		.bus_req_tag_o			(bus_req_tag_o),
		.bus_req_idx_o			(bus_req_idx_o),
		.bus_req_message_o		(bus_req_message_o),
		.bus_req_data_o			(bus_req_data_o), // to Dmem_ctrl
		
		// response outputs
		.bus_rsp_vld_o			(bus_rsp_vld_o),
		.bus_rsp_id_o			(bus_rsp_id_o),
		.bus_rsp_data_o			(bus_rsp_data_o),
		.bus_rsp_addr_o 		(bus_rsp_addr_o) // to Dmem_ctrl
	);



	//===============================================================
	// Deme_ctrl instantiation
	//===============================================================
	assign bus_req_tag_i		= bus_req_tag_o;         
	assign bus_req_idx_i		= bus_req_idx_o;
	assign bus_req_message_i    = bus_req_message_o;
	assign bus_req_data_i       = bus_req_data_o;
	assign bus_rsp_vld_i		= bus_rsp_vld_o;
	assign bus_rsp_data_i		= bus_rsp_data_o;
	assign bus_rsp_addr_i		= bus_rsp_addr_o;
	assign bus_rsp_ptr_i		= bus2Dmem_ctrl_rsp_ptr_o;
 
	assign Dmem2proc_response_i	= Dmem2proc_response;
	assign Dmem2Dcache_data_i	= mem2proc_data_i;
	assign Dmem2proc_tag_i		= mem2proc_tag_i;

	Dmem_ctrl Dmem_ctrl (
		.clk					(clk),
		.rst					(rst),

		// bus interface	
		.bus_req_tag_i			(bus_req_tag_i),
		.bus_req_idx_i			(bus_req_idx_i),
		.bus_req_message_i		(bus_req_message_i),
		.bus_req_data_i			(bus_req_data_i),
	
		.bus_rsp_vld_i			(bus_rsp_vld_i),	
		.bus_rsp_data_i			(bus_rsp_data_i),
		.bus_rsp_addr_i			(bus_rsp_addr_i),
		.bus_rsp_ptr_i			(bus_rsp_ptr_i),

		.Dmem_ctrl_rsp_ack_o	(Dmem_ctrl_rsp_ack_o),
		.Dmem_ctrl_rsp_vld_o	(Dmem_ctrl_rsp_vld_o),
		.Dmem_ctrl_rsp_ptr_o	(Dmem_ctrl_rsp_ptr_o),
		.Dmem_ctrl_rsp_data_o	(Dmem_ctrl_rsp_data_o),

		// memory interface
		.Dmem2proc_response_i	(Dmem2proc_response_i),
		.Dmem2Dcache_data_i		(Dmem2Dcache_data_i),
		.Dmem2proc_tag_i		(Dmem2proc_tag_i),

		.proc2Dmem_addr_o		(proc2Dmem_addr_o),
		.proc2Dmem_data_o		(proc2Dmem_data_o),
		.proc2Dmem_command_o	(proc2Dmem_command_o)
	);


	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			abt_vec_r	<= `SD `ID_MEM_ABT_VEC_W'b1;
		end else begin
			abt_vec_r[`ID_MEM_ABT_VEC_W-1]	<= abt_vec_r[0];
			abt_vec_r[`ID_MEM_ABT_VEC_W-2:0]<= abt_vec_r[`ID_MEM_ABT_VEC_W-1:1];
		end
	end


endmodule: core_top

