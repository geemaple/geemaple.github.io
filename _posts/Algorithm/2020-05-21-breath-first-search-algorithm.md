---
layout: post
title: "广度优先搜索算法BFS"
categories: Algorithm
tags: Algorithm BFS
excerpt: "拓扑排序"
---

* content
{:toc}

## 宽度优先搜索

宽度优先搜索。是把最近的邻居节点都访问之后，在选择更远邻居的一种策略。很像把一块石头丢到水里，水波纹一层层向外扩散的过程。所以宽度优先搜索，更形象的称之为层级搜索

非递归代码，通过队列**Queue**来完成。考虑到递归的缺点，加上BFS实现简单, BFS一般不用递归来实现

BFS适用于：层级遍历，图是否连通，拓扑排序，(同权重)最短路径

## 树与图

图的遍历，一定，一定，一定要去重复，重要的事情说三遍

树的遍历，就不需要去重复，因为根据树的定义，不可能有环出现

### 图是树的充分必要条件：

1. N个点，N-1条边
2. 所有点连通

## 图的表示

社交网络是图比较常用的切入话题之一，包括N度人脉，单向关注，好友关系

![graph_representation]({{site.static}}/images/graph_representation.png)

```python
edge(i, j)表示从点i到点j有一条边
```

### 边列表(edge lists)

每一个二元组代表，两个顶点之前有一条边，对于不连通的图，还需配合顶点列表List<V>

```python
[ [0,1], [0,6], [0,8], [1,4], [1,6], [1,9], [2,4], [2,6], [3,4], [3,5],
[3,8], [4,5], [4,9], [7,8], [7,9] ]
```

### 临接表(adjacency lists)

```python
# 比较常用
[ [1, 6, 8],     # 0 -> [1,6,8]   # edge(0, 1), edge(0, 6), edge(0, 8)
  [0, 4, 6, 9],  # 1 -> [0,4,6,9] # edge(1, 0), edge(1, 4), edge(1, 6), edge(1, 9)
  [4, 6],
  [4, 5, 8],
  [1, 2, 3, 5, 9],
  [3, 4],
  [0, 1, 2],
  [8, 9],
  [0, 3, 7],
  [1, 4, 7] ]
```

### 邻接矩阵(adjacency matrices)

```python
# edge(i,j) = M[i][j] = 1, 比较浪费存储
[ [0, 1, 0, 0, 0, 0, 1, 0, 1, 0],
  [1, 0, 0, 0, 1, 0, 1, 0, 0, 1],
  [0, 0, 0, 0, 1, 0, 1, 0, 0, 0],
  [0, 0, 0, 0, 1, 1, 0, 0, 1, 0],
  [0, 1, 1, 1, 0, 1, 0, 0, 0, 1],
  [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
  [1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
  [1, 0, 0, 1, 0, 0, 0, 1, 0, 0],
  [0, 1, 0, 0, 1, 0, 0, 1, 0, 0] ]
```

## 数据结构的存储

内存中的数据结构，类等，通常无法直接用来网络传输，或存储在磁盘上，要通过序列化之后进行

### 序列化：

object_to_string: 将内存中的数据结构，类等转化成字符串(字节组数)的过程

### 反序列化：

string_to_object: 将序列化结果，从新解析成对应数据结构的过程

常见的序列化有**xml, json, protobuf, thrift, yaml, plist**

设计权衡通常有**可读性，压缩率**

## 数据结构的拷贝

拷贝只对于复合数据结构(数组，类)才有所不同, 虽然不同语言处理细节不同, 但简单原则如下:

### 浅拷贝(reference)

尽可能拷贝的越少越好，无论是否返回​同一个对象，最终的数据源是共享的，一份数据的改变体现在所有的拷贝上

```python
A = C0
B = copy(A) = C0
# 如果C改变，那么B的状态也会改变
```

### 深拷贝(clone)

拷贝所有细节，返回不同的对象，最终的数据源是隔离的，一份数据的改变不会影响其他拷贝

深拷贝有潜在的诸多问题:

1. 拷贝内容过多, 通常解决的方案，是让开发者自己定义如何拷贝。
2. 循环拷贝, 属于图的遍历范畴，所以记得去重复。

```python
A = C0
B = deepcopy(A) = C1
# 如果C0改变，B的状态C1没有影响
```

## 拓扑排序

```
1 ->
       3  -> 4 -> 5
2 ->

# 拓扑序列: [1, 2 ,3, 4, 5] 或 [2, 1, 3, 4, 5]
```

对于有向无环图(**DAG**), 至少有一个拓扑排序。

拓扑排序主要对于有依赖关系的一组任务，给出一个可执行的序列。此外拓扑排序还可以判断有没有循环依赖， 比如编译循环依赖检测，内存泄漏等问题。

常见的问题有，对于给定的一组依赖关系，有没有可能拓扑排序，如果有，输出其中一个结果

### [课程排序](https://leetcode.com/problems/course-schedule-ii/)

```python
# leetcode-210(Course-Schedule-II)
# 现在你总共有 n 门课需要选，记为 0 到 n-1。
# 在选修某些课程之前需要一些先修课程。 例如，想要学习课程 0 ，你需要先完成课程 1 ，我们用一个匹配来表示他们: [0,1]
# 给定课程总量以及它们的先决条件，返回你为了学完所有课程所安排的学习顺序。
# 可能会有多个正确的顺序，你只要返回一种就可以了。如果不可能完成所有课程，返回一个空数组。
from collections import Counter, deque
class Solution(object):
    def findOrder(self, numCourses, prerequisites):
        """
        :type numCourses: int
        :type prerequisites: List[List[int]]
        :rtype: List[int]
        """
        res = []
        indegrees = Counter()
        edges = defaultdict(list)
        
        for pair in prerequisites:
            indegrees[pair[0]] += 1
            edges[pair[1]].append(pair[0])
            
        queue = deque()
        for i in range(numCourses):
            if indegrees[i] == 0:
                queue.append(i)
                
        while(len(queue) > 0):
            front = queue.popleft()
            res.append(front)

            for neighbor in edges[front]:
                indegrees[neighbor] -= 1
                if indegrees[neighbor] == 0:
                    queue.append(neighbor)
                    del indegrees[neighbor]
                    
        return [] if len(indegrees) > 0 else res 
```

--End--