# TCL File Generated by Component Editor 16.1
# Fri Apr 13 14:14:00 GMT+08:00 2018
# DO NOT MODIFY


# 
# avlmm_out "avlmm_out" v1.0
#  2018.05.21.14:14:00
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module xg_ethernet
# 
set_module_property DESCRIPTION ""
set_module_property NAME avlmm_out
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "FACC 5G"
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME avlmm_out
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL avlmm_out
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file avlmm_out.sv SYSTEM_VERILOG PATH avlmm_out.sv TOP_LEVEL_FILE



# 
# parameters
# 
add_parameter WORD_WIDTH INTEGER 32
set_parameter_property WORD_WIDTH DEFAULT_VALUE 32
set_parameter_property WORD_WIDTH DISPLAY_NAME WORD_WIDTH
set_parameter_property WORD_WIDTH TYPE INTEGER
set_parameter_property WORD_WIDTH UNITS None
set_parameter_property WORD_WIDTH HDL_PARAMETER true

# 
# parameters
# 
add_parameter WORD_QTY INTEGER 10
set_parameter_property WORD_QTY DEFAULT_VALUE 10
set_parameter_property WORD_QTY DISPLAY_NAME WORD_QTY
set_parameter_property WORD_QTY TYPE INTEGER
set_parameter_property WORD_QTY UNITS None
set_parameter_property WORD_QTY HDL_PARAMETER true

# 
# parameters
# 
add_parameter ADDR_WIDTH INTEGER 5
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 5
set_parameter_property ADDR_WIDTH DISPLAY_NAME ADDR_WIDTH
set_parameter_property ADDR_WIDTH TYPE INTEGER
set_parameter_property ADDR_WIDTH UNITS None
set_parameter_property ADDR_WIDTH HDL_PARAMETER true

# 
# display items
# 


# 
# connection point clock
# 
                   
                                                                   
#                                                                  
# connection point clk                                          
#                                                                  
add_interface clk clock end                                     
set_interface_property clk clockRate 0                          
set_interface_property clk ENABLED true                         
set_interface_property clk EXPORT_OF ""                         
set_interface_property clk PORT_NAME_MAP ""                     
set_interface_property clk CMSIS_SVD_VARIABLES ""               
set_interface_property clk SVD_ADDRESS_GROUP ""                 
                                                                   
add_interface_port clk clk clk Input 1   

                                                         
# rst_n                                                                                     
add_interface rst_n reset end                                                        
set_interface_property rst_n associatedClock clk                              
set_interface_property rst_n synchronousEdges DEASSERT                               
set_interface_property rst_n ENABLED true                                            
set_interface_property rst_n EXPORT_OF ""                                            
set_interface_property rst_n PORT_NAME_MAP ""                                        
set_interface_property rst_n CMSIS_SVD_VARIABLES ""                                  
set_interface_property rst_n SVD_ADDRESS_GROUP ""                                    
                                                                                            
add_interface_port rst_n rst_n reset_n Input 1                                
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

#                                                             
# avalon_mm                                                         
#                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
 
