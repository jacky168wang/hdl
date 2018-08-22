
// Module:       eth_pusch


module  pack #( 
 parameter PACKET_ANTE_NUM = 8'd1,
 parameter SC_NUM = 3300,
 parameter ANTE_NUM = 8'd2,   
 parameter ARBIT_LEVEL = 2,
 parameter DATA_WIDTH = 64,
 parameter DATA_1G_WIDTH = 32   

)
(    
 input clk,
 input clk_1g,
 input rst_n,
 
 // connect harden_rx
 input [3:0]  ante0_block_used,   
 output       ante0_rx_rd_en,                 
 input [63:0] ante0_rx_data,  
 input        ante0_rx_valid,                 
 input [15:0] ante0_gain_factor,        
 input [ 7:0] ante0_symbol_index,        
 input [ 7:0] ante0_slot_index,          
 input [15:0] ante0_frame_index ,       

 input [3:0]  ante1_block_used,            
 output       ante1_rx_rd_en,              
 input [63:0] ante1_rx_data,               
 input        ante1_rx_valid,              
 input [15:0] ante1_gain_factor,           
 input [ 7:0] ante1_symbol_index,          
 input [ 7:0] ante1_slot_index,            
 input [15:0] ante1_frame_index ,    
 
 input [3:0]  ante2_block_used,         
 output       ante2_rx_rd_en,           
 input [63:0] ante2_rx_data,            
 input        ante2_rx_valid,           
 input [15:0] ante2_gain_factor,        
 input [ 7:0] ante2_symbol_index,       
 input [ 7:0] ante2_slot_index,         
 input [15:0] ante2_frame_index ,       
                                        
 input [3:0]  ante3_block_used,         
 output       ante3_rx_rd_en,           
 input [63:0] ante3_rx_data,            
 input        ante3_rx_valid,           
 input [15:0] ante3_gain_factor,        
 input [ 7:0] ante3_symbol_index,       
 input [ 7:0] ante3_slot_index,         
 input [15:0] ante3_frame_index ,  
 //
 input [31:0] dest_addr_l ,
 input [31:0] dest_addr_h ,  
 input [31:0] sour_addr_l ,
 input [31:0] sour_addr_h ,  
 
 // connect harden_sync            
 input [31:0]sync_din_data,             
 input       irq_1ms,              
 input [15:0]timing_frame_index,   
 input [15:0]timing_slot_index, 
  
 // avalon_st connect 1g_eth
 
 input din_sop , 
 input din_eop ,  
 input din_valid ,
 input [DATA_1G_WIDTH -1:0]din_data ,
 input [1:0]din_empty ,
 input din_erro ,  
                                               
 // avalon_st  connect 10g_eth 
 input  dout_ready,
 output dout_sop,                               
 output dout_eop,                          
 output dout_valid,                        
 output [DATA_WIDTH-1:0] dout_data,    
 output [2:0] dout_empty     
 );  
 
 /***************************************************************/
  localparam CHANNEL_QTY = ANTE_NUM + 2;
  localparam INDX_WIDTH = 10  ; 
  
  wire  [INDX_WIDTH-1:0] arbit_index; 
  wire  [ARBIT_LEVEL-1:0]arbit_request[CHANNEL_QTY-1 :0] ;
  wire  [CHANNEL_QTY-1 :0] arbit_grant ;                                                     
  wire  [CHANNEL_QTY-1 :0] arbit_eop ;                                                       
  wire  [CHANNEL_QTY-1 :0] arbit_din_sop;                                                    
  wire  [CHANNEL_QTY-1 :0] arbit_din_eop;                                                    
  wire  [CHANNEL_QTY-1 :0] arbit_din_valid;                                                  
  wire  [DATA_WIDTH-1:0] arbit_din_data[CHANNEL_QTY-1 :0] ;                                  
  wire   [2:0] arbit_din_empty[CHANNEL_QTY-1 :0];     
 
 /***************************************************************/   
                                                                                                          
  wire [3:0]block_used[ANTE_NUM-1:0]        ;                 
  wire [ANTE_NUM-1:0]rx_rd_en               ;                
  wire [DATA_WIDTH-1:0]rx_data[ANTE_NUM-1:0];                 
  wire [ANTE_NUM-1:0]rx_valid               ;                 
  wire [15:0]gain_factor[ANTE_NUM-1:0]      ;                
  wire [7:0]symbol_index[ANTE_NUM-1:0]      ;                 
  wire [7:0]slot_index[ANTE_NUM-1:0]        ;                 
  wire [15:0]frame_index[ANTE_NUM-1:0]      ;               
                             
  assign   block_used[0] = ante0_block_used;            
  assign      rx_data[0] = ante0_rx_data;                             
  assign     rx_valid[0] = ante0_rx_valid;                          
  assign  gain_factor[0] = ante0_gain_factor;                     
  assign symbol_index[0] = ante0_symbol_index;                   
  assign   slot_index[0] = ante0_slot_index;                      
  assign  frame_index[0] = ante0_frame_index ; 
  assign  ante0_rx_rd_en = rx_rd_en[0];                    
              
  assign   block_used[1] = ante1_block_used;       
  assign      rx_data[1] = ante1_rx_data;          
  assign     rx_valid[1] = ante1_rx_valid;               
  assign  gain_factor[1] = ante1_gain_factor;                                   
  assign symbol_index[1] = ante1_symbol_index;                             
  assign   slot_index[1] = ante1_slot_index;                               
  assign  frame_index[1] = ante1_frame_index ;               
  assign  ante1_rx_rd_en = rx_rd_en[1];      
 
  util_arbitmux #(     
  .DATA_WIDTH(DATA_WIDTH),
  .CHANNEL_QTY(CHANNEL_QTY),
  .MUX_SW_DELAY(2), 
  .ARBIT_LEVEL(ARBIT_LEVEL),
  .ARBIT_ALGORITHM(1), 
  .ARBIT_CLK_STAGGER(1'b1),
  .INDX_WIDTH(10)
  )  
  util_arbitmux_inst
  (
  .clk          (clk),     
  .rst_n        (rst_n), 
  .din_sop      (arbit_din_sop), 
  .din_eop      (arbit_din_eop  ),
  .din_valid    (arbit_din_valid),
  .din_data     ('{arbit_din_data[3],arbit_din_data[2],arbit_din_data[1],arbit_din_data[0]}),
  .din_empty    ('{arbit_din_empty[3],arbit_din_empty[2],arbit_din_empty[1],arbit_din_empty[0]}),
  .arbit_request('{arbit_request[3],arbit_request[2],arbit_request[1],arbit_request[0]}),    
  .arbit_eop    (arbit_eop ),         
  .arbit_grant  (arbit_grant    ),
  .arbit_index  (arbit_index    ),
  .dout_sop     (dout_sop       ),
  .dout_eop     (dout_eop       ),
  .dout_valid   (dout_valid     ),
  .dout_data    (dout_data      ),
  .dout_empty   (dout_empty     )  
  );
 
 
 /***************************************************************/
	genvar i;                                                  
	generate                                                                                                                        
	for (i =0; i < CHANNEL_QTY -2 ; i = i+1)
	begin: pusch_packet_loop     
	
	pusch_packet  #(
	 .SC_NUM (SC_NUM), 
	 .RX_BLOCK_USED (8),  
	 .ANTE_NUM(PACKET_ANTE_NUM)       
 )  
   pusch_packet_inst 
 (
   .clk          (clk               ),  
   .rst_n        (rst_n             ),
   .dest_addr_l  (dest_addr_l       ),
   .dest_addr_h  (dest_addr_h       ),  
   .sour_addr_l  (sour_addr_l       ), 
   .sour_addr_h  (sour_addr_h       ),
   .arbit_request(arbit_request[i+1]  ),
   .arbit_grant  (arbit_grant[i+1]    ),
   .arbit_eop    (arbit_eop[i+1]      ),
   .block_used   (block_used[i]   ),
   .rx_rd_en     (rx_rd_en[i]     ),
   .rx_data      (rx_data[i]      ),
   .rx_valid     (rx_valid[i]     ),
	.ante_index   ( i              ),
   .gain_factor  (gain_factor[i]  ),
   .symbol_index (symbol_index[i] ),
   .slot_index   (slot_index[i]   ),
   .frame_index  (frame_index[i]  ),  
   .dout_ready   (1'b1            ),
   .dout_sop     (arbit_din_sop[i+1]  ),
   .dout_eop     (arbit_din_eop[i+1]  ),
   .dout_valid   (arbit_din_valid[i+1]), 
   .dout_data    (arbit_din_data[i+1] ),
   .dout_empty   (arbit_din_empty[i+1]),
   .dout_error   (                  )
 );      
  end
  endgenerate	
  
  /*************************************************************/
  
  timing_packet timing_packet_inst
 (
   .clk           (clk               ),  
   .rst_n         (rst_n             ), 
   .din_data      (sync_din_data     ),   
   .irq_1ms       (irq_1ms           ),   
   .frame_index   (timing_frame_index),   
   .slot_index    (timing_slot_index ),
   .dest_addr_l   (dest_addr_l       ),
   .dest_addr_h   (dest_addr_h       ),  
   .sour_addr_l   (sour_addr_l       ), 
   .sour_addr_h   (sour_addr_h       ),   
   .packet_request(arbit_request[0]),
   .packet_grant  (arbit_grant[0]), 
   .packet_eop    (arbit_eop[0]), 
   .dout_ready    (1'b1              ),       
   .dout_sop      (arbit_din_sop[0]  ),         
   .dout_eop      (arbit_din_eop[0]  ),         
   .dout_valid    (arbit_din_valid[0]),         
   .dout_data     (arbit_din_data[0] ),         
   .dout_empty    (arbit_din_empty[0]),         
   .dout_error    (                  )          
                  
  );

  /*************************************************************/     
  avlst_32to64 #(   
    .DATA_WIDTH_RD(64),
    .DATA_WIDTH_WR(DATA_1G_WIDTH),                                    
    .WORD_ADDR_LEN_WR(4096),                 
    .WORD_ADDR_LEN_RD(2048),                 
    .PACK_ADDR_LEN(127)                                            
  ) avlst_inst (                                         
    .clk_wr(clk_1g),                                      
    .clk_rd(clk),                                      
    .rst_n(rst_n),                                       
    .din_ready(),                           
    .din_restart(1'b0),                     
    .din_sop(din_sop),                                   
    .din_eop(din_eop),                                   
    .din_valid(din_valid),                               
    .din_data(din_data),                                 
    .din_empty(din_empty),                               
    .dout_drop(1'b0),                           
    .dout_repeat(1'b0),                           
    .arbit_grant( arbit_grant[CHANNEL_QTY-1]),                           
    .arbit_request(arbit_request[CHANNEL_QTY-1] ),                       
    .arbit_eop(arbit_eop[CHANNEL_QTY-1]),                               
    .dout_sop(arbit_din_sop[CHANNEL_QTY-1]),                                 
    .dout_eop(arbit_din_eop[CHANNEL_QTY-1]),                                 
    .dout_valid(arbit_din_valid[CHANNEL_QTY-1]),                             
    .dout_data(arbit_din_data[CHANNEL_QTY-1]),                               
    .dout_empty(arbit_din_empty[CHANNEL_QTY-1]),                              
    .dout_index(),                                        
    .din_index(),                                         
    .overflow_cnt(),                                      
    .pack_used(),                                         
    .word_used(),                                                                          
    .used_full(),                                         
    .used_empty()                                         
  );  
  
 endmodule                                                    





   
   
   
   
   
   
               