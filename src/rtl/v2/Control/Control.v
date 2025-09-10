`include "global_define.v"
module Control(
    input clk,
    input rstn,

    input      [`INST_WIDTH-1:0]            inst,
    input                                   inst_valid,

    input      [63:0]                       mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1,
    output     [11:0]                       mem0_rd_addr_0,mem0_rd_addr_1,mem1_rd_addr_0,mem1_rd_addr_1,
    output                                  mem0_wr_en_0,mem0_wr_en_1,mem1_wr_en_0,mem1_wr_en_1

);


    wire [11:0] loop_0;
    wire [7:0] loop_1;
    wire [7:0] loop_2;
    wire [7:0] loop_3;
    wire [`UINST_ADDR_WIDTH-1:0] upc_start;
    wire flag15to8;
    wire [2:0] lut_flag;
    wire [16:0] addr_start_0,addr_start_1,addr_start_2,addr_start_3;
    wire [1:0] R0_mode;
    wire [2:0] R3_mode;
    wire R1_mode;
    wire R2_mode;
    wire [2:0] R0_mask;
    wire R1_mask;
    wire R0_inverse;
    wire macs_mode;
    wire macs_signal;
    wire [10:0] di_len;
    wire Hash_lev;
    wire R0_en,R1_en,R2_en;
    wire [1:0] R3_en;
    wire [63:0] R0_in,R1_in,R2_in,R3_in;

    wire [`UINST_ADDR_WIDTH-1:0] upc;

    wire [63:0] R0_out,R1_out,R2_out,R3_out;
    wire [32:0] R1_32;
    wire [15:0] R0_16;
    wire [7:0] R0_8;
    wire [`UINST_WIDTH-1:0] uinst;

    wire [16:0] addr_0,addr_1,addr_2,addr_3;




    wire done;
    assign done = uinst[0];
    
    wire [2:0] upc_st,upc_up;
    assign upc_st = uinst[3:1];
    assign upc_up = uinst[6:4];
    
    wire [3:0] addr_clr;
    wire [3:0] addr_add;
    wire [2:0] addr_carry;
    assign addr_clr = uinst[10:7];
    assign addr_add = uinst[14:11];
    assign addr_carry = uinst[17:15];
    
    wire macs_en;
    assign macs_en = uinst[18];
    
    wire di_valid,ex_en,ram_reset,dout_en;
    assign di_valid = uinst[19];
    assign ex_en = uinst[20];
    assign ram_reset = uinst[21];
    assign dout_en = uinst[22];
    
    wire stall;
    assign stall = uinst[23];


    InstDecoder u_InstDecoder(
        .clk(clk),
        .rstn(rstn),
        .inst(inst),
        .inst_valid(inst_valid),
        .loop_0(loop_0),
        .loop_1(loop_1),
        .loop_2(loop_2),
        .loop_3(loop_3),
        .upc_start(upc_start),
        .flag15to8(flag15to8),
        .lut_flag(lut_flag),
        .addr_start_0(addr_start_0),
        .addr_start_1(addr_start_1),
        .addr_start_2(addr_start_2),
        .addr_start_3(addr_start_3),
        .R0_mode(R0_mode),
        .R3_mode(R3_mode),
        .R1_mode(R1_mode),
        .R2_mode(R2_mode),
        .R0_mask(R0_mask),
        .R1_mask(R1_mask),
        .R0_inverse(R0_inverse),
        .macs_mode(macs_mode),
        .macs_signal(macs_signal),
        .done(done),
        .di_len(di_len),
        .Hash_lev(Hash_lev),
        .R0_en(R0_en),
        .R1_en(R1_en),
        .R2_en(R2_en),
        .R3_en(R3_en)
    );




    uControl u_uControl(
        .clk(clk),
        .rstn(rstn),
        .loop_0(loop_0),
        .loop_1(loop_1),
        .loop_2(loop_2),
        .loop_3(loop_3),
        .upc_start(upc_start),
        .upc(upc),
        .stall(stall),
        .upc_up(upc_up),
        .upc_st(upc_st),
        .flag15to8(flag15to8),
        .lut_flag(lut_flag)
    );

    
  
    Register u_Register(
        .clk(clk),
        .rstn(rstn),
        .R0_in(R0_in),
        .R1_in(R1_in),
        .R2_in(R2_in),
        .R3_in(R3_in),
        .R0_mask(R0_mask),
        .R1_mask(R1_mask),
        .R0_inverse(R0_inverse),
        .R0_out(R0_out),
        .R1_out(R1_out),
        .R2_out(R2_out),
        .R3_out(R3_out),
        .R1_32(R1_32),
        .R0_16(R0_16),
        .R0_8(R0_8)
    );

    AGU u_AGU(
        .clk(clk),
        .rstn(rstn),
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
        .addr_carry(addr_carry),
        .addr_0(addr_0),
        .addr_1(addr_1),
        .addr_2(addr_2),
        .addr_3(addr_3)
    );

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
        .R3_in(R3_in),
        .R0_mask(R0_mask),
        .R1_mask(R1_mask),
        .mem0_rd_addr_0(mem0_rd_addr_0),
        .mem0_rd_addr_1(mem0_rd_addr_1),
        .mem1_rd_addr_0(mem1_rd_addr_0),
        .mem1_rd_addr_1(mem1_rd_addr_1),
        .R3_mask(R3_mask),
        .R3_data(R3_data),
        .mem0_wr_en_0(mem0_wr_en_0),
        .mem0_wr_en_1(mem0_wr_en_1),
        .mem1_wr_en_0(mem1_wr_en_0),
        .mem1_wr_en_1(mem1_wr_en_1)
    );




endmodule