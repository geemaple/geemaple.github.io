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

### 层级遍历

```python
from collections import deque
class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        if root is None:
            return []

        res = []
        q = deque([root])
        while len(q) > 0:
            size = len(q) # 这个大小单独保存额外重要
            level = []
            for i in range(size):
                node = q.popleft()
                level.append(node.val)
                if node.left:
                    q.append(node.left)
                if node.right:
                    q.append(node.right)
            res.append(level)
        return res
```

### 图的连通性

判断一个图是否是一个树:

1. n个点，n-1条边
2. 图连通

```python
class Solution(object):
    def validTree(self, n, edges):
        """
        :type n: int
        :type edges: List[List[int]]
        :rtype: bool
        """
        if n != 1 + len(edges):
            return False
        
        graph = {i : [] for i in range(n)}
        for i in range(len(edges)):
            graph[edges[i][0]].append(edges[i][1])
            graph[edges[i][1]].append(edges[i][0])
            
        visted = set()
        queue = [0]
        
        while len(queue) > 0:
            tmp = queue.pop(0)
            visted.add(tmp)
            
            for neighbor in graph[tmp]:
                if neighbor not in visted:
                    queue.append(neighbor)
                    
        return len(visted) == n
```

### 最短路径

棋盘上，起始从起点到终点的最短路径

```python
class Solution:
    def shortestPath(self, grid, source, destination) ->int:
        directions = [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
        q = [(source.x, source.y)]
        steps = 0
        grid[source.x][source.y] = True

        while len(q) > 0:
            size = len(q)
            for i in range(size):
                x, y = q.pop(0)
                if x == destination.x and y == destination.y:
                    return steps

                for i in range(8):
                    new_x = x + directions[i][0]
                    new_y = y + directions[i][1]
                    if 0 <= new_x < len(grid) and 0 <= new_y < len(grid[x]) and not grid[new_x][new_y]:
                        grid[new_x][new_y] = True
                        q.append((new_x, new_y))

            steps += 1

        return -1
```

### 拓扑排序

```sh
1 ->
       3  -> 4 -> 5
2 ->

# 拓扑序列: [1, 2 ,3, 4, 5] 或 [2, 1, 3, 4, 5]
```

对于有向无环图(**DAG**), 至少有一个拓扑排序。

拓扑排序主要对于有依赖关系的一组任务，给出一个可执行的序列。此外拓扑排序还可以判断有没有循环依赖， 比如编译循环依赖检测，内存泄漏等问题。

常见的问题有，对于给定的一组依赖关系，有没有可能拓扑排序，如果有，输出其中一个结果

BFS的方式也叫做**Kahn算法**，是一种贪心算法，没有任何依赖节点直接访问，然后断掉依赖重复，最后判断访问的点的个数是否满足

### 课程排序

```python
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