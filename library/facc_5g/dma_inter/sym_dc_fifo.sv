/*
//
//  Module:       sym_dc_fifo
//
//  Description:  a symmetric dual clock fifo
//
//  Maintainer:   Linda
//
//  Revision:     0.10
//
//  Change Log:   0.10 2019/03/25, initial release.
//                
//                
//                
//                
//                
//                
//
*/

`timescale 1ns/100ps

module sym_dc_fifo
#(
	parameter	 MEM_SIZE= 1024,
	parameter	 ADDR_WIDTH = BIT_WIDTH(MEM_SIZE-1),
	parameter	 DATA_WIDTH = 64,
//	parameter	 THRESHOLD_EMPTY = 1,    //almost empty
//	parameter	 THRESHOLD_FULL  =1023,			//almost full
	parameter	 LATENCY = 2

	
)
(
	input												clk_wr,				//write FIFO clock 
	input												clk_rd,       //read  FIFO clock 
	          									
	input												rst_n,				//clear signal
	          									
		input												wr_en,				//write FIFO enable
		input[DATA_WIDTH-1:0]				din,          //write FIFO data
		input												rd_en,        //read FIFO enable 
	
	output reg[DATA_WIDTH-1 :0]	dout,         //read  FIFO data,latency =1;
		output reg[DATA_WIDTH-1 :0]	dout_r, 			////read  FIFO data,latency =2;
	output reg                 valid_out,
		output reg                 valid_out_r,
		output reg									full,					// 1 = FIFO full   
		output reg									empty,         // 1 = FIFO empty
	output [ADDR_WIDTH-1 :0] 		            test_wr_addr	

);
   
    
	reg[DATA_WIDTH-1 :0]				mem[MEM_SIZE-1 :0];  //memory space
	
		reg[ADDR_WIDTH :0]				wr_ptr;
		reg[ADDR_WIDTH :0]				rd_ptr;				//write and read address pointer, msb repersents the rollover
	
	reg[ADDR_WIDTH :0]				sync_wr_ptr_gray[3:1];
	reg[ADDR_WIDTH :0]				sync_rd_ptr_gray[3:1];  //synchronization across clock domains

		wire[ADDR_WIDTH :0]				wr_next_ptr;
		wire[ADDR_WIDTH :0]				rd_next_ptr;   //next pointer
	
	wire[ADDR_WIDTH :0]				wr_next_ptr_gray;
	wire[ADDR_WIDTH :0]				rd_next_ptr_gray;   //gray code
	
		wire[ADDR_WIDTH-1 :0] 		wr_addr;
		wire[ADDR_WIDTH-1 :0]			rd_addr;   //read and write address
	
	wire 											async_full;
	wire 											async_empty;
	
	assign		wr_addr = wr_ptr[ADDR_WIDTH-1 :0];	
	assign		rd_addr = rd_ptr[ADDR_WIDTH-1 :0];
	
	//assign		wr_next_ptr =   wr_ptr[ADDR_WIDTH :0]+(~full && wr_en) ;
	assign		wr_next_ptr =   wr_ptr[ADDR_WIDTH :0]+ wr_en ;
	assign		rd_next_ptr =   rd_ptr[ADDR_WIDTH :0]+(~empty && rd_en) ;
	
	assign	  wr_next_ptr_gray = (wr_next_ptr >> 1)^wr_next_ptr;
	assign		rd_next_ptr_gray = (rd_next_ptr >> 1)^rd_next_ptr;   //gray code

	assign		async_empty = sync_wr_ptr_gray[3] == rd_next_ptr_gray ;
	assign		async_full  = sync_rd_ptr_gray[3] == {~wr_next_ptr_gray[ADDR_WIDTH:ADDR_WIDTH-1],wr_next_ptr_gray[ADDR_WIDTH-2:0]} ;  //the nature of gray code
	
	assign                               test_wr_addr =wr_addr;     
	
///////////////////////////write in/////////////////////////
	integer		i;
	always @ (posedge clk_wr or negedge rst_n)				
		begin
			if(!rst_n)
				begin
					for(i=0;i<MEM_SIZE;i=i+1)
						begin
							mem[i] <= 0;
						end					
				end
			else
				begin
					//if(~full  && wr_en  )
					if( wr_en  )
						begin
							mem[wr_addr] <= din;
						end
					else
						begin
						end
				end
		end
		
	always @ (posedge clk_wr or negedge rst_n)
		begin
			if(!rst_n)
				begin
					wr_ptr <= 0;
					sync_wr_ptr_gray[1] <= 0;
				end
			else
				begin
					wr_ptr <= wr_next_ptr;   
					sync_wr_ptr_gray[1] <= wr_next_ptr_gray; 
				end
		end
		
	always @ (posedge clk_wr or negedge rst_n)
		begin
			if(!rst_n)
				begin
					sync_rd_ptr_gray[2] <= 0;
					sync_rd_ptr_gray[3] <= 0;					
				end
			else
				begin
					sync_rd_ptr_gray[2] <= sync_rd_ptr_gray[1]; 
					sync_rd_ptr_gray[3] <= sync_rd_ptr_gray[2];
				end
		end		

	always @ (posedge clk_wr or negedge rst_n)
		begin
			if(!rst_n)
				begin
					full <= 0;
				end
			else
				begin
					full <= async_full;
				end
		end		
	
	always @ (posedge clk_rd or negedge rst_n)
		begin
			if(!rst_n)
				begin
					dout <= 0;
					dout_r <= 0;
					valid_out <= 0;
					valid_out_r <= 0;
				end
			else
				begin
					dout <= mem[rd_addr];
					dout_r <= dout;
					valid_out <= ~empty & rd_en;
					valid_out_r <= valid_out;
				end
		end		

	always @ (posedge clk_rd or negedge rst_n)
		begin
			if(!rst_n)
				begin
					rd_ptr <= 0;
					sync_rd_ptr_gray[1] <= 0;
				end
			else
				begin
					rd_ptr <= rd_next_ptr ;
					sync_rd_ptr_gray[1] <= rd_next_ptr_gray;
				end
		end		
	
	always @ (posedge clk_rd or negedge rst_n)
		begin
			if(!rst_n)
				begin
					sync_wr_ptr_gray[2] <= 0;
					sync_wr_ptr_gray[3] <= 0;
				end
			else
				begin
					sync_wr_ptr_gray[2] <= sync_wr_ptr_gray[1]; 
					sync_wr_ptr_gray[3] <= sync_wr_ptr_gray[2]; 					
				end
		end		

	always @ (posedge clk_rd or negedge rst_n)
		begin
			if(!rst_n)
				begin
					empty <= 1;
				end
			else
				begin
					empty <= async_empty;
				end
		end		


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
