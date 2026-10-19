import numpy as np
import sys
import os

# 添加当前目录到路径，以便导入模块
sys.path.append(os.path.dirname(__file__))

# 导入重构后的模块
from core.memory import Memory, MemoryData
from core.instruction_merger import InstructionMerger
from algorithms.keygen640 import Keygen640Generator
from algorithms.encaps640 import Encaps640Generator
from algorithms.decaps640 import Decaps640Generator
from algorithms.keygen976 import Keygen976Generator
from algorithms.encaps976 import Encaps976Generator
from algorithms.decaps976 import Decaps976Generator
from algorithms.keygen1344 import Keygen1344Generator
from algorithms.encaps1344 import Encaps1344Generator
from algorithms.decaps1344 import Decaps1344Generator
from instructions.uinst_assembler import UinstAssembler


mem0 = Memory()
mem1 = Memory()

z_640 = '92F267AAFA3F87CA60D01CB54F29202A'
seedSE_640 = '2FD81A25CCB148032DCD739936737F2DB505D7CFAD1B497499323C8686325E47'

mem0.store_hex_string_little_endian(seedSE_640,0xfc1)
mem0.store_hex_string_little_endian(z_640,0xfc9)

# 生成uinst.bin文件
print("正在生成uinst.bin文件...")
uinst_assembler = UinstAssembler()

# 定义密钥生成序列（与算法无关的通用指令序列）
sequence = [
    'ABSORB_BYTE', # 吸收字节操作
    'HASH_RND',    # 哈希随机数生成
    'ABSORB',      # 吸收操作
    'SQUEEZE_STRM', # 挤压流操作
    'SQUEEZE',     # 挤压操作
    'AMATMUL',     # A矩阵乘法
    'ABSORB_STRM', # 流吸收
    'MATMUL',     # 矩阵乘法
    'ENCDEC',     # 编码/解码
    'MATADD',     # 矩阵加法
]

binary_codes, instruction_addresses = uinst_assembler.assemble_sequence(sequence)
uinst_assembler.save_to_bin(binary_codes,"uinst.bin")

print("指令首地址信息:")
for instruction_name, address in instruction_addresses.items():
    print(f"  {instruction_name}: 地址 {address}")

# 根据指令首地址更新mem1
# 指令操作码到地址的映射
opcode_to_address = {
    0b1000: instruction_addresses.get('ABSORB', 0),      # ABSORB
    0b1001: instruction_addresses.get('SQUEEZE', 0),     # SQUEEZE  
    0b1010: instruction_addresses.get('HASH_RND', 0),     # HASH_RND
    0b1100: instruction_addresses.get('SQUEEZE_STRM', 0), # SQUEEZE_STRM
    0b1101: instruction_addresses.get('ABSORB_BYTE', 0),  # ABSORB_BYTE
    0b0100: instruction_addresses.get('AMATMUL', 0),     # AMATMUL
    0b1011: instruction_addresses.get('ABSORB_STRM', 0), # ABSORB_STRM
    0b0010: instruction_addresses.get('MATMUL', 0),     # MATMUL
    0b0001: instruction_addresses.get('ENCDEC', 0),     # ENCDEC
    0b0101: instruction_addresses.get('MATADD', 0),     # MATADD
}

# 更新mem1中的指令地址（地址 = 操作码）
mem1.modify_word(0x1, opcode_to_address[0b0001])   # ENCDEC
mem1.modify_word(0x2, opcode_to_address[0b0010])   # MATMUL
mem1.modify_word(0x4, opcode_to_address[0b0100])   # AMATMUL
mem1.modify_word(0x5, opcode_to_address[0b0101])   # MATADD
mem1.modify_word(0x8, opcode_to_address[0b1000])    # ABSORB
mem1.modify_word(0x9, opcode_to_address[0b1001])    # SQUEEZE
mem1.modify_word(0xA, opcode_to_address[0b1010])   # HASH_RND
mem1.modify_word(0xB, opcode_to_address[0b1011])    # ABSORB_STRM
mem1.modify_word(0xC, opcode_to_address[0b1100])    # SQUEEZE_STRM
mem1.modify_word(0xD, opcode_to_address[0b1101])   # ABSORB_BYTE



# 更新mem0中的矩阵地址
mem0.modify_word(1, 0xfc9)   # seedA,z
mem0.modify_word(2, 0x1a81)   # S
mem0.modify_word(3, 0x3010)   # E
mem0.modify_word(4, 0x3a85)   # E"
mem0.modify_word(5, 0x0010)   # B
mem0.modify_word(6, 0x1fcb)   # u
mem0.modify_word(7, 0x0fcf)   # enu


print("mem1更新完成:")
print(f"  ENCDEC (0x1): 地址 {opcode_to_address[0b0001]}")
print(f"  MATMUL (0x2): 地址 {opcode_to_address[0b0010]}")
print(f"  AMATMUL (0x4): 地址 {opcode_to_address[0b0100]}")
print(f"  MATADD (0x5): 地址 {opcode_to_address[0b0101]}")
print(f"  ABSORB (0x8): 地址 {opcode_to_address[0b1000]}")
print(f"  SQUEEZE (0x9): 地址 {opcode_to_address[0b1001]}")
print(f"  HASH_RND (0xA): 地址 {opcode_to_address[0b1010]}")
print(f"  ABSORB_STRM (0xB): 地址 {opcode_to_address[0b1011]}")
print(f"  SQUEEZE_STRM (0xC): 地址 {opcode_to_address[0b1100]}")
print(f"  ABSORB_BYTE (0xD): 地址 {opcode_to_address[0b1101]}")

# 生成inst.bin文件
print("\n正在生成inst.bin文件...")

# 创建keygen640算法实例
keygen640 = Keygen640Generator()
encaps640 = Encaps640Generator()
decaps640 = Decaps640Generator()
keygen976 = Keygen976Generator()
encaps976 = Encaps976Generator()
decaps976 = Decaps976Generator()
keygen1344 = Keygen1344Generator()
encaps1344 = Encaps1344Generator()
decaps1344 = Decaps1344Generator()



# 创建指令合并器
merger = InstructionMerger()

# 添加keygen640算法到合并器
merger.add_algorithm(keygen640, "keygen640")
merger.add_algorithm(encaps640, "encaps640")
merger.add_algorithm(decaps640, "decaps640")
merger.add_algorithm(keygen976, "keygen976")
merger.add_algorithm(encaps976, "encaps976")
merger.add_algorithm(decaps976, "decaps976")
merger.add_algorithm(keygen1344, "keygen1344")
merger.add_algorithm(encaps1344, "encaps1344")
merger.add_algorithm(decaps1344, "decaps1344")

# 生成并保存inst.bin文件
output_file = merger.save_to_file(filename="inst.bin")

print(f"inst.bin文件已生成: {output_file}")
print(f"算法位置信息: {merger.get_algorithm_positions()}")



# 确保输出目录存在
os.makedirs("../../sim/hex", exist_ok=True)

mem0.export_to_file("./src/sim/hex/mem0.hex","hex")
mem1.export_to_file("./src/sim/hex/mem1.hex","hex")
