//`include "Frodo_defines.v"
module AGU (
    input clk,
    input           rstn,
    input [16:0]    addr_start_0,addr_start_1,addr_start_2,addr_start_3,
    input [1:0]     R0_mode,
    input [2:0]     R3_mode,
    input           R1_mode,
    input  [3:0]    addr_clr,
    input  [3:0]    addr_add,
    input           addr1_carry,//addr2是否进位
    output reg  [16:0]  addr_0,addr_1,addr_2,addr_3
);

// addr_0
    reg [10:0] loop;
    always @(*) begin
        case (R0_mode)
            `FRODO_1344: loop = 11'd1343;
            `FRODO_976: loop = 11'd975;
            `FRODO_640: loop = 11'd639;
            default: loop = 11'd0;
        endcase
    end
    
    localparam NORMAL64 = 2'b00;//64位对齐+1
    localparam NORMAL16 = 2'b01;//16位对齐+1
    localparam NORMAL8  = 2'b10;//8位对齐+1
    localparam READBP   = 2'b11;//读B'
    // localparam GENS     = 3'b011;//生成S,S'
    // localparam GENEP    = 3'b100;//生成E'
    
    reg [10:0] R0_cnt;//R0计数器

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_0 <= 16'b0;
            R0_cnt <= 11'b0;
        end
        else if(addr_clr[0])begin
            addr_0 <= addr_start_0;
            R0_cnt <= 11'b0;
        end
        else if(addr_add[0])begin
            case (R0_mode)
                NORMAL64: begin
                    addr_0[16:3] <= addr_0[16:3] + 1'b1;
                end
                NORMAL16: begin
                    addr_0[16:1] <= addr_0[16:1] + 1'b1;
                end
                NORMAL8: begin
                    addr_0 <= addr_0 + 1'b1;
                end
                // GENS: begin
                //     if(addr_0[14:3] == loop)begin//地址满n时。低位地址加1
                //         addr_0[14:3] <= addr_start_0[14:3];
                //         addr_0[2:0]  <= addr_0[2:0] + 1'b1;
                //     end
                //     else begin
                //         addr_0[14:3] <= addr_0[14:3] + 1'b1;
                //     end
                // end
                READBP: begin
                    if(R0_cnt == loop)begin//地址满n时。低位地址加1,等效于128位对齐
                        //addr_0[14:3] <= addr_start_0[14:3];
                        addr_0[3:0]  <= addr_0[3:0] + 1'b1;
                        addr_0[14:4] <= addr_start_0[14:4];
                        R0_cnt <= 11'b0;
                    end
                    else begin
                        addr_0[14:4] <= addr_0[14:4] + 1'b1;
                        R0_cnt <= R0_cnt + 1'b1;
                    end
                end
                default: begin
                    addr_0 <= addr_0 + 1'b1;
                end
            endcase
        end
    end
    

// addr_1    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_1 <= 16'b0;
        end
        else if(addr_clr[1])begin
            addr_1 <= addr_start_1;
        end
        else if(addr1_carry)begin
            addr_1[16:3] <= addr_1[16:3] + 1'b1;
        end
        else if(addr_add[1])begin
            case (R1_mode)
                1'b0: begin
                    addr_1[16:3] <= addr_1[16:3] + 1'b1;
                end
                1'b1:begin
                    addr_1[2] <= ~addr_1[2];
                end
            endcase
        end
    end

// addr_2
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_2 <= 16'b0;
        end
        else if(addr_clr[2])begin
            addr_2 <= addr_start_2;
        end
        else if(addr_add[2])begin
            addr_2[16:3] <= addr_2[16:3] + 1'b1;
        end
    end

// addr_3
    localparam WRITE64 = 3'b000;//64位对齐+1
    localparam WRITE16 = 3'b001;//16位对齐+1
    localparam WRITE8  = 3'b010;//8位对齐+1
    localparam GENS    = 3'b011;//生成S,S'
    localparam GENEP   = 3'b100;//生成E'
    localparam MATRAN  = 3'b101;//矩阵转置
    reg [10:0] R3_cnt;//R3计数器
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_3 <= 16'b0;
            R3_cnt <= 11'b0;
        end
        else if(addr_add[3])begin
            case (R3_mode)
                WRITE64: begin
                    addr_3[16:3] <= addr_3[16:3] + 1'b1;
                end
                WRITE16: begin
                    addr_3[16:1] <= addr_3[16:1] + 1'b1;
                end
                WRITE8: begin
                    addr_3 <= addr_3 + 1'b1;
                end
                GENS: begin
                    if(addr_3[14:3] == loop)begin//地址满n时。低位地址加1
                        addr_3[14:3] <= addr_start_3[14:3];
                        addr_3[2:0]  <= addr_3[2:0] + 1'b1;
                    end
                    else begin
                        addr_3[14:3] <= addr_3[14:3] + 1'b1;
                    end
                end
                GENEP: begin
                    if(R3_cnt == loop)begin//地址满2*n时。低位地址加1,等效于128位对齐
                        //addr_3[14:3] <= addr_start_3[14:3];
                        addr_3[3:0]  <= addr_3[3:0] + 1'b1;
                        addr_3[14:4] <= addr_start_3[14:4];
                        R3_cnt <= 11'b0;
                    end
                    else begin
                        addr_3[14:4] <= addr_3[14:4] + 1'b1;
                        R3_cnt <= R3_cnt + 1'b1;
                    end
                end
                MATRAN: begin
                    if(R3_cnt == 11'd8)begin//一行8个全部读完
                        addr_3[3:1] <= addr_3[3:1] + 1'b1;
                        addr_3[16:4] <= addr_start_3[16:4];
                        R3_cnt <= 11'b0;
                    end
                    else begin//128位对齐实现行跳转
                        addr_3[16:4] <= addr_3[16:4] + 1'b1;
                        R3_cnt <= R3_cnt + 1'b1;
                    end
                end
                default: begin
                    addr_3 <= addr_3 + 1'b1;
                end
            endcase
        end
    end

endmodule