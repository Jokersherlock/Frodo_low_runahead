module Control #(
    parameter INST_WIDTH        = 28,
    parameter ADDR_WIDTH        = 12,
    parameter UINST_ADDR_WIDTH  = 9,
    parameter UINST_WIDTH       = 36
)(
    input                   clk,
    input                   rstn,
    input [INST_WIDTH-1:0]  inst,
    input                   inst_valid,
    

    // mem数据
    input       [63:0]              mem0_rd_data_0,
    input       [63:0]              mem0_rd_data_1,
    input       [63:0]              mem1_rd_data_0,
    input       [63:0]              mem1_rd_data_1,

    output      [ADDR_WIDTH-1:0]    mem0_addr_0,
    output      [ADDR_WIDTH-1:0]    mem0_addr_1,
    output      [ADDR_WIDTH-1:0]    mem1_addr_0,
    output      [ADDR_WIDTH-1:0]    mem1_addr_1,

    output                          mem0_wr_en_0,
    output                          mem0_wr_en_1,
    output                          mem1_wr_en_0,
    output                          mem1_wr_en_1,

    output reg  [63:0]              mem_wr_data,  // 需要写入mem的数据

    //mac相关数据
    output      [31:0]              short_data,  //4个8位数据
    output      [63:0]              long_data,   //4个16位数据
    output      [63:0]              add_data,    //4个加矩阵数据,
    input       [63:0]              macs_result, //mac计算结果
    
    output reg                      macs_mode,  // macs模式，0为乘法，1为加法
    output reg                      macs_signal, // macs符号信号，0为正，1为负
    output                          macs_en,    // macs使能信号

    //其他输入数据
    input       [63:0]              data_encode,
    output                          trans_en,
    input       [63:0]              data_decode,

    output reg  [10:0]              hash_di_len,   // hash输入长度
    output reg  [7:0]               hash_in,       // hash原始输入
    output reg                      hash_lev,      // hash安全等级
    output                          hash_di_valid, // hash数据有效信号
    output                          squeeze_en,    // 挤压使能
    output                          ram_reset,      // 显示复位使能
    output                          dout_en,        //输出数据使能
    input        [63:0]             hash_out,
    output                          absorb_en,     //吸收数据有效信号
    output reg                      flag15to8,

    //采样模块信号
    input        [7:0]              sample_data,
    output       [15:0]             hash_cut,
    output reg                      sample_en,

    input        [1:0]              level,

    output                          finish,  // 完成信号
    output                          mem_wen
);
    
    parameter IDLE = 2'b00;  //待机状态
    parameter IF   = 2'b01;  //取指令阶段
    parameter ID   = 2'b10;  //译码阶段
    parameter EX   = 2'b11;  //执行阶段

    reg [1:0] state,next_state;
    reg [2:0] ID_cnt;  // ID阶段计数器

//安全等级
    reg [10:0] level_num;
    always @(*) begin
        case (level)
            2'b01: level_num = 11'd1344;
            2'b10: level_num = 11'd976;
            2'b11: level_num = 11'd640;
            2'b00: level_num = 0;
        endcase
    end

