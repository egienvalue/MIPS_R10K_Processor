/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  sys_defs.vh                                         //
//                                                                     //
//  Description :  This file has the macro-defines for macros used in  //
//                 the pipeline design.                                //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

// Define for top



////////////////////////////////////////////////////////////////////////
//																	  //
// hengfei															  //
//																	  //
////////////////////////////////////////////////////////////////////////

//*********************************************************************//
// defines for Icache												   //
//*********************************************************************//
`define		IMEM_ADDR_W				64
`define		ICACHE_SIZE_IN_BYTES	256
`define		ICACHE_SIZE_IN_BITS		256*8
`define		ICACHE_LINE_IN_BITS		64
`define		ICACHE_DATA_IN_BITS		64
`define		ICACHE_WAY_NUM			1
`define		ICACHE_LINE_IN_BYTES	8
`define		ICACHE_DAT_NUM			1
`define		ICACHE_D				32
`define		ICACHE_IDX_W			5
`define		ICACHE_TAG_W			56
`define		ICACHE_BLK_OFFSET_W		3

//*********************************************************************//
// defines for Dcache												   //
//*********************************************************************//
`define		TWO_WAY

`ifdef TWO_WAY
`define		DCACHE_SIZE_IN_BYTES	256
`define		DCACHE_SIZE_IN_BITS		256*8
`define		DCACHE_LINE_IN_BITS		64
`define		DCACHE_LINE_IN_BYTES	8
`define		DCACHE_WORD_IN_BITS		64
`define		DCACHE_WORD_IN_BYTES	8
`define		DCACHE_WAY_NUM			2
`define		DCACHE_LINE_NUM			32
`define		DCACHE_SET_NUM			16
`define		DCACHE_BYTE_OFFSET		3
`define		DCACHE_IDX_W			4
`define		DCACHE_TAG_W			57
//`define		DCACHE_SET_NUM			(`DCACHE_LINE_NUM/`DCACHE_WAY_NUM)
//`define		DCACHE_BYTE_OFFSET		($clog2(`DCACHE_WORD_IN_BYTES))
//`define		DCACHE_IDX_W			($clog2(`DCACHE_SET_NUM))
//`define		DCACHE_TAG_W			(64 - (`DCACHE_IDX_W + `DCACHE_BYTE_OFFSET))

`else

`define		DCACHE_SIZE_IN_BYTES	256
`define		DCACHE_SIZE_IN_BITS		256*8
`define		DCACHE_LINE_IN_BITS		64
`define		DCACHE_LINE_IN_BYTES	8
`define		DCACHE_WORD_IN_BITS		64
`define		DCACHE_WORD_IN_BYTES	8
`define		DCACHE_WAY_NUM			1
`define		DCACHE_LINE_NUM			32
`define		DCACHE_SET_NUM			32
`define		DCACHE_BYTE_OFFSET		3
`define		DCACHE_IDX_W			5
`define		DCACHE_TAG_W			56

`endif


`define		MSHR_NUM				4
`define		MSHR_IDX_W				2

typedef enum logic[1:0] {
	GET_S	= 2'h0,
	GET_M	= 2'h1,
	PUT_M	= 2'h2,
	NONE	= 2'h3
} message_t;


`define		RSP_Q_NUM				4
`define		RSP_Q_PTR_W				2

`define		DMEM_MSHR_NUM			4
`define		DMEM_MSHR_IDX_W			2

`define		MEM_TAG_W				4

`define		ID_MEM_ABT_VEC_W		5

