from .mininst import MicrocodeAssembler

def get_hash_rnd_instructions():
    """获取哈希随机数生成微指令"""
    return [
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 1,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 1},
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},
        {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},
        {'DONE':1,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0},
    ]

def main():
    """主函数，用于单独测试"""
    assembler = MicrocodeAssembler()
    multi_inst = get_hash_rnd_instructions()
    binary_codes = assembler.assemble_batch(multi_inst)
    
    for i, code in enumerate(binary_codes):
        #print(f"指令{i+1}: {code} 长度={len(code)}bits")
        print(code)

if __name__ == "__main__":
    main()
