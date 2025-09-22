// `include "global_define.v"
`timescale 1ns / 1ns
module Frodo #(
    parameter TIME = 1000
)(
    input clk,
    input rstn,
    input [1:0] level,
    input [1:0] mode,
    input start
);
    wire [63:0] mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1;
    wire mem0_wr_en_0,mem0_wr_en_1,mem1_wr_en_0,mem1_wr_en_1;
    wire [11:0] mem0_addr_0,mem0_addr_1,mem1_addr_0,mem1_addr_1;
    wire [10:0] di_len;
    wire [7:0] hash_in;
    wire hash_lev;
    wire di_valid;
    wire squeeze_en;
    wire absorb_en;
    wire ram_reset;
    wire hash_dout_en;
    wire flag15to8;
    wire [15:0] Hash_16out;
    wire [7:0] pc;
    wire [`INST_WIDTH-1:0] inst;
    
    // Bus模块相关信号
    wire [16:0] addr_0, addr_1, addr_2, addr_3;
    wire R0_en, R1_en, R2_en;
    wire [1:0] R3_en;
    wire [63:0] R0_in, R1_in, R2_in, R3_in;
    wire [2:0] R0_mask;
    wire R1_mask;
    wire [7:0] R3_mask;
    wire [31:0] R1_32;
    wire [15:0] R0_16;
    wire [7:0] R0_8;
    wire [11:0] mem0_rd_addr_0, mem0_rd_addr_1, mem1_rd_addr_0, mem1_rd_addr_1;
    wire [11:0] upc_addr;
    wire [11:0] ex_addr;
    wire ex_addr_en;
    wire [63:0] mem_wr_data;
    wire upc_addr_en;
    wire [1:0] level_reg;
    wire [1:0] mode_reg;
    wire [63:0] R2_out;
    
    // AGU相关信号
    wire [16:0] addr_start_0, addr_start_1, addr_start_2, addr_start_3;
    wire [1:0] R0_mode;
    wire [2:0] R3_mode;
    wire R1_mode, R2_mode;
    wire [3:0] addr_clr, addr_add;

    wire keccak_ready;
    wire sample_en;
    wire [7:0] sample_out;
    wire mem_wen;
    wire macs_en;
    wire macs_mode;
    wire macs_signal;
    wire [63:0] macs_result;
    wire load_en;
    wire consume_en;
    wire [15:0] data_encode;
    wire [15:0] data_decode;
    Control u_Control(
        .clk(clk),
        .rstn(rstn),
        .inst(inst),
        .level(level),
        .mode(mode),
        .level_reg(level_reg),
        .mode_reg(mode_reg),
        .start(start),
        .pc(pc),
        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),
        .di_len(di_len),
        .hash_in(hash_in),
        .hash_lev(hash_lev),
        .di_valid(di_valid),
        .squeeze_en(squeeze_en),
        .absorb_en(absorb_en),
        .ram_reset(ram_reset),
        .hash_dout_en(hash_dout_en),
        .flag15to8(flag15to8),
        // Bus模块相关输出
        .R0_en(R0_en),
        .R1_en(R1_en),
        .R2_en(R2_en),
        .R3_en(R3_en),
        .R0_mask(R0_mask),
        .R1_mask(R1_mask),
        .R1_32(R1_32),
        .R0_16(R0_16),
        .R0_8(R0_8),
        .R2_out(R2_out),
        //.R3_mask(R3_mask),
        .upc_addr(upc_addr),
        .upc_addr_en(upc_addr_en),
        .ex_addr(ex_addr),
        .ex_addr_en(ex_addr_en),
        .mem_wr_data(mem_wr_data),
        .R0_in(R0_in),
        .R1_in(R1_in),
        .R2_in(R2_in),
        .keccak_ready(keccak_ready),
        .sample_en(sample_en),
        .sample_out(sample_out),
        .hash_16out(Hash_16out),
        .mem_wen(mem_wen),
        .macs_en(macs_en),
        .macs_mode(macs_mode),
        .macs_signal(macs_signal),
        .macs_result(macs_result),
        .load_en(load_en),
        .consume_en(consume_en),
        .data_encode(data_encode),
        .data_decode(data_decode),
        // AGU相关输出
        .addr_start_0(addr_start_0),
        .addr_start_1(addr_start_1),
        .addr_start_2(addr_start_2),
        .addr_start_3(addr_start_3),
        .R0_mode(R0_mode),
        .R3_mode(R3_mode),
        .R1_mode(R1_mode),
        .R2_mode(R2_mode),
        .addr_clr(addr_clr),
        .addr_add(addr_add),
    );

    // AGU模块实例化
    AGU u_AGU(
        .clk(clk),
        .rstn(rstn),
        .level(level_reg),
        .addr_start_0(addr_start_0),
        .addr_start_1(addr_start_1),
        .addr_start_2(addr_start_2),
        .addr_start_3(addr_start_3),
        .R0_mode(R0_mode),
        .R3_mode(R3_mode),
        .R1_mode(R1_mode),
        .R2_mode(R2_mode),
        .addr_clr(addr_clr),
        .addr_add(addr_add),
        .addr_0(addr_0),
        .addr_1(addr_1),
        .addr_2(addr_2),
        .addr_3(addr_3)
    );


    // wire [1:0] dout_en_cnt;
    // wire [63:0] Hash_64out;
    keccak u_keccak(
        .clk(clk),
        .rst(~rstn),
        .di_len(di_len),
        .Hash_in_(hash_in),
        .Hash_lev(hash_lev),
        .di_valid(di_valid),
        .squeeze_en(squeeze_en),
        .absorb_en(absorb_en),
        .ram_reset(ram_reset),
        .dout_en(hash_dout_en),
        .flag15to8(flag15to8),
        .Hash_16out(Hash_16out),
        .keccak_ready(keccak_ready)
    );


