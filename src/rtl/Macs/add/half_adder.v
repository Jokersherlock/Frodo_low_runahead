////// 1 bit half_adder
module HALF_ADDER(
    input a0,
	input b0,
	
	output s1,
	output c1
);
    
    assign c1 = a0 & b0 ;
	assign s1 = a0 ^ b0 ;

endmodule 