add_interface avalon_mm avalon end                                                                                                                                                                                                                                                                                                                                                           
set_interface_property avalon_mm addressUnits WORDS                                                                                                                                                                                                                                                                                                                                          
set_interface_property avalon_mm associatedClock "clk"                                                                                                                                                                                                                                                                                                                                
set_interface_property avalon_mm associatedReset "rst_n"                                                                                                                                                                                                                                                                                                                              
set_interface_property avalon_mm bitsPerSymbol 8                                                                                                                                                                                                                                                                                                                                             
set_interface_property avalon_mm burstOnBurstBoundariesOnly false                                                                                                                                                                                                                                                                                                                            
set_interface_property avalon_mm burstcountUnits WORDS                                                                                                                                                                                                                                                                                                                                       
set_interface_property avalon_mm explicitAddressSpan 0                                                                                                                                                                                                                                                                                                                                       
set_interface_property avalon_mm holdTime 0                                                                                                                                                                                                                                                                                                                                                  
set_interface_property avalon_mm linewrapBursts false                                                                                                                                                                                                                                                                                                                                        
set_interface_property avalon_mm maximumPendingReadTransactions 0                                                                                                                                                                                                                                                                                                                            
set_interface_property avalon_mm maximumPendingWriteTransactions 0                                                                                                                                                                                                                                                                                                                           
set_interface_property avalon_mm readLatency 0                                                                                                                                                                                                                                                                                                                                               
set_interface_property avalon_mm readWaitTime 1                                                                                                                                                                                                                                                                                                                                              
set_interface_property avalon_mm setupTime 0                                                                                                                                                                                                                                                                                                                                                 
set_interface_property avalon_mm timingUnits Cycles                                                                                                                                                                                                                                                                                                                                          
set_interface_property avalon_mm writeWaitTime 0                                                                                                                                                                                                                                                                                                                                             
set_interface_property avalon_mm ENABLED true                                                                                                                                                                                                                                                                                                                                                
set_interface_property avalon_mm EXPORT_OF ""                                                                                                                                                                                                                                                                                                                                                
set_interface_property avalon_mm PORT_NAME_MAP ""                                                                                                                                                                                                                                                                                                                                            
set_interface_property avalon_mm CMSIS_SVD_VARIABLES ""                                                                                                                                                                                                                                                                                                                                      
set_interface_property avalon_mm SVD_ADDRESS_GROUP ""                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                                                      
add_interface_port avalon_mm address address Input ADDR_WIDTH                                                                                                                                                                                                                                                                                                                 
add_interface_port avalon_mm read read Input 1                                                                                                                                                                                                                                                                                                                            
add_interface_port avalon_mm readdata readdata Output WORD_WIDTH                                                                                                                                                                                                                                                                                                                  
add_interface_port avalon_mm waitrequest waitrequest Output 1                                                                                                                                                                                                                                                                                                             
add_interface_port avalon_mm write write Input 1                                                                                                                                                                                                                                                                                                                          
add_interface_port avalon_mm writedata writedata Input WORD_WIDTH

#                                                                      
# xgeth_rstn                                                           
#                                                                      
add_interface xgeth_rstn conduit end                                   
set_interface_property xgeth_rstn associatedClock  ""                  
set_interface_property xgeth_rstn associatedReset ""                   
set_interface_property xgeth_rstn ENABLED true                         
set_interface_property xgeth_rstn EXPORT_OF ""                         
set_interface_property xgeth_rstn PORT_NAME_MAP ""                     
set_interface_property xgeth_rstn CMSIS_SVD_VARIABLES ""               
set_interface_property xgeth_rstn SVD_ADDRESS_GROUP ""                 
                                                                       
add_interface_port xgeth_rstn data_out_0 export Output 32                                                                                                                                                                                                                                                                                                                                                                                                     

#                                                                            
# harden_sync_ctrl                                                                   
#                                                                            
add_interface harden_sync_ctrl conduit end                                           
set_interface_property harden_sync_ctrl associatedClock  ""                          
set_interface_property harden_sync_ctrl associatedReset ""                           
set_interface_property harden_sync_ctrl ENABLED true                                 
set_interface_property harden_sync_ctrl EXPORT_OF ""                                 
set_interface_property harden_sync_ctrl PORT_NAME_MAP ""                             
set_interface_property harden_sync_ctrl CMSIS_SVD_VARIABLES ""                       
set_interface_property harden_sync_ctrl SVD_ADDRESS_GROUP ""                         
                                                                             
add_interface_port harden_sync_ctrl data_out_1 export_0 Output 32  
add_interface_port harden_sync_ctrl data_out_2 export_1 Output 32  
add_interface_port harden_sync_ctrl data_out_3 export_2 Output 32                      
                                                                              
#                                                                            
# harden_tx_ctrl                                                                   
#                                                                            
add_interface harden_tx_ctrl conduit end                                           
set_interface_property harden_tx_ctrl associatedClock  ""                          
set_interface_property harden_tx_ctrl associatedReset ""                           
set_interface_property harden_tx_ctrl ENABLED true                                 
set_interface_property harden_tx_ctrl EXPORT_OF ""                                 
set_interface_property harden_tx_ctrl PORT_NAME_MAP ""                             
set_interface_property harden_tx_ctrl CMSIS_SVD_VARIABLES ""                       
set_interface_property harden_tx_ctrl SVD_ADDRESS_GROUP ""                         
                                                                             
