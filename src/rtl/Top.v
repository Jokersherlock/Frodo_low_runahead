module Top #(
    parameter TIME = 0
)(
    input sys_clk_p,
    input sys_clk_n,
    input rstn,
    //output [63:0] output_data,
    output        valid,
    input         switch
);
    wire frodo_clk;
    // driver与Frodo_top之间的信号
    wire start, finish;
    wire [2:0] driver_state;
    wire [11:0] load_addr, read_addr;
    wire [63:0] driver_rom_data;
    wire [13:0] driver_rom_load_addr, driver_rom_read_addr;
    wire [3:0] mode_reg;
    wire [63:0] output_data;



    // 状态定义
    parameter  IDLE     = 3'b000;
    parameter  SWITCH   = 3'b001;
    parameter  FINISH   = 3'b010;
    parameter  LOAD     = 3'b100;
    parameter  START    = 3'b101;
    parameter  EX       = 3'b110;
    parameter  VERIFY   = 3'b111;


    reg [2:0] driver_state_reg,driver_state_reg_;
    always @(posedge frodo_clk or negedge rstn) begin
        if(!rstn)
            driver_state_reg <= 3'b0;
        else
            driver_state_reg <= driver_state;
    end


    assign valid = finish;

    parameter FRODO_1344 = 2'b01;
    parameter FRODO_976  = 2'b10;
    parameter FRODO_640  = 2'b11;
    parameter KEYGEN     = 2'b00;
    parameter ENCAP      = 2'b01;
    parameter DECAP      = 2'b10;


    reg [1:0] safe_level,frodo_mode;

    always @(*) begin
        case (mode_reg)
            4'd0:begin
                safe_level = FRODO_640;
                frodo_mode = KEYGEN;
            end
            4'd1:begin
                safe_level = FRODO_640;
                frodo_mode = ENCAP;
            end
            4'd2:begin
                safe_level = FRODO_640;
                frodo_mode = DECAP;
            end
            4'd3:begin
                safe_level = FRODO_976;
                frodo_mode = KEYGEN;
            end
            4'd4:begin
                safe_level = FRODO_976;
                frodo_mode = ENCAP;
            end
            4'd5:begin
                safe_level = FRODO_976;
                frodo_mode = DECAP;
            end
            4'd6:begin
                safe_level = FRODO_1344;
                frodo_mode = KEYGEN;
            end
            4'd7:begin
                safe_level = FRODO_1344;
                frodo_mode = ENCAP;
            end
            4'd8:begin
                safe_level = FRODO_1344;
                frodo_mode = DECAP;
            end
            default: begin
                safe_level = 2'b00;
                frodo_mode = 2'b00;
            end  
        endcase
    end


    // driver实例
    driver u_driver (
        .clk(frodo_clk),
        .rstn(rstn),
        .finish(finish),
        .start(start),
        .state(driver_state),
        .load_addr(load_addr),
        .read_addr(read_addr),
        .mode_reg(mode_reg),
        .switch(~switch)
    );

    // driver_rom实例
    driver_rom u_driver_rom (
        .clk(frodo_clk),
        .rstn(rstn),
        .load_addr(load_addr),
        .read_addr(read_addr),
        .data_dout(driver_rom_data),
        .load_addr_dout(driver_rom_load_addr),
        .read_addr_dout(driver_rom_read_addr)
    );

    wire load_en,read_en;
    assign load_en = driver_state_reg == LOAD;
    assign read_en = driver_state_reg == VERIFY;

    // Frodo_top实例
    Frodo_top u_Frodo_top (
        .clk(frodo_clk),
        .rstn(rstn),
        .level(safe_level),
        .mode(frodo_mode),
        .start(start),
        .valid(finish), // 可外接
        .load_addr(driver_rom_load_addr),
        .load_data(driver_rom_data),
        .read_addr(driver_rom_read_addr),
        .load_en(load_en),
        .read_en(read_en),
        .output_data(output_data)
    );
    // RAM实例化
    // dual_port_ram #(
    //     .LOAD_FILE_PATH("../../../../../../sim/RAM/final/mem0_Bprime_976.hex"),
    //     .STORE_PATH("../../../../../../sim/mem0_result.hex"),
    //     .TIME(TIME)
    // ) u_ram_0 (
    //     .clk(frodo_clk),
    //     .rstn(rstn),
    //     .port_a_en(mem0_wr_en_0),
    //     .addr_a(mem0_addr_0),
    //     .din_a(mem_wr_data),
    //     .dout_a(mem0_rd_data_0),
    //     .port_b_en(mem0_wr_en_1),
    //     .addr_b(mem0_addr_1),
    //     .din_b(mem_wr_data),
    //     .dout_b(mem0_rd_data_1)
    // );


    // dual_port_ram #(
    //     .LOAD_FILE_PATH("../../../../../../sim/RAM/final/mem1_Bprime_976.hex"),
    //     .STORE_PATH("../../../../../../sim/mem1_result.hex"),
    //     .TIME(TIME)
    // ) u_ram_1 (
    //     .clk(frodo_clk),
    //     .rstn(rstn),
    //     .port_a_en(mem1_wr_en_0),
    //     .addr_a(mem1_addr_0),
    //     .din_a(mem_wr_data),
    //     .dout_a(mem1_rd_data_0),
    //     .port_b_en(mem1_wr_en_1),
    //     .addr_b(mem1_addr_1),
    //     .din_b(mem_wr_data),
    //     .dout_b(mem1_rd_data_1)
    // );

    ila_0 u_ila_0(
        .clk(frodo_clk),
        .probe0(valid),
        .probe1(output_data),
        .probe2(driver_rom_read_addr),
        .probe3(start),
        .probe4(safe_level),
        .probe5(frodo_mode)
    );

    wire locked;

    clk_wiz_0 pll(
        .clk_out1(frodo_clk),
        .reset(~rstn),
        .locked(locked),
        .clk_in1_p(sys_clk_p),
        .clk_in1_n(sys_clk_n)
    );



endmodule
