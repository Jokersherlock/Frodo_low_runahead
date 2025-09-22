from .mininst import MicrocodeAssembler

def get_absorb_instructions():
    """获取吸收操作微指令"""
    return [
        {'DONE':0,'UPC_ST' : 0b100,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0001,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},#记录PC,清0地址
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b100,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0001,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},#地址加跳转
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},#空延迟槽
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 1,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},#数据在这一周期更新,hash输入使能
        {'DONE':1,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},#结束
    ]

def main():
    """主函数，用于单独测试"""
    assembler = MicrocodeAssembler()
    multi_inst = get_absorb_instructions()
    binary_codes = assembler.assemble_batch(multi_inst)
    
    for i, code in enumerate(binary_codes):
        #print(f"指令{i+1}: {code} 长度={len(code)}bits")
        print(code)

if __name__ == "__main__":
    main()