# TCL File Generated by Component Editor 16.1
# Fri Feb 8 16:31:53 GMT+08:00 2018
# DO NOT MODIFY


# 
# harden_rx "harden_rx_eth" v1.0
# Royce Ai Yu Pan 2018.05.15.16:31:53 
# harden receiver data path.
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module harden_rx
# 
set_module_property DESCRIPTION "harden receiver data path ,data_out to Ethernet"
set_module_property NAME harden_rx_eth
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "FACC 5G"
set_module_property AUTHOR  Royce Ai Yu Pan
set_module_property DISPLAY_NAME harden_rx
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL harden_rx
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false

add_fileset_file harden_rx.v VERILOG PATH harden_rx.v TOP_LEVEL_FILE
add_fileset_file cp_removal.v VERILOG PATH cp_removal.v
add_fileset_file sc_demap.sv SYSTEM_VERILOG PATH sc_demap.sv
add_fileset_file util_blocfifo.sv SYSTEM_VERILOG PATH util_blocfifo.sv
add_fileset_file compression.v VERILOG PATH compression.v
add_fileset_file util_fft.v VERILOG PATH util_fft.v
add_fileset_file util_scaler.v VERILOG PATH util_scaler.v
add_fileset_file sd_forward.sv SYSTEM_VERILOG PATH sd_forward.sv 


# 
# parameters
# 

#  FFT_SIZE
add_parameter FFT_SIZE INTEGER 4096
set_parameter_property FFT_SIZE DEFAULT_VALUE 4096
set_parameter_property FFT_SIZE DISPLAY_NAME FFT_SIZE
set_parameter_property FFT_SIZE TYPE INTEGER
set_parameter_property FFT_SIZE UNITS None
set_parameter_property FFT_SIZE HDL_PARAMETER true

#  EXP_MASK
add_parameter EXP_MASK STD_LOGIC_VECTOR 8388606
set_parameter_property EXP_MASK DEFAULT_VALUE 8388606
set_parameter_property EXP_MASK DISPLAY_NAME EXP_MASK
set_parameter_property EXP_MASK TYPE STD_LOGIC_VECTOR
set_parameter_property EXP_MASK UNITS None
set_parameter_property EXP_MASK ALLOWED_RANGES 0:268435455
set_parameter_property EXP_MASK HDL_PARAMETER true

#  SC_NUM
add_parameter SC_NUM STD_LOGIC_VECTOR 1200
set_parameter_property SC_NUM DEFAULT_VALUE 1200
set_parameter_property SC_NUM DISPLAY_NAME SC_NUM
set_parameter_property SC_NUM WIDTH 17
set_parameter_property SC_NUM TYPE STD_LOGIC_VECTOR
set_parameter_property SC_NUM UNITS None
set_parameter_property SC_NUM ALLOWED_RANGES 0:131071
set_parameter_property SC_NUM HDL_PARAMETER true

#  DC_ENABLE
add_parameter DC_ENABLE INTEGER 0
set_parameter_property DC_ENABLE DEFAULT_VALUE 0
set_parameter_property DC_ENABLE DISPLAY_NAME DC_ENABLE
set_parameter_property DC_ENABLE TYPE INTEGER
set_parameter_property DC_ENABLE UNITS None
set_parameter_property DC_ENABLE HDL_PARAMETER true

#  CP_LEN1
add_parameter CP_LEN1 INTEGER 352
set_parameter_property CP_LEN1 DEFAULT_VALUE 352
set_parameter_property CP_LEN1 DISPLAY_NAME CP_LEN1
set_parameter_property CP_LEN1 TYPE INTEGER
set_parameter_property CP_LEN1 UNITS None
set_parameter_property CP_LEN1 HDL_PARAMETER true

#  CP_LEN2
add_parameter CP_LEN2 INTEGER 288
set_parameter_property CP_LEN2 DEFAULT_VALUE 288
set_parameter_property CP_LEN2 DISPLAY_NAME CP_LEN2
set_parameter_property CP_LEN2 TYPE INTEGER
set_parameter_property CP_LEN2 UNITS None
set_parameter_property CP_LEN2 HDL_PARAMETER true

   
#                                                                      
# connection point link_clk                                            
#                                                                      
add_interface link_clk clock end                                       
set_interface_property link_clk clockRate 0                            
set_interface_property link_clk ENABLED true                           
set_interface_property link_clk EXPORT_OF ""                           
set_interface_property link_clk PORT_NAME_MAP ""                       
set_interface_property link_clk CMSIS_SVD_VARIABLES ""                 
set_interface_property link_clk SVD_ADDRESS_GROUP ""                   
                                                                       
add_interface_port link_clk link_clk clk Input 1
                                                                  
#                                                             
# connection point eth_clk                                    
#                                                             
add_interface eth_clk clock end                                                                                                 
set_interface_property eth_clk clockRate 0                                                                                      
set_interface_property eth_clk ENABLED true                                                                                     
set_interface_property eth_clk EXPORT_OF ""                                                                                     
set_interface_property eth_clk PORT_NAME_MAP ""                                                                                 
set_interface_property eth_clk CMSIS_SVD_VARIABLES ""                                                                           
set_interface_property eth_clk SVD_ADDRESS_GROUP ""                                                                             
                                                                                                                                
