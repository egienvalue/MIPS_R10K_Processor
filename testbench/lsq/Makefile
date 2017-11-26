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

VCS = vcs -sverilog +vc -Mupdate -line -full64
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v


############################
# Modify this part, MODULE
# and submodule1/2... names
############################
MODULE=lsq
SOURCE_DIR= ../../verilog/$(MODULE)
SIMFILES =	$(SOURCE_DIR)/$(MODULE).v	\
			#$(SOURCE_DIR)/ifb.v			\
			$(SOURCE_DIR)/cachemem.v	\
			$(SOURCE_DIR)/Icache_ctrl.v	\
			$(SOURCE_DIR)/rps4.v	\
			$(SOURCE_DIR)/prefetch.v	\
			../mem.v#
SOURCE_FILES= $(SOURCE_DIR)/$(MODULE).v	\
			  #$(SOURCE_DIR)/ifb.v		\
			$(SOURCE_DIR)/cachemem.v	\
			$(SOURCE_DIR)/Icache_ctrl.v	\
			$(SOURCE_DIR)/rps4.v	\
			$(SOURCE_DIR)/prefetch.v	
HEADERS = ../../sys_defs.vh
TESTBENCH = $(MODULE)_tb.v	\
#			../mem.v
SYNFILES = ../../synth/$(MODULE)/$(MODULE).vg
SYN_DIR = ../../synth/$(MODULE)

all:	simv
	./simv | tee program.out

simv:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) $^	-o simv

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
	$(VCS) +memcbk $(HEADERS) $(TESTBENCH) $(SYNFILES) -o dve -R -gui
.PHONY:	syn_dve

clean:
	rm -rf simv simv.daidir csrc vcs.key program.out
	rm -rf vis_simv vis_simv.daidir
	rm -rf dve*
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h

nuke:	clean
	rm -f $(SYN_DIR)/*.vg $(SYN_DIR)/*.rep $(SYN_DIR)/*.ddc $(SYN_DIR)/*.chk $(SYN_DIR)/command.log
	rm -f $(SYN_DIR)/*.out command.log $(SYN_DIR)/*.db $(SYN_DIR)/*.svf

