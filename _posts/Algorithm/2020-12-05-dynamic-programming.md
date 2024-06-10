---
layout: post
title: "动态规划"
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

## 至顶向下

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

## 至底向上

方向: 从"小问题"到"大问题"

1. **最后一步**(是怎样能够得到答案的)
2. **化成子问题**(得到初始条件与边界)

### 状态定义

F(N) = 斐波那契额数列中第N个值

### 状态转换

F(N) = F(N - 2) + F(N - 1)

### 初始与边界条件

F(0) = 0, F(1) = 1

如果只求第一个，那么注意F(1)的初始化边界

### 计算方向

从0到N

### 代码实现

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

### 空间优化

至底向上的好处是：

1. 时间复杂度好计算
2. 有空间压缩的可能

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

## One More Thing

算法能够解决的问题非常有限，而思想应对的问题却千变万化

所以，这篇介绍非常简单，但实战远不止这些。

而真正思想的锻炼，是在实战中不断积累提高的

一个真正量变引起质变的过程

--End--
