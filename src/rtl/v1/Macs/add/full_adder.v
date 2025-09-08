////// 1 bit full_adder
module FULL_ADDER(
    input a0,
	input b0,
	input c0,
	output s1,
	output c1
);
    
    assign c1 = a0 & b0 | c0 & (a0 ^ b0);
	assign s1 = c0 ^ a0 ^ b0;

endmodule 