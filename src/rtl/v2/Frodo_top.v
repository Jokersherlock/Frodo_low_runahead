`include "../include/global_define.v"
`timescale 1ns / 1ns

module Frodo_top(
    input clk,
    input rstn,
    input switch,           // 外部按钮输入
    output [1:0] level,      // 当前算法等级
    output [1:0] mode,      // 当前算法模式
    output start,           // 启动信号
    output valid             // 算法完成信号
);

    // 状态机定义
    localparam IDLE = 2'b00;      // 空闲状态
    localparam EXECUTING = 2'b01;  // 执行状态
    localparam SWITCHING = 2'b10;  // 切换状态
    
    // 算法执行顺序定义
    localparam TOTAL_ALGORITHMS = 9; // 总共9个算法：3个等级 × 3个模式
    
    // 当前算法索引
    reg [3:0] current_algorithm;
    
    // 状态机寄存器
    reg [1:0] state, state_next;
    
    // 按钮边沿检测
    reg switch_reg;
    wire switch_pos;
    
    // 输出寄存器
    reg [1:0] level_reg, mode_reg;
    reg start_reg;
    
    // 按钮边沿检测
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            switch_reg <= 1'b0;
        end else begin
            switch_reg <= switch;
        end
    end
    
    assign switch_pos = switch & ~switch_reg;
    
    // 状态机时序逻辑
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end
    
    // 状态机组合逻辑
    always @(*) begin
        state_next = state;
        case (state)
            IDLE: begin
                if (switch_pos) begin
                    state_next = EXECUTING;
                end
            end
            EXECUTING: begin
                if (valid) begin
                    state_next = SWITCHING;
                end
            end
            SWITCHING: begin
                state_next = IDLE;
            end
            default: begin
                state_next = IDLE;
            end
        endcase
    end
    
    // 算法索引更新逻辑
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_algorithm <= 4'b0;
        end else if (state == SWITCHING) begin
            if (current_algorithm == TOTAL_ALGORITHMS - 1) begin
                current_algorithm <= 4'b0; // 循环回到第一个算法
            end else begin
                current_algorithm <= current_algorithm + 1'b1;
            end
        end
    end
    
    // 算法配置逻辑 - 根据current_algorithm选择level和mode
    always @(*) begin
        case (current_algorithm)
            4'd0: begin // 640 keygen
                level_reg = `FRODO_640;
                mode_reg = `KEYGEN;
            end
            4'd1: begin // 640 encap
                level_reg = `FRODO_640;
                mode_reg = `ENCAP;
            end
            4'd2: begin // 640 decap
                level_reg = `FRODO_640;
                mode_reg = `DECAP;
            end
            4'd3: begin // 976 keygen
                level_reg = `FRODO_976;
                mode_reg = `KEYGEN;
            end
            4'd4: begin // 976 encap
                level_reg = `FRODO_976;
                mode_reg = `ENCAP;
            end
            4'd5: begin // 976 decap
                level_reg = `FRODO_976;
                mode_reg = `DECAP;
            end
            4'd6: begin // 1344 keygen
                level_reg = `FRODO_1344;
                mode_reg = `KEYGEN;
            end
            4'd7: begin // 1344 encap
                level_reg = `FRODO_1344;
                mode_reg = `ENCAP;
            end
            4'd8: begin // 1344 decap
                level_reg = `FRODO_1344;
                mode_reg = `DECAP;
            end
            default: begin
                level_reg = `FRODO_640;
                mode_reg = `KEYGEN;
            end
        endcase
    end
    
    // start信号控制逻辑
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            start_reg <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    start_reg <= 1'b0;
                end
                EXECUTING: begin
                    start_reg <= 1'b1;
                end
                SWITCHING: begin
                    start_reg <= 1'b0;
                end
                default: begin
                    start_reg <= 1'b0;
                end
            endcase
        end
    end
    
    // 输出端口连接
    assign level = level_reg;
    assign mode = mode_reg;
    assign start = start_reg;
    
    // Frodo模块实例化
    Frodo #(
        .TIME(1000)
    ) u_Frodo (
        .clk(clk),
        .rstn(rstn),
        .level(level),
        .mode(mode),
        .start(start),
        .valid(valid)
    );

endmodule