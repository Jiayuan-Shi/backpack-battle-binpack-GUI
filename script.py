# -*- coding: utf-8 -*-
import numpy as np
import numpy as np
import matplotlib.pyplot as plt
import random
import itertools
import copy
import time
import pickle
print('pack:', pack_data)
print('cont:', cont_data)

def save_data(data, filename):
    with open(filename, 'wb') as file:  # 'wb'表示以二进制写模式打开
        pickle.dump(data, file)


class bages():
    def __init__(self,nrows,ncols,list_elements,type):
        self.nrows = nrows
        self.ncols = ncols
        self.mat = np.array(list_elements).reshape(nrows, ncols)
        self.type = type
    def push_index(self,index):
        self.index = index
        return self
    def get_sum(self):
        self.sum = sum([sum(row) for row in self.mat])
        return self.sum
    def rolling(self,direction):
        self.direction = direction
        if direction == 1:
            # 顺时针旋转90度：先转置，然后沿着垂直轴翻转
            self.mat = np.flip(self.mat.T, axis=1)
        elif direction == 2:
            # 旋转180度：先沿着垂直轴翻转，然后沿着水平轴翻转
            self.mat = np.flip(np.flip(self.mat, axis=1), axis=0)
        elif direction == 3:
            # 逆时针旋转90度：先转置，然后沿着水平轴翻转
            self.mat = np.flip(self.mat.T, axis=0)
        self.nrows = self.mat.shape[0]
        self.ncols = self.mat.shape[1]
        return self

class board():
    def __init__(self,board,color_board):
            self.board = board
            self.color_board = color_board
            self.nrows, self.ncols = board.shape
    def get_sum(self):
        self.sum = sum([sum(row) for row in self.board])
        return self.sum
    def can_place(self, bages, start_row, start_col):
        rows, cols = bages.mat.shape
        if start_row + rows > self.nrows or start_col + cols > self.ncols:
            return False
        test_board = np.copy(self.board)
        test_board[start_row:start_row + rows, start_col:start_col + cols] += bages.mat
        if np.any(test_board > 1) :
            return False
        return True
    def place(self, bages, start_row, start_col):
        rows, cols = bages.mat.shape
        self.board[start_row:start_row + rows, start_col:start_col + cols] += bages.mat
        self.color_board[start_row:start_row + rows, start_col:start_col + cols] += bages.type * bages.mat
        return self
    def remove(self, bages, start_row, start_col):
        rows, cols = bages.mat.shape
        self.board[start_row:start_row + rows, start_col:start_col + cols] -= bages.mat
        self.color_board[start_row:start_row + rows, start_col:start_col + cols] -= bages.type * bages.mat
        return self

def backpack_collections(input_packs):
    rows = []
    cols = []
    list_elements = []
    sums = []
    numbers = []
    for i in input_packs:
        rows.append(i[0])
        cols.append(i[1])
        list_elements.append(i[2])
        sums.append(sum(i[2]))
        numbers.append(i[3])
    theindex = np.argsort(np.array(sums))[::-1]
    output_packs = []
    k = 0
    for j in theindex:
        k += 1
        output_packs.extend(itertools.repeat(bages(rows[j],
                                                   cols[j],
                                                   list_elements[j],
                                                   k),numbers[j]))
    m = 0
    for l in output_packs:
        l.push_index(m)
        m += 1
    return output_packs

def backtracking(board, pack_lists, pack_index=0, solution_collections=None):
    if solution_collections is None:
        solution_collections = []
    if board.get_sum() == board.nrows*board.ncols:
        # 如果所有的方块都已尝试放置，记录当前板的状态
        solution_collections.append(copy.deepcopy(board))
        return
    if pack_index < len(pack_lists):  # 确保不会超出pack_lists的索引范围
        pack = pack_lists[pack_index]
        for direction in range(4):
            pack_rolled = copy.deepcopy(pack)
            pack_rolled = pack_rolled.rolling(direction)

            for row in range(board.nrows - pack_rolled.nrows + 1):
                for col in range(board.ncols - pack_rolled.ncols + 1):
                    if board.can_place(pack_rolled, row, col):
                        # 如果当前方块可以放置，则放置方块
                        board.place(pack_rolled, row, col)
                        # 递归尝试放置下一个方块
                        backtracking(board, pack_lists, pack_index + 1, solution_collections)
                        # 回溯：移除刚才放置的方块
                        board.remove(pack_rolled, row, col)
    # 在当前层级的所有方向和位置尝试后，如果没有成功放置方块，也需要尝试下一个方块
    # 这是为了处理当某个方块无论如何都放不下，但可能其他的方块组合能够成功的情况
    if pack_index + 1 < len(pack_lists):
        backtracking(board, pack_lists, pack_index + 1, solution_collections)
    if pack_index == 0:
        return solution_collections

def plot_mat(mat):
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
    plt.show()

def main():
    start = time.time()
    for pack in pack_data:
        if not isinstance(pack[2], list):
            pack[2] = [pack[2]]

    input_packs = pack_data
    input_cont = np.array(cont_data[2]).reshape(cont_data[0],cont_data[1])
    myboard = board(input_cont, np.zeros((cont_data[0], cont_data[1])))
    pack_lists = backpack_collections(input_packs)
    a = backtracking(myboard, pack_lists)
    global runing_time
    global solution_count
    solution_count = len(a)
    color_collection = []
    for i in a:
        color_collection.append(i.color_board)

    save_data(color_collection, 'solution_data.pkl')

    end = time.time()
    runing_time = str(end - start)

if __name__ == "__main__":
    main()