import math
import numpy as np
from typing import Union, List

class MemoryData:
    def __init__(self, matrix, data_bit_width=8, start_addr=0, matrix_name="default_matrix"):
        """
        初始化 MemoryData 对象。

        参数:
            matrix (list of list of int): 存储器测试数据的矩阵，每个元素为数据值。
            data_bit_width (int): 数据的实际位宽，默认为8，只能为8或16。
            start_addr (int): 存储器数据的起始地址（按照64位存储单元计算）。
            matrix_name (str): 矩阵的名字，用于标识该测试数据矩阵。
        """
        if data_bit_width not in (8, 16):
            raise ValueError("data_bit_width 必须是 8 或 16")
            
        self.matrix = matrix
        self.data_bit_width = data_bit_width
        self.start_addr = start_addr
        self.matrix_name = matrix_name
        self.end_addr = self._calculate_end_addr()
        
    def _calculate_end_addr(self):
        """
        根据矩阵大小与数据位宽计算末地址（按64位存储器单元计算）。

        流程：
          1. 统计矩阵中总元素数。
          2. 总位数 = 元素个数 * 数据位宽。
          3. 需要的64位存储单元数 = ceil(总位数 / 64)。
          4. 末地址 = 起始地址 + 单元数 - 1。
        """
        num_elements = sum(len(row) for row in self.matrix)
        total_bits = num_elements * self.data_bit_width
        words_needed = math.ceil(total_bits / 64)
        return self.start_addr + words_needed - 1

    def __repr__(self):
        matrix_dim = f"{len(self.matrix)}x{len(self.matrix[0])}" if self.matrix and self.matrix[0] else "0x0"
        return (f"MemoryData(name='{self.matrix_name}', start_addr={self.start_addr}, end_addr={self.end_addr}, "
                f"data_bit_width={self.data_bit_width}, matrix_size={matrix_dim})")


class Memory:
    def __init__(self, bit_width: int = 64, length: int = 4096):
        """
        初始化 Memory 对象。

        参数:
            bit_width (int): 存储单元位宽，固定为64。
            length (int): 存储单元数量（64位宽），默认4096。
        """
        if bit_width != 64:
            raise ValueError("Memory bit_width must be 64")
        self.bit_width = bit_width
        self.length = length
        # 使用整数列表模拟存储器，每个元素表示一个64位存储单元的内容
        self._words = [0] * self.length
    def add_memory_data(self, mem_data) -> None:
        """
        将 MemoryData 对象的数据写入到主存中。

        小端按整块写入：
        - 8位数据时，每个64位单元存8个数据；
        - 16位数据时，每个64位单元存4个数据。
        """
        flat = [int(val) for row in mem_data.matrix for val in row]
        bw = mem_data.data_bit_width
        start = mem_data.start_addr
        elems_per_word = self.bit_width // bw
        mask = (1 << bw) - 1
        # 总共要写入的单元数
        total_words = math.ceil(len(flat) / elems_per_word)
        for w in range(total_words):
            word_index = start + w
            if word_index >= self.length:
                raise IndexError(f"Address {word_index} out of memory range")
            chunk = flat[w*elems_per_word:(w+1)*elems_per_word]
            word_val = 0
            for i, v in enumerate(chunk):
                if v < 0 or v > mask:
                    raise ValueError(f"Value {v} out of range for bit width {bw}")
                offset = i * bw
                word_val |= (v & mask) << offset
            self._words[word_index] = word_val

    def modify_word(self, addr: int, value: int) -> None:
        """
        修改指定存储单元的内容。

        参数:
            addr (int): 64位存储单元地址。
            value (int): 要写入的64位值。
        """
        if not (0 <= addr < self.length):
            raise IndexError(f"Address {addr} out of memory range")
        if value < 0 or value >= (1 << self.bit_width):
            raise ValueError(f"Value {value} out of range for 64-bit width")
        self._words[addr] = value
    
    def store_hex_string_little_endian(self, hex_string: str, start_addr: int) -> None:
        """
        将十六进制字符串以小端序存入RAM。
        
        参数:
            hex_string (str): 十六进制字符串，如 '92F267AAFA3F87CA60D01CB54F29202A'
            start_addr (int): 起始地址（64位存储单元地址）
        
        示例:
            输入 '92F267AAFA3F87CA60D01CB54F29202A'，起始地址0
            第0个地址存入: CA873FFAAA67F292
            第1个地址存入: 2A20294FB51CD060
        """
        # 移除可能的空格和0x前缀
        hex_string = hex_string.replace(' ', '').replace('0x', '').upper()
        
        # 确保字符串长度为偶数
        if len(hex_string) % 2 != 0:
            raise ValueError("十六进制字符串长度必须为偶数")
        
        # 将字符串转换为字节数组
        try:
            byte_data = bytes.fromhex(hex_string)
        except ValueError as e:
            raise ValueError(f"无效的十六进制字符串: {e}")
        
        # 按64位（8字节）为单位分组，小端序存储
        bytes_per_word = 8
        num_words = (len(byte_data) + bytes_per_word - 1) // bytes_per_word
        
        for word_idx in range(num_words):
            word_addr = start_addr + word_idx
            if word_addr >= self.length:
                raise IndexError(f"地址 {word_addr} 超出内存范围")
            
            # 提取8字节数据
            start_byte = word_idx * bytes_per_word
            end_byte = min(start_byte + bytes_per_word, len(byte_data))
            word_bytes = byte_data[start_byte:end_byte]
            
            # 如果不足8字节，用0填充
            while len(word_bytes) < bytes_per_word:
                word_bytes += b'\x00'
            
            # 小端序组装64位值
            word_value = 0
            for i, byte_val in enumerate(word_bytes):
                word_value |= (byte_val << (i * 8))
            
            self._words[word_addr] = word_value
    
    def export_to_file(self, filename: str, file_type: str = 'bin') -> None:
        """
        将当前内存内容输出到文件。

        参数:
            filename (str): 文件路径。
            file_type (str): 输出格式，'bin' 或 'hex'。
        """
        if file_type == 'bin':
            fmt = '{:064b}'
        elif file_type == 'hex':
            fmt = '{:016X}'
        else:
            raise ValueError("file_type must be 'bin' or 'hex'")
        with open(filename, 'w') as f:
            for word in self._words:
                f.write(fmt.format(word) + '\n')


