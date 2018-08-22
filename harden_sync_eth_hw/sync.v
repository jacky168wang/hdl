
// harden_frame_sync 
// auther : xj.z 
// version 1   time : 2018.1.31    
// version 2   time : 2018.2.27 Simplify the code        
// version 3   time : 2018.5.26 eth_mode  
// version 4   time : 2018.6.03 : Support bbu or RRU mode switching , symbol_trigger and 0_5ms_irq synchronizes with 1pps .
        
   
   /*****************************************************************/
   
   module  sync #(
   
   parameter FFT_SIZE = 2048 ,  // 4096, // IFFT size       
   parameter CP_LEN1  = 160  ,  // 320,       
   parameter CP_LEN2  = 144  ,  // 288,
   parameter TX_OR_RX = 1    ,  // 1:TX  0:RX   
   parameter FREQ     = 30720000//   Hz  
  
    )   
   (     
   //interface
   input   clk         ,  
   input   rst_n       ,
   
   input  mode         ,                                 
   input  pps_start    ,
   input  sync_enable  ,
   input  [31:0]delay  ,
   input  duty_ctrl    ,  // default : 0  100% duty
   output reg [3 : 0]  symbol_cnt   ,        
   output reg [7 : 0]  slot_cnt     ,                
   output reg [9 : 0]  frame_cnt    , 
   output reg [15: 0]  sample_cnt   ,
                      
   // output             
   output  trigger     ,
   output  long_cp                
   );   
   /*****************************************************************/ 
   // duty_ctrl   
   wire [3:0]data_fb_sym ; // front begin   
   wire [3:0]data_fe_sym ; // front end     
   wire [3:0]data_bb_sym ; // back begin    
   wire [3:0]data_be_sym ; // back end      
    
   assign  data_fb_sym  = duty_ctrl ?   1 :  1  ;
   assign  data_fe_sym  = duty_ctrl ?  11 : 10  ;
   assign  data_bb_sym  = duty_ctrl ?  13 : 12  ;
   assign  data_be_sym  = duty_ctrl ?  13 : 13  ;
   
   /****************************************************************/
    
   parameter  SYM_LEN    =  14   ;
   parameter  SLOT_LEN   =  20   ;
   parameter  SUBF_LEN   =  10   ;
   parameter  FRAM_LEN   =  512  ;        
                                                          	 
   reg  [32-1 : 0] time_cnt ;                                                                                                                                                                                    	
   wire [16-1 : 0] slen     ;  //cplen + ifftlen  

   /******************************************************************/
    reg   flag_sync1 ;
    reg   flag_sync0 ;
    wire  flag_sync  ; 
    reg   delay_start;   
    reg   [2:0]  i   ; 
          
    always@(posedge clk or negedge rst_n)                             
      if(!rst_n) begin       	                                                                   	                                         
        time_cnt <= 32'd0 ;    	                                                             
        flag_sync0 <= 1'b0 ;
        flag_sync1 <= 1'b0 ;		  
        delay_start <= 1'b0 ;
        i <= 3'd0 ;
      end 
      else 
      case(i)
      	0:  begin 
      		   time_cnt <=   32'd0  ;  
      		   i<= pps_start ? i+1'b1 : i ; 
      		   flag_sync1 <= 1'b1 ; 
      		   delay_start <= 1'b0 ;     		  
      		  end 
      	1:  if(time_cnt == delay) begin  
          		flag_sync0 <= 1;
          		flag_sync1 <= sync_enable ? 1'b0 : 1'b1 ;
          		delay_start <= sync_enable ? 1'b1 : 1'b0 ;
          		i<= sync_enable ? 3'd0 : i ;          	
          	end else begin          	
          		time_cnt <= time_cnt + 1'b1 ;
          	end 
        default : begin i <= 3'd0 ;end
      endcase 
    assign flag_sync = flag_sync0 & flag_sync1 ;  
    
    /***********************************************************/   
    // sample_cnt 
    always@(posedge clk or negedge rst_n)  
     if(!rst_n) begin
     	sample_cnt  <= 0;
    end
    else if(flag_sync)begin  	 
    	sample_cnt <= sample_cnt == slen -1 ? 0 : sample_cnt +1'b1;
    end else begin
    	sample_cnt <=0 ;
    end
    	
    /***********************************************************/                                                                 
    //        symbol_cnt                 
    always@( posedge clk or negedge rst_n )   
    if(!rst_n) begin      	
     symbol_cnt <=0;
    end
    else if( flag_sync && sample_cnt == slen -1) begin
    	symbol_cnt <= symbol_cnt == SYM_LEN - 1 ? 0 : symbol_cnt + 1 ;
    end else if(!flag_sync) begin
    	symbol_cnt <= 4'd0 ;
    end      
    /***********************************************************/                                                                 
    //        slot_cnt                 
    always@( posedge clk or negedge rst_n )   
    if(!rst_n) begin      	
     slot_cnt  <=0;
    end
    else if( flag_sync && ( symbol_cnt == SYM_LEN - 1  ) && sample_cnt == slen -1) begin
    	slot_cnt <= slot_cnt == SLOT_LEN - 1 ? 0 : slot_cnt + 1 ;
    end else if(!flag_sync) begin
    	slot_cnt <= 8'd0 ;
    end    
    /***********************************************************/                                          
    //       frame_cnt                  
    always@( posedge clk or negedge rst_n )                                                                         
    if(!rst_n)begin    
    	 frame_cnt <= 0; 
    end     	                                                                                                                            
    else if( (flag_sync && slot_cnt == SLOT_LEN - 1 && symbol_cnt == SYM_LEN - 1 && sample_cnt == slen -1 ) || (delay_start & slot_cnt == SLOT_LEN - 1 ) )begin 
    	frame_cnt <= frame_cnt == FRAM_LEN -1 ? 0 : frame_cnt + 1'b1 ;
    end else ; 
     
   ///***********************************************************/ 
    
   assign long_cp = flag_sync0 && symbol_cnt == 0 && sample_cnt < FFT_SIZE/2 && trigger;         
   assign slen = (flag_sync0 && symbol_cnt == 0 ) ? FFT_SIZE + CP_LEN1 : FFT_SIZE + CP_LEN2 ;
   assign trigger = mode ? (TX_OR_RX ? (flag_sync0 && sample_cnt < FFT_SIZE/2 && symbol_cnt <= data_fe_sym -1 ) : (flag_sync0 && sample_cnt < FFT_SIZE/2 && symbol_cnt >= data_bb_sym -1 &&  symbol_cnt <= data_be_sym -1)) : 
                         	(TX_OR_RX ? (flag_sync0 && sample_cnt < FFT_SIZE/2 && symbol_cnt >= data_bb_sym -1 &&  symbol_cnt <= data_be_sym -1) : (flag_sync0 && sample_cnt < FFT_SIZE/2 && symbol_cnt <= data_fe_sym -1 ) );                                    
                                                                                                                                           
  /************************************************************/ 
   
   endmodule       
   
   
          	                                                 
    
    
    
 
 
 
 
 
 
 
 
                                                               
 
 
 
 
 















