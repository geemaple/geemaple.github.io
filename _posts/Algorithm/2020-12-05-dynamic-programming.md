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

## 动归四要素

**状态定义：**

F(N) = 斐波那契额数列中第N个值

**状态转换：**

F(N) = F(N - 2) + F(N - 1)

**初始与边界条件：**

F(0) = 0, F(1) = 1

如果只求第一个，那么注意F(1)的初始化边界

**计算方向：**

推导方向，从0到N

## 空间优化

状态数组的好处是，有空间压缩的可能

### 一维压缩

由于动态规划计算都是有一定方向的，可以使用空间压缩

```python
class Solution:
    def fib(self, N: int) -> int:
        # 技巧: 每个地方取模就好了
        dp = [0 for _ in range(2)]
        
        if len(dp) > 1:
            dp[1 % 2] = 1
        
        for i in range(2, N + 1):
            dp[i % 2] = dp[(i - 2) % 2] + dp[(i - 1) % 2]
            
        return dp[N % 2]

class Solution:
    def fib(self, N: int) -> int:
        # 变量替换，与上面本质一样
        if N < 2:
            return N
        
        pre, cur = 0, 1 
        for i in range(2, N + 1):
            pre, cur = cur, pre + cur
            
        return cur
```

### 二维压缩

当我们考虑空间优化时，DP矩阵行列的布局就变得尤为重要。通常情况下，在填充DP矩阵时，我们可以利用前一行的结果来更新当前行。

然而，如果我们将 DP矩阵的行列互换，在访问时可能会导致需要保留更多的状态信息，特别是在我们需要同时访问当前行和前一行数据的情况下。 由于题目的多样性，这种行列互换，可能并不是有意为之的。

```python
class Solution:
    def back_pack_v(self, nums: List[int], target: int) -> int:
        # 依赖前一列，而且依赖前多行，无法压缩
        n = len(nums)
        dp = [[0] * (n + 1) for i in range(target + 1)]
        
        for i in range(n + 1):
            dp[0][i] = 1

        for i in range(1, target + 1):
            for j in range(1, n + 1):
                weight = nums[j - 1]
                dp[i][j] = dp[i][j - 1]
                if i >= weight:
                    dp[i][j] += dp[i - weight][j - 1]

        return dp[target][n]

class Solution:
    def back_pack_v(self, nums: List[int], target: int) -> int:
        n = len(nums)
        dp = [[0] * (target + 1) for i in range(n + 1)]
        
        for i in range(n + 1):
            dp[i][0] = 1

        for i in range(1, n + 1):
            for j in range(1, target + 1):
                weight = nums[i - 1]
                dp[i][j] = dp[i - 1][j]
                if j >= weight:
                    dp[i][j] += dp[i - 1][j - weight]

        return dp[n][target]

class Solution:
    def back_pack_v(self, nums: List[int], target: int) -> int:
        n = len(nums)
        dp = [0] * (target + 1)
        dp[0] = 1

        for i in range(1, n + 1):
            for j in range(target, 0, -1):
                weight = nums[i - 1]
                if j >= weight:
                    dp[j] += dp[j - weight]

        return dp[target]
```

### 逆序依赖

空间压缩时，只需要判断前两个维度的依赖关系, 压缩维度和次维度

正序遍历隐含着向左，向上依赖, 也就是双垂直90度

1. 上下垂直的依赖⬆️：压缩时自然继承
2. 水平左右依赖⬅️➡️：新值依赖当前行新值，要顺着箭头方向遍历
3. 倾斜角度依赖↖️↗️: 新值依赖次行旧值，要避让箭头的方向

```python
class Solution:
    def findMaxForm(self, strs: List[str], m: int, n: int) -> int:

        k = len(strs)
        
        dp = [[[0 for _ in range(n + 1)] for _ in range(m + 1)] for _ in range(k + 1)]

        for i in range(1, k + 1):
            num = strs[i - 1]
            zeros = num.count('0')
            ones = len(num) - zeros

            for z in range(m + 1):
                for o in range(n + 1):
                    if zeros <= z and ones <= o:
                        dp[i][z][o] = max(dp[i - 1][z][o], dp[i - 1][z - zeros][o -ones] + 1) # max右边，↖️依赖，要避让箭头方向遍历
                    else:
                        dp[i][z][o] = dp[i - 1][z][o] # 垂直依赖，自然继承

        return dp[k][m][n]

class Solution:
    def findMaxForm(self, strs: List[str], m: int, n: int) -> int:

        k = len(strs)
        
        dp = [[0 for j in range(n + 1)] for i in range(m + 1)]

        for i in range(1, k + 1):
            num = strs[i - 1]
            zeros = num.count('0')
            ones = len(num) - zeros

            for z in range(m, zeros - 1, -1):
                for o in range(n, ones - 1, -1):
                    dp[z][o] = max(dp[z][o], dp[z - zeros][o - ones] + 1)

        return dp[m][n]
```

逆序依赖，除了可以像上面倒着遍历，还可以使用临时变量，因为不再有覆盖问题，所以正序逆序都可以。

```python
class Solution:
    def back_pack_v(self, nums: List[int], target: int) -> int:
        n = len(nums)
        dp = [[0] * (target + 1) for i in range(n + 1)]
        
        for i in range(n + 1):
            dp[i][0] = 1

        for i in range(1, n + 1):
            for j in range(1, target + 1):
                weight = nums[i - 1]
                dp[i][j] = dp[i - 1][j]
                if j >= weight:
                    dp[i][j] += dp[i - 1][j - weight]

        return dp[n][target]

class Solution:
    def back_pack_v(self, nums: List[int], target: int) -> int:
        n = len(nums)
        dp = [0] * (target + 1)
        dp[0] = 1

        for i in range(1, n + 1):
            tmp = list(dp)
            for j in range(1, target + 1):
                weight = nums[i - 1]
                if j >= weight:
                    tmp[j] = dp[j] + dp[j - weight]

            dp = tmp
        return dp[target]
```