add_interface_port eth_clk eth_clk clk Input 1                                                                                  
                                                                  
                                                                  
   
# connection point reset_sink                                       
# rst_n                                                                 
add_interface reset_sink reset end                                  
set_interface_property reset_sink associatedClock link_clk             
set_interface_property reset_sink synchronousEdges DEASSERT         
set_interface_property reset_sink ENABLED true                      
set_interface_property reset_sink EXPORT_OF ""                      
set_interface_property reset_sink PORT_NAME_MAP ""                  
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""            
set_interface_property reset_sink SVD_ADDRESS_GROUP ""              
                                                                    
add_interface_port reset_sink rst_sys_n reset_n Input 1 


#################################################################
# trigger from harden_sync     
                                                                                                                      
add_interface sync_ctrl conduit end                
set_interface_property sync_ctrl associatedClock  ""
set_interface_property sync_ctrl associatedReset ""
set_interface_property sync_ctrl ENABLED true
set_interface_property sync_ctrl EXPORT_OF ""
set_interface_property sync_ctrl PORT_NAME_MAP ""
set_interface_property sync_ctrl CMSIS_SVD_VARIABLES ""
set_interface_property sync_ctrl SVD_ADDRESS_GROUP ""

add_interface_port sync_ctrl trigger trigger Input 1
add_interface_port sync_ctrl long_cp lcp Input 1              
add_interface_port sync_ctrl mode mode Input 1     
add_interface_port sync_ctrl din_symbol symbol Input 4      
add_interface_port sync_ctrl din_slot   slot Input 8    
add_interface_port sync_ctrl din_frame  frame Input 10              
 
 
                              
#################################################################
#                  connect axi_ad9371                           #
#################################################################
            
#                                                                           
# connection point adc_ch_0_axi                                             
#                                                                           
add_interface adc_ch_0_axi conduit end                                      
set_interface_property adc_ch_0_axi associatedClock link_clk                
set_interface_property adc_ch_0_axi associatedReset ""                      
set_interface_property adc_ch_0_axi ENABLED true                            
set_interface_property adc_ch_0_axi EXPORT_OF ""                            
set_interface_property adc_ch_0_axi PORT_NAME_MAP ""                        
set_interface_property adc_ch_0_axi CMSIS_SVD_VARIABLES ""                  
set_interface_property adc_ch_0_axi SVD_ADDRESS_GROUP ""                    
                                                                            
add_interface_port adc_ch_0_axi data_in_i0 data Input 16                    
add_interface_port adc_ch_0_axi enable_in_i0 enable Input 1                 
add_interface_port adc_ch_0_axi valid_in_i0 valid Input 1                   
                                                                            
#                                                                           
# connection point adc_ch_1_axi                                             
#                                                                           
add_interface adc_ch_1_axi conduit end                                      
set_interface_property adc_ch_1_axi associatedClock link_clk                
set_interface_property adc_ch_1_axi associatedReset ""                      
set_interface_property adc_ch_1_axi ENABLED true                            
set_interface_property adc_ch_1_axi EXPORT_OF ""                            
set_interface_property adc_ch_1_axi PORT_NAME_MAP ""                        
set_interface_property adc_ch_1_axi CMSIS_SVD_VARIABLES ""                  
set_interface_property adc_ch_1_axi SVD_ADDRESS_GROUP ""                    
                                                                            
add_interface_port adc_ch_1_axi data_in_q0 data Input 16                    
add_interface_port adc_ch_1_axi enable_in_q0 enable Input 1                 
add_interface_port adc_ch_1_axi valid_in_q0 valid Input 1                   
                                                                            
#                                                                           
# connection point adc_ch_2_axi                                             
#                                                                           
add_interface adc_ch_2_axi conduit end                                      
set_interface_property adc_ch_2_axi associatedClock link_clk                
set_interface_property adc_ch_2_axi associatedReset ""                      
set_interface_property adc_ch_2_axi ENABLED true                            
set_interface_property adc_ch_2_axi EXPORT_OF ""                            
set_interface_property adc_ch_2_axi PORT_NAME_MAP ""                        
set_interface_property adc_ch_2_axi CMSIS_SVD_VARIABLES ""                  
set_interface_property adc_ch_2_axi SVD_ADDRESS_GROUP ""                    
                                                                            
add_interface_port adc_ch_2_axi data_in_i1 data Input 16                    
add_interface_port adc_ch_2_axi enable_in_i1 enable Input 1                 
add_interface_port adc_ch_2_axi valid_in_i1 valid Input 1                   
                                                                            
