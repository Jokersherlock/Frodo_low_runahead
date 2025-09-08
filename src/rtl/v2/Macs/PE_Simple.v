module PE_Simple (
    input               clk,
    input               rstn,
    input       [7:0]   a,
    input       [15:0]  b,
    input       [15:0]  c,
    output reg  [15:0]  result,
    output reg          done, 
    input               en,
    input       [1:0]   level
);

    reg state;
    // reg en_prev; // 用于检测en的上升沿

    // always @(posedge clk or negedge rstn) begin
    //     if (!rstn) begin
    //         en_prev <= 1'b0;
    //     end else begin
    //         en_prev <= en;
    //     end
    // end

    // wire en_rise = en && !en_prev; // 检测en的上升沿

    wire [15:0] a_temp;
    assign a_temp = {{8{a[7]}},a};
    wire [15:0] b_temp;

    assign b_temp = (level == `FRODO_640) ? {b[14],b[14:0]} : b;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result <= 16'b0;
            state  <= 1'b0;
            done   <= 1'b0;
        end 
        else begin
            done <= 1'b0;
            if (state) begin
                // 状态1：执行加法操作
                result <= result + c;
                state  <= 1'b0;
                done   <= 1'b1; // 操作完成
            end else if (en) begin
                // 检测到en上升沿，启动乘法
                result <= a_temp * b_temp;
                state  <= 1'b1;
            end
        end
    end    
endmodule