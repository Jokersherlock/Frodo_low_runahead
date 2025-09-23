// `include "global_define.v"
module InstDecoder (
    input clk,
    input rstn,

    input      [`INST_WIDTH-1:0]            inst,
    input                                   inst_valid,
    input      [1:0]                        level,
    input                                   done,
    output     [3:0]                        opcode,

    output reg  [`INST_WIDTH-1:0]           inst_reg,

    output reg  [11:0]                      loop_0,
    output reg  [7:0]                       loop_1,
    output reg  [7:0]                       loop_2,
    output reg  [7:0]                       loop_3,
    output reg  [`UINST_ADDR_WIDTH-1:0]     upc_start,
    output reg                              flag15to8, //640安全等级下,15to8使能
    output reg  [2:0]                       lut_flag, //640安全等级下,ss和pkh的不同循环节

    output reg  [16:0]                      addr_start_0,addr_start_1,addr_start_2,addr_start_3,
    output reg  [1:0]                       R0_mode,
    output reg  [2:0]                       R3_mode,
    output reg                              R1_mode,
    output reg                              R2_mode,

    // input  reg  [2:0]                       R0_mask,
    // input  reg                              R1_mask,
    output reg                              R0_inverse,

    output reg                              macs_mode,
    output reg                              macs_signal,
    output reg                              macs_src,

    output reg   [10:0]                     di_len,
    output reg                              hash_in_src,
    output reg                              hash_lev,
    output reg                              hash_ex_mode,
    output reg                              ram_reset_inst,

    output reg                              R0_en,R1_en,R2_en,
    output reg   [1:0]                      R3_en,

    output                                  ucontrol_start,

    output reg   [11:0]                     upc_addr,
    output reg                              upc_addr_en,
    output reg   [11:0]                     ex_addr,
    output reg                              ex_addr_en,

    input        [63:0]                     mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1,

    output reg   [2:0]                      R3_src,
    output reg                              sample_en
);

    localparam IDLE   = 3'b000;
    localparam IF     = 3'b001;
    localparam ID     = 3'b010;
    localparam EX     = 3'b011;
    localparam FINISH = 3'b100;

    //wire [3:0] opcode;

    assign opcode = inst_reg[`INST_WIDTH-23:`INST_WIDTH-26];

    reg [2:0] state_reg,state_nxt;
    wire done;
    reg [2:0] ID_cnt;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            state_reg <= IDLE;
        else
            state_reg <= state_nxt;
    end

    always @(*) begin
        case (state_reg)
            IDLE: begin
                if(inst_valid)
                    state_nxt = IF;
                else
                    state_nxt = IDLE;
            end
            IF: begin
                state_nxt = ID;
            end
            ID: begin
                if(ID_cnt == 3'b101)
                    state_nxt = EX;
                else
                    state_nxt = ID;
            end
            EX: begin
                if(done)
                    state_nxt = FINISH;
                else
                    state_nxt = EX;
            end
            FINISH: begin
                state_nxt = IDLE;
            end
            default: begin
                state_nxt = IDLE;
            end
        endcase
    end


//inst_reg
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            inst_reg <= `INST_WIDTH'b0;
        end
        else if(state_reg == IF)begin
            inst_reg <= inst;
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            inst_reg <= `INST_WIDTH'b0;
        end
    end

//ID_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            ID_cnt <= 3'b0;
        end
        else if(state_reg == ID)begin
            ID_cnt <= ID_cnt + 1'b1;
        end
        else begin
            ID_cnt <= 3'b0;
        end
    end



//微程序启动
    reg ucontrol_start_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            ucontrol_start_reg <= 1'b0;
        end
        else if(state_reg == EX)begin
            ucontrol_start_reg <= 1'b1;
        end
        else begin
            ucontrol_start_reg <= 1'b0;
        end
    end

    assign ucontrol_start = ~ucontrol_start_reg & (state_reg == EX);



//upc_start
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            upc_addr <= 12'b0;
            upc_addr_en <= 1'b0;
        end
        else if(state_reg == ID && ID_cnt == 3'b001)begin
            upc_addr <= {8'b0,opcode};
            upc_addr_en <= 1'b1;
        end
        else begin
            upc_addr <= 12'b0;
            upc_addr_en <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            upc_start <= 8'b0;
        end
        else if(state_reg == ID && ID_cnt == 3'b100)begin
            upc_start <= mem1_rd_data_0[7:0];
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            upc_start <= 8'b0;
        end
    end



//loop获取值
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            loop_0 <= 12'b0;
            loop_1 <= 8'b0;
            loop_2 <= 8'b0;
            loop_3 <= 8'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    loop_0 <= {2'b0,inst_reg[`INST_WIDTH-13:`INST_WIDTH-18],3'b0}; //指令length与64对齐,因此循环数loop0 = length*64/8
                    loop_1 <= 8'b0;
                    loop_2 <= 8'b0;
                    loop_3 <= 8'b0;
                end
                `SQUEEZE_STRM:begin
                    loop_0 <= {inst_reg[`INST_WIDTH-27:`INST_WIDTH-28],inst_reg[`INST_WIDTH-13:`INST_WIDTH-18]};
                    loop_1 <= level == `FRODO_640 ? 8'd84 : 8'd68;
                    loop_2 <= 8'b0;
                    loop_3 <= 8'b0;
                end
                `SQUEEZE:begin
                    loop_0 <= {3'b0,inst_reg[`INST_WIDTH-13:`INST_WIDTH-18],2'b0}; //指令length与64对齐,因此循环数loop0 = length*64/16
                    loop_1 <= 8'b0;
                    loop_2 <= 8'b0;
                    loop_3 <= 8'b0;
                end
                `AMATMUL:begin
                    // loop_0 <= level == `FRODO_640  ? 12'd640  :
                    //           level == `FRODO_976  ? 12'd976  :
                    //           level == `FRODO_1344 ? 12'd1344 : 12'b0;
                    loop_0 <= 12'd1;
                    loop_1 <= level == `FRODO_640 ?  8'd7  :
                              level == `FRODO_976 ?  8'd11 :
                              level == `FRODO_1344 ? 8'd15 : 8'b0;
                    loop_2 <= 8'd84;
                    loop_3 <= level == `FRODO_640 ?  8'd52 :
                              level == `FRODO_976 ?  8'd52 :
                              level == `FRODO_1344 ? 8'd84 : 8'b0;
                end
                `ENCDEC:begin
                    if(inst_reg[`INST_WIDTH-22])begin//decode
                        loop_0 <= 12'd4;
                        loop_1 <= 8'd16;
                        loop_2 <= level == `FRODO_640 ? 8'd2 :
                                  level == `FRODO_976 ? 8'd3 :
                                  level == `FRODO_1344 ? 8'd4 : 8'b0;
                        loop_3 <= 8'd0;
                    end
                    else begin
                        loop_0 <= 12'd4;
                        loop_1 <= level == `FRODO_640 ? 8'd2 :
                                  level == `FRODO_976 ? 8'd3 :
                                  level == `FRODO_1344 ? 8'd4 : 8'b0;
                        loop_2 <= 8'd16;
                        loop_3 <= 8'd0;
                    end
                end
                default:begin
                    loop_0 <= 12'b0;
                    loop_1 <= 8'b0;
                    loop_2 <= 8'b0;
                    loop_3 <= 8'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            loop_0 <= 12'b0;
            loop_1 <= 8'b0;
            loop_2 <= 8'b0;
            loop_3 <= 8'b0;
        end
    end

