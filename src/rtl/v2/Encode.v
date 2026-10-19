//`include "global_define.v"
module Encode (
    input              clk,           
    input              rstn,         
    input              load_en,       // 模式一：载入 16bit 数据
    input              consume_en,    // 模式二：消费并输出 16bit 数据
    input              clr,    
    input       [1:0]  level,          // 11→640(2bit)，10→976(3bit)，01→1344(4bit)
    input       [15:0] data_in,       // 从 RAM 读回的 16bit
    output reg  [15:0] dout16         // 并行输出 16bit
);

    localparam SHIFT640 = 2;   // 2
    localparam SHIFT976 = 3;  // 3
    localparam SHIFT1344= 4;  // 4

    (* keep = "true" *) reg [63:0] shift_reg;
    reg [1:0] bia;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            bia <= 2'b0;
        else if(clr)
            bia <= 2'b0;
        else if(load_en)begin
            case (level)
                `FRODO_1344:begin
                    bia <= bia + 1'b1;
                end
                `FRODO_976 :begin
                    if(bia == 2'd2)
                        bia <= 2'd0;
                    else
                        bia <= bia + 1'b1;
                end
                `FRODO_640 :begin
                    if(bia == 2'd1)
                        bia <= 2'd0;
                    else
                        bia <= bia + 1'b1;
                end
                default: bia <= bia;
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            shift_reg <= 64'b0;
        //载入使能时,将输入的16bit数据嵌入到对应位置
        else if (load_en) begin
            case (bia)
                2'd0: shift_reg <= {shift_reg[63:16], data_in};
                2'd1: shift_reg <= {shift_reg[63:32], data_in, shift_reg[15:0]};
                2'd2: shift_reg <= {shift_reg[63:48], data_in, shift_reg[31:0]};
                2'd3: shift_reg <= {data_in, shift_reg[47:0]};
                default: shift_reg <= shift_reg;
            endcase
        end
        //输出使能时,1344,976,640分别右移4,3,2位
        else if(consume_en)begin
            case (level)
                `FRODO_640: shift_reg <= shift_reg >> SHIFT640;
                `FRODO_976: shift_reg <= shift_reg >> SHIFT976;
                `FRODO_1344: shift_reg <= shift_reg >> SHIFT1344;
            endcase
        end
    end

    reg [15:0] s0;
    always @(*) begin
        case (level)
            // Frodo640: GRP_W = 2
            `FRODO_640: begin
                s0 = {shift_reg[1],shift_reg[1: 0],13'b0};
            end
            // Frodo976: GRP_W = 3
            `FRODO_976: begin
                s0 = {shift_reg[ 2: 0],13'b0};
            end
            // Frodo1344: GRP_W = 4
            `FRODO_1344: begin
                s0 = {shift_reg[ 3: 0],12'b0};
            end
            default: begin
                s0 = 16'b0;
            end
        endcase
    end
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            dout16 <= 16'b0;
        else
            dout16 <= s0;
    end

endmodule
