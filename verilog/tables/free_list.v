// ****************************************************************************
// Filename: free_list.v
// Discription: Free List
//				Four cases: 1. read
//								Output head immediately. Head++.
//							2. write
//								Write to tail sequentially. Tail++.
//							3. read & write & status==empty
//								Read takes writing value and output immediately.
//								Head&tail remain unmoved.
//							4. restore
//								Move head back to some point. 
// Author: Chuan Cen
// Version History:
// 	intial creation: 10/17/2017
// 	***************************************************************************

module free_list(
		input			clk,
		input			rst,					//|From where|
		input			dispatch_en_i,			//[Decoder]		If true, output head entry and head++
		input			retire_en_i,			//[ROB]			If true, write new retired preg to tail, and tail++
		input			retire_preg_i,			//[ROB]			New retired preg.
		input			recover_en_i,			//[ROB]			Enabling early branch single cycle recovery
		input	[4:0]	recover_head_i,			//[ROB]			Recover head to some point

												//|To where|
		output			free_preg_vld_o,		//[ROB, Map Table, RS]	Is output valid?
		output	[5:0]	free_preg_o,			//[ROB, Map Table, Rs]	Output new free preg.
		output	[4:0]	free_preg_cur_head_o	//[ROB]			Current head pointer.
		);
		
		logic	[31:0][5:0]	FL;
		logic	[4:0] count;
		logic	head,tail;
		logic	full,empty;

		assign empty = (count == 0);
		assign full = (count >= 5'b11111);

		assign free_preg_vld_o	=	~dispatch_en_i	? 0 : 
									~empty			? 1 : 
									retire_en_i		? 1 : 0;

		assign free_preg_o		=	~dispatch_en_i	? 6'b000000		: 
									~empty			? FL[head]		:
									retire_en_i		? retire_preg_i : 0;

		assign free_preg_cur_head_o = dispatch_en_i ? head : 5'b00000;

		//write FL and tail
		always_ff @(posedge clk) begin
			if (rst) begin
				for (int i=0;i<32;i++) begin
					FL[i] <= `SD 0;
				end
				tail <= `SD 0;
			end else if (retire_en_i && ~(empty && dispatch_en_i) && ~full) begin
				tail	 <=	(tail + 1 >= 5'b11111) ? tail + 1 - 5'b11111 : tail + 1;
				FL[tail] <= `SD retire_preg_i;
			end else begin
				tail <= `SD tail;
			end
		end
		
		//write head
		always_ff @(posedge clk) begin
			if (rst) begin
				head <= `SD 0;
			end else if (dispatch_en_i && ~empty) begin
				head <= `SD (head + 1 >= 5'b11111) ? head + 1 - 5'b11111 : head + 1;
			end else if (recover_en_i) begin
				head <= `SD recover_head_i;
			end else begin
				head <= `SD head;
			end
		end

		//write count
		always_ff @(posedge clk) begin
			if (rst) begin
				count <= `SD 0;
			end else if (dispatch_en_i && ~retire_en_i) begin
				count <= `SD count - 1;
			end else if (~dispatch_en_i && retire_en_i) begin
				count <= `SD count + 1;
			end else begin
				count <= `SD count;
			end
		end

endmodule
