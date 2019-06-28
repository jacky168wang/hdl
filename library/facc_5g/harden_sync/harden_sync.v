// harden_sync 
// auther : xj.z  version 8.0
// version 1.0   time : 2018.01.30  
// version 2.0   time : 2018.05.26 : Eth_mode , ante_switch added. 
// version 3.0   time : 2018.06.03 : Support bbu or RRU mode switching , symbol_trigger and 0_5ms_irq synchronizes with 1pps .
// version 4.0   time : 2018.06.08 : Support trigger duty contrl . 
// version 5.0   time : 2018.09.28 : Add subframe_boundary flag bit .
// version 6.0   time : 2018.10.10 : Parse the received CSR packet for Slot Format configuration .     
// version 6.1   time : 2018.10.11 : Fixed frame format configuration(temporary version) . 
// version 7.0   time : 2018.12.12 : CMCC time_delay & time_ahead added .           
//         7.1   time : 2019.04.13 : add tdd_trig module by jf.     
//         8.0   time : 2019/04/12 : add calibration_enable by jf.  
//         8.1   time : 2019/05/06 : 0.5ms delay 1pps / 38141 & cmcc protocol supported.  
//         8.2   time : 2019/05/07 : add trigger&lcp signal to gpio.  

   /*****************************************************************/
   
   module  harden_sync #(
                                                             
   parameter FFT_SIZE = 4096 , //FFT size                    
   parameter TX_FREQ  = 61440, //KHZ     
   parameter RX_FREQ  = 122880,//KHZ     122.8 for sim
   parameter CP_LEN1  = 352,   //long_cp           
   parameter CP_LEN2  = 288    //short_cp                 
    )   
   (     
   //input
   input   clk_rx          , 
   input   clk_tx          ,	
   input   rst_n           ,                              
   (* mark_debug = "true" *)input   pps_in          ,
   input   subf_bd         ,//subframe_boundary
   
   input  [31:0]sync_ctrl  ,
  // input  [27:0]slot_config,  
                                 //   bs     ue
   input  [31:0]tx_ahead_time  , //    0   1600
   input  [31:0]tx_delay_time  , //    0      0
   input  [31:0]rx_ahead_time  , // 1600      0
   input  [31:0]rx_delay_time  , //  220    220
  
   // connect  timing_packet
   output [ 7 : 0] slot_cnt_abs ,       
   output [ 15: 0] frame_cnt_abs ,
   output reg irq_1ms      ,            
                      
   // connect harden_tx          
   (* mark_debug = "true" *)output tx_trigger       ,
   (* mark_debug = "true" *)output tx_lcp           ,
   (* mark_debug = "true" *)output [3 :0]tx_symbol_cnt ,                  
   output [7 :0]tx_slot_cnt   ,                  
   output [9 :0]tx_frame_cnt  ,                  
   
   //connect harden_rx  
   (* mark_debug = "true" *)output rx_trigger       ,
   (* mark_debug = "true" *)output rx_lcp           ,
   (* mark_debug = "true" *)output mode             ,
   (* mark_debug = "true" *)output [3 :0]rx_symbol_cnt ,               
   output [7 :0]rx_slot_cnt   ,               
   output [9 :0]rx_frame_cnt  ,               
  
   // ante_switch
   output     ante_enable  ,
   output reg ante0_switch , // 0 :RX  / 1:TX
   output reg ante1_switch ,
   
   output debug_rx_trigger       , 
   output debug_rx_lcp           ,  
   output debug_tx_trigger       ,  
   output debug_tx_lcp           ,  
   
   //
   (* mark_debug = "true" *)output  trig_rf_gpio,
   (* mark_debug = "true" *) input  calib_enable
              
   );
  /******************************************************************/
    assign debug_rx_trigger   =  rx_trigger ;
    assign debug_rx_lcp       =  rx_lcp     ;   
    assign debug_tx_trigger   =  tx_trigger ;   
    assign debug_tx_lcp       =  tx_lcp     ;     
    
  /******************************************************************/
    assign slot_cnt_abs  =  rx_slot_cnt  ;
    assign frame_cnt_abs =  rx_frame_cnt ;   
  /******************************************************************/
  // enable control  //duty_control 
  wire enable ;   
  wire disable_1ms  ; 
  wire sync_enable ; 
  wire calibration_enable;
  wire protocl_select;
     
  assign enable =  sync_ctrl[0] ; 
  assign disable_1ms  = sync_ctrl[1] ;                                                                                                           
  assign mode = sync_ctrl[4] ; 
  assign sync_enable = sync_ctrl[5] ;   
  assign ante_enable = sync_ctrl[8] ;
  assign protocl_select = sync_ctrl[12] ;    //00:cmcc   01:38141                
                                                                                                        
	/*****************************************************************/  
	// enable_ctrl
	wire rx_flag_sync;
	reg  rx_flag_sync_r;
	wire tx_flag_sync; 
	reg tx_flag_sync_r;
	
   always@(posedge clk_tx or negedge rst_n)                                  
     if(!rst_n)                                                           
        begin  tx_flag_sync_r  <= 0; end                                    
     else                                                                 
        begin  tx_flag_sync_r <= tx_flag_sync;  end                    	
	
	   always@(posedge clk_rx or negedge rst_n)                                  
     if(!rst_n)                                                           
        begin  rx_flag_sync_r  <= 0; end                                    
     else                                                                 
        begin  rx_flag_sync_r <= rx_flag_sync;  end        
	
	
	
	
	
	
	
	wire rst_n_en;   
  reg [1:0]rst_cnt ;
  reg rst_done ;

  always @(posedge clk_tx or negedge enable) begin
    if(! enable) begin
      rst_done <= 1'b0;
      rst_cnt  <= 2'd0;
    end
    else if(rst_cnt == 2'd3) begin
      rst_done <= 1'b1;
    end
    else begin
      rst_cnt <= rst_cnt + 1'b1;
    end
  end
  assign rst_n_en = rst_n & rst_done;     	
	/*****************************************************************/
   //synchronize  pps_start                                        
   reg   [1:0] pps_in_r ;                                                 
   (* mark_debug = "true" *)wire  pps_start ;                                                      
                                                                          
   always@(posedge clk_tx or negedge rst_n)                                  
     if(!rst_n)                                                           
        begin  pps_in_r  <= 2'b11; end                                    
     else                                                                 
        begin  pps_in_r <= {pps_in_r[0],pps_in} ;  end                    
                                                                          
    assign pps_start =  (pps_in_r[0]&&(!pps_in_r[1]))? 1 : 0;   
    
  /*****************************************************************/   
   wire sync_start  ;
   
   assign  sync_start = pps_start ;    //temporary      
   //assign sync_start = mode ? pps_start | subf_bd : subf_bd ;   //final     
	/*****************************************************************/   
   wire  [15:0]rx_sample_cnt ;  
   wire  [15:0]tx_sample_cnt ;     
   wire  [31:0]rx_time;
   wire  [31:0]tx_time;

	 assign	rx_time = RX_FREQ*10 - rx_ahead_time + rx_delay_time  ;
	 assign tx_time = TX_FREQ*10 - (tx_ahead_time>>1) + (tx_delay_time>>1)  ; 

	/*****************************************************************/
	 // Slot Format configuration / 00:switch / 01:tx / 10:rx / 11:tx&rx 
	 localparam PROTCL_NUM = 10 ;
	 
	 reg  [27:0]slot_config ; 
	 wire [27:0]slot_format[PROTCL_NUM-1:0] ;
	 reg  [ 4:0]i;
	 assign slot_format[0] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_tttt_tttt                                                                                                                                                                                          
	 assign slot_format[1] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_tttt_tttt	                                                                                                                                                                                        
	 assign slot_format[2] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_tttt_tttt	
	 assign slot_format[3] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b1010_00000000_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b0101_00000000_10101010_10101010 );
	 assign slot_format[4] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b1010_10101010_10101010_10101010  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b0101_01010101_01010101_01010101 );//bs :tt_tttt_tttt_tttt		 
	 assign slot_format[5] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_tttt_tttt                                                                                                                                                                                          
	 assign slot_format[6] = mode ? (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_tttt_tttt		  	                                                                                                                                                                                       
	 assign slot_format[7] = mode ? (protocl_select ? 28'b1010_10100000_00000101_01010101 : 28'b0101_01010101_01010101_01010101  ): (protocl_select ? 28'b0101_01010000_00001010_10101010 : 28'b1010_10101010_10101010_10101010 );//bs :tt_tttt_ttss_ssrr	 	                                                                                                                                                                                      
	 assign slot_format[8] = mode ? (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_00000000_01010101_01010101  ): (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_00000000_10101010_10101010 );//bs :rr_rrrr_rrrr_rrrr	 
	 assign slot_format[9] = mode ? (protocl_select ? 28'b1010_10101010_10101010_10101010 : 28'b1010_10101010_10101010_10101010  ): (protocl_select ? 28'b0101_01010101_01010101_01010101 : 28'b0101_01010101_01010101_01010101 );//bs :rr_rrrr_rrrr_rrrr	 	 
	 	                                                                                                                                                                                        
	 
 always@(posedge clk_rx or negedge rst_n_en)     	
    if(!rst_n_en)begin   
     	slot_config  <= slot_format[0];
     	i <= 1;
    end 
    else if( ~rx_flag_sync )begin
    	slot_config  <=  slot_format[0] ; 
    	i <= 1;      
    end 	             
    else if( rx_symbol_cnt == 14 - 3 && rx_sample_cnt == FFT_SIZE -1 )begin    
    	slot_config  <=  slot_format[i] ;
    	i <= i == PROTCL_NUM-1  ? 0 : i + 1;           
    end
    
  /*****************************************************************/         	              		 	 	 	    
	 wire [13:0] tx_config ;     
	 wire [13:0] rx_config ;   
	 wire [13:0] switch_config;  
	 
	 assign  tx_config = {slot_config[26],slot_config[24],slot_config[22],slot_config[20],slot_config[18],slot_config[16],slot_config[14],
	                      slot_config[12],slot_config[10],slot_config[ 8],slot_config[ 6],slot_config[ 4],slot_config[ 2],slot_config[ 0]}; 
	 assign  rx_config = {slot_config[27],slot_config[25],slot_config[23],slot_config[21],slot_config[19],slot_config[17],slot_config[15],           	                   
	                      slot_config[13],slot_config[11],slot_config[ 9],slot_config[ 7],slot_config[ 5],slot_config[ 3],slot_config[ 1]};   
	 assign  switch_config = ~( tx_config | rx_config);                         	                          	
	  
	 reg [13:0] tx_tx_config_r ;
	 reg [13:0] tx_rx_config_r ; 
	 reg [13:0] tx_switch_config_r ; 
	 reg [13:0] rx_tx_config_r ;       	 
	 reg [13:0] rx_rx_config_r ;       	  
	 reg [13:0] rx_switch_config_r ;  	 
	 
	 always@(posedge clk_rx or negedge rst_n_en)     	
     if(!rst_n_en)begin                           	     	    
     	  rx_rx_config_r <= rx_config ; 
     	  rx_tx_config_r <= tx_config ; 
     	  rx_switch_config_r <= switch_config ;        	        	      	                
	   end 
	   else if( (rx_symbol_cnt == 14 - 1 && rx_sample_cnt == FFT_SIZE + CP_LEN2 -1) |   ~rx_flag_sync_r   )begin   
	    	rx_rx_config_r <=  |slot_config ? rx_config : (mode ? 14'b00011111111111 : 14'b01000000000000 );   
	    	rx_tx_config_r <=  |slot_config ? tx_config : (mode ? 14'b00011111111111 : 14'b01000000000000 );           
	    	rx_switch_config_r <= switch_config  ;     	    		    	
	 	 end else begin 
	 	 	  rx_rx_config_r <= rx_rx_config_r;  
	 	 	  rx_tx_config_r <= rx_tx_config_r;   
	 	 	  rx_switch_config_r <= rx_switch_config_r ; 	  	 	 	 	 	 	  	 	 
	 	 end		                                   
	 	 
	 always@(posedge clk_tx or negedge rst_n_en)     	                                                       	 	 
     if(!rst_n_en)begin                           	                                                       	 	 
     	  tx_rx_config_r <= rx_config ;               
     	  tx_tx_config_r <= tx_config ;               
     	  tx_switch_config_r <= switch_config ;                                	 	     	                                                                         	 	      	    	                                                           	 	 
	   end                                                                                                   	 	 
	   else if( (tx_symbol_cnt == 14 - 1 && tx_sample_cnt == (FFT_SIZE + CP_LEN2)/2 -1)  |   ~tx_flag_sync_r  )begin                               	 	 
	    	tx_rx_config_r <=  |slot_config ? rx_config : (mode ? 14'b00011111111111 : 14'b01000000000000 );                    
	    	tx_tx_config_r <=  |slot_config ? tx_config : (mode ? 14'b00011111111111 : 14'b01000000000000 );                    
	    	tx_switch_config_r <= switch_config  ;     	    		    	                                                           	 
	 	 end else begin                                                                                        	 	 
		 	 	tx_rx_config_r <= tx_rx_config_r ;                       
		 	 	tx_tx_config_r <= tx_tx_config_r ;                       
		 	 	tx_switch_config_r <= tx_switch_config_r ; 	  	 	 	 	                              	 	 	 	 	                                                                     	 	 	 	 	  	 	                                                                 	 	 
	 	 end		                                                                                               	 	 	 	 	 	 	 	 
	 	 
	/*****************************************************************/             	
	// ante_switch
  wire   [3 :0]symbol_cnt ;    	
  wire   [15:0]sample_cnt ;    	
  wire   [15:0]sample_num ;  
  
  assign symbol_cnt = mode ? rx_symbol_cnt : tx_symbol_cnt ;                                
  assign sample_cnt = mode ? rx_sample_cnt : tx_sample_cnt ;                                
  assign sample_num = mode ? FFT_SIZE : FFT_SIZE/2 ; 	                                        	
	
	always@(posedge clk_tx or negedge rst_n_en)                                                                                                                                                                                                                                                                                                                                                                  
     if(!rst_n_en)begin                                                    
     	ante0_switch <= mode ? 1'b1 : 1'b0 ;                                         
     	ante1_switch <= mode ? 1'b1 : 1'b0 ;                                           
    end  
    else begin    
    	case(mode)
        0: 
            if ( tx_rx_config_r[tx_symbol_cnt]||(tx_switch_config_r[tx_symbol_cnt] && tx_rx_config_r[tx_symbol_cnt-1] && tx_sample_cnt <= (FFT_SIZE+CP_LEN2)/2-1) )begin                                                                                                                                                
             ante0_switch <= 1'b0 ;                                                                                         
             ante1_switch <= 1'b0 ;                                                                                        
            end                                  
            else begin                                                                                          
            	ante0_switch <= 1'b1  ;                              
            	ante1_switch <= 1'b1  ; 
            end                                                                                                                                 
        1: 
            if ( rx_tx_config_r[rx_symbol_cnt]||(rx_switch_config_r[rx_symbol_cnt] && rx_tx_config_r[rx_symbol_cnt-1] && rx_sample_cnt <= FFT_SIZE+CP_LEN2-1) )begin
             ante0_switch <= 1'b1;                                                                                      
             ante1_switch <= 1'b1;                                                                                      
            end                                     
            else begin                                                                                            
            	ante0_switch <= 1'b0;                               
            	ante1_switch <= 1'b0;                                                                                
            end  
        default ; 
      endcase
    end                      
   // irq_1ms
	always@(posedge clk_rx or negedge rst_n_en)                             
     if(!rst_n_en)begin 
     	irq_1ms <= 1'b0 ;
    end
    else begin
    	irq_1ms <= (rx_symbol_cnt == 2 - 1 )&&(rx_sample_cnt == FFT_SIZE )  ;
    end                                                  
		

		
	/*******************************************************************/	
    
    sync # (
        .FFT_SIZE  (FFT_SIZE>>1),        
        .CP_LEN1   (CP_LEN1>>1 ), 
        .CP_LEN2   (CP_LEN2>>1 ),
        .TX_OR_RX  ( 1         ) //tx      
    )  
      sync_tx_inst(      
      .clk        (clk_tx           ),   
      .rst_n      (rst_n_en         ),
      .mode       (tx_tx_config_r   ),
      .sync_start (sync_start       ),
      .sync_enable(sync_enable      ),
      .delay      (tx_time          ),  
      .trigger    (tx_trigger       ),
      .long_cp    (tx_lcp           ),
      .sample_cnt (tx_sample_cnt    ),
      .symbol_cnt (tx_symbol_cnt    ),                
      .slot_cnt   (tx_slot_cnt      ),  
      .flag_sync  (tx_flag_sync      ),              
      .frame_cnt  (tx_frame_cnt     )                         
      );

   sync # (
        .FFT_SIZE  (FFT_SIZE),        
        .CP_LEN1   (CP_LEN1 ), 
        .CP_LEN2   (CP_LEN2 ),
        .TX_OR_RX  ( 0         ) //rx             
    )  
      sync_rx_inst(      
      .clk        (clk_rx           ),   
      .rst_n      (rst_n_en         ),
      .mode       (rx_rx_config_r    ),      
      .sync_start (sync_start       ),
      .sync_enable(sync_enable      ),      
      .delay      (rx_time          ),  
      .trigger    (rx_trigger       ),
      .long_cp    (rx_lcp           ),           
      .sample_cnt (rx_sample_cnt    ),        
      .symbol_cnt (rx_symbol_cnt    ), 
      .slot_cnt   (rx_slot_cnt      ),
      .flag_sync  (rx_flag_sync      ),
      .frame_cnt  (rx_frame_cnt     )
      ); 
       
    /*****************************************************************/
    
	 tdd_trig #(
    .RX_FREQ ( RX_FREQ )
    )
   ins_tdd_trig(  
	  .clk(clk_rx),
	  .rst_n(rst_n),	
	  .pps_start(pps_start),	
	  .sync_enable(sync_enable),
    .calibration_enable(calib_enable),
    .rx_ahead_time(tx_ahead_time)  ,
    .rx_delay_time(tx_delay_time)  ,      
    .trig_rf_gpio(trig_rf_gpio)	   
   );
	
	
	
	
	
	
	
	
	

	
	
  endmodule