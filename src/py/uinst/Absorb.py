from mininst import MicrocodeAssembler

assembler = MicrocodeAssembler()
#右矩阵位宽为8，左矩阵位宽为16
multi_inst = [
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b100,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0010,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#获取第一轮循环数为数据bit数/64
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b101,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#获取第二轮循环数8
    {'DONE':0,'UPC_UP' : 0b101,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':1,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#输入数据,偏置加一
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#空延迟槽
    {'DONE':0,'UPC_UP' : 0b100,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0010,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#跳转，地址加一
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0},#空延迟槽
    {'DONE':1,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0}#结束
]


binary_codes = assembler.assemble_batch(multi_inst)

for i, code in enumerate(binary_codes):
    #print(f"指令{i+1}: {code} 长度={len(code)}bits")
    print(code)