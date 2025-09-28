#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
通用微指令汇编器
将指令名称转换为对应的二进制微指令，与具体算法无关
"""

import os
import sys
from .mininst import MicrocodeAssembler

# 导入各个指令模块
from .absorb import get_absorb_instructions
from .absorb_byte import get_absorb_byte_instructions
from .absorb_strm import get_absorb_strm_instructions
from .Amatmul import get_amatmul_instructions
from .encdec import get_encdec_instructions
from .hash_rnd import get_hash_rnd_instructions
from .matadd import get_matadd_instructions
from .matmul import get_matmul_instructions
from .squeeze import get_squeeze_instructions
from .squeeze_strm import get_squeeze_strm_instructions

class UinstAssembler:
    """通用微指令汇编器类"""
    
    def __init__(self):
        self.assembler = MicrocodeAssembler()
        self.instruction_functions = {
            'ABSORB': get_absorb_instructions,
            'ABSORB_BYTE': get_absorb_byte_instructions,
            'ABSORB_STRM': get_absorb_strm_instructions,
            'AMATMUL': get_amatmul_instructions,
            'ENCDEC': get_encdec_instructions,
            'HASH_RND': get_hash_rnd_instructions,
            'MATADD': get_matadd_instructions,
            'MATMUL': get_matmul_instructions,
            'SQUEEZE': get_squeeze_instructions,
            'SQUEEZE_STRM': get_squeeze_strm_instructions,
        }
    
    def get_instruction(self, name):
        """获取指定名称的微指令函数"""
        if name not in self.instruction_functions:
            raise ValueError(f"未找到微指令: {name}")
        
        return self.instruction_functions[name]()
    
    def assemble_instruction(self, name):
        """汇编单个微指令"""
        instructions = self.get_instruction(name)
        binary_codes = []
        
        for instruction in instructions:
            binary_code = self.assembler.assemble(instruction)
            binary_codes.append(binary_code)
        
        return binary_codes
    
    def assemble_sequence(self, instruction_sequence):
        """
        汇编微指令序列
        
        Args:
            instruction_sequence: 微指令名称列表，按执行顺序排列
            
        Returns:
            tuple: (二进制微指令列表, 指令首地址字典)
        """
        all_binary_codes = []
        instruction_addresses = {}
        current_address = 1  # 从1开始，因为首行是全0
        
        for instruction_name in instruction_sequence:
            print(f"正在汇编微指令: {instruction_name}")
            binary_codes = self.assemble_instruction(instruction_name)
            
            # 记录指令首地址
            instruction_addresses[instruction_name] = current_address
            print(f"  - 生成了 {len(binary_codes)} 条微指令，首地址: {current_address}")
            
            all_binary_codes.extend(binary_codes)
            current_address += len(binary_codes)
        
        return all_binary_codes, instruction_addresses
    
    def save_to_bin(self, binary_codes, filename="uinst.bin"):
        """
        将二进制微指令保存到文本文件，首行和末行加上全0
        
        Args:
            binary_codes: 二进制微指令列表
            filename: 输出文件名
        """
        # 确保输出目录存在
        output_dir = os.path.join(os.path.dirname(__file__), "..", "..", "..","sim", "bin")
        os.makedirs(output_dir, exist_ok=True)
        
        output_path = os.path.join(output_dir, filename)
        
        with open(output_path, 'w') as f:
            # 首行写入全0（26位）
            f.write('0' * 26 + '\n')
            
            for code in binary_codes:
                # 直接写入二进制字符串，每行一条指令
                f.write(code + '\n')
            
            # 末行写入全0（26位）
            f.write('0' * 26 + '\n')
        
        print(f"微指令已保存到: {output_path}")
        print(f"总共生成了 {len(binary_codes)} 条微指令（首末行各加一个全0）")
    
    def list_available_instructions(self):
        """列出所有可用的微指令"""
        print("可用的微指令:")
        for name, instruction_func in self.instruction_functions.items():
            instructions = instruction_func()
            count = len(instructions)
            print(f"  - {name}: {count} 条微指令")
    
    def get_available_instructions(self):
        """获取所有可用的指令名称列表"""
        return list(self.instruction_functions.keys())