//      2018.07.02      YJF       arbit_grant    is    64to32  fifo   output   ready  
//      2018.10.16      YJF       BIT_WIDTH  is  error in  xilinx   ip  packer 
//			2018.12.17			Linda			for the test of channel-multiplexing  
//			2018.05.02			Linda			a new register is added, for the loopback and non-loopback situation


module unpack		#(
	parameter		ETH_TYPE_NUM = 2,
	parameter		ANTE_C_IQ_NUM = 4,
	parameter		ANTE_INDEX_NUM = 5,	
	parameter		REPEAT_C_NUM =0,
	parameter		REPEAT_INDEX_NUM =1,
	parameter		HEADER_NUM = 6,
	parameter		REPEAT_HEADER_NUM =2,
	parameter		ANTE_NUM = 4,	
	parameter		SCS_NUM = 3276, 
	parameter		FISRT_IQ_BLOCK_NUM = 	HEADER_NUM + SCS_NUM/4,
	parameter		OTHER_IQ_BLOCK_NUM =  REPEAT_HEADER_NUM + SCS_NUM/4,
	//parameter		HEADER_WIDTH = BIT_WIDTH(HEADER_NUM),
	//parameter		FISRT_IQ_BLOCK_WIDTH = BIT_WIDTH(FISRT_IQ_BLOCK_NUM),
	//parameter		OTHET_IQ_BLOCK_WIDTH = BIT_WIDTH(OTHER_IQ_BLOCK_NUM),
	parameter 	IQ_BLOCK_NUM = ( HEADER_NUM > REPEAT_HEADER_NUM ) ? FISRT_IQ_BLOCK_NUM : OTHER_IQ_BLOCK_NUM,
	//parameter 	IQ_BLOCK_WIDTH = BIT_WIDTH(IQ_BLOCK_NUM),
	//parameter		MAX_NUM_WIDTH = BIT_WIDTH(FISRT_IQ_BLOCK_NUM +(ANTE_NUM-1)* OTHER_IQ_BLOCK_NUM),
	//parameter		DATA_BLOCK_WIDTH =BIT_WIDTH(SCS_NUM/4),
	
	parameter DATA_WIDTH_WR = 64,                 // write data bit width
  parameter DATA_WIDTH_RD = 32,                  // read data bit width
  parameter WORD_ADDR_LEN_WR = 4096,            // write word address maximum length
  parameter WORD_ADDR_LEN_RD = 32768,           // read word address maximum length
  parameter OFFS_ADDR_LEN_WR = 1520*8/DATA_WIDTH_WR,
                                                // write offset address maximum length
  parameter PACK_ADDR_LEN = 127,                // packet address maximum length
/*   parameter PACK_ADDR_WIDTH = BIT_WIDTH(PACK_ADDR_LEN),
                                                // packet address bit width, able to represent maximum PACK_ADDR_LEN required.
  parameter WORD_ADDR_WIDTH_WR = BIT_WIDTH(WORD_ADDR_LEN_WR-1),
                                                // write word address bit width, able to represent maximum 'WORD_ADDR_LEN_WR - 1' required.
  parameter WORD_ADDR_WIDTH_RD = BIT_WIDTH(WORD_ADDR_LEN_RD-1), */
  
  
  parameter PACK_ADDR_WIDTH = 7,
                                                // packet address bit width, able to represent maximum PACK_ADDR_LEN required.
  parameter WORD_ADDR_WIDTH_WR = 12,
                                                // write word address bit width, able to represent maximum 'WORD_ADDR_LEN_WR - 1' required.
  parameter WORD_ADDR_WIDTH_RD = 15,
  
  
                                                // read word address bit width, able to represent maximum 'WORD_ADDR_LEN_RD - 1' required.
 // parameter EMPT_WIDTH_WR = BIT_WIDTH(DATA_WIDTH_WR/8-1),
                                                // write empty bit width, able to represent maximum 'DATA_WIDTH_WR/8 - 1' required.
  parameter EMPT_WIDTH_RD = 2,
                                                // read empty bit width, able to represent maximum 'DATA_WIDTH_RD/8 - 1' required.
  parameter DATA_BIG_ENDIAN = 1'b1,             // data big endian
  parameter DOUT_READY_REQ = 1'b0               // output ready as request	
	
	)
	(
	//clock & reset
	input clk_in,    //clk_wr
	input	clk_rd,
	input	rst_n,			//low active
	
	//control_register
	//[0]=1 loopback,[0]=0 non-loopback
	input	[31:0]	loopback_ctrl,				
	
	// input
	input  wire [63:0]  din_data,                            
	input  wire         din_valid,                                                      
	input  wire         din_sop,                    
	input  wire         din_eop,                      
	input  wire [2:0]   din_empty,                          
	input  wire         din_error,  
	output wire 				mac_avalon_st_tx_ready,
	
	//input to 64to32
 // input dout_drop,                              // output data drop
//  input dout_repeat,                            // output data repeat 
  input arbit_grant,                           // arbitrate grant, or output ready	
  	
	//to harden_tx

	output wire					dout_ante_valid,	
	output wire         dout_ante_sop,
	output wire         dout_ante_eop,
	output wire[63:0]		dout_ante_data,
	output wire[15:0]		frame_ante_index,
	output wire[7:0]		slot_ante_index,
	output wire[7:0]		symbol_ante_index, 
	output wire[7:0]		antenna_index,
	

	//packfifo's output
  output [1:0] arbit_request,                   // arbitrate request, bit 0 - general request, bit 1 - critical request.
  output arbit_eop,                             // arbitrate end of packet
  
  
  output dout_sop,                              // output start of packet
  output dout_eop,                              // output end of packet
  output dout_valid,                            // output data valid
  output wire [DATA_WIDTH_RD-1:0] dout_data,     // output data
  output [(EMPT_WIDTH_RD > 0 ? 
           EMPT_WIDTH_RD-1:0):0] dout_empty,    // output empty
  output [WORD_ADDR_WIDTH_RD-1:0] dout_index,   // output data index
  output [WORD_ADDR_WIDTH_WR-1:0] din_index,    // input data index
  
  output wire [31:0] overflow_cnt,               // packet overflow count
  output [PACK_ADDR_WIDTH-1:0]  pack_used,      // packet used quantity, minimum 0 and maximum PACK_ADDR_LEN.
  output [WORD_ADDR_WIDTH_WR:0] word_used,      // word used quantity, minimum 0 and maximum WORD_ADDR_LEN_WR.
  output [WORD_ADDR_WIDTH_WR:0] word_used_pre,  // predictive word used quantity, minimum 1 and maximum over WORD_ADDR_LEN_WR.
  output used_full,                             // packet or word used full
  output used_empty                             // packet and word used empty
	
	);

