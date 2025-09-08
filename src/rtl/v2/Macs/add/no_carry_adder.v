////// 1 bit no_carry_out_adder
module NC_ADDER(
    input a0,
	input b0,
	input c0,
	output s1

);
    
    
	assign s1 = c0 ^ a0 ^ b0;

endmodule 