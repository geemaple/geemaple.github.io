---
layout: post
title: "算法 - 最长回文子串Manacher's Algorithm"
categories: Algorithm
tags: Manacher String
excerpt: "开启神秘领域"
---

* content
{:toc}

## 最长回文子串

给一个字符串s, 要求找到任意一个最大区间`[i: j]`, 且区间是一个回文串。常规的解法时间复杂度都在`O(N^2)`以上

## Manacher's Algorithm

### 思路分析

这个算法没有对应的中文名，应该是这个哥们`Manacher`发明的, 它能在`O(N)`的时间内解决此问题

```python

--------------------------------
              c
      |---r---|---r---|
             c+0          
   c - r            c + r
```

数组定义下标`c`处的半径r, 当r=0时, 左右内边界点与原点相同 
那么，该圆内左右两侧，坐标节点分别是'c - r 和 c + r'

```python
        'a b a'
           c
           r = 1

        'a   a'

           c
           r = 1
```

回文串可以看作这样的原点与半径, 对于数组来说，第二种不好表示，所以Manacher算法加入了额外的分隔符

```python
    '# a # b # a #'
           c
           r = 3

    '# a # a #'

         c
         r = 2
```

加上分隔符之后，半径r的长度，就是回文串的长度了，我们把每个点为原点计算出它的半径

```python
            
r = 0  1  0  3  0  3  0  1  0  1  0          
   '#  b  #  a  #  b  #  a  #  d  #'
             ^     ^     ^
             j     C     i
          |-----------------|
          |-----|     r    
```

这个哥们Manacher， 利用了回文串左右对称的特点，图中`i和j`关于原点`c`对称， 那么有`c = (i + j) / 2`, 那么`j = 2 * c - i`

仅观察C为原点半径内，`j`点的半径为`1`(虽然超出半径为`3`), 那么回文串`i`是对称的，那么他应该也是`1`才对。

为了限制在半径内`p[i] = min(r - i, p[j])`, 利用这种镜面对称获得了`i`点的半径`初始值`

至于能不能更大，就需要继续判断了


```python
   'b     a     b     a     d'
    0  0  1  1  2  2  3  3  4  4  
   '#  b  #  a  #  b  #  a  #  d  #'
          ^        ^     
          s        C     
          |-----------------|
                       r  
```

最后已知`c`点半径最大，半径为`r`,说明结果字符串长度也是`r`

起始点`s = c - r`, 半径起始点始终是一个`#`, `#`左边有k个`#{字母}`偶数组合, 0为起点，`s`下标始终为偶数

将`s = s / 2`即可获取到原字符串对应的下标

### 代码实现

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        t = '#' + '#'.join(s) + '#'
        n = len(t)
        p = [0] * n
        center = 0
        right_r = 0

        for i in range(n):
            mirror_j = 2 * center - i # 求出i关于原点的镜像j

            if i < right_r: # 判断i是否在覆盖内
                p[i] = min(right_r - i, p[mirror_j])

            # 拓展半径
            while i + p[i] + 1 < n and i - p[i] - 1 >= 0 and t[i + p[i] + 1] == t[i - p[i] - 1 ]:
                p[i]+= 1

            # 更新半径能覆盖的距离
            if right_r < i + p[i]:
                right_r = i + p[i]
                center = i

        max_center = 0 
        max_r = 0
        for i in range(n):
            if p[i] > max_r:
                max_r = p[i]
                max_center = i

        start = (max_center - max_r) // 2
        return s[start: start + max_r]
```

### 时间复杂度

传统双循环时间复杂度`O(N^2)`, 是因为内层循环`j`在达到递增之后，从新赋值相当于有了递减操作

粗略分析，外层循环是`2n + 1`次, 那么内层呢？

`center`如果它在最远半径内则保持不变，反之不断增加
`right_r`随着拓展半径操作，也是尽可能增加的
`i + p[i] + 1`, 也是不断增加的，而且`p[i]`初始值通过镜像获取

所有关键变量都没有回头操作，粗略估计时间复杂度为`O(N)`

-- END --