wire [63:0]	mac_avalon_st_tx_data   ;
wire       	mac_avalon_st_tx_valid  ;
wire       	mac_avalon_st_tx_sop    ;
wire       	mac_avalon_st_tx_eop    ;
wire [2:0] 	mac_avalon_st_tx_empty  ;
wire       	mac_avalon_st_tx_error  ;

assign    mac_avalon_st_tx_data  = din_data; 
assign    mac_avalon_st_tx_valid = din_valid;
assign    mac_avalon_st_tx_sop   = din_sop;  
assign    mac_avalon_st_tx_eop   = din_eop;  
assign    mac_avalon_st_tx_empty = din_empty;
assign    mac_avalon_st_tx_error = din_error;


wire						dout_arm_restart ;
wire						dout_arm_valid   ;
wire						dout_arm_sop     ;
wire						dout_arm_eop     ;
wire[2:0]				dout_arm_empty   ;
wire[63:0]			dout_arm_dataout ;



  /************************************************/
  /*                    dl_distributor            */
  /************************************************/
	dl_distribt#(
	.SCS_NUM(SCS_NUM)
	)	distribt_inst 
	(
		.clk_in														(clk_in    ), 
		.rst_n                            (rst_n         ), 
		
		.mode_ctrl												(loopback_ctrl),
		                                  
		.mac_avalon_st_tx_data            (mac_avalon_st_tx_data              ),      
		.mac_avalon_st_tx_valid           (mac_avalon_st_tx_valid             ),  
		.mac_avalon_st_tx_startofpacket   (mac_avalon_st_tx_sop     ),  
		.mac_avalon_st_tx_endofpacket     (mac_avalon_st_tx_eop       ),  
		.mac_avalon_st_tx_empty           (mac_avalon_st_tx_empty    ),  
		.mac_avalon_st_tx_error           (mac_avalon_st_tx_error    ),  
		.mac_avalon_st_tx_ready           (mac_avalon_st_tx_ready    ),  
		                                                                  
		.dout_arm_restart                  (dout_arm_restart      ),  
		.dout_arm_valid                    (dout_arm_valid        ),  
		.dout_arm_sop                      (dout_arm_sop          ),  
		.dout_arm_eop                      (dout_arm_eop          ),  
		.dout_arm_empty                    (dout_arm_empty        ),  
		.dout_arm_dataout                  (dout_arm_dataout      ), 
		
		.frame_ante_index		(frame_ante_index ),
		.slot_ante_index     (slot_ante_index  ),
		.symbol_ante_index   (symbol_ante_index), 
		.antenna_index 				(antenna_index ),

			
		.dout_ante_valid	(dout_ante_valid	   ),         
		.dout_ante_sop   (dout_ante_sop      ),         
		.dout_ante_eop   (dout_ante_eop      ),         
		.dout_ante_data  (dout_ante_data     )         

		
	);

	
  /************************************************/
  /*                   avlst_64to32                */
  /************************************************/
	avlst_64to32	   avlst_64to32_inst
	(
		.clk_wr       (clk_in          ),
		.clk_rd       (clk_rd          ),
		.rst_n        (rst_n           ),
		.din_restart  (dout_arm_restart     ), 
		
		.din_ready    (       ), 
		.din_sop      (dout_arm_sop         ), 
		.din_eop      (dout_arm_eop         ), 
		.din_valid    (dout_arm_valid        ),
		.din_data     (dout_arm_dataout        ),
		.din_empty    (dout_arm_empty       ),
		.dout_drop    (1'b0       ),
		.dout_repeat  (1'b0     ),
		.arbit_grant  (arbit_grant     ),
		//.arbit_grant  (1'b1     ),
		.arbit_request(arbit_request   ),                
		.arbit_eop    (arbit_eop       ),                                                           
		                     
		.dout_sop     (dout_sop        ),                      
		.dout_eop     (dout_eop        ),                      
		.dout_valid   (dout_valid      ),                      
		.dout_data    (dout_data       ),   
		.dout_empty   (dout_empty      ),
		.dout_index   (dout_index      ),
		.din_index    (din_index       ),
		.overflow_cnt (overflow_cnt    ),           
		.pack_used    (pack_used       ),
		.word_used    (word_used       ),
		//.word_used_pre(word_used_pre   ),
		.used_full    (used_full       ),                      
		.used_empty   (used_empty      )     		
	);




  function integer BIT_WIDTH;
    input integer value;
    begin
      if(value <= 0) begin
        BIT_WIDTH = 0;
      end
      else for(BIT_WIDTH = 0; value > 0; BIT_WIDTH = BIT_WIDTH + 1) begin
        value = value >> 1;
      end
    end
  endfunction		
	
endmodule
