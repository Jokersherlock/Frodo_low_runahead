module PRE_THETA
(
    input wire  clk,
    input wire  rst,
    input wire  pre_en,
    
    input wire  [0:199] k_ram_o_all,
    input wire  [0:199] k_ram_i_all,
    input wire  [0:199] ci_out,
    input wire          pre_rnd,
    
    input [2:0] Sub_Rnd_cnt,
    input [4:0] Rnd_cnt,
    input [2:0] state,
    
 
    output wire [0:24] pre_theta
);
    wire [0:24] pre_ramout;//本小轮从ram读出的数据，用于0大轮的6-0小轮
    wire [0:24] pre_ciout;//本小轮经ci的数据，用于1-24大轮
    wire [0:24] pre_07_ci;//将pre_70数据进行ci操作
    
    reg [0:24] pre_07;//用于从Sub_cnt从0跳7的theta  
    reg [0:24] pre_61;//用于从Sub_cnt从6跳1的theta 
    
    
    
    assign pre_ramout = {k_ram_o_all[0],  k_ram_o_all[8],  k_ram_o_all[16], k_ram_o_all[24], k_ram_o_all[32],
                         k_ram_o_all[40], k_ram_o_all[48], k_ram_o_all[56], k_ram_o_all[64], k_ram_o_all[72],
                         k_ram_o_all[80], k_ram_o_all[88], k_ram_o_all[96], k_ram_o_all[104],k_ram_o_all[112],
                         k_ram_o_all[120],k_ram_o_all[128],k_ram_o_all[136],k_ram_o_all[144],k_ram_o_all[152],
                         k_ram_o_all[160],k_ram_o_all[168],k_ram_o_all[176],k_ram_o_all[184],k_ram_o_all[192]};
                              
    assign pre_ciout = {ci_out[0],  ci_out[8],  ci_out[16], ci_out[24], ci_out[32],
                        ci_out[40], ci_out[48], ci_out[56], ci_out[64], ci_out[72],
                        ci_out[80], ci_out[88], ci_out[96], ci_out[104],ci_out[112],
                        ci_out[120],ci_out[128],ci_out[136],ci_out[144],ci_out[152],
                        ci_out[160],ci_out[168],ci_out[176],ci_out[184],ci_out[192]};                           
                              
   
    assign pre_07_ci[0]  =(pre_07[0] ^(~pre_07[1]   & pre_07[2])) ^ pre_rnd;
    assign pre_07_ci[1]  = pre_07[1] ^(~pre_07[2]   & pre_07[3]);
    assign pre_07_ci[2]  = pre_07[2] ^(~pre_07[3]   & pre_07[4]);
    assign pre_07_ci[3]  = pre_07[3] ^(~pre_07[4]   & pre_07[0]);
    assign pre_07_ci[4]  = pre_07[4] ^(~pre_07[0]   & pre_07[1]);
           
    assign pre_07_ci[5]  = pre_07[5]  ^(~pre_07[6]  & pre_07[7]);
    assign pre_07_ci[6]  = pre_07[6]  ^(~pre_07[7]  & pre_07[8]);
    assign pre_07_ci[7]  = pre_07[7]  ^(~pre_07[8]  & pre_07[9]);
    assign pre_07_ci[8]  = pre_07[8]  ^(~pre_07[9]  & pre_07[5]);
    assign pre_07_ci[9]  = pre_07[9]  ^(~pre_07[5]  & pre_07[6]);
              
    assign pre_07_ci[10] = pre_07[10] ^(~pre_07[11] & pre_07[12]);
    assign pre_07_ci[11] = pre_07[11] ^(~pre_07[12] & pre_07[13]);
    assign pre_07_ci[12] = pre_07[12] ^(~pre_07[13] & pre_07[14]);
    assign pre_07_ci[13] = pre_07[13] ^(~pre_07[14] & pre_07[10]);
    assign pre_07_ci[14] = pre_07[14] ^(~pre_07[10] & pre_07[11]);
               
    assign pre_07_ci[15] = pre_07[15] ^(~pre_07[16] & pre_07[17]);
    assign pre_07_ci[16] = pre_07[16] ^(~pre_07[17] & pre_07[18]);
    assign pre_07_ci[17] = pre_07[17] ^(~pre_07[18] & pre_07[19]);
    assign pre_07_ci[18] = pre_07[18] ^(~pre_07[19] & pre_07[15]);
    assign pre_07_ci[19] = pre_07[19] ^(~pre_07[15] & pre_07[16]);
              
    assign pre_07_ci[20] = pre_07[20] ^(~pre_07[21] & pre_07[22]);
    assign pre_07_ci[21] = pre_07[21] ^(~pre_07[22] & pre_07[23]);
    assign pre_07_ci[22] = pre_07[22] ^(~pre_07[23] & pre_07[24]);
    assign pre_07_ci[23] = pre_07[23] ^(~pre_07[24] & pre_07[20]);
    assign pre_07_ci[24] = pre_07[24] ^(~pre_07[20] & pre_07[21]);

    assign pre_theta =  (Sub_Rnd_cnt == 3'd7) ? ( (Rnd_cnt == 5'd0) ? pre_61 : pre_07_ci) : pre_61;
    

    ////////对于，仅针对slice0，进行rp步骤（从特定小轮取出特定位置的ram数据）
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            pre_07 <= 25'b0;
        else if(pre_en)
        begin
            case(Sub_Rnd_cnt)
            3'd0: begin 
            pre_07[0]   <= k_ram_i_all[0]  ;//00 - 00  + 0   
            pre_07[7]   <= k_ram_i_all[83] ;//12 - 20 80 + 3                            
            pre_07[10]  <= k_ram_i_all[9];//20 - 01 8 + 1                           
            pre_07[11]  <= k_ram_i_all[62] ;//21 - 12 56 + 6 
            pre_07[24]  <= k_ram_i_all[170];//44 - 41 168+ 2
                    end
            3'd1:begin
            pre_07[4]   <= k_ram_i_all[198] ;//04 - 44 192 + 6
            pre_07[13]  <= k_ram_i_all[152] ;//23 - 34 152 + 0
            pre_07[17]  <= k_ram_i_all[90] ;//32 - 21 88 + 2 
            pre_07[18]  <= k_ram_i_all[143] ;//33 - 32 136 + 7     
                    end  
            3'd2:begin
            pre_07[3]   <= k_ram_i_all[149] ;//03 - 33 144 + 5
            pre_07[6]   <= k_ram_i_all[76] ;//11 - 14 72 + 4
            pre_07[14]  <= k_ram_i_all[162] ;//24 - 40 160  +2       
                    end  
            3'd3:begin
            pre_07[5]   <= k_ram_i_all[28]  ;//10 - 03 24 + 4
            pre_07[12]  <= k_ram_i_all[105] ;//22 -23 104 + 1
            pre_07[15]  <= k_ram_i_all[35] ;//30- 04 32 + 3
                    end  
            3'd4:begin
            pre_07[16]  <= k_ram_i_all[44] ;//31 - 10 40 + 4
            pre_07[22]  <= k_ram_i_all[119] ;//42 - 24 112 + 7
                    end  
            3'd5:begin
            pre_07[1]   <= k_ram_i_all[52] ;//01 - 11 48 + 4
            pre_07[2]   <= k_ram_i_all[99] ;//02 - 22 96 + 3
            pre_07[8]   <= k_ram_i_all[133] ;//13 - 31 128 + 5
            pre_07[23]  <= k_ram_i_all[121] ;//43 - 30 120 + 1
                    end  
            3'd6:begin
            pre_07[21]  <= k_ram_i_all[71] ;//41 - 13 64 + 7
                    end  
            3'd7:begin
            pre_07[9]   <= k_ram_i_all[181] ;//14 - 42 176 + 5
            pre_07[19]  <= k_ram_i_all[184] ;//34 - 43 184 + 0
            pre_07[20]  <= k_ram_i_all[22] ;//40 - 02 16 + 6
                    end 
            default: pre_07 <= 25'd0;
            endcase    
        end
        else
        pre_07 <= 25'b0;
    end

    /////////////////////////
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            pre_61 <= 25'b0;    
        else if(pre_en)
        begin
            if(state == 3'd3)
                pre_61 <= pre_ramout;
            else if(Rnd_cnt == 5'd0)//0大轮的6-0小轮，需要直接从ram读出的数据（未经theta）    
                pre_61 <= pre_ramout;
            else//其余大轮的6-0小轮，需要从ram读出后经过ci的数据
                pre_61 <= pre_ciout;
        end        
        else
            pre_61 <= 25'b0;   
    end

    


    
    
endmodule