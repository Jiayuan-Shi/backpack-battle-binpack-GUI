# -*- coding: utf-8 -*-
import matplotlib.pyplot as plt
import pickle
def plot_mat(mat):
    plt.figure()
    # 使用matplotlib的tab10颜色图，它为不同的数值提供了高区分度的颜色
    cmap = plt.get_cmap("tab10")
    norm = plt.Normalize(vmin=0, vmax=10)  # 设置数值范围从0到10
    plt.imshow(mat, cmap=cmap, norm=norm)
    # 添加颜色条以展示不同数值对应的颜色
    plt.colorbar()
    # 画分割线，确保它们覆盖整个图像范围
    for x in range(len(mat[0]) + 1):
        plt.axvline(x - 0.5, color='k', linestyle='-', linewidth=1)
    for y in range(len(mat) + 1):
        plt.axhline(y - 0.5, color='k', linestyle='-', linewidth=1)
    plt.axis('off')  # 去除坐标轴
    plt.savefig("plot.png")
    plt.close()
    
def load_data(filename):
    with open(filename, 'rb') as file:  # 'rb'表示以二进制读模式打开
        return pickle.load(file)

# 使用函数读取数据
a_loaded = load_data('solution_data.pkl')
plot_mat(a_loaded[index-1])
print("Loaded solutions:", index)
