module AGU_hash (
    input                   clk,
    input                   rstn,
    input                   addr_clr,
    input                   add_en,
    input       [2:0]       mode,
    output reg  [11:0]      addr_output,
    output reg  [2:0]       bias,
    input       [1:0]      level
);
    reg [10:0] loop;
    always @(*) begin
        case (level)
            2'b01: loop = 11'd1343;
            2'b10: loop = 11'd975;
            2'b11: loop = 11'd639;
            2'b00: loop = 11'd0;
        endcase        
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_output <= 12'b0;
            bias <= 3'b0;
        end
        else if(addr_clr)begin
            addr_output <= 12'b0;
            bias <= 3'b0;
        end
        else if(add_en)begin
            case (mode)
                3'b000:begin // S,S'
                    if(addr_output == loop)begin
                        addr_output <= 12'b0;
                        bias <= bias + 1'b1;
                    end
                    else begin
                        addr_output <= addr_output + 1'b1;
                    end
                end
                3'b001:begin// E
                    if(bias[1:0] == 2'd3)begin
                        addr_output <= addr_output + 1'b1;
                    end
                    bias <= bias + 1'b1;
                end
                3'b010:begin//E'
                    if(addr_output[11:1] == loop)begin
                        //addr_output <= 12'b0;
                        bias <= bias + 1'b1;
                        if((bias[2] && bias != 3'b111)|| bias == 3'b011)begin
                            addr_output <= 12'd1;
                        end
                        else begin
                            addr_output <= 12'd0;
                        end
                    end
                    else begin
                        addr_output[11:1] <= addr_output[11:1] + 1'b1;
                    end
                end
                3'b100:begin//B
                    addr_output <= addr_output + 1'b1;
                end
                3'b101:begin//B'
                    if(bias[0]==1'b1)begin
                        if(addr_output[11:1] == loop)begin
                            addr_output <= 12'b0;
                            bias[2:1] <= bias[2:1] + 1'b1;
                        end
                        else begin
                            addr_output[11:1] <= addr_output[11:1] + 1'b1;
                        end
                    end
                    bias[0] <= ~bias[0];
                end
                3'b110:begin
                    if(bias == 3'd7)begin
                        addr_output <= addr_output + 1'b1;
                    end
                    bias <= bias + 1'b1;
                end
            endcase
        end
    end


    
endmodule