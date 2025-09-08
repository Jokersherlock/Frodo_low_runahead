
module Encode (
    input              clk,           
    input              rstn,         
    input              load_en,       // 模式一：载入 64bit 数据
    input              consume_en,    // 模式二：消费并输出 64bit 数据
    input              clr,    
    input       [1:0]  level,          // 11→640(2bit)，10→976(3bit)，01→1344(4bit)
    input       [63:0] data_in,       // 从 RAM 读回的 64bit
    output reg  [63:0] dout64         // 并行输出 4×16bit
);

    parameter SHIFT640 = 8;   // 2*4
    parameter SHIFT976 = 12;  // 3*4
    parameter SHIFT1344= 16;  // 4*4

    reg [255:0] shift_reg;
    reg [1:0] bia;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            bia <= 2'b0;
        else if(clr)
            bia <= 2'b0;
        else if(load_en)
            bia <= bia + 1'b1;
    end


    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            shift_reg <= 256'b0;
        else if (load_en) begin
            case (bia)
                2'd0: shift_reg <= {shift_reg[255:64], data_in};
                2'd1: shift_reg <= {shift_reg[255:128], data_in, shift_reg[63:0]};
                2'd2: shift_reg <= {shift_reg[255:192], data_in, shift_reg[127:0]};
                2'd3: shift_reg <= {data_in, shift_reg[191:0]};
                default: shift_reg <= shift_reg;
            endcase
        end
        else if(consume_en)begin
            case (level)
                2'b11: shift_reg <= shift_reg >> SHIFT640;
                2'b10: shift_reg <= shift_reg >> SHIFT976;
                2'b01: shift_reg <= shift_reg >> SHIFT1344;
            endcase
        end
    end

    reg [15:0] s0,s1,s2,s3;
    always @(*) begin
        case (level)
            // Frodo640: GRP_W = 2
            2'b11: begin
                s0 = {shift_reg[1],shift_reg[ 1: 0],13'b0};
                s1 = {shift_reg[3],shift_reg[ 3: 2],13'b0};
                s2 = {shift_reg[4],shift_reg[ 5: 4],13'b0};
                s3 = {shift_reg[7],shift_reg[ 7: 6],13'b0};
            end
            // Frodo976: GRP_W = 3
            2'b10: begin
                s0 = {shift_reg[ 2: 0],13'b0};
                s1 = {shift_reg[ 5: 3],13'b0};
                s2 = {shift_reg[ 8: 6],13'b0};
                s3 = {shift_reg[11: 9],13'b0};
            end
            // Frodo1344: GRP_W = 4
            2'b01: begin
                s0 = {shift_reg[ 3: 0],12'b0};
                s1 = {shift_reg[ 7: 4],12'b0};
                s2 = {shift_reg[11: 8],12'b0};
                s3 = {shift_reg[15:12],12'b0};
            end
            default: begin
                s0 = 16'b0;
                s1 = 16'b0;
                s2 = 16'b0;
                s3 = 16'b0;
            end
        endcase
    end
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            dout64 <= 64'b0;
        else
            dout64 <= {s3,s2,s1,s0};
    end


endmodule