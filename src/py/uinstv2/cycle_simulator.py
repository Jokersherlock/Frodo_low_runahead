#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Frodo低资源周期统计模拟器
根据inst.bin、uinst.bin和mem1.hex文件模拟指令执行并统计周期数
"""

import os
import sys
from typing import List, Dict, Tuple, Optional

class FrodoCycleSimulator:
    def __init__(self, inst_file: str, uinst_file: str, mem1_file: str):
        """
        初始化模拟器
        
        Args:
            inst_file: 指令文件路径 (inst.bin)
            uinst_file: 微指令文件路径 (uinst.bin) 
            mem1_file: 内存文件路径 (mem1.hex)
        """
        self.inst_file = inst_file
        self.uinst_file = uinst_file
        self.mem1_file = mem1_file
        
        # 指令操作码定义
        self.OPCODES = {
            0b0001: "ENCDEC",
            0b0010: "MATMUL", 
            0b0011: "MOV",
            0b0100: "AMATMUL",
            0b0101: "MATADD",
            0b1000: "ABSORB",
            0b1001: "SQUEEZE",
            0b1010: "HASH_RND",
            0b1011: "ABSORB_STRM",
            0b1100: "SQUEEZE_STRM",
            0b1101: "ABSORB_BYTE"
        }
        
        # 安全等级定义
        self.FRODO_640 = 0b01
        self.FRODO_976 = 0b10
        self.FRODO_1344 = 0b11
        
        # 加载文件数据
        self.instructions = self._load_instructions()
        self.micro_instructions = self._load_micro_instructions()
        self.mem1_data = self._load_mem1_data()
        
        # 模拟状态
        self.total_cycles = 0
        self.current_instruction = 0
        self.current_upc = 0
        self.registers = {}  # 存储upc_st保存的寄存器值
        self.delay_slot_count = 0  # upc_up延迟槽计数器
        self.pending_jump = None  # 待执行的跳转目标
        
    def _load_instructions(self) -> List[str]:
        """加载指令文件"""
        try:
            with open(self.inst_file, 'r') as f:
                return [line.strip() for line in f.readlines()]
        except FileNotFoundError:
            print(f"错误：找不到指令文件 {self.inst_file}")
            return []
    
    def _load_micro_instructions(self) -> List[str]:
        """加载微指令文件"""
        try:
            with open(self.uinst_file, 'r') as f:
                return [line.strip() for line in f.readlines()]
        except FileNotFoundError:
            print(f"错误：找不到微指令文件 {self.uinst_file}")
            return []
    
    def _load_mem1_data(self) -> List[str]:
        """加载mem1.hex文件的前16行"""
        try:
            with open(self.mem1_file, 'r') as f:
                lines = []
                for i, line in enumerate(f):
                    if i >= 16:  # 只读取前16行
                        break
                    lines.append(line.strip())
                return lines
        except FileNotFoundError:
            print(f"错误：找不到内存文件 {self.mem1_file}")
            return []
    
    def _parse_instruction(self, inst_str: str) -> Dict:
        """解析指令字符串，提取操作码和其他字段"""
        if len(inst_str) != 28:
            return None
            
        inst_bits = inst_str
        # 根据InstDecoder.v定义：opcode = inst_reg[INST_WIDTH-23:INST_WIDTH-26]
        # INST_WIDTH=28，所以是位[5:2]
        # 在28位字符串中，位[5:2]对应索引[5:2]（从右数）
        # 但Python字符串索引是从左开始，所以需要转换
        # 位[5:2]在字符串中对应索引[25:22]（从右数第2-5位）
        opcode = int(inst_bits[22:26], 2)  # 位[5:2] = 索引[25:22]
        
        return {
            'opcode': opcode,
            'opcode_name': self.OPCODES.get(opcode, f"UNKNOWN_{opcode}"),
            'raw': inst_str
        }
    
    def _get_micro_instruction_address(self, opcode: int) -> int:
        """根据操作码从mem1.hex前16行获取微指令首地址"""
        if opcode >= len(self.mem1_data):
            return 0
        return int(self.mem1_data[opcode], 16)
    
    def _get_loop_counts(self, instruction: Dict, level: int = None) -> Tuple[int, int, int, int]:
        """
        根据指令获取4个循环数
        基于InstDecoder.v中的逻辑，使用assembler.py中的字段定义
        """
        if level is None:
            level = self.FRODO_640
            
        opcode = instruction['opcode']
        inst_bits = instruction['raw']
        
        loop_0 = loop_1 = loop_2 = loop_3 = 0
        
        if opcode == 0b1000:  # ABSORB
            # 根据InstDecoder.v实际代码：loop_0 <= {inst_reg[INST_WIDTH-27:INST_WIDTH-28],inst_reg[INST_WIDTH-13:INST_WIDTH-18]}
            # INST_WIDTH=28, INST_WIDTH-27=1, INST_WIDTH-28=0, 所以是位[1:0]
            # INST_WIDTH-13=15, INST_WIDTH-18=10, 所以是位[15:10]
            # 位[1:0]对应字符串索引[26:28]，位[15:10]对应字符串索引[12:18]
            length_high = int(inst_bits[26:28], 2)  # 位[1:0]
            length_low = int(inst_bits[12:18], 2)    # 位[15:10]
            loop_0 = (length_high << 6) | length_low  # 直接赋值，不乘以8
        elif opcode == 0b1011:  # ABSORB_STRM  
            # 根据InstDecoder.v：loop_0 <= {inst_reg[INST_WIDTH-27:INST_WIDTH-28],inst_reg[INST_WIDTH-13:INST_WIDTH-18]}
            loop_high = int(inst_bits[26:28], 2)  # 位[1:0]
            loop_low = int(inst_bits[12:18], 2)   # 位[15:10]
            loop_0 = (loop_high << 6) | loop_low
            if level == self.FRODO_640:
                loop_1 = 168
            elif level == self.FRODO_976:
                loop_1 = 136
            elif level == self.FRODO_1344:
                loop_1 = 136
        elif opcode == 0b1100:  # SQUEEZE_STRM
            # 根据InstDecoder.v：loop_0 <= {inst_reg[INST_WIDTH-27:INST_WIDTH-28],inst_reg[INST_WIDTH-13:INST_WIDTH-18]}
            loop_high = int(inst_bits[26:28], 2)  # 位[1:0]
            loop_low = int(inst_bits[12:18], 2)   # 位[15:10]
            loop_0 = (loop_high << 6) | loop_low
            loop_1 = 84 if level == self.FRODO_640 else 68
        elif opcode == 0b1001:  # SQUEEZE
            # 根据InstDecoder.v实际代码：loop_0 <= {inst_reg[INST_WIDTH-27:INST_WIDTH-28],inst_reg[INST_WIDTH-13:INST_WIDTH-18]}
            length_high = int(inst_bits[26:28], 2)  # 位[1:0]
            length_low = int(inst_bits[12:18], 2)    # 位[15:10]
            loop_0 = (length_high << 6) | length_low  # 直接赋值，不乘以4
        elif opcode == 0b0100:  # AMATMUL
            if level == self.FRODO_640:
                loop_0, loop_1, loop_2, loop_3 = 640, 7, 21, 52
            elif level == self.FRODO_976:
                loop_0, loop_1, loop_2, loop_3 = 976, 11, 21, 52
            elif level == self.FRODO_1344:
                loop_0, loop_1, loop_2, loop_3 = 1344, 15, 21, 84
        elif opcode == 0b0001:  # ENCDEC
            # ENCDEC指令的mode字段在位[6]
            decode_flag = inst_bits[21] == '1'  # 位[6]
            if decode_flag:
                loop_0, loop_1, loop_2 = 4, 16, 2 if level == self.FRODO_640 else (3 if level == self.FRODO_976 else 4)
            else:
                loop_0 = 4
                loop_1 = 2 if level == self.FRODO_640 else (3 if level == self.FRODO_976 else 4)
                loop_2 = 16
        elif opcode == 0b0010:  # MATMUL
            loop_0 = 640 if level == self.FRODO_640 else (976 if level == self.FRODO_976 else 1344)
            loop_1 = 8
        elif opcode == 0b0101:  # MATADD
            loop_0 = 16
        elif opcode == 0b1010:  # HASH_RND
            # HASH_RND指令的length字段在位[19:10]
            length = int(inst_bits[8:18], 2)  # 位[19:10]
            # 根据InstDecoder.v，HASH_RND的循环数计算方式不同
            # 这里需要根据实际硬件逻辑来确定
            loop_0 = length // 8  # 假设按8位对齐
        
        return loop_0, loop_1, loop_2, loop_3
    
    def _reset_simulation_state(self):
        """重置模拟状态"""
        self.total_cycles = 0
        self.current_instruction = 0
        self.current_upc = 0
        self.registers = {}
        self.delay_slot_count = 0
        self.pending_jump = None
        self.loop_counters = [0, 0, 0, 0]  # 重置循环计数器
    
    def _parse_micro_instruction(self, uinst_str: str) -> Dict:
        """解析微指令，提取控制信号
        根据MicrocodeAssembler的字段定义：
        - DONE: 位[0], 1位
        - UPC_ST: 位[1:3], 3位 (最高位为使能，低2位为索引)
        - UPC_UP: 位[4:6], 3位 (最高位为使能，低2位为索引)
        - STALL: 位[20], 1位 (对应wait信号)
        """
        if len(uinst_str) != 26:
            return None
        
        # 不反转字符串，直接使用原始字符串
        uinst_bits = uinst_str
        
        # 根据mininst.py的字段定义，正确提取位字段
        # DONE: 位[0] - 字符串索引[25]
        done = int(uinst_bits[25]) == 1
        
        # UPC_ST: 位[1:3] - 字符串索引[24:22]
        upc_st_raw = int(uinst_bits[22:25], 2)
        upc_st_enable = (upc_st_raw & 0b100) != 0         # 最高位为使能
        upc_st_index = upc_st_raw & 0b011                 # 低2位为索引
        
        # UPC_UP: 位[4:6] - 字符串索引[21:19]
        upc_up_raw = int(uinst_bits[19:22], 2)
        upc_up_enable = (upc_up_raw & 0b100) != 0        # 最高位为使能
        upc_up_index = upc_up_raw & 0b011                 # 低2位为索引
        
        # STALL: 位[20] - 字符串索引[5]
        stall = int(uinst_bits[5]) == 1
        
        return {
            'upc_st': upc_st_enable,
            'upc_up': upc_up_enable,
            'stall': stall,
            'done': done,
            'raw': uinst_str,
            'upc_st_index': upc_st_index,                 # UPC_ST的索引
            'upc_up_index': upc_up_index                 # UPC_UP的索引
        }
    
    def _execute_micro_instruction(self, uinst: Dict, loop_counts: Tuple[int, int, int, int]) -> bool:
        """
        执行微指令，返回是否继续执行
        返回False表示微程序结束（done信号）
        
        Args:
            uinst: 微指令字典
            loop_counts: 循环数元组 (loop_0, loop_1, loop_2, loop_3)
        """
        self.total_cycles += 1
        
        # 处理upc_st：根据UPC_ST索引存储到对应寄存器
        if uinst['upc_st']:
            reg_index = uinst['upc_st_index']
            self.registers[reg_index] = self.current_upc + 1
            # print(f"    upc_st: 保存upc+1={self.current_upc + 1}到寄存器{reg_index}")
        
        # 处理upc_up：根据UPC_UP索引从对应寄存器恢复upc，但有2个周期延迟槽
        # 循环数影响upc_up执行的次数，loop0-3对应寄存器0-3
        if uinst['upc_up']:
            reg_index = uinst['upc_up_index']
            # 检查寄存器索引是否在有效范围内
            if 0 <= reg_index <= 3:  # 寄存器索引范围是0-3
                # 检查寄存器中是否有值
                if reg_index in self.registers:
                    target_upc = self.registers[reg_index]
                    loop_count = loop_counts[reg_index]
                    # print(f"    upc_up: 从寄存器{reg_index}跳转到upc={target_upc}，循环数={loop_count}，延迟槽=2")
                    
                    # 如果循环数大于0，需要执行多次跳转
                    if loop_count > 0:
                        # 增加对应寄存器的循环计数
                        self.current_loop_counters[reg_index] += 1
                        # print(f"    循环计数器[{reg_index}] = {self.current_loop_counters[reg_index]}/{loop_count}")
                        
                        # 如果循环计数未达到目标，继续跳转
                        if self.current_loop_counters[reg_index] < loop_count:
                            self.delay_slot_count = 2  # 设置延迟槽计数器
                            self.pending_jump = target_upc  # 保存目标地址
                            # print(f"    循环计数: {self.current_loop_counters[reg_index]}/{loop_count}")
                        else:
                            # 循环完成，重置计数器，不执行跳转，继续执行后续微指令
                            self.current_loop_counters[reg_index] = 0  # 重置循环计数器
                            # print(f"    循环{reg_index}完成，重置计数器")
                    else:
                        # 循环数为0，不执行跳转，继续执行后续微指令
                        # print(f"    循环数为0，不执行跳转，继续执行")
                        pass
                else:
                    # print(f"    upc_up: 寄存器{reg_index}中无值，忽略跳转")
                    pass
            else:
                print(f"    upc_up: 寄存器索引{reg_index}超出范围(0-3)")
        
        # 处理stall：等待200个周期
        if uinst['stall']:
            # print(f"    stall: 等待200个周期")
            self.total_cycles += 199  # 加上额外的199个周期（当前周期已计入）
        
        # 处理done：微程序结束
        if uinst['done']:
            # print(f"    done: 微程序结束")
            return False  # 遇到done信号，立即结束指令执行
        
        # 延迟槽处理
        if self.delay_slot_count > 0:
            self.delay_slot_count -= 1
            # print(f"    延迟槽剩余: {self.delay_slot_count}")
            if self.delay_slot_count == 0:
                # 延迟槽结束，执行跳转
                if hasattr(self, 'pending_jump'):
                    # 跳转到目标地址-1，因为主循环会+1
                    self.current_upc = self.pending_jump - 1
                    # print(f"    执行跳转到upc={self.pending_jump}")
                    delattr(self, 'pending_jump')
                    # 返回True，主循环会+1，最终upc=pending_jump
                    return True
            # 延迟槽期间，upc正常递增
            self.current_upc += 1
            return True
        
        # 正常情况下，不在这里递增upc，由主循环负责递增
        return True
    
    def simulate_instruction(self, inst_index: int, level: int = None) -> int:
        """
        模拟执行一条指令
        
        Args:
            inst_index: 指令在inst.bin中的索引
            level: 安全等级
            
        Returns:
            该指令执行的周期数
        """
        if level is None:
            level = self.FRODO_640
            
        if inst_index >= len(self.instructions):
            print(f"错误：指令索引 {inst_index} 超出范围")
            return 0
        
        # 解析指令
        instruction = self._parse_instruction(self.instructions[inst_index])
        if not instruction:
            print(f"错误：无法解析指令 {inst_index}")
            return 0
        
        # 重置模拟状态，确保每次指令执行都是独立的
        self._reset_simulation_state()
        
        # 获取微指令首地址
        upc_start = self._get_micro_instruction_address(instruction['opcode'])
        self.current_upc = upc_start
        
        # 获取循环数
        loop_counts = self._get_loop_counts(instruction, level)
        print(f"正在执行指令 {inst_index}: {instruction['opcode_name']} (opcode={instruction['opcode']}) - loop_0={loop_counts[0]}, loop_1={loop_counts[1]}, loop_2={loop_counts[2]}, loop_3={loop_counts[3]}")
        # print(f"  原始指令: {instruction['raw']}")
        # print(f"  微指令起始地址: {upc_start}")
        
        # 为本次指令初始化循环计数器
        self.current_loop_counters = [0, 0, 0, 0]
        
        # 记录开始周期数
        start_cycles = self.total_cycles
        
        # 输出微指令执行过程
        # print(f"  开始执行微指令，起始地址: {upc_start}")
        # print(f"  当前upc: {self.current_upc}, 总周期: {self.total_cycles}")
        
        # 执行微指令序列，传入循环数
        while self.current_upc < len(self.micro_instructions):
            uinst_str = self.micro_instructions[self.current_upc]
            uinst = self._parse_micro_instruction(uinst_str)
            
            if not uinst:
                print(f"错误：无法解析微指令 {self.current_upc}")
                break
                
            # 输出正在执行的微指令和循环计数器信息
            # if uinst['upc_st'] or uinst['upc_up'] or uinst['stall'] or uinst['done']:
            #     print(f"  微指令 {self.current_upc}: upc_st={uinst['upc_st']}, upc_up={uinst['upc_up']}, stall={uinst['stall']}, done={uinst['done']}")
            
            # 输出循环计数器状态
            if any(self.current_loop_counters):
                loop_info = []
                for i, count in enumerate(self.current_loop_counters):
                    if count > 0:
                        loop_info.append(f"循环计数器[{i}]={count}")
                if loop_info:
                    print(f"指令 {inst_index} ({instruction['opcode_name']}) 微指令 {self.current_upc}: {', '.join(loop_info)}")
            
            # 执行微指令，传入循环数
            if not self._execute_micro_instruction(uinst, loop_counts):
                # print(f"  微程序结束 (done信号)")
                break
                
            self.current_upc += 1
        
        # 计算该指令的周期数
        instruction_cycles = self.total_cycles - start_cycles
        print(f"  指令 {inst_index} 执行完成，周期数: {instruction_cycles}")
        print()
        
        return instruction_cycles
    
    def simulate_range(self, start_inst: int, end_inst: int, level: int = None) -> Dict:
        """
        模拟执行指令范围内的所有指令
        
        Args:
            start_inst: 起始指令索引
            end_inst: 结束指令索引  
            level: 安全等级
            
        Returns:
            包含总周期数和详细信息的字典
        """
        if level is None:
            level = self.FRODO_640
            
        print(f"开始模拟指令范围 {start_inst} 到 {end_inst}")
        print(f"安全等级: {level} ({'FRODO_640' if level == self.FRODO_640 else 'FRODO_976' if level == self.FRODO_976 else 'FRODO_1344'})")
        print("=" * 50)
        
        # 重置模拟状态
        self._reset_simulation_state()
        
        total_cycles = 0
        instruction_details = []
        
        for i in range(start_inst, min(end_inst + 1, len(self.instructions))):
            cycles = self.simulate_instruction(i, level)
            total_cycles += cycles
            instruction_details.append({
                'index': i,
                'cycles': cycles,
                'instruction': self.instructions[i]
            })
        
        result = {
            'total_cycles': total_cycles,
            'instruction_count': end_inst - start_inst + 1,
            'start_inst': start_inst,
            'end_inst': end_inst,
            'level': level,
            'details': instruction_details
        }
        
        print("=" * 50)
        print(f"模拟完成！")
        print(f"总周期数: {total_cycles}")
        print(f"指令数量: {result['instruction_count']}")
        print(f"平均每指令周期数: {total_cycles / result['instruction_count']:.2f}")
        
        return result

def main():
    """主函数"""
    # 文件路径
    inst_file = "src/sim/bin/inst.bin"
    uinst_file = "src/sim/bin/uinst.bin" 
    mem1_file = "src/sim/hex/mem1.hex"
    
    # 检查文件是否存在
    for file_path in [inst_file, uinst_file, mem1_file]:
        if not os.path.exists(file_path):
            print(f"错误：文件不存在 {file_path}")
            return
    
    # 创建模拟器
    simulator = FrodoCycleSimulator(inst_file, uinst_file, mem1_file)
    
    # 示例：模拟前5条指令
    print("Frodo低资源周期统计模拟器")
    print("=" * 50)
    
    # 模拟指令0-4（前5条指令）
    result = simulator.simulate_range(268,312, simulator.FRODO_1344)
    
    # 输出详细结果
    print("\n详细结果:")
    for detail in result['details']:
        print(f"指令 {detail['index']}: {detail['cycles']} 周期")

if __name__ == "__main__":
    main()
