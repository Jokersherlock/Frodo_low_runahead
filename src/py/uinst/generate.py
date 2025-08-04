import numpy as np

def generate_and_save_matrix(rows, cols, min_val, max_val, file_path):
    """
    生成一个指定大小的矩阵，并将其保存到指定的txt文件中。
    
    参数:
    - rows: 矩阵的行数
    - cols: 矩阵的列数
    - min_val: 矩阵元素的最小值
    - max_val: 矩阵元素的最大值
    - file_path: 保存矩阵的文件路径
    """
    # 生成指定大小的矩阵，元素在 min_val 和 max_val 之间的随机整数
    matrix = np.random.randint(min_val, max_val, size=(rows, cols))
    
    # 将矩阵保存到指定txt文件中，使用空格分隔
    np.savetxt(file_path, matrix, fmt="%d", delimiter=" ")
    
    print(f"Matrix of size {rows}x{cols} saved to {file_path}.")

# 示例调用：
generate_and_save_matrix(8, 32, -15, 15, "./sim_data/A.txt")
generate_and_save_matrix(32, 8, -15, 15, "./sim_data/B.txt")
generate_and_save_matrix(8, 8, -15, 15, "./sim_data/C.txt")
