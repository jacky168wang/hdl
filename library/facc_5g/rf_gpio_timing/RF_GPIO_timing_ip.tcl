# ip

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip.tcl

adi_ip_create RF_GPIO_timing

adi_ip_files RF_GPIO_timing [list \
  "RF_GPIO_timing.v" \
]

adi_ip_properties_lite RF_GPIO_timing

ipx::save_core [ipx::current_core]