class MemoryReader:
    """
    从 bin 或 hex 文件中读取存储内容，并可按需重构矩阵。
    """
    def __init__(self, filename: str, file_type: str = 'bin'):
        self.words: List[int] = []
        self._load_file(filename, file_type)

    def _load_file(self, filename: str, file_type: str) -> None:
        base = 2 if file_type == 'bin' else 16 if file_type == 'hex' else None
        if base is None:
            raise ValueError("file_type must be 'bin' or 'hex'")
        with open(filename, 'r') as f:
            for line in f:
                s = line.strip()
                if not s:
                    continue
                self.words.append(int(s, base))

    def read_matrix(self, start_addr: int, rows: int, cols: int,
                    data_bit_width: int, signed: bool = True) -> List[List[int]]:
        """
        从指定地址开始，按行优先顺序解析出矩阵。

        参数:
            start_addr: 起始64位单元地址
            rows: 矩阵行数
            cols: 矩阵列数
            data_bit_width: 元素位宽，8、15 或 16
            signed: 是否以有符号数读取

        返回:
            二维 int 矩阵，维度 rows x cols
        """
        if data_bit_width not in (8, 15, 16):
            raise ValueError("data_bit_width must be 8, 15 or 16")
        if data_bit_width == 15:
            elems_per_word = 64 // 16  # 15位模式下，按16位对齐
            mask = (1 << 15) - 1
            bit_width_for_offset = 16
        else:
            elems_per_word = 64 // data_bit_width
            mask = (1 << data_bit_width) - 1
            bit_width_for_offset = data_bit_width
        total = rows * cols
        flat: List[int] = []
        for idx in range(total):
            word_index = start_addr + idx // elems_per_word
            if word_index >= len(self.words):
                raise IndexError(f"Address {word_index} out of memory range")
            offset = (idx % elems_per_word) * bit_width_for_offset
            value = (self.words[word_index] >> offset) & mask
            if signed:
                # 进行有符号扩展
                sign_bit = 1 << (15 if data_bit_width == 15 else data_bit_width - 1)
                if value & sign_bit:
                    value = value - (1 << (15 if data_bit_width == 15 else data_bit_width))
            flat.append(value)
        # reshape
        matrix: List[List[int]] = []
        for r in range(rows):
            row_vals = flat[r * cols:(r + 1) * cols]
            matrix.append(row_vals)
        return matrix

    def __repr__(self) -> str:
        return f"MemoryReader(words={len(self.words)} entries)"
