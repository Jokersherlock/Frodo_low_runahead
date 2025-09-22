"""
算法基类模块

定义了所有FrodoKEM算法实现的通用基类，提供统一的接口和通用功能。
"""

from .assembler import FrodoAssembler
import os
from abc import ABC, abstractmethod
from typing import List, Tuple, Dict, Any


class FrodoAlgorithmBase(ABC):
    """
    FrodoKEM算法基类
    
    定义了所有FrodoKEM算法实现的通用接口和功能，
    包括指令生成、汇编、文件输出等通用操作。
    """
    
    def __init__(self, algorithm_name: str, output_dir: str = "../../sim/bin"):
        """
        初始化算法基类
        
        Args:
            algorithm_name (str): 算法名称，用于标识和文件命名
            output_dir (str): 输出目录路径
        """
        self.algorithm_name = algorithm_name
        self.output_dir = output_dir
        self.assembler = FrodoAssembler()
        self.zero_instruction = "0000000000000000000000000000"
        
        # 子类需要实现的指令序列
        self.instructions = self._define_instructions()
    
    @abstractmethod
    def _define_instructions(self) -> List[Dict[str, Any]]:
        """
        定义算法特定的微指令序列
        
        子类必须实现此方法来定义具体的指令序列
        
        Returns:
            List[Dict[str, Any]]: 微指令序列列表
        """
        pass
    
    def generate_instructions(self) -> List[str]:
        """
        生成微指令序列
        
        Returns:
            List[str]: 包含首末行全零指令的完整指令序列
        """
        # 汇编微指令
        codes = self.assembler.assemble_batch_instructions(self.instructions)
        
        # 在首行和末行添加全零指令
        all_codes = [self.zero_instruction] + codes + [self.zero_instruction]
        
        return all_codes
    
    def get_binary_instructions(self) -> List[str]:
        """
        获取算法的二进制指令序列（不包含首末行全零指令）
        
        Returns:
            List[str]: 算法的二进制指令序列
        """
        return self.assembler.assemble_batch_instructions(self.instructions)
    
    def get_instruction_count(self) -> int:
        """
        获取指令数量（不包含首末行全零指令）
        
        Returns:
            int: 实际指令数量
        """
        return len(self.instructions)
    
    def get_algorithm_info(self) -> Dict[str, Any]:
        """
        获取算法信息
        
        Returns:
            Dict[str, Any]: 包含算法名称、指令数量等信息的字典
        """
        return {
            'algorithm_name': self.algorithm_name,
            'instruction_count': self.get_instruction_count(),
            'output_dir': self.output_dir
        }
    
    def validate_instructions(self) -> bool:
        """
        验证指令序列的有效性
        
        Returns:
            bool: 指令序列是否有效
        """
        try:
            # 尝试汇编指令
            self.assembler.assemble_batch_instructions(self.instructions)
            return True
        except Exception as e:
            print(f"指令验证失败: {e}")
            return False
    
    def __str__(self) -> str:
        """
        返回算法的字符串表示
        
        Returns:
            str: 算法信息字符串
        """
        info = self.get_algorithm_info()
        return f"{self.algorithm_name}算法 - 指令数量: {info['instruction_count']}"
    
    def __repr__(self) -> str:
        """
        返回算法的详细表示
        
        Returns:
            str: 算法的详细字符串表示
        """
        return f"FrodoAlgorithmBase(algorithm_name='{self.algorithm_name}')"
