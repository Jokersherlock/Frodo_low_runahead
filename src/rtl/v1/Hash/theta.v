
module theta
(
    input   wire  [0:199] theta_in,
    input   wire  [0:24]  pre_out,///来自后面片的第一个片
    output  wire  [0:199] theta_out
        );

        
wire    [0:39] theta_sum;//200/5=40   
wire    [0:4]  theta_sum_;
//200/5=40        
    assign theta_sum  = theta_in[0:39] ^ theta_in[40:79] ^ theta_in[80:119] ^ theta_in[120:159] ^ theta_in[160:199];       
    /*
    assign theta_sum_ [0] = pre_out[0] ^ pre_out[5] ^ pre_out[10] ^ pre_out[15] ^ pre_out[20]; 
    assign theta_sum_ [1] = pre_out[1] ^ pre_out[6] ^ pre_out[11] ^ pre_out[16] ^ pre_out[21]; 
    assign theta_sum_ [2] = pre_out[2] ^ pre_out[7] ^ pre_out[12] ^ pre_out[17] ^ pre_out[22]; 
    assign theta_sum_ [3] = pre_out[3] ^ pre_out[8] ^ pre_out[13] ^ pre_out[18] ^ pre_out[23]; 
    assign theta_sum_ [4] = pre_out[4] ^ pre_out[9] ^ pre_out[14] ^ pre_out[19] ^ pre_out[24]; 
     */
    assign theta_sum_ = pre_out[0:4] ^ pre_out[5:9] ^ pre_out[10:14] ^ pre_out[15:19] ^ pre_out[20:24]; 
    
    assign theta_out[7]   = theta_in[7]     ^  theta_sum[39] ^ theta_sum_[1];
    assign theta_out[15]  = theta_in[15]    ^  theta_sum[7]  ^ theta_sum_[2];
    assign theta_out[23]  = theta_in[23]    ^  theta_sum[15] ^ theta_sum_[3];
    assign theta_out[31]  = theta_in[31]    ^  theta_sum[23] ^ theta_sum_[4];
    assign theta_out[39]  = theta_in[39]    ^  theta_sum[31] ^ theta_sum_[0];
                                    
    assign theta_out[47]  = theta_in[47]    ^  theta_sum[39] ^ theta_sum_[1];
    assign theta_out[55]  = theta_in[55]    ^  theta_sum[7]  ^ theta_sum_[2];
    assign theta_out[63]  = theta_in[63]    ^  theta_sum[15] ^ theta_sum_[3];
    assign theta_out[71]  = theta_in[71]    ^  theta_sum[23] ^ theta_sum_[4];
    assign theta_out[79]  = theta_in[79]    ^  theta_sum[31] ^ theta_sum_[0];
                                    
    assign theta_out[87]  = theta_in[87]    ^  theta_sum[39] ^ theta_sum_[1];
    assign theta_out[95]  = theta_in[95]    ^  theta_sum[7]  ^ theta_sum_[2];
    assign theta_out[103] = theta_in[103]   ^  theta_sum[15] ^ theta_sum_[3];
    assign theta_out[111] = theta_in[111]   ^  theta_sum[23] ^ theta_sum_[4];
    assign theta_out[119] = theta_in[119]   ^  theta_sum[31] ^ theta_sum_[0];
                                    
    assign theta_out[127] = theta_in[127]   ^  theta_sum[39] ^ theta_sum_[1];
    assign theta_out[135] = theta_in[135]   ^  theta_sum[7]  ^ theta_sum_[2];
    assign theta_out[143] = theta_in[143]   ^  theta_sum[15] ^ theta_sum_[3];
    assign theta_out[151] = theta_in[151]   ^  theta_sum[23] ^ theta_sum_[4];
    assign theta_out[159] = theta_in[159]   ^  theta_sum[31] ^ theta_sum_[0];
                                    
    assign theta_out[167] = theta_in[167]   ^  theta_sum[39] ^ theta_sum_[1];
    assign theta_out[175] = theta_in[175]   ^  theta_sum[7]  ^ theta_sum_[2];
    assign theta_out[183] = theta_in[183]   ^  theta_sum[15] ^ theta_sum_[3];
    assign theta_out[191] = theta_in[191]   ^  theta_sum[23] ^ theta_sum_[4];
    assign theta_out[199] = theta_in[199]   ^  theta_sum[31] ^ theta_sum_[0];
    
     
  
    assign theta_out[0:6]     = theta_in[0:6]    ^ theta_sum[32:38] ^ theta_sum[9:15];
    assign theta_out[8:14]    = theta_in[8:14]   ^ theta_sum[0:6]   ^ theta_sum[17:23];
    assign theta_out[16:22]   = theta_in[16:22]  ^ theta_sum[8:14]  ^ theta_sum[25:31];      
    assign theta_out[24:30]   = theta_in[24:30]  ^ theta_sum[16:22] ^ theta_sum[33:39];        
    assign theta_out[32:38]   = theta_in[32:38]  ^ theta_sum[24:30] ^ theta_sum[1:7];        
                                                 
    assign theta_out[40:46]   = theta_in[40:46]  ^ theta_sum[32:38] ^ theta_sum[9:15];
    assign theta_out[48:54]   = theta_in[48:54]  ^ theta_sum[0:6]   ^ theta_sum[17:23];
    assign theta_out[56:62]   = theta_in[56:62]  ^ theta_sum[8:14]  ^ theta_sum[25:31];   
    assign theta_out[64:70]   = theta_in[64:70]  ^ theta_sum[16:22] ^ theta_sum[33:39];   
    assign theta_out[72:78]   = theta_in[72:78]  ^ theta_sum[24:30] ^ theta_sum[1:7];     
                                        
    assign theta_out[80:86]   = theta_in[80:86]   ^ theta_sum[32:38] ^ theta_sum[9:15];
    assign theta_out[88:94]   = theta_in[88:94]   ^ theta_sum[0:6]   ^ theta_sum[17:23];
    assign theta_out[96:102]  = theta_in[96:102]  ^ theta_sum[8:14]  ^ theta_sum[25:31];  
    assign theta_out[104:110] = theta_in[104:110] ^ theta_sum[16:22] ^ theta_sum[33:39];  
    assign theta_out[112:118] = theta_in[112:118] ^ theta_sum[24:30] ^ theta_sum[1:7];    
                                                 
    assign theta_out[120:126] = theta_in[120:126] ^ theta_sum[32:38] ^ theta_sum[9:15];
    assign theta_out[128:134] = theta_in[128:134] ^ theta_sum[0:6]   ^ theta_sum[17:23];
    assign theta_out[136:142] = theta_in[136:142] ^ theta_sum[8:14]  ^ theta_sum[25:31]; 
    assign theta_out[144:150] = theta_in[144:150] ^ theta_sum[16:22] ^ theta_sum[33:39]; 
    assign theta_out[152:158] = theta_in[152:158] ^ theta_sum[24:30] ^ theta_sum[1:7];   
                                                 
    assign theta_out[160:166] = theta_in[160:166] ^ theta_sum[32:38] ^ theta_sum[9:15];
    assign theta_out[168:174] = theta_in[168:174] ^ theta_sum[0:6]   ^ theta_sum[17:23];
    assign theta_out[176:182] = theta_in[176:182] ^ theta_sum[8:14]  ^ theta_sum[25:31];  
    assign theta_out[184:190] = theta_in[184:190] ^ theta_sum[16:22] ^ theta_sum[33:39];  
    assign theta_out[192:198] = theta_in[192:198] ^ theta_sum[24:30] ^ theta_sum[1:7];    
    
    
    
    
    
    
    
    
    

endmodule