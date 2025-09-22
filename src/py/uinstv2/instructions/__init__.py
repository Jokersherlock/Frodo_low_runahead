"""
微指令模块

包含各种微指令的定义和实现：
- 吸收指令
- 挤压指令
- 哈希指令
- 矩阵运算指令
- 其他微指令
"""

from .absorb import get_absorb_instructions
from .absorb_byte import get_absorb_byte_instructions
from .squeeze import get_squeeze_instructions
from .squeeze_strm import get_squeeze_strm_instructions
from .hash_rnd import get_hash_rnd_instructions
from .Amatmul import get_amatmul_instructions
from .mininst import MicrocodeAssembler
from .uinst_assembler import UinstAssembler

__all__ = [
    'get_absorb_instructions',
    'get_absorb_byte_instructions', 
    'get_squeeze_instructions',
    'get_squeeze_strm_instructions',
    'get_hash_rnd_instructions',
    'get_amatmul_instructions',
    'MicrocodeAssembler',
    'UinstAssembler'
]