`define		PFETCH_NUM				4


// jun
`define			ROB_W			32
`define			ROB_IDX_W		5
`define			HT_W 			($clog2(`ROB_W))
`define			EX_UNIT_W		5
`define			BR_PR_WRONG		2'b01
`define			BR_PR_CORRECT		2'b10
`define			BR_NONE			2'b00
`define			BR_STATE_W		2
`define         BHR_W           8
`define         PT_W            32
`define         PT_IDX_W        ($clog2(`PT_W))
`define         THRESHOLD       256
`define         WEIGHT_W        ($clog2(`THRESHOLD)+1)
`define			PERCEPTRON

// Chuan
`define			PRF_NUM			64
`define			PRF_IDX_W		($clog2(`PRF_NUM))
`define			LRF_NUM			32
`define			LRF_IDX_W		($clog2(`LRF_NUM))
`define			MT_NUM			`LRF_NUM
`define			FL_NUM			`PRF_NUM - `MT_NUM
`define			FL_PTR_W		$clog2(`FL_NUM)
`define			PC_IDX_W		5
`define			BHT_NUM			2**`PC_IDX_W
`define			BHT_W			2
`define			PHT_NUM			2**`BHT_W

`define			BTB_TAG_W		10		//BTB
`define			BTB_VAL_W		12
`define			BTB_SEL_W		9
`define			BTB_NUM			2**`BTB_SEL_W



// Lu
`define			RS_ENT_NUM		8
`define			RS_IDX_W		($clog2(`RS_ENT_NUM))

`define			FU_NUM			6
`define			FU_SEL_W		3
`define			FU_SEL_NONE		3'b000
`define			FU_SEL_ALU		3'b001
`define			FU_SEL_MULT		3'b010
`define			FU_SEL_UNCOND_BRANCH	3'b011
`define			FU_SEL_COND_BRANCH	3'b100
`define			FU_SEL_LOAD		3'b101
`define			FU_SEL_STORE		3'b110

`define			EX_CYCLES_MAX		4
`define			EX_CYCLES_ALU		1
`define			EX_CYCLES_BRANCH	1
`define			EX_CYCLES_LOAD		1
`define			EX_CYCLES_STORE		1
`define			EX_CYCLES_MULT		4

`define			BR_MASK_W			5

`define			SQ_ENT_NUM			8
`define			SQ_IDX_W			$clog2(`SQ_ENT_NUM)
`define			LQ_ENT_NUM			8
`define			LQ_IDX_W			$clog2(`LQ_ENT_NUM)

`define			ADDR_W				64

// Shijing
`define IFB_SIZE 8
`define TAG_SIZE ($clog2(`IFB_SIZE))

`ifndef __SYS_DEFS_VH__
`define __SYS_DEFS_VH__

/* Synthesis testing definition, used in DUT module instantiation */

`ifdef  SYNTH_TEST
`define DUT(mod) mod``_svsim
`else
`define DUT(mod) mod
`endif

//////////////////////////////////////////////
//
// Memory/testbench attribute definitions
//
//////////////////////////////////////////////


`define NUM_MEM_TAGS           15

`define MEM_SIZE_IN_BYTES      (64*1024)
`define MEM_64BIT_LINES        (`MEM_SIZE_IN_BYTES/8)

// probably not a good idea to change this second one
`define VIRTUAL_CLOCK_PERIOD   7.0 // Clock period from dc_shell
`define VERILOG_CLOCK_PERIOD   10.0 // Clock period from test bench

`ifndef CLOCK_PERIOD
`define CLOCK_PERIOD		   10.0
`endif

`define MEM_LATENCY_IN_CYCLES (100.0/`CLOCK_PERIOD+0.49999)
// the 0.49999 is to force ceiling(100/period).  The default behavior for
// float to integer conversion is rounding to nearest

//////////////////////////////////////////////
//
// Error codes
//
//////////////////////////////////////////////

`define NO_ERROR 4'h0
`define HALTED_ON_MEMORY_ERROR 4'h1
`define HALTED_ON_HALT 4'h2
`define HALTED_ON_ILLEGAL 4'h3


//////////////////////////////////////////////
//
// Datapath control signals
//
//////////////////////////////////////////////

//
// ALU opA input mux selects
//
`define ALU_OPA_IS_REGA         2'h0
`define ALU_OPA_IS_MEM_DISP     2'h1
`define ALU_OPA_IS_NPC          2'h2
`define ALU_OPA_IS_NOT3         2'h3

//
// ALU opB input mux selects
//
`define ALU_OPB_IS_REGB         2'h0
`define ALU_OPB_IS_ALU_IMM      2'h1
`define ALU_OPB_IS_BR_DISP      2'h2

//
// Destination register select
//
`define DEST_IS_REGC    2'h0
`define DEST_IS_REGA    2'h1
`define DEST_NONE       2'h2


//
// ALU function code input
// probably want to leave these alone
//
`define ALU_ADDQ        5'h00
`define ALU_SUBQ        5'h01
`define ALU_AND         5'h02
`define ALU_BIC         5'h03
`define ALU_BIS         5'h04
`define ALU_ORNOT       5'h05
`define ALU_XOR         5'h06
`define ALU_EQV         5'h07
`define ALU_SRL         5'h08
`define ALU_SLL         5'h09
`define ALU_SRA         5'h0a
`define ALU_MULQ        5'h0b
`define ALU_CMPEQ       5'h0c
`define ALU_CMPLT       5'h0d
`define ALU_CMPLE       5'h0e
`define ALU_CMPULT      5'h0f
`define ALU_CMPULE      5'h10

//////////////////////////////////////////////
//
// Assorted things it is not wise to change
//
//////////////////////////////////////////////

//
// actually, you might have to change this if you change VERILOG_CLOCK_PERIOD
//
`define SD #1


// the Alpha register file zero register, any read of this register always
// returns a zero value, and any write to this register is thrown away
//
`define ZERO_REG       31

//
// Memory bus commands control signals
//
`define BUS_NONE       2'h0
`define BUS_LOAD       2'h1
`define BUS_STORE      2'h2

//
// useful boolean single-bit definitions
//
`define FALSE	1'h0
`define TRUE	1'h1

//
// Basic NOOP instruction.  Allows pipline registers to clearly be reset with
// an instruction that does nothing instead of Zero which is really a PAL_INST
//
`define NOOP_INST 32'h47ff041f

//
// top level opcodes, used by the IF stage to decode Alpha instructions
//
`define PAL_INST	6'h00
`define LDA_INST	6'h08
`define LDAH_INST	6'h09
`define LDBU_INST	6'h0a
`define LDQ_U_INST	6'h0b
`define LDWU_INST	6'h0c
`define STW_INST	6'h0d
`define STB_INST	6'h0e
`define STQ_U_INST	6'h0f
`define INTA_GRP	6'h10
`define INTL_GRP	6'h11
`define INTS_GRP	6'h12
`define INTM_GRP	6'h13
`define ITFP_GRP	6'h14	// unimplemented
`define FLTV_GRP	6'h15	// unimplemented
`define FLTI_GRP	6'h16	// unimplemented
`define FLTL_GRP	6'h17	// unimplemented
`define MISC_GRP	6'h18
`define JSR_GRP		6'h1a
`define FTPI_GRP	6'h1c
`define LDF_INST	6'h20
`define LDG_INST	6'h21
`define LDS_INST	6'h22
`define LDT_INST	6'h23
`define STF_INST	6'h24
`define STG_INST	6'h25
`define STS_INST	6'h26
`define STT_INST	6'h27
`define LDL_INST	6'h28
`define LDQ_INST	6'h29
`define LDL_L_INST	6'h2a
`define LDQ_L_INST	6'h2b
`define STL_INST	6'h2c
`define STQ_INST	6'h2d
`define STL_C_INST	6'h2e
`define STQ_C_INST	6'h2f
`define BR_INST		6'h30
`define FBEQ_INST	6'h31
`define FBLT_INST	6'h32
`define FBLE_INST	6'h33
`define BSR_INST	6'h34
`define FBNE_INST	6'h35
`define FBGE_INST	6'h36
`define FBGT_INST	6'h37
`define BLBC_INST	6'h38
`define BEQ_INST	6'h39
`define BLT_INST	6'h3a
`define BLE_INST	6'h3b
`define BLBS_INST	6'h3c
`define BNE_INST	6'h3d
`define BGE_INST	6'h3e
`define BGT_INST	6'h3f

// PALcode opcodes
`define PAL_HALT  26'h555
`define PAL_WHAMI 26'h3c

// INTA (10.xx) opcodes
`define ADDL_INST	7'h00
`define S4ADDL_INST	7'h02
`define SUBL_INST	7'h09
`define S4SUBL_INST	7'h0b
`define CMPBGE_INST	7'h0f
`define S8ADDL_INST	7'h12
`define S8SUBL_INST	7'h1b
`define CMPULT_INST	7'h1d
`define ADDQ_INST	7'h20
`define S4ADDQ_INST	7'h22
`define SUBQ_INST	7'h29
`define S4SUBQ_INST	7'h2b
`define CMPEQ_INST	7'h2d
`define S8ADDQ_INST	7'h32
`define S8SUBQ_INST	7'h3b
`define CMPULE_INST	7'h3d
`define ADDLV_INST	7'h40
`define SUBLV_INST	7'h49
`define CMPLT_INST	7'h4d
`define ADDQV_INST	7'h60
`define SUBQV_INST	7'h69
`define CMPLE_INST	7'h6d

// INTL (11.xx) opcodes
`define AND_INST	7'h00
`define BIC_INST	7'h08
`define CMOVLBS_INST	7'h14
`define CMOVLBC_INST	7'h16
`define BIS_INST	7'h20
`define CMOVEQ_INST	7'h24
`define CMOVNE_INST	7'h26
`define ORNOT_INST	7'h28
`define XOR_INST	7'h40
`define CMOVLT_INST	7'h44
`define CMOVGE_INST	7'h46
`define EQV_INST	7'h48
`define AMASK_INST	7'h61
`define CMOVLE_INST	7'h64
`define CMOVGT_INST	7'h66
`define IMPLVER_INST	7'h6c

// INTS (12.xx) opcodes
`define MSKBL_INST	7'h02
`define EXTBL_INST	7'h06
`define INSBL_INST	7'h0b
`define MSKWL_INST	7'h12
`define EXTWL_INST	7'h16
`define INSWL_INST	7'h1b
`define MSKLL_INST	7'h22
`define EXTLL_INST	7'h26
`define INSLL_INST	7'h2b
`define ZAP_INST	7'h30
`define ZAPNOT_INST	7'h31
`define MSKQL_INST	7'h32
`define SRL_INST	7'h34
`define EXTQL_INST	7'h36
`define SLL_INST	7'h39
`define INSQL_INST	7'h3b
`define SRA_INST	7'h3c
`define MSKWH_INST	7'h52
`define INSWH_INST	7'h57
`define EXTWH_INST	7'h5a
`define MSKLH_INST	7'h62
`define INSLH_INST	7'h67
`define EXTLH_INST	7'h6a
`define MSKQH_INST	7'h72
`define INSQH_INST	7'h77
`define EXTQH_INST	7'h7a

// INTM (13.xx) opcodes
`define MULL_INST	7'h00
`define MULQ_INST	7'h20
`define UMULH_INST	7'h30
`define MULLV_INST	7'h40
`define MULQV_INST	7'h60

// MISC (18.xx) opcodes
`define TRAPB_INST	16'h0000
`define EXCB_INST	16'h0400
`define MB_INST		16'h4000
`define WMB_INST	16'h4400
`define FETCH_INST	16'h8000
`define FETCH_M_INST	16'ha000
`define RPCC_INST	16'hc000
`define RC_INST		16'he000
`define ECB_INST	16'he800
`define RS_INST		16'hf000
`define WH64_INST	16'hf800

// JSR (1a.xx) opcodes
`define JMP_INST	2'h0
`define JSR_INST	2'h1
`define RET_INST	2'h2
`define JSR_CO_INST	2'h3

`endif
