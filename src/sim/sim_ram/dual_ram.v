`timescale 1ns / 1ns

module dual_ram #(
    parameter ADDR_WIDTH = 12,    // 地址位宽
    parameter DATA_WIDTH = 64,    // 数据位宽
    parameter MEM_DEPTH = 4096,   // 存储器深度
    parameter HEX_FILE = "mem0.hex",  // 初始化文件路径
    parameter TIME = 1000,        // 输出存储器数据的时钟周期数
    parameter OUTPUT_FILE = "mem_output.hex"  // 输出文件路径
)(
    input wire clk,               // 时钟信号
    input wire rstn,              // 复位信号（低电平有效）
    
    // 端口A（读/写端口）
    input wire [ADDR_WIDTH-1:0] addr_a,     // 端口A地址输入
    input wire [DATA_WIDTH-1:0] din_a,      // 端口A数据输入
    input wire [7:0] wr_mask_a,             // 端口A写掩码（8位，支持8/16/32/64位写入）
    output reg [DATA_WIDTH-1:0] dout_a,     // 端口A数据输出（带寄存器）
    
    // 端口B（读/写端口）
    input wire [ADDR_WIDTH-1:0] addr_b,     // 端口B地址输入
    input wire [DATA_WIDTH-1:0] din_b,      // 端口B数据输入
    input wire [7:0] wr_mask_b,             // 端口B写掩码（8位，支持8/16/32/64位写入）
    output reg [DATA_WIDTH-1:0] dout_b      // 端口B数据输出（带寄存器）
);

    // 存储器数组
    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    
    // 数据寄存器，用于实现输出寄存器功能
    reg [DATA_WIDTH-1:0] dout_a_reg;
    reg [DATA_WIDTH-1:0] dout_b_reg;
    
    // 时钟计数器，用于跟踪经过的时钟周期数
    reg [31:0] clk_counter;
    reg output_done;  // 标记是否已经输出过数据
    
    // 存储器初始化
    initial begin
        $readmemh(HEX_FILE, mem);
        clk_counter = 0;
        output_done = 0;
    end
    
    // 端口A写操作（同步写，支持mask）
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位时不清空存储器内容，只复位输出寄存器
            clk_counter <= 0;
            output_done <= 0;
        end else begin
            // 时钟计数器递增
            clk_counter <= clk_counter + 1;
            
            // 根据mask进行部分写入（当mask非零时执行写操作）
            if (wr_mask_a != 8'b00000000) begin
                case (wr_mask_a)
                    8'b00000001: mem[addr_a][7:0]   <= din_a[7:0];     // 写8位
                    8'b00000011: mem[addr_a][15:0]  <= din_a[15:0];    // 写16位
                    8'b00001111: mem[addr_a][31:0]  <= din_a[31:0];    // 写32位
                    8'b11111111: mem[addr_a][63:0]  <= din_a[63:0];    // 写64位
                    default: begin
                        // 按位写入
                        if (wr_mask_a[0]) mem[addr_a][7:0]   <= din_a[7:0];
                        if (wr_mask_a[1]) mem[addr_a][15:8]  <= din_a[15:8];
                        if (wr_mask_a[2]) mem[addr_a][23:16] <= din_a[23:16];
                        if (wr_mask_a[3]) mem[addr_a][31:24] <= din_a[31:24];
                        if (wr_mask_a[4]) mem[addr_a][39:32] <= din_a[39:32];
                        if (wr_mask_a[5]) mem[addr_a][47:40] <= din_a[47:40];
                        if (wr_mask_a[6]) mem[addr_a][55:48] <= din_a[55:48];
                        if (wr_mask_a[7]) mem[addr_a][63:56] <= din_a[63:56];
                    end
                endcase
            end
        end
    end
    
    // 端口B写操作（同步写，支持mask）
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位时不做任何操作
        end else begin
            // 根据mask进行部分写入（当mask非零时执行写操作）
            if (wr_mask_b != 8'b00000000) begin
                case (wr_mask_b)
                    8'b00000001: mem[addr_b][7:0]   <= din_b[7:0];     // 写8位
                    8'b00000011: mem[addr_b][15:0]  <= din_b[15:0];    // 写16位
                    8'b00001111: mem[addr_b][31:0]  <= din_b[31:0];    // 写32位
                    8'b11111111: mem[addr_b][63:0]  <= din_b[63:0];    // 写64位
                    default: begin
                        // 按位写入
                        if (wr_mask_b[0]) mem[addr_b][7:0]   <= din_b[7:0];
                        if (wr_mask_b[1]) mem[addr_b][15:8]  <= din_b[15:8];
                        if (wr_mask_b[2]) mem[addr_b][23:16] <= din_b[23:16];
                        if (wr_mask_b[3]) mem[addr_b][31:24] <= din_b[31:24];
                        if (wr_mask_b[4]) mem[addr_b][39:32] <= din_b[39:32];
                        if (wr_mask_b[5]) mem[addr_b][47:40] <= din_b[47:40];
                        if (wr_mask_b[6]) mem[addr_b][55:48] <= din_b[55:48];
                        if (wr_mask_b[7]) mem[addr_b][63:56] <= din_b[63:56];
                    end
                endcase
            end
        end
    end
    
    // 端口A读操作（带输出寄存器）
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_a_reg <= {DATA_WIDTH{1'b0}};
            dout_a <= {DATA_WIDTH{1'b0}};
        end else begin
            // 第一个周期：读取数据到寄存器
            dout_a_reg <= mem[addr_a];
            // 第二个周期：输出数据（基于上一个周期的地址读取的数据）
            dout_a <= dout_a_reg;
        end
    end
    
    // 端口B读操作（带输出寄存器）
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_b_reg <= {DATA_WIDTH{1'b0}};
            dout_b <= {DATA_WIDTH{1'b0}};
        end else begin
            // 第一个周期：读取数据到寄存器
            dout_b_reg <= mem[addr_b];
            // 第二个周期：输出数据（基于上一个周期的地址读取的数据）
            dout_b <= dout_b_reg;
        end
    end
    
    // 存储器数据输出逻辑
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位时不做任何操作
        end else begin
            // 当达到指定时钟周期数且尚未输出时，将存储器数据输出到文件
            if (clk_counter >= TIME && !output_done) begin
                output_done <= 1;
                $writememh(OUTPUT_FILE, mem);
                $display("存储器数据已输出到文件: %s (时钟周期: %d)", OUTPUT_FILE, clk_counter);
            end
        end
    end

endmodule
