`timescale 1ns / 1ns
`include "../../rtl/include/global_define.v"
`include "../../sim/sim_ram/rom.v"
`include "../../rtl/v2/Frodo.v"

module tb_Frodo;

    // 时钟和复位信号
    reg clk;
    reg rstn;
    
    // Frodo模块输入信号
    reg [1:0] level;
    reg [1:0] mode;
    reg start;
    parameter TIME = 100000;
    
    // 实例化Frodo模块
    Frodo #(
        .TIME(TIME)
    ) u_Frodo (
        .clk(clk),
        .rstn(rstn),
        .level(level),
        .mode(mode),
        .start(start)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz时钟
    end
    
    // 复位生成
    initial begin
        rstn = 0;
        #100 rstn = 1;
    end
    
    // 主测试流程
    initial begin
        // 初始化信号
        level = `FRODO_640;      // FRODO_640
        mode = `KEYGEN;       // 默认模式
        start = 0;
        // 等待复位完成
        wait(rstn);
        #50;
        start = 1;
        repeat(1)@(posedge clk);
        start = 0;
        repeat(TIME)@(posedge clk);
        $finish;
    end
    
    // // 时钟周期计数
    // always @(posedge clk) begin
    //     if (rstn) begin
    //         cycle_count <= cycle_count + 1;
    //     end
    // end
    
    // // 监控关键信号
    // always @(posedge clk) begin
    //     if (rstn && inst_valid) begin
    //         $display("时间: %0t, 指令输入: inst=0x%08h, level=%0d, mode=%0d", 
    //                  $time, inst, level, mode);
    //     end
        
    //     if (rstn && inst_done) begin
    //         $display("时间: %0t, 指令完成信号拉高", $time);
    //     end
    // end
    
    // // 存储器访问监控
    // always @(posedge clk) begin
    //     if (rstn) begin
    //         if (mem0_addr_0 != 0) begin
    //             $display("时间: %0t, mem0_0 读地址: 0x%03h, 数据: 0x%016h", 
    //                      $time, mem0_addr_0, mem0_rd_data_0);
    //         end
    //         if (mem0_addr_1 != 0) begin
    //             $display("时间: %0t, mem0_1 读地址: 0x%03h, 数据: 0x%016h", 
    //                      $time, mem0_addr_1, mem0_rd_data_1);
    //         end
    //         if (mem1_addr_0 != 0) begin
    //             $display("时间: %0t, mem1_0 读地址: 0x%03h, 数据: 0x%016h", 
    //                      $time, mem1_addr_0, mem1_rd_data_0);
    //         end
    //         if (mem1_addr_1 != 0) begin
    //             $display("时间: %0t, mem1_1 读地址: 0x%03h, 数据: 0x%016h", 
    //                      $time, mem1_addr_1, mem1_rd_data_1);
    //         end
    //     end
    // end
    

endmodule
