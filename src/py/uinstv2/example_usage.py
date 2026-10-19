#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Frodo周期统计模拟器使用示例
"""

from cycle_simulator import FrodoCycleSimulator

def main():
    """主函数 - 使用示例"""
    print("Frodo周期统计模拟器使用示例")
    print("=" * 60)
    
    # 文件路径
    inst_file = "src/sim/bin/inst.bin"
    uinst_file = "src/sim/bin/uinst.bin" 
    mem1_file = "src/sim/hex/mem1.hex"
    
    try:
        # 创建模拟器
        simulator = FrodoCycleSimulator(inst_file, uinst_file, mem1_file)
        
        print(f"✓ 成功加载文件:")
        print(f"  - 指令文件: {len(simulator.instructions)} 条指令")
        print(f"  - 微指令文件: {len(simulator.micro_instructions)} 条微指令")
        print(f"  - 内存文件: {len(simulator.mem1_data)} 行数据")
        print()
        
        # 示例1: 模拟单条指令
        print("示例1: 模拟单条指令")
        print("-" * 30)
        cycles = simulator.simulate_instruction(0, simulator.FRODO_640)
        print(f"指令0执行周期数: {cycles}")
        print()
        
        # 示例2: 模拟指令范围
        print("示例2: 模拟指令范围 (指令0-2)")
        print("-" * 30)
        result = simulator.simulate_range(0, 2, simulator.FRODO_640)
        
        print("\n详细统计:")
        print(f"总周期数: {result['total_cycles']}")
        print(f"指令数量: {result['instruction_count']}")
        print(f"平均每指令周期数: {result['total_cycles'] / result['instruction_count']:.2f}")
        
        print("\n各指令详情:")
        for detail in result['details']:
            print(f"  指令{detail['index']}: {detail['cycles']} 周期")
        
        # 示例3: 不同安全等级的对比
        print("\n示例3: 不同安全等级对比")
        print("-" * 30)
        
        levels = [
            (simulator.FRODO_640, "FRODO_640"),
            (simulator.FRODO_976, "FRODO_976"), 
            (simulator.FRODO_1344, "FRODO_1344")
        ]
        
        for level, level_name in levels:
            result = simulator.simulate_range(0, 1, level)
            print(f"{level_name}: {result['total_cycles']} 周期")
        
        print("\n✓ 模拟完成！")
        
    except FileNotFoundError as e:
        print(f"✗ 文件未找到: {e}")
        print("请确保以下文件存在:")
        print(f"  - {inst_file}")
        print(f"  - {uinst_file}")
        print(f"  - {mem1_file}")
    except Exception as e:
        print(f"✗ 模拟过程中出错: {e}")

if __name__ == "__main__":
    main()
