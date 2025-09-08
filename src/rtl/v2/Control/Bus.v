module Bus(
    input clk,
    input rstn,

    input  [16:0] addr_0,addr_1,addr_2,//R0,R1,R2的地址
    input         R0_en,R1_en,R2_en,//R0,R1,R2的使能
    
    input  [63:0] mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1,

    output [63:0] R0_in,
    output [63:0] R1_in,
    output [63:0] R2_in,
    output [2:0]  R0_mask,
    output        R1_mask,

    output [11:0] mem0_rd_addr_0,mem0_rd_addr_1,mem1_rd_addr_0,mem1_rd_addr_1,

    input  [16:0] addr_3,//R3的地址
    input  [1:0]  R3_en,//R3的使能,00为不写使能,01写8位,10写16位,11写64位
    input  [63:0] R3_data,//R3的写数据
    output [7:0]  R3_mask,
    output        mem0_wr_en_0,mem0_wr_en_1,mem1_wr_en_0,mem1_wr_en_1
);
    wire [1:0] mem_index_0,mem_index_1,mem_index_2,mem_index_3;

    //地址首2位为ram号和端口号
    assign mem_index_0 = addr_0[16:15];
    assign mem_index_1 = addr_1[16:15];
    assign mem_index_2 = addr_2[16:15];
    assign mem_index_3 = addr_3[16:15];


    //考虑读存储器地址与数据的延迟，R0的mask
    reg [2:0] R0_mask_reg,R0_mask_reg_;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R0_mask_reg <= 3'b0;
            R0_mask_reg_ <= 3'b0;
        end
        else begin
            R0_mask_reg <= addr_0[2:0];
            R0_mask_reg_ <= R0_mask_reg;
        end
    end
    assign R0_mask = R0_mask_reg_;

    //考虑读存储器地址与数据的延迟，R1的mask
    reg R1_mask_reg,R1_mask_reg_;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            R1_mask_reg <= 1'b0;
            R1_mask_reg_ <= 1'b0;
        end
        else begin
            R1_mask_reg <= addr_1[2];
            R1_mask_reg_ <= R1_mask_reg;
        end
    end
    assign R1_mask = R1_mask_reg_;

    // R3的mask生成，根据R3_en和地址低位生成字节使能信号，使用移位操作
    // R3地址和数据同步，不需要延迟处理
    wire [7:0] R3_mask_temp;
    assign R3_mask_temp = (R3_en == 2'b00) ? 8'b00000000 :  // 不写使能
                          (R3_en == 2'b01) ? (8'b00000001 << addr_3[2:0]) :  // 写8位，根据地址移位
                          (R3_en == 2'b10) ? (8'b00000011 << (addr_3[2:1] << 1)) :  // 写16位，根据地址移位
                          8'b11111111;  // 写64位
    assign R3_mask = R3_mask_temp;

    // 根据mem_index为存储器地址输出赋值，优先级R0>R3>R1>R2，考虑使能信号
    // mem0_rd_addr_0: mem_index=2'b00时被选中
    assign mem0_rd_addr_0 = (R0_en && mem_index_0 == 2'b00) ? addr_0[14:3] :
                            (R3_en != 2'b00 && mem_index_3 == 2'b00) ? addr_3[14:3] :
                            (R1_en && mem_index_1 == 2'b00) ? addr_1[14:3] :
                            (R2_en && mem_index_2 == 2'b00) ? addr_2[14:3] :
                            12'b0;
    
    // mem0_rd_addr_1: mem_index=2'b01时被选中
    assign mem0_rd_addr_1 = (R0_en && mem_index_0 == 2'b01) ? addr_0[14:3] :
                            (R3_en != 2'b00 && mem_index_3 == 2'b01) ? addr_3[14:3] :
                            (R1_en && mem_index_1 == 2'b01) ? addr_1[14:3] :
                            (R2_en && mem_index_2 == 2'b01) ? addr_2[14:3] :
                            12'b0;
    
    // mem1_rd_addr_0: mem_index=2'b10时被选中
    assign mem1_rd_addr_0 = (R0_en && mem_index_0 == 2'b10) ? addr_0[14:3] :
                            (R3_en != 2'b00 && mem_index_3 == 2'b10) ? addr_3[14:3] :
                            (R1_en && mem_index_1 == 2'b10) ? addr_1[14:3] :
                            (R2_en && mem_index_2 == 2'b10) ? addr_2[14:3] :
                            12'b0;
    
    // mem1_rd_addr_1: mem_index=2'b11时被选中
    assign mem1_rd_addr_1 = (R0_en && mem_index_0 == 2'b11) ? addr_0[14:3] :
                            (R3_en != 2'b00 && mem_index_3 == 2'b11) ? addr_3[14:3] :
                            (R1_en && mem_index_1 == 2'b11) ? addr_1[14:3] :
                            (R2_en && mem_index_2 == 2'b11) ? addr_2[14:3] :
                            12'b0;

    // 根据mem_index选择存储器数据，优先级R0>R3>R1>R2，考虑使能信号
    wire [63:0] mem_data_0, mem_data_1, mem_data_2;
    
    // 为每个地址选择对应的存储器数据，只有当使能信号有效时才选择数据
    assign mem_data_0 = R0_en ? ((mem_index_0 == 2'b00) ? mem0_rd_data_0 :
                                 (mem_index_0 == 2'b01) ? mem0_rd_data_1 :
                                 (mem_index_0 == 2'b10) ? mem1_rd_data_0 :
                                 mem1_rd_data_1) : 64'b0;
                        
    assign mem_data_1 = R1_en ? ((mem_index_1 == 2'b00) ? mem0_rd_data_0 :
                                 (mem_index_1 == 2'b01) ? mem0_rd_data_1 :
                                 (mem_index_1 == 2'b10) ? mem1_rd_data_0 :
                                 mem1_rd_data_1) : 64'b0;
                        
    assign mem_data_2 = R2_en ? ((mem_index_2 == 2'b00) ? mem0_rd_data_0 :
                                 (mem_index_2 == 2'b01) ? mem0_rd_data_1 :
                                 (mem_index_2 == 2'b10) ? mem1_rd_data_0 :
                                 mem1_rd_data_1) : 64'b0;
    
    // 优先级分配：R0>R3>R1>R2，考虑使能信号
    // 如果多个寄存器需要同一个存储器端口，优先级高的获得数据，优先级低的获得0
    // 如果寄存器使能无效，则直接输出0
    assign R0_in = R0_en ? mem_data_0 : 64'b0;
    assign R1_in = R1_en ? (((R0_en && mem_index_1 == mem_index_0) || (R3_en != 2'b00 && mem_index_1 == mem_index_3)) ? 64'b0 : mem_data_1) : 64'b0;
    assign R2_in = R2_en ? (((R0_en && mem_index_2 == mem_index_0) || (R3_en != 2'b00 && mem_index_2 == mem_index_3) || (R1_en && mem_index_2 == mem_index_1)) ? 64'b0 : mem_data_2) : 64'b0;

    // 存储器写使能信号生成，优先级R0>R3>R1>R2
    assign mem0_wr_en_0 = (R3_en != 2'b00 && mem_index_3 == 2'b00) ? 1'b1 : 1'b0;
    assign mem0_wr_en_1 = (R3_en != 2'b00 && mem_index_3 == 2'b01) ? 1'b1 : 1'b0;
    assign mem1_wr_en_0 = (R3_en != 2'b00 && mem_index_3 == 2'b10) ? 1'b1 : 1'b0;
    assign mem1_wr_en_1 = (R3_en != 2'b00 && mem_index_3 == 2'b11) ? 1'b1 : 1'b0;

endmodule