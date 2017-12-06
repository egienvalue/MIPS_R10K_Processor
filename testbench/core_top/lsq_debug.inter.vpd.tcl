# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Tue Dec 5 12:24:13 2017
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__1031777237
#   Wave.1: 52 signals
#   Group count = 11
#   Group CLK_RST_CNT_RT signal count = 5
#   Group FU signals signal count = 5
#   Group LQ Reg signal count = 9
#   Group LSQ2Dcache signal count = 5
#   Group Dcache2LSQ signal count = 6
#   Group Dcache From/To LSQ signal count = 11
#   Group Dcache MSHR_ISS Input signal count = 6
#   Group BUS message signal count = 5
#   Group Group1 signal count = 0
#   Group Group2 signal count = 0
#   Group Group3 signal count = 0
# End_DVE_Session_Save_Info

# DVE version: K-2015.09_Full64
# DVE build date: Aug 25 2015 21:36:02


#<Session mode="Full" path="/home/hengfei/Desktop/EECS470/final_prj/testbench/core_top/lsq_debug.inter.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{1 38} {3076 1231}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 380]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 380
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 379} {height 698} {dock_state left} {dock_on_new_line true} {child_hier_colhier 272} {child_hier_coltype 99} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 825]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 825
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 1080
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 824} {height 698} {dock_state left} {dock_on_new_line true} {child_data_colvariable 326} {child_data_colvalue 286} {child_data_coltype 203} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 415]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 3380
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 415
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 3075} {height 414} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{0 66} {3439 1406}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 999} {child_wave_right 2435} {child_wave_colname 497} {child_wave_colvalue 498} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{-ucligui +vc +define+CLOCK_PERIOD=8.8 +memcbk}}
gui_set_env SIMSETUP::SIMEXE {dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dve}] } {
gui_sim_run Ucli -exe dve -args {-ucligui +vc +define+CLOCK_PERIOD=8.8 +memcbk} -dir ../core_top -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 100ps
gui_set_time_units 100ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss}
gui_load_child_values {core_top_tb}


set _session_group_57 CLK_RST_CNT_RT
gui_sg_create "$_session_group_57"
set CLK_RST_CNT_RT "$_session_group_57"

gui_sg_addsignal -group "$_session_group_57" { core_top_tb.rst core_top_tb.clk core_top_tb.clock_count core_top_tb.core_retire_wr_en core_top_tb.instr_count }
gui_set_radix -radix {decimal} -signals {Sim:core_top_tb.clock_count}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.clock_count}
gui_set_radix -radix {decimal} -signals {Sim:core_top_tb.instr_count}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.instr_count}

set _session_group_58 {FU signals}
gui_sg_create "$_session_group_58"
set {FU signals} "$_session_group_58"

gui_sg_addsignal -group "$_session_group_58" { core_top_tb.core_top.core0.fu_main.fu2preg_wr_en_o core_top_tb.core_top.core0.fu_main.fu2preg_wr_idx_o core_top_tb.core_top.core0.fu_main.fu2preg_wr_value_o core_top_tb.core_top.core0.fu_main.fu_cdb_vld_o core_top_tb.core_top.core0.fu_main.fu_cdb_broad_o }
gui_set_radix -radix {decimal} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu2preg_wr_idx_o}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu2preg_wr_idx_o}
gui_set_radix -radix {decimal} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_cdb_broad_o}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_cdb_broad_o}

set _session_group_59 {LQ Reg}
gui_sg_create "$_session_group_59"
set {LQ Reg} "$_session_group_59"

gui_sg_addsignal -group "$_session_group_59" { core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_head_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_tail_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_vld_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rdy_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_addr_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_data_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rob_idx_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_dest_tag_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_br_mask_r }
gui_set_radix -radix {binary} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_vld_r}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_vld_r}
gui_set_radix -radix {binary} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rdy_r}
gui_set_radix -radix {unsigned} -signals {Sim:core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rdy_r}

set _session_group_60 LSQ2Dcache
gui_sg_create "$_session_group_60"
set LSQ2Dcache "$_session_group_60"

gui_sg_addsignal -group "$_session_group_60" { core_top_tb.core_top.core0.fu_main.lsq2Dcache_ld_en_o core_top_tb.core_top.core0.fu_main.lsq2Dcache_ld_addr_o core_top_tb.core_top.core0.fu_main.lsq2Dcache_st_en_o core_top_tb.core_top.core0.fu_main.lsq2Dcache_st_addr_o core_top_tb.core_top.core0.fu_main.lsq2Dcache_st_data_o }

set _session_group_61 Dcache2LSQ
gui_sg_create "$_session_group_61"
set Dcache2LSQ "$_session_group_61"

