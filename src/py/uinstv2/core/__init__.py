"""
核心模块

包含FrodoKEM微指令生成器的核心功能：
- 算法基类
- 算法工厂
- 汇编器
- 内存管理
"""

from .algorithm_base import FrodoAlgorithmBase
from .assembler import FrodoAssembler
from .memory import Memory, MemoryData, MemoryReader
from .instruction_merger import InstructionMerger, merge_algorithms

__all__ = [
    'FrodoAlgorithmBase',
    'FrodoAssembler',
    'Memory',
    'MemoryData', 
    'MemoryReader',
    'InstructionMerger',
    'merge_algorithms'
]
