# ip

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip.tcl

adi_ip_create unpack

set st_ram_64to32 [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name st_ram_64to32]
  set_property -dict [ list \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Write_Width_A {64} \
    CONFIG.Write_Depth_A {2048} \
    CONFIG.Read_Width_A {64} \
    CONFIG.Operating_Mode_A {NO_CHANGE} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Write_Width_B {32} \
    CONFIG.Read_Width_B {32} \
    CONFIG.Operating_Mode_B {WRITE_FIRST} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
     ] [get_ips st_ram_64to32]

generate_target {all} [get_files unpack.srcs/sources_1/ip/st_ram_64to32/st_ram_64to32.xci]

adi_ip_files unpack [list \
  "dl_distribt.sv" \
  "util_packfifo.sv" \
  "avlst_64to32.sv" \
  "unpack.v"\
  ]

adi_ip_properties_lite unpack

adi_add_bus "pdsch_ante" "master" \
"analog.com:interface:pdsch_ante_rtl:1.0" \
"analog.com:interface:pdsch_ante:1.0" \
{\
  { "dout_ante_data" "data" } \
  { "dout_ante_sop" "sop" } \
  { "dout_ante_eop" "eop" } \
  { "dout_ante_valid" "valid" } \
  { "antenna_index" "ante" } \
  { "symbol_ante_index" "symbol" } \
  { "slot_ante_index" "slot" } \
  { "frame_ante_index" "frame" } \
}

#### for denug
##adi_add_bus "avalon_din" "slave" \
##"analog.com:interface:avalon_st_rtl:1.0" \
##"analog.com:interface:avalon_st:1.0" \
##{\
##  { "mac_avalon_st_tx_ready" "ready" } \
##  { "din_sop" "sop" } \
##  { "din_eop" "eop" } \
##  { "din_valid" "valid" } \
##  { "din_empty" "empty" } \
##  { "din_data" "data" } \
##}

adi_add_bus	"xg_s_axis" "slave"\
"xilinx.com:interface:axis_rtl:1.0" \
"xilinx.com:interface:axis:1.0" \
[list \
	{"din_data" "TDATA"}\
	{"din_eop" "TLAST"}\
	{"din_valid" "TVALID"}\
	{"mac_avalon_st_tx_ready" "TREADY"} ]


ipx::save_core [ipx::current_core]

