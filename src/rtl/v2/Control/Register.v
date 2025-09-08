module Register(
    input                   clk,
    input                   rstn,
    input       [63:0]      R0_in,R1_in,R2_in,R3_in,
    input       [2:0]       R0_mask,
    input                   R1_mask,
    input                   R0_inverse,
    
    output      [63:0]      R0_out,R1_out,R2_out,R3_out,
    output      [31:0]      R1_32,
    output reg  [15:0]      R0_16,
    output reg  [7:0]       R0_8
);

    reg [63:0] R0,R1,R2,R3;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            R0 <= 64'h0;
            R1 <= 64'h0;
            R2 <= 64'h0;
            R3 <= 64'h0;
        end
        else begin
            R0 <= R0_in;
            R1 <= R1_in;
            R2 <= R2_in;
            R3 <= R3_in;
        end
    end

    assign R0_out = R0;
    assign R1_out = R1;
    assign R2_out = R2;
    assign R3_out = R3;
    assign R1_32 = R1_mask ? R1[63:32] : R1[31:0];

    always@(*) begin
        case (R0_mask[2:1])
            3'b00: R0_16 = R0[15:0];
            2'b01: R0_16 = R0[31:16];
            2'b10: R0_16 = R0[47:32];
            2'b11: R0_16 = R0[63:48];
        endcase
    end

    always@(*) begin
        if(R0_inverse)begin
            R0_8 = R0_mask[0] ? R0_16[7:0] : R0_16[15:8];
        end
        else begin
            R0_8 = R0_mask[0] ? R0_16[15:8] : R0_16[7:0];
        end
    end

endmodule