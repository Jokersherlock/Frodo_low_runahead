// `include "add/adder_frodo.v"
// `include "PE_Simple.v"

module Macs (
    input               clk,
    input               rstn,
    input       [7:0]   a_0,
    input       [7:0]   a_1,
    input       [7:0]   a_2,
    input       [7:0]   a_3,
    input       [15:0]  b_0,
    input       [15:0]  b_1,
    input       [15:0]  b_2,
    input       [15:0]  b_3,
    input       [15:0]  c_0,
    input       [15:0]  c_1,
    input       [15:0]  c_2,
    input       [15:0]  c_3,
    output      [63:0]  result,

    input               mode,//0为乘加,1为加法
    input               signal,//0为加,1为减
    input               en,
    output              done,
    input       [1:0]   level
);

    reg [7:0] a_temp_0,a_temp_1,a_temp_2,a_temp_3;

    wire [15:0] d_0,d_1,d_2,d_3;
    assign d_0 = result[15:0];
    assign d_1 = result[31:16];
    assign d_2 = result[47:32];
    assign d_3 = result[63:48];



    always @(*) begin
        if(mode)begin
            if(signal)begin
                a_temp_0 = 8'hff;
                a_temp_1 = 8'hff;
                a_temp_2 = 8'hff;
                a_temp_3 = 8'hff;
            end
            else begin
                a_temp_0 = 8'h1;
                a_temp_1 = 8'h1;
                a_temp_2 = 8'h1;
                a_temp_3 = 8'h1;
            end
        end
        else begin
            if(signal)begin
                a_temp_0 = ~a_0 + 1'b1;
                a_temp_1 = ~a_1 + 1'b1;
                a_temp_2 = ~a_2 + 1'b1;
                a_temp_3 = ~a_3 + 1'b1;
            end
            else begin
                a_temp_0 = a_0;
                a_temp_1 = a_1;
                a_temp_2 = a_2;
                a_temp_3 = a_3;
            end
        end
    end

`ifdef USE_DSP
    // 使用DSP时使用PE_Simple
    PE_Simple u_pe_0(
        .clk(clk),
        .rstn(rstn),
        .a(a_temp_0),
        .b(b_0),
        .c(c_0),
        .result(result[15:0]),
        .done(done),
        .en(en),
        .level(level)
    );

    PE_Simple u_pe_1(
        .clk(clk),
        .rstn(rstn),
        .a(a_temp_1),
        .b(b_1),
        .c(c_1),
        .result(result[31:16]),
        .en(en),
        .level(level)
    );

    PE_Simple u_pe_2(
        .clk(clk),
        .rstn(rstn),
        .a(a_temp_2),
        .b(b_2),
        .c(c_2),
        .result(result[47:32]),
        .en(en),
        .level(level)
    );
    
    PE_Simple u_pe_3(
        .clk(clk),
        .rstn(rstn),
        .a(a_temp_3),
        .b(b_3),
        .c(c_3),
        .result(result[63:48]),
        .en(en),
        .level(level)
    );
`else
    // 不使用DSP时使用ADDER_FRODO
    ADDER_FRODO u_pe_0(
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .in_a(b_0),
        .in_b_(a_temp_0),
        .in_c(c_0),
        .result(result[15:0]),
        .done(done),
        .level(level)
    );
    
    ADDER_FRODO u_pe_1(
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .in_a(b_1),
        .in_b_(a_temp_1),
        .in_c(c_1),
        .result(result[31:16]),
        .level(level)
    );
    
    ADDER_FRODO u_pe_2(
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .in_a(b_2),
        .in_b_(a_temp_2),
        .in_c(c_2),
        .result(result[47:32]),
        .level(level)
    );
    
    ADDER_FRODO u_pe_3(
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .in_a(b_3),
        .in_b_(a_temp_3),
        .in_c(c_3),
        .result(result[63:48]),
        .level(level)
    );
`endif

endmodule