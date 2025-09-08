module driver (
    input               clk,
    input               rstn,
    input               finish,
    input               switch,
    output              start,
    output reg[11:0]    load_addr,
    output reg[11:0]    read_addr,
    output reg [2:0]    state,
    output reg [3:0]    mode_reg
);

    parameter  IDLE     = 3'b000;
    parameter  SWITCH   = 3'b001;
    parameter  FINISH   = 3'b010;
    parameter  LOAD     = 3'b100;
    parameter  START    = 3'b101;
    parameter  EX       = 3'b110;
    parameter  VERIFY   = 3'b111;

    reg switch_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            switch_reg <= 1'b0;
        else
            switch_reg <= switch;
    end
    wire switch_pos;
    assign switch_pos = switch & (~switch_reg);
    


    reg [2:0] state_nxt;
    assign start = state == START;
    always @(*) begin
        case (state)
            IDLE:begin
                if(switch_pos)
                    state_nxt = SWITCH;
                else
                    state_nxt = IDLE;
            end
            SWITCH:
                state_nxt = LOAD;
            LOAD:begin
                if(load_addr == 12'h005)//keygen640
                    state_nxt = START;
                else if(load_addr == 12'h00d)//encap640
                    state_nxt = START;
                else if(load_addr == 12'h01d)//decap640
                    state_nxt = START;
                else if(load_addr == 12'h025)//keygen976
                    state_nxt = START;
                else if(load_addr == 12'h030) //encap976
                    state_nxt = START;
                else if(load_addr == 12'h040)//decap976
                    state_nxt = START;
                else if(load_addr == 12'h04a)//keygen1344
                    state_nxt = START;
                else if(load_addr == 12'h058)//encap1344
                    state_nxt = START;
                else if(load_addr == 12'h068)//decap1344
                    state_nxt = START;
                else
                    state_nxt = LOAD;
            end
            START:begin
                state_nxt = EX;
            end
            EX: begin
                if(finish)begin
                    //state_nxt = EX;
                    state_nxt = VERIFY;
                end
                else 
                    state_nxt = EX;
            end
            VERIFY:begin
                if(read_addr == 12'h001)//keygen640
                    state_nxt = FINISH;
                else if(read_addr == 12'h003)//encap640
                    state_nxt = FINISH;
                else if(read_addr == 12'h007)//decap640
                    state_nxt = FINISH;
                else if(read_addr == 12'h00a)//keygen976
                    state_nxt = FINISH;
                else if(read_addr == 12'h00d)//encap976
                    state_nxt = FINISH;
                else if(read_addr == 12'h013)//decap976
                    state_nxt = FINISH;
                else if(read_addr == 12'h017)//keygen1344
                    state_nxt = FINISH;
                else if(read_addr == 12'h01b)//encap1344
                    state_nxt = FINISH;
                else if(read_addr == 12'h023)//decap1344
                    state_nxt = FINISH;
                // else if(read_addr == 12'h037)
                //     state_nxt = FINISH;
                // else if(read_addr ==12'h053)
                //     state_nxt = FINISH;
                else
                    state_nxt = VERIFY;
            end
            FINISH:
                state_nxt = IDLE;
            default:
                state_nxt = IDLE;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            state <= IDLE;
        end
        else begin
            state <= state_nxt;
        end
    end

    //reg [3:0] mode_reg;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            mode_reg <= 4'd0;
        else if(state == FINISH)begin
            if(mode_reg == 4'd8)
                mode_reg <= 4'b0;
            else
                mode_reg <= mode_reg + 1'b1;
        end
    end


    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            //load_addr <= 12'b0;
            //load_addr <= 12'h00e;
            load_addr <= 12'h0;
        end
        else if(state == SWITCH)begin
            case(mode_reg)
                4'd0: load_addr <= 12'h000;//keygen-640
                4'd1: load_addr <= 12'h006;//encap-640
                4'd2: load_addr <= 12'h00e;//decap-640
                4'd3: load_addr <= 12'h01e;//keygen-976
                4'd4: load_addr <= 12'h026;//encap-976
                4'd5: load_addr <= 12'h031;//decap-976
                4'd6: load_addr <= 12'h041;//keygen-1344
                4'd7: load_addr <= 12'h04b;//encap-1344
                4'd8: load_addr <= 12'h059;//decap-1344
            default : load_addr <= 12'h000; 
            endcase
        end
        else if(state==LOAD)begin
            load_addr <= load_addr + 1'b1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            read_addr <= 12'h000;
        end
        else if(state == SWITCH)begin
            case(mode_reg)
                4'd0: read_addr <= 12'h000;
                4'd1: read_addr <= 12'h002;
                4'd2: read_addr <= 12'h004;
                4'd3: read_addr <= 12'h008;
                4'd4: read_addr <= 12'h00b;
                4'd5: read_addr <= 12'h00e;
                4'd6: read_addr <= 12'h014;
                4'd7: read_addr <= 12'h018;
                4'd8: read_addr <= 12'h01c;
                //4'd8: read_addr <= 12'h038;
            default : read_addr <= 12'h000; 
            endcase
        end
        else if(state==VERIFY)begin
            read_addr <= read_addr + 1'b1;
        end
    end
    

    // reg [3:0] sim_switch;

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn)begin
    //         sim_switch = 4'b0;
    //     end
    //     else if(state == start)begin
    //         if(sim_switch == 4'd8)
    //             sim_switch <= 4'd0;
    //         else
    //             sim_switch <= sim_switch + 1'b1;
    //     end
    // end

    // always @(posedge clk or negedge rstn) begin
    //     if(!rstn)begin
    //         level <= 2'b0;
    //     end
    //     else begin
    //         if(sim_switch == 3'd0 || sim_switch == 3'd1 || sim_switch == 3'd2)
    //             level <= 2'b11;
    //         else if(sim_switch == 3'd3 || sim_switch == 3'd4 || sim_switch == 3'd5)
    //             level <= 2'b10;
    //         else if(sim_swicth == 3'd6 || sim_swicth == 3'd)
    //     end
    // end




endmodule