### 45度方向

```py
 i \ j | a        | b        | c        | d        |
-------|----------|----------|----------|----------|
   a   | 1        | dp[0][1] | dp[0][2] | dp[0][3] |
-------|----------|----------|----------|----------|
   b   |          | 1        | dp[1][2] | dp[1][3] |
-------|----------|----------|----------|----------|
   c   |          |          | 1        | dp[2][3] |
-------|----------|----------|----------|----------|
   d   |          |          |          | 1        |
```

区间型动态规划，是从小的区间计算到大的区间，题目初始化为长度**1**， 也就是对角线。

从斜边往右上↗️, 区间长度一次递增， 这里思考沿着45度方向思考

```py
class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        dp = [[0] * n for i in range(n)]

        for i in range(n):
            dp[i][i] = 1

        for i in range(n - 1):
            dp[i][i + 1] = 2 if s[i] == s[i + 1] else 1

        for l in range(3, n + 1):
            for i in range(n - l + 1):
                j = i + l - 1
                
                if s[i] == s[j]:
                    dp[i][j] = dp[i + 1][j - 1] + 2
                else:
                    dp[i][j] = max(dp[i][j - 1], dp[i + 1][j])
                    
        return dp[0][n - 1]

class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        pre = [1] * n # 对角线，单个字符1
        cur = [1] * n # 两个字符默认值 = 单个字符，同样1

        for i in range(n - 1):
            if s[i] == s[i + 1]:
                cur[i + 1] = 2

        # 保留两个斜边pre和cur，计算第三个斜边tmp, 注意所有的都是j对其, i被压缩
        for length in range(3, n + 1): 
            tmp = [0 for i in range(n)]
            for i in range(n - length + 1):
                j = i + length - 1
                if s[i] == s[j]:
                    tmp[j] = pre[j - 1] + 2
                else:
                    tmp[j] = max(cur[j - 1], cur[j])

            # 更新两个斜边pre和cur
            pre, cur = cur, tmp

        return cur[n - 1]

# 同样，根据逆序依赖， 如果i逆序，可以不使用新的tmp数组
class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        pre = [1] * n # 对角线，单个字符1
        cur = [1] * n # 两个字符默认值 = 单个字符，同样1

        for i in range(n - 1):
            if s[i] == s[i + 1]:
                cur[i + 1] = 2

        # 直接在pre上更新, 然后pre，cur互换一下
        for length in range(3, n + 1): 
            tmp = pre
            for i in range(n - length, -1, -1):
                j = i + length - 1
                if s[i] == s[j]:
                    tmp[j] = pre[j - 1] + 2
                else:
                    tmp[j] = max(cur[j - 1], cur[j])

            pre, cur = cur, pre

        return cur[n - 1]
```

把原二维dp，反转一下，这里优化要水平横着思考

```py
   i \ j | a        | b        | c        | d        |
---------|----------|----------|----------|----------|
   a     | 1        |          |          |          |
---------|----------|----------|----------|----------|
   b     | dp[0][1] | 1        |          |          |
---------|----------|----------|----------|----------|
   c     | dp[0][2] | dp[1][2] | 1        |          |
---------|----------|----------|----------|----------|
   d     | dp[0][3] | dp[1][3] | dp[2][3] | 1        |
```

```py

class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        dp = [[0] * n for i in range(n)]

        for i in range(n):
            dp[i][i] = 1

        for i in range(n - 1):
            dp[i + 1][i] = 2 if s[i] == s[i + 1] else 1

        for l in range(3, n + 1):
            for j in range(l - 1, n):
                i = j - l + 1
                
                if s[i] == s[j]:
                    dp[j][i] = dp[j - 1][i + 1] + 2
                else:
                    dp[j][i] = max(dp[j - 1][i], dp[j][i + 1])
   
        return dp[n - 1][0]

class Solution:
    def longestPalindromeSubseq(self, s: str) -> int:
        n = len(s)
        dp = [0] * n
  
        for i in range(n):
            dp[i] = 1 # 斜边单个字符初始化1
            prev = 0   # 用来保存 dp[j - 1][i + 1], 初始化为空字符0
            for j in range(i - 1, -1, -1):
                temp = dp[j]
                if s[i] == s[j]:
                    dp[j] = prev + 2
                else:
                    dp[j] = max(dp[j], dp[j + 1])
                # 更新 prev 为下次循环的 dp[j - 1][i + 1]，每一次内循环后: 区间长度+1, 也就是斜边深度+1
                prev = temp  
        
        return dp[0]
```

## 背包问题

定义`dp[i][j]`为，前i个物品，重量不超过j的情况下能达到的最大值。

假设第i个物品的重量为W，价值为V

### 0/1背包问题

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

1. 方案数/可行性，初始化为1, 通常空就是第一个满足的方案, 状态=各个可能的之和/OR，没有额外值
2. 最大获利，初始化为0, 不行动就没有获, 状态=各个可能方案+单次奖励

### 字符串匹配

`dp[i][j] = k`为A字符串前i个与B字符串前j个相匹配的时候的k值

### 划分类型

1. 划分行，最后一步是满足条件的一段(不一定是最后一个坐标), 比如最后一步是回文串
2. 划分次数 = 划分结果个数 - 1

### 博弈类型

1. 从每个人视角看他都是先手, 某一步A想尽所有办法，从B的视角看全必赢，那么此次结果A为必输

### 区间类型

1. 区间类型由长度`length`从小到大递归方向，也就是二维矩阵45度方向

--End--
