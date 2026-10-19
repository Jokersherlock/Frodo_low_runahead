#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试Frodo周期统计模拟器
"""

from cycle_simulator import FrodoCycleSimulator

def test_simulator():
    """测试模拟器基本功能"""
    print("测试Frodo周期统计模拟器")
    print("=" * 50)
    
    # 文件路径
    inst_file = "src/sim/bin/inst.bin"
    uinst_file = "src/sim/bin/uinst.bin" 
    mem1_file = "src/sim/hex/mem1.hex"
    
    try:
        # 创建模拟器
        simulator = FrodoCycleSimulator(inst_file, uinst_file, mem1_file)
        
        print(f"加载了 {len(simulator.instructions)} 条指令")
        print(f"加载了 {len(simulator.micro_instructions)} 条微指令")
        print(f"加载了 {len(simulator.mem1_data)} 行内存数据")
        print()
        
        # 测试前3条指令
        print("测试前3条指令的模拟:")
        result = simulator.simulate_range(0, 2, simulator.FRODO_640)
        
        print("\n详细结果:")
        for detail in result['details']:
            print(f"指令 {detail['index']}: {detail['cycles']} 周期")
            print(f"  指令内容: {detail['instruction']}")
        
        return True
        
    except Exception as e:
        print(f"测试失败: {e}")
        return False

if __name__ == "__main__":
    test_simulator()
