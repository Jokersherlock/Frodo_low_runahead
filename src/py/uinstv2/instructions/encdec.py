from .mininst import MicrocodeAssembler

def get_encdec_instructions():
    """获取A矩阵乘法微指令"""
    return [
    {'DONE':0,'UPC_ST' : 0b100,'UPC_UP' : 0b000,'ADDR_CLR' : 0b1001,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop0,4,获取首地址
    {'DONE':0,'UPC_ST' : 0b101,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop1,16/2/3/4
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b101,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0001,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':1,'CONSUME_EN':0},#loop1跳转，输入
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期

    {'DONE':0,'UPC_ST' : 0b110,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop2,2/3/4/16
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b110,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b1000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':1},#loop2跳转，输出
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期

    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b100,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop1跳转
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期

    {'DONE':1,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#结束
    ]

def main():
    """主函数，用于单独测试"""
    assembler = MicrocodeAssembler()
    multi_inst = get_amatmul_instructions()
    binary_codes = assembler.assemble_batch(multi_inst)
    
    for i, code in enumerate(binary_codes):
        #print(f"指令{i+1}: {code} 长度={len(code)}bits")
        print(code)

if __name__ == "__main__":
    main()