`timescale 1ns/1ps

module tb_Top;
    parameter TIME = 0;

    reg sys_clk_p;
    reg sys_clk_n;
    reg rstn;
    reg switch;
    wire valid;
    // wire [63:0] output_data; // 如果需要输出数据可解开

    // 差分时钟生成
    initial begin
        sys_clk_p = 0;
        sys_clk_n = 1;
        forever begin
            #2.5 sys_clk_p = ~sys_clk_p;
            sys_clk_n = ~sys_clk_p;
        end
    end

    // 复位信号
    initial begin
        rstn = 0;
        #20;
        rstn = 1;
    end

    // 实例化Top模块
    Top #(
        .TIME(TIME)
    ) u_Top (
        .sys_clk_p(sys_clk_p),
        .sys_clk_n(sys_clk_n),
        .rstn(rstn),
        .valid(valid),
        .switch(switch)
        // .output_data(output_data) // 如需输出数据可解开
    );

    // 仿真结束
    initial begin
        switch = 1'b1;
        //repeat(2)@(posedge sys_clk_p);
        #20
        //keygen-640
        switch = 1'b0;
        //repeat(5)@(posedge sys_clk_p);
        #40
        switch = 1'b1; 
        //repeat(300000)@(posedge sys_clk_p);
        #26800
        // switch = 1'b0;
        // #40
        // switch = 1'b1;
        // #284000000
        // switch = 1'b0;
        // #40
        // switch = 1'b1;
        // #284000000
        $finish;
        // //encap-640
        // switch = 1'b0;
        // repeat(5)@(posedge sys_clk_p);
        // switch = 1'b1; 
        // repeat(8200000)@(posedge sys_clk_p);

        // //decap-640
        // switch = 1'b0;
        // repeat(5)@(posedge sys_clk_p);
        // switch = 1'b1; 
        // repeat(8200000)@(posedge sys_clk_p);
        //$finish;
    end

    // 可添加更多激励和监控
    // initial begin
    //     wait(valid);
    //     $display("valid拉高，仿真检测点");
    // end

endmodule