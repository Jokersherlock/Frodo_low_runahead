import numpy as np
import sys
import os

# 添加当前目录到路径，以便导入模块
sys.path.append(os.path.dirname(__file__))

# 导入重构后的模块
from core.memory import Memory, MemoryData
from core.instruction_merger import InstructionMerger
from algorithms.keygen640 import Keygen640Generator
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
}

# 更新mem1中的指令地址
mem1.modify_word(8, opcode_to_address[0b1000])   # ABSORB
mem1.modify_word(9, opcode_to_address[0b1001])   # SQUEEZE
mem1.modify_word(10, opcode_to_address[0b1010])  # HASH_RND
mem1.modify_word(12, opcode_to_address[0b1100])  # SQUEEZE_STRM
mem1.modify_word(13, opcode_to_address[0b1101])  # ABSORB_BYTE

print("mem1更新完成:")
print(f"  ABSORB (0x8): 地址 {opcode_to_address[0b1000]}")
print(f"  SQUEEZE (0x9): 地址 {opcode_to_address[0b1001]}")
print(f"  HASH_RND (0xA): 地址 {opcode_to_address[0b1010]}")
print(f"  SQUEEZE_STRM (0xC): 地址 {opcode_to_address[0b1100]}")
print(f"  ABSORB_BYTE (0xD): 地址 {opcode_to_address[0b1101]}")

# 生成inst.bin文件
print("\n正在生成inst.bin文件...")

# 创建keygen640算法实例
keygen640 = Keygen640Generator()

# 创建指令合并器
merger = InstructionMerger()

# 添加keygen640算法到合并器
merger.add_algorithm(keygen640, "keygen640")

# 生成并保存inst.bin文件
output_file = merger.save_to_file(filename="inst.bin")

print(f"inst.bin文件已生成: {output_file}")
print(f"算法位置信息: {merger.get_algorithm_positions()}")



# 确保输出目录存在
os.makedirs("../../sim/hex", exist_ok=True)

mem0.export_to_file("./src/sim/hex/mem0.hex","hex")
mem1.export_to_file("./src/sim/hex/mem1.hex","hex")
