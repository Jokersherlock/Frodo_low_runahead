module Datapre (
    input              clk,
    input              rstn,
    input              start_pos,
    input              done,

    input       [63:0] A_data,
    input       [63:0] B_data,
    input       [63:0] hash_out,
    output reg  [15:0] hash_cut,
    input              genA,


    input       [7:0]  sample_in,
    output reg  [63:0] sample_out,
    input              hash_width,

    input              short_data_mode,
    input              short_bia_add,
    input              long_bia_add,

    output reg  [7:0]  short_data_0,short_data_1,short_data_2,short_data_3,
    output reg  [15:0] long_data_0,long_data_1,long_data_2,long_data_3,
    output reg  [7:0]  hash_in,

    input              hash_in_tran,
    input       [2:0]  hash_bias,

    input              sample_en,

    input              hash_inverse,
    input              B_hash_en

);

    reg [2:0] short_bia;
    reg [1:0] long_bia;
    //当A右乘时，8bit数据每次只读1个，其余每次读4个
    always @(*) begin
        if(short_data_mode)begin
            case (short_bia)
                3'b000:begin
                    short_data_0 = A_data[7:0];
                    short_data_1 = A_data[7:0];
                    short_data_2 = A_data[7:0];
                    short_data_3 = A_data[7:0];
                end
                3'b001:begin
                    short_data_0 = A_data[15:8];
                    short_data_1 = A_data[15:8];
                    short_data_2 = A_data[15:8];
                    short_data_3 = A_data[15:8];
                end
                3'b010:begin
                    short_data_0 = A_data[23:16];
                    short_data_1 = A_data[23:16];
                    short_data_2 = A_data[23:16];
                    short_data_3 = A_data[23:16];
                end
                3'b011:begin
                    short_data_0 = A_data[31:24];
                    short_data_1 = A_data[31:24];
                    short_data_2 = A_data[31:24];
                    short_data_3 = A_data[31:24];
                end
                3'b100:begin
                    short_data_0 = A_data[39:32];
                    short_data_1 = A_data[39:32];
                    short_data_2 = A_data[39:32];
                    short_data_3 = A_data[39:32];
                end
                3'b101:begin
                    short_data_0 = A_data[47:40];
                    short_data_1 = A_data[47:40];
                    short_data_2 = A_data[47:40];
                    short_data_3 = A_data[47:40];
                end
                3'b110:begin
                    short_data_0 = A_data[55:48];
                    short_data_1 = A_data[55:48];
                    short_data_2 = A_data[55:48];
                    short_data_3 = A_data[55:48];
                end
                3'b111:begin
                    short_data_0 = A_data[63:56];
                    short_data_1 = A_data[63:56];
                    short_data_2 = A_data[63:56];
                    short_data_3 = A_data[63:56];
                end
            endcase
        end
        else begin
            if(!short_bia[0])begin
                short_data_0 = A_data[7:0];
                short_data_1 = A_data[15:8];
                short_data_2 = A_data[23:16];
                short_data_3 = A_data[31:24];
            end
            else begin
                short_data_0 = A_data[39:32];
                short_data_1 = A_data[47:40];
                short_data_2 = A_data[55:48];
                short_data_3 = A_data[63:56];
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            short_bia <= 3'b0;
        end
        else if(start_pos)begin
            short_bia <= 3'b0;
        end
        else if(done)begin
            short_bia <= 3'b0;
        end
        else if(short_bia_add)begin
            short_bia <= short_bia + 1'b1;
        end
    end

    //long data刚好与short_data相反
    always @(*) begin
        if(genA)begin
            long_data_0 = hash_cut;
            long_data_1 = hash_cut;
            long_data_2 = hash_cut;
            long_data_3 = hash_cut;
        end
        else begin
            if(short_data_mode)begin
                long_data_0 = B_data[15:0];
                long_data_1 = B_data[31:16];
                long_data_2 = B_data[47:32];
                long_data_3 = B_data[63:48];
            end
            else begin
                case (long_bia) 
                    2'b00:begin
                        long_data_0 = B_data[15:0];
                        long_data_1 = B_data[15:0];
                        long_data_2 = B_data[15:0];
                        long_data_3 = B_data[15:0];
                    end
                    2'b01:begin
                        long_data_0 = B_data[31:16];
                        long_data_1 = B_data[31:16];
                        long_data_2 = B_data[31:16];
                        long_data_3 = B_data[31:16];
                    end
                    2'b10:begin
                        long_data_0 = B_data[47:32];
                        long_data_1 = B_data[47:32];
                        long_data_2 = B_data[47:32];
                        long_data_3 = B_data[47:32];
                    end
                    2'b11:begin
                        long_data_0 = B_data[63:48];
                        long_data_1 = B_data[63:48];
                        long_data_2 = B_data[63:48];
                        long_data_3 = B_data[63:48];
                    end
                endcase
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            long_bia <= 2'b0;
        end
        else if(start_pos)begin
            long_bia <= 2'b0;
        end
        else if(done)begin
            long_bia <= 2'b0;
        end
        else if(long_bia_add)begin
            long_bia <= long_bia + 1'b1;
        end
    end

    always @(*) begin
        if(!hash_in_tran)begin
            if(!hash_inverse)begin
                case (short_bia)
                3'b000: hash_in = B_data[7:0];
                3'b001: hash_in = B_data[15:8];
                3'b010: hash_in = B_data[23:16];
                3'b011: hash_in = B_data[31:24];
                3'b100: hash_in = B_data[39:32];
                3'b101: hash_in = B_data[47:40];
                3'b110: hash_in = B_data[55:48];
                3'b111: hash_in = B_data[63:56];
                endcase
            end
            else begin
                case (short_bia)
                3'b001: hash_in = B_data[7:0];
                3'b000: hash_in = B_data[15:8];
                3'b011: hash_in = B_data[23:16];
                3'b010: hash_in = B_data[31:24];
                3'b101: hash_in = B_data[39:32];
                3'b100: hash_in = B_data[47:40];
                3'b111: hash_in = B_data[55:48];
                3'b110: hash_in = B_data[63:56];
                endcase
            end
        end
        else begin
            if(!hash_inverse)begin
                case (hash_bias[2:1])
                    2'b00: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[7:0];
                        end
                        else begin
                            hash_in = B_data[15:8];
                        end
                    end
                    2'b01: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[23:16];
                        end
                        else begin
                            hash_in = B_data[31:24];
                        end
                    end
                    2'b10: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[39:32];
                        end
                        else begin
                            hash_in = B_data[47:40];
                        end
                    end
                    2'b11: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[55:48];
                        end
                        else begin
                            hash_in = B_data[63:56];
                        end
                    end
                endcase
            end
            else begin
                case (hash_bias[2:1])
                    2'b00: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[15:8];
                        end
                        else begin
                            hash_in = B_data[7:0];
                        end
                    end
                    2'b01: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[31:24];
                        end
                        else begin
                            hash_in = B_data[23:16];
                        end
                    end
                    2'b10: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[47:40];
                        end
                        else begin
                            hash_in = B_data[39:32];
                        end
                    end
                    2'b11: begin
                        if(!hash_bias[0])begin
                            hash_in = B_data[63:56];
                        end
                        else begin
                            hash_in = B_data[55:48];
                        end
                    end
                endcase
            end  
        end
    end

    always @(*) begin
        case (long_bia)
            2'b00:  hash_cut = hash_out[15:0];
            2'b01:  hash_cut = hash_out[31:16];
            2'b10:  hash_cut = hash_out[47:32];
            2'b11:  hash_cut = hash_out[63:48];
        endcase
    end

    reg [2:0] hash_bias_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_bias_reg <= 3'b0;
        end
        else begin
            hash_bias_reg <= hash_bias;
        end
    end


    always @(*) begin
        if(sample_en)begin
            if(B_hash_en)begin
                sample_out = B_data;
                if(hash_width)begin
                    case (hash_bias_reg[1:0])
                        2'b00: sample_out[15:0]  = {{8{sample_in[7]}},sample_in};
                        2'b01: sample_out[31:16] = {{8{sample_in[7]}},sample_in};
                        2'b10: sample_out[47:32] = {{8{sample_in[7]}},sample_in};
                        2'b11: sample_out[63:48] = {{8{sample_in[7]}},sample_in};
                    endcase
                end
                else begin
                    case (hash_bias_reg)
                        3'b000: sample_out[7:0] = sample_in;
                        3'b001: sample_out[15:8] = sample_in;
                        3'b010: sample_out[23:16] = sample_in;
                        3'b011: sample_out[31:24] = sample_in;
                        3'b100: sample_out[39:32] = sample_in;
                        3'b101: sample_out[47:40] = sample_in;
                        3'b110: sample_out[55:48] = sample_in;
                        3'b111: sample_out[63:56] = sample_in;
                    endcase
                end
            end
            else begin
                sample_out = B_data;
                case (long_bia)
                    2'b00: sample_out[15:0]  = {{8{sample_in[7]}},sample_in};
                    2'b01: sample_out[31:16] = {{8{sample_in[7]}},sample_in};
                    2'b10: sample_out[47:32] = {{8{sample_in[7]}},sample_in};
                    2'b11: sample_out[63:48] = {{8{sample_in[7]}},sample_in};
                endcase
            end
        end
        else begin
            sample_out = B_data;
            case(long_bia)
                2'b00: sample_out[15:0] = hash_cut;
                2'b01: sample_out[31:16] = hash_cut;
                2'b10: sample_out[47:32] = hash_cut;
                2'b11: sample_out[63:48] = hash_cut;
            endcase
        end
    end

endmodule