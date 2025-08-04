module Frodo_top #(
    parameter INST_WIDTH = 28,
    parameter ADDR_WIDTH = 12
)(
    input                   clk,
    input                   rstn,
    input  [1:0]            level,
    input  [1:0]            mode,
    input                   start,
    output                  valid,

    input  [13:0]           load_addr,
    input  [63:0]           load_data,
    input  [13:0]           read_addr,
    input                   load_en,
    input                   read_en,

    output [63:0]           output_data
);

    wire [63:0] mem0_rd_data_0,mem0_rd_data_1,mem1_rd_data_0,mem1_rd_data_1;
    wire [ADDR_WIDTH-1:0] mem0_addr_0,mem0_addr_1,mem1_addr_0,mem1_addr_1;
    wire [ADDR_WIDTH-1:0] frodo_mem0_addr_0,frodo_mem0_addr_1,frodo_mem1_addr_0,frodo_mem1_addr_1;
    wire frodo_mem0_wr_en_0,frodo_mem0_wr_en_1,frodo_mem1_wr_en_0,frodo_mem1_wr_en_1;
    wire [63:0] frodo_mem_wr_data;
    wire [63:0] mem_wr_data;

    assign mem0_addr_0 = load_en   ? load_addr[11:0]  :
                         read_en   ? read_addr[11:0]  :
                                                    frodo_mem0_addr_0;
    assign mem0_addr_1 = load_en   ? load_addr[11:0]  :
                         read_en   ? read_addr[11:0]  :
                                                    frodo_mem0_addr_1;
    assign mem1_addr_0 = load_en   ? load_addr[11:0]  :
                         read_en   ? read_addr[11:0]  :
                                                    frodo_mem1_addr_0;
    assign mem1_addr_1 = load_en   ? load_addr[11:0]  :
                         read_en   ? read_addr[11:0]  :
                                                    frodo_mem1_addr_1;

    assign mem0_wr_en_0 = (load_en && load_addr[13:12] == 2'b00) ? 1'b1 : frodo_mem0_wr_en_0;
    assign mem0_wr_en_1 = (load_en && load_addr[13:12] == 2'b01) ? 1'b1 : frodo_mem0_wr_en_1;
    assign mem1_wr_en_0 = (load_en && load_addr[13:12] == 2'b10) ? 1'b1 : frodo_mem1_wr_en_0;
    assign mem1_wr_en_1 = (load_en && load_addr[13:12] == 2'b11) ? 1'b1 : frodo_mem1_wr_en_1;

    assign mem_wr_data  = load_en ? load_data : frodo_mem_wr_data;

    Frodo u_Frodo (
        .clk(clk),
        .rstn(rstn),
        .level(level),
        .mode(mode),
        .start(start),
        .mem0_rd_data_0(mem0_rd_data_0),
        .mem0_rd_data_1(mem0_rd_data_1),
        .mem1_rd_data_0(mem1_rd_data_0),
        .mem1_rd_data_1(mem1_rd_data_1),
        .mem0_addr_0(frodo_mem0_addr_0),
        .mem0_addr_1(frodo_mem0_addr_1),
        .mem1_addr_0(frodo_mem1_addr_0),
        .mem1_addr_1(frodo_mem1_addr_1),
        .mem0_wr_en_0(frodo_mem0_wr_en_0),
        .mem0_wr_en_1(frodo_mem0_wr_en_1),
        .mem1_wr_en_0(frodo_mem1_wr_en_0),
        .mem1_wr_en_1(frodo_mem1_wr_en_1),
        .valid(valid), // 可外接
        .mem_wr_data(frodo_mem_wr_data)
    );


    ram0 u_ram0(
        .clka(clk),
        .wea(mem0_wr_en_0),
        .addra(mem0_addr_0),
        .dina(mem_wr_data),
        .douta(mem0_rd_data_0),
        .clkb(clk),
        .web(mem0_wr_en_1),
        .addrb(mem0_addr_1),
        .dinb(mem_wr_data),
        .doutb(mem0_rd_data_1)
    );

    ram1 u_ram1(
        .clka(clk),
        .wea(mem1_wr_en_0),
        .addra(mem1_addr_0),
        .dina(mem_wr_data),
        .douta(mem1_rd_data_0),
        .clkb(clk),
        .web(mem1_wr_en_1),
        .addrb(mem1_addr_1),
        .dinb(mem_wr_data),
        .doutb(mem1_rd_data_1)
    );

    reg read_en_reg;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            read_en_reg <= 1'b0;
        else
            read_en_reg <= read_en;
    end

    reg [1:0] ram_index;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            ram_index <= 2'b0;
        else
            ram_index <= read_addr[13:12];
    end



    assign output_data = read_en_reg ? (
        (ram_index == 2'b00) ? mem0_rd_data_0 :
        (ram_index == 2'b01) ? mem0_rd_data_1 :
        (ram_index == 2'b10) ? mem1_rd_data_0 :
        (ram_index == 2'b11) ? mem1_rd_data_1 :
        64'b0
    ) : 64'b0;

endmodule