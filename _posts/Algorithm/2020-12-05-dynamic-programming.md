---
layout: post
title: "算法 - 动态规划DP"
categories: Algorithm
tags: DP
excerpt: "纸上得来终觉浅，绝知此事要躬行"
---

* content
{:toc}

## 动归思想

> 递归，动归都是一种思想。而分治是一种算法。

子问题，通常规模更小，更容易求出答案

说到动态规划，其实离不开递归的思想，也就是把问题拆解成子问题

动态规划，是将复杂的问题，递归拆解成**最优**子问题，避免**重复计算**的编程方法

那这里隐含两个要素:

1. **最优子问题**
2. **重复计算**, 倘若计算过程没有重复，那就变成了分治算法了

以斐波那契额数列为例F(n) = F(n - 2) + F(n - 1)

```python
          f(5)
         /    \  
    'f(3)'     f(4)
      /\        /\
   f(1) f(2) f(2) 'f(3)'
```

1. 其中F(5)可以通过子问题F(3) + F(4)得出
2. 关键是，图中f(3)等节点的计算包含重复，而且是整棵树的重复

### 记忆化搜索

方向: 从"大问题"到"小问题"

也就是正常的递归+记忆化搜索，优点可能是比较容易想到，缺点可能会栈溢出，无法优化空间

每当遇到一个计算，先看表里有没有已经算好的，如果有就直接用上。

没有的话，计算好后，放入表中，等待将来查找

```python
from functools import lru_cache
class Solution:
    @lru_cache(maxsize=None)
    def fib(self, N: int) -> int:
        if N < 2:
            return N
        
        return self.fib(N - 2) + self.fib(N - 1) 
```

### 状态数组

方向: 从"小问题"到"大问题"

1. **最后一步**(是怎样能够得到答案的)
2. **化成子问题**(得到初始条件与边界)

```python
class Solution:
    def fib(self, N: int) -> int:
        
        dp = [0 for _ in range(N + 1)]
        
        if len(dp) > 1:
            dp[1] = 1
        
        for i in range(2, N + 1):
            dp[i] = dp[i - 2] + dp[i - 1]
            
        return dp[N]
```

## 四要素

**状态定义：**

F(N) = 斐波那契额数列中第N个值

**状态转换：**

F(N) = F(N - 2) + F(N - 1)

**初始与边界条件：**

F(0) = 0, F(1) = 1

如果只求第一个，那么注意F(1)的初始化边界

**计算方向：**

推倒方向，从0到N


## 空间优化

状态数组的好处是，有空间压缩的可能

由于动态规划计算都是有一定方向的，那么对于前面的dp数组保存的值，可能就用不上了，可以空间压缩

技巧: 每个地方取模就好了

```python
class Solution:
    def fib(self, N: int) -> int:
        dp = [0 for _ in range(2)]
        
        if len(dp) > 1:
            dp[1 % 2] = 1
        
        for i in range(2, N + 1):
            dp[i % 2] = dp[(i - 2) % 2] + dp[(i - 1) % 2]
            
        return dp[N % 2]
```

少数可以只用几个变量

```python
class Solution:
    def fib(self, N: int) -> int:
        if N < 2:
            return N
        
        pre, cur = 0, 1 
        for i in range(2, N + 1):
            pre, cur = cur, pre + cur
            
        return cur
```

## 背包问题

定义`dp[i][j]`为，前i个物品，重量不超过j的情况下能达到的最大值。

假设第i个物品的重量为W，价值为V

### 0～1背包问题

每个只能取一次

选择1. 不装第i个物品: `dp[i][j] = dp[i - 1][j]`

选择2，装第i个物品：`dp[i][j] = dp[i - 1][j - W] + V`

```python
class Solution:
    def back_pack(self, a: List[int], v: List[int], m: int) -> int:
        # write your code here
        n = len(a)
        dp = [[0 for j in range(m + 1)] for i in range(n + 1)]

        for i in range(1, n + 1):
            for j in range(1, m + 1):
                w = a[i - 1]
                val = v[i - 1]
                if j >= w:
                    dp[i][j] = max(dp[i - 1][j], dp[i - 1][j - w] + val)
                else:
                    dp[i][j] = dp[i - 1][j]

        return dp[n][m]

# 压缩空间，应该倒序遍历
class Solution:
    def back_pack(self, a: List[int], v: List[int], m: int) -> int:
        # write your code here
        n = len(a)
        dp = [0 for j in range(m + 1)]

        for i in range(1, n + 1):
            for j in range(m, 0, -1):
                w = a[i - 1]
                val = v[i - 1]
                if j >= w:
                    dp[j] = max(dp[j], dp[j - w] + val)

        return dp[m]
```

### 完全背包问题

不限次数

选择1. 不装第i个物品: `dp[i][j] = dp[i - 1][j]`

选择2，装第i个物品：`dp[i][j] = dp[i][j - W] + V  #由于不限次数dp[i]不变`

```python
class Solution:
    def back_pack(self, a: List[int], v: List[int], m: int) -> int:
        # write your code here
        n = len(a)
        dp = [[0 for j in range(m + 1)] for i in range(n + 1)]

        for i in range(1, n + 1):
            for j in range(1, m + 1):
                w = a[i - 1]
                val = v[i - 1]
                if j >= w:
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - w] + val)
                else:
                    dp[i][j] = dp[i - 1][j]

        return dp[n][m]

# 压缩空间，应该正序遍历
class Solution:
    def back_pack(self, a: List[int], v: List[int], m: int) -> int:
        # write your code here
        n = len(a)
        dp = [0 for j in range(m + 1)]

        for i in range(1, n + 1):
            for j in range(1, m + 1):
                w = a[i - 1]
                val = v[i - 1]
                if j >= w:
                    dp[j] = max(dp[j], dp[j - w] + val)

        return dp[m]
```

## 技巧

### 方案与获利

1. 方案数/可行性，初始化为1。状态=各个可能的之和/OR，没有额外值
2. 最大获利，初始化为0，状态=各个可能方案+单次奖励

### 字符串匹配

`dp[i][j] = k`为A字符串前i个与B字符串前j个相匹配的时候的k值

--End--
