"""
指令合并器模块

提供将多个算法的二进制指令序列合并到单个文件的功能。
"""

import os
from typing import List, Dict, Any, Tuple
from .algorithm_base import FrodoAlgorithmBase


class InstructionMerger:
    """
    指令合并器类
    
    负责将多个算法的二进制指令序列合并到单个inst.bin文件中。
    格式：首行全0 + 算法1序列 + 算法2序列 + ...
    """
    
    def __init__(self, output_dir: str = "../../sim/bin"):
        """
        初始化指令合并器
        
        Args:
            output_dir (str): 输出目录
        """
        self.output_dir = output_dir
        self.zero_instruction = "0000000000000000000000000000"  # 26位全0
        self.merged_instructions = []
        self.algorithm_info = {}  # 记录每个算法的信息
    
    def add_algorithm(self, algorithm: FrodoAlgorithmBase, algorithm_name: str = None) -> int:
        """
        添加算法到合并序列中
        
        Args:
            algorithm (FrodoAlgorithmBase): 算法实例
            algorithm_name (str, optional): 算法名称，如果为None则使用算法类名
            
        Returns:
            int: 该算法在合并序列中的起始位置
        """
        if algorithm_name is None:
            algorithm_name = algorithm.__class__.__name__
        
        # 生成算法的指令序列（不包含首末行全零指令）
        algorithm_instructions = algorithm.get_binary_instructions()
        
        # 记录算法信息
        start_position = len(self.merged_instructions)
        self.algorithm_info[algorithm_name] = {
            'start_position': start_position,
            'instruction_count': len(algorithm_instructions),
            'algorithm': algorithm
        }
        
        # 添加到合并序列中
        self.merged_instructions.extend(algorithm_instructions)
        
        print(f"已添加算法 {algorithm_name}: {len(algorithm_instructions)} 条指令，起始位置: {start_position}")
        
        return start_position
    
    def add_algorithms_from_factory(self, algorithm_names: List[str], factory) -> Dict[str, int]:
        """
        从算法工厂批量添加算法
        
        Args:
            algorithm_names (List[str]): 要添加的算法名称列表
            factory: 算法工厂实例
            
        Returns:
            Dict[str, int]: 算法名称到起始位置的映射
        """
        positions = {}
        
        for name in algorithm_names:
            try:
                algorithm = factory.create_algorithm(name)
                position = self.add_algorithm(algorithm, name)
                positions[name] = position
            except Exception as e:
                print(f"添加算法 {name} 失败: {e}")
        
        return positions
    
    def get_merged_instructions(self) -> List[str]:
        """
        获取合并后的完整指令序列
        
        Returns:
            List[str]: 合并后的指令序列（包含首行全0）
        """
        # 首行全0 + 所有算法指令
        return [self.zero_instruction] + self.merged_instructions
    
    def save_to_file(self, filename: str = "inst.bin") -> str:
        """
        保存合并后的指令序列到文件
        
        Args:
            filename (str): 输出文件名
            
        Returns:
            str: 输出文件的完整路径
        """
        # 确保输出目录存在
        os.makedirs(self.output_dir, exist_ok=True)
        
        output_file = os.path.join(self.output_dir, filename)
        
        # 获取完整指令序列
        full_instructions = self.get_merged_instructions()
        
        # 写入文件
        with open(output_file, 'w') as f:
            for instruction in full_instructions:
                f.write(instruction + '\n')
        
        print(f"合并后的指令已保存到: {output_file}")
        print(f"总指令数量: {len(full_instructions)} (包含首行全0)")
        
        return output_file
    
    def get_algorithm_positions(self) -> Dict[str, Dict[str, Any]]:
        """
        获取所有算法的位置信息
        
        Returns:
            Dict[str, Dict[str, Any]]: 算法位置信息
        """
        return self.algorithm_info.copy()
    
    def print_summary(self):
        """打印合并摘要"""
        print("\n" + "="*60)
        print("指令合并摘要")
        print("="*60)
        print(f"总指令数量: {len(self.merged_instructions)}")
        print(f"算法数量: {len(self.algorithm_info)}")
        print("\n算法详情:")
        
        for name, info in self.algorithm_info.items():
            print(f"  {name}:")
            print(f"    起始位置: {info['start_position']}")
            print(f"    指令数量: {info['instruction_count']}")
            print(f"    结束位置: {info['start_position'] + info['instruction_count'] - 1}")
        
        print("="*60)
    
    def clear(self):
        """清空合并器，重新开始"""
        self.merged_instructions = []
        self.algorithm_info = {}
        print("指令合并器已清空")


def merge_algorithms(algorithms: List[FrodoAlgorithmBase], 
                    algorithm_names: List[str] = None,
                    output_dir: str = "../../sim/bin",
                    filename: str = "inst.bin") -> Tuple[str, Dict[str, Any]]:
    """
    便捷函数：合并多个算法到单个文件
    
    Args:
        algorithms (List[FrodoAlgorithmBase]): 算法实例列表
        algorithm_names (List[str], optional): 算法名称列表
        output_dir (str): 输出目录
        filename (str): 输出文件名
        
    Returns:
        Tuple[str, Dict[str, Any]]: (输出文件路径, 算法位置信息)
    """
    merger = InstructionMerger(output_dir)
    
    # 添加算法
    for i, algorithm in enumerate(algorithms):
        name = algorithm_names[i] if algorithm_names and i < len(algorithm_names) else None
        merger.add_algorithm(algorithm, name)
    
    # 保存文件
    output_file = merger.save_to_file(filename)
    
    # 打印摘要
    merger.print_summary()
    
    return output_file, merger.get_algorithm_positions()


# 使用示例
if __name__ == "__main__":
    # 示例：合并多个算法
    from ..algorithms import Keygen640Generator, Encaps640Generator
    
    # 创建算法实例
    keygen = Keygen640Generator()
    encaps = Encaps640Generator()
    
    # 使用便捷函数合并
    output_file, positions = merge_algorithms(
        algorithms=[keygen, encaps],
        algorithm_names=["keygen640", "encaps640"],
        filename="inst.bin"
    )
    
    print(f"\n合并完成！输出文件: {output_file}")
    print("算法位置信息:", positions)