#                                                                           
# connection point adc_ch_3_axi                                             
#                                                                           
add_interface adc_ch_3_axi conduit end                                      
set_interface_property adc_ch_3_axi associatedClock link_clk                
set_interface_property adc_ch_3_axi associatedReset ""                      
set_interface_property adc_ch_3_axi ENABLED true                            
set_interface_property adc_ch_3_axi EXPORT_OF ""                            
set_interface_property adc_ch_3_axi PORT_NAME_MAP ""                        
set_interface_property adc_ch_3_axi CMSIS_SVD_VARIABLES ""                  
set_interface_property adc_ch_3_axi SVD_ADDRESS_GROUP ""                    
                                                                            
add_interface_port adc_ch_3_axi data_in_q1 data Input 16                    
add_interface_port adc_ch_3_axi enable_in_q1 enable Input 1                 
add_interface_port adc_ch_3_axi valid_in_q1 valid Input 1                   
                                                                            
                                                                                                                                                                                                                                    
#################################################################         
#                    connect pusch_packet                       #         
#################################################################

add_interface pusch_ante_0 conduit end                                      
set_interface_property pusch_ante_0 associatedClock ""                
set_interface_property pusch_ante_0 associatedReset ""                      
set_interface_property pusch_ante_0 ENABLED true                            
set_interface_property pusch_ante_0 EXPORT_OF ""                            
set_interface_property pusch_ante_0 PORT_NAME_MAP ""                        
set_interface_property pusch_ante_0 CMSIS_SVD_VARIABLES ""                  
set_interface_property pusch_ante_0 SVD_ADDRESS_GROUP ""                    
                                                                            
add_interface_port pusch_ante_0 data0_rd_req rd_req Input 1                    
add_interface_port pusch_ante_0 dout0_data   data   Output 64                 
add_interface_port pusch_ante_0 dout0_valid  valid  Output 1 
add_interface_port pusch_ante_0 dout0_sop    sop    Output 1 
add_interface_port pusch_ante_0 dout0_eop    eop    Output 1                  
add_interface_port pusch_ante_0 dout0_used   used   Output 4 
add_interface_port pusch_ante_0 dout0_symbol symbol Output 8                                                                      
add_interface_port pusch_ante_0 dout0_slot   slot   Output 8 
add_interface_port pusch_ante_0 dout0_frame  frame  Output 10  
add_interface_port pusch_ante_0 dout0_exp    exp    Output 16 

add_interface pusch_ante_1 conduit end                                         
set_interface_property pusch_ante_1 associatedClock ""                   
set_interface_property pusch_ante_1 associatedReset ""                         
set_interface_property pusch_ante_1 ENABLED true                               
set_interface_property pusch_ante_1 EXPORT_OF ""                               
set_interface_property pusch_ante_1 PORT_NAME_MAP ""                           
set_interface_property pusch_ante_1 CMSIS_SVD_VARIABLES ""                     
set_interface_property pusch_ante_1 SVD_ADDRESS_GROUP ""                       
                                                                               
add_interface_port pusch_ante_1 data1_rd_req rd_req Input 1                    
add_interface_port pusch_ante_1 dout1_data   data   Output 64                  
add_interface_port pusch_ante_1 dout1_valid  valid  Output 1                   
add_interface_port pusch_ante_1 dout1_sop    sop    Output 1                   
add_interface_port pusch_ante_1 dout1_eop    eop    Output 1                   
add_interface_port pusch_ante_1 dout1_used   used   Output 4                   
add_interface_port pusch_ante_1 dout1_symbol symbol Output 8                   
add_interface_port pusch_ante_1 dout1_slot   slot   Output 8                   
add_interface_port pusch_ante_1 dout1_frame  frame  Output 10                  
add_interface_port pusch_ante_1 dout1_exp    exp    Output 16                  
                                                                               

#################################################################         
#                          gpio                                 #         
#################################################################         
                  
#                                                     
# connection point gp_control                               
#                                                            
add_interface gp_control conduit end                     
set_interface_property gp_control associatedClock  ""    
set_interface_property gp_control associatedReset ""     
set_interface_property gp_control ENABLED true           
set_interface_property gp_control EXPORT_OF ""           
set_interface_property gp_control PORT_NAME_MAP ""       
set_interface_property gp_control CMSIS_SVD_VARIABLES "" 
set_interface_property gp_control SVD_ADDRESS_GROUP ""   
                                                      
add_interface_port gp_control gp_control export Input 32    

# 
# connection point gp_status
# 
add_interface gp_status conduit end
set_interface_property gp_status associatedClock  ""
set_interface_property gp_status associatedReset ""
set_interface_property gp_status ENABLED true
set_interface_property gp_status EXPORT_OF ""
set_interface_property gp_status PORT_NAME_MAP ""
set_interface_property gp_status CMSIS_SVD_VARIABLES ""
set_interface_property gp_status SVD_ADDRESS_GROUP ""

add_interface_port gp_status gp_status_0 export_0 Output 32
add_interface_port gp_status gp_status_1 export_1 Output 32


                
                 
                
                 
                 
                 
                 
                 
                 
                 
                 
                
                  
                