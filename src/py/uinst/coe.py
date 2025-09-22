import os

# 简易版：读取文本或二进制文件，生成同名 .coe 文件

def bin2coe(path, radix=2):
    """
    支持两种输入：
    1) 文本文件，每行一个二进制字符串（长度不限）。
    2) 二进制文件，按字节读取，8位为一单元。
    输出 .coe 文件，radix 可选 2 或 16。
    """
    if not os.path.isfile(path):
        print(f"错误：文件不存在 -> {path}")
        return

    # 尝试按文本读取，判断是否全为 0/1
    try:
        with open(path, 'r') as f:
            lines = [l.strip() for l in f if l.strip()]
        if all(set(l) <= {'0','1'} for l in lines):
            # 文本模式，每行一个二进制词
            words = lines
            bit_width = len(words[0])
            if not all(len(w)==bit_width for w in words):
                print("错误：文本中各行长度不一致，无法确定位宽")
                return
        elif all(set(l.upper()) <= set('0123456789ABCDEF') for l in lines):
            # HEX文本模式，每行一个十六进制词
            words = [bin(int(l, 16))[2:].zfill(len(l)*4) for l in lines]
            bit_width = len(words[0])
            if not all(len(w)==bit_width for w in words):
                print("错误：HEX文本中各行长度不一致，无法确定位宽")
                return
        else:
            raise ValueError
    except Exception:
        # 二进制模式
        data = open(path, 'rb').read()
        bit_width = 8
        words = [f"{b:08b}" for b in data]

    # COE 文件输出
    coe_path = os.path.splitext(path)[0] + '.coe'
    with open(coe_path, 'w') as f:
        f.write(f"memory_initialization_radix = {radix};\n")
        f.write("memory_initialization_vector =\n")
        for i, w in enumerate(words):
            if radix==16:
                # 将二进制字符串转为 hex
                val = int(w, 2)
                hex_width = (bit_width + 3) // 4
                w_str = f"{val:0{hex_width}X}"
            else:
                w_str = w
            sep = ',' if i < len(words)-1 else ';'
            f.write(f"    {w_str}{sep}\n")

    print(f"生成 COE 文件: {coe_path} (bit width: {bit_width}, radix: {radix})")

if __name__ == '__main__':
    path = '../../src/coe/inst_coe/inst_v2.bin'
    bin2coe(path, 2)
    path = '../../src/coe/inst_coe/inst_ke.bin'
    bin2coe(path, 2)
    path = '../../src/coe/ram_coe/mem0.hex'
    bin2coe(path, 16)
