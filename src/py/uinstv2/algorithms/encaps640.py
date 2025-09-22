"""
FrodoKEM-640 封装算法实现

演示如何使用基类实现其他算法。
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from core.algorithm_base import FrodoAlgorithmBase
from typing import List, Dict, Any


class Encaps640Generator(FrodoAlgorithmBase):
    """
    FrodoKEM-640 封装算法微指令生成器
    
    继承自FrodoAlgorithmBase，实现FrodoKEM-640封装算法的微指令序列生成功能。
    """
    
    def __init__(self, output_dir="../../sim/bin"):
        """
        初始化FrodoKEM-640封装生成器
        
        Args:
            output_dir (str): 输出目录路径
        """
        super().__init__("Encaps640", output_dir)
    
    def _define_instructions(self) -> List[Dict[str, Any]]:
        """
        定义FrodoKEM-640封装算法的微指令序列
        
        Returns:
            List[Dict[str, Any]]: FrodoKEM-640封装算法的微指令序列
        """
        return [
            # 这里应该定义封装算法的具体指令序列
            # 示例指令（实际使用时需要根据具体算法定义）
            {'instruction_type': 'ABSORB_BYTE',  'fields': {'byte': 0x96}},                                             #吸收96                       
            {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc1, 'length': 4, 'ram_index': 0x00}},            #吸收seedse,256bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 33 , 'mode': 0}},                                 #执行吸收,长度为33*8bit
            {'instruction_type': 'SQUEEZE_STRM', 'fields': {'addr': 0xa81, 'loop': 60, 'mode': 0b00,'sample': 1}},    #输出S'的主体
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 3249, 'length': 20, 'ram_index': 0, 'mode': 0b00,'sample': 1}}, #输出S'剩余
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 0x10, 'length': 1, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E'首轮
            {'instruction_type': 'HASH_RND',     'fields': {'length': 0 , 'mode': 1}},                                 #执行一次挤压
            {'instruction_type': 'SQUEEZE_STRM','fields': {'addr':17, 'loop': 60, 'ram_index': 1, 'mode': 0b10,'sample': 1}}, #输出E'主体
            {'instruction_type': 'SQUEEZE',      'fields': {'addr': 1277, 'length': 19, 'ram_index': 1, 'mode': 0b10,'sample': 1}},  #输出E'剩余
            {'instruction_type': 'ABSORB',       'fields': {'addr': 0xfc9, 'length': 2, 'ram_index': 0,'ram_reset': 1}},             #吸收mu,128bit
            {'instruction_type': 'HASH_RND',     'fields': {'length': 16 , 'mode': 0}},                                 #执行吸收,长度为16*8bit
            {'instruction_type': 'SQUEEZE',      'fields': {'addr':0xfc9, 'length':2, 'ram_index': 0, 'mode': 0b10,'sample': 0}}, #输出k,16bit
        ]


# 使用示例
if __name__ == "__main__":
    # 创建封装生成器实例
    generator = Encaps640Generator()
    
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
