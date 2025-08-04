from mininst import MicrocodeAssembler

assembler = MicrocodeAssembler()
#右矩阵位宽为8，左矩阵位宽为16
multi_inst = [
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b1111,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#获取B地址
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b100,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#loop0,16
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#地址加一
    {'DONE':0,'UPC_UP' : 0b100,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0010,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#写地址加一，跳转
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':1,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#延迟槽写数据

    {'DONE':1,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0,'RBIAS_T':0,'WBIAS_T':0,'ABSORB':0,'HASH_AD':0,'INDEX_A':0,'INDEX_E':0b00,'D_BIA':0},#结束    

]


binary_codes = assembler.assemble_batch(multi_inst)

for i, code in enumerate(binary_codes):
    #print(f"指令{i+1}: {code} 长度={len(code)}bits")
    print(code)