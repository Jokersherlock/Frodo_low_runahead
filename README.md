# Frodo_low_overhead 工程说明

## 工程简介
本工程为FrodoKEM格基公钥加密算法的软硬件协同实现，包含完整的FPGA硬件设计、Python参考实现、仿真测试、综合与功耗分析等内容。适用于格密码算法的硬件加速、验证与研究。

## 目录结构
```
Frodo_low_overhead/
├── src/                # 源码目录
│   ├── rtl/            # Verilog硬件设计（顶层、核心、控制、运算、哈希、驱动等）
│   ├── py/             # Python参考实现与辅助工具
│   ├── coe/            # 存储初始化文件（coe/hex/bin）
│   └── sim/            # 仿真测试文件
├── prj/                # Vivado工程文件
├── ptpx/               # 功耗与时序分析报告
├── dc/                 # 综合相关报告
├── doc/                # 文档目录
```

## 主要功能模块
- **Python实现**：`src/py/frodo`为FrodoKEM算法的纯软件实现，`src/py/uinst`为微指令/矩阵等辅助生成与验证工具。
- **硬件RTL**：`src/rtl`为核心Verilog实现，包括顶层（Frodo_top/Top）、控制、核心、解码/编码、哈希、矩阵运算、驱动等模块。
- **仿真测试**：`src/sim/tb_top.v`为顶层仿真激励，配合driver自动化测试。
- **工程与IP核**：`prj/Frodo`为Vivado工程，包含IP核、约束、生成文件等。
- **报告分析**：`ptpx`、`dc`目录下为功耗、时序、综合等分析报告。

## 快速开始
1. **Python功能测试**：
   ```bash
   cd src/py/frodo
   python run_frodokem.py
   ```
2. **Vivado工程**：
   - 用Vivado 2024.2及以上版本打开`prj/Frodo/Frodo.xpr`，可进行综合、实现、仿真等操作。
3. **仿真**：
   - 推荐使用Vivado自带仿真器，或ModelSim等工具，仿真入口为`src/sim/tb_top.v`。

## 主要文件说明
- `src/rtl/Frodo_top.v`：硬件顶层，接口定义与内存管理。
- `src/rtl/Top.v`：系统顶层，集成driver与Frodo_top。
- `src/rtl/driver/driver.v`：自动化测试驱动。
- `src/py/frodo/frodokem.py`：FrodoKEM算法Python实现。
- `src/py/uinst/frodokem_top.py`：Python端微指令/矩阵生成与验证。
