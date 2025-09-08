module Decode (
    input              clk,           
    input              rstn,         
    input              load_en,       // 模式一：载入 64bit 数据
    input              consume_en,    // 模式二：消费并输出 64bit 数据
    input              clr,    
    input       [1:0]  level,          // 11→640(2bit)，10→976(3bit)，01→1344(4bit)
    input       [63:0] din64,       // 从 RAM 读回的 64bit
    output reg  [63:0] dout64         // 并行输出 4×16bit
);
    
    // parameter SHIFT640   = 8;   // 2*4
    // parameter SHIFT976   = 12;  // 3*4
    // parameter SHIFT1344  = 16;  // 4*4

    reg [4:0] SHIFT;      // 位移量

    // parameter OFF640   = 16'd1 << 12;  // 2-bit 模式半间隔
    // parameter OFF976   = 16'd1 << 12;  // 3-bit 模式半间隔
    // parameter OFF1344  = 16'd1 << 11;  // 4-bit 模式半间隔


    // reg [4:0] OFFSET;
    // always @(*) begin
    //     case(level)
    //         2'b11:  OFFSET = OFF640;  
    //         2'b10:  OFFSET = OFF976;  
    //         2'b01:  OFFSET = OFF1344; 
    //         default:OFFSET = OFF1344;
    //     endcase
    // end

    function [0:15] decode16;
        input [15:0] data;
        input [1:0]  lvl;
        reg   [15:0] tmp;
        begin
            case(lvl)
                2'b01: begin // 1344：4-bit
                    tmp       = data + {5'd1,11'd0};
                    //decode16  = {12'b0, tmp[15:12]};
                    decode16 = {tmp[12],tmp[13],tmp[14],tmp[15],12'b0};
                end
                2'b10: begin // 976：3-bit
                    tmp       = data + {4'd1,12'd0};
                    //decode16  = {13'b0, tmp[15:13]};
                    decode16 = {tmp[13],tmp[14],tmp[15],13'b0};
                end
                2'b11: begin // 640：2-bit
                    tmp       = data + {4'd1,12'd0};
                    // 注意：取 tmp[14:13] 共 2 位
                    //decode16  = {14'b0, tmp[14:13]};
                    decode16 = {tmp[13],tmp[14],14'b0};
                end
                default: begin
                    tmp       = data;
                    decode16  = data;
                end
            endcase
        end
    endfunction

    reg [0:255] shift_reg;

    wire [15:0] d0,d1,d2,d3;
    wire [0:15] q0,q1,q2,q3;

    assign d0 = din64[15: 0];
    assign d1 = din64[31:16];
    assign d2 = din64[47:32];
    assign d3 = din64[63:48];

    assign q0 = decode16(d0, level);
    assign q1 = decode16(d1, level);
    assign q2 = decode16(d2, level);
    assign q3 = decode16(d3, level);

    // wire [15:0] raw_bits = (level==2'b01) ? {q3[3:0], q2[3:0], q1[3:0], q0[3:0]} :
    //                        (level==2'b10) ? {q3[2:0], q2[2:0], q1[2:0], q0[2:0]} :
    //                                         {q3[1:0], q2[1:0], q1[1:0], q0[1:0]};

    reg [1:0] bia;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            bia <= 2'b0;
        else if(clr)
            bia <= 2'b0;
        else if(consume_en)
            bia <= bia + 1'b1;
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            shift_reg <= 256'b0;
        end
        else if(clr)
            shift_reg <= 256'b0;
        else if(load_en)begin
            case (level)
                // 2'b01: shift_reg = {shift_reg[239:0],q3[3:0], q2[3:0], q1[3:0], q0[3:0]};
                // 2'b10: shift_reg = {shift_reg[243:0],q3[2:0], q2[2:0], q1[2:0], q0[2:0]};
                // 2'b11: shift_reg = {shift_reg[247:0],q3[1:0], q2[1:0], q1[1:0], q0[1:0]};
                2'b01: shift_reg = {shift_reg[16:255],q0[0:3], q1[0:3], q2[0:3], q3[0:3]};
                2'b10: shift_reg = {shift_reg[12:255],q0[0:2], q1[0:2], q2[0:2], q3[0:2]};
                2'b11: shift_reg = {shift_reg[8:255],q0[0:1], q1[0:1], q2[0:1], q3[0:1]};
            endcase
        end
    end


    // function [63:0] reverse_word_order;
    // input [63:0] data;
    // begin
    //     reverse_word_order = {data[7:0], data[15:8], data[23:16], data[31:24], data[39:32], data[47:40], data[55:48], data[63:56]};
    // end
    // endfunction

        function [63:0] reverse_bits;
        input [0:63] in_vec;  // 输入向量，in_vec[0] 是最高权重
        integer i;
        begin
        for (i = 0; i < 64; i = i + 1) begin
            reverse_bits[i] = in_vec[i];
        end
        end
    endfunction
  


    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            dout64 <= 64'b0;
        else begin
            case (level)
                2'b11:begin
                    case (bia)
                        // 2'd0: dout64 <= reverse_word_order(shift_reg[127:64]);
                        // 2'd1: dout64 <= reverse_word_order(shift_reg[63:0]);
                        2'd0: dout64 <= reverse_bits(shift_reg[128:191]);
                        2'd1: dout64 <= reverse_bits(shift_reg[192:255]);
                        default: dout64 <= 64'b0;
                    endcase
                end
                2'b10:begin
                    case (bia)
                        2'd0: dout64 <= reverse_bits(shift_reg[64:127]);
                        2'd1: dout64 <= reverse_bits(shift_reg[128:191]);
                        2'd2: dout64 <= reverse_bits(shift_reg[192:255]);
                        default: dout64 <= 64'b0;
                    endcase
                end
                2'b01:begin
                    case (bia)
                        2'd0: dout64 <= reverse_bits(shift_reg[0:63]);
                        2'd1: dout64 <= reverse_bits(shift_reg[64:127]);
                        2'd2: dout64 <= reverse_bits(shift_reg[128:191]);
                        2'd3: dout64 <= reverse_bits(shift_reg[192:255]);
                        default: dout64 <= 64'b0;
                    endcase
                end
            endcase
        end
    end


endmodule