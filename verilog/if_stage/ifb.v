// ****************************************************************************
// Filename: ifb.v
// Discription: instruction fetch buffer
// Author: Shijing
// Version History:
// 	intial creation: 10/26/2017
// 	<11/11> added target_PC_r for storage
// 	<11/13> added prediction bit for bp for storage
// 	***************************************************************************

module ifb(
		input	clk,
		input	rst,
		input	ifb_en_i,
		input	[31:0]	if_insn_i,
		input	[63:0]	if_PC_i,
		input	[63:0]	if_target_PC_i,
		input	flush_en_i,//branch flush signal
		input	decode_en_i,//
		input	bp2if_pred_bit_i,

		output	logic	ifb_2if_full_o,
		output	logic	ifb_2id_empty_o,
		output	logic	[31:0]	ifb_insn_o,
		output	logic	[63:0]	ifb_PC_o,
		output	logic	[63:0]	ifb_target_PC_o,
		output  logic			ifb_pred_bit_o
	);

	logic	[(`TAG_SIZE-1):0]	ifb_head;
	logic	[(`TAG_SIZE-1):0]	ifb_tail;
	logic	[(`TAG_SIZE-1):0]	ifb_head_nxt;
	logic	[(`TAG_SIZE-1):0]	ifb_tail_nxt;
	logic	h_round, h_round_nxt;
	logic	t_round, t_round_nxt;

	logic	[`IFB_SIZE-1:0][63:0] PC_array;
	logic	[`IFB_SIZE-1:0][31:0] insn_array;
	logic	[`IFB_SIZE-1:0][63:0] target_PC_r;
	logic	[`IFB_SIZE-1:0]		  pred_bit_r;

	//logic	[`IFB_SIZE-1:0][63:0] PC_array_nxt;
	//logic	[`IFB_SIZE-1:0][31:0] insn_array_nxt;

	//logic	direct;
	
	//assign direct = ifb_2id_empty_o && ifb_en_i && decode_en_i;

	//fetch stage to insn fetch buffer

	//insn fetch buffer to decode stage	<12/2: decode_en_i add here may cause the timing loop>
	assign ifb_PC_o			= PC_array[ifb_head];//~decode_en_i ? 0 : PC_array[ifb_head];
	assign ifb_insn_o		= insn_array[ifb_head];//~decode_en_i ? 0 : insn_array[ifb_head];
	assign ifb_target_PC_o	= target_PC_r[ifb_head];
	assign ifb_pred_bit_o 	= pred_bit_r[ifb_head];

	assign ifb_2id_empty_o = ((ifb_head == ifb_tail) && (h_round == t_round));
	assign ifb_2if_full_o  = ((ifb_tail == ifb_head) && (h_round != t_round));

	//head & tail pointer
	assign ifb_head_nxt = (~decode_en_i) ? ifb_head :
						  (ifb_head == (`IFB_SIZE-1)) ? 0 : ifb_head+1;
	assign ifb_tail_nxt = (~ifb_en_i) ? ifb_tail :
						  (ifb_tail == (`IFB_SIZE-1)) ? 0 : ifb_tail+1;


	assign h_round_nxt = (decode_en_i && (ifb_head == (`IFB_SIZE-1)))? ~h_round : h_round;
	assign t_round_nxt = (  ifb_en_i  && (ifb_tail == (`IFB_SIZE-1)))? ~t_round : t_round;



	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if(rst) begin
			ifb_head	<= `SD 0;
			ifb_tail	<= `SD 0;
			h_round		<= `SD 0;
			t_round		<= `SD 0;
			PC_array	<= `SD {`IFB_SIZE{64'h0}};
			insn_array	<= `SD {`IFB_SIZE{32'h0}};
			target_PC_r	<= `SD {`IFB_SIZE{64'h0}};
			pred_bit_r	<= `SD `IFB_SIZE'b0;
		end else begin
			if (flush_en_i) begin
				ifb_head	<= `SD 0;
				ifb_tail	<= `SD 0;
				h_round		<= `SD 0;
				t_round		<= `SD 0;
				PC_array	<= `SD {`IFB_SIZE{64'h0}};
				insn_array	<= `SD {`IFB_SIZE{32'h0}};
				target_PC_r	<= `SD {`IFB_SIZE{64'h0}};
			end else begin
				ifb_head <= `SD ifb_head_nxt;
				ifb_tail <= `SD ifb_tail_nxt;
				h_round  <= `SD h_round_nxt;
				t_round  <= `SD t_round_nxt;
				if(ifb_en_i) begin
					PC_array[ifb_tail]   <= `SD if_PC_i;
					insn_array[ifb_tail] <= `SD if_insn_i;
					target_PC_r[ifb_tail]<= `SD if_target_PC_i;
					pred_bit_r[ifb_tail] <= `SD bp2if_pred_bit_i;
				end
			end
		end
	end

	

endmodule










