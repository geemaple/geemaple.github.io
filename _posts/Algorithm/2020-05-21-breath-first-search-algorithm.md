---
layout: post
title: "算法 - 广度优先搜索BFS"
categories: Algorithm
tags: BFS
excerpt: "拓扑排序"
---

* content
{:toc}

## 宽度优先搜索

宽度优先搜索。是把最近的邻居节点都访问之后，在选择更远邻居的一种策略。很像把一块石头丢到水里，水波纹一层层向外扩散的过程。所以宽度优先搜索，更形象的称之为层级搜索

非递归代码，通过队列**Queue**来完成。考虑到递归的缺点，加上BFS实现简单, BFS一般不用递归来实现

BFS适用于：层级遍历，图是否连通，拓扑排序，(同权重)最短路径

## 拓扑排序

```sh
1 ->
       3  -> 4 -> 5
2 ->

# 拓扑序列: [1, 2 ,3, 4, 5] 或 [2, 1, 3, 4, 5]
```

对于有向无环图(**DAG**), 至少有一个拓扑排序。

拓扑排序主要对于有依赖关系的一组任务，给出一个可执行的序列。此外拓扑排序还可以判断有没有循环依赖， 比如编译循环依赖检测，内存泄漏等问题。

常见的问题有，对于给定的一组依赖关系，有没有可能拓扑排序，如果有，输出其中一个结果

### 课程排序

```python
# https://leetcode.com/problems/course-schedule-ii/
# 现在你总共有 n 门课需要选，记为 0 到 n-1。
# 在选修某些课程之前需要一些先修课程。 例如，想要学习课程 0 ，你需要先完成课程 1 ，我们用一个匹配来表示他们: [0,1]
# 给定课程总量以及它们的先决条件，返回你为了学完所有课程所安排的学习顺序。
# 可能会有多个正确的顺序，你只要返回一种就可以了。如果不可能完成所有课程，返回一个空数组。
from collections import defaultdict, deque
class Solution:
    def findOrder(self, numCourses: int, prerequisites: List[List[int]]) -> List[int]:
        graph = defaultdict(list)
        indegree = defaultdict(int)
        for x in prerequisites:
            graph[x[1]].append(x[0])
            indegree[x[0]] += 1

        res = []
        q = deque([x for x in range(numCourses) if indegree[x] == 0])
        while len(q) > 0:
            cur = q.popleft()
            res.append(cur)
            for node in graph[cur]:
                indegree[node] -= 1
                if indegree[node] == 0:
                    q.append(node)

        return res if len(res) == numCourses else []
```

--End--