gui_sg_addsignal -group "$_session_group_61" { core_top_tb.core_top.core0.fu_main.Dcache_hit_i core_top_tb.core_top.core0.fu_main.Dcache_mshr_vld_i core_top_tb.core_top.core0.fu_main.Dcache_mshr_addr_i core_top_tb.core_top.core0.fu_main.Dcache_data_i core_top_tb.core_top.core0.fu_main.Dcache_mshr_ld_ack_i core_top_tb.core_top.core0.fu_main.Dcache_mshr_st_ack_i }

set _session_group_62 {Dcache From/To LSQ}
gui_sg_create "$_session_group_62"
set {Dcache From/To LSQ} "$_session_group_62"

gui_sg_addsignal -group "$_session_group_62" { core_top_tb.core_top.core0.Dcache.Dcache_ctrl.lq2Dctrl_en_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.Dctrl2lq_ack_o core_top_tb.core_top.core0.Dcache.Dcache2lq_data_vld_o core_top_tb.core_top.core0.Dcache.Dcache_ctrl.lq2Dctrl_addr_i core_top_tb.core_top.core0.Dcache.Dcache2lq_mshr_data_vld_o core_top_tb.core_top.core0.Dcache.Dcache2lq_addr_o core_top_tb.core_top.core0.Dcache.Dcache2lq_data_o core_top_tb.core_top.core0.Dcache.Dcache_ctrl.sq2Dctrl_en_i core_top_tb.core_top.core0.Dcache.Dcache2sq_ack_o core_top_tb.core_top.core0.Dcache.Dcache_ctrl.sq2Dctrl_addr_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.sq2Dctrl_data_i }

set _session_group_63 {Dcache MSHR_ISS Input}
gui_sg_create "$_session_group_63"
set {Dcache MSHR_ISS Input} "$_session_group_63"

gui_sg_addsignal -group "$_session_group_63" { core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_alloc_en_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_tag_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_idx_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_data_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_message_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.mshr_iss.mshr_iss_ack_i }

set _session_group_64 {BUS message}
gui_sg_create "$_session_group_64"
set {BUS message} "$_session_group_64"

gui_sg_addsignal -group "$_session_group_64" { core_top_tb.core_top.core0.Dcache.Dcache_ctrl.bus2Dctrl_req_ack_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.bus2Dctrl_req_id_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.bus2Dctrl_req_tag_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.bus2Dctrl_req_idx_i core_top_tb.core_top.core0.Dcache.Dcache_ctrl.bus2Dctrl_req_message_i }

set _session_group_65 Group1
gui_sg_create "$_session_group_65"
set Group1 "$_session_group_65"


set _session_group_66 Group2
gui_sg_create "$_session_group_66"
set Group2 "$_session_group_66"


set _session_group_67 Group3
gui_sg_create "$_session_group_67"
set Group3 "$_session_group_67"


# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 1749011



# Save global setting...

# Wave/List view global setting
gui_list_create_group_when_add -wave -enable
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} core_top_tb}
catch {gui_list_expand -id ${Hier.1} core_top_tb.core_top}
catch {gui_list_expand -id ${Hier.1} core_top_tb.core_top.core0}
catch {gui_list_expand -id ${Hier.1} core_top_tb.core_top.core0.fu_main}
catch {gui_list_expand -id ${Hier.1} core_top_tb.core_top.core0.fu_main.fu_ldst}
catch {gui_list_select -id ${Hier.1} {core_top_tb.core_top.core0.fu_main.fu_ldst.lsq}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 1

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*_r}
gui_list_show_data -id ${Data.1} {core_top_tb.core_top.core0.fu_main.fu_ldst.lsq}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_head_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_tail_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_head_msb_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_tail_msb_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_addr_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_data_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_vld_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rdy_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_rob_idx_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_dest_tag_r core_top_tb.core_top.core0.fu_main.fu_ldst.lsq.lq_br_mask_r }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 1

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__1031777237 /home/hengfei/Desktop/EECS470/final_prj/sys_defs.vh
gui_src_value_annotate -id ${Source.1} -switch true
gui_set_env TOGGLE::VALUEANNOTATE 1
gui_view_scroll -id ${Source.1} -vertical -set 0
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 1747340 1750561
gui_list_add_group -id ${Wave.1} -after {New Group} {CLK_RST_CNT_RT}
gui_list_add_group -id ${Wave.1} -after {New Group} {{FU signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{LQ Reg}}
gui_list_add_group -id ${Wave.1} -after {New Group} {LSQ2Dcache}
gui_list_add_group -id ${Wave.1} -after {New Group} {Dcache2LSQ}
gui_list_add_group -id ${Wave.1} -after {New Group} {{Dcache From/To LSQ}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{Dcache MSHR_ISS Input}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{BUS message}}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group2}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group3}
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group {FU signals}  -item {core_top_tb.core_top.core0.fu_main.fu_cdb_broad_o[5:0]} -position below

gui_marker_move -id ${Wave.1} {C1} 1749011
gui_view_scroll -id ${Wave.1} -vertical -set 51
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

