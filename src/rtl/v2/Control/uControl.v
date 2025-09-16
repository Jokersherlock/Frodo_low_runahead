// `include "global_define.v"
module uControl (
    input                               clk,
    input                               rstn,

    input                               start, //开始信号
    input      [`UINST_ADDR_WIDTH-1:0]  upc_start, //起始地址
    output reg [`UINST_ADDR_WIDTH-1:0]  upc, //当前地址
    
    input                               stall,   //等待信号

    input      [11:0]                   loop_0,
    input      [7:0]                    loop_1,
    input      [7:0]                    loop_2,
    input      [7:0]                    loop_3,

    input      [2:0]                    upc_up,
    input      [2:0]                    upc_st,

    input                               flag15to8,
    input      [2:0]                    lut_flag,

    input                               done,
    input                               keccak_ready
);

//状态机
    reg [1:0] state_reg,state_nxt;

    localparam IDLE = 2'b00;//空闲状态
    localparam START = 2'b01;//开始状态
    localparam RUN  = 2'b10;//运行状态
    localparam WAIT = 2'b11;//等待hash状态


    reg [`UINST_ADDR_WIDTH-1:0] upc_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            upc_reg <= `UINST_ADDR_WIDTH'b0;
        else
            upc_reg <= upc;
    end


    // reg [7:0] stall_cnt;

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn)
    //         stall_cnt <= 8'b0;
    //     else if(state_reg == WAIT)
    //         stall_cnt <= stall_cnt + 1'b1;
    //     else
    //         stall_cnt <= 8'b0;
    // end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            state_reg <= IDLE;
        else
            state_reg <= state_nxt;
    end

    always @(*) begin
        state_nxt = state_reg;
        case (state_reg)
            IDLE: begin
                if(start)
                    state_nxt = START;
                else
                    state_nxt = IDLE;
            end
            START: begin
                state_nxt = RUN;
            end
            RUN: begin
                if(stall)
                    state_nxt = WAIT;
                else if(done)
                    state_nxt = IDLE;
                else
                    state_nxt = RUN;
            end
            WAIT: begin
                if(keccak_ready)
                    state_nxt = RUN;
            end
        endcase
    end

//640安全等级下,loop_1
    reg [2:0] flag_cnt;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            flag_cnt <= 3'b0;
        else if(state_reg == RUN && upc_st[2] && upc_st[1:0] == 2'b10)begin
            if(flag_cnt == 3'd4)
                flag_cnt <= 3'b0;
            else
                flag_cnt <= flag_cnt + 1'b1;
        end
        else if(state_reg == IDLE)
            flag_cnt <= 3'b0;
    end



//循环计数
    wire [11:0] cnt_0_nxt;
    wire [7:0] cnt_1_nxt,cnt_2_nxt,cnt_3_nxt;
    reg [11:0] loop_0_cnt;
    reg [7:0] loop_1_cnt,loop_2_cnt,loop_3_cnt;

    assign cnt_0_nxt = loop_0_cnt - 1'b1;
    assign cnt_1_nxt = loop_1_cnt - 1'b1;
    assign cnt_2_nxt = loop_2_cnt - 1'b1;
    assign cnt_3_nxt = loop_3_cnt - 1'b1;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            loop_0_cnt <= 12'b0;
            loop_1_cnt <= 8'b0;
            loop_2_cnt <= 8'b0;
            loop_3_cnt <= 8'b0;
        end
        else if(state_reg == RUN)begin
            if(upc_st[2])begin
                case (upc_st[1:0])
                    2'b00: begin
                        loop_0_cnt <= loop_0;
                    end
                    2'b01: begin
                        //loop_1_cnt <= loop_1;
                        if(!flag15to8)
                            loop_1_cnt <= loop_1;
                        else if(flag_cnt == lut_flag)
                            loop_1_cnt <= 8'd180;
                        else
                            loop_1_cnt <= 8'd179;
                    end
                    2'b10: begin
                        loop_2_cnt <= loop_2;
                    end
                    2'b11: begin
                        loop_3_cnt <= loop_3;
                    end
                endcase
            end
            else if(upc_up[2])begin
                case (upc_up[1:0])
                    2'b00: begin
                        loop_0_cnt <= cnt_0_nxt;
                    end
                    2'b01: begin
                        loop_1_cnt <= cnt_1_nxt;
                    end
                    2'b10: begin
                        loop_2_cnt <= cnt_2_nxt;
                    end
                    2'b11: begin
                        loop_3_cnt <= cnt_3_nxt;
                    end
                endcase
            end
        end
        else if(state_reg == IDLE)begin
            loop_0_cnt <= 11'b0;
            loop_1_cnt <= 8'b0;
            loop_2_cnt <= 8'b0;
            loop_3_cnt <= 8'b0;
        end
    end



    reg [`UINST_ADDR_WIDTH-1:0] upc_nxt;
    reg [`UINST_ADDR_WIDTH-1:0] upc_reg_0,upc_reg_1,upc_reg_2,upc_reg_3;

//寄存upc
    always@(posedge clk or negedge rstn) begin
        if(!rstn)begin
            upc_reg_0 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_1 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_2 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_3 <= `UINST_ADDR_WIDTH'b0;
        end
        else if(state_reg == RUN)begin
            if(upc_st[2])begin
                case (upc_st[1:0])
                    2'b00: begin
                        upc_reg_0 <= upc_reg;
                    end
                    2'b01: begin
                        upc_reg_1 <= upc_reg;
                    end
                    2'b10: begin
                        upc_reg_2 <= upc_reg;
                    end
                    2'b11: begin
                        upc_reg_3 <= upc_reg;
                    end
                endcase
            end
        end
        else if(state_reg == IDLE)begin
            upc_reg_0 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_1 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_2 <= `UINST_ADDR_WIDTH'b0;
            upc_reg_3 <= `UINST_ADDR_WIDTH'b0;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            upc <= `UINST_ADDR_WIDTH'b0;
        else
            upc <= upc_nxt;
    end
//upc更新
    always @(*) begin
        upc_nxt = upc;
        case (state_reg)
            IDLE: begin
                upc_nxt = `UINST_ADDR_WIDTH'b0;
            end
            START: begin
                upc_nxt = upc_start;
            end
            RUN: begin
                if(upc_up[2])begin
                    case (upc_up[1:0])
                        2'b00: begin
                            if(cnt_0_nxt)begin
                                upc_nxt = upc_reg_0;
                            end
                            else begin
                                upc_nxt = upc + 1'b1;
                            end
                        end
                        2'b01: begin
                            if(cnt_1_nxt)begin
                                upc_nxt = upc_reg_1;
                            end
                            else begin
                                upc_nxt = upc + 1'b1;
                            end
                        end
                        2'b10: begin
                            if(cnt_2_nxt)begin
                                upc_nxt = upc_reg_2;
                            end
                            else begin
                                upc_nxt = upc + 1'b1;
                            end
                        end
                        2'b11: begin
                            if(cnt_3_nxt)begin
                                upc_nxt = upc_reg_3;
                            end
                            else begin
                                upc_nxt = upc + 1'b1;
                            end
                        end
                    endcase
                end
                else begin
                    upc_nxt = upc + 1'b1;
                end
            end
            WAIT: begin
                upc_nxt = upc;
            end
            default: begin
                upc_nxt = upc;
            end
        endcase
    end




endmodule