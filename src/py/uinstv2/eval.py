from memory import MemoryReader
import numpy as np
from hash2mat import hex_string_to_matrix


reader_0 = MemoryReader('sim/hex/mem0_output.hex','hex')
#print(S)
#S = S.T
reader_1 = MemoryReader('sim/hex/mem1_output.hex','hex')
#reader_1 = MemoryReader('sim/RAM/final/mem1_decap.hex','hex')
# reader_0 = MemoryReader('sim/RAM/final/mem0_Bprime.hex','hex')

S = reader_0.read_matrix(0xA81,640,8,8)
S = np.array(S)
#S = S.T
S_ref = np.loadtxt('py/uinstv2/data/S_matrix_640.txt', dtype=np.int32)

# 比较S和S_ref
S_equal = (S == S_ref)
print("S == S_ref:")
print(S_equal)

# 获取不相同的个数
# S_different_count = np.sum(~S_equal)
# print(f"S中不相同的元素个数: {S_different_count}")
# print(f"S中总元素个数: {S.size}")
# print(f"S中相同的元素个数: {S.size - S_different_count}")
# print(f"S的匹配率: {(S.size - S_different_count) / S.size * 100:.2f}%")
# print()


E = reader_0.read_matrix(16,640,8,16)
E = np.array(E)
# #E = E.T
E_ref = np.loadtxt('py/uinstv2/data/E_matrix_640.txt', dtype=np.int32)

# 比较E和E_ref
E_equal = (E == E_ref)
print("E == E_ref:")
print(E_equal)

# 获取不相同的个数
E_different_count = np.sum(~E_equal)
print(f"E中不相同的元素个数: {E_different_count}")
print(f"E中总元素个数: {E.size}")
print(f"E中相同的元素个数: {E.size - E_different_count}")
print(f"E的匹配率: {(E.size - E_different_count) / E.size * 100:.2f}%")
