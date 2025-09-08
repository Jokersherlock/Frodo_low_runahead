module Transpose (
    input                   clk,
    input                   rstn,
    input       [63:0]      rdata,
    input       [63:0]      wdata,
    input                   mode,//0为16位，1为8位
    input                   rbias_add,
    input                   wbias_add,
    output  reg [63:0]      output_data      
);
    reg [2:0] read_bias,write_bias;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            read_bias <= 3'b0;
        end
        else if(rbias_add)begin
            read_bias <= read_bias + 1'b1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            write_bias <= 3'b0;
        end
        else if(wbias_add)begin
            write_bias <= write_bias + 1'b1;
        end
    end
    reg [15:0] rdata_0;
    always @(*) begin
        if(mode == 1'b0)begin
            case(read_bias[1:0])
                2'b00: rdata_0 = rdata[15:0];
                2'b01: rdata_0 = rdata[31:16];
                2'b10: rdata_0 = rdata[47:32];
                2'b11: rdata_0 = rdata[63:48];
            endcase
        end
        else begin
            case (read_bias)
                3'b000: rdata_0 = {8'b0,rdata[7:0]};
                3'b001: rdata_0 = {8'b0,rdata[15:8]};
                3'b010: rdata_0 = {8'b0,rdata[23:16]};
                3'b011: rdata_0 = {8'b0,rdata[31:24]};
                3'b100: rdata_0 = {8'b0,rdata[39:32]};
                3'b101: rdata_0 = {8'b0,rdata[47:40]};
                3'b110: rdata_0 = {8'b0,rdata[55:48]};
                3'b111: rdata_0 = {8'b0,rdata[63:56]};
            endcase
        end
    end

    always @(*) begin
        output_data = wdata;
        if(mode==1'b0)begin
            case (write_bias[1:0])
                2'b00: output_data[15:0]  = rdata_0;
                2'b01: output_data[31:16] = rdata_0;
                2'b10: output_data[47:32] = rdata_0;
                2'b11: output_data[63:48] = rdata_0;
            endcase
        end
        else begin
            case (write_bias)
                3'b000: output_data[7:0] = rdata_0[7:0];
                3'b001: output_data[15:8] = rdata_0[7:0];
                3'b010: output_data[23:16] = rdata_0[7:0];
                3'b011: output_data[31:24] = rdata_0[7:0];
                3'b100: output_data[39:32] = rdata_0[7:0];
                3'b101: output_data[47:40] = rdata_0[7:0];
                3'b110: output_data[55:48] = rdata_0[7:0];
                3'b111: output_data[63:56] = rdata_0[7:0];
            endcase
        end
    end

endmodule