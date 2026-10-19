from .mininst import MicrocodeAssembler

def get_matmul_instructions():
    """获取矩阵乘法微指令"""
    return [
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b1111,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#地址清0，hash复位
    {'DONE':0,'UPC_ST' : 0b101,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop0,循环数为8
    {'DONE':0,'UPC_ST' : 0b100,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#loop1,循环数为n
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0101,'MACS_EN' : 1,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#macs使能,S,E地址加
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b1000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':1,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#这个周期算完,写
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b100,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0111,'MACS_EN' : 1,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#这个周期下一组数据到了macs使能，跳转,S,E,B地址加
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b1000,'MACS_EN' : 1,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':1,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#这个周期算完，写数据

    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b101,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#跳转
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#空周期

    {'DONE':1,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN':0,'A_INDEX':0b00,'LOAD_EN':0,'CONSUME_EN':0},#结束
    ]

def main():
    """主函数，用于单独测试"""
    assembler = MicrocodeAssembler()
    multi_inst = get_matmul_instructions()
    binary_codes = assembler.assemble_batch(multi_inst)
    
    for i, code in enumerate(binary_codes):
        #print(f"指令{i+1}: {code} 长度={len(code)}bits")
        print(code)

if __name__ == "__main__":
    main()