import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from core.algorithm_base import FrodoAlgorithmBase
from typing import List, Dict, Any


class Keygen1344Generator(FrodoAlgorithmBase):
    """
    FrodoKEM-1344 密钥生成微指令生成器
    
    继承自FrodoAlgorithmBase，实现FrodoKEM-1344密钥生成算法的微指令序列生成功能。
    """
    
    def __init__(self, output_dir="../../sim/bin"):
        """
        初始化FrodoKEM-1344密钥生成器
        
        Args:
            output_dir (str): 输出目录路径
        """
        super().__init__("Keygen1344", output_dir)
    
    def _define_instructions(self) -> List[Dict[str, Any]]:
        """
        定义FrodoKEM-1344密钥生成的微指令序列
        
        Returns:
            List[Dict[str, Any]]: FrodoKEM-1344密钥生成的微指令序列
        """
        return [
            {'instruction_type': 'ABSORB_BYTE',  'fields': {'byte': 0x5f}},                                             #吸收5f                       
            {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc1, 'length': 64, 'ram_index': 0x00}},            #吸收seedse,512bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 49 , 'mode': 0}},                                 #执行吸收,长度为49*8bit
            {'instruction_type': 'SQUEEZE_STRM', 'fields': {'addr': 0xa81, 'loop': 158, 'mode': 0b00,'sample': 1}},    #输出S的主体,158*1088/16=10744
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 3249, 'length': 8, 'ram_index': 0, 'mode': 0b00,'sample': 1}}, #输出S剩余,8*1344-10744=8
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 0x10, 'length': 60, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出首轮E,1088-8*16=960,960/16=60
            {'instruction_type': 'HASH_RND',     'fields': {'length': 0 , 'mode': 1}},                                 #执行一次挤压
            {'instruction_type': 'SQUEEZE_STRM','fields': {'addr':17, 'loop': 158, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E主体157*1088/16=10676
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 1277, 'length': 16, 'ram_index': 1, 'mode': 0b10,'sample': 1}},  #输出E剩余,8*1344-60-10676=16,44*16=704
            {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc9, 'length': 16, 'ram_index': 0,'ram_reset': 1}},             #吸收z,128bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 16 , 'mode': 0}},                                 #执行吸收,长度为16*8bit
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfc9, 'length':8, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #输出seedA,16bit
            {'instruction_type':  'AMATMUL',     'fields': {'src0': 1, 'src1': 2, 'dst': 3, 'mode': 0}},                      #B=AS+E
            #以下是滥竽充数
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xfc1, 'length': 16, 'ram_index': 0x00}},             #假装吸收seedA
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa81, 'length': 120, 'ram_index': 0x00,'flag15to8': 1}},             #假装吸收B的首轮部分,1088-128=960,960/8=120
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},                                 #假装执行的第一轮吸收
            {'instruction_type': 'ABSORB_STRM','fields': {'addr': 0xa81, 'loop': 157, 'mode': 0,'flag15to8': 1}},       #假装吸收B的主体,113*1088/16=7684
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},                                 #假装执行一次吸收
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa81, 'length': 16, 'ram_index': 0x00,'flag15to8': 1}},   #假装吸收B的剩余,8*976-60-7684=64,4*64=256
            {'instruction_type': 'HASH_RND',     'fields': {'length': 8 , 'mode': 0}},                                 #执行一次吸收
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xa81, 'length':16, 'ram_index': 1, 'mode': 0b10,'sample': 0}}, #挤出pkh
        ]


# 使用示例
if __name__ == "__main__":
    # 创建密钥生成器实例
    generator = Keygen1344Generator()
    
    # 生成并保存指令
    instructions, output_file = generator.generate_and_save()
    
    # 打印统计信息
    print(f"\n统计信息:")
    print(f"实际指令数量: {generator.get_instruction_count()}")
    print(f"总指令数量: {generator.get_total_instruction_count()}")
