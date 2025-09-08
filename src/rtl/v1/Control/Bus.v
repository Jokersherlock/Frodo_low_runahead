module Bus 
#(
    parameter ADDR_WIDTH = 12
)(
    input       [ADDR_WIDTH+1:0]    A_addr,
    input       [ADDR_WIDTH+1:0]    B_addr,
    input       [ADDR_WIDTH+1:0]    C_addr_origin,
    input       [ADDR_WIDTH+1:0]    D_addr_origin,
    input                           C_bia,
    input                           D_bia,
    input       [ADDR_WIDTH-1:0]    control_addr,
    input                           control_addr_en,
    input       [ADDR_WIDTH-1:0]    uinst_addr,
    input                           uinst_addr_en,

    output reg  [ADDR_WIDTH-1:0]    mem0_addr_0,
    output reg  [ADDR_WIDTH-1:0]    mem0_addr_1,
    output reg  [ADDR_WIDTH-1:0]    mem1_addr_0,
    output reg  [ADDR_WIDTH-1:0]    mem1_addr_1,

    input       [63:0]              mem0_rd_data_0,
    input       [63:0]              mem0_rd_data_1,
    input       [63:0]              mem1_rd_data_0,
    input       [63:0]              mem1_rd_data_1,

    output reg  [63:0]              A_data,
    output reg  [63:0]              B_data,
    output reg  [63:0]              C_data
);

    wire [ADDR_WIDTH+1:0] D_addr,C_addr;
    assign D_addr = D_bia ? D_addr_origin + 1'b1 : D_addr_origin;
    assign C_addr = C_bia ? C_addr_origin + 1'b1 : C_addr_origin;


    // 将地址转译到对应的RAM
    always @(*) begin
        if(control_addr_en)begin
            mem0_addr_0 = control_addr;
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b00) begin
            mem0_addr_0 = D_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem0_addr_0 = C_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b01) begin
            mem0_addr_1 = D_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem0_addr_1 = C_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(uinst_addr_en)begin
            mem1_addr_0 = uinst_addr;
        end
        else if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b10) begin
            mem1_addr_0 = D_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem1_addr_0 = C_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        if(B_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = B_addr[ADDR_WIDTH-1:0];
        end
        else if(A_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = A_addr[ADDR_WIDTH-1:0];
        end
        else if(D_addr[ADDR_WIDTH+1:ADDR_WIDTH] == 2'b11) begin
            mem1_addr_1 = D_addr[ADDR_WIDTH-1:0];
        end
        else begin
            mem1_addr_1 = C_addr[ADDR_WIDTH-1:0];
        end
    end

    always @(*) begin
        case (A_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00:begin
                A_data = mem0_rd_data_0;
            end
            2'b01:begin
                A_data = mem0_rd_data_1;
            end
            2'b10:begin
                A_data = mem1_rd_data_0;
            end
            2'b11:begin
                A_data = mem1_rd_data_1;
            end
        endcase    
    end

    always @(*) begin
        case (B_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00:begin
                B_data = mem0_rd_data_0;
            end
            2'b01:begin
                B_data = mem0_rd_data_1;
            end
            2'b10:begin
                B_data = mem1_rd_data_0;
            end
            2'b11:begin
                B_data = mem1_rd_data_1;
            end
        endcase    
    end

    always @(*) begin
        case (C_addr[ADDR_WIDTH+1:ADDR_WIDTH])
            2'b00:begin
                C_data = mem0_rd_data_0;
            end
            2'b01:begin
                C_data = mem0_rd_data_1;
            end
            2'b10:begin
                C_data = mem1_rd_data_0;
            end
            2'b11:begin
                C_data = mem1_rd_data_1;
            end
        endcase    
    end



    
endmodule