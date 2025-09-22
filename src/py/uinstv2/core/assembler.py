#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Frodo指令汇编器
实现类似汇编器的功能，支持指令编码和解码
"""

class FrodoAssembler:
    """Frodo指令汇编器类"""
    
    def __init__(self):
        # 指令操作码定义（基于global_define.v）
        self.opcodes = {
            'ENCDEC': 0b0001,      # 编码/解码操作
            'MATMUL': 0b0010,      # 矩阵乘法
            'MOV': 0b0011,         # 数据移动
            'AMATMUL': 0b0100,    # A矩阵乘法
            'MATADD': 0b0101,      # 矩阵加法
            'ABSORB': 0b1000,      # 吸收操作
            'SQUEEZE': 0b1001,     # 挤压操作
            'HASH_RND': 0b1010,    # 哈希随机数
            'ABSORB_STRM': 0b1011, # 流吸收
            'SQUEEZE_STRM': 0b1100, # 流挤压
            'ABSORB_BYTE': 0b1101, # 字节吸收
        }
        
        
        # 指令类型特定配置（每个指令完全独立定义）
        self.instruction_configs = {
            'ENCDEC': {
                'description': '编码/解码操作',
                'required_fields': ['src0', 'dst', 'mode'],
                'fields': {
                    'src0': {'bits': 4, 'offset': 24},             # 源操作数0 (位27-24)
                    'dst': {'bits': 4, 'offset': 16},             # 目标操作数 (位19-16)
                    'mode': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'MATMUL': {
                'description': '矩阵乘法',
                'required_fields': ['src0', 'src1', 'dst'],
                'optional_fields': ['mode'],
                'default_values': {'mode': 0},
                'fields': {
                    'src0': {'bits': 4, 'offset': 24},             # 源操作数0 (位27-24)
                    'src1': {'bits': 4, 'offset': 20},            # 源操作数1 (位23-20)
                    'dst': {'bits': 4, 'offset': 16},             # 目标操作数 (位19-16)
                    'mode': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'MOV': {
                'description': '数据移动',
                'required_fields': ['src0', 'dst', 'length'],
                'default_values': {'mode': 0},
                'fields': {
                    'src0': {'bits': 4, 'offset': 24},             # 源操作数0 (位27-24)
                    'length_high': {'bits': 4, 'offset': 20},      # length[9:6] (位23-20)
                    'dst': {'bits': 4, 'offset': 16},             # 目标操作数 (位19-16)
                    'length_low': {'bits': 6, 'offset': 10},      # length[5:0] (位15-10)
                    'mode': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'AMATMUL': {
                'description': 'A矩阵乘法',
                'required_fields': ['src0', 'src1', 'dst'],
                'optional_fields': ['mode'],
                'default_values': {'mode': 0},
                'fields': {
                    'src0': {'bits': 4, 'offset': 24},             # 源操作数0 (位27-24)
                    'src1': {'bits': 4, 'offset': 20},            # 源操作数1 (位23-20)
                    'dst': {'bits': 4, 'offset': 16},             # 目标操作数 (位19-16)
                    'mode': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'MATADD': {
                'description': '矩阵加法',
                'required_fields': ['src0', 'dst'],
                'optional_fields': ['mode'],
                'default_values': {'mode': 0},
                'fields': {
                    'src0': {'bits': 4, 'offset': 24},             # 源操作数0 (位27-24)
                    'dst': {'bits': 4, 'offset': 16},             # 目标操作数 (位19-16)
                    'mode': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'ABSORB': {
                'description': '吸收操作',
                'required_fields': ['addr', 'length', 'ram_index'],
                'optional_fields': ['flag15to8','inverse','ram_reset'],
                'default_values': {'flag15to8': 0, 'inverse': 0, 'ram_reset': 0},
                'fields': {
                    'addr': {'bits': 12, 'offset': 16},             # 地址 (位27-24)
                    'length': {'bits': 6, 'offset': 10},          # 长度 (位15-10)
                    'ram_index': {'bits': 1, 'offset': 9},        # RAM索引 (位9)
                    'flag15to8': {'bits': 1, 'offset': 8},        # 保留位 (位8-7)
                    'inverse': {'bits': 1, 'offset': 7},             # 模式 (位6)
                    'ram_reset': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'SQUEEZE': {
                'description': '挤压操作',
                'required_fields': ['addr', 'length', 'ram_index','mode'],
                'optional_fields': ['sample'],
                'default_values': {'sample': 0},
                'fields': {
                    'addr': {'bits': 12, 'offset': 16},             # 地址 (位27-24)
                    'length': {'bits': 6, 'offset': 10},          # 长度 (位15-10)
                    'ram_index': {'bits': 1, 'offset': 9},        # RAM索引 (位9)
                    'mode': {'bits': 2, 'offset': 7},        # 保留位 (位8-7)
                    'sample': {'bits': 1, 'offset': 6},             # 模式 (位6)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            },
            'HASH_RND': {
                'description': '哈希随机数',
                'required_fields': ['length', 'mode'],
                'optional_fields': [],
                'default_values': {},
                'fields': {
                    'length': {'bits': 10, 'offset': 10},       # 10位length (位19-10)
                    'mode': {'bits': 1, 'offset': 6},            # 1位mode (位9)
                    'opcode': {'bits': 4, 'offset': 2},          # 4位opcode (位5-2)
                }
            },
            'SQUEEZE_STRM': {
                'description': '流挤压',
                'required_fields': ['addr', 'mode'],
                'optional_fields': ['sample'],
                'default_values': {'sample': 0},
                'fields': {
                    'addr': {'bits': 12, 'offset': 16},             # 地址 (位27-16)
                    'loop_low': {'bits': 6, 'offset': 10},         # loop[5:0] (位15-10)
                    'ram_index': {'bits': 1, 'offset': 9},         # RAM索引 (位9)
                    'mode': {'bits': 2, 'offset': 7},              # 模式 (位8-7)
                    'sample': {'bits': 1, 'offset': 6},            # 采样 (位6)
                    'opcode': {'bits': 4, 'offset': 2},            # 操作码 (位5-2)
                    'loop_high': {'bits': 2, 'offset': 0},         # loop[7:6] (位1-0)
                }
            },
            'ABSORB_STRM': {
                'description': '流吸收',
                'required_fields': ['addr', 'mode'],
                'optional_fields': [],
                'default_values': {},
                'fields': {
                    'addr': {'bits': 12, 'offset': 16},             # 地址 (位27-16)
                    'loop_low': {'bits': 6, 'offset': 10},         # loop[5:0] (位15-10)
                    'ram_index': {'bits': 1, 'offset': 9},         # RAM索引 (位9)
                    'mode': {'bits': 2, 'offset': 7},              # 模式 (位8-7)
                    'reserved': {'bits': 1, 'offset': 6},          # 保留位 (位6)
                    'opcode': {'bits': 4, 'offset': 2},            # 操作码 (位5-2)
                    'loop_high': {'bits': 2, 'offset': 0},         # loop[7:6] (位1-0)
                }
            },
            'ABSORB_BYTE': {
                'description': '字节吸收',
                'required_fields': ['byte'],
                'optional_fields': [],
                'default_values': {},
                'fields': {
                    'byte': {'bits': 8, 'offset': 20},             # 字节 (位27-20)
                    'opcode': {'bits': 4, 'offset': 2},           # 操作码 (位5-2)
                }
            }
        }
        
        self.validate_field_structure()
    
    def validate_field_structure(self):
        """验证字段定义是否冲突"""
        # 验证每个指令类型的字段定义
        for instruction_type, config in self.instruction_configs.items():
            used_bits = set()
            for field, field_config in config['fields'].items():
                start = field_config['offset']
                end = start + field_config['bits']
                if any(bit in used_bits for bit in range(start, end)):
                    raise ValueError(f"指令类型 {instruction_type} 的字段 {field} 存在位域冲突")
                used_bits.update(range(start, end))
        
    
    def assemble_instruction(self, instruction_dict, instruction_type=None):
        """
        将指令字典转换为二进制字符串
        
        Args:
            instruction_dict: 包含指令字段的字典
            instruction_type: 指令类型，用于应用特定配置
            
        Returns:
            str: 二进制字符串
        """
        # 确定使用的字段定义
        if instruction_type and instruction_type in self.instruction_configs:
            config = self.instruction_configs[instruction_type]
            
            # 检查必需字段
            for field in config['required_fields']:
                if field not in instruction_dict:
                    raise ValueError(f"指令类型 {instruction_type} 缺少必需字段: {field}")
            
            # 应用默认值
            for field, default_value in config['default_values'].items():
                if field not in instruction_dict:
                    instruction_dict[field] = default_value
            
            # 设置操作码
            if 'opcode' not in instruction_dict:
                instruction_dict['opcode'] = self.opcodes[instruction_type]
            
            # 使用该指令类型的字段定义
            fields_to_use = config['fields']
        else:
            raise ValueError("必须指定有效的指令类型")
        
        # 计算总位数（28位）
        binary = ['0'] * 28
        
        # 特殊处理MOV指令的length字段分割
        if instruction_type == 'MOV' and 'length' in instruction_dict:
            length_value = instruction_dict['length']
            # 分割length字段
            length_high = (length_value >> 6) & 0xF  # length[9:6]
            length_low = length_value & 0x3F         # length[5:0]
            
            # 设置分割后的字段
            if 'length_high' in fields_to_use:
                config = fields_to_use['length_high']
                bin_str = format(length_high, f'0{config["bits"]}b')
                for i, bit in enumerate(bin_str):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < 28:
                        binary[pos] = bit
            
            if 'length_low' in fields_to_use:
                config = fields_to_use['length_low']
                bin_str = format(length_low, f'0{config["bits"]}b')
                for i, bit in enumerate(bin_str):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < 28:
                        binary[pos] = bit
        
        # 特殊处理SQUEEZE_STRM和ABSORB_STRM指令的loop字段分割
        if instruction_type in ['SQUEEZE_STRM', 'ABSORB_STRM'] and 'loop' in instruction_dict:
            loop_value = instruction_dict['loop']
            # 分割loop字段
            loop_high = (loop_value >> 6) & 0x3  # loop[7:6]
            loop_low = loop_value & 0x3F         # loop[5:0]
            
            # 设置分割后的字段
            if 'loop_high' in fields_to_use:
                config = fields_to_use['loop_high']
                bin_str = format(loop_high, f'0{config["bits"]}b')
                for i, bit in enumerate(bin_str):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < 28:
                        binary[pos] = bit
            
            if 'loop_low' in fields_to_use:
                config = fields_to_use['loop_low']
                bin_str = format(loop_low, f'0{config["bits"]}b')
                for i, bit in enumerate(bin_str):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < 28:
                        binary[pos] = bit
        
        for field, value in instruction_dict.items():
            # 跳过已特殊处理的字段
            if instruction_type == 'MOV' and field == 'length':
                continue
            if instruction_type in ['SQUEEZE_STRM', 'ABSORB_STRM'] and field == 'loop':
                continue
                
            if field not in fields_to_use:
                raise ValueError(f"未定义的指令字段: {field}")
                
            config = fields_to_use[field]
            max_val = (1 << config['bits']) - 1
            if value > max_val:
                raise ValueError(f"字段 {field} 的值 {value} 超出 {config['bits']} 位限制")
            
            # 将数值转换为二进制字符串并填充到对应位置
            bin_str = format(value, f'0{config["bits"]}b')
            for i, bit in enumerate(bin_str):
                pos = config['offset'] + (config['bits'] - 1 - i)
                if pos < 28:
                    binary[pos] = bit
        
        return ''.join(binary[::-1])  # 反转得到标准二进制表示
    
    
    def disassemble_instruction(self, binary_string, instruction_type=None):
        """
        将二进制字符串解析为指令字典
        
        Args:
            binary_string: 二进制字符串
            instruction_type: 指令类型，用于确定字段定义
            
        Returns:
            dict: 指令字段字典
        """
        if instruction_type and instruction_type in self.instruction_configs:
            fields_to_use = self.instruction_configs[instruction_type]['fields']
        else:
            raise ValueError("必须指定有效的指令类型进行反汇编")
        
        result = {}
        binary = binary_string[::-1]  # 反转以匹配内部表示
        
        # 特殊处理MOV指令的length字段合并
        if instruction_type == 'MOV':
            # 提取length_high和length_low字段
            length_high = 0
            length_low = 0
            
            if 'length_high' in fields_to_use:
                config = fields_to_use['length_high']
                start = config['offset']
                end = start + config['bits']
                if end <= len(binary):
                    field_bits = binary[start:end]
                    length_high = int(field_bits, 2)
            
            if 'length_low' in fields_to_use:
                config = fields_to_use['length_low']
                start = config['offset']
                end = start + config['bits']
                if end <= len(binary):
                    field_bits = binary[start:end]
                    length_low = int(field_bits, 2)
            
            # 合并length字段
            result['length'] = (length_high << 6) | length_low
        
        # 特殊处理SQUEEZE_STRM和ABSORB_STRM指令的loop字段合并
        if instruction_type in ['SQUEEZE_STRM', 'ABSORB_STRM']:
            # 提取loop_high和loop_low字段
            loop_high = 0
            loop_low = 0
            
            if 'loop_high' in fields_to_use:
                config = fields_to_use['loop_high']
                # 提取字段位，注意位序
                field_bits = []
                for i in range(config['bits']):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < len(binary):
                        field_bits.append(binary[pos])
                loop_high = int(''.join(field_bits), 2)
            
            if 'loop_low' in fields_to_use:
                config = fields_to_use['loop_low']
                # 提取字段位，注意位序
                field_bits = []
                for i in range(config['bits']):
                    pos = config['offset'] + (config['bits'] - 1 - i)
                    if pos < len(binary):
                        field_bits.append(binary[pos])
                loop_low = int(''.join(field_bits), 2)
            
            # 合并loop字段
            result['loop'] = (loop_high << 6) | loop_low
        
        for field, config in fields_to_use.items():
            # 跳过已特殊处理的字段
            if instruction_type == 'MOV' and field in ['length_high', 'length_low']:
                continue
            if instruction_type in ['SQUEEZE_STRM', 'ABSORB_STRM'] and field in ['loop_high', 'loop_low']:
                continue
                
            start = config['offset']
            end = start + config['bits']
            if end <= len(binary):
                # 提取字段位，注意位序
                field_bits = []
                for i in range(config['bits']):
                    pos = start + (config['bits'] - 1 - i)
                    if pos < len(binary):
                        field_bits.append(binary[pos])
                result[field] = int(''.join(field_bits), 2)
            else:
                result[field] = 0
        
        return result
    
    
    def get_opcode_name(self, opcode_value):
        """根据操作码值获取操作码名称"""
        for name, value in self.opcodes.items():
            if value == opcode_value:
                return name
        return f"UNKNOWN_{opcode_value:04b}"
    
    def assemble_batch_instructions(self, instruction_list):
        """批量转换多条指令"""
        results = []
        for inst in instruction_list:
            if 'instruction_type' in inst and 'fields' in inst:
                # 新格式：包含instruction_type和fields
                result = self.assemble_instruction(inst['fields'], inst['instruction_type'])
                results.append(result)
            else:
                # 旧格式：直接传递指令字典
                result = self.assemble_instruction(inst)
                results.append(result)
        return results
    
    
    def format_instruction(self, instruction_dict):
        """格式化指令为可读字符串"""
        opcode_name = self.get_opcode_name(instruction_dict.get('opcode', 0))
        return f"{opcode_name}({instruction_dict})"
    
    def create_instruction(self, instruction_type, **kwargs):
        """
        创建指定类型的指令
        
        Args:
            instruction_type: 指令类型名称
            **kwargs: 指令字段值
            
        Returns:
            str: 二进制编码的指令
        """
        if instruction_type not in self.instruction_configs:
            raise ValueError(f"未知的指令类型: {instruction_type}")
        
        return self.assemble_instruction(kwargs, instruction_type)
    
    def get_instruction_info(self, instruction_type):
        """获取指令类型信息"""
        if instruction_type not in self.instruction_configs:
            return None
        return self.instruction_configs[instruction_type]
    
    def list_instruction_types(self):
        """列出所有支持的指令类型"""
        return list(self.instruction_configs.keys())
    
    def set_instruction_fields(self, instruction_type, fields):
        """
        为指定指令类型设置字段定义
        
        Args:
            instruction_type: 指令类型名称
            fields: 字段定义字典
                格式: {'field_name': {'bits': int, 'offset': int}, ...}
        """
        if instruction_type not in self.instruction_configs:
            raise ValueError(f"未知的指令类型: {instruction_type}")
        
        # 验证字段定义
        used_bits = set()
        for field, config in fields.items():
            start = config['offset']
            end = start + config['bits']
            if any(bit in used_bits for bit in range(start, end)):
                raise ValueError(f"字段 {field} 存在位域冲突")
            used_bits.update(range(start, end))
        
        self.instruction_configs[instruction_type]['fields'] = fields
    
    def get_instruction_fields(self, instruction_type):
        """获取指定指令类型的字段定义"""
        if instruction_type not in self.instruction_configs:
            return None
        
        return self.instruction_configs[instruction_type]['fields']
    
    def add_instruction_type(self, instruction_type, opcode_value, description, 
                           required_fields, fields, optional_fields=None, default_values=None):
        """
        添加新的指令类型
        
        Args:
            instruction_type: 指令类型名称
            opcode_value: 操作码值
            description: 指令描述
            required_fields: 必需字段列表
            fields: 字段定义字典
            optional_fields: 可选字段列表
            default_values: 默认值字典
        """
        if optional_fields is None:
            optional_fields = []
        if default_values is None:
            default_values = {}
        
        self.opcodes[instruction_type] = opcode_value
        self.instruction_configs[instruction_type] = {
            'description': description,
            'required_fields': required_fields,
            'optional_fields': optional_fields,
            'default_values': default_values,
            'fields': fields
        }
    
    def read_bin_file(self, file_path, instruction_type=None):
        """
        读取.bin文件并解析指令
        
        Args:
            file_path: .bin文件路径
            instruction_type: 指令类型，如果为None则尝试自动识别
            
        Returns:
            list: 解析后的指令列表，每个元素包含指令类型和字段字典
        """
        instructions = []
        
        try:
            # 首先尝试作为文本文件读取（每行28位二进制）
            try:
                with open(file_path, 'r') as f:
                    lines = f.readlines()
                    
                for line_num, line in enumerate(lines):
                    line = line.strip()
                    if len(line) == 28:  # 确保是28位二进制
                        binary_string = line
                        
                        # 尝试识别指令类型
                        if instruction_type is None:
                            # 从操作码识别指令类型
                            opcode_bits = binary_string[22:26]  # 位5-2
                            opcode_value = int(opcode_bits, 2)
                            
                            # 查找对应的指令类型
                            found_type = None
                            for inst_type, opcode in self.opcodes.items():
                                if opcode == opcode_value:
                                    found_type = inst_type
                                    break
                            
                            if found_type:
                                # 反汇编指令
                                disassembled = self.disassemble_instruction(binary_string, found_type)
                                instructions.append({
                                    'instruction_type': found_type,
                                    'fields': disassembled,
                                    'binary': binary_string,
                                    'hex': f"0x{int(binary_string, 2):07X}",
                                    'line': line_num + 1
                                })
                            else:
                                # 未知指令类型
                                instructions.append({
                                    'instruction_type': 'UNKNOWN',
                                    'fields': {'opcode': opcode_value},
                                    'binary': binary_string,
                                    'hex': f"0x{int(binary_string, 2):07X}",
                                    'line': line_num + 1
                                })
                        else:
                            # 使用指定的指令类型
                            disassembled = self.disassemble_instruction(binary_string, instruction_type)
                            instructions.append({
                                'instruction_type': instruction_type,
                                'fields': disassembled,
                                'binary': binary_string,
                                'hex': f"0x{int(binary_string, 2):07X}",
                                'line': line_num + 1
                            })
                            
            except UnicodeDecodeError:
                # 如果文本读取失败，尝试作为二进制文件读取
                with open(file_path, 'rb') as f:
                    data = f.read()
                    
                    # 按28位（3.5字节）分组处理
                    for i in range(0, len(data), 4):  # 每次读取4字节（32位）
                        # 提取28位指令
                        if i + 3 < len(data):
                            # 读取4字节
                            word = int.from_bytes(data[i:i+4], byteorder='little')
                            
                            # 提取28位指令（去掉高4位）
                            instruction_bits = word & 0x0FFFFFFF
                            
                            # 转换为28位二进制字符串
                            binary_string = format(instruction_bits, '028b')
                            
                            # 尝试识别指令类型
                            if instruction_type is None:
                                # 从操作码识别指令类型
                                opcode_bits = binary_string[22:26]  # 位5-2
                                opcode_value = int(opcode_bits, 2)
                                
                                # 查找对应的指令类型
                                found_type = None
                                for inst_type, opcode in self.opcodes.items():
                                    if opcode == opcode_value:
                                        found_type = inst_type
                                        break
                                
                                if found_type:
                                    # 反汇编指令
                                    disassembled = self.disassemble_instruction(binary_string, found_type)
                                    instructions.append({
                                        'instruction_type': found_type,
                                        'fields': disassembled,
                                        'binary': binary_string,
                                        'hex': f"0x{instruction_bits:07X}"
                                    })
                                else:
                                    # 未知指令类型
                                    instructions.append({
                                        'instruction_type': 'UNKNOWN',
                                        'fields': {'opcode': opcode_value},
                                        'binary': binary_string,
                                        'hex': f"0x{instruction_bits:07X}"
                                    })
                            else:
                                # 使用指定的指令类型
                                disassembled = self.disassemble_instruction(binary_string, instruction_type)
                                instructions.append({
                                    'instruction_type': instruction_type,
                                    'fields': disassembled,
                                    'binary': binary_string,
                                    'hex': f"0x{instruction_bits:07X}"
                                })
                            
        except FileNotFoundError:
            raise FileNotFoundError(f"文件 {file_path} 不存在")
        except Exception as e:
            raise Exception(f"读取文件时出错: {e}")
        
        return instructions
    
    def write_bin_file(self, instructions, file_path):
        """
        将指令列表写入.bin文件
        
        Args:
            instructions: 指令列表，每个元素包含instruction_type和fields
            file_path: 输出文件路径
        """
        try:
            with open(file_path, 'wb') as f:
                for instruction in instructions:
                    # 汇编指令
                    binary = self.assemble_instruction(
                        instruction['fields'], 
                        instruction['instruction_type']
                    )
                    
                    # 转换为字节
                    instruction_int = int(binary, 2)
                    
                    # 写入4字节（32位对齐）
                    f.write(instruction_int.to_bytes(4, byteorder='little'))
                    
        except Exception as e:
            raise Exception(f"写入文件时出错: {e}")
    


def main():
    # """主函数 - 使用示例"""
    assembler = FrodoAssembler()
    
    # 示例1: 使用便捷方法创建指令
    # print("=== 使用便捷方法创建指令 ===")
    
    # # MATMUL指令示例
    # code = assembler.create_instruction('HASH_RND',length=512, mode=0)
    # print(f"HASH_RND指令: {code}")
    
    # # ENCDEC指令示例
    # encdec_code = assembler.create_instruction('ENCDEC',
    #                                           src0=4, dst=5, 
    #                                           length=8, mode=1)
    # print(f"ENCDEC指令: {encdec_code}")
    
    # # HASH_RND指令示例（只需要dst）
    # hash_code = assembler.create_instruction('HASH_RND',
    #                                         dst=6, length=16, mode=0)
    # print(f"HASH_RND指令: {hash_code}")
    
    # # 示例2: 手动创建指令
    # print("\n=== 手动创建指令 ===")
    # manual_instruction = {
    #     'src0': 1,
    #     'src1': 2, 
    #     'dst': 3,
    #     'length': 15,
    #     'ram_index': 1,
    #     'mode': 0,
    #     'opcode': assembler.opcodes['MATMUL']
    # }
    
    # binary_code = assembler.assemble_instruction(manual_instruction)
    # print(f"手动指令: {binary_code}")
    # print(f"编码长度: {len(binary_code)} bits")
    
    # # 示例3: 解码指令
    # print("\n=== 指令解码示例 ===")
    # decoded = assembler.disassemble_instruction(binary_code)
    # print(f"解码结果: {decoded}")
    
    # 示例4: .bin文件读取功能
    # print("\n=== .bin文件读取功能 ===")
    # # try:
    # #     # 创建一些测试指令并写入文件
    # #     test_instructions = [
    # #         {'instruction_type': 'MOV', 'fields': {'src0': 1, 'dst': 2, 'length': 100, 'mode': 0}},
    # #         {'instruction_type': 'ENCDEC', 'fields': {'src0': 3, 'dst': 4, 'mode': 1}},
    # #         {'instruction_type': 'HASH_RND', 'fields': {'length': 512, 'mode': 0}}
    # #     ]
        
    #     # 写入测试文件
    test_file = '../../sim/bin/inst.bin'
    #assembler.write_bin_file(test_instructions, test_file)
    print(f"已创建测试文件: {test_file}")
    
    # 读取并解析文件
    instructions = assembler.read_bin_file(test_file)
    print(f"从文件读取到 {len(instructions)} 条指令:")
    for i, inst in enumerate(instructions):
        print(f"  指令{i+1}: {inst['instruction_type']} - {inst['fields']} - {inst['hex']}")
        
    # except Exception as e:
    #     print(f"错误: {e}")
    
    # # 示例5: 指令信息查询
    # print("\n=== 指令信息查询 ===")
    # for inst_type in ['MATMUL', 'ENCDEC', 'HASH_RND']:
    #     info = assembler.get_instruction_info(inst_type)
    #     print(f"{inst_type}: {info['description']}")
    #     print(f"  必需字段: {info['required_fields']}")
    #     print(f"  可选字段: {info['optional_fields']}")
    #     print(f"  默认值: {info['default_values']}")
    #     print()
    
    # # 示例5: 批量处理
    # print("=== 批量处理示例 ===")
    # instruction_batch = [
    #     {'src0': 1, 'src1': 2, 'dst': 3, 'length': 10, 'opcode': assembler.opcodes['MATMUL']},
    #     {'src0': 4, 'dst': 5, 'length': 8, 'mode': 1, 'opcode': assembler.opcodes['ENCDEC']},
    #     {'dst': 6, 'length': 16, 'mode': 0, 'opcode': assembler.opcodes['HASH_RND']}
    # ]
    
    # batch_codes = assembler.assemble_batch_instructions(instruction_batch)
    # for i, code in enumerate(batch_codes):
    #     print(f"指令 {i+1}: {code}")


if __name__ == "__main__":
    main()
