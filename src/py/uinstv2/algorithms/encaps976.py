"""
FrodoKEM-976 封装算法实现

演示如何使用基类实现其他算法。
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from core.algorithm_base import FrodoAlgorithmBase
from typing import List, Dict, Any


class Encaps976Generator(FrodoAlgorithmBase):
    """
    FrodoKEM-976 封装算法微指令生成器
    
    继承自FrodoAlgorithmBase，实现FrodoKEM-976封装算法的微指令序列生成功能。
    """
    
    def __init__(self, output_dir="../../sim/bin"):
        """
        初始化FrodoKEM-976封装生成器
        
        Args:
            output_dir (str): 输出目录路径
        """
        super().__init__("Encaps976", output_dir)
    
    def _define_instructions(self) -> List[Dict[str, Any]]:
        """
        定义FrodoKEM-976封装算法的微指令序列
        
        Returns:
            List[Dict[str, Any]]: FrodoKEM-976封装算法的微指令序列
        """
        return [
            #生成pkh
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xfc1, 'length': 16, 'ram_index': 0x00}},             #假装吸收seedA
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa81, 'length': 120, 'ram_index': 0x00,'flag15to8': 1}},             #假装吸收B的首轮部分,19*64=1216,1216/16=76
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},                                 #假装执行的第一轮吸收
            {'instruction_type': 'ABSORB_STRM','fields': {'addr': 0xa81, 'loop': 113, 'mode': 0b00,'flag15to8': 1}},       #假装吸收B的主体,60*1344/16=5040
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},                                 #假装执行一次吸收
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa81, 'length':64, 'ram_index': 0x00,'flag15to8': 1}},   #假装吸收B的剩余,8*640-76-5040=4,4*16=64
            {'instruction_type': 'HASH_RND',     'fields': {'length': 8 , 'mode': 0}},                                 #执行一次吸收
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xa81, 'length':8, 'ram_index': 1, 'mode': 0b10,'sample': 0}}, #挤出pkh


            #生成seedSE
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa81, 'length': 24, 'ram_index': 1,'ram_reset': 1}},             #吸收Pkh
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xfcb, 'length': 24, 'ram_index': 0,'ram_reset': 0}},             #吸收u,192bit
            {'instruction_type': 'ABSORB',       'fields': {'addr':0xa95, 'length': 48, 'ram_index': 1,'ram_reset': 0}},             #吸收salt,384bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 64 , 'mode': 0}},                                 #执行吸收,长度为512bit
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfc1, 'length':24, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #挤出seedSE
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfdf, 'length':16, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #挤出k

            {'instruction_type': 'ABSORB_BYTE',  'fields': {'byte': 0x96}},                                             #吸收96                       
            {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc1, 'length': 48, 'ram_index': 0x00}},            #吸收seedse,256bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 33 , 'mode': 0}},                                 #执行吸收,长度为33*8bit
            {'instruction_type': 'SQUEEZE_STRM', 'fields': {'addr': 0xa81, 'loop': 114, 'mode': 0b00,'sample': 1}},    #输出S'的主体
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 3249, 'length': 56, 'ram_index': 0, 'mode': 0b00,'sample': 1}}, #输出S'剩余
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 0x10, 'length': 12, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E'首轮
            {'instruction_type': 'HASH_RND',     'fields': {'length': 0 , 'mode': 1}},                                 #执行一次挤压
            {'instruction_type': 'SQUEEZE_STRM','fields': {'addr':17, 'loop': 114, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E'主体
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 1277, 'length': 44, 'ram_index': 1, 'mode': 0b10,'sample': 1}},  #输出E'剩余
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xa85, 'length':24, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #挤出E"首轮
            {'instruction_type': 'HASH_RND',     'fields': {'length': 0 , 'mode': 1}},                                 #执行一次挤压
            {'instruction_type': 'SQUEEZE' ,     'fields': {'addr':0xa86, 'length': 40, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E"主体

            {'instruction_type': 'MATMUL',      'fields': {'src0': 5, 'src1': 2, 'dst': 4, 'mode': 1}},                      #V=S'B+E"
            {'instruction_type': 'ENCDEC',      'fields': {'src0': 6, 'dst': 7, 'mode': 0}},                      #encode u
            {'instruction_type': 'MATADD',      'fields': {'src0': 4, 'dst': 7, 'mode': 1}},                       #C=V+enu

            {'instruction_type': 'AMATMUL',     'fields': {'src0': 1, 'src1': 2, 'dst': 3, 'mode': 0}},                      #B'=S'A+E'

            {'instruction_type': 'ABSORB_STRM', 'fields': {'addr': 0x10, 'loop': 114, 'flag15to8': 1,'mode':1,'ram_reset':1}},    #吸收B'的主体
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},
            {'instruction_type': 'ABSORB',      'fields': {'addr':0x10, 'length': 112, 'ram_index': 0x00,'flag15to8': 1,'mode':1}},
            {'instruction_type': 'ABSORB',      'fields': {'addr':0xa85,'length':24,'ram_index': 1,'flag15to8': 0}},
            {'instruction_type': 'HASH_RND',     'fields': {'length': 168 , 'mode': 0}},                                 #假装执行一次吸收
            {'instruction_type': 'ABSORB',      'fields': {'addr':0xa88, 'length':8, 'ram_index': 1}},
            {'instruction_type': 'ABSORB',      'fields': {'addr':0xfdf, 'length':48, 'ram_index': 0}},
            {'instruction_type': 'HASH_RND',     'fields': {'length': 192 , 'mode': 0}},
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfe3, 'length':12, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #挤出ss
        ]


# 使用示例
if __name__ == "__main__":
    # 创建封装生成器实例
    generator = Encaps976Generator()
    
    # 生成并保存指令
    instructions, output_file = generator.generate_and_save()
    
    # 打印统计信息
    print(f"\n统计信息:")
    print(f"算法信息: {generator}")
    print(f"实际指令数量: {generator.get_instruction_count()}")
    print(f"总指令数量: {generator.get_total_instruction_count()}")
    
    # 验证指令
    if generator.validate_instructions():
        print("指令验证通过")
    else:
        print("指令验证失败")
