module hash_out_buffer
(   input wire clk,
    input wire rst,
    
    input wire [4:0] Rnd_cnt,
    input wire [2:0] Sub_Rnd_cnt,
    input wire [2:0] state,
 
    
    input wire [0:199] ci_out,
    input wire         dout_en,
    
    output wire [0:63] Hash_64out

);

reg [0:1343] Hash_out_buffer;//1344

//reg [4:0]    buffer_out_cnt;
//reg          buffer_out_en;//////连续输出使用   


//assign Hash_64out = dout_en ? Hash_out_buffer[0:63] : 64'd0; 
//assign Hash_64out = Hash_out_buffer[0:63];
//assign Hash_64out = {Hash_out_buffer[48:63],Hash_out_buffer[32:47],Hash_out_buffer[16:31],Hash_out_buffer[0:15]};
assign Hash_64out = {Hash_out_buffer[56:63],Hash_out_buffer[48:55],Hash_out_buffer[40:47],Hash_out_buffer[32:39],Hash_out_buffer[24:31],Hash_out_buffer[16:23],Hash_out_buffer[8:15],Hash_out_buffer[0:7]};


always@(posedge clk or posedge rst)
begin
    if(rst)
            Hash_out_buffer <= 1344'd0;
     else if(dout_en)
            Hash_out_buffer     <=  {Hash_out_buffer[64:1343],64'd0};
    else if(state == 3'd5)//向buffer里装载数�?
        begin
            if(Rnd_cnt == 5'd24)
                begin
                    case(Sub_Rnd_cnt)
                        3'd7:begin
                               Hash_out_buffer[0:7]             <=  ci_out[0:7]    ;
                               Hash_out_buffer[64:71]           <=  ci_out[8:15]   ;
                               Hash_out_buffer[128:135]         <=  ci_out[16:23]  ;
                               Hash_out_buffer[192:199]         <=  ci_out[24:31]  ;
                               Hash_out_buffer[256:263]         <=  ci_out[32:39]  ;
                               Hash_out_buffer[320:327]         <=  ci_out[40:47]  ;
                               Hash_out_buffer[384:391]         <=  ci_out[48:55]  ;
                               Hash_out_buffer[448:455]         <=  ci_out[56:63]  ;
                               Hash_out_buffer[512:519]         <=  ci_out[64:71]  ;
                               Hash_out_buffer[576:583]         <=  ci_out[72:79]  ;
                               Hash_out_buffer[640:647]         <=  ci_out[80:87]  ;
                               Hash_out_buffer[704:711]         <=  ci_out[88:95]  ;
                               Hash_out_buffer[768:775]         <=  ci_out[96:103] ;
                               Hash_out_buffer[832:839]         <=  ci_out[104:111]; 
                               Hash_out_buffer[896:903]         <=  ci_out[112:119];
                               Hash_out_buffer[960:967]         <=  ci_out[120:127]; 
                               Hash_out_buffer[1024:1031]       <=  ci_out[128:135]; 
                               Hash_out_buffer[1088:1095]       <=  ci_out[136:143];
                               Hash_out_buffer[1152:1159]       <=  ci_out[144:151]; 
                               Hash_out_buffer[1216:1223]       <=  ci_out[152:159]; 
                               Hash_out_buffer[1280:1287]       <=  ci_out[160:167];
                            end
                        3'd6:begin
                              Hash_out_buffer[8:15]             <=  ci_out[0:7]    ;
                              Hash_out_buffer[72:79]            <=  ci_out[8:15]   ;
                              Hash_out_buffer[136:143]          <=  ci_out[16:23]  ;
                              Hash_out_buffer[200:207]          <=  ci_out[24:31]  ;
                              Hash_out_buffer[264:271]          <=  ci_out[32:39]  ;
                              Hash_out_buffer[328:335]          <=  ci_out[40:47]  ;
                              Hash_out_buffer[392:399]          <=  ci_out[48:55]  ;
                              Hash_out_buffer[456:463]          <=  ci_out[56:63]  ;
                              Hash_out_buffer[520:527]          <=  ci_out[64:71]  ;
                              Hash_out_buffer[584:591]          <=  ci_out[72:79]  ;
                              Hash_out_buffer[648:655]          <=  ci_out[80:87]  ;
                              Hash_out_buffer[712:719]          <=  ci_out[88:95]  ;
                              Hash_out_buffer[776:783]          <=  ci_out[96:103] ;
                              Hash_out_buffer[840:847]          <=  ci_out[104:111]; 
                              Hash_out_buffer[904:911]          <=  ci_out[112:119];
                              Hash_out_buffer[968:975]          <=  ci_out[120:127]; 
                              Hash_out_buffer[1032:1039]        <=  ci_out[128:135]; 
                              Hash_out_buffer[1096:1103]        <=  ci_out[136:143];
                              Hash_out_buffer[1160:1167]        <=  ci_out[144:151]; 
                              Hash_out_buffer[1224:1231]        <=  ci_out[152:159]; 
                              Hash_out_buffer[1288:1295]        <=  ci_out[160:167];      
                            end
                        3'd5: begin
                            Hash_out_buffer[16:23]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[80:87]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[144:151]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[208:215]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[272:279]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[336:343]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[400:407]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[464:471]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[528:535]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[592:599]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[656:663]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[720:727]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[784:791]          <=  ci_out[96:103] ;
                            Hash_out_buffer[848:855]          <=  ci_out[104:111]; 
                            Hash_out_buffer[912:919]          <=  ci_out[112:119];
                            Hash_out_buffer[976:983]          <=  ci_out[120:127]; 
                            Hash_out_buffer[1040:1047]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1104:1111]        <=  ci_out[136:143];
                            Hash_out_buffer[1168:1175]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1232:1239]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1296:1303]        <=  ci_out[160:167];
                        end
                        3'd4: begin
                            Hash_out_buffer[24:31]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[88:95]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[152:159]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[216:223]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[280:287]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[344:351]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[408:415]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[472:479]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[536:543]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[600:607]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[664:671]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[728:735]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[792:799]          <=  ci_out[96:103] ;
                            Hash_out_buffer[856:863]          <=  ci_out[104:111]; 
                            Hash_out_buffer[920:927]          <=  ci_out[112:119];
                            Hash_out_buffer[984:991]          <=  ci_out[120:127]; 
                            Hash_out_buffer[1048:1055]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1112:1119]        <=  ci_out[136:143];
                            Hash_out_buffer[1176:1183]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1240:1247]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1304:1311]        <=  ci_out[160:167];
                        end
                        3'd3: begin
                            Hash_out_buffer[32:39]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[96:103]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[160:167]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[224:231]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[288:295]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[352:359]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[416:423]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[480:487]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[544:551]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[608:615]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[672:679]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[736:743]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[800:807]          <=  ci_out[96:103] ;
                            Hash_out_buffer[864:871]          <=  ci_out[104:111]; 
                            Hash_out_buffer[928:935]          <=  ci_out[112:119];
                            Hash_out_buffer[992:999]          <=  ci_out[120:127]; 
                            Hash_out_buffer[1056:1063]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1120:1127]        <=  ci_out[136:143];
                            Hash_out_buffer[1184:1191]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1248:1255]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1312:1319]        <=  ci_out[160:167];
                        end              
                        3'd2: begin
                            Hash_out_buffer[40:47]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[104:111]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[168:175]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[232:239]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[296:303]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[360:367]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[424:431]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[488:495]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[552:559]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[616:623]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[680:687]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[744:751]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[808:815]          <=  ci_out[96:103] ;
                            Hash_out_buffer[872:879]          <=  ci_out[104:111]; 
                            Hash_out_buffer[936:943]          <=  ci_out[112:119];
                            Hash_out_buffer[1000:1007]          <=  ci_out[120:127]; 
                            Hash_out_buffer[1064:1071]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1128:1135]        <=  ci_out[136:143];
                            Hash_out_buffer[1192:1199]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1256:1263]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1320:1327]        <=  ci_out[160:167];
                        end      
                        3'd1: begin
                            Hash_out_buffer[48:55]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[112:119]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[176:183]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[240:247]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[304:311]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[368:375]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[432:439]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[496:503]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[560:567]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[624:631]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[688:695]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[752:759]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[816:823]          <=  ci_out[96:103] ;
                            Hash_out_buffer[880:887]          <=  ci_out[104:111]; 
                            Hash_out_buffer[944:951]          <=  ci_out[112:119];
                            Hash_out_buffer[1008:1015]          <=  ci_out[120:127]; 
                            Hash_out_buffer[1072:1079]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1136:1143]        <=  ci_out[136:143];
                            Hash_out_buffer[1200:1207]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1264:1271]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1328:1335]        <=  ci_out[160:167];
                        end
                        3'd0: begin
                            Hash_out_buffer[56:63]             <=  ci_out[0:7]    ;
                            Hash_out_buffer[120:127]            <=  ci_out[8:15]   ;
                            Hash_out_buffer[184:191]          <=  ci_out[16:23]  ;
                            Hash_out_buffer[248:255]          <=  ci_out[24:31]  ;
                            Hash_out_buffer[312:319]          <=  ci_out[32:39]  ;
                            Hash_out_buffer[376:383]          <=  ci_out[40:47]  ;
                            Hash_out_buffer[440:447]          <=  ci_out[48:55]  ;
                            Hash_out_buffer[504:511]          <=  ci_out[56:63]  ;
                            Hash_out_buffer[568:575]          <=  ci_out[64:71]  ;
                            Hash_out_buffer[632:639]          <=  ci_out[72:79]  ;
                            Hash_out_buffer[696:703]          <=  ci_out[80:87]  ;
                            Hash_out_buffer[760:767]          <=  ci_out[88:95]  ;
                            Hash_out_buffer[824:831]          <=  ci_out[96:103] ;
                            Hash_out_buffer[888:895]          <=  ci_out[104:111]; 
                            Hash_out_buffer[952:959]          <=  ci_out[112:119];
                            Hash_out_buffer[1016:1023]        <=  ci_out[120:127]; 
                            Hash_out_buffer[1080:1087]        <=  ci_out[128:135]; 
                            Hash_out_buffer[1144:1151]        <=  ci_out[136:143];
                            Hash_out_buffer[1208:1215]        <=  ci_out[144:151]; 
                            Hash_out_buffer[1272:1279]        <=  ci_out[152:159]; 
                            Hash_out_buffer[1336:1343]        <=  ci_out[160:167];
                        end
                    default : Hash_out_buffer <= Hash_out_buffer;
                    endcase
                end    
            else 
                Hash_out_buffer <= Hash_out_buffer;
        end
    else
        Hash_out_buffer <= Hash_out_buffer;
end



endmodule