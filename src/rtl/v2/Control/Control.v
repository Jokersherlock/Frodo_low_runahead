// `include "global_define.v"
module Control(
    input clk,
    input rstn,

    input      [`INST_WIDTH-1:0]            inst,
    // input                                   inst_valid,
    input      [1:0]                        level,
    input      [1:0]                        mode,
    output reg [1:0]                        level_reg,
    output reg [1:0]                        mode_reg,


    input                                   start,
    output reg [7:0]                        pc,
    output reg                             valid,
    input      [63:0]                       mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1,
    output     [63:0]                       mem_wr_data,

    output     [10:0]                       di_len,//hash输入长度
    output     [7:0]                        hash_in,//hash输入
    output     [1:0]                        hash_lev,//hash安全等级
    output                                  di_valid,//hash输入使能
    output                                  squeeze_en,//挤压使能
    output                                  absorb_en,//吸收使能
    output                                  ram_reset,//ram复位
    output                                  hash_dout_en,//输出使能
    output                                  flag15to8,//640等级下,hash位宽转换
    
    // Bus模块相关输出端口
    output                                  R0_en, R1_en, R2_en,
    output     [1:0]                        R3_en,
    input     [2:0]                        R0_mask,
    input                                  R1_mask,
    output     [31:0]                       R1_32,
    output     [15:0]                       R0_16,
    output     [7:0]                        R0_8,
    output     [63:0]                       R2_out,
    //output     [7:0]                        R3_mask,
    output     [11:0]                       upc_addr,
    output                                  upc_addr_en,
    output     [11:0]                       ex_addr,
    output                                  ex_addr_en,
    input      [63:0]                       R0_in,R1_in,R2_in,
    
    // AGU相关输出端口
    output     [16:0]                       addr_start_0, addr_start_1, addr_start_2, addr_start_3,
    output     [1:0]                        R0_mode,
    output     [2:0]                        R3_mode,
    output                                  R1_mode, R2_mode,
    output     [3:0]                        addr_clr, addr_add,

    input                                  keccak_ready,
    output                                 sample_en,
    input      [7:0]                      sample_out,
    input      [15:0]                     hash_16out,

    output                                 mem_wen,

    output                                 macs_en,
    output                                 macs_mode,
    output                                 macs_signal,
    output                                 macs_src,
    input      [63:0]                      macs_result,
    output                                 load_en,
    output                                 consume_en,

    input      [15:0]                     data_encode,
    input      [15:0]                     data_decode
);

    //wire [`INST_WIDTH-1:0] inst;
    wire inst_valid;

    wire inst_done;


    localparam IDLE = 3'b000;
    localparam START = 3'b001;
    localparam IF0 = 3'b010;
    localparam IF1 = 3'b011;
    localparam IF2 = 3'b100;
    localparam EX = 3'b101;
    localparam FINISH = 3'b110;
//start上升沿检测
    reg start_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            start_reg <= 1'b0;
        end
        else begin
            start_reg <= start;
        end
    end

    wire start_pos;
    assign start_pos = start & (!start_reg);
//state_reg
    //reg [1:0] mode_reg,level_reg;
    reg [2:0] state,state_nxt;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            mode_reg <= 2'b0;
            level_reg <= 2'b0;
        end
        else if(state == IDLE)begin
            mode_reg <= mode;
            level_reg <= level;
        end
    end
//状态机
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            state <= IDLE;
        end
        else begin
            state <= state_nxt;
        end
    end
    always @(*) begin
        valid = 1'b0;
        case (state)
            IDLE:begin
                if(start_pos)begin
                    state_nxt = START;
                end
                else begin
                    state_nxt = IDLE;
                end
            end
            START:begin
                state_nxt = IF0 ;
            end
            IF0:begin
                state_nxt = IF1;
            end
            IF1:begin
                state_nxt = IF2;
            end
            IF2:begin
                state_nxt = EX;
            end
            EX:begin
                if(inst_done)begin
                    state_nxt = FINISH;
                end
                else begin
                    state_nxt = EX;
                end
            end
            FINISH:begin
                case (mode_reg)
                `KEYGEN:begin
                    if(level_reg == `FRODO_640 &&pc == 8'd19)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_976 &&pc == 8'd94)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_1344 &&pc == 8'd181)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else begin
                        state_nxt = IF0;        
                    end
                end
                `ENCAP:begin
                    if(level_reg == `FRODO_640 &&pc == 8'd12)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_976 &&pc == 8'd127)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_1344 &&pc == 8'd212)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else begin
                        state_nxt = IF0;
                    end
                end
                `DECAP:begin
                    if(level_reg == `FRODO_640 &&pc == 8'd12)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_976 &&pc == 8'd170)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else if(level_reg == `FRODO_1344 &&pc == 8'd251)begin
                        state_nxt = IDLE;
                        valid     = 1'b1;
                    end
                    else begin
                        state_nxt = IF0;
                    end
                end
                default:begin
                    state_nxt = IDLE;
                end
                endcase
            end
        endcase
    end
//pc
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            pc <= 8'b0;
        end
        else begin
            case (state)
                IDLE:begin
                    pc <= 8'b0;
                end
                START:begin
                    if(level_reg == `FRODO_640 &&mode_reg == `KEYGEN)begin
                        pc <= 8'd1;
                    end
                    else if(level_reg == `FRODO_976 &&mode_reg == `KEYGEN)begin
                        pc <= 8'd13;
                    end
                    else if(level_reg == `FRODO_1344 &&mode_reg == `KEYGEN)begin
                        pc <= 8'd45;
                    end
                    else if(level_reg == `FRODO_640 &&mode_reg == `ENCAP)begin
                        pc <= 8'd13;
                    end
                    else if(level_reg == `FRODO_976 &&mode_reg == `ENCAP)begin
                        pc <= 8'd45;
                    end
                    else if(level_reg == `FRODO_1344 &&mode_reg == `ENCAP)begin
                        pc <= 8'd84;
                    end
                    else if(level_reg == `FRODO_640 &&mode_reg == `DECAP)begin
                        pc <= 8'd84;
                    end
                    else if(level_reg == `FRODO_976 &&mode_reg == `DECAP)begin
                        pc <= 8'd128;
                    end
                    else if(level_reg == `FRODO_1344 &&mode_reg == `DECAP)begin
                        pc <= 8'd171;
                    end
                    else begin
                        pc <= 8'b0;
                    end
                end
                FINISH:begin
                    pc <= pc + 1'b1;
                end
            endcase
        end
    end

    assign inst_valid = (state == IF2);
    reg [`INST_WIDTH-1:0] inst_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            inst_reg <= `INST_WIDTH'b0;
        end
        else if(state == IF2)begin
            inst_reg <= inst;
        end
        else if(state == IDLE)begin
            inst_reg <= `INST_WIDTH'b0;
        end
        else if(state == FINISH)begin
            inst_reg <= `INST_WIDTH'b0;
        end
    end



    wire [3:0] opcode;
    wire [11:0] loop_0;
    wire [7:0] loop_1;
    wire [7:0] loop_2;
    wire [7:0] loop_3;
    wire [`UINST_ADDR_WIDTH-1:0] upc_start;
    wire flag15to8;
    wire [2:0] lut_flag;
