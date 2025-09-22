import numpy as np
from typing import List, Optional, Union

def hex_string_to_matrix(
    hex_str: str,
    rows: Optional[int] = None,
    cols: Optional[int] = None,
    as_numpy: bool = True
) -> Union[np.ndarray, List[List[int]]]:
    """
    将十六进制字符串按每四位转换为无符号 16 位整数，并重塑为指定尺寸矩阵。

    参数:
        hex_str (str): 输入的十六进制字符串（可带空格或 0x 前缀）。
        rows (int or None): 矩阵行数。如果为 None，则根据 cols 自动推算。
        cols (int or None): 矩阵列数。如果为 None，则根据 rows 自动推算。
        as_numpy (bool): 是否返回 numpy.ndarray；否则返回 Python 列表。

    返回:
        numpy.ndarray 或 List[List[int]]: 重塑后的矩阵，或一维列表/数组（若 rows 和 cols 都为 None）。
    """

    # 清洗输入
    s = hex_str.strip().replace(" ", "").lower()
    if s.startswith("0x"):
        s = s[2:]
    # 必须是 4 的倍数
    if len(s) % 4 != 0:
        raise ValueError("Hex 字符串长度必须是 4 的倍数")
    total_words = len(s) // 4  # 每 4 个 hex 字符表示一个 16 位数

    # 解析成 16 位整数列表
    values = [int(s[i:i+4], 16) for i in range(0, len(s), 4)]

    # 推断维度或校验
    if rows is not None and cols is not None:
        if rows * cols != total_words:
            raise ValueError(f"rows*cols={rows*cols} 与 total_words={total_words} 不匹配")
    elif rows is not None:
        if total_words % rows != 0:
            raise ValueError(f"无法将 {total_words} 个元素均分为 {rows} 行")
        cols = total_words // rows
    elif cols is not None:
        if total_words % cols != 0:
            raise ValueError(f"无法将 {total_words} 个元素均分为 {cols} 列")
        rows = total_words // cols
    else:
        # 均未指定，返回一维
        if as_numpy:
            return np.array(values, dtype=np.uint16)
        else:
            return values

    # 重塑为矩阵
    if as_numpy:
        return np.array(values, dtype=np.uint16).reshape(rows, cols)
    else:
        return [values[i*cols:(i+1)*cols] for i in range(rows)]


# 使用示例
if __name__ == "__main__":
    hex_input = "fb3ecd955f51cb1cb2679557a2eea4c01a81d670f1ee721ed3953d218604a72f5ed3b41f4834edf054810f96128a63e9d8dc60a490713e2fe44064b0d17ddc9fc866c86bacff830d5df1c977a472cd9d46f89dc42ba848554af3025f861bc423a5b58899d745113cc9d3c0fc28e17fce1e9490a8ae8ae131c75e6a01b1683fb401dbf41fffefa42a2d55307f699a5a395e95be894d04d9f6a51838e24224ca11987006a76db364bb"  # 示例：16 字符，共 4 个 16 位数
    # 转为 2×2 矩阵
    # 或者只指定行数，自动推列数
    mat2 = hex_string_to_matrix(hex_input, rows=1)
    print("列表矩阵：", mat2)