//hash相关信号
    //hash_in_src  0:ram,1:inst
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_in_src <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB_BYTE:begin
                    hash_in_src <= 1'b1;
                end
                `ABSORB:begin
                    hash_in_src <= 1'b0;
                end
                `AMATMUL:begin
                    hash_in_src <= 1'b0;
                end
                default:begin
                    hash_in_src <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            hash_in_src <= 1'b0;
        end
    end
    //hash_lev 0:128,1:256
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_lev <= 1'b1;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    if(level == `FRODO_640)
                        hash_lev <= 1'b0;
                    else
                        hash_lev <= 1'b1;
                end
                `AMATMUL:begin
                    hash_lev <= 1'b0;
                end
                `HASH_RND:begin
                    hash_lev <= inst_reg[`INST_WIDTH-20];
                end
                default:begin
                    hash_lev <= 1'b1;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            hash_lev <= 1'b1;
        end
    end
    //hash_ex_mode 0:absorb,1:squeeze/absorb(Amatmul)
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_ex_mode <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `HASH_RND:begin
                    hash_ex_mode <= inst_reg[`INST_WIDTH-22];
                end
                `SQUEEZE_STRM:begin
                    hash_ex_mode <= 1'b1;
                end
                `AMATMUL:begin
                    hash_ex_mode <= 1'b0;
                end
                default:begin
                    hash_ex_mode <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            hash_ex_mode <= 1'b0;
        end
    end
    //di_len
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            di_len <= 11'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `HASH_RND:begin
                    di_len <= {inst_reg[`INST_WIDTH-9:`INST_WIDTH-18],3'b0};//length*8
                    //di_len <= 8;
                end
                `AMATMUL:begin
                    di_len <= 11'd144;
                end
                default:begin
                    di_len <= 11'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            di_len <= 11'b0;
        end
    end

    //flag15to8
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            flag15to8 <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    flag15to8 <= inst_reg[`INST_WIDTH-20];
                end
                default:begin
                    flag15to8 <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            flag15to8 <= 1'b0;
        end
    end

    //ram_reset_inst
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            ram_reset_inst <= 1'b0;
        end
        else if(state_reg == ID && ID_cnt == 3'b000)begin
            case (opcode)
                `ABSORB:begin
                    ram_reset_inst <= inst_reg[`INST_WIDTH-22];
                end
                `AMATMUL:begin
                    ram_reset_inst <= 1'b1;
                end
                default:begin
                    ram_reset_inst <= 1'b0;
                end
            endcase
        end
        else begin
            ram_reset_inst <= 1'b0;
        end
    end

    //R0_inverse
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R0_inverse <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    R0_inverse <= inst_reg[`INST_WIDTH-21];
                end
                default:begin
                    R0_inverse <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R0_inverse <= 1'b0;
        end
    end

    //sample_en
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            sample_en <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `SQUEEZE_STRM:begin
                    sample_en <= inst_reg[`INST_WIDTH-22];
                end
                `SQUEEZE:begin
                    sample_en <= inst_reg[`INST_WIDTH-22];
                end
                default:begin
                    sample_en <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            sample_en <= 1'b0;
        end
    end


