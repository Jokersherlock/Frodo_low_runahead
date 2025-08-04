module driver_rom #(
    parameter ADDR_WIDTH = 12
)(
    input                           clk,
    input                           rstn,
    input       [ADDR_WIDTH-1:0]    load_addr,
    input       [ADDR_WIDTH-1:0]    read_addr,
    output  reg [63:0]              data_dout,
    output  reg [13:0]              load_addr_dout,
    output  reg [13:0]              read_addr_dout  
);

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            data_dout <= 64'b0;
        end
        else begin
            case (load_addr)
                // keygen_640
                     //seedse
                12'h000: data_dout <= 64'h0348B1CC251AD82F;
                12'h001: data_dout <= 64'h2D7F73369973CD2D;
                12'h002: data_dout <= 64'h74491BADCFD705B5;
                12'h003: data_dout <= 64'h475E3286863C3299;
                    //z
                12'h004: data_dout <= 64'hCA873FFAAA67F292;
                12'h005: data_dout <= 64'h2A20294FB51CD060;
                // encap_640
                    //salt
                12'h006: data_dout <= 64'h7B2A1798210039D6;
                12'h007: data_dout <= 64'hBA01C0F6A8EC4219;
                12'h008: data_dout <= 64'h5427AC59EE2B2026;
                12'h009: data_dout <= 64'h57D3D8417D76EA84;
                    //u
                12'h00a: data_dout <= 64'h2DBA4EEF667C4AEB;
                12'h00b: data_dout <= 64'hB106C78B8DC838DB;
                    //seedA
                12'h00c: data_dout <= 64'hE09D470188D7B0A3;
                12'h00d: data_dout <= 64'h433DCABCD59C7BF6;
                //decap_640
                    //C
                12'h00e: data_dout <= 64'h05D7576C06F40922;
                12'h00f: data_dout <= 64'h7C7541941CAF1BF4;
                12'h010: data_dout <= 64'h07C911BD79C64FC3;
                12'h011: data_dout <= 64'h74F13F69081945F9;
                12'h012: data_dout <= 64'h278E2FCB51FC0FAA;
                12'h013: data_dout <= 64'h2A471D2112D00AB2;
                12'h014: data_dout <= 64'h7039221369283F22;
                12'h015: data_dout <= 64'h7C76385166C02790;
                12'h016: data_dout <= 64'h38F35C4142F9159C;
                12'h017: data_dout <= 64'h0FA04E3D09551EED;
                12'h018: data_dout <= 64'h097E6CD71F9B0D0C;
                12'h019: data_dout <= 64'h7337608C25B44F31;
                12'h01a: data_dout <= 64'h5F7E1A1375CC4E7A;
                12'h01b: data_dout <= 64'h306147EA1DF01F7F;
                12'h01c: data_dout <= 64'h6B4453E62C8A6F03;
                12'h01d: data_dout <= 64'h059065F11A214C87;
                //keygen-976
                    //seedse
                12'h01e: data_dout <= 64'h2D7F73369973CD2D;
                12'h01f: data_dout <= 64'h74491BADCFD705B5;
                12'h020: data_dout <= 64'h475E3286863C3299;
                12'h021: data_dout <= 64'hCA873FFAAA67F292;
                12'h022: data_dout <= 64'h2A20294FB51CD060;
                12'h023: data_dout <= 64'hFDDCBC7ECB4C783E;
                    //z
                12'h024: data_dout <= 64'h7478F76A7F2B5445;
                12'h025: data_dout <= 64'hAA84501779440F2E;
                //encap-976
                    //salt
                12'h026: data_dout <= 64'h795BBAA045BC3B46;
                12'h027: data_dout <= 64'h62B02FF8EE46DD80;
                12'h028: data_dout <= 64'hBB06F342D0775003;
                12'h029: data_dout <= 64'hF165D90D0E049163;
                12'h02a: data_dout <= 64'hB4CC9FCA83D1A9FD;
                12'h02b: data_dout <= 64'h3300AB84B110C08F;
                    //u
                12'h02c: data_dout <= 64'h723B5EC1626771EE;
                12'h02d: data_dout <= 64'h00519A3BA65076AA;
                12'h02e: data_dout <= 64'hC07504E70F3CB040;
                    //seedA
                12'h02f: data_dout <= 64'h7B87102D7CC9FD01;
                12'h030: data_dout <= 64'hAE362546A9207866;
                //decap-976
                12'h031: data_dout <= 64'hAD6E054DF0C8730C;
                12'h032: data_dout <= 64'hD47308E799D53850;
                12'h033: data_dout <= 64'h23AF8A4D3A37A181;
                12'h034: data_dout <= 64'h49CA14B1A77112FD;
                12'h035: data_dout <= 64'h0B16E8D1AB1B091E;
                12'h036: data_dout <= 64'h7DD55EB3BA82E283;
                12'h037: data_dout <= 64'h00901A7712CAFD7F;
                12'h038: data_dout <= 64'h92E173FBC3E1E63B;
                12'h039: data_dout <= 64'h837B22D343B9FA9D;
                12'h03a: data_dout <= 64'hEB08F0DE831660AE;
                12'h03b: data_dout <= 64'h6C2885ED441D8909;
                12'h03c: data_dout <= 64'h4E472424C8D6DD62;
                12'h03d: data_dout <= 64'h021E780F65D103AF;
                12'h03e: data_dout <= 64'h8017A7E74FDDD123;
                12'h03f: data_dout <= 64'hEAE90A59F9E476D5;
                12'h040: data_dout <= 64'hA8AFAFF9E124CE6F;
                //keygen-1344
                    //seedse
                12'h041: data_dout <= 64'h74491BADCFD705B5;
                12'h042: data_dout <= 64'h475E3286863C3299;
                12'h043: data_dout <= 64'hCA873FFAAA67F292;
                12'h044: data_dout <= 64'h2A20294FB51CD060;
                12'h045: data_dout <= 64'hFDDCBC7ECB4C783E;
                12'h046: data_dout <= 64'h7478F76A7F2B5445;
                12'h047: data_dout <= 64'hAA84501779440F2E;
                12'h048: data_dout <= 64'hAA780634743B8B48;
                    //z
                12'h049: data_dout <= 64'h61A1B028962EE238;
                12'h04a: data_dout <= 64'h9C3B1752D20BEBFD;
                //encap-1344
                    //salt
                12'h04b: data_dout <= 64'hDE754CD5E0043ACB;
                12'h04c: data_dout <= 64'h5A93DFFBFD5B70B9;
                12'h04d: data_dout <= 64'hC6B0E5E62E802875;
                12'h04e: data_dout <= 64'h84D09B1D762B3BA7;
                12'h04f: data_dout <= 64'h4FA84CFCF34C6E8A;
                12'h050: data_dout <= 64'hF4FE5BF31A33E014;
                12'h051: data_dout <= 64'hF96DAE6D3AB1421E;
                12'h052: data_dout <= 64'hCAA17B85C138F737;
                    //u
                12'h053: data_dout <= 64'h7666FF877658089F;
                12'h054: data_dout <= 64'h288D913EE71D675C;
                12'h055: data_dout <= 64'h1AA3E7F43F57CA23;
                12'h056: data_dout <= 64'hEA40E52640326091;
                    //seedA
                12'h057: data_dout <= 64'h160237500729FF44;
                12'h058: data_dout <= 64'hCFC96329C437C7F0;
                //decap-1344
                    //C
                12'h059: data_dout <= 64'hD44F19E81566217A;
                12'h05a: data_dout <= 64'hB68E2E7B0E6B3F3F;
                12'h05b: data_dout <= 64'h8B053C91783E474C;
                12'h05c: data_dout <= 64'hB66F6603E3144364;
                12'h05d: data_dout <= 64'h3C6EF2FBAAE67269;
                12'h05e: data_dout <= 64'h58D2186662DC5E0F;
                12'h05f: data_dout <= 64'h45B3E65FDC83A2A1;
                12'h060: data_dout <= 64'hD3D82B0785F3564D;
                12'h061: data_dout <= 64'hAE45306CFF7922E3;
                12'h062: data_dout <= 64'h453BA64426AF458B;
                12'h063: data_dout <= 64'h26F8C4ED11EBF91C;
                12'h064: data_dout <= 64'hCA38268396269E24;
                12'h065: data_dout <= 64'h0B15B675836F8028;
                12'h066: data_dout <= 64'hE28469B6F5B9AE51;
                12'h067: data_dout <= 64'h43491E98838275F2;
                12'h068: data_dout <= 64'h520DE342E7A518E0;
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            load_addr_dout <= 14'b0;
        end
        else begin
            case (load_addr)
                //keygen_640
                    //seedse
                12'h000: load_addr_dout <= 14'h3fe0;
                12'h001: load_addr_dout <= 14'h3fe1;
                12'h002: load_addr_dout <= 14'h3fe2;
                12'h003: load_addr_dout <= 14'h3fe3;
                    //z
                12'h004: load_addr_dout <= 14'h0ff0;
                12'h005: load_addr_dout <= 14'h0ff1;
                //encap_640
                    //salt
                12'h006: load_addr_dout <= 14'h2ff8;
                12'h007: load_addr_dout <= 14'h2ff9;
                12'h008: load_addr_dout <= 14'h2ffa;
                12'h009: load_addr_dout <= 14'h2ffb;
                    //u
                12'h00a: load_addr_dout <= 14'h0ff2;
                12'h00b: load_addr_dout <= 14'h0ff3;
                    //seedA
                12'h00c: load_addr_dout <= 14'h0ffa;
                12'h00d: load_addr_dout <= 14'h0ffb;
                //decap_640
                    //C
                12'h00e: load_addr_dout <= 14'h0fd0; 
                12'h00f: load_addr_dout <= 14'h0fd1;
                12'h010: load_addr_dout <= 14'h0fd2;
                12'h011: load_addr_dout <= 14'h0fd3;
                12'h012: load_addr_dout <= 14'h0fd4;
                12'h013: load_addr_dout <= 14'h0fd5;
                12'h014: load_addr_dout <= 14'h0fd6;
                12'h015: load_addr_dout <= 14'h0fd7;
                12'h016: load_addr_dout <= 14'h0fd8;
                12'h017: load_addr_dout <= 14'h0fd9;
                12'h018: load_addr_dout <= 14'h0fda;
                12'h019: load_addr_dout <= 14'h0fdb;
                12'h01a: load_addr_dout <= 14'h0fdc;
                12'h01b: load_addr_dout <= 14'h0fdd;
                12'h01c: load_addr_dout <= 14'h0fde;
                12'h01d: load_addr_dout <= 14'h0fdf;
                //keygen_976
                    //seedse
                12'h01e: load_addr_dout <= 14'h3fe0;
                12'h01f: load_addr_dout <= 14'h3fe1;
                12'h020: load_addr_dout <= 14'h3fe2;
                12'h021: load_addr_dout <= 14'h3fe3;
                12'h022: load_addr_dout <= 14'h3fe4;
                12'h023: load_addr_dout <= 14'h3fe5;
                    //z
                12'h024: load_addr_dout <= 14'h0ff0;
                12'h025: load_addr_dout <= 14'h0ff1;
                //encap_976
                    //salt
                12'h026: load_addr_dout <= 14'h2ff8;
                12'h027: load_addr_dout <= 14'h2ff9;
                12'h028: load_addr_dout <= 14'h2ffa;
                12'h029: load_addr_dout <= 14'h2ffb;
                12'h02a: load_addr_dout <= 14'h2ffc;
                12'h02b: load_addr_dout <= 14'h2ffd;
                    //u
                12'h02c: load_addr_dout <= 14'h0ff2;
                12'h02d: load_addr_dout <= 14'h0ff3;
                12'h02e: load_addr_dout <= 14'h0ff4;
                    //seedA
                12'h02f: load_addr_dout <= 14'h0ffa;
                12'h030: load_addr_dout <= 14'h0ffb;
                // decap_976
                12'h031: load_addr_dout <= 14'h0fd0; 
                12'h032: load_addr_dout <= 14'h0fd1;
                12'h033: load_addr_dout <= 14'h0fd2;
                12'h034: load_addr_dout <= 14'h0fd3;
                12'h035: load_addr_dout <= 14'h0fd4;
                12'h036: load_addr_dout <= 14'h0fd5;
                12'h037: load_addr_dout <= 14'h0fd6;
                12'h038: load_addr_dout <= 14'h0fd7;
                12'h039: load_addr_dout <= 14'h0fd8;
                12'h03a: load_addr_dout <= 14'h0fd9;
                12'h03b: load_addr_dout <= 14'h0fda;
                12'h03c: load_addr_dout <= 14'h0fdb;
                12'h03d: load_addr_dout <= 14'h0fdc;
                12'h03e: load_addr_dout <= 14'h0fdd;
                12'h03f: load_addr_dout <= 14'h0fde;
                12'h040: load_addr_dout <= 14'h0fdf;
                //keygen-1344
                    //seedse
                12'h041: load_addr_dout <= 14'h3fe0;
                12'h042: load_addr_dout <= 14'h3fe1;
                12'h043: load_addr_dout <= 14'h3fe2;
                12'h044: load_addr_dout <= 14'h3fe3;
                12'h045: load_addr_dout <= 14'h3fe4;
                12'h046: load_addr_dout <= 14'h3fe5;
                12'h047: load_addr_dout <= 14'h3fe6;
                12'h048: load_addr_dout <= 14'h3fe7;
                    //z
                12'h049: load_addr_dout <= 14'h0ff0;
                12'h04a: load_addr_dout <= 14'h0ff1;
                //encap-1344
                    //salt
                12'h04b: load_addr_dout <= 14'h2ff8;
                12'h04c: load_addr_dout <= 14'h2ff9;
                12'h04d: load_addr_dout <= 14'h2ffa;
                12'h04e: load_addr_dout <= 14'h2ffb;
                12'h04f: load_addr_dout <= 14'h2ffc;
                12'h050: load_addr_dout <= 14'h2ffd;
                12'h051: load_addr_dout <= 14'h2ffe;
                12'h052: load_addr_dout <= 14'h2fff;
                    //u
                12'h053: load_addr_dout <= 14'h0ff2;
                12'h054: load_addr_dout <= 14'h0ff3;
                12'h055: load_addr_dout <= 14'h0ff4;
                12'h056: load_addr_dout <= 14'h0ff5;
                    //seedA
                12'h057: load_addr_dout <= 14'h0ffa;
                12'h058: load_addr_dout <= 14'h0ffb;
                //decap-1344
                    //C
                12'h059: load_addr_dout <= 14'h0fd0; 
                12'h05a: load_addr_dout <= 14'h0fd1;
                12'h05b: load_addr_dout <= 14'h0fd2;
                12'h05c: load_addr_dout <= 14'h0fd3;
                12'h05d: load_addr_dout <= 14'h0fd4;
                12'h05e: load_addr_dout <= 14'h0fd5;
                12'h05f: load_addr_dout <= 14'h0fd6;
                12'h060: load_addr_dout <= 14'h0fd7;
                12'h061: load_addr_dout <= 14'h0fd8;
                12'h062: load_addr_dout <= 14'h0fd9;
                12'h063: load_addr_dout <= 14'h0fda;
                12'h064: load_addr_dout <= 14'h0fdb;
                12'h065: load_addr_dout <= 14'h0fdc;
                12'h066: load_addr_dout <= 14'h0fdd;
                12'h067: load_addr_dout <= 14'h0fde;
                12'h068: load_addr_dout <= 14'h0fdf;
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            read_addr_dout <= 14'b0;
        end
        else begin
            case (read_addr)
                //keygen_640
                12'h000: read_addr_dout <= 14'h3fd2;
                12'h001: read_addr_dout <= 14'h3fd3;
                //encap_640
                12'h002: read_addr_dout <= 14'h0ffc;
                12'h003: read_addr_dout <= 14'h0ffd;
                //decap_640
                12'h004: read_addr_dout <= 14'h0ffc;
                12'h005: read_addr_dout <= 14'h0ffd;
                12'h006: read_addr_dout <= 14'h2fd6;
                12'h007: read_addr_dout <= 14'h2fd7;
                //keygen-976
                12'h008: read_addr_dout <= 14'h3fd2;
                12'h009: read_addr_dout <= 14'h3fd3;
                12'h00a: read_addr_dout <= 14'h3fd4;
                //encap-976
                12'h00b: read_addr_dout <= 14'h0ffc;
                12'h00c: read_addr_dout <= 14'h0ffd;
                12'h00d: read_addr_dout <= 14'h0ffe;
                ///decap-976
                12'h00e: read_addr_dout <= 14'h0ffc;
                12'h00f: read_addr_dout <= 14'h0ffd;
                12'h010: read_addr_dout <= 14'h0ffe;
                12'h011: read_addr_dout <= 14'h2fd6;
                12'h012: read_addr_dout <= 14'h2fd7;
                12'h013: read_addr_dout <= 14'h2fd8;
                //keygen-1344
                12'h014: read_addr_dout <= 14'h3fd2;
                12'h015: read_addr_dout <= 14'h3fd3;
                12'h016: read_addr_dout <= 14'h3fd4;
                12'h017: read_addr_dout <= 14'h3fd5;
                //encap-1344
                12'h018: read_addr_dout <= 14'h0ffc;
                12'h019: read_addr_dout <= 14'h0ffd;
                12'h01a: read_addr_dout <= 14'h0ffe;
                12'h01b: read_addr_dout <= 14'h0fff;


                // 12'h01c: read_addr_dout <= 14'h3fe8;
                // 12'h01d: read_addr_dout <= 14'h3fe9;
                // 12'h01e: read_addr_dout <= 14'h3fea;
                // 12'h01f: read_addr_dout <= 14'h3feb;
                // 12'h020: read_addr_dout <= 14'h3fec;
                // 12'h021: read_addr_dout <= 14'h3fed;
                // 12'h022: read_addr_dout <= 14'h3fee;
                // 12'h023: read_addr_dout <= 14'h3fff;
                // 12'h024: read_addr_dout <= 14'h3ff0;
                // 12'h025: read_addr_dout <= 14'h3ff1;
                // 12'h026: read_addr_dout <= 14'h3ff2;
                // 12'h027: read_addr_dout <= 14'h3ff3;
                // 12'h028: read_addr_dout <= 14'h3ff4;
                // 12'h029: read_addr_dout <= 14'h3ff5;
                // 12'h02a: read_addr_dout <= 14'h3ff6;
                // 12'h02b: read_addr_dout <= 14'h3ff7;
                // 12'h02c: read_addr_dout <= 14'h3ff8;
                // 12'h02d: read_addr_dout <= 14'h3ff9;
                // 12'h02e: read_addr_dout <= 14'h3ffa;
                // 12'h02f: read_addr_dout <= 14'h3ffb;
                // 12'h030: read_addr_dout <= 14'h3ffc;
                // 12'h031: read_addr_dout <= 14'h3ffd;
                // 12'h032: read_addr_dout <= 14'h3ffe;
                // 12'h033: read_addr_dout <= 14'h3fff;
                // 12'h034: read_addr_dout <= 14'h0ff6;
                // 12'h035: read_addr_dout <= 14'h0ff7;
                // 12'h036: read_addr_dout <= 14'h0ff8;
                // 12'h037: read_addr_dout <= 14'h0ff9;
                //decap-1344
                12'h01c: read_addr_dout <= 14'h0ffc;
                12'h01d: read_addr_dout <= 14'h0ffd;
                12'h01e: read_addr_dout <= 14'h0ffe;
                12'h01f: read_addr_dout <= 14'h0fff;
                12'h020: read_addr_dout <= 14'h2fd6;
                12'h021: read_addr_dout <= 14'h2fd7;
                12'h022: read_addr_dout <= 14'h2fd8;
                12'h023: read_addr_dout <= 14'h2fd9;

                // 12'h038: read_addr_dout <= 14'h3fe8;
                // 12'h039: read_addr_dout <= 14'h3fe9;
                // 12'h03a: read_addr_dout <= 14'h3fea;
                // 12'h03b: read_addr_dout <= 14'h3feb;
                // 12'h03c: read_addr_dout <= 14'h3fec;
                // 12'h03d: read_addr_dout <= 14'h3fed;
                // 12'h03e: read_addr_dout <= 14'h3fee;
                // 12'h03f: read_addr_dout <= 14'h3fff;
                // 12'h040: read_addr_dout <= 14'h3ff0;
                // 12'h041: read_addr_dout <= 14'h3ff1;
                // 12'h042: read_addr_dout <= 14'h3ff2;
                // 12'h043: read_addr_dout <= 14'h3ff3;
                // 12'h044: read_addr_dout <= 14'h3ff4;
                // 12'h045: read_addr_dout <= 14'h3ff5;
                // 12'h046: read_addr_dout <= 14'h3ff6;
                // 12'h047: read_addr_dout <= 14'h3ff7;
                // 12'h048: read_addr_dout <= 14'h3ff8;
                // 12'h049: read_addr_dout <= 14'h3ff9;
                // 12'h04a: read_addr_dout <= 14'h3ffa;
                // 12'h04b: read_addr_dout <= 14'h3ffb;
                // 12'h04c: read_addr_dout <= 14'h3ffc;
                // 12'h04d: read_addr_dout <= 14'h3ffd;
                // 12'h04e: read_addr_dout <= 14'h3ffe;
                // 12'h04f: read_addr_dout <= 14'h3fff;
                // 12'h050: read_addr_dout <= 14'h0ff6;
                // 12'h051: read_addr_dout <= 14'h0ff7;
                // 12'h052: read_addr_dout <= 14'h0ff8;
                // 12'h053: read_addr_dout <= 14'h0ff9;

            endcase
        end
    end

    

    
endmodule