`ifdef USE_IP_CORE
    // 使用IP核模式
    inst_rom u_inst_rom(
        .clka(clk),
        .ena(1'b1),
        .addra(pc),
        .douta(inst)
    );
`else
    // 使用仿真模式
    rom #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(28),
        .MEM_DEPTH(256),
        .HEX_FILE("../../../../../../src/sim/bin/keygen640.bin")
    ) u_inst_rom(
        .clk(clk),
        .addr(pc),
        .dout(inst)
    );
`endif

    Bus u_Bus(
        .clk(clk),
        .rstn(rstn),
        .addr_0(addr_0),
        .addr_1(addr_1),
        .addr_2(addr_2),
        .addr_3(addr_3),
        .R0_en(R0_en),
        .R1_en(R1_en),
        .R2_en(R2_en),
        .R3_en(R3_en),
        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),
        .R0_in(R0_in),
        .R1_in(R1_in),
        .R2_in(R2_in),
        .R0_mask(R0_mask),
        .R1_mask(R1_mask),
        .mem0_addr_0(mem0_rd_addr_0),
        .mem0_addr_1(mem0_rd_addr_1),
        .mem1_addr_0(mem1_rd_addr_0),
        .mem1_addr_1(mem1_rd_addr_1),
        .R3_mask(R3_mask),
        .mem0_wr_en_0(mem0_wr_en_0),
        .mem0_wr_en_1(mem0_wr_en_1),
        .mem1_wr_en_0(mem1_wr_en_0),
        .mem1_wr_en_1(mem1_wr_en_1),
        .upc_addr(upc_addr),
        .upc_addr_en(upc_addr_en),
        .ex_addr(ex_addr),
        .ex_addr_en(ex_addr_en)
    );
    
    wire [7:0] mem0_wen_mask,mem1_wen_mask,mem_uinst_mask;
    assign mem0_wen_mask = {8{mem0_wr_en_0}};
    assign mem1_wen_mask = {8{mem1_wr_en_0}};
    assign mem_uinst_mask = {8{mem_wen}};

`ifdef USE_IP_CORE
    // 使用IP核模式
    mem0 u_mem0(
        .clka(clk),
        .ena(1'b1),
        .wea(R3_mask&mem0_wen_mask&mem_uinst_mask),
        .addra(mem0_rd_addr_0),
        .dina(mem_wr_data),
        .douta(mem0_rd_data_0),
        .clkb(clk),
        .enb(1'b1),
        .addrb(mem0_rd_addr_1),
        .doutb(mem0_rd_data_1),
        .web(8'b0)
    );

    mem1 u_mem1(
        .clka(clk),
        .ena(1'b1),
        .wea(R3_mask&mem1_wen_mask&mem_uinst_mask),
        .addra(mem1_rd_addr_0),
        .dina(mem_wr_data),
        .douta(mem1_rd_data_0),
        .clkb(clk),
        .enb(1'b1),
        .addrb(mem1_rd_addr_1),
        .doutb(mem1_rd_data_1),
        .web(8'b0)
    );
`else
    // 使用仿真模式
    dual_ram #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(64),
        .MEM_DEPTH(4096),
        .HEX_FILE("../../../../../../src/sim/hex/mem0.hex"),
        .TIME(TIME),
        .OUTPUT_FILE("../../../../../../src/sim/hex/mem0_output.hex")
    ) u_mem0_ram(
        .clk(clk),
        .rstn(rstn),
        .addr_a(mem0_rd_addr_0),
        .din_a(mem_wr_data),
        .wr_mask_a(R3_mask & mem0_wen_mask&mem_uinst_mask),
        .dout_a(mem0_rd_data_0),
        .addr_b(mem0_rd_addr_1),
        .din_b(64'b0),
        .wr_mask_b(8'b0),
        .dout_b(mem0_rd_data_1)
    );

    dual_ram #(
        .ADDR_WIDTH(12),
        .DATA_WIDTH(64),
        .MEM_DEPTH(2048),
        .HEX_FILE("../../../../../../src/sim/hex/mem1.hex"),
        .TIME(TIME),
        .OUTPUT_FILE("../../../../../../src/sim/hex/mem1_output.hex")
    ) u_mem1_ram(
        .clk(clk),
        .rstn(rstn),
        .addr_a(mem1_rd_addr_0),
        .din_a(mem_wr_data),
        .wr_mask_a(R3_mask & mem1_wen_mask&mem_uinst_mask),
        .dout_a(mem1_rd_data_0),
        .addr_b(mem1_rd_addr_1),
        .din_b(64'b0),
        .wr_mask_b(8'b0),
        .dout_b(mem1_rd_data_1)
    );
`endif

    sample u_sample(
        .clk(clk),
        .rst_n(rstn),
        .en(sample_en),
        .level(level_reg),
        .random_string(Hash_16out),
        .sample_out(sample_out)
    );


    Macs u_Macs(
        .clk(clk),
        .rstn(rstn),
        .a_0(R1_32[7:0]),
        .a_1(R1_32[15:8]),
        .a_2(R1_32[23:16]),
        .a_3(R1_32[31:24]),
        .b_0(R0_16),
        .b_1(R0_16),
        .b_2(R0_16),
        .b_3(R0_16),
        .c_0(R2_out[15:0]),
        .c_1(R2_out[31:16]),
        .c_2(R2_out[47:32]),
        .c_3(R2_out[63:48]),
        .mode(mode_reg),
        .signal(macs_signal),
        .en(macs_en),
        .result(macs_result),
        .level(level_reg)
    );

    Encode u_Encode(
        .clk(clk),
        .rstn(rstn),
        .load_en(load_en),
        .consume_en(consume_en),
        .data_in(R0_16),
        .dout16(data_encode)
    );


    Decode u_Decode(
        .clk(clk),
        .rstn(rstn),
        .load_en(load_en),
        .consume_en(consume_en),
        .data_in(R0_16),
        .dout16(data_decode)
    );

endmodule