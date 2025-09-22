"""
指令合并示例

演示如何使用指令合并器将多个算法的二进制序列合并到inst.bin文件中。
"""

import sys
import os

# 添加当前目录到路径
sys.path.append(os.path.dirname(__file__))

from core import InstructionMerger, merge_algorithms
from algorithms import Keygen640Generator, Encaps640Generator


def example_manual_merge():
    """示例1：手动合并算法"""
    print("示例1：手动合并算法")
    print("="*50)
    
    # 创建指令合并器
    merger = InstructionMerger()
    
    # 创建算法实例
    keygen = Keygen640Generator()
    encaps = Encaps640Generator()
    
    # 添加算法到合并器
    merger.add_algorithm(keygen, "keygen640")
    merger.add_algorithm(encaps, "encaps640")
    
    # 保存合并后的指令
    output_file = merger.save_to_file("inst.bin")
    
    # 打印摘要
    merger.print_summary()
    
    return output_file


def example_convenient_merge():
    """示例2：使用便捷函数合并"""
    print("\n示例2：使用便捷函数合并")
    print("="*50)
    
    # 创建算法实例
    algorithms = [
        Keygen640Generator(),
        Encaps640Generator()
    ]
    
    algorithm_names = ["keygen640", "encaps640"]
    
    # 使用便捷函数合并
    output_file, positions = merge_algorithms(
        algorithms=algorithms,
        algorithm_names=algorithm_names,
        output_dir="../../sim/bin",
        filename="inst.bin"
    )
    
    print(f"\n合并完成！输出文件: {output_file}")
    print("算法位置信息:")
    for name, pos_info in positions.items():
        print(f"  {name}: 位置 {pos_info['start_position']} - {pos_info['start_position'] + pos_info['instruction_count'] - 1}")
    
    return output_file


def example_multiple_algorithms():
    """示例3：合并多个相同算法的实例"""
    print("\n示例3：合并多个相同算法的实例")
    print("="*50)
    
    merger = InstructionMerger()
    
    # 创建多个相同算法的实例（可能使用不同参数）
    keygen1 = Keygen640Generator()
    keygen2 = Keygen640Generator()
    encaps1 = Encaps640Generator()
    
    # 添加算法
    merger.add_algorithm(keygen1, "keygen640_v1")
    merger.add_algorithm(encaps1, "encaps640_v1")
    merger.add_algorithm(keygen2, "keygen640_v2")
    
    # 保存
    output_file = merger.save_to_file("multi_inst.bin")
    merger.print_summary()
    
    return output_file


def verify_output_file(file_path: str):
    """验证输出文件"""
    print(f"\n验证输出文件: {file_path}")
    print("-" * 30)
    
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        print(f"文件行数: {len(lines)}")
        print(f"首行内容: {lines[0].strip()}")
        print(f"首行长度: {len(lines[0].strip())}")
        
        # 检查首行是否为全0
        first_line = lines[0].strip()
        if first_line == "0000000000000000000000000000":
            print("✓ 首行正确：全0")
        else:
            print(f"✗ 首行错误：{first_line}")
        
        # 显示前几行
        print("\n前5行内容:")
        for i, line in enumerate(lines[:5]):
            print(f"  {i}: {line.strip()}")
        
        if len(lines) > 5:
            print(f"  ... (共{len(lines)}行)")
            
    except Exception as e:
        print(f"验证失败: {e}")


def main():
    """主函数"""
    print("FrodoKEM 指令合并器演示")
    print("="*60)
    
    # 运行示例
    try:
        # 示例1：手动合并
        file1 = example_manual_merge()
        verify_output_file(file1)
        
        # 示例2：便捷函数合并
        file2 = example_convenient_merge()
        verify_output_file(file2)
        
        # 示例3：多算法合并
        file3 = example_multiple_algorithms()
        verify_output_file(file3)
        
        print("\n🎉 所有示例运行完成！")
        
    except Exception as e:
        print(f"❌ 运行失败: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
