// ****************************************************************************
// Filename: rob.v
// Discription: reorder buffer
// Author: Jun, Shijing
// Version History: add early recovery 
// 	intial creation: 10/17/2017
// 	<11/11> added IR and vld bit fields in rob - Hengfei
// 	<12/1>  added output rob_head_st_instr_o, for SQ
// 	<12/1>  added br_recovery_mark_r for only one cycle br_recovery signal
// 	***************************************************************************


//`define DEBUG_OUT

module	rob (
		input					clk,
		input					rst,

		// port for writeback in tb <12/6>
		output	logic	[63:0]							retire_PC_tb_o,
		output	logic	[`LRF_IDX_W-1:0]				retire_areg_tb_o,
		output	logic	[`PRF_IDX_W-1:0]				retire_preg_tb_o,
		output	logic									retire_rdy_tb_o,

		//----------------------------------------------------------------------
		//Dispatch Signal Input
		//----------------------------------------------------------------------
		input		[`PRF_IDX_W-1:0]		fl2rob_tag_i,//tag sent from freelist
		input		[`PRF_IDX_W-2:0]		fl2rob_cur_head_i,//freelist head
		input		[`PRF_IDX_W-1:0]		map2rob_tag_i,//tag sent from maptable
		input		[`PRF_IDX_W-2:0]		decode2rob_logic_dest_i,//logic dest sent from decode
		input		[63:0]					decode2rob_PC_i,//PC sent from decode
		input								decode2rob_br_flag_i,//flag show whether the instruction is a branch
		input								decode2rob_br_pretaken_i,//branch predictor result sent from decode
		input		[63:0]					decode2rob_br_target_i,//branch target sent from decode 
		input								decode2rob_rd_mem_i,//flag shows whether this instruction read memory
		input								decode2rob_wr_mem_i,//flag shows whether this instruction write memory
		input								rob_dispatch_en_i,//signal from dispatch to allocate entry in rob
		input		[`BR_MASK_W-1:0]		decode2rob_br_mask_i,
        input                               id2rob_halt_i,
        input                               id2rob_illegal_i,
		input		[31:0]					id2rob_IR_i,

		//----------------------------------------------------------------------
		//Functional Unit Signal Input
		//----------------------------------------------------------------------
		input		[`ROB_IDX_W:0]			fu2rob_idx_i,//tag sent from functional unit to know which entry's done register needed to be set 
		input								fu2rob_done_signal_i,//done signal from functional unit 
		input								fu2rob_br_taken_i,//branck taken result sent from functional unit
        //input       [63:0]                  fu2rob_br_target_i,//br_target sent from fu

		input								br_recovery_taken_i,
		input		[63:0]					br_recovery_target_i,
		input		[`ROB_IDX_W:0]			br_recovery_idx_i,
		input								br_recovery_done_i,

        input       [`ROB_IDX_W:0]        	rs2rob_rd_idx_i,// rs sent read index to rob for reading NPC
        output      [63:0]                  rob2fu_rd_NPC_o,//!!!rob sent the NPC data to fu

		output		[`HT_W:0]				rob2rs_tail_idx_o,//tail # sent to rs to record which entry the instruction is 
		output		[`PRF_IDX_W-1:0]		rob2fl_tag_o,//tag from ROB to freelist for returning the old tag to freelist 
		output		[`PRF_IDX_W-1:0]		rob2arch_map_tag_o,//tag from ROB to Arch map
		output		[`PRF_IDX_W-2:0]		rob2arch_map_logic_dest_o,//logic dest from ROB to Arch map
		output								rob_stall_dp_o,//signal show if the ROB is full
		output								rob_head_retire_rdy_o,//the head of ROb is ready to retire
		output								rob_head_st_instr_o,
		output		[`ROB_IDX_W:0]			rob_head_o,
		//12.02
		output	logic						rob2lsq_st_retire_en_o,
		//----------------------------------------------------------------------
		//Early Recovery Signal Ouput
		//----------------------------------------------------------------------
		output	logic						br_recovery_rdy_o,//ready to start early branch recovery
		output	logic	[`PRF_IDX_W-2:0]	rob2fl_recover_head_o,
		output	logic	[`BR_MASK_W-1:0]	br_recovery_mask_o,
        output  logic                       br_right_o,

        output  logic                       rob_halt_o,
        output  logic                       rob_illegal_o
	
		//----------------------------------------------------------------------
		//ROB data output for debug
		//---------------------------------------------------------------------
		
		`ifdef	DEBUG_OUT
		
		,output logic	[`HT_W:0]			            head_o,
		output logic	[`HT_W:0]			            tail_o,
		output logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag_o, 
		output logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	dest_tag_o,
		output logic	[`ROB_W-1:0]		            done_o,
		output logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest_o,
		output logic	[`ROB_W-1:0][63:0]	            PC_o,
		output logic	[`ROB_W-1:0]		            br_flag_o,
		output logic	[`ROB_W-1:0]		            br_taken_o,
		output logic	[`ROB_W-1:0]		            br_pretaken_o,
		output logic	[`ROB_W-1:0][63:0]	            br_target_o,
		output logic	[`ROB_W-1:0][`BR_MASK_W-1:0]	br_mask_o,
		output logic	[`ROB_W-1:0]		            wr_mem_o,
		output logic	[`ROB_W-1:0]		            rd_mem_o,
		output logic	[4:0]				            fl_cur_head_o
		
	   	//,output debug_t debug_o
		`endif


	);

	//--------------------------------------------------------------------------
	//Register storing the data of ROB
	//--------------------------------------------------------------------------
	logic	[`ROB_W-1:0]					vld_r;
	logic	[`HT_W:0]						head_r;
	logic	[`HT_W:0]						tail_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	old_dest_tag_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-1:0]	dest_tag_r;
	logic	[`ROB_W-1:0]					done_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	logic_dest_r;
	logic	[`ROB_W-1:0][63:0]				PC_r;
	logic	[`ROB_W-1:0]					br_flag_r;
	logic	[`ROB_W-1:0]					br_taken_r;
	logic	[`ROB_W-1:0]					br_pretaken_r;
	logic	[`ROB_W-1:0][63:0]				br_target_r;
	logic	[`ROB_W-1:0]					wr_mem_r;
	logic	[`ROB_W-1:0]					rd_mem_r;
	logic	[`ROB_W-1:0][`PRF_IDX_W-2:0]	fl_cur_head_r;
	logic	[`ROB_W-1:0][`BR_MASK_W-1:0]	br_mask_r;
    logic   [`ROB_W-1:0]                    halt_r;
    logic   [`ROB_W-1:0]                    illegal_r;
	logic	[`ROB_W-1:0][31:0]				IR_r;

	//--------------------------------------------------------------------------
	//Register for updating the head and tail
	//--------------------------------------------------------------------------
    logic                       t_halt_r_nxt;
    logic                       t_illegal_r_nxt;
    logic                       h_halt_r_nxt;
    logic                       h_illegal_r_nxt;

	// added by hengfei 11/11
	logic	[31:0]				t_IR_r_nxt;
	logic						t_vld_r_nxt;
	logic	[31:0]				h_IR_r_nxt;
	logic						h_vld_r_nxt;

	logic	[`PRF_IDX_W-2:0]	t_fl_cur_head_r_nxt;
	logic	[`PRF_IDX_W-2:0]	h_fl_cur_head_r_nxt;	

	logic	[`BR_MASK_W-1:0]	t_br_mask_r_nxt;
	logic	[63:0]				t_br_target_r_nxt;
	logic						t_br_pretaken_r_nxt;
	logic						t_br_flag_r_nxt;
	logic						t_br_taken_r_nxt;

	logic	[`BR_MASK_W-1:0]	h_br_mask_r_nxt;
	logic						h_br_flag_r_nxt;
	logic						h_br_taken_r_nxt;
	logic						h_br_pretaken_r_nxt;
	logic	[63:0]				h_br_target_r_nxt;

	logic	[`HT_W:0]			head_r_nxt;
	logic	[`HT_W:0]			tail_r_nxt;
	logic	[`PRF_IDX_W-1:0]	h_old_dest_tag_r_nxt, h_dest_tag_r_nxt;
	logic						h_done_r_nxt;
	logic	[`PRF_IDX_W-2:0]	h_logic_dest_r_nxt;
	logic	[63:0]				h_PC_r_nxt;
	logic						h_rd_mem_r_nxt;
	logic						h_wr_mem_r_nxt;

	logic	[`PRF_IDX_W-1:0]	t_old_dest_tag_r_nxt, t_dest_tag_r_nxt;
	logic	[`PRF_IDX_W-2:0]	t_logic_dest_r_nxt;
	logic	[63:0]				t_PC_r_nxt;
	logic						t_rd_mem_r_nxt;
	logic						t_wr_mem_r_nxt;
	logic						t_done_r_nxt;

	logic						fu_br_taken_r_nxt;
	logic						fu_done_r_nxt;

	logic						br_recovery_mark_r; // <12/1>
	
	wire 						dispatch_en;
	// <11/14>
	wire 						br_predict_wrong;

	
	// <12/6> ports for writeback
	assign retire_PC_tb_o	= PC_r[head_r[`HT_W-1:0]];
	assign retire_areg_tb_o	= logic_dest_r[head_r[`HT_W-1:0]];
	assign retire_preg_tb_o	= dest_tag_r[head_r[`HT_W-1:0]];
	assign retire_rdy_tb_o	= rob_head_retire_rdy_o;

	assign dispatch_en					= rob_dispatch_en_i;
	// <11/14>
	assign br_predict_wrong				= ((br_pretaken_r[br_recovery_idx_i[`ROB_IDX_W-1:0]] != br_recovery_taken_i) |
										  (br_recovery_target_i != br_target_r[br_recovery_idx_i[`ROB_IDX_W-1:0]]));

	assign rob2rs_tail_idx_o			= tail_r;
	assign rob2fl_tag_o					= rob_head_retire_rdy_o ? old_dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_tag_o			= rob_head_retire_rdy_o ? dest_tag_r[head_r[`HT_W-1:0]]	: 0;
	assign rob2arch_map_logic_dest_o	= rob_head_retire_rdy_o ? logic_dest_r[head_r[`HT_W-1:0]] : 0;
	assign rob_head_retire_rdy_o 		= (done_r[head_r[`HT_W-1:0]]==1) && (head_r!=tail_r);
	assign rob_head_st_instr_o			= wr_mem_r[head_r[`HT_W-1:0]];
	assign rob_head_o					= head_r;
	assign rob_stall_dp_o				= ((head_r^tail_r)==6'b100000)&&(~rob_head_retire_rdy_o);
    assign rob_halt_o                   = halt_r[head_r[`HT_W-1:0]] && (head_r!=tail_r);
    assign rob_illegal_o                = illegal_r[head_r[`HT_W-1:0]] && (head_r!=tail_r);
	assign head_r_nxt					= rob_head_retire_rdy_o ? (head_r+1) : head_r;
	assign tail_r_nxt 					= br_recovery_rdy_o ? (br_recovery_idx_i+1) : dispatch_en ? (tail_r+1) : tail_r;

    assign rob2fu_rd_NPC_o              = PC_r[rs2rob_rd_idx_i[`ROB_IDX_W-1:0]]+4; //sent the NPC to branch alu to calculate the branch target

	always_comb begin
		br_recovery_mask_o  = br_mask_r[br_recovery_idx_i[`ROB_IDX_W-1:0]];
		rob2fl_recover_head_o = fl_cur_head_r[br_recovery_idx_i[`ROB_IDX_W-1:0]];
		if(br_flag_r[br_recovery_idx_i[`ROB_IDX_W-1:0]]&br_recovery_done_i)
			if(br_predict_wrong) begin
                br_right_o          = 0;
                //rob2fl_recover_head_o = fl_cur_head_r[br_recovery_idx_i[`ROB_IDX_W-1:0]];
				br_recovery_rdy_o   = br_recovery_mark_r; // depends on mark <12/1>
			end else begin
                br_right_o          = 1;
                //rob2fl_recover_head_o = 0;
				br_recovery_rdy_o   = 0;
			end
		else begin
            br_right_o          = 0;
			br_recovery_rdy_o   = 0;
            //rob2fl_recover_head_o = 0;
		end
	end

	always_comb begin
		if (head_r[`HT_W-1:0]==tail_r[`HT_W-1:0])begin
			if (dispatch_en) begin
				t_old_dest_tag_r_nxt 		= map2rob_tag_i; 
				t_dest_tag_r_nxt 			= fl2rob_tag_i;
				t_logic_dest_r_nxt 			= decode2rob_logic_dest_i;
				t_PC_r_nxt					= decode2rob_PC_i;
				t_br_pretaken_r_nxt			= decode2rob_br_pretaken_i;
				t_br_taken_r_nxt			= 1'b0;
				t_br_flag_r_nxt				= decode2rob_br_flag_i;
				t_br_target_r_nxt			= decode2rob_br_target_i;
				t_br_mask_r_nxt				= decode2rob_br_mask_i;
				t_fl_cur_head_r_nxt			= fl2rob_cur_head_i;
				t_rd_mem_r_nxt				= decode2rob_rd_mem_i;
				t_wr_mem_r_nxt				= decode2rob_wr_mem_i;
                t_halt_r_nxt                = id2rob_halt_i;
                t_illegal_r_nxt             = id2rob_illegal_i;
				t_IR_r_nxt					= id2rob_IR_i;
				t_vld_r_nxt					= 1'b1;
				t_done_r_nxt				= 1'b0;
			end else begin
				t_old_dest_tag_r_nxt 		= h_old_dest_tag_r_nxt;
				t_dest_tag_r_nxt 			= h_dest_tag_r_nxt;
				t_logic_dest_r_nxt 			= h_logic_dest_r_nxt;  
				t_PC_r_nxt					= h_PC_r_nxt;		
				t_br_pretaken_r_nxt			= h_br_pretaken_r_nxt;
				t_br_taken_r_nxt			= h_br_taken_r_nxt;		
				t_br_flag_r_nxt				= h_br_flag_r_nxt;			
				t_br_target_r_nxt			= h_br_target_r_nxt;		
				t_br_mask_r_nxt				= h_br_mask_r_nxt;			
				t_fl_cur_head_r_nxt			= h_fl_cur_head_r_nxt;		
				t_rd_mem_r_nxt				= h_rd_mem_r_nxt;			
				t_wr_mem_r_nxt				= h_wr_mem_r_nxt;
                t_halt_r_nxt                = h_halt_r_nxt;
                t_illegal_r_nxt             = h_illegal_r_nxt;
				t_IR_r_nxt					= h_IR_r_nxt;
				t_vld_r_nxt					= h_vld_r_nxt;
				t_done_r_nxt				= h_done_r_nxt;
			end
		end else begin
			if (dispatch_en) begin
				t_old_dest_tag_r_nxt 		= map2rob_tag_i; 
				t_dest_tag_r_nxt 			= fl2rob_tag_i;
				t_logic_dest_r_nxt 			= decode2rob_logic_dest_i;
				t_PC_r_nxt					= decode2rob_PC_i;
				t_br_pretaken_r_nxt			= decode2rob_br_pretaken_i;
				t_br_taken_r_nxt			= 1'b0;
				t_br_flag_r_nxt				= decode2rob_br_flag_i;
				t_br_target_r_nxt			= decode2rob_br_target_i;
				t_br_mask_r_nxt				= decode2rob_br_mask_i;
				t_fl_cur_head_r_nxt			= fl2rob_cur_head_i;
				t_rd_mem_r_nxt				= decode2rob_rd_mem_i;
				t_wr_mem_r_nxt				= decode2rob_wr_mem_i;
                t_halt_r_nxt                = id2rob_halt_i;
                t_illegal_r_nxt             = id2rob_illegal_i;
				t_IR_r_nxt					= id2rob_IR_i;
				t_vld_r_nxt					= 1'b1;
				t_done_r_nxt				= 1'b0;
			end else begin
				t_old_dest_tag_r_nxt  		= old_dest_tag_r[tail_r[`HT_W-1:0]];	
				t_dest_tag_r_nxt 	 		= dest_tag_r[tail_r[`HT_W-1:0]];   	
				t_logic_dest_r_nxt 	 		= logic_dest_r[tail_r[`HT_W-1:0]];   	
				t_PC_r_nxt			 		= PC_r[tail_r[`HT_W-1:0]];   	
				t_br_pretaken_r_nxt	 		= br_pretaken_r[tail_r[`HT_W-1:0]];
				t_br_taken_r_nxt			= br_taken_r[tail_r[`HT_W-1:0]];	
				t_br_flag_r_nxt		 		= br_flag_r[tail_r[`HT_W-1:0]];   	
				t_br_target_r_nxt	 		= br_target_r[tail_r[`HT_W-1:0]];   	
				t_br_mask_r_nxt		 		= br_mask_r[tail_r[`HT_W-1:0]];   	
				t_fl_cur_head_r_nxt	 		= fl_cur_head_r[tail_r[`HT_W-1:0]];   	
				t_rd_mem_r_nxt		 		= rd_mem_r[tail_r[`HT_W-1:0]];   	
				t_wr_mem_r_nxt		 		= wr_mem_r[tail_r[`HT_W-1:0]];
                t_halt_r_nxt                = halt_r[tail_r[`HT_W-1:0]];
                t_illegal_r_nxt             = illegal_r[tail_r[`HT_W-1:0]];
  				t_IR_r_nxt					= IR_r[tail_r[`HT_W-1:0]];
				t_vld_r_nxt					= vld_r[tail_r[`HT_W-1:0]];
				t_done_r_nxt				= done_r[tail_r[`HT_W-1:0]];
			end
		end
	end

	always_comb begin
		if(rob_head_retire_rdy_o) begin
			h_old_dest_tag_r_nxt		= 6'd31;
            h_dest_tag_r_nxt			= 6'd31;
            h_logic_dest_r_nxt			= 5'd31;
            h_done_r_nxt				= 0;
            h_PC_r_nxt					= 0;
            h_br_flag_r_nxt				= 0;
            h_br_taken_r_nxt			= 0;
            h_br_pretaken_r_nxt			= 0;
            h_br_target_r_nxt			= 0;
            h_br_mask_r_nxt				= 0;
            h_fl_cur_head_r_nxt			= 0;
            h_rd_mem_r_nxt				= 0;
		    h_wr_mem_r_nxt				= 0;
            h_halt_r_nxt                = 0;
            h_illegal_r_nxt             = 0;
			h_IR_r_nxt					= 0;
			h_vld_r_nxt					= 0;
		end else begin
			h_old_dest_tag_r_nxt		= old_dest_tag_r[head_r[`HT_W-1:0]]; 
            h_dest_tag_r_nxt			= dest_tag_r[head_r[`HT_W-1:0]];
            h_logic_dest_r_nxt			= logic_dest_r[head_r[`HT_W-1:0]];
            h_done_r_nxt				= done_r[head_r[`HT_W-1:0]];
            h_PC_r_nxt					= PC_r[head_r[`HT_W-1:0]];
            h_br_flag_r_nxt				= br_flag_r[head_r[`HT_W-1:0]];
            h_br_taken_r_nxt			= br_taken_r[head_r[`HT_W-1:0]];
            h_br_pretaken_r_nxt			= br_pretaken_r[head_r[`HT_W-1:0]];
            h_br_target_r_nxt			= br_target_r[head_r[`HT_W-1:0]];
            h_br_mask_r_nxt				= br_mask_r[head_r[`HT_W-1:0]];
            h_fl_cur_head_r_nxt			= fl_cur_head_r[head_r[`HT_W-1:0]];
            h_rd_mem_r_nxt				= rd_mem_r[head_r[`HT_W-1:0]];
		    h_wr_mem_r_nxt				= wr_mem_r[head_r[`HT_W-1:0]];
            h_halt_r_nxt                = halt_r[head_r[`HT_W-1:0]];
            h_illegal_r_nxt             = illegal_r[head_r[`HT_W-1:0]];
			h_IR_r_nxt					= IR_r[head_r[`HT_W-1:0]];
			h_vld_r_nxt					= vld_r[head_r[`HT_W-1:0]];
		end
	end

/*	always_comb begin
		if(fu2rob_done_signal_i) begin
			fu_done_r_nxt				= 1;
            fu_br_taken_r_nxt			= fu2rob_br_taken_i;
		end else if(fu2rob_idx_i[`ROB_IDX_W-1:0]==head_r[`HT_W-1:0]) begin
			fu_done_r_nxt				= h_done_r_nxt;
			fu_br_taken_r_nxt			= h_br_taken_r_nxt;
		end else if(fu2rob_idx_i[`ROB_IDX_W-1:0]==tail_r[`HT_W-1:0]) begin
			fu_done_r_nxt				= t_done_r_nxt;
			fu_br_taken_r_nxt			= t_br_taken_r_nxt;
		end	else begin
			fu_done_r_nxt				= done_r[fu2rob_idx_i[`ROB_IDX_W-1:0]];
			fu_br_taken_r_nxt			= br_taken_r[fu2rob_idx_i[`ROB_IDX_W-1:0]];
		end
	end
*/

	`ifdef DEBUG_OUT
	
	always_comb begin
		head_o			= head_r;
		tail_o			= tail_r;
		old_dest_tag_o  = old_dest_tag_r;
		dest_tag_o		= dest_tag_r;
		done_o			= done_r;
		logic_dest_o	= logic_dest_r;
		PC_o			= PC_r;
		br_flag_o		= br_flag_r;
		br_taken_o		= br_taken_r;
		br_pretaken_o	= br_pretaken_r;
		br_target_o		= br_target_r;
		br_mask_o		= br_mask_r;
		wr_mem_o		= wr_mem_r;
		rd_mem_o		= rd_mem_r;
		fl_cur_head_o   = fl_cur_head_r;

	end
	
	`endif

	// <12/1>
	// synopsys sync_set_reset "rst"
	always_ff @(posedge clk) begin
		if (rst) begin
			br_recovery_mark_r	<= `SD 1'b1;
		end else begin
			if (br_recovery_rdy_o)
				br_recovery_mark_r	<= `SD 1'b0;
			else 
				br_recovery_mark_r	<= `SD 1'b1;
		end
	end



	always_ff @(posedge clk) begin
		if (rst) begin
			head_r			<= `SD 0;
			tail_r			<= `SD 0;
			old_dest_tag_r	<= `SD {`ROB_W{6'd31}};
			dest_tag_r		<= `SD {`ROB_W{6'd31}};
			logic_dest_r	<= `SD {`ROB_W{5'd31}};
			done_r			<= `SD 0;
			PC_r			<= `SD 0;
			br_flag_r		<= `SD 0;
			br_taken_r		<= `SD 0;
			br_pretaken_r	<= `SD 0;
			br_target_r		<= `SD 0;
			br_mask_r		<= `SD 0;
			rd_mem_r		<= `SD 0;
			wr_mem_r		<= `SD 0;
			fl_cur_head_r	<= `SD 0;
			halt_r			<= `SD 0;
			illegal_r		<= `SD 0;
			IR_r			<= `SD {`ROB_W{32'h0}};
			vld_r			<= `SD 0;
		end else begin
			head_r								<= `SD head_r_nxt;
			tail_r								<= `SD tail_r_nxt;
			
			old_dest_tag_r[head_r[`HT_W-1:0]]	<= `SD h_old_dest_tag_r_nxt;
			dest_tag_r[head_r[`HT_W-1:0]]		<= `SD h_dest_tag_r_nxt;
			logic_dest_r[head_r[`HT_W-1:0]]		<= `SD h_logic_dest_r_nxt;
			PC_r[head_r[`HT_W-1:0]]				<= `SD h_PC_r_nxt;
			done_r[head_r[`HT_W-1:0]]			<= `SD h_done_r_nxt;
			fl_cur_head_r[head_r[`HT_W-1:0]]	<= `SD h_fl_cur_head_r_nxt;
			br_flag_r[head_r[`HT_W-1:0]]		<= `SD h_br_flag_r_nxt;
			br_taken_r[head_r[`HT_W-1:0]]		<= `SD h_br_taken_r_nxt;
			br_pretaken_r[head_r[`HT_W-1:0]]	<= `SD h_br_pretaken_r_nxt;
			br_target_r[head_r[`HT_W-1:0]]		<= `SD h_br_target_r_nxt;
			br_mask_r[head_r[`HT_W-1:0]]		<= `SD h_br_mask_r_nxt;
			wr_mem_r[head_r[`HT_W-1:0]]			<= `SD h_wr_mem_r_nxt;
			rd_mem_r[head_r[`HT_W-1:0]]			<= `SD h_rd_mem_r_nxt;
            halt_r[head_r[`HT_W-1:0]]           <= `SD h_halt_r_nxt;
            illegal_r[head_r[`HT_W-1:0]]        <= `SD h_illegal_r_nxt;
			IR_r[head_r[`HT_W-1:0]]				<= `SD h_IR_r_nxt;
			vld_r[head_r[`HT_W-1:0]]			<= `SD h_vld_r_nxt;
				
			old_dest_tag_r[tail_r[`HT_W-1:0]]	<= `SD t_old_dest_tag_r_nxt;
			dest_tag_r[tail_r[`HT_W-1:0]]		<= `SD t_dest_tag_r_nxt;
			logic_dest_r[tail_r[`HT_W-1:0]]		<= `SD t_logic_dest_r_nxt;
			PC_r[tail_r[`HT_W-1:0]]				<= `SD t_PC_r_nxt;
			br_taken_r[tail_r[`HT_W-1:0]]		<= `SD t_br_taken_r_nxt;
			br_pretaken_r[tail_r[`HT_W-1:0]]	<= `SD t_br_pretaken_r_nxt;
			br_flag_r[tail_r[`HT_W-1:0]]		<= `SD t_br_flag_r_nxt;
			br_target_r[tail_r[`HT_W-1:0]]		<= `SD t_br_target_r_nxt;
			br_mask_r[tail_r[`HT_W-1:0]]		<= `SD t_br_mask_r_nxt;
			rd_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_rd_mem_r_nxt;
			wr_mem_r[tail_r[`HT_W-1:0]]			<= `SD t_wr_mem_r_nxt;
			fl_cur_head_r[tail_r[`HT_W-1:0]]	<= `SD t_fl_cur_head_r_nxt;
            halt_r[tail_r[`HT_W-1:0]]           <= `SD t_halt_r_nxt;
            illegal_r[tail_r[`HT_W-1:0]]        <= `SD t_illegal_r_nxt;
			IR_r[tail_r[`HT_W-1:0]]				<= `SD t_IR_r_nxt;
			vld_r[tail_r[`HT_W-1:0]]			<= `SD t_vld_r_nxt;
			done_r[tail_r[`HT_W-1:0]]			<= `SD t_done_r_nxt;
			if (fu2rob_done_signal_i) begin
				br_taken_r[fu2rob_idx_i[`HT_W-1:0]]	<= `SD fu2rob_br_taken_i;
				done_r[fu2rob_idx_i[`HT_W-1:0]]		<= `SD 1'b1;
			end
		end 
	end
	

endmodule

