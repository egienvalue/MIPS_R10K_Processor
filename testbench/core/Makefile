# This is Makefile template for sim before synth and sim after synth
#
# make          <- runs simv (after compiling simv if needed)
# make all      <- runs simv (after compiling simv if needed)
# make simv     <- compile simv if needed (but do not run)
# make syn_simv <- compile syn_simv and output the syn_program.out
# make syn      <- runs syn only
# make rsyn		<- re-syn the module
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#
#t

VCS = SW_VCS=2015.09 vcs -sverilog +vc -Mupdate -line -full64
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v


############################
# Modify this part, MODULE
# and submodule1/2... names
############################
MODULE=core
SOURCE_DIR= ../../verilog/$(MODULE)
SIMFILES =	$(SOURCE_DIR)/$(MODULE).v	\
			$(SOURCE_DIR)/../Icache/Icache.v	\
			$(SOURCE_DIR)/../Icache/Icache_ctrl.v	\
			$(SOURCE_DIR)/../Icache/rps4.v	\
			$(SOURCE_DIR)/../Icache/prefetch.v	\
			$(SOURCE_DIR)/../Icache/cachemem.v	\
			$(SOURCE_DIR)/../if_stage/ifb.v	\
			$(SOURCE_DIR)/../if_stage/if_stage.v	\
			$(SOURCE_DIR)/../id_stage.v	\
			$(SOURCE_DIR)/../rs/pe.v	\
			$(SOURCE_DIR)/../rs/ps.v	\
			$(SOURCE_DIR)/../rs/rs1.v	\
			$(SOURCE_DIR)/../rs/rs.v	\
			$(SOURCE_DIR)/../rob/rob.v	\
			$(SOURCE_DIR)/../tables/map_table.v	\
			$(SOURCE_DIR)/../tables/free_list.v	\
			$(SOURCE_DIR)/../fu/fu_alu.v	\
			$(SOURCE_DIR)/../fu/fu_br.v	\
			$(SOURCE_DIR)/../fu/fu_mult.v	\
			$(SOURCE_DIR)/../fu/preg_file.v	\
			$(SOURCE_DIR)/../fu/fu_ldst.v	\
			$(SOURCE_DIR)/../fu/fu_main.v	\
			$(SOURCE_DIR)/../branch_stack/br_stack_ent.v	\
			$(SOURCE_DIR)/../branch_stack/br_mask_ctrl.v	\
			$(SOURCE_DIR)/../branch_stack/branch_stack.v	\
			$(SOURCE_DIR)/../lsq/lsq.v	\
			$(SOURCE_DIR)/../branch_pred/BTB.v	\
			$(SOURCE_DIR)/../branch_pred/PAg_DIRP.v	\
			$(SOURCE_DIR)/../branch_pred/branch_pred.v		

SOURCE_FILES= $(SOURCE_DIR)/$(MODULE).v	\
			$(SOURCE_DIR)/../Icache/Icache.v	\
			$(SOURCE_DIR)/../Icache/Icache_ctrl.v	\
			$(SOURCE_DIR)/../Icache/rps4.v	\
			$(SOURCE_DIR)/../Icache/prefetch.v	\
			$(SOURCE_DIR)/../Icache/cachemem.v	\
			$(SOURCE_DIR)/../if_stage/ifb.v	\
			$(SOURCE_DIR)/../if_stage/if_stage.v	\
			$(SOURCE_DIR)/../id_stage.v	\
			$(SOURCE_DIR)/../rs/pe.v	\
			$(SOURCE_DIR)/../rs/ps.v	\
			$(SOURCE_DIR)/../rs/rs1.v	\
			$(SOURCE_DIR)/../rs/rs.v	\
			$(SOURCE_DIR)/../rob/rob.v	\
			$(SOURCE_DIR)/../tables/map_table.v	\
			$(SOURCE_DIR)/../tables/free_list.v	\
			$(SOURCE_DIR)/../fu/fu_alu.v	\
			$(SOURCE_DIR)/../fu/fu_br.v	\
			$(SOURCE_DIR)/../fu/fu_mult.v	\
			$(SOURCE_DIR)/../fu/preg_file.v	\
			$(SOURCE_DIR)/../fu/fu_ldst.v	\
			$(SOURCE_DIR)/../fu/fu_main.v	\
			$(SOURCE_DIR)/../branch_stack/br_stack_ent.v	\
			$(SOURCE_DIR)/../branch_stack/br_mask_ctrl.v	\
			$(SOURCE_DIR)/../branch_stack/branch_stack.v	\
			$(SOURCE_DIR)/../lsq/lsq.v	\
			$(SOURCE_DIR)/../branch_pred/BTB.v	\
			$(SOURCE_DIR)/../branch_pred/PAg_DIRP.v	\
			$(SOURCE_DIR)/../branch_pred/branch_pred.v		
HEADERS = ../../sys_defs.vh
TESTBENCH = $(MODULE)_tb.v	\
			../mem.v
SYNFILES = ../../synth/$(MODULE)/$(MODULE).vg
SYN_DIR = ../../synth/$(MODULE)

all:	simv
	./simv | tee program.out

simv:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) $(HEADERS) $(TESTBENCH) $(SIMFILES)	-o simv

dve:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) +memcbk $(HEADERS) $(TESTBENCH) $(SIMFILES) -o dve -R -gui
.PHONY:	dve

simv_syn:	$(HEADERS) $(SYNFILES) $(TESTBENCH)
	$(VCS) $(HEADERS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv 
	./syn_simv | tee syn_program.out

syn:	$(SOURCE_FILES) $(SYN_DIR)/$(MODULE)_syn.tcl
	cd $(SYN_DIR)/ && dc_shell-t -f ./$(MODULE)_syn.tcl | tee $(MODULE)_synth.out

rsyn:	nuke $(SIMFILES) $(SYN_DIR)/$(MODULE)_syn.tcl
	cd $(SYN_DIR)/ && dc_shell-t -f ./$(MODULE)_syn.tcl | tee $(MODULE)_synth.out

syn_dve:	$(HEADERS) $(SYNFILES) $(TESTBENCH)
	$(VCS) +memcbk $(HEADERS) $(TESTBENCH) $(SYNFILES) $(LIB) -o dve -R -gui
.PHONY:	syn_dve

clean:
	rm -rf simv simv.daidir csrc vcs.key program.out
	rm -rf vis_simv vis_simv.daidir
	rm -rf dve*
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h
	rm -rf ucli.key

nuke:	clean
	rm -f $(SYN_DIR)/*.vg $(SYN_DIR)/*.rep $(SYN_DIR)/*.ddc $(SYN_DIR)/*.chk $(SYN_DIR)/command.log
	rm -f $(SYN_DIR)/*.out command.log $(SYN_DIR)/*.db $(SYN_DIR)/*.svf

