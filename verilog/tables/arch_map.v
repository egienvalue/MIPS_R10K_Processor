// ****************************************************************************
// Filename: arch_map.v
// Discription: Architectural Map
//				One case only: 1. Retire
//								  Update corresponding physical reg. 
// Author: Chuan Cen
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************


module arch_map(
		input			rst,
		input			clk,				//|From where|
		input			retire_en_i,		//[ROB]	If true, replace some preg with a new one.
		input	[5:0]	retire_preg_i,		//[ROB] New preg.
		input	[4:0]	retire_areg_idx_i,	//[ROB]	The index of the target logic reg to which the new preg is written.
		input	[4:0]	read_idx_i, 

		output	[5:0]	read_data_o
		);

		logic [31:0][5:0] AMAP;

		assign read_data_o = AMAP[read_idx_i];

		always_ff @(posedge clk) begin
			if (rst) begin
				for (int i=0;i<32;i++) begin
					AMAP[i] <= `SD i;
				end
			end else if (retire_en_i) begin
				AMAP[retire_areg_idx_i] <= `SD retire_preg_i;
			end
		end
endmodule
