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
//								*Still need to figure out how. Added dump
//								inputs for future recovery design anyway. 
// Author: Chuan Cen
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************
//


module map_table(
		input			clk,
		input			rst,						//|From where|									
		input	[4:0]	opa_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand A from map table.
		input	[4:0]	opb_areg_idx_i,				//[Decoder]		A logic register index to read the physical register name and ready bit of oprand B from map table.
		input	[4:0]	dest_areg_idx_i,			//[Decoder]		A logic register index to read the old dest physical reg, and to write a new dest physical reg.
		input	[5:0]	new_free_preg_i,			//[Free-List]	New physical register name from Free List.
		input			dispatch_en_i,				//[Decoder]		Enabling all inputs above. 
		input	[5:0]	cdb_set_RDYit_preg_i,		//[CDB]			A physical reg from CDB to set ready bit of corresponding logic reg in map table.
		input			cdb_set_RDYit_en_i,			//[CDB]			Enabling setting ready bit. 
		input	[31:0][5:0] preg_restore_dump_i,	//[??]			Dump check-point copy from somewhere when early branch single cycle recovery.
		input			preg_restore_dump_en_i,		//[ROB]			Enabling dumping.
													
													//|To where|
		output	[5:0]	opa_preg_o,					//[RS]			Oprand A physical reg output.
		output	[5:0]	opb_preg_o,					//[RS]			Oprand B physical reg output.
		output			opa_preg_RDYit_o,			//[RS]			Oprand A physical reg ready bit output. 
		output			opb_preg_RDYit_o,			//[RS]			Oprand B physical reg ready bit output.
		output	[5:0]	dest_old_preg_o				//[ROB]			Old dest physical reg output. 
		);

		logic	[31:0][5:0]		MAP;
		logic	[31:0]			RDY;
		logic	[4:0]			cdb_match_index;

		assign opa_preg_o = dispatch_en_i ? MAP[opa_areg_idx_i]: 6'b000000;
		assign opb_preg_o = dispatch_en_i ? MAP[opb_areg_idx_i]: 6'b000000;
		assign opa_preg_RDYit_o = dispatch_en_i ? cdb_match_index==opa_areg_idx_i ? 1 : RDY[opa_areg_idx_i] : 0;
		assign opb_preg_RDYit_o = dispatch_en_i ? cdb_match_index==opb_areg_idx_i ? 1 : RDY[opb_areg_idx_i] : 0;
		assign dest_old_preg_o = dispatch_en_i ? MAP[dest_areg_idx_i] : 6'b000000;

		always_ff@(posedge clk) begin
			if (rst) begin
				for (int i=0; i<32; i++) begin
					MAP[i] <= `SD i;
					RDY[i] <= `SD 1;
				end
			end else if (preg_restore_dump_en_i) begin
				for (int i=0; i<32;i++) begin
					MAP[i] <= `SD preg_restore_dump_i[i];
					RDY[i] <= `SD 1;		
				end
			end else 
				if (dispatch_en_i) begin
					MAP[dest_areg_idx_i] <= `SD new_free_preg_i;
					RDY[dest_areg_idx_i] <= `SD 0;
				end else begin
				end
				if (cdb_set_RDYit_en_i && cdb_match_index!=0) begin
					RDY[cdb_match_index] <= `SD 1;
				end else begin
				end
			end
		end
		
		always_comb begin
			cdb_match_index = 0;
			if(cdb_set_RDYit_en_i) begin
				for (int i=0;i<32;i++) begin
					if (MAP[i] == cdb_set_RDYit_preg_i) begin
						cdb_match_index = i;
					end
				end
			end
		end

endmodule