//    wire [2:0] R0_mask;
//    wire R1_mask;
    wire R0_inverse;
    // wire macs_mode;
    // wire macs_signal;
    wire [10:0] di_len;
    wire hash_in_src;
    wire hash_ex_mode;
//    wire R0_en,R1_en,R2_en;
    wire ram_reset_inst;
//    wire [63:0] R0_in,R1_in,R2_in,R3_in;

    wire [`UINST_ADDR_WIDTH-1:0] upc;
    wire ucontrol_start;

    wire [63:0] R0_out,R1_out,R3_out;
    assign mem_wr_data = R3_out;
    // wire [32:0] R1_32;
    // wire [15:0] R0_16;
    // wire [7:0] R0_8;
    wire [`UINST_WIDTH-1:0] uinst;

    wire [2:0] R3_src;




    wire done;
    assign done = uinst[0];
    assign inst_done = done;
    
    wire [2:0] upc_st,upc_up;
    assign upc_st = uinst[3:1];
    assign upc_up = uinst[6:4];
    
    assign addr_clr = uinst[10:7];
    assign addr_add = uinst[14:11];
    
    wire macs_en;
    assign macs_en = uinst[15];
    
    wire ex_en;
    assign di_valid = uinst[16];
    assign ex_en = uinst[17];
    assign ram_reset = uinst[18] | ram_reset_inst;
    assign hash_dout_en = uinst[19];
    
    wire stall;
    assign stall = uinst[20];

    wire mem_wen;
    assign mem_wen = uinst[21];

    wire [1:0] a_index;
    assign a_index = uinst[23:22];
    //wire load_en;
    assign load_en = uinst[24];
   // wire consume_en;
    assign consume_en = uinst[25];

    reg [15:0] A_line_index;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            A_line_index <= 16'b0;
        end
        else if(state == EX)begin
            if(a_index == 2'b11)begin
                A_line_index <= A_line_index + 1'b1;
            end
        end
        else if(state == IDLE)begin
            A_line_index <= 16'b0;
        end
        else if(state == FINISH)begin
            A_line_index <= 16'b0;
        end
    end


    //hash
    assign hash_in = hash_in_src   ? inst_reg[`INST_WIDTH-1:`INST_WIDTH-8] : 
                     (~a_index[1]) ? R0_8 :
                       a_index[0]  ? A_line_index[15:8] : A_line_index[7:0];
    reg di_valid_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            di_valid_reg <= 1'b0;
        end
        else begin
            di_valid_reg <= di_valid;
        end
    end
    //A参与的乘法,前一时刻di_valid使能,说明此时为吸收过程
    assign absorb_en = opcode == `AMATMUL ? ex_en & di_valid_reg : ~hash_ex_mode & ex_en;
    assign squeeze_en = opcode == `AMATMUL ? ex_en & ~di_valid_reg : hash_ex_mode & ex_en;
       
    // assign absorb_en = ~hash_ex_mode & ex_en;
    // assign squeeze_en = hash_ex_mode & ex_en;


    //R3_in
    localparam HASH = 3'b000;
    localparam SAMPLE = 3'b001;
    localparam MACS = 3'b010;
    localparam ENCODE = 3'b011;
    localparam DECODE = 3'b100;
    reg [63:0] R3_in;

    always @(*) begin
        case (R3_src)
            HASH:begin
                R3_in = {4{hash_16out}};
            end
            SAMPLE:begin
                R3_in = R3_en == 2'b01 ? {8{sample_out}} : {4{{8{sample_out[7]}},sample_out}};
            end
            MACS:begin
                R3_in = macs_result;
            end
            ENCODE:begin
                R3_in = {4{data_encode}};
            end
            DECODE:begin
                R3_in = {4{data_decode}};
            end
            default:begin
                R3_in = 64'b0;
            end
        endcase
    end

    InstDecoder u_InstDecoder(
        .clk(clk),
        .rstn(rstn),
        .inst(inst),
        .level(level_reg),
        .inst_valid(inst_valid),
        .opcode(opcode),
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
        // .R0_mask(R0_mask),
        // .R1_mask(R1_mask),
        .R0_inverse(R0_inverse),
        .macs_mode(macs_mode),
        .macs_signal(macs_signal),
        .macs_src(macs_src),
        .done(done),
        .di_len(di_len),
        .hash_in_src(hash_in_src),
        .hash_lev(hash_lev),
        .hash_ex_mode(hash_ex_mode),
        .ram_reset_inst(ram_reset_inst),
        .R0_en(R0_en),
        .R1_en(R1_en),
        .R2_en(R2_en),
        .R3_en(R3_en),
        .ucontrol_start(ucontrol_start),
        .upc_addr(upc_addr),
        .upc_addr_en(upc_addr_en),
        .ex_addr(ex_addr),
        .ex_addr_en(ex_addr_en),
        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),
        .R3_src(R3_src),
        .sample_en(sample_en)
    );




    uControl u_uControl(
        .clk(clk),
        .rstn(rstn),
        .start(ucontrol_start),
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
        .lut_flag(lut_flag),
        .done(done),
        .keccak_ready(keccak_ready)
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


    wire [`UINST_WIDTH-1:0] uinst_temp;

`ifdef USE_IP_CORE
    // 使用IP核模式
    uinst_rom u_uinst_rom(
        .clka(clk),
        .ena(1'b1),
        .addra(upc),
        .douta(uinst_temp)
    );
`else
    // 使用仿真模式
    rom #(
        .ADDR_WIDTH(`UINST_ADDR_WIDTH),
        .DATA_WIDTH(`UINST_WIDTH),
        .MEM_DEPTH(256),
        .HEX_FILE("../../../../../../src/sim/bin/uinst.bin")
    ) u_inst_rom(
        .clk(clk),
        .addr(upc),
        .dout(uinst_temp)
    );
`endif

assign uinst = (state == EX) ? uinst_temp : `UINST_WIDTH'b0;


endmodule