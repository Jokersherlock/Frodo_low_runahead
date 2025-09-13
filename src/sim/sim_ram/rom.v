`timescale 1ns / 1ns

module rom #(
    parameter ADDR_WIDTH = 12,    // 地址位宽
    parameter DATA_WIDTH = 64,    // 数据位宽
    parameter MEM_DEPTH = 4096,   // 存储器深度
    parameter HEX_FILE = "mem0.hex"  // 初始化文件路径
)(
    input wire clk,               // 时钟信号
    input wire rstn,             // 复位信号（低电平有效）
    input wire [ADDR_WIDTH-1:0] addr,  // 地址输入
    output reg [DATA_WIDTH-1:0] dout   // 数据输出（带寄存器）
);

    // 存储器数组
    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // 数据寄存器，用于实现输出寄存器功能
    reg [DATA_WIDTH-1:0] dout_reg;
    
    // 存储器初始化
    initial begin
        $readmemb(HEX_FILE, mem);
    end

    // 同步逻辑：在时钟上升沿读取数据并打拍输出
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_reg <= {DATA_WIDTH{1'b0}};
            dout <= {DATA_WIDTH{1'b0}};
        end else begin
            // 第一个周期：读取数据到输出寄存器
            dout_reg <= mem[addr];
            dout <= dout_reg;
        end
    end

endmodule
