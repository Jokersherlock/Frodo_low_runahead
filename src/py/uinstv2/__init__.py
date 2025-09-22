"""
FrodoKEM 微指令生成器 v2

这是一个重构后的FrodoKEM微指令生成器框架，采用模块化设计，
支持多种算法的统一管理和扩展。

主要模块：
- core: 核心功能模块
- algorithms: 具体算法实现
- instructions: 微指令定义
- utils: 工具函数
- tests: 测试文件
"""

from .core.algorithm_factory import AlgorithmFactory, get_algorithm, list_available_algorithms

# 创建全局工厂实例
factory = AlgorithmFactory()

# 导出主要接口
__all__ = [
    'AlgorithmFactory',
    'get_algorithm', 
    'list_available_algorithms',
    'factory'
]
