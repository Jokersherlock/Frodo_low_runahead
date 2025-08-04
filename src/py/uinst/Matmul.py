from mininst import MicrocodeAssembler

assembler = MicrocodeAssembler()
#右矩阵位宽为8，左矩阵位宽为16
multi_inst = [
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b1111,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#数据地址清0
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b100,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#第一层循环，循环数为安全等级
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b101,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#第二层循环,循环数为2
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b110,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#第三层循环，循环数为4
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b0100,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#加矩阵地址偏置加一
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b1000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':1},#写矩阵地址加一
    {'DONE':0,'UPC_UP' : 0b110,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':1,'ADDR_A':0b0100,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#加矩阵地址加一，左矩阵偏置加一准备跳转
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b1000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':1},#延迟槽写数据
    {'DONE':0,'UPC_UP' : 0b101,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0010,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#第二次跳转，左矩阵地址加一
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#空延迟槽
    {'DONE':0,'UPC_UP' : 0b100,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0001,'ADDR_C':0b1100,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#第三次跳转，右矩阵地址加一，写、加矩阵地址清0
    {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#延迟槽
    {'DONE':1,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000,'TRANS':0,'HASH_DI':0,'SQUEEZE':0,'RAM_RES':0,'DOUT_EN':0,'MEM_WEN':0},#结束
]


binary_codes = assembler.assemble_batch(multi_inst)

for i, code in enumerate(binary_codes):
    #print(f"指令{i+1}: {code} 长度={len(code)}bits")
    print(code)