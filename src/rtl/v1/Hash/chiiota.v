
module chiiota
(
    input wire [0:199] ci_in,
    input wire [4:0]   Rnd_cnt,
    input wire [2:0]   Sub_Rnd_cnt, 
    output wire         pre_rnd,
    output wire [0:199] ci_out  

        );


//////////////////////////for chiiota
reg    [6:0]  c1;
wire   [63:0] c0;
reg    [7:0]  c_rnd;  

assign pre_rnd = c0[63];


always@(*)
		begin
			case(Rnd_cnt)
				5'd1: c1 <= 7'b0000_001;	
                5'd2: c1 <= 7'b0011_010;
				5'd3: c1 <= 7'b1011_110;	
                5'd4: c1 <= 7'b1110_000;
				5'd5: c1 <= 7'b0011_111;	
                5'd6: c1 <= 7'b0100_001;
				5'd7: c1 <= 7'b1111_001;	
                5'd8: c1 <= 7'b1010_101;
				5'd9: c1 <= 7'b0001_110;	
                5'd10: c1 <= 7'b0001_100;
				5'd11: c1 <= 7'b0110_101;	
                5'd12: c1 <= 7'b0100_110;
                5'd13: c1 <= 7'b0111_111;	
                5'd14: c1 <= 7'b1001_111;
                5'd15: c1 <= 7'b1011_101;	
                5'd16: c1 <= 7'b1010_011;
                5'd17: c1 <= 7'b1010_010;	
                5'd18: c1 <= 7'b1001_000;
                5'd19: c1 <= 7'b0010_110;	
                5'd20: c1 <= 7'b1100_110;
                5'd21: c1 <= 7'b1111_001;	
                5'd22: c1 <= 7'b1011_000;
                5'd23: c1 <= 7'b0100_001;	
                5'd24: c1 <= 7'b1110_100;
				default:	c1 <= 7'b0000_000;	
			endcase 
		end

assign c0 = {c1[6],31'b0,c1[5],15'b0,c1[4],7'b0,c1[3],3'b0,c1[2],1'b0,c1[1:0]};


always@(*)
		begin
			case(Sub_Rnd_cnt)
                3'd0: c_rnd = c0[63:56]    ;
                3'd1: c_rnd = c0[55:48]    ;
                3'd2: c_rnd = c0[47:40]    ;
                3'd3: c_rnd = c0[39:32]    ;
                3'd4: c_rnd = c0[31:24]    ;
                3'd5: c_rnd = c0[23:16]    ;
                3'd6: c_rnd = c0[15:8]    ;
                3'd7: c_rnd = c0[7:0]    ;
                default:;
                endcase    
        end    

assign ci_out[0:7]     =  (ci_in[0:7]     ^ (~ci_in[8:15]    & ci_in[16:23]  )) ^ c_rnd; 
assign ci_out[8:15]    =  ci_in[8:15]    ^ (~ci_in[16:23]   & ci_in[24:31]  );         
assign ci_out[16:23]   =  ci_in[16:23]   ^ (~ci_in[24:31]   & ci_in[32:39]  );         
assign ci_out[24:31]   =  ci_in[24:31]   ^ (~ci_in[32:39]   & ci_in[0:7]    );         
assign ci_out[32:39]   =  ci_in[32:39]   ^ (~ci_in[0:7]     & ci_in[8:15]   );         
                                                                                       
assign ci_out[40:47]   =  ci_in[40:47]   ^ (~ci_in[48:55]   & ci_in[56:63]  );         
assign ci_out[48:55]   =  ci_in[48:55]   ^ (~ci_in[56:63]   & ci_in[64:71]  );         
assign ci_out[56:63]   =  ci_in[56:63]   ^ (~ci_in[64:71]   & ci_in[72:79]  );         
assign ci_out[64:71]   =  ci_in[64:71]   ^ (~ci_in[72:79]   & ci_in[40:47]  );         
assign ci_out[72:79]   =  ci_in[72:79]   ^ (~ci_in[40:47]   & ci_in[48:55]  );         
                                                                              
assign ci_out[80:87]   =  ci_in[80:87]   ^ (~ci_in[88:95]   & ci_in[96:103] );         
assign ci_out[88:95]   =  ci_in[88:95]   ^ (~ci_in[96:103]  & ci_in[104:111]);         
assign ci_out[96:103]  =  ci_in[96:103]  ^ (~ci_in[104:111] & ci_in[112:119]);         
assign ci_out[104:111] =  ci_in[104:111] ^ (~ci_in[112:119] & ci_in[80:87]  );         
assign ci_out[112:119] =  ci_in[112:119] ^ (~ci_in[80:87]   & ci_in[88:95]  );         
                                                                              
assign ci_out[120:127] =  ci_in[120:127] ^ (~ci_in[128:135] & ci_in[136:143]);         
assign ci_out[128:135] =  ci_in[128:135] ^ (~ci_in[136:143] & ci_in[144:151]);         
assign ci_out[136:143] =  ci_in[136:143] ^ (~ci_in[144:151] & ci_in[152:159]);         
assign ci_out[144:151] =  ci_in[144:151] ^ (~ci_in[152:159] & ci_in[120:127]);         
assign ci_out[152:159] =  ci_in[152:159] ^ (~ci_in[120:127] & ci_in[128:135]);         
                                                                              
assign ci_out[160:167] =  ci_in[160:167] ^ (~ci_in[168:175] & ci_in[176:183]);         
assign ci_out[168:175] =  ci_in[168:175] ^ (~ci_in[176:183] & ci_in[184:191]);         
assign ci_out[176:183] =  ci_in[176:183] ^ (~ci_in[184:191] & ci_in[192:199]);         
assign ci_out[184:191] =  ci_in[184:191] ^ (~ci_in[192:199] & ci_in[160:167]);         
assign ci_out[192:199] =  ci_in[192:199] ^ (~ci_in[160:167] & ci_in[168:175]);         

endmodule