---
layout: post
title: "算法 - 最短路径Shortest Path"
categories: Algorithm
tags: 最短路径
excerpt: 这是捷径么
---

* content
{:toc}

## 最短路径算法

### 搜索算法

使用BFS算法，如果访问节点的距离更短则更新。由于没有**某种排序**，无法确定某个点是否是当前最短的。所以不能够用传统哈希去重复，因为另一条路径可能更短。

```python
from collections import defaultdict, deque
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        graph = defaultdict(dict)
        for u, v, w in times:
            graph[u][v] = w

        q = deque([(0, k)])
        t = [float('inf') for i in range(n + 1)]

        while len(q) > 0:
            delay, cur = q.popleft()
            if delay < t[cur]:
                t[cur] = delay
                for node, time in graph[cur].items():
                    q.append((time + delay, node))

        res = max(t[1:]) # 第0个没用，忽略掉
        return res if res < float('inf') else -1

class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        graph = defaultdict(dict)
        for u, v, w in times:
            graph[u][v] = w

        t = [float('inf') for i in range(n + 1)]
        self.dfs(graph, t, k, 0)

        res = max(t[1:]) # 第0个没用，忽略掉
        return res if res < float('inf') else -1

    def dfs(self, graph: dict, t: list, cur: int, delay: int):
        if delay >= t[cur]:
            return

        t[cur] = delay
        for node, time in graph[cur].items():
            self.dfs(graph, t, node, time + delay)
```

### Dijkstra算法

该算法的核心思想是**贪心算法**，通过每一步选择当前最短路径的节点，并以此更新其他节点的最短路径估计值，直到所有节点都被访问。

Dijkstra算法适用于**边权非负**的有向图或无向图

```python
from collections import defaultdict
import heapq
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        graph = defaultdict(dict)
        for u, v, w in times:
            graph[u][v] = w

        heap = [(0, k)]
        visited = set()
        res = 0
        while len(heap) > 0:
            delay, cur = heapq.heappop(heap)
            if cur in visited:
                continue

            visited.add(cur)
            res = delay

            for node, time in graph[cur].items():
                if node not in visited:
                    heapq.heappush(heap, (time + delay, node))

        return res if len(visited) == n else -1
```

### Bellman-Ford算法

它的核心思想是逐步松弛每条边：尝试用当前的最短路径去更新其他节点的最短路径。它可以正确处理包含负权边的图，并且可以检测负权环路（即路径长度无限减小的环路）。

`N`个点需要松弛`N - 1`次, 经过 n-1 次迭代后，如果还可以松弛任何边，则图中存在负权环

时间复杂度**O(VE)**

```python
from collections import defaultdict, deque
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        delay = [float('inf') for i in range(n + 1)]
        delay[k] = 0

        for _ in range(n): # n - 1 次
            for u, v, w in times:
                if delay[u] < float('inf') and delay[u] + w < delay[v]:
                    delay[v] = delay[u] + w

        res = max(delay[1:]) # 第0个没用，忽略掉
        return res if res < float('inf') else -1
```

### Floyd-Warshall算法

Floyd-Warshall 算法是一种经典的动态**规划算法**，用于计算有向图中所有节点之间的最短路径。它能够处理包含负权重的边，但不允许存在负权重的环

1. 定义dp为i到j的最短路径
2. 初始化自身可达，并且为0
3. 初始化边的权重

```python
class Solution:
    def networkDelayTime(self, times: List[List[int]], n: int, k: int) -> int:
        # 初始化距离矩阵
        dp = [[float('inf')] * (n + 1) for _ in range(n + 1)]
        
        # 设置对角线为0，表示到自身的距离为0
        for i in range(1, n + 1):
            dp[i][i] = 0
            
        # 填充初始边权
        for u, v, w in times:
            dp[u][v] = w

        # Floyd-Warshall 算法
        for mid in range(1, n + 1):
            for i in range(1, n + 1):
                for j in range(1, n + 1):
                    if dp[i][j] > dp[i][mid] + dp[mid][j]:
                        dp[i][j] = dp[i][mid] + dp[mid][j]

        # 获取从节点 k 到其他所有节点的最大延迟
        res = max(dp[k][1:])  # 忽略 dp[k][0]，只计算1到n的延迟
        return res if res < float('inf') else -1
```

-- END --