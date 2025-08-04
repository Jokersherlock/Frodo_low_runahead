module AGU 
#(
    parameter ADDR_WIDTH = 12
)(  
    input                           clk,
    input                           rstn,
    input       [3:0]               add_en,
    input       [3:0]               stride,
    input       [3:0]               clr_en, 
    input       [ADDR_WIDTH+1:0]    A_addr_start,
    input       [ADDR_WIDTH+1:0]    B_addr_start,
    input       [ADDR_WIDTH+1:0]    C_addr_start,
    input       [ADDR_WIDTH+1:0]    D_addr_start,
    input       [11:0]              hash_addr,
    input       [2:0]               hash_bias,
    input                           hash_width,
    input                           B_hash_en,

    output reg  [ADDR_WIDTH+1:0]    A_addr,
    output reg  [ADDR_WIDTH+1:0]    B_addr,
    output reg  [ADDR_WIDTH+1:0]    C_addr,
    output reg  [ADDR_WIDTH+1:0]    D_addr
);

wire [ADDR_WIDTH-1:0] A_addr_tb,B_addr_tb,C_addr_tb,D_addr_tb;
assign A_addr_tb = A_addr[ADDR_WIDTH-1:0];
assign B_addr_tb = B_addr[ADDR_WIDTH-1:0];
assign C_addr_tb = C_addr[ADDR_WIDTH-1:0];
assign D_addr_tb = D_addr[ADDR_WIDTH-1:0];

wire [ADDR_WIDTH+1 : 0] B_hash,D_hash;
assign B_hash = B_addr_start + hash_addr;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            A_addr <= {(ADDR_WIDTH+2){1'b0}};
        end
        else if(clr_en[0]) begin
            A_addr <= A_addr_start;
        end
        else if(add_en[0])begin
            // if(stride[0])begin
            //     A_addr[ADDR_WIDTH+1:1] <= A_addr[ADDR_WIDTH+1:1] + 1'b1;
            // end
            // else begin
                A_addr <= A_addr + 1'b1;
            //end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            B_addr <= {(ADDR_WIDTH+2){1'b0}};
        end
        else if(clr_en[1]) begin
            B_addr <= B_addr_start;
        end
        else if(B_hash_en)begin
            // if(hash_width)begin  // 16位数据
            //     if(hash_bias[2])begin
            //         B_addr <= B_hash + 1'b1;
            //     end
            //     else begin
            //         B_addr <= B_hash;
            //     end
            // end
            // else begin
            //     B_addr <= B_hash;
            // end
            B_addr <= B_hash;
        end
        else if(add_en[1])begin
            if(stride[1])begin
                B_addr[ADDR_WIDTH+1:1] <= B_addr[ADDR_WIDTH+1:1] + 1'b1;
            end
            else begin
                B_addr <= B_addr + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            C_addr <= {(ADDR_WIDTH+2){1'b0}};
        end
        else if(clr_en[2]) begin
            C_addr <= C_addr_start;
        end
        else if(add_en[2])begin
            if(stride[2])begin
                C_addr[ADDR_WIDTH+1:1] <= C_addr[ADDR_WIDTH+1:1] + 1'b1;
            end
            else begin
                C_addr <= C_addr + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            D_addr <= {(ADDR_WIDTH+2){1'b0}};
        end
        else if(clr_en[3]) begin
            D_addr <= D_addr_start;
        end
        else if(B_hash_en)begin
            //D_addr <= {B_addr[ADDR_WIDTH+1:0],~B_addr[ADDR_WIDTH],B_addr[ADDR_WIDTH-1:0]};
            D_addr <= {B_addr[ADDR_WIDTH+1],~B_addr[ADDR_WIDTH],B_hash[ADDR_WIDTH-1:0]};
        end
        else if(add_en[3])begin
            if(stride[3])begin
                D_addr[ADDR_WIDTH+1:1] <= D_addr[ADDR_WIDTH+1:1] + 1'b1;
            end
            else begin
                D_addr <= D_addr + 1'b1;
            end
        end
    end
    
endmodule