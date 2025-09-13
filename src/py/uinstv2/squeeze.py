from mininst import MicrocodeAssembler

assembler = MicrocodeAssembler()

multi_inst = [
    {'DONE':0,'UPC_ST' : 0b100,'UPC_UP' : 0b000,'ADDR_CLR' : 0b1000,'ADDR_ADD' : 0b0000,'ADDR_CARRY' : 0b000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN' : 0},#记录PC,清0地址
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b100,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b1000,'ADDR_CARRY' : 0b000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 1,'STALL' : 0,'MEM_WEN' : 1},#写数据,地址加,跳转
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'ADDR_CARRY' : 0b000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN' : 0},#空延迟槽
    {'DONE':0,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'ADDR_CARRY' : 0b000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN' : 0},#空延迟槽
    {'DONE':1,'UPC_ST' : 0b000,'UPC_UP' : 0b000,'ADDR_CLR' : 0b0000,'ADDR_ADD' : 0b0000,'ADDR_CARRY' : 0b000,'MACS_EN' : 0,'DI_VALID' : 0,'EX_EN' : 0,'RAM_RESET' : 0,'DOUT_EN' : 0,'STALL' : 0,'MEM_WEN' : 0},#结束
]


binary_codes = assembler.assemble_batch(multi_inst)

for i, code in enumerate(binary_codes):
    #print(f"指令{i+1}: {code} 长度={len(code)}bits")
    print(code)