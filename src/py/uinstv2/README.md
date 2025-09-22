# FrodoKEM 微指令生成器 v2

## 目录结构

重构后的项目采用模块化设计，按功能组织代码：

```
uinstv2/
├── __init__.py              # 主包初始化
├── main.py                  # 主入口文件
├── README.md               # 项目说明
├── core/                   # 核心功能模块
│   ├── __init__.py
│   ├── algorithm_base.py   # 算法基类
│   ├── algorithm_factory.py # 算法工厂
│   ├── assembler.py        # 汇编器
│   └── memory.py           # 内存管理
├── algorithms/             # 具体算法实现
│   ├── __init__.py
│   ├── keygen640.py        # 密钥生成算法
│   └── encaps640.py        # 封装算法
├── instructions/           # 微指令定义
│   ├── __init__.py
│   ├── absorb.py           # 吸收指令
│   ├── absorb_byte.py      # 字节吸收指令
│   ├── squeeze.py          # 挤压指令
│   ├── squeeze_strm.py   # 流挤压指令
│   ├── hash_rnd.py         # 哈希随机数指令
│   ├── Amatmul.py          # A矩阵乘法指令
│   ├── mininst.py          # 微指令汇编器
│   └── uinst_assembler.py  # 微指令综合汇编器
├── utils/                  # 工具函数
│   ├── __init__.py
│   └── eval.py             # 评估工具
├── tests/                  # 测试文件
│   ├── __init__.py
│   ├── test.py             # 基本测试
│   └── tb_memory.py        # 内存测试
└── data/                   # 数据文件
    ├── A_matrix_*.txt      # A矩阵数据
    ├── B_matrix_*.txt      # B矩阵数据
    ├── S_matrix_*.txt      # S矩阵数据
    └── ...                 # 其他数据文件
```

## 模块说明

### 1. 核心模块 (core/)

- **algorithm_base.py**: 定义所有算法的基类，提供统一接口
- **algorithm_factory.py**: 算法工厂，支持动态创建和管理算法
- **assembler.py**: 微指令汇编器，将高级指令转换为二进制代码
- **memory.py**: 内存管理类，支持数据存储和读取

### 2. 算法模块 (algorithms/)

- **keygen640.py**: FrodoKEM-640密钥生成算法实现
- **encaps640.py**: FrodoKEM-640封装算法实现
- 可扩展添加更多算法（如解密算法、其他安全级别等）

### 3. 指令模块 (instructions/)

- **absorb.py**: 吸收指令实现
- **squeeze.py**: 挤压指令实现
- **hash_rnd.py**: 哈希随机数指令实现
- **Amatmul.py**: A矩阵乘法指令实现
- 其他微指令实现

### 4. 工具模块 (utils/)

- **eval.py**: 算法评估和验证工具

### 5. 测试模块 (tests/)

- **test.py**: 基本功能测试
- **tb_memory.py**: 内存管理测试

## 使用方法

### 基本使用

```python
from uinstv2 import get_algorithm, list_available_algorithms

# 列出可用算法
print("可用算法:", list_available_algorithms())

# 创建算法实例
keygen = get_algorithm("keygen640")

# 生成指令
instructions, output_file = keygen.generate_and_save()
```

### 直接使用算法类

```python
from uinstv2.algorithms import Keygen640Generator

# 创建算法实例
generator = Keygen640Generator()

# 生成指令
instructions, output_file = generator.generate_and_save()
```

### 批量生成

```python
from uinstv2.core import AlgorithmFactory

# 创建工厂
factory = AlgorithmFactory()

# 生成所有算法
results = factory.generate_all_algorithms()
```

## 扩展新算法

### 1. 创建算法类

```python
from uinstv2.core import FrodoAlgorithmBase
from typing import List, Dict, Any

class NewAlgorithmGenerator(FrodoAlgorithmBase):
    def __init__(self, output_dir="../../sim/bin"):
        super().__init__("NewAlgorithm", output_dir)
    
    def _define_instructions(self) -> List[Dict[str, Any]]:
        return [
            # 定义具体的微指令序列
            {'instruction_type': 'ABSORB_BYTE', 'fields': {'byte': 0x5f}},
            # ... 更多指令
        ]
```

### 2. 注册到工厂

```python
from uinstv2.core import AlgorithmFactory
from uinstv2.algorithms.new_algorithm import NewAlgorithmGenerator

# 注册新算法
factory = AlgorithmFactory()
factory.register_algorithm("new_algorithm", NewAlgorithmGenerator)
```

## 优势

1. **模块化设计**: 按功能组织代码，便于维护和扩展
2. **统一接口**: 所有算法使用相同的接口，便于管理
3. **可扩展性**: 轻松添加新算法和新功能
4. **类型安全**: 使用类型提示，提高代码质量
5. **测试友好**: 独立的测试模块，便于单元测试

## 运行示例

```bash
# 运行主程序
python main.py

# 运行特定算法
python -c "from uinstv2 import get_algorithm; get_algorithm('keygen640').generate_and_save()"
```
