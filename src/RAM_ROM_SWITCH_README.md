# RAM/ROM 例化方式切换说明

## 概述
本工程支持两种RAM/ROM例化方式：
1. **仿真模式**：使用自定义的 `dual_ram` 和 `rom` 模块
2. **综合模式**：使用IP核（`mem0`, `mem1`, `inst_rom`, `uinst_rom`）

## 切换方法

### 仿真模式（默认）
在 `rtl/include/global_define.v` 文件中，确保 `USE_IP_CORE` 宏被注释掉：

```verilog
// 仿真/综合模式切换宏定义
// 注释掉下面这行使用仿真模式（dual_ram, rom模块）
// 取消注释使用综合模式（IP核）
// `define USE_IP_CORE
```

### 综合模式
在 `rtl/include/global_define.v` 文件中，取消注释 `USE_IP_CORE` 宏：

```verilog
// 仿真/综合模式切换宏定义
// 注释掉下面这行使用仿真模式（dual_ram, rom模块）
// 取消注释使用综合模式（IP核）
`define USE_IP_CORE
```

## 影响的模块

### 1. Frodo.v
- **指令ROM**：`inst_rom` (IP核) vs `rom` (仿真模块)
- **数据存储器**：`mem0`, `mem1` (IP核) vs `dual_ram` (仿真模块)

### 2. Control.v
- **微指令ROM**：`uinst_rom` (IP核) vs `rom` (仿真模块)

## 文件路径说明

### 仿真模式文件路径
- 指令文件：`../../../../../../src/sim/bin/inst.bin`
- 微指令文件：`../../../../../../src/sim/bin/uinst.bin`
- 数据存储器文件：
  - mem0: `../../../../../../src/sim/hex/mem0.hex`
  - mem1: `../../../../../../src/sim/hex/mem1.hex`

### IP核模式
- 需要预先生成对应的IP核文件
- 确保IP核的接口与代码中的例化一致

## 注意事项

1. **路径设置**：仿真模式下的文件路径是相对于仿真工作目录的，请确保路径正确
2. **IP核生成**：使用综合模式前，需要先使用Vivado等工具生成对应的IP核
3. **接口一致性**：确保IP核的接口与代码中的例化参数一致
4. **编译顺序**：修改宏定义后需要重新编译整个工程

## 使用建议

- **开发调试阶段**：建议使用仿真模式，便于调试和验证
- **综合实现阶段**：建议使用IP核模式，获得更好的性能和资源利用率