//状态机
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                next_state = IF;
            end
            IF: begin
                if(inst_valid)begin
                    next_state = ID;
                end
                else begin
                    next_state = IF;
                end
            end
            ID: begin
                if(ID_cnt == 3'b110) begin
                    next_state = EX;
                end
                else begin
                    next_state = ID;
                end
            end
            EX: begin
                if(finish)begin
                    next_state = IDLE;
                end
                else begin
                    next_state = EX;
                end
            end
            default: begin
                next_state = IDLE;
            end  
        endcase
    end

//IF阶段
//inst_reg,取指阶段取指
    reg [INST_WIDTH-1:0] inst_reg;//指令寄存器
    wire [2:0] opcode;
    assign opcode = inst_reg[INST_WIDTH-1:INST_WIDTH-3];
    wire func;
    assign func = inst_reg[INST_WIDTH-28];
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            inst_reg <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    inst_reg <= 0;
                end
                IF: begin
                    inst_reg <= inst;
                end 
            endcase
        end
    end

//ID阶段
//ID_cnt
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            ID_cnt <= 3'b0;
        end
        else begin
            if(state == ID)begin
                ID_cnt <= ID_cnt + 1'b1;
            end
            else begin
                ID_cnt <= 3'b0;
            end
        end
    end
//hash ram_set
    reg id_ram_reset;
    always@(posedge clk or negedge rstn)begin
        if(!rstn)
            id_ram_reset <= 1'b0;
        else if(state==ID)begin
            if(ID_cnt == 3'b000)begin
                if(opcode == 3'b110 & func)
                    id_ram_reset <= inst_reg[INST_WIDTH-27];
                else if(opcode == 3'b000 & !func)
                    id_ram_reset <= inst_reg[INST_WIDTH-27];
                else if(opcode == 3'b111)
                    id_ram_reset <= 1'b1;
                else if(opcode == 3'b001 & !func)
                    id_ram_reset <= 1'b1;
                else 
                    id_ram_reset <= 1'b0;
            end
            else
                id_ram_reset <= 1'b0;
        end
    end

//读地址
    reg [ADDR_WIDTH-1:0] control_addr; //矩阵索引，用来读矩阵首地址
    reg control_addr_en;
    reg [ADDR_WIDTH+1:0] A_addr_start,B_addr_start,C_addr_start,D_addr_start;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            control_addr <= 0;
            control_addr_en <= 1'b0;
            A_addr_start <= 0;
            B_addr_start <= 0;
            C_addr_start <= 0;
            D_addr_start <= 0;
        end
        else if(state == ID)begin
            case (ID_cnt)
                3'b000:begin
                    control_addr[3:0] <= inst_reg[INST_WIDTH-4:INST_WIDTH-7];
                    control_addr_en   <= 1'b1; 
                end
                3'b001:begin
                    control_addr[3:0] <= inst_reg[INST_WIDTH-8:INST_WIDTH-11];
                    //A_addr_start      <= mem0_rd_data_0[ADDR_WIDTH+1:0];
                end
                3'b010:begin
                    control_addr[3:0] <= inst_reg[INST_WIDTH-12:INST_WIDTH-15];
                    A_addr_start      <= mem0_rd_data_0[ADDR_WIDTH+1:0];
                end
                3'b011:begin
                    if(opcode == 3'b000 || opcode == 3'b010 || opcode == 3'b001 || opcode == 3'b011)begin
                        B_addr_start  <= {inst_reg[INST_WIDTH-23],1'b0,inst_reg[INST_WIDTH-4:INST_WIDTH-15]};
                    end
                    else begin
                        B_addr_start  <= mem0_rd_data_0[ADDR_WIDTH+1:0];
                    end
                end
                3'b100:begin
                    C_addr_start      <= mem0_rd_data_0[ADDR_WIDTH+1:0];
                    //D_addr_start      <= {mem0_rd_data_0[ADDR_WIDTH+1],~mem0_rd_data_0[ADDR_WIDTH],mem0_rd_data_0[ADDR_WIDTH-1:0]};
                    if(opcode == 3'b010 || opcode == 3'b011)begin
                        D_addr_start <= {inst_reg[INST_WIDTH-23],1'b1,inst_reg[INST_WIDTH-4:INST_WIDTH-15]};
                    end
                    else if(opcode == 3'b110)
                        D_addr_start  <=  {mem0_rd_data_0[ADDR_WIDTH+1],~B_addr_start[ADDR_WIDTH],mem0_rd_data_0[ADDR_WIDTH-1:0]};
                    else begin
                        D_addr_start      <= {mem0_rd_data_0[ADDR_WIDTH+1],~mem0_rd_data_0[ADDR_WIDTH],mem0_rd_data_0[ADDR_WIDTH-1:0]};
                    end
                end
                3'b101:begin
                    control_addr_en <= 1'b0;
                end
            endcase
        end
    end

//读写使能信号
    //D_addr对应的端口为写使能，其余均为读使能
    //wire mem_wen;
    reg mem_wen_reg [0:3];
    wire [ADDR_WIDTH+1:0] A_addr,B_addr,C_addr,D_addr;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            mem_wen_reg[0] <= 1'b0;
            mem_wen_reg[1] <= 1'b0;
            mem_wen_reg[2] <= 1'b0;
            mem_wen_reg[3] <= 1'b0;
        end
        else if(ID_cnt == 3'b101)begin
            //if(opcode[2])begin
                case (D_addr_start[ADDR_WIDTH+1:ADDR_WIDTH])
                2'b00:begin
                    mem_wen_reg[0] <= 1'b1;
                    mem_wen_reg[1] <= 1'b0;
                    mem_wen_reg[2] <= 1'b0;
                    mem_wen_reg[3] <= 1'b0;
                end
                2'b01:begin
                    mem_wen_reg[0] <= 1'b0;
                    mem_wen_reg[1] <= 1'b1;
                    mem_wen_reg[2] <= 1'b0;
                    mem_wen_reg[3] <= 1'b0;
                end
                2'b10:begin
                    mem_wen_reg[0] <= 1'b0;
                    mem_wen_reg[1] <= 1'b0;
                    mem_wen_reg[2] <= 1'b1;
                    mem_wen_reg[3] <= 1'b0;
                end
                2'b11:begin
                    mem_wen_reg[0] <= 1'b0;
                    mem_wen_reg[1] <= 1'b0;
                    mem_wen_reg[2] <= 1'b0;
                    mem_wen_reg[3] <= 1'b1;
                end   
                endcase
          //  end
        end
        else if(state == IDLE)begin
            mem_wen_reg[0] <= 1'b0;
            mem_wen_reg[1] <= 1'b0;
            mem_wen_reg[2] <= 1'b0;
            mem_wen_reg[3] <= 1'b0;
        end
    end

    assign mem0_wr_en_0 = mem_wen_reg[0] & mem_wen;
    assign mem0_wr_en_1 = mem_wen_reg[1] & mem_wen;
    assign mem1_wr_en_0 = mem_wen_reg[2] & mem_wen;
    assign mem1_wr_en_1 = mem_wen_reg[3] & mem_wen;


//wr_src,写数据的来源
    reg [2:0] wr_src; // 写数据来源
    wire [63:0] transpose_data;//转置模块输出
    wire [63:0] sample_out;//采样后嵌入数据

    parameter ENCODE    = 3'b001;
    parameter DECODE    = 3'b010;
    parameter MACS      = 3'b011;
    parameter TRANSPOSE = 3'b100;
    parameter SAMPLE    = 3'b101;
    parameter HASH      = 3'b110;
    parameter HASH_CUT  = 3'b111;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            wr_src <= 3'b00;
        end
        else if(state == ID)begin
            case (opcode)
                3'b110:begin
                    if(inst_reg[INST_WIDTH-16])begin
                        wr_src <= DECODE;
                    end
                    else begin
                        wr_src <= ENCODE;
                    end
                end
                3'b100:begin
                    wr_src <= MACS;
                end
                3'b101:begin
                    wr_src <= TRANSPOSE;
                end
                3'b111:begin
                    wr_src <= MACS;
                end
                3'b010:begin
                    if(!func)begin
                        wr_src <= SAMPLE;
                    end
                    else begin
                        wr_src <= HASH;
                    end
                end
                3'b011:begin
                    wr_src <= SAMPLE;
                end
            endcase
        end
        else if(state == IDLE)begin
            wr_src <= 3'b000;
        end
    end

    always @(*) begin
        case (wr_src)
            ENCODE:     mem_wr_data = data_encode;
            DECODE:     mem_wr_data = data_decode;
            MACS:       mem_wr_data = macs_result;
            TRANSPOSE:  mem_wr_data = transpose_data;
            SAMPLE:     mem_wr_data = sample_out;
            HASH:       mem_wr_data = hash_out;
            default:    mem_wr_data = 64'b0;
        endcase
    end

//upc首地址
    reg [UINST_ADDR_WIDTH-1:0] upc_start; 
    reg [ADDR_WIDTH-1:0] uinst_addr;
    reg uinst_addr_en;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            uinst_addr <= 0;
            uinst_addr_en <= 1'b0;
            upc_start <= 0;
        end
        else if(state==ID)begin
            case (ID_cnt)
                3'b000:begin
                    //uinst_addr <= {{(ADDR_WIDTH-3){1'b0}},opcode};
                    uinst_addr <= {{(ADDR_WIDTH-4){1'b0}},func,opcode};
                    uinst_addr_en <= 1'b1;
                end
                3'b010:begin
                    //upc_start <= mem1_rd_data_0;
                    if(level == 2'b11)begin
                        if(opcode == 3'b000 & func)begin
                            upc_start <= 437;
                        end
                        else if(opcode == 3'b001 & !func)
                            upc_start <= 466;
                        else if(opcode ==3'b001 & func)
                            upc_start <= 437;
                        else begin
                            upc_start <= mem1_rd_data_0;
                        end
                    end
                    else begin
                        upc_start <= mem1_rd_data_0;
                    end
                end
                default: uinst_addr_en <= 1'b0;
            endcase
        end
        else if(state == IDLE)begin
            uinst_addr <= 0;
            uinst_addr_en <= 1'b0;
            upc_start <= 0;
        end
    end

//short_data_mode,有两种模式，1只读8位出来，0读32位
    reg short_data_mode;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            short_data_mode <= 1'b0;
        end
        else if(ID_cnt==3'b001)begin
            case (opcode)
                3'b100:begin
                    if(!func)
                        short_data_mode<=1'b0;
                    else
                        short_data_mode <= 1'b1;
                end
                3'b111:begin
                    if(func == 1'b0)begin
                        short_data_mode <= 1'b0;
                    end
                end
                default: short_data_mode<=1'b1;
            endcase
        end
        else if(state==IDLE)begin
            short_data_mode <= 1'b0;
        end
    end
//loop
    reg [10:0] loop_0,loop_1,loop_2,loop_3,loop_4;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            loop_0 <= 11'b0;
            loop_1 <= 11'b0;
            loop_2 <= 11'b0;
            loop_3 <= 11'b0;
            loop_4 <= 11'b0;
        end
        else if(state==ID)begin
            case (opcode)
                3'b110:begin
                    if(!inst_reg[INST_WIDTH-16])begin
                        case(level)
                            2'b01: loop_0 <= 11'd4;
                            2'b10: loop_0 <= 11'd3;
                            2'b11: loop_0 <= 11'd2;
                        endcase
                        loop_1 <= 11'd16;
                    end
                    else begin
                        loop_0 <= 11'd16;
                        case(level)
                            2'b01: loop_1 <= 11'd4;
                            2'b10: loop_1 <= 11'd3;
                            2'b11: loop_1 <= 11'd2;
                        endcase
                    end
                    //loop_0 <= 11'd16;
                end
                3'b100:begin
                    if(!func)
                        loop_0 <= level_num;
                    else
                        loop_0 <= 11'd16;
                        //loop_0 <= 11'd1;
                    loop_1 <= 11'd2;
                    loop_2 <= 11'd4;
                end
                3'b101:begin
                    loop_0 <= 11'd4;
                    loop_1 <= 11'd2;
                    loop_2 <= 11'd4;
                    loop_4 <= 11'd100;
                end
                3'b000:begin
                    if(func == 1'b0)begin
                        loop_0 <= {7'b0,inst_reg[INST_WIDTH-16:INST_WIDTH-21]};
                        loop_1 <= 11'd8;
                    end
                    else begin
                        case (level)
                            2'b01:begin
                                loop_0 <= 11'd15;
                                loop_1 <= 11'd4;
                                loop_2 <= 11'd157;
                                loop_3 <= 11'd17;
                                loop_4 <= 11'd100;
                            end
                            2'b10:begin
                                loop_0 <= 11'd15;
                                loop_1 <= 11'd16;
                                loop_2 <= 11'd113;
                                loop_3 <= 11'd17;
                                loop_4 <= 11'd100;
                            end
                            2'b11:begin
                                loop_0 <= 11'd163;
                                loop_1 <= 11'd56;
                                loop_2 <= 11'd0;
                                loop_3 <= 11'd42;
                                loop_4 <= 11'd100;
                            end
                        endcase
                    end
                end
                3'b111:begin
                    //loop_0 <= 11'd1;
                    loop_0 <= level_num;
                    loop_1 <= 11'd100;
                    case (level)
                        2'b01: loop_2 <= 11'd15; //1344
                        2'b10: loop_2 <= 11'd11;
                        2'b11: loop_2 <= 11'd7;
                    endcase
                    loop_3 <= 11'd21;
                    case (level)
                        2'b01: loop_4 <= 11'd21;
                        2'b10: loop_4 <= 11'd13;
                        2'b11: loop_4 <= 11'd13;
                    endcase
                end
                3'b001:begin
                    if(!func)begin
                        case (level)
                            2'b01:begin
                                loop_0 <= 11'd79;
                                loop_1 <= 11'd136;
                                loop_2 <= 11'd8;
                                loop_4 <= 11'd100;
                            end
                            2'b10:begin
                                loop_0 <= 11'd57;
                                loop_1 <= 11'd136;
                                loop_2 <= 11'd56;
                                loop_4 <= 11'd100;
                            end
                            2'b11:begin
                                loop_1 <= 11'd28;
                                loop_2 <= 11'd179;
                                loop_3 <= 11'd102;
                                loop_4 <= 11'd100;
                            end
                        endcase
                        // case(level):
                        //     2'b11:begin
                        //         loop_0 <= 11'd79;
                        //         loop_1 <= 11'd136;
                        //         loop_2 <= 11'd8;
                        //         loop_4 <= 11'd100;
                        //     end
                            
                        // endcase
                    end
                    else begin
                        case (level)
                            2'b01:begin
                                loop_0 <= 11'd78;
                                loop_1 <= 11'd136;
                                loop_2 <= 11'd128;
                                loop_3 <= 11'd16;
                                loop_4 <= 11'd100;
                            end
                            2'b10:begin
                                loop_0 <= 11'd56;
                                loop_1 <= 11'd136;
                                loop_2 <= 11'd80;
                                loop_3 <= 11'd112;
                                loop_4 <= 11'd100;
                            end
                            2'b11:begin
                                loop_0 <= 11'd77;
                                loop_1 <= 11'd28;
                                loop_2 <= 11'd179;
                                loop_3 <= 11'd25;
                                loop_4 <= 11'd100;
                            end
                        endcase
                        // loop_0 <= 11'd78;
                        // loop_1 <= 11'd136;
                        // loop_2 <= 11'd128;
                        // loop_3 <= 11'd16;
                        // loop_4 <= 11'd100;
                    end
                end
                3'b010:begin
                    loop_0 <= {7'b0,inst_reg[INST_WIDTH-16:INST_WIDTH-21]};
                    loop_4 <= 11'd100;
                    // if(!func)begin
                    //     loop_0 <= {7'b0,inst_reg[INST_WIDTH-16:INST_WIDTH-21]};
                    // end
                    // else begin
                    //     case (level)
                    //         2'b01: loop_0 <= 11'd2;
                    //         2'b10: loop_0 <= 11'd2;
                    //         2'b11: loop_0 <= 11'd2;
                    //     endcase
                    //     loop_4 <= 11'd100;
                    // end
                end
                3'b011:begin
                    if(!func)begin
                        case (level)
                            2'b01: loop_0 <= 11'd158;
                            2'b10: loop_0 <= 11'd114;
                            2'b11: loop_0 <= 11'd60;
                        endcase 
                        //loop_1 <= 11'd17;
                        if(level==2'b11)
                            loop_1 <= 11'd21;
                        else
                            loop_1 <= 11'd17;
                        case (level)
                            2'b01: loop_2 <= 11'd2;
                            2'b10: loop_2 <= 11'd14;
                            2'b11: loop_2 <= 11'd20;
                        endcase
                        loop_4 <= 11'd100;
                    end
                    else begin
                        case (level)
                            2'b01: loop_0 <= 11'd15;
                            2'b10: loop_0 <= 11'd3;
                            2'b11: loop_0 <= 11'd1;
                        endcase
                        case (level)
                            2'b01: loop_1 <= 11'd157;
                            2'b10: loop_1 <= 11'd114;
                            2'b11: loop_1 <= 11'd60;
                        endcase
                        //loop_2 <= 11'd17;
                        if(level==2'b11)
                            loop_2 <= 11'd21;
                        else
                            loop_2 <= 11'd17;
                        case (level)
                            2'b01: loop_3 <= 11'd4;
                            2'b10: loop_3 <= 11'd11;
                            2'b11: loop_3 <= 11'd19;
                        endcase
                        loop_4 <= 11'd100;
                    end
                end
            endcase
        end
        else if(state == IDLE)begin
            loop_0 <= 11'b0;
            loop_1 <= 11'b0;
            loop_2 <= 11'b0;
            loop_3 <= 11'b0;
            loop_4 <= 11'b0;
        end
    end
//macs相关控制信号
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            macs_mode <= 1'b0;
        end
        else if(state == ID)begin
            //macs_mode <= 1'b0;
            if(opcode == 3'b100)begin
                macs_mode <= func;
            end
        end
        else if(state == IDLE)begin
            macs_mode <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            macs_signal <= 1'b0;
        end
        else if(state==ID)begin
            case (opcode)
                3'b100:begin
                    macs_signal <= inst_reg[INST_WIDTH-16];
                end
            endcase
        end
        else if(state==IDLE)begin
            macs_signal <= 1'b0;
        end
    end
//genA
    reg genA;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            genA <= 1'b0;
        end
        else if(state == ID)begin
            if(opcode == 3'b111)begin
                genA <= 1'b1;
            end
        end
        else if(state == IDLE)begin
            genA <= 1'b0;
        end
    end



//Transpose控制信号
    reg trans_mode;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            trans_mode <= 1'b0;
        end
        else if(state == ID)begin
            trans_mode <= inst_reg[INST_WIDTH-16];
        end
        else if(state == IDLE)begin
            trans_mode <= 1'b0;
        end
    end

// Hash相关控制信号
    reg flag_clr;
    reg [2:0] lut_flag;
    
    always@(posedge clk or negedge rstn)begin
        if(!rstn)begin
            flag_clr <= 1'b0;
            flag15to8 <= 1'b0;
            lut_flag <= 3'b0;
        end
        else if(state == ID && level == 2'b11)begin
            if(ID_cnt == 3'b000)begin
                if(opcode == 3'b000 & func)begin
                    flag_clr <= 1'b1;
                    flag15to8 <= 1'b1;
                    lut_flag <= 3'b100;
                end
                else if(opcode == 3'b001 & !func)begin
                    flag_clr <= 1'b1;
                    flag15to8 <= 1'b1;
                    lut_flag <= 3'b000;
                end
                else if(opcode == 3'b001 & func)begin
                    flag_clr <= 1'b1;
                    flag15to8 <= 1'b1;
                    lut_flag <= 3'b001;
                end
                else if(opcode == 3'b000 & !func)begin
                    flag15to8 <= inst_reg[INST_WIDTH-22];
                end

            end
            else begin
                flag_clr <= 1'b0;
            end
        end
        else if(state == IDLE)begin
            flag15to8 <= 1'b0;
            flag_clr <= 1'b0;
            lut_flag <= 3'b000;
        end
    end

    reg [11:0] hash_di_len_;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_di_len_ <= 12'b0;
        end
        else begin
            if(state == ID)begin
                case(opcode)
                    3'b000: begin
                        if(!func)begin
                            hash_di_len_ <= {inst_reg[INST_WIDTH-16:INST_WIDTH-21],6'b0};
                        end
                        else begin
                            //hash_di_len_ <= 12'd1088;
                            if(level == 2'b11)
                                hash_di_len_ <= 12'd1344;
                            else
                                hash_di_len_ <= 12'd1088;
                        end
                    end 
                    3'b111: hash_di_len_ <= 12'd144;
                    //3'b011: hash_di_len_ <= 12'd520; 
                    3'b011: begin
                        case(level)
                            2'b01: hash_di_len_ <= 12'd520;
                            2'b10: hash_di_len_ <= 12'd392;
                            2'b11: hash_di_len_ <= 12'd264;
                        endcase
                    end
                    //3'b000: hash_di_len <= {inst_reg[INST_WIDTH-16:INST_WIDTH-21],6'b0};
                    3'b010: begin
                        if(!func)begin
                            hash_di_len_ <= {inst_reg[INST_WIDTH-16:INST_WIDTH-21],6'b0};
                        end
                        else begin
                            //hash_di_len_ <= 12'd128;
                            hash_di_len_ <= {inst_reg[INST_WIDTH-16:INST_WIDTH-21],6'b0};
                        end
                    end
                    default: hash_di_len_ <= 12'd0;
                    3'b011:begin
                        hash_di_len_ <= 12'd1088;
                    end
                    3'b001:begin
                        //hash_di_len_ <= 12'd1088;
                        if(level == 2'b11)
                            hash_di_len_ <= 12'd1344;
                        else
                            hash_di_len_ <= 12'd1088;
                    end
                endcase
                /*//hash_di_len <= {inst_reg[INST_WIDTH-16:INST_WIDTH-21],6'b0};
                if(opcode == 3'b111)begin
                    hash_di_len <= 12'd144;
                end
                // if(opcode == 3'b010)begin
                //     hash_di_len <= 12'd144;
                // end
                if(opcode == 3'b011)begin
                    hash_di_len <= 12'd144;
                end*/
            end
            else if(state == IDLE)begin
                hash_di_len_ <= 12'b0;
            end
        end
    end

    wire D_bia;

    always @(*) begin
        if(opcode == 3'b000 && func)begin
            if(D_bia)begin
                //hash_di_len = 12'd256;
                if(level == 2'b01)
                    hash_di_len = 12'd256;
                else if(level == 2'b10)
                    hash_di_len = 12'd1024;
                else
                    hash_di_len = hash_di_len_;
            end
            else
                hash_di_len = hash_di_len_;
        end
        else 
            hash_di_len = hash_di_len_;
    end



    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_lev <= 1'b0;
        end
        else if(level == 2'b11)
            hash_lev <= 1'b0;
        else if(state == ID)begin
            case (opcode)
                //3'b000: hash_lev <= 1'b1;
                3'b000:begin
                    if(level == 2'b11)
                        hash_lev <= 1'b0;
                    else
                        hash_lev <= 1'b1; 
                end
                3'b111: hash_lev <= 1'b0;
                3'b011:begin
                    if(level == 2'b11)begin
                        hash_lev <= 1'b0;
                    end
                    else begin
                        hash_lev <= 1'b1;
                    end
                end
                3'b010:begin
                    if(level == 2'b11)begin
                        hash_lev <= 1'b0;
                    end
                end
            endcase
        end
        else if(state == IDLE)begin
            hash_lev <= 1'b1;
        end
    end 
//Hash地址生成单元控制信号
    reg [2:0] hash_agu_mode;
    reg hash_agu_clr;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_agu_mode <= 3'b0;
        end
        else if(state==ID)begin
            //hash_agu_mode <= inst_reg[INST_WIDTH-24:INST_WIDTH-25];
            if(opcode == 3'b000)begin
                //hash_agu_mode <= 3'b100;
                if(level == 2'b11)
                    hash_agu_mode <= 3'b110;
                else
                    hash_agu_mode <= 3'b100;
            end
            else if(opcode == 3'b001)begin
                hash_agu_mode <= 3'b101;
            end
            // else if(opcode == 3'b010)begin
            //     hash_agu_mode <= 3'b100;
            // end
            else if(opcode == 3'b011)begin
                if(!func)begin
                    hash_agu_mode <= 3'b000;
                end
                else begin
                    if(inst_reg[INST_WIDTH-25]== 1'b0)begin
                        hash_agu_mode <= 3'b001;
                    end
                    else begin
                        hash_agu_mode <= 3'b010;
                    end
                end
            end
        end
        else if(state==IDLE)begin
            hash_agu_mode <= 3'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_agu_clr <= 1'b0;
        end
        else if(state == ID)begin
            if(ID_cnt == 3'b000)begin
                // if(inst_reg[INST_WIDTH-27])begin
                //     hash_agu_clr <= 1'b1;
                // end
                hash_agu_clr <= 1'b1;
            end
            else if(ID_cnt == 3'b001)begin
                hash_agu_clr <= 1'b0;
            end
        end
        else if(state == IDLE)begin
            hash_agu_clr <= 1'b0;
        end
    end
    reg hash_width,B_hash_en;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_width <= 1'b0;
        end
        else if(state == ID)begin
            //1为16位，0为8位
            case (opcode)
                // 3'b010:begin
                //     //hash_width <= inst_reg[INST_WIDTH-22];
                //     if(func)begin
                //         hash_width <= 1'b0;
                //     end
                // end
                3'b011:begin
                    if(func)begin
                        hash_width <= 1'b1;
                    end
                end 
            endcase
        end
        else if(state == IDLE)begin
            hash_width <= 1'b0;
        end
    end
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            B_hash_en <= 1'b0;
        end
        else if(state == ID)begin
            case (opcode)
                3'b000: begin
                    if(func)begin
                        B_hash_en <= 1'b1;
                    end
                    else begin
                        B_hash_en <= 1'b0;
                    end
                end
                3'b001: begin
                    B_hash_en <= 1'b1;
                end
                3'b010: begin
                    B_hash_en <= 1'b0;
                end
                3'b011:begin
                    B_hash_en <= 1'b1;
                end
            endcase
        end
        else if(state == IDLE)begin
            B_hash_en <= 1'b0;
        end
    end

    reg hash_inverse;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_inverse <= 1'b0;
        end
        else if(state == ID)begin
            if(opcode == 3'b000 && func)begin
                hash_inverse <= 1'b1;
            end
            else if(opcode == 3'b001)begin
                hash_inverse <= 1'b1;
            end
            else if(opcode == 3'b010 && !func)begin
                hash_inverse <= inst_reg[INST_WIDTH-24];
            end
            else if(opcode == 3'b000 && !func)
                hash_inverse <= inst_reg[INST_WIDTH-24];
        end
        else if(state == IDLE)begin
            hash_inverse <= 1'b0;
        end
    end


//hash数据模式
    reg hash_in_tran;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            hash_in_tran <= 1'b0;
        end
        else if(state == ID)begin
            //hash_in_tran <= inst_reg[INST_WIDTH-27];
            if(opcode == 3'b001)begin
                hash_in_tran <= 1'b1;
            end
            else if(opcode == 3'b000 && func && level == 2'b11)
                hash_in_tran <= 1'b1;
        end
        else if(state == IDLE)begin
            hash_in_tran <= 1'b0;
        end
    end


//采样模块
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            sample_en <= 1'b0;
        end
        else if(state == ID)begin
            case (opcode)
                3'b010:begin
                    sample_en <= inst_reg[INST_WIDTH-26];
                end
                3'b011:begin
                    sample_en <= inst_reg[INST_WIDTH-26];
                end      
            endcase
        end
        else if(state == IDLE)begin
            sample_en <= 1'b0;
        end
    end

//EX阶段
//start信号
    wire start;
    assign start = state==EX ? 1:0;

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
    assign start_pos = start & (~start_reg);

//微指令连线
    wire [UINST_ADDR_WIDTH-1:0] upc;
    wire [UINST_WIDTH-1:0] uinst;

    wire done;
    assign done = uinst[0];
    assign finish = done;
    wire [2:0] upc_up; //更新upc至寄存器内地址
    assign upc_up = uinst[3:1];
    wire [2:0] upc_st; //存储此时upc至寄存器
    assign upc_st = uinst[6:4];
    wire mac_en;
    assign mac_en = uinst[7]; // Macs使能信号
    wire short_bia_add,long_bia_add;
    assign short_bia_add = uinst[8];
    assign long_bia_add = uinst[9];
    wire [3:0] addr_a,addr_c,stride;
    assign addr_a = uinst[13:10];
    assign addr_c = uinst[17:14];
    assign stride = uinst[21:18];
    assign macs_en = mac_en;
    assign trans_en = uinst[22];
    assign hash_di_valid = uinst[23];
    assign squeeze_en = uinst[24];
    assign ram_reset = uinst[25] | id_ram_reset;
    assign dout_en = uinst[26];
    assign mem_wen = uinst[27];
    wire trans_rbias_add,trans_wbias_add;
    assign trans_rbias_add = uinst[28];
    assign trans_wbias_add = uinst[29];
    assign absorb_en = uinst[30];
    wire hash_add;
    assign hash_add = uinst[31];
    wire A_index_add;
    assign A_index_add = uinst[32];
    wire [1:0] A_index_location;
    assign  A_index_location = uinst[34:33];
    //wire D_bia;
    assign  D_bia = uinst[35];

//A矩阵生成
    reg [15:0] A_line_index;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            A_line_index <= 16'b0;
        end
        else if(state == EX && A_index_add)begin
            A_line_index <= A_line_index + 1'b1;
        end
        else if(state == IDLE)begin
            A_line_index <= 16'b0;
        end
    end



//模块实例化连线
    wire [63:0] A_data,B_data,C_data;
//数据总线
    Bus u_bus(
        .A_addr(A_addr),
        .B_addr(B_addr),
        .C_addr_origin(C_addr),
        .D_addr_origin(D_addr),
        .D_bia(D_bia),
        .C_bia(stride[0]),
        .control_addr(control_addr),
        .control_addr_en(control_addr_en),
        .uinst_addr(uinst_addr),
        .uinst_addr_en(uinst_addr_en),
        .mem0_addr_0(mem0_addr_0),
        .mem0_addr_1(mem0_addr_1),
        .mem1_addr_0(mem1_addr_0),
        .mem1_addr_1(mem1_addr_1),

        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),

        .A_data(A_data),
        .B_data(B_data),
        .C_data(C_data)
    );
//微指令存储器
    // sync_rom #(
    //     .ADDR_WIDTH(UINST_ADDR_WIDTH),
    //     .DATA_WIDTH(UINST_WIDTH)
    // ) inst_rom(
    //     .clk(clk),
    //     .rstn(rstn),
    //     .en(1'b1),
    //     .addr(upc),
    //     .dout(uinst)
    // );
    uinst_rom rom(
        .addra(upc),
        .clka(clk),
        .douta(uinst),
        .ena(1'b1)
    );

    // spsram320X36 rom(
    //     .clk(clk),
    //     .en(1'b1),
    //     .addr(upc),
    //     .din(36'b0),
    //     .we(1'b0),
    //     .dout(uinst)
    // );

//微pc控制器
    ucontrol #(
        .UINST_ADDR_WIDTH(UINST_ADDR_WIDTH),
        .UINST_WIDTH(UINST_WIDTH)
    ) u_minicontrol(
        .clk(clk),
        .rstn(rstn),
        .start_pos(start_pos),
        .upc_start(upc_start),
        .upc(upc),
        .loop_0(loop_0),
        .loop_1(loop_1),
        .loop_2(loop_2),
        .loop_3(loop_3),
        .loop_4(loop_4),
        .done(done),
        .upc_up(upc_up),
        .upc_st(upc_st),
        .flag15to8(flag15to8),
        .flag_clr(flag_clr),
        .lut_flag(lut_flag)
    );

//数据预处理模块
    wire [7:0] hash_temp;
    wire [2:0] hash_agu_bias_output;
    //assign  hash_in = A_index_location[1] ?(A_index_location[0]? A_line_index[15:8]:A_line_index[7:0]) : hash_temp;
    always @(*) begin
        if({func,opcode} == 4'b1110)begin
            hash_in = inst_reg[INST_WIDTH-4:INST_WIDTH-11];
        end
        else if(A_index_location[1])begin
            if(A_index_location[0])begin
                hash_in = A_line_index[15:8];
            end
            else
                hash_in = A_line_index[7:0];
        end
        else begin
            hash_in = hash_temp;
        end
    end
    
    
    Datapre u_data_pre(
        .clk(clk),
        .rstn(rstn),
        .start_pos(start_pos),
        .done(done),
        .A_data(A_data),
        .B_data(B_data),
        .short_data_mode(short_data_mode),
        .short_bia_add(short_bia_add),
        .long_bia_add(long_bia_add),
        .short_data_0(short_data[7:0]),
        .short_data_1(short_data[15:8]),
        .short_data_2(short_data[23:16]),
        .short_data_3(short_data[31:24]),
        .long_data_0(long_data[15:0]),
        .long_data_1(long_data[31:16]),
        .long_data_2(long_data[47:32]),
        .long_data_3(long_data[63:48]),
        .hash_in(hash_temp),
        .hash_out(hash_out),
        .hash_cut(hash_cut),
        .genA(genA),
        .sample_in(sample_data),
        .sample_out(sample_out),
        .hash_width(hash_width),
        .hash_in_tran(hash_in_tran),
        .hash_bias(hash_agu_bias_output),
        .hash_inverse(hash_inverse),
        .sample_en(sample_en),
        .B_hash_en(B_hash_en)
    );
    assign add_data = C_data;

//地址生成单元
    wire [11:0] hash_agu_addr_output;
    AGU #(
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_agu(
        .clk(clk),
        .rstn(rstn),
        .add_en(addr_a),
        .stride(stride),
        .clr_en(addr_c),
        .A_addr_start(A_addr_start),
        .B_addr_start(B_addr_start),
        .C_addr_start(C_addr_start),
        .D_addr_start(D_addr_start),
        .hash_addr(hash_agu_addr_output),
        .hash_bias(hash_agu_bias_output),
        .hash_width(hash_width),
        .B_hash_en(B_hash_en),
        .A_addr(A_addr),
        .B_addr(B_addr),
        .C_addr(C_addr),
        .D_addr(D_addr)
    );

//转置模块
    Transpose  u_Transpose (
    .clk                              ( clk                               ),
    .rstn                             ( rstn                              ),
    .rdata                            ( B_data                            ),
    .wdata                            ( C_data                            ),
    .mode                             ( trans_mode                        ),
    .rbias_add                        ( trans_rbias_add                   ),
    .wbias_add                        ( trans_wbias_add                   ),
    .output_data                      ( transpose_data                    )
    );
//hash地址生成单元
    AGU_hash u_agu_hash(
        .clk(clk),
        .rstn(rstn),
        .addr_clr(hash_agu_clr),
        .add_en(hash_add),
        .mode(hash_agu_mode),
        .addr_output(hash_agu_addr_output),
        .bias(hash_agu_bias_output),
        .level(level)
    );

endmodule