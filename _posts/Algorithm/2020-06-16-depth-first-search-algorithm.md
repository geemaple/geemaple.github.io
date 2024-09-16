---
layout: post
title: "算法 - 深度优先搜索DFS"
categories: Algorithm
tags: DFS
excerpt: "爆破专家"
---

* content
{:toc}

## 深度优先搜索

深度优先搜索，是一条路走到黑(不撞南墙不回头)，然后在选择其他路径的策略。其中从路的尽头一步步*状态回退*的过程，称作回溯。
所以，深度优先搜索，也可称之为回溯算法(Backtracking)

深度优先搜索，通常通过递归来完成，非递归代码，使用Stack数据结构。

非递归代码要难得多，只需掌握树的三种DFS的非递归代码即可

DFS适用：排列+组合 + 暴力破解 + 切割问题

## 图搜索

对于图的深度优先遍历，一定要记得去重(也就是递归出口)。

```python
# 对于去重使用的哈希算法，它的时间复杂度为O(N), 大多数的时候我们认为它的时间复杂度为O(1), 是因为我们假定输入长度在常量范围内。比如最长的单词也只有45个字母, O(45) = O(1)
len("pneumonoultramicroscopicsilicovolcanoconiosis") = 45
```

**矩阵是一种特殊的图:**

```python
                                |-------------------  x
1 2 3        - 1 - 2 - 3 -      |   - 1 - 2 - 3 -  
               |   |   |        |     |   |   |
4 5 6   =>   - 4 - 5 - 6 -  =>  |   - 4 - 5 - 6 -
               |   |   |        |     |   |   |
7 8 9        - 7 - 8 - 9 -      |   - 7 - 8 - 9 -
                                y
```

更进一步，由于矩阵非常工整，我们可以认为它是坐标系上的点。点的位置移动，可以使用坐标转换数组, 以图中的*5*为例，它的坐标为(a, b), 它的上下左右可以分别:

```python
a = (1, 1)
x = [0, 0, -1, 1]  
y = [-1, 1, 0, 0]

for i in range(len(y)):
  targetX = a + x[i]
  targetY = b + y[i]
```

## 树搜索

树是一种特殊的图(树没有环状结构，不需要去重)，它的深度优先搜索以二叉树为例，有三种遍历策略，是以遍历root的三种策略命名的

1. 前序遍历(**根**左右)
2. 中序遍历(左**根**右)
3. 后续遍历(左右**根**)

**拓扑排序**

DFS主要判断拓扑排序有没有环路出现，正常构造图，结果需要反向；亦或逆向构造图，直接返回结果

个人推荐更简单的宽度优先搜索算法BFS

```python
class Solution:
    def findOrder(self, numCourses: int, prerequisites: List[List[int]]) -> List[int]:
        graph = defaultdict(list)
        for x in prerequisites:
            graph[x[1]].append(x[0])
        
        visited = {}  # 访问状态
        path = set()  # 路径状态，用于检测环
        res = []  # 存储拓扑排序结果
        
        for course in range(numCourses):
            if course not in visited:
                if not self.dfs(course, graph, visited, path, res):  # 如果存在环，返回空列表
                    return []
        
        return res[::-1]  # 反转结果，返回正确的拓扑排序

    def dfs(self, course: int, graph: defaultdict(list), visited: list, path: list, res: list) -> bool:
        if course in path:  # 检测到环
            return False
        if course in visited:  # 如果已经访问过，直接返回
            return True
        
        # 标记路径与回溯
        path.add(course)
        for neighbor in graph[course]:  # 遍历所有邻接节点
            if not self.dfs(neighbor, graph, visited, path, res):  # 如果DFS返回False，说明存在环
                return False
        path.remove(course)

        # 当前节点处理完后，加入结果并标记为已访问
        visited[course] = True
        res.append(course)
        return True
```

## 暴力破解

DFS另一个擅长的领域是，排列组合(Permutation/Combination)，也可以说通过穷举所有可能，来达到搜索的目的。

常见的标志是，找出*所有(find-all)*的答案。

时间复杂度 = 答案个数 * 构造每个答案的时间, 可以通过预处理，或者剪枝来达到优化的效果， 时间复杂度在2^N~N!级别

**列举了所有适用情况，最好的方式是通过代码学习:**

### 排列

```python
[1, 1', 1'', 2] [1, 1'' ,1', 2] [1', 1, 1'', 2] [1', 1'', 1, 2] [1'', 1, 1', 2] [1'', 1', 1, 2]
```

对于上述重复答案，我们当然选择[1, 1', 1'', 2]作为答案代表。它的特点是，重复数据**1**，必须递增连续出现**1，1'，1''**

```python
# https://leetcode.com/problems/permutations-ii/
class Solution(object):
  def permuteUnique(self, nums):
    """
    :type nums: List[int]
    :rtype: List[List[int]]
    """
    result = []
    state = []
    visited = set()
    self.helper(sorted(nums), state, visited, result)
    return result
        
  def helper(self, nums, state, visited, result):
      
    if len(nums) == len(state):
        result.append(list(state)) #state一定要复制
        return
      
    for i in range(0, len(nums)):
      if i in visited: 
        continue
        
      # 去重，以[1, 1', 1'', 2]为代表，重复数字要连续取，不能跳着取
      # 所以如果和前面数字一样，并且上一个数i-1没用过，就跳过
      if i != 0 and nums[i] == nums[i - 1] and i - 1 not in visited: 
        continue
        
      visited.add(i)

      state.append(nums[i])
      self.helper(nums, state, visited, result)
      state.pop() # 回溯

      visited.remove(i)
```

### 组合

```python
# https://leetcode.com/problems/subsets-ii/
class Solution(object):
  def subsetsWithDup(self, nums):
    """
    :type nums: List[int]
    :rtype: List[List[int]]
    """
    result = []
    state = []
    self.helper(sorted(nums), 0, state, result)
    return result
        
  def helper(self, nums, start, state, result):
      
    result.append(list(state)) #state一定要复制
      
    for i in range(start, len(nums)):
      # 和排列一样，除此之外，可以肯定上一个数(start-1), 一定使用过
      # 所以如果和前面数字一样，并且上一个数i-1没用过，就跳过
      # if i != 0 and nums[i] == nums[i - 1] && i - 1 != start - 1: 
      if i != start and nums[i] == nums[i - 1]: 
        continue
      state.append(nums[i])
      self.helper(nums, i + 1, state, result)
      state.pop() # 回溯
```

## N皇后

```python
class Solution:
    def totalNQueens(self, n: int) -> int:
        self.res = 0
        self.helper(n, 0, 0, 0, 0)
        return self.res
        
    def helper(self, n: int, row: int, cols: int, rd:int, ld:int) -> None:
        
        if row == n:
            self.res += 1
            return
        
        # (cols | rd | ld) 三个方向取或，0就是没有占用的位置
        # ～取反，1就是没有占用的位置, 但是32位的头部0也会变成1 
        # 所以, ((1 << n) - 1)只有后这些位置是有意义的。
        candidate = ~(cols | rd | ld) & ((1 << n) - 1) 
        
        while candidate > 0:
            
            # 得到末尾的1(负数的表示正数取反+1), 获得放置位置
            p = candidate & -candidate 
            
            # 往下递归时，列垂直向下, ↖️↘️往右移一位, ↙️↗️往左移一位
            self.helper(n, row + 1, cols | p, (rd | p) >> 1, (ld | p) << 1)
            
            # 消掉末尾的1
            candidate &= candidate - 1  
```

## 子组数 vs. 子序列

子组数(subarray)，子串(substring), 窗口(window): 原数组，起点i到终点j*连续的*部分，数量级为N^2

```python
array = [1,2,3,4]

N = j - i + 1, 作为滑动窗口
长度为N的   ->有1个, 
长度为N-1的 ->有2个, 
...
长度为1的   ->有N个,

非空答案 = (1 + N) * N / 2

subarray = [1] [1,2] [1,2,3] [1,2,3,4] [2] [2,3] [2,3,4] [3] [3,4] [4] # 非空共10 substring是一种特殊的数组
```


子序列(subsequence): 结果元素相对顺序保持不变, 数量级为2^N

```python
array = [1,2,3,4]

第1个元素, 可以选择要or不要, 2种可能
第2个元素, 可以选择要or不要, 2种可能
...
第N个元素, 可以选择要or不要, 2种可能

答案 = 2 ^ N

subsequence = [] [1] [2] [3] [4] [1,2] [1,3] [1,4] [2,3] [2,4] [3,4] [1,2,3] [1,2,4] [1,3,4] [2,3,4] [1,2,3,4] //共16个
```

--End--