//R0_mode
    localparam NORMAL64 = 2'b00;//64位对齐+1
    localparam NORMAL16 = 2'b01;//16位对齐+1
    localparam NORMAL8  = 2'b10;//8位对齐+1
    localparam READBP   = 2'b11;//读B'


    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R0_mode <= NORMAL64;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    R0_mode <= NORMAL8;
                end
                `AMATMUL:begin
                    R0_mode <= NORMAL8;
                end
                `ENCDEC:begin
                    R0_mode <= NORMAL16;
                end
                default:begin
                    R0_mode <= NORMAL64;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R0_mode <= NORMAL64;
        end
    end

//R3_mode
    localparam WRITE64 = 3'b000;//64位对齐+1
    localparam WRITE16 = 3'b001;//16位对齐+1
    localparam WRITE8  = 3'b010;//8位对齐+1
    localparam GENS    = 3'b011;//生成S,S'
    localparam GENEP   = 3'b100;//生成E'
    localparam MATRAN  = 3'b101;//矩阵转置
    localparam AMATMUL = 3'b110;//A矩阵乘法

    always @(posedge clk or negedge rstn) begin

        if(!rstn)begin
            R3_mode <= WRITE64;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `SQUEEZE_STRM:begin
                    case(inst_reg[`INST_WIDTH-20:`INST_WIDTH-21])
                        2'b00:begin //S，生成S,S'
                            R3_mode <= GENS;
                        end
                        2'b01:begin //E 生成E'
                            R3_mode <= GENEP;
                        end
                        2'b10:begin //16位对齐+1
                            R3_mode <= WRITE16;
                        end
                        default:begin
                            R3_mode <= WRITE8;
                        end
                    endcase
                end
                `SQUEEZE:begin
                    case(inst_reg[`INST_WIDTH-20:`INST_WIDTH-21])
                        2'b00:begin //S，生成S,S'
                            R3_mode <= GENS;
                        end
                        2'b01:begin //E 生成E'
                            R3_mode <= GENEP;
                        end
                        2'b10:begin //16位对齐+1
                            R3_mode <= WRITE16;
                        end
                        default:begin
                            R3_mode <= WRITE8;
                        end
                    endcase
                end
                `AMATMUL:begin
                    R3_mode <= inst_reg[`INST_WIDTH-22] ? WRITE64 : AMATMUL;
                end
                `ENCDEC:begin
                    R3_mode <= WRITE16;
                end
                default:begin
                    R3_mode <= WRITE64;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R3_mode <= WRITE64;
        end
    end

    //addr

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            ex_addr_en <= 1'b0;
            ex_addr <= 12'b0;
        end
        else if(state_reg == ID && ~opcode[3])begin
            case(ID_cnt)
                3'b000:begin
                    ex_addr_en <= 1'b1;
                    ex_addr <= {inst_reg[`INST_WIDTH-1:`INST_WIDTH-4]};
                end
                3'b001:begin
                    ex_addr_en <= 1'b1;
                    ex_addr <= {inst_reg[`INST_WIDTH-5:`INST_WIDTH-8]};
                end
                3'b010:begin
                    ex_addr_en <= 1'b1;
                    ex_addr <= {inst_reg[`INST_WIDTH-9:`INST_WIDTH-12]};
                end
                3'b011:begin
                    ex_addr_en <= 1'b0;
                end
                default:begin
                    ex_addr_en <= 1'b0;
                    ex_addr <= 12'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            ex_addr_en <= 1'b0;
            ex_addr <= 12'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            addr_start_0 <= 17'b0;
            addr_start_1 <= 17'b0;
            addr_start_2 <= 17'b0;
            addr_start_3 <= 17'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    addr_start_0 <= {inst_reg[`INST_WIDTH-19],1'b0,inst_reg[`INST_WIDTH-1:`INST_WIDTH-12],3'b0};
                end
                `SQUEEZE_STRM:begin
                    addr_start_3 <= {inst_reg[`INST_WIDTH-19],1'b0,inst_reg[`INST_WIDTH-1:`INST_WIDTH-12],3'b0};
                end
                `SQUEEZE:begin
                    addr_start_3 <= {inst_reg[`INST_WIDTH-19],1'b0,inst_reg[`INST_WIDTH-1:`INST_WIDTH-12],3'b0};
                end
                `AMATMUL:begin
                    case(ID_cnt)
                        3'b011:begin
                            addr_start_0 <= {mem0_rd_data_0[13:0],3'b0};
                        end
                        3'b100:begin
                            addr_start_1 <= {mem0_rd_data_0[13:0],3'b0};
                        end
                        3'b101:begin
                            addr_start_2 <= {mem0_rd_data_0[13:0],3'b0};
                            addr_start_3 <= {mem0_rd_data_0[13],~mem0_rd_data_0[12],mem0_rd_data_0[11:0],3'b0};
                        end
                    endcase
                end
                `ENCDEC:begin
                    case(ID_cnt)
                        3'b011:begin
                            addr_start_0 <= {mem0_rd_data_0[13:0],3'b0};
                        end
                        3'b101:begin
                            addr_start_3<= {mem0_rd_data_0[13:0],3'b0};
                        end
                    endcase
                end

                default:begin
                    addr_start_0 <= 17'b0;
                    addr_start_1 <= 17'b0;
                    addr_start_2 <= 17'b0;
                    addr_start_3 <= 17'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            addr_start_0 <= 17'b0;
            addr_start_1 <= 17'b0;
            addr_start_2 <= 17'b0;
            addr_start_3 <= 17'b0;
        end
    end

    //R_en
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R0_en <= 1'b0;
            R1_en <= 1'b0;
            R2_en <= 1'b0;
            R3_en <= 2'b00;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `ABSORB:begin
                    R0_en <= 1'b1;
                    R1_en <= 1'b0;
                    R2_en <= 1'b0;
                    R3_en <= 2'b00;
                end
                `SQUEEZE_STRM:begin
                    R0_en <= 1'b0;
                    R1_en <= 1'b0;
                    R2_en <= 1'b0;
                    case(inst_reg[`INST_WIDTH-20:`INST_WIDTH-21])
                        2'b00:begin //S，写8位
                            R3_en <= 2'b01;
                        end
                        2'b01:begin //E 写16位
                            R3_en <= 2'b10;
                        end
                        2'b10:begin //16位对齐+1
                            R3_en <= 2'b10;
                        end
                        default:begin
                            R3_en <= 2'b00;
                        end
                    endcase
                end
                `SQUEEZE:begin
                    case(inst_reg[`INST_WIDTH-20:`INST_WIDTH-21])
                        2'b00:begin //S，写8位
                            R3_en <= 2'b01;
                        end
                        2'b01:begin //E 写16位
                            R3_en <= 2'b10;
                        end
                        2'b10:begin //16位对齐+1
                            R3_en <= 2'b10;
                        end
                        default:begin
                            R3_en <= 2'b00;
                        end
                    endcase
                end
                `AMATMUL:begin
                    R0_en <= 1'b1;
                    R1_en <= 1'b1;
                    R2_en <= 1'b1;
                    R3_en <= 2'b11;
                end
                `ENCDEC:begin
                    R0_en <= 1'b1;
                    R1_en <= 1'b0;
                    R2_en <= 1'b0;
                    R3_en <= 2'b10;
                end
                default:begin
                    R0_en <= 1'b0;
                    R1_en <= 1'b0;
                    R2_en <= 1'b0;
                    R3_en <= 2'b00;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R0_en <= 1'b0;
            R1_en <= 1'b0;
            R2_en <= 1'b0;
            R3_en <= 2'b00;
        end
    end

//R3_src

    localparam HASH = 3'b000;
    localparam SAMPLE = 3'b001;
    localparam MACS = 3'b010;
    localparam ENCODE = 3'b011;
    localparam DECODE = 3'b100;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R3_src <= 3'b000;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `SQUEEZE_STRM:begin
                    R3_src <= inst_reg[`INST_WIDTH-22] ? SAMPLE : HASH;
                end
                `SQUEEZE:begin
                    R3_src <= inst_reg[`INST_WIDTH-22] ? SAMPLE : HASH;
                end
                `AMATMUL:begin
                    R3_src <= MACS;
                end
                `ENCDEC:begin
                    R3_src <= inst_reg[`INST_WIDTH-22] ? DECODE : ENCODE;
                end
                default:begin
                    R3_src <= 3'b000;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R1_mode <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `AMATMUL:begin
                    R1_mode <= 1'b0;
                end
                default:begin
                    R1_mode <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R1_mode <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R2_mode <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `AMATMUL:begin
                    R2_mode <= 1'b0;
                end
                default:begin
                    R2_mode <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            R2_mode <= 1'b0;
        end
    end


//macs
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            macs_mode <= 1'b0;
            macs_signal <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `AMATMUL:begin
                    macs_mode <= 1'b0;
                    macs_signal <= 1'b0;
                end
                default:begin
                    macs_mode <= 1'b0;
                    macs_signal <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            macs_mode <= 1'b0;
            macs_signal <= 1'b0;
        end
    end
    //0:ram,1:hash
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            macs_src <= 1'b0;
        end
        else if(state_reg == ID)begin
            case (opcode)
                `AMATMUL:begin
                    macs_src <= 1'b1;
                end
                default:begin
                    macs_src <= 1'b0;
                end
            endcase
        end
        else if(state_reg == IDLE || state_reg == FINISH)begin
            macs_src <= 1'b0;
        end
    end


endmodule
