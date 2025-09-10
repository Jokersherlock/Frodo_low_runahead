class MicrocodeAssembler:
    def __init__(self):
        # 定义微指令字段结构（根据Control.v中的uinst定义）
        self.fields = {
            'DONE'      : {'bits':1,'offset':0},     # 微程序结束信号
            'UPC_ST'    : {'bits':3,'offset':1},     # 存储pc+1至寄存器
            'UPC_UP'    : {'bits':3,'offset':4},     # 更新pc至寄存器
            'ADDR_CLR'  : {'bits':4,'offset':7},     # AGU清除地址
            'ADDR_ADD'  : {'bits':4,'offset':11},    # AGU的地址增加
            'ADDR_CARRY': {'bits':3,'offset':15},    # AGU地址进位
            'MACS_EN'   : {'bits':1,'offset':18},    # MACS使能
            'DI_VALID'  : {'bits':1,'offset':19},    # hash输入使能
            'EX_EN'     : {'bits':1,'offset':20},    # hash执行使能,吸收/挤压
            'RAM_RESET' : {'bits':1,'offset':21},    # hash ram清0
            'DOUT_EN'   : {'bits':1,'offset':22},    # hash输出使能
            'STALL'     : {'bits':1,'offset':23},    # 等待hash运算
        }
        self.validate_field_structure()

    def validate_field_structure(self):
        """验证字段定义是否冲突"""
        used_bits = set()
        for field, config in self.fields.items():
            start = config['offset']
            end = start + config['bits']
            if any(bit in used_bits for bit in range(start, end)):
                raise ValueError(f"字段 {field} 存在位域冲突")
            used_bits.update(range(start, end))

    def assemble(self, microinstruction):
        """将微指令字典转换为二进制字符串"""
        binary = ['0'] * (max(f['offset'] + f['bits'] for f in self.fields.values()))
        
        for field, value in microinstruction.items():
            if field not in self.fields:
                raise ValueError(f"未定义的字段: {field}")
                
            config = self.fields[field]
            max_val = (1 << config['bits']) - 1
            if value > max_val:
                raise ValueError(f"字段 {field} 的值 {value} 超出 {config['bits']} 位限制")
            
            # 将数值转换为二进制字符串并填充到对应位置
            bin_str = format(value, f'0{config["bits"]}b')
            for i, bit in enumerate(bin_str):
                pos = config['offset'] + (config['bits'] - 1 - i)
                binary[pos] = bit
        
        return ''.join(binary[::-1])  # 反转得到标准二进制表示
    
    def assemble_batch(self, microinstructions):
        """批量转换多条微指令"""
        return [self.assemble(inst) for inst in microinstructions]

# # 使用示例
# assembler = MicrocodeAssembler()

# #matmul指令  8*1344(8bit) * 1344*8(16bit)
# #下面代码的注释 E = SB + E
# multi_inst = [
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b1111,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b100,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#记录第一层循环pc位置，并获取循环数
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b0100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':1,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':1,'LBIA_A':0,'ADDR_A':0b1100,'ADDR_C':0b0000,'STRIDE':0b0000},
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000},#空周期等待结果
#     {'DONE':0,'UPC_UP' : 0b100,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b1011,'ADDR_C':0b0000,'STRIDE':0b0010},#循环归位，左矩阵地址加2
#     {'DONE':0,'UPC_UP' : 0b000,'UPC_ST' : 0b000,'MAC_EN':0,'SBIA_A':0,'LBIA_A':0,'ADDR_A':0b0000,'ADDR_C':0b0000,'STRIDE':0b0000}#循环后接一个空操作
# ]

# # 批量转换
# binary_codes = assembler.assemble_batch(multi_inst)

# # 输出结果
# for i, code in enumerate(binary_codes):
#     #print(f"指令{i+1}: {code} 长度={len(code)}bits")
#     print(code)
