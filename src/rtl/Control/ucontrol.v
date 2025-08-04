module ucontrol 
#(
    parameter  UINST_ADDR_WIDTH = 9,
    parameter  UINST_WIDTH      = 32
)(
    input                               clk,
    input                               rstn,
    input                               start_pos,
    input       [UINST_ADDR_WIDTH-1:0]  upc_start,
    output  reg [UINST_ADDR_WIDTH-1:0]  upc,
    input                               flag15to8,
    input                               flag_clr,
    input       [2:0]                   lut_flag,

    input       [10:0]                  loop_0,
    input       [10:0]                  loop_1,
    input       [10:0]                  loop_2,
    input       [10:0]                  loop_3,
    input       [10:0]                  loop_4,

    input                               done,
    input       [2:0]                   upc_up,
    input       [2:0]                   upc_st
);  

    reg state;
    reg [10:0] loop_0_cnt,loop_1_cnt,loop_2_cnt,loop_3_cnt,loop_4_cnt;
    wire [10:0] cnt_0_nxt,cnt_1_nxt,cnt_2_nxt,cnt_3_nxt,cnt_4_nxt;
    reg [UINST_ADDR_WIDTH-1:0] upc_reg_0,upc_reg_1,upc_reg_2,upc_reg_3,upc_reg_4;
    // reg [7:0] pkh_lut,ss_lut;
    reg [3:0] flag_cnt;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            flag_cnt <= 3'b0;
        else if(flag_clr)begin
            flag_cnt <= 3'b0;
        end
        else if(upc_st[2] && upc_st[1:0] == 2'b10)begin
            if(flag_cnt == 3'd4)
                flag_cnt <= 3'b0;
            else
                flag_cnt <= flag_cnt + 1'b1;
        end
    end

    // always @(*) begin
    //     case(flag_cnt)
    //         3'b000:     pkh_lut = 8'd179;
    //         3'b001:     pkh_lut = 8'd179;
    //         3'b010:     pkh_lut = 8'd179;
    //         3'b011:     pkh_lut = 8'd179;
    //         3'b100:     pkh_lut = 8'd180;
    //         default:    pkh_lut = 8'd0;
    //     endcase
    // end

    // always @(*) begin
    //     case(flag_cnt)
    //         3'b000:     ss_lut = 8'd180;
    //         3'b001:     ss_lut = 8'd179;
    //         3'b010:     ss_lut = 8'd179;
    //         3'b011:     ss_lut = 8'd179;
    //         3'b100:     ss_lut = 8'd179;
    //         default:    ss_lut = 8'd0;
    //     endcase
    // end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            state <= 1'b0;
        end
        else begin
            if(!state)begin
                if(start_pos)begin
                    state <= 1'b1;
                end
            end
            else begin
                if(done)begin
                    state <= 1'b0;
                end
            end
        end
    end

    assign cnt_0_nxt = loop_0_cnt - 1'b1;
    assign cnt_1_nxt = loop_1_cnt - 1'b1;
    assign cnt_2_nxt = loop_2_cnt - 1'b1;
    assign cnt_3_nxt = loop_3_cnt - 1'b1;
    assign cnt_4_nxt = loop_4_cnt - 1'b1;



    reg [UINST_ADDR_WIDTH-1:0] upc_nxt;
    always @(posedge clk or negedge rstn)begin
        if(!rstn)begin
            upc <= 0;
        end
        else begin
            upc <= upc_nxt;
        end
    end

    always @(*) begin
       if(start_pos)begin
            upc_nxt = upc_start;
       end 
       else if(done)begin
            upc_nxt = 0;
       end
       else if(state)begin
            if(upc_up[2])begin
                case (upc_up[1:0])
                2'b00:begin
                    if(cnt_0_nxt)begin
                        upc_nxt = upc_reg_0;
                    end
                    else begin
                        upc_nxt = upc + 1'b1;
                    end
                end
                2'b01:begin
                    if(cnt_1_nxt)begin
                        upc_nxt = upc_reg_1;
                    end
                    else begin
                        upc_nxt = upc + 1'b1;
                    end
                end
                2'b10:begin
                    if(cnt_2_nxt)begin
                        upc_nxt = upc_reg_2;
                    end
                    else begin
                        upc_nxt = upc + 1'b1;
                    end
                end
                2'b11:begin
                    if(cnt_3_nxt)begin
                        upc_nxt = upc_reg_3;
                    end
                    else begin
                        upc_nxt = upc + 1'b1;
                    end
                end
                endcase
            end
            else if(upc_up == 3'b011)begin
                if(cnt_4_nxt)begin
                    upc_nxt = upc_reg_4;
                end
                else begin
                    upc_nxt = upc + 1'b1;
                end
            end
            else begin
                upc_nxt = upc + 1'b1;
            end 
       end
       else begin
            upc_nxt = upc;
       end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            upc_reg_0 <= 0;
            upc_reg_1 <= 0;
            upc_reg_2 <= 0;
            upc_reg_3 <= 0;
            upc_reg_4 <= 0;
        end
        else if(state)begin
            if(upc_st[2])begin
                case (upc_st[1:0])
                    2'b00: begin
                        upc_reg_0 <= upc;
                    end
                    2'b01: begin
                        upc_reg_1 <= upc;
                    end
                    2'b10: begin
                        upc_reg_2 <= upc;
                    end
                    2'b11: begin
                        upc_reg_3 <= upc;
                    end
                endcase
            end
            else if(upc_st == 3'b011)begin
                upc_reg_4 <= upc;
            end
        end
        else begin
            upc_reg_0 <= 0;
            upc_reg_1 <= 0;
            upc_reg_2 <= 0;
            upc_reg_3 <= 0;
            upc_reg_4 <= 0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            loop_0_cnt <= 11'b0;
            loop_1_cnt <= 11'b0;
            loop_2_cnt <= 11'b0;
            loop_3_cnt <= 11'b0;
            loop_4_cnt <= 11'b0;
        end
        else if(state)begin
            if(upc_st[2])begin
                case (upc_st[1:0])
                    2'b00: begin
                        loop_0_cnt <= loop_0;
                    end
                    2'b01: begin
                        loop_1_cnt <= loop_1;
                    end
                    2'b10: begin
                        //loop_2_cnt <= loop_2;
                        if(!flag15to8)
                            loop_2_cnt <= loop_2;
                        else if(flag_cnt == lut_flag)
                            loop_2_cnt <= 11'd180;
                        else
                            loop_2_cnt <= 11'd179;
                    end
                    2'b11:begin
                        loop_3_cnt <= loop_3;
                    end
                endcase
            end
            else if(upc_st == 3'b011)begin
                loop_4_cnt <= loop_4;
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
                    2'b11:begin
                        loop_3_cnt <= cnt_3_nxt;
                    end
                endcase
            end
            else if(upc_up == 3'b011)begin
                loop_4_cnt <= cnt_4_nxt;
            end
        end
        else begin
            loop_0_cnt <= 11'b0;
            loop_1_cnt <= 11'b0;
            loop_2_cnt <= 11'b0;
            loop_3_cnt <= 11'b0;
            loop_4_cnt <= 11'b0;
        end
    end
    



endmodule