add_interface_port harden_tx_ctrl data_out_4 export Output 32  
                                 
#                                                                                   
# harden_rx_ctrl                                                                    
#                                                                                   
add_interface harden_rx_ctrl conduit end                                            
set_interface_property harden_rx_ctrl associatedClock  ""                           
set_interface_property harden_rx_ctrl associatedReset ""                            
set_interface_property harden_rx_ctrl ENABLED true                                  
set_interface_property harden_rx_ctrl EXPORT_OF ""                                  
set_interface_property harden_rx_ctrl PORT_NAME_MAP ""                              
set_interface_property harden_rx_ctrl CMSIS_SVD_VARIABLES ""                        
set_interface_property harden_rx_ctrl SVD_ADDRESS_GROUP ""                          
                                                                                    
add_interface_port harden_rx_ctrl data_out_5 export Output 32    

#                                                                                     
# pack_ctrl                                                                           
#                                                                                                        
add_interface pack_ctrl conduit end                                                                                                                                       
set_interface_property pack_ctrl associatedClock  ""                                                                                                                      
set_interface_property pack_ctrl associatedReset ""                                   
set_interface_property pack_ctrl ENABLED true                                         
set_interface_property pack_ctrl EXPORT_OF ""                                         
set_interface_property pack_ctrl PORT_NAME_MAP ""                                     
set_interface_property pack_ctrl CMSIS_SVD_VARIABLES ""                               
set_interface_property pack_ctrl SVD_ADDRESS_GROUP ""                                 
                                                                                      
add_interface_port pack_ctrl data_out_6 export_0 Output 32                            
add_interface_port pack_ctrl data_out_7 export_1 Output 32                            
add_interface_port pack_ctrl data_out_8 export_2 Output 32                            
add_interface_port pack_ctrl data_out_9 export_3 Output 32          

#                                                                                   
# pe4312_ctrl                                                                    
#                                                                                   
add_interface pe4312_ctrl conduit end                                            
set_interface_property pe4312_ctrl associatedClock  ""                           
set_interface_property pe4312_ctrl associatedReset ""                            
set_interface_property pe4312_ctrl ENABLED true                                  
set_interface_property pe4312_ctrl EXPORT_OF ""                                  
set_interface_property pe4312_ctrl PORT_NAME_MAP ""                              
set_interface_property pe4312_ctrl CMSIS_SVD_VARIABLES ""                        
set_interface_property pe4312_ctrl SVD_ADDRESS_GROUP ""                          
                                                                                    
add_interface_port pe4312_ctrl data_out_10 export Output 32    


#                                                                                   
# rfio_ctrl                                                                    
#                                                                                   
add_interface rfio_ctrl conduit end                                            
set_interface_property rfio_ctrl associatedClock  ""                           
set_interface_property rfio_ctrl associatedReset ""                            
set_interface_property rfio_ctrl ENABLED true                                  
set_interface_property rfio_ctrl EXPORT_OF ""                                  
set_interface_property rfio_ctrl PORT_NAME_MAP ""                              
set_interface_property rfio_ctrl CMSIS_SVD_VARIABLES ""                        
set_interface_property rfio_ctrl SVD_ADDRESS_GROUP ""                          
                                                                                    
add_interface_port rfio_ctrl data_out_11 export Output 32    

                  
#                                                                                   
# gpio_system_top                                                                 
#                                                                                   
add_interface gpio_system_top conduit end                                            
set_interface_property gpio_system_top associatedClock  ""                           
set_interface_property gpio_system_top associatedReset ""                            
set_interface_property gpio_system_top ENABLED true                                  
set_interface_property gpio_system_top EXPORT_OF ""                                  
set_interface_property gpio_system_top PORT_NAME_MAP ""                              
set_interface_property gpio_system_top CMSIS_SVD_VARIABLES ""                        
set_interface_property gpio_system_top SVD_ADDRESS_GROUP ""                          
                                                                                    
add_interface_port gpio_system_top data_out_12 export Output 32    

                                                                                      