#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <dlfcn.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
extern long long int GetLLIresult();
extern void StoreLLIresult(const unsigned int* data);
typedef struct VeriC_Descriptor *vc_handle;

#ifndef SV_3_COMPATIBILITY
#define SV_STRING const char*
#else
#define SV_STRING char*
#endif

#endif /* _VC_TYPES_ */

void print_header(const char* str);
void print_cycles();
void print_stage(const char* div, int inst, int npc, int valid_inst);
void print_reg(int wb_reg_wr_data_out_hi, int wb_reg_wr_data_out_lo, int wb_reg_wr_idx_out, int wb_reg_wr_en_out);
void print_membus(int proc2mem_command, int mem2proc_response, int proc2mem_addr_hi, int proc2mem_addr_lo, int proc2mem_data_hi, int proc2mem_data_lo);
void print_close();

#ifdef __cplusplus
}
#endif

