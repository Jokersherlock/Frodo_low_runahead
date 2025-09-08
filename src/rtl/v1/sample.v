// **************************************************************
// COPYRIGHT(c)2005, Hislicon Technologies Co, Ltd
// All rights reserved.
//
// IP LIB INDEX :  
// IP Name      :  	
// File name     :  sample.v
// Module name  :   SAMPLE
// Full name     :  Gaussian sampling computation unit
//
// Author        :   
// Email         :  
// Data          :   
// Version        :  V 1.2 
// 
//Abstract        :
// Called by       :  
// 
// Modification history
// ------------------------------------------------------------------------------------------------------
// //
// $Log$
//
// *********************************************************************

module sample 
(
    input clk,
    input rst_n,
    input en,                              //使能
    input [1:0] level,                      //安全等级选择
    input wire [15:0] random_string,       //输入数据
   
    output reg [7:0] sample_out,           //输出数据
    output reg valid = 1'b0                //输出有效标注信号 
);  

reg [2:0] ctrl;
always @(*) begin
    case (level)
        2'b01: ctrl = 3'b100;
        2'b10: ctrl = 3'b010;
        2'b11: ctrl = 3'b001;
        2'b00: ctrl = 3'b000;
    endcase
end


parameter TX_640_1  = 15'd4643;
parameter TX_640_2  = 15'd13363;
parameter TX_640_3  = 15'd20579;
parameter TX_640_4  = 15'd25843;
parameter TX_640_5  = 15'd29227;
parameter TX_640_6  = 15'd31145;
parameter TX_640_7  = 15'd32103;
parameter TX_640_8  = 15'd32525;
parameter TX_640_9  = 15'd32689;
parameter TX_640_10 = 15'd32745;
parameter TX_640_11 = 15'd32762;
parameter TX_640_12 = 15'd32766;
parameter TX_640_13 = 15'd32767;
           
parameter TX_976_1  = 15'd5638;
parameter TX_976_2  = 15'd15915;
parameter TX_976_3  = 15'd23689;
parameter TX_976_4  = 15'd28571;
parameter TX_976_5  = 15'd31116;
parameter TX_976_6  = 15'd32217;
parameter TX_976_7  = 15'd32613;
parameter TX_976_8  = 15'd32731;
parameter TX_976_9  = 15'd32760;
parameter TX_976_10 = 15'd32766;
parameter TX_976_11 = 15'd32767;
           
parameter TX_1344_1  = 15'd9142;
parameter TX_1344_2  = 15'd23462;
parameter TX_1344_3  = 15'd30338;
parameter TX_1344_4  = 15'd32361;
parameter TX_1344_5  = 15'd32725;
parameter TX_1344_6  = 15'd32765;
parameter TX_1344_7  = 15'd32767;

wire [7:0] sample;
wire e_1,e_2,e_3,e_4,e_5,e_6,e_7,e_8,e_9,e_10,e_11,e_12,e_13;
wire [7:0] e;

assign e_1  =  ctrl[0] ? (TX_640_1 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_1 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_1< random_string[15:1]) : 1'b0 ));
                                 
assign e_2  =  ctrl[0] ? (TX_640_2 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_2 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_2< random_string[15:1]) : 1'b0 ));
                                 
assign e_3  =  ctrl[0] ? (TX_640_3 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_3 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_3< random_string[15:1]) : 1'b0 )); 
                                
assign e_4  =  ctrl[0] ? (TX_640_4 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_4 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_4< random_string[15:1]) : 1'b0 )); 
                                
assign e_5  =  ctrl[0] ? (TX_640_5 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_5 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_5< random_string[15:1]) : 1'b0 ));                                 
                                 
assign e_6  =  ctrl[0] ? (TX_640_6 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_6 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_6< random_string[15:1]) : 1'b0 ));    
                                 
assign e_7  =  ctrl[0] ? (TX_640_7 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_7 < random_string[15:1])
            : (ctrl[2] ? (TX_1344_7< random_string[15:1]) : 1'b0 ));                                
                                
assign e_8  =  ctrl[0] ? (TX_640_8 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_8 < random_string[15:1])
            : 1'b0                                  );
                                 
assign e_9  =  ctrl[0] ? (TX_640_9 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_9 < random_string[15:1])
            : 1'b0                                   );
            
assign e_10  =  ctrl[0] ? (TX_640_10 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_10 < random_string[15:1])
            : 1'b0                                   );
            
assign e_11  =  ctrl[0] ? (TX_640_11 < random_string[15:1]) 
            : (ctrl[1] ? (TX_976_11 < random_string[15:1])
            : 1'b0                                   );

assign e_12  =  ctrl[0] ? (TX_640_12 < random_string[15:1]) 
            : 1'b0 ;        

assign e_13  =  ctrl[0] ? (TX_640_13 < random_string[15:1]) 
            : 1'b0 ;


assign e = e_1 + e_2 + e_3 + e_4 + e_5 + e_6 + e_7 + e_8 + e_9 + e_10 + e_11 + e_12 + e_13;

assign sample = (random_string[0] == 1) ? (~e + 1'b1) : e;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sample_out <= 8'd0;
        valid <= 1'b0; 
    end else if (en) begin 
        sample_out <= sample;
        valid <= 1'b1; 
    end else begin
        valid <= 1'b0; 
    end
end

endmodule