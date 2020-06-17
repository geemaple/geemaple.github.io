---
layout: post
title: "深度优先搜索算法DFS"
categories: 算法
tags: DFS 算法
excerpt: "爆破专家"
---

## 深度优先搜索

深度优先搜索，是一条路走到黑(不撞南墙不回头)的策略，然后在选择其他路径。其中从路的尽头一步步*状态回退*的过程，称作回溯。

所以，深度优先搜索，也可称之为回溯算法(Backtracing)

深度优先搜索，通常通过递归来完成，非递归代码，可以使用Stack数据结构。

非递归代码要难得多，只需掌握树的三种DFS的非递归代码

DFS适用：排列+组合 + 暴力破解 + 切割问题

## 图的深度优先搜索

对于图的深度优先遍历，一定要记得去重(也就是递归出口)。

> 对于去重使用的哈希算法，它的时间复杂度为O(N), 大多数的时候我们认为它的时间复杂度为O(1), 是因为我们假定输入长度在常量范围内。比如最长的单词也只有45个字母, O(45) = O(1)

```
len("pneumonoultramicroscopicsilicovolcanoconiosis") = 45
```

### 矩阵是一种特殊的图

```
                                |-------------------  x
1 2 3        - 1 - 2 - 3 -      |   - 1 - 2 - 3 -  
               |   |   |        |
4 5 6   =>   - 4 - 5 - 6 -  =>  |   - 4 - 5 - 6 -
               |   |   |        | 
7 8 9        - 7 - 8 - 9 -      |   - 7 - 8 - 9 -
                                y
```

更进一步，由于矩阵非常工整，我们可以认为它是坐标系上的点。点的位置移动，可以使用坐标转换数组, 以图中的*5*为例，它的坐标为(a, b), 它的上下左右可以分别:

```
a = (1, 1)
x = [0, 0, -1, 1]  
y = [-1, 1, 0, 0]

for i in range(len(y)):
  targetX = a + x[i]
  targetY = b + y[i]
```

### 树的深度优先搜索

树是一种特殊的图(树没有环状结构，不需要去重)，它的深度优先搜索以二叉树为例，有三种遍历策略，是以遍历root的三种策略命名的

1. 前序遍历(**根**左右)
2. 中序遍历(左**根**右)
3. 后续遍历(左右**根**)

具体遍历，参考之前的文章[《树的三种DFS策略(前序、中序、后序)遍历》](http://geemaple.github.io/2018/09/09/树的三种DFS策略(前序-中序-后序)遍历/)

### 拓扑排序

这里提一下，如果谷歌"Topological Sort", 靠前面的答案，给的都是DFS解决。

但从实现上，推荐更简单的[《宽度优先搜索算法BFS》](http://geemaple.github.io/2020/05/21/宽度优先搜索算法BFS/)

## 穷举暴力破解

DFS另一个擅长的领域是，排列组合(Permutation/Combination)，也可以说通过穷举所有可能，来达到破解的目的。

常见的标志是，找出*所有(find-all)*的答案。

时间复杂度 = 答案个数 * 构造每个答案的时间, 可以通过预处理，或者剪枝来达到优化的效果， 时间复杂度在N! ~ 2^N级别

### [排列](https://leetcode.com/problems/permutations-ii/)

```
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
        
      #如果和前面数字一样，并且前面也没用过，就跳过
      if i != 0 and nums[i] == nums[i - 1] and i - 1 not in visited: 
        continue
        
      visited.add(i)

      state.append(nums[i])
      self.helper(nums, state, visited, result)
      state.pop() # 回溯

      visited.remove(i)
```

### [组合](https://leetcode.com/problems/subsets-ii/)

```
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
      #同排列注释，i != 0 and nums[i] == nums[i - 1] and i != start
      if i != start and nums[i] == nums[i - 1]: 
        continue
      state.append(nums[i])
      self.helper(nums, i + 1, state, result)
      state.pop() # 回溯
```


### 子组数 vs. 子序列

子组数(subarray)，子串(substring): 原数组，起点i到终点j*连续的*部分，数量级为N^2

子序列(subsequence): 结果元素相对顺序保持不变, 素组从头开始, 每个元素选择*要or不要*, 数量级为2^N

```
array = [1,2,3,4]

subarray = [1] [1,2] [1,2,3] [1,2,3,4] [2] [2,3] [2,3,4] [3] [3,4] [4] # 非空共10 substring是一种特殊的数组

subsequence = [] [1] [2] [3] [4] [1,2] [1,3] [1,4] [2,3] [2,4] [3,4] [1,2,3] [1,2,4] [1,3,4] [2,3,4] [1,2,3,4] //共16个
```

--End--