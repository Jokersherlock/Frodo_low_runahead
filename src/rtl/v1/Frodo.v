module Frodo #(
    parameter INST_WIDTH = 28,
    parameter ADDR_WIDTH = 12
)(
    input                   clk,
    input                   rstn,
    input  [1:0]            level,
    input  [1:0]            mode,
    input                   start,
    input  [63:0] mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1,
    output [ADDR_WIDTH-1:0] mem0_addr_0,mem0_addr_1,mem1_addr_0,mem1_addr_1,
    output  mem0_wr_en_0,mem0_wr_en_1,mem1_wr_en_0,mem1_wr_en_1,
    output                  valid,
    output [63:0]           mem_wr_data
);
    wire trans_en;
    wire [10:0] di_len;
    wire [7:0] Hash_in_;
    wire Hash_lev,di_valid,squeeze_en,ram_reset,dout_en;
    wire absorb;
    wire sample_en;
    wire [15:0] sample_data;
    wire [7:0] sample_out;
    wire [1:0] level_reg;
    wire inst_valid;
    wire [INST_WIDTH-1:0] inst;
    wire inst_done;
    wire [7:0] pc;
    wire [31:0] short_data;
    wire [63:0] long_data,add_data;

    wire [63:0] macs_result;
    wire [63:0] data_encode,data_decode;
    wire [63:0] Hash_64out;
    wire macs_mode,macs_signal,macs_en;
    wire absorb_en;
    wire flag15to8;
    wire mem_wen;

    Core u_core(
        .clk(clk),
        .rstn(rstn),
        .level(level),
        .mode(mode),
        .start(start),
        .inst_done(inst_done),
        .valid(valid),
        .inst_valid(inst_valid),
        .level_reg(level_reg),
        .pc(pc)
    );

    // sync_rom #(
    //     .ADDR_WIDTH(8),
    //     .DATA_WIDTH(32),
    //     .DEPTH(256),
    //     .INIT_FILE("../../../../../../rtl/coe/inst/inst.bin") 
    // ) u_inst_rom(
    //     .clk(clk),
    //     .rstn(rstn),
    //     .en(1'b1),
    //     .addr(pc),
    //     .dout(inst)
    // );    

    rom u_rom(
        .addra(pc),
        .clka(clk),
        .douta(inst)
    //    .ena(1'b1)
    );


    Control u_control(
        .clk(clk),
        .rstn(rstn),
        .inst(inst),
        .inst_valid(inst_valid),
        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),
        .mem0_addr_0(mem0_addr_0),
        .mem0_addr_1(mem0_addr_1),
        .mem1_addr_0(mem1_addr_0),
        .mem1_addr_1(mem1_addr_1),
        .mem0_wr_en_0(mem0_wr_en_0),
        .mem0_wr_en_1(mem0_wr_en_1),
        .mem1_wr_en_0(mem1_wr_en_0),
        .mem1_wr_en_1(mem1_wr_en_1),
        .mem_wr_data(mem_wr_data),
        
        .short_data(short_data),
        .long_data(long_data),
        .add_data(add_data),

        .macs_result(macs_result),
        .macs_mode(macs_mode),
        .macs_signal(macs_signal),
        .macs_en(macs_en),
        
        .data_encode(data_encode),
        .trans_en(trans_en),
        .data_decode(data_decode),

        .hash_di_len(di_len),
        .hash_in(Hash_in_),
        .hash_lev(Hash_lev),
        .hash_di_valid(di_valid),
        .squeeze_en(squeeze_en),
        .ram_reset(ram_reset),
        .dout_en(dout_en),
        .hash_out(Hash_64out),
        .absorb_en(absorb_en),
        .flag15to8(flag15to8),

        .sample_data(sample_out),
        .hash_cut(sample_data),
        .sample_en(sample_en),

        .level(level_reg),
        .finish(inst_done),
        .mem_wen(mem_wen)
    );

    // Encode u_encode(
    //     .input_data(long_data),
    //     .output_data(data_encode),
    //     .en(trans_en),
    //     .level(level_reg)
    // );

    Encode u_encode(
        .clk(clk),
        .rstn(rstn),
        .load_en(trans_en),
        .consume_en(mem_wen),
        .clr(inst_done),
        .level(level_reg),
        .data_in(long_data),
        .dout64(data_encode)
    );


    Decode u_decode(
        .clk(clk),
        .rstn(rstn),
        .load_en(trans_en),
        .consume_en(mem_wen),
        .clr(inst_done),
        .level(level_reg),
        .din64(long_data),
        .dout64(data_decode)
    );

    Macs  u_Macs (
    .clk                     ( clk      ),
    .rstn                    ( rstn     ),
    .a_0                     ( short_data[7:0]),
    .a_1                     ( short_data[15:8] ),
    .a_2                     ( short_data[23:16] ),
    .a_3                     ( short_data[31:24] ),
    .b_0                     ( long_data[15:0]),
    .b_1                     ( long_data[31:16]),
    .b_2                     ( long_data[47:32]),
    .b_3                     ( long_data[63:48]),
    .c_0                     ( add_data[15:0]),
    .c_1                     ( add_data[31:16]),
    .c_2                     ( add_data[47:32]),
    .c_3                     ( add_data[63:48]),
    .mode                    ( macs_mode     ),
    .signal                  ( macs_signal   ),
    .en                      ( macs_en       ),

    .result                  ( macs_result),
    .level                   (level_reg)
);

    keccak u_keccak(
        .clk(clk),
        .rst(~rstn),
        .di_len(di_len),
        .Hash_in_(Hash_in_),
        .Hash_lev(Hash_lev),
        .di_valid(di_valid),
        .squeeze_en(squeeze_en),
        .ram_reset(ram_reset),
        .dout_en(dout_en),
        .Hash_64out(Hash_64out),
        .absorb_en(absorb_en),
        .flag15to8(flag15to8)
    );

    sample u_sample(
        .clk(clk),
        .rst_n(rstn),
        .en(sample_en),
        .level(level_reg),
        .random_string(sample_data),
        .sample_out(sample_out)
    );


endmodule