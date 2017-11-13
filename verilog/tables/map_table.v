// ****************************************************************************
// Filename: map_table.v
// Discription: Map table
//				Three cases: 1.	Dispatch
//								Read out the tags(pregs) of two oprands' aregs and dest
//								areg. Write in new preg to the index of the dest areg. 
//								*Notice that the ready bit outputs of two oprands
//								should catch what CDB braodcasts at the same
//								cycle.
//							 2.	CDB broadcast
//								If corresponding preg is found, change its ready
//								bit to 1.
//							 3. Early branch single cycle recovery
//								Map table maintains some checkpoint copies. It
//								will be flushed back when branch prediction is
//								wrong by manipulating these copies.
// Author: Chuan Cen
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************
//
typedef enum logic {NORMAL = 1'b0, ROLLBACK = 1'b1} STATE;	

//`define MT_DEBUG

module map_table(
		input										clk,
		input										rst,						//|From where|									
		input	[`LRF_IDX_W-1:0]					opa_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.
		input	[`LRF_IDX_W-1:0]					opb_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
		input	[`LRF_IDX_W-1:0]					dest_areg_idx_i,			//[Decoder]		A logic register index to read the old dest physical reg, and to write a new dest physical reg.
		input	[`PRF_IDX_W-1:0]					new_free_preg_i,			//[Free-List]	New physical register name from Free List.
		input										dispatch_en_i,				//[Decoder]		Enabling all inputs above. 
		input	[`PRF_IDX_W-1:0]					cdb_set_rdy_bit_preg_i,		//[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
		input										cdb_set_rdy_bit_en_i,		//[CDB]			Enabling setting ready bit. 
		input	[`BR_STATE_W-1:0]					branch_state_i,				//[ROB]			Branch prediction wrong or correct?
		input	[`MT_NUM-1:0][`PRF_IDX_W:0]			rc_mt_all_data_i,			//[Br_stack]	Recovery data for map table.	Highest bit [`PRF_IDX_W] is RDY.
		
		
		`ifdef MT_DEBUG
			input	[`LRF_IDX_W-1:0]				read_idx_i,					// Check the original map table only. 
			output	[`PRF_IDX_W-1:0]				read_preg_o,
			output									read_rdy_bit_o,
			output									cdb_match_fd,
		`endif
																		//|To where|
		output	logic	[`PRF_IDX_W-1:0]			opa_preg_o,					//[RS]			Oprand A physical reg output.
		output	logic	[`PRF_IDX_W-1:0]			opb_preg_o,					//[RS]			Oprand B physical reg output.
		output	logic								opa_preg_rdy_bit_o,			//[RS]			Oprand A physical reg ready bit output. 
		output	logic								opb_preg_rdy_bit_o,			//[RS]			Oprand B physical reg ready bit output.
		output	logic	[`PRF_IDX_W-1:0]			dest_old_preg_o,			//[ROB]			Old dest physical reg output. 
		output	logic	[`MT_NUM-1:0][`PRF_IDX_W:0]	bak_data_o					//[Br_stack]	Back up data to branch stack.

		);

		logic	[`MT_NUM-1:0][`PRF_IDX_W-1:0]		MAP;						//MAP[0] is the original MAP. MAP[1] is the first copy and so on.
		logic	[`MT_NUM-1:0]						RDY;						//RDY[0] is the original RDY. RDY[1] is the first copy and so on.
		logic	[`MT_NUM-1:0][`PRF_IDX_W-1:0]		next_MAP;					//Next MAP values
		logic	[`MT_NUM-1:0]						next_RDY;					//Next RDY values
		logic	[`LRF_IDX_W-1:0]					cdb_match_index;
		logic										cdb_match_found;
	
		STATE state;
	
		`ifdef MT_DEBUG
			assign read_preg_o		= MAP[read_idx_i];
			assign read_rdy_bit_o	= RDY[read_idx_i];
			assign cdb_match_fd		= cdb_match_found;
		`endif
	
		assign opa_preg_o			= dispatch_en_i ? MAP[opa_areg_idx_i]: 6'b000000;		// Always use original map table here. Copies only for dealing with branch issues.
		assign opb_preg_o			= dispatch_en_i ? MAP[opb_areg_idx_i]: 6'b000000;

		//assign opa_preg_rdy_bit_o	= dispatch_en_i ? cdb_match_index==opa_areg_idx_i ? 1 : RDY[opa_areg_idx_i] : 0;
		//assign opb_preg_rdy_bit_o	= dispatch_en_i ? cdb_match_index==opb_areg_idx_i ? 1 : RDY[opb_areg_idx_i] : 0;

		assign opa_preg_rdy_bit_o = RDY[opa_areg_idx_i];
		assign opb_preg_rdy_bit_o = RDY[opb_areg_idx_i];

		assign dest_old_preg_o		= dispatch_en_i ? MAP[dest_areg_idx_i] : 6'b000000;
		assign state				= (branch_state_i == `BR_PR_WRONG) ? ROLLBACK : NORMAL; 	// Two different situations. 

		always_comb begin					// Concatenate/pack-up two arrays for output.
			for (int i=0;i<`MT_NUM;i++) begin
				bak_data_o[i] = {next_RDY[i],next_MAP[i]};
			end
		end

		always_comb begin	// Here we make the next_MAP/RDY ready for sequential assignments.
			next_MAP	= MAP; // added by hengfei. set default value, otherwise synthesis will generate Latches
			next_RDY	= RDY;
			case(state)
				NORMAL:
				begin
					if (cdb_set_rdy_bit_en_i && cdb_match_found) begin
						for (int i=0; i<`MT_NUM; i++) begin
							if (i==cdb_match_index) begin
								next_RDY[i] = 1;
							end else begin
								next_RDY[i] = RDY[i];   // Accordant with the origin.
							end
						end
					end else begin
					end
					if (dispatch_en_i) begin
						for (int i=0; i<`MT_NUM; i++) begin
							if (i==dest_areg_idx_i) begin
								next_MAP[dest_areg_idx_i] = new_free_preg_i;
								next_RDY[dest_areg_idx_i] = 0;
							end else begin
								//next_MAP[i] = MAP[i];		// Accordant with the origin.
								//next_RDY[i] = RDY[i];
							end
						end
					end else begin
					end
				end
				ROLLBACK:
				begin
					for (int i=0; i<`MT_NUM; i++) begin
						next_MAP[i] = rc_mt_all_data_i[i][`PRF_IDX_W-1:0];		// Assigned by the wrong copy
						next_RDY[i] = rc_mt_all_data_i[i][`PRF_IDX_W];
					end
				end
			endcase
			next_RDY[31] = 1; // edited by hengfei ZERO_REG is always ready
		end

		always_comb begin					// Find index by cdb's tag
			cdb_match_index = 0;
			cdb_match_found = 0;
			if(cdb_set_rdy_bit_en_i) begin
				for (int i=0;i<`MT_NUM;i++) begin
					if (MAP[i] == cdb_set_rdy_bit_preg_i) begin
						cdb_match_index = i;
						cdb_match_found = 1;
						break;
					end
				end
			end
		end

		always_ff@(posedge clk) begin								// Use for loop going over through every registers to make sequential assignments
			if (rst) begin
				for (int i=0; i<`MT_NUM; i++) begin
					MAP[i] <= `SD i;
					RDY[i] <= `SD 1;
				end
			end else begin
				for (int i=0; i<`MT_NUM; i++) begin
					MAP[i] <= `SD next_MAP[i];
					RDY[i] <= `SD next_RDY[i];
				end
			end
		end
		
endmodule
