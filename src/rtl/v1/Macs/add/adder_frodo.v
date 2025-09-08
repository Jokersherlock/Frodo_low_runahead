// Module name   :   ADDER_FRODO�?
// Full name     :  16bit adder and multiplier for frodo
//
// Author        :  
module ADDER_FRODO(

input  wire   clk,
input  wire   rstn,
input  wire   en,

input  wire [15:0] in_a,             ////multiplier  (unsiged)
input  wire [7:0] in_b_,             ///multiplicand (signed) 1111_1111_111-1_XXXX or 0000_0000_000-0_XXXX
input  wire [15:0] in_c,             ///addend
  

output reg         done,
output reg [15:0] result,          /// a * b /+ c
input      [1:0]  level

);
wire [15:0] out_d;
wire [15:0] product;
reg state;
wire [7:0] in_b;

assign in_b = level == 2'b11 ? {in_b_[6],in_b_[6:0]} : in_b_;

always@(posedge clk or negedge rstn)
begin
    if(!rstn)
        begin
            done <= 1'b0;
            state <= 1'b0;
            result <= 16'd0;
        end
    else
        begin
            done <= 1'b0;
        if(state)
            begin
                result <= out_d;
                state <= 1'b0;
                done <= 1'b1;
            end
        else if(en)        
            begin
                result <= product;
                state  <= 1'b1;
                done <= done;
            end
        else
            begin
                done   <= done;
                result <= result;
                state <= state;
                done <= done;
            end
        
        end
        
end



/////////////////////////////////////////Partial volume////////////////  
wire [15:0] cn0; // b[0] & a[15:0]
wire [14:0] cn1; // b[1] & a[15:0]
wire [13:0] cn2; // b[2] & a[15:0]
wire [12:0] cn3; // b[3] & a[15:0]
wire [11:0] cn4; // b[3] & a[15:0]


//////////////////////////////////////calculate for Partial volume//////
assign cn0  = {16{in_b[0]}} & in_a[15:0] ;  
assign cn1  = {15{in_b[1]}} & in_a[14:0] ;
assign cn2  = {14{in_b[2]}} & in_a[13:0] ;
assign cn3  = {13{in_b[3]}} & in_a[12:0] ;//

//complement
assign cn4  = (~(in_a[11:0]) + 1'b1) & {12{in_b[4]}} ;

//////////// adder array////////////////////////////////////
/////////////first row ////////////////////////////////
wire [14:0]array_a0; //Carrying
wire [14:0]array_a1; //Sum

HALF_ADDER U_HALF_ADDER_A0(
 .a0(cn0[1]),
 .b0(cn1[0]),

 .s1(array_a1[0]) ,
 .c1(array_a0[0])
                );

genvar  i1;	
generate 
        for(i1=1;i1<14;i1=i1+1)begin:Cn1
			FULL_ADDER U_FULL_ADDER_A(
                    .a0(cn0[i1 + 1'b1]),
                    .b0(cn1[i1]),
                    .c0(array_a0[i1 - 1'b1]),
                    .s1(array_a1[i1]),
                    .c1(array_a0[i1])
                    );            
		end
endgenerate

NC_ADDER U_NC_ADDER_A0(
 .a0(cn0[15]),
 .b0(cn1[14]),
 .c0(array_a0[13]),   
 .s1(array_a1[14])
                );
/////////////2 row ////////////////////////////////
wire [13:0]array_b0; //Carrying
wire [13:0]array_b1; //Sum

HALF_ADDER U_HALF_ADDER_B0(
 .a0(cn2[0]),
 .b0(array_a1[1]),

 .s1(array_b1[0]) ,
 .c1(array_b0[0])
                );

genvar  i2;	
generate 
        for(i2=1;i2<13;i2=i2+1)begin:Cn2
			FULL_ADDER U_FULL_ADDER_B(
                    .a0(cn2[i2]),
                    .b0(array_a1[i2 + 1'b1]),
                    .c0(array_b0[i2 - 1'b1]),
                    .s1(array_b1[i2]),
                    .c1(array_b0[i2])
                    );            
		end
endgenerate

NC_ADDER U_NC_ADDER_B0(
 .a0(cn2[13]),
 .b0(array_a1[14]),
 .c0(array_b0[12]),   
 .s1(array_b1[13])
                );
/////////////3 row ////////////////////////////////
wire [12:0]array_c0; //Carrying
wire [12:0]array_c1; //Sum

HALF_ADDER U_HALF_ADDER_C0(
 .a0(cn3[0]),
 .b0(array_b1[1]),

 .s1(array_c1[0]) ,
 .c1(array_c0[0])
                );

genvar  i3;	
generate 
        for(i3=1;i3<12;i3=i3+1)begin:Cn3
			FULL_ADDER U_FULL_ADDER_C(
                    .a0(cn3[i3]),
                    .b0(array_b1[i3 + 1'b1]),
                    .c0(array_c0[i3 - 1'b1]),
                    .s1(array_c1[i3]),
                    .c1(array_c0[i3])
                    );            
		end
endgenerate

NC_ADDER U_NC_ADDER_C0(
 .a0(cn3[12]),
 .b0(array_b1[13]),
 .c0(array_c0[11]),   
 .s1(array_c1[12])
                );
/////////////4 row ////////////////////////////////

wire [11:0]array_d0; //Carrying
wire [11:0]array_d1; //Sum

HALF_ADDER U_HALF_ADDER_D0(
 .a0(cn4[0]),
 .b0(array_c1[1]),

 .s1(array_d1[0]) ,
 .c1(array_d0[0])
                );

genvar  i4;	
generate 
        for(i4=1;i4<11;i4=i4+1)begin:Cn4
			FULL_ADDER U_FULL_ADDER_D(
                    .a0(cn4[i4]),
                    .b0(array_c1[i4 + 1'b1]),
                    .c0(array_d0[i4 - 1'b1]),
                    .s1(array_d1[i4]),
                    .c1(array_d0[i4])
                    );            
		end
endgenerate

NC_ADDER U_NC_ADDER_D0(
 .a0(cn4[11]),
 .b0(array_c1[12]),
 .c0(array_d0[10]),   
 .s1(array_d1[11]) 
                );
///////////////////////////////////////product a*b /////////////////////
assign product = {array_d1,array_c1[0],array_b1[0],array_a1[0],cn0[0]};

///////////////////////////////////////16 bit mod adder//////////////////////
wire [14:0]array_e0; //Carrying
wire [15:0]array_e1; //Sum

HALF_ADDER U_HALF_ADDER_E0(
 .a0(product [0]),
 .b0(in_c    [0]),

 .s1(array_e1[0]) ,
 .c1(array_e0[0])
                );

genvar  i5;	
generate 
        for(i5=1;i5<15;i5=i5+1)begin:Cn5
			FULL_ADDER U_FULL_ADDER_E(
                    .a0(product [i5]),
                    .b0(in_c    [i5]),
                    .c0(array_e0[i5 - 1'b1]),
                    .s1(array_e1[i5]),
                    .c1(array_e0[i5])
                    );            
		end
endgenerate

NC_ADDER U_NC_ADDER_E0(
 .a0(product [15]),
 .b0(in_c    [15]),
 .c0(array_e0[14]),   
 .s1(array_e1[15]) 
                );

assign out_d = array_e1;

endmodule
