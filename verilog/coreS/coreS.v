//*****************************************************************************
// Filename: coreS.v
// Discription: 2-core top level, for performance boosting test
// Author: Hengfei Zhong
// Version History
//   <12/2> memory access arbitration added
//*****************************************************************************

`timescale	1ns/100ps

`define			IID_MEM_ABT_VEC_W 		4 // 2 Imem, 1 Dmem arbitration

module coreS	(
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
		output	logic	[3:0]					core0_retired_instrs,
		output	logic	[3:0]					core0_error_status,
		output	logic							core0_halt_o,

		output	logic	[3:0]					core1_retired_instrs,
		output	logic	[3:0]					core1_error_status,
		output	logic							core1_halt_o,

		output	logic	[63:0]					core0_retire_PC_tb_o,
		output	logic	[`LRF_IDX_W-1:0]		core0_retire_areg_tb_o,
		output	logic	[63:0]					core0_retire_areg_val_tb_o,
		output	logic							core0_retire_rdy_tb_o,

		output	logic	[63:0]					core1_retire_PC_tb_o,
		output	logic	[`LRF_IDX_W-1:0]		core1_retire_areg_tb_o,
		output	logic	[63:0]					core1_retire_areg_val_tb_o,
		output	logic							core1_retire_rdy_tb_o,

		// ports for writeback all dty data from Dcache to mem
		input			[`DCACHE_WAY_NUM-1:0]	Dcache0_way_idx_tb_i,
		input			[`DCACHE_IDX_W-1:0]		Dcache0_set_idx_tb_i,
		output	logic							Dcache0_blk_dty_tb_o,
		output	logic	[`DCACHE_TAG_W-1:0]		Dcache0_tag_tb_o,
		output	logic	[63:0]					Dcache0_data_tb_o,
	
		input			[`DCACHE_WAY_NUM-1:0]	Dcache1_way_idx_tb_i,
		input			[`DCACHE_IDX_W-1:0]		Dcache1_set_idx_tb_i,
		output	logic							Dcache1_blk_dty_tb_o,
		output	logic	[`DCACHE_TAG_W-1:0]		Dcache1_tag_tb_o,
		output	logic	[63:0]					Dcache1_data_tb_o
	);

	//---------------------------------------------------------------
	// signals for core0, without bus and Dmem_ctrl
	//---------------------------------------------------------------
	logic									bus2Dcache0_req_ack_i;
	logic									bus2Dcache0_req_id_i;
	logic	[`DCACHE_TAG_W-1:0]				bus2Dcache0_req_tag_i;
	logic	[`DCACHE_IDX_W-1:0]				bus2Dcache0_req_idx_i;
	message_t								bus2Dcache0_req_message_i;
	logic									bus2Dcache0_rsp_vld_i;
	logic									bus2Dcache0_rsp_id_i;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus2Dcache0_rsp_data_i;

	logic									Dcache02bus_req_en_o;
	logic	[`DCACHE_TAG_W-1:0]				Dcache02bus_req_tag_o;
	logic	[`DCACHE_IDX_W-1:0]				Dcache02bus_req_idx_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache02bus_req_data_o;
	message_t								Dcache02bus_req_message_o;

	logic									Dcache02bus_rsp_ack_o;
	// response to other request
	logic									Dcache02bus_rsp_vld_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache02bus_rsp_data_o;	

	logic	[3:0]							Imem2proc0_response_i;
	logic	[63:0]							Imem2Icache0_data_i;
	logic	[3:0]							Imem2proc0_tag_i;

	logic	[63:0]							proc02Imem_addr_o;
	logic	[1:0]							proc02Imem_command_o;


	//---------------------------------------------------------------
	// signals for core0, without bus and Dmem_ctrl
	//---------------------------------------------------------------
	logic									bus2Dcache1_req_ack_i;
	logic									bus2Dcache1_req_id_i;
	logic	[`DCACHE_TAG_W-1:0]				bus2Dcache1_req_tag_i;
	logic	[`DCACHE_IDX_W-1:0]				bus2Dcache1_req_idx_i;
	message_t								bus2Dcache1_req_message_i;
	logic									bus2Dcache1_rsp_vld_i;
	logic									bus2Dcache1_rsp_id_i;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		bus2Dcache1_rsp_data_i;

	logic									Dcache12bus_req_en_o;
	logic	[`DCACHE_TAG_W-1:0]				Dcache12bus_req_tag_o;
	logic	[`DCACHE_IDX_W-1:0]				Dcache12bus_req_idx_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache12bus_req_data_o;
	message_t								Dcache12bus_req_message_o;

	logic									Dcache12bus_rsp_ack_o;
	// response to other request
	logic									Dcache12bus_rsp_vld_o;
	logic	[`DCACHE_WORD_IN_BITS-1:0]		Dcache12bus_rsp_data_o;	

	logic	[3:0]							Imem2proc1_response_i;
	logic	[63:0]							Imem2Icache1_data_i;
	logic	[3:0]							Imem2proc1_tag_i;

	logic	[63:0]							proc12Imem_addr_o;
	logic	[1:0]							proc12Imem_command_o;


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

	logic										bus2Dmem_ctrl_core_req_o;
	logic										bus2Dmem_ctrl_req_ack_o;

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

	logic									bus_req_core_ack_i;
	logic									bus_req_ack_i;

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
	logic									Imem_abt_bit_r;
	logic		[`IID_MEM_ABT_VEC_W-1:0]	abt_vec_r;

	// Imen arbitration: 2 different requests to Imem, 1 selected request to Imem
	logic		[3:0]						Imem2proc0_response;
	logic		[3:0]						Imem2proc1_response;

	logic		[1:0]						proc2Imem_command_o; // select one to Imem
	logic		[63:0]						proc2Imem_addr_o; // select one to Imem

	// Imem and Dmem arbitration
	logic		[3:0]						Imem2proc_response;
	logic		[3:0]						Dmem2proc_response;

	
	// Imem arbitration logic, select one of them in 2 cores
	always_comb begin
		if (~Imem_abt_bit_r) begin // core0 first
			proc2Imem_command_o = (proc02Imem_command_o != `BUS_NONE) ?
								   proc02Imem_command_o : proc12Imem_command_o;
			proc2Imem_addr_o	= (proc02Imem_command_o != `BUS_NONE) ?
								   proc02Imem_addr_o : proc12Imem_addr_o;
			Imem2proc0_response	= (proc02Imem_command_o != `BUS_NONE) ?
								   Imem2proc_response : 0;
			Imem2proc1_response	= (proc02Imem_command_o != `BUS_NONE) ?
								   0 : Imem2proc_response;
		end else begin // core1 first
			proc2Imem_command_o = (proc12Imem_command_o != `BUS_NONE) ?
								   proc12Imem_command_o : proc02Imem_command_o;
			proc2Imem_addr_o	= (proc12Imem_command_o != `BUS_NONE) ?
								   proc12Imem_addr_o : proc02Imem_addr_o;
			Imem2proc0_response	= (proc12Imem_command_o != `BUS_NONE) ?
								   0 : Imem2proc_response;
			Imem2proc1_response	= (proc02Imem_command_o != `BUS_NONE) ?
								   Imem2proc_response : 0;
		end
	end

	// Imem and Dmem arbitration logic
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
	// core0 instantiation
	//===============================================================
	assign bus2Dcache0_req_ack_i		= bus2core0_req_ack_o;
	assign bus2Dcache0_req_id_i			= bus_req_id_o;
	assign bus2Dcache0_req_tag_i		= bus_req_tag_o;
	assign bus2Dcache0_req_idx_i		= bus_req_idx_o;
	assign bus2Dcache0_req_message_i	= bus_req_message_o;
	assign bus2Dcache0_rsp_vld_i		= bus_rsp_vld_o;
	assign bus2Dcache0_rsp_id_i			= bus_rsp_id_o;
	assign bus2Dcache0_rsp_data_i		= bus_rsp_data_o;

	assign Imem2proc0_response_i	= Imem2proc0_response;
	assign Imem2Icache0_data_i		= mem2proc_data_i; // !!!
	assign Imem2proc0_tag_i			= mem2proc_tag_i; // !!!
	
	core core0 (
		.clk						(clk),
		.rst						(rst),

		.cpu_id_i					(1'b0),

		// may need more ports for testbench!!!
		.core_retired_instrs		(core0_retired_instrs),
		.core_error_status			(core0_error_status),
		.core_halt_o				(core0_halt_o),

		//
		.retire_PC_tb_o				(core0_retire_PC_tb_o),
		.retire_areg_tb_o			(core0_retire_areg_tb_o),
		.retire_areg_val_tb_o		(core0_retire_areg_val_tb_o),
		.retire_rdy_tb_o			(core0_retire_rdy_tb_o),

		// ports for writeback all dty data from Dcache to mem
		.Dcache_way_idx_tb_i		(Dcache0_way_idx_tb_i),
		.Dcache_set_idx_tb_i		(Dcache0_set_idx_tb_i),
		.Dcache_blk_dty_tb_o		(Dcache0_blk_dty_tb_o),
		.Dcache_tag_tb_o			(Dcache0_tag_tb_o),
		.Dcache_data_tb_o			(Dcache0_data_tb_o),

		//-----------------------------------------------
		// network(or bus) side signals
		.bus2Dcache_req_ack_i		(bus2Dcache0_req_ack_i),
		.bus2Dcache_req_id_i		(bus2Dcache0_req_id_i),
		.bus2Dcache_req_tag_i		(bus2Dcache0_req_tag_i),
		.bus2Dcache_req_idx_i		(bus2Dcache0_req_idx_i),
		.bus2Dcache_req_message_i	(bus2Dcache0_req_message_i),
		.bus2Dcache_rsp_vld_i		(bus2Dcache0_rsp_vld_i),
		.bus2Dcache_rsp_id_i		(bus2Dcache0_rsp_id_i),
		.bus2Dcache_rsp_data_i		(bus2Dcache0_rsp_data_i),

		.Dcache2bus_req_en_o		(Dcache02bus_req_en_o),
		.Dcache2bus_req_tag_o		(Dcache02bus_req_tag_o),
		.Dcache2bus_req_idx_o		(Dcache02bus_req_idx_o),
		.Dcache2bus_req_data_o		(Dcache02bus_req_data_o),
		.Dcache2bus_req_message_o	(Dcache02bus_req_message_o),

		.Dcache2bus_rsp_ack_o		(Dcache02bus_rsp_ack_o),
		// response to other request
		.Dcache2bus_rsp_vld_o		(Dcache02bus_rsp_vld_o),
		.Dcache2bus_rsp_data_o		(Dcache02bus_rsp_data_o),

		//Icache ports
		.Imem2proc_response_i		(Imem2proc0_response_i),
		.Imem2Icache_data_i			(Imem2Icache0_data_i),
		.Imem2proc_tag_i			(Imem2proc0_tag_i),

		.proc2Imem_addr_o			(proc02Imem_addr_o),
		.proc2Imem_command_o		(proc02Imem_command_o)
	);


	//===============================================================
	// core1 instantiation
	//===============================================================
	assign bus2Dcache1_req_ack_i		= bus2core1_req_ack_o;
	assign bus2Dcache1_req_id_i			= bus_req_id_o;
	assign bus2Dcache1_req_tag_i		= bus_req_tag_o;
	assign bus2Dcache1_req_idx_i		= bus_req_idx_o;
	assign bus2Dcache1_req_message_i	= bus_req_message_o;
	assign bus2Dcache1_rsp_vld_i		= bus_rsp_vld_o;
	assign bus2Dcache1_rsp_id_i			= bus_rsp_id_o;
	assign bus2Dcache1_rsp_data_i		= bus_rsp_data_o;

	assign Imem2proc1_response_i	= Imem2proc1_response;
	assign Imem2Icache1_data_i		= mem2proc_data_i; // !!!
	assign Imem2proc1_tag_i			= mem2proc_tag_i; // !!!
	
	core core1 (
		.clk						(clk),
		.rst						(rst),

		.cpu_id_i					(1'b1),

		// may need more ports for testbench!!!
		.core_retired_instrs		(core1_retired_instrs),
		.core_error_status			(core1_error_status),
		.core_halt_o				(core1_halt_o),

		.retire_PC_tb_o				(core1_retire_PC_tb_o),
		.retire_areg_tb_o			(core1_retire_areg_tb_o),
		.retire_areg_val_tb_o		(core1_retire_areg_val_tb_o),
		.retire_rdy_tb_o			(core1_retire_rdy_tb_o),		

		// ports for writeback all dty data from Dcache to mem
		.Dcache_way_idx_tb_i		(Dcache1_way_idx_tb_i),
		.Dcache_set_idx_tb_i		(Dcache1_set_idx_tb_i),
		.Dcache_blk_dty_tb_o		(Dcache1_blk_dty_tb_o),
		.Dcache_tag_tb_o			(Dcache1_tag_tb_o),
		.Dcache_data_tb_o			(Dcache1_data_tb_o),

		//-----------------------------------------------
		// network(or bus) side signals
		.bus2Dcache_req_ack_i		(bus2Dcache1_req_ack_i),
		.bus2Dcache_req_id_i		(bus2Dcache1_req_id_i),
		.bus2Dcache_req_tag_i		(bus2Dcache1_req_tag_i),
		.bus2Dcache_req_idx_i		(bus2Dcache1_req_idx_i),
		.bus2Dcache_req_message_i	(bus2Dcache1_req_message_i),
		.bus2Dcache_rsp_vld_i		(bus2Dcache1_rsp_vld_i),
		.bus2Dcache_rsp_id_i		(bus2Dcache1_rsp_id_i),
		.bus2Dcache_rsp_data_i		(bus2Dcache1_rsp_data_i),

		.Dcache2bus_req_en_o		(Dcache12bus_req_en_o),
		.Dcache2bus_req_tag_o		(Dcache12bus_req_tag_o),
		.Dcache2bus_req_idx_o		(Dcache12bus_req_idx_o),
		.Dcache2bus_req_data_o		(Dcache12bus_req_data_o),
		.Dcache2bus_req_message_o	(Dcache12bus_req_message_o),

		.Dcache2bus_rsp_ack_o		(Dcache12bus_rsp_ack_o),
		// response to other request
		.Dcache2bus_rsp_vld_o		(Dcache12bus_rsp_vld_o),
		.Dcache2bus_rsp_data_o		(Dcache12bus_rsp_data_o),

		//Icache ports
		.Imem2proc_response_i		(Imem2proc1_response_i),
		.Imem2Icache_data_i			(Imem2Icache1_data_i),
		.Imem2proc_tag_i			(Imem2proc1_tag_i),

		.proc2Imem_addr_o			(proc12Imem_addr_o),
		.proc2Imem_command_o		(proc12Imem_command_o)
	);



	//===============================================================
	// bus instantiation
	//===============================================================
	assign core0_req_en_i		= Dcache02bus_req_en_o;
	assign core0_req_tag_i		= Dcache02bus_req_tag_o;
	assign core0_req_idx_i		= Dcache02bus_req_idx_o;
	assign core0_req_data_i		= Dcache02bus_req_data_o;
	assign core0_req_message_i	= Dcache02bus_req_message_o;
	assign core0_rsp_vld_i		= Dcache02bus_rsp_vld_o;
	assign core0_rsp_data_i		= Dcache02bus_rsp_data_o;
	assign core0_rsp_ack_i		= Dcache02bus_rsp_ack_o;

	assign core1_req_en_i		= Dcache12bus_req_en_o;
	assign core1_req_tag_i		= Dcache12bus_req_tag_o;
	assign core1_req_idx_i		= Dcache12bus_req_idx_o;
	assign core1_req_data_i		= Dcache12bus_req_data_o;
	assign core1_req_message_i	= Dcache12bus_req_message_o;
	assign core1_rsp_vld_i		= Dcache12bus_rsp_vld_o;
	assign core1_rsp_data_i		= Dcache12bus_rsp_data_o;
	assign core1_rsp_ack_i		= Dcache12bus_rsp_ack_o;
 
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
		// <12/3>
		.bus2Dmem_ctrl_core_req_o(bus2Dmem_ctrl_core_req_o),
		.bus2Dmem_ctrl_req_ack_o(bus2Dmem_ctrl_req_ack_o),

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

	assign bus_req_core_ack_i	= bus2Dmem_ctrl_core_req_o;
	
	assign bus_req_ack_i		= bus2Dmem_ctrl_req_ack_o;

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
		// <12/3>
		.bus_req_core_ack_i		(bus_req_core_ack_i),

		.bus_req_ack_i			(bus_req_ack_i),

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
			abt_vec_r		<= `SD `IID_MEM_ABT_VEC_W'b1;
			Imem_abt_bit_r	<= `SD 1'b0;
		end else begin
			abt_vec_r[`IID_MEM_ABT_VEC_W-1]		<= `SD abt_vec_r[0];
			abt_vec_r[`IID_MEM_ABT_VEC_W-2:0]	<= `SD abt_vec_r[`IID_MEM_ABT_VEC_W-1:1];
			Imem_abt_bit_r						<= `SD ~Imem_abt_bit_r;
		end
	end


endmodule: coreS

