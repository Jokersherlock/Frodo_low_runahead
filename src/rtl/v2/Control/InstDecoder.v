`include "global_define.v"
module InstDecoder (
    input clk,
    input rstn,

    input      [`INST_WIDTH-1:0]            inst,
    input                                   inst_valid,
    input                                   done,

    
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

    output reg  [2:0]                       R0_mask,
    output reg                              R1_mask,
    output reg                              R0_inverse,

    output reg                              macs_mode,
    output reg                              macs_signal,

    output reg   [10:0]                     di_len,
    output reg                              Hash_lev,

    output reg                              R0_en,R1_en,R2_en,
    output reg   [1:0]                      R3_en
);

    localparam IDLE   = 3'b000;
    localparam IF     = 3'b001;
    localparam ID     = 3'b010;
    localparam EX     = 3'b011;
    localparam FINISH = 3'b100;

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





endmodule
