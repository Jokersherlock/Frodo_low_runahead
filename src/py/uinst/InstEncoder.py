class InstEncoder:
    def __init__(self):
        self.instruction_length = 28  # bits

    def encode(self, instr_type, **kwargs):
        if instr_type == "TRANS":
            return self.encode_TRANS(**kwargs)
        # 添加更多指令类型
        else:
            raise ValueError(f"Unknown instruction type: {instr_type}")

    def to_bin(self, value, bits):
        return format(value, f'0{bits}b')

    def encode_TRANS(self, Src, Dst, mode):
        # bit: 26-24 = 1 1 0
        # bit: 23-14 = Src (10 bits)
        # bit: 13-4 = Dst (10 bits)
        # bit: 3-0 = mode (4 bits)
        code = '110'
        code += self.to_bin(Src, 10)
        code += self.to_bin(Dst, 10)
        code += self.to_bin(mode, 4)
        return code
    
    def encode_ABSORB(self,Addr,Length,port):


# 🧪 使用示例
encoder = InstEncoder()
binary_instr = encoder.encode("TRANS", Src=0x1A3, Dst=0x0F4, mode=0b1010)
print("TRANS binary:", binary_instr)
