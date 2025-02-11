---
layout: post
title: "算法 - 字符串匹配搜索KMP"
categories: Algorithm
tags: String KMP DP
excerpt: "一米阳光的幸福"
---

* content
{:toc}

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        n = len(haystack)
        m = len(needle)

        for i in range(n):
            for j in range(m):
                if i + j >= n or haystack[i + j] != needle[j]:
                    break
                if j == m - 1:
                    return i

        return -1
```

正常的字符串匹配，同向双指针为锚点，比较两个字符串内容是否相等，不相等往后移动一位, 时间复杂度O(NM)

KMP使用构建好的部分匹配表，即Next数组，来优化向后移动，时间复杂度O(N + M)

KMP难点在于，如何构建Next数组，其次是如何使用这个表优化搜索

## 部分匹配表

### 前后缀

```python
A = PS, 对于非空字符S, P是A的前缀
A = SP, 对于非空字符S, P是A的后缀
```

⚠️注意, 对于字符串A来讲，A本身既不是它的前缀，也不是它的后缀

### Next数组

部分匹配表(PMT), 也叫`next数组`, 指的是字符串所有公共前后缀中最大的长度, 详细解释如下:

例如: ```ABCDABD```

```python
A       前缀 = []
        后缀 = []                                   ->    0
        结果 = 0

AB      前缀 = [A]
        后缀 = [B]                                  ->    0
        结果 = 0

ABC     前缀 = [A, AB]
        后缀 = [C, BC]                              ->    0
        结果 = 0

ABCD    前缀 = [A, AB, ABC]
        后缀 = [D, CD, BCD]                         ->    0
        结果 = 0

ABCDA   前缀 = [A, AB, ABC, ABCD]
        后缀 = [A, DA, CDA, BCDA]                   ->    1
        结果 = len(A) = 1

ABCDAB  前缀 = [A, AB, ABC, ABCD, ABCDA]
        后缀 = [B, AB, DAB, CDAB, BCDAB]            ->    2
        结果 = len(AB) = 2

ABCDABD 前缀 = [A, AB, ABC, ABCD, ABCDA, ABCDAB]
        后缀 = [D, BD, ABD, DABD, CDABD, BCDABD]    ->    0
        结果 = 0
```

### 动态规划

使用动态规划计算出`next数组`, 时间复杂度为O(N)

#### 状态定义

```python
    dp[i]
------------
SSSSSSSSSSSS....SSSS
0          i
```

`dp[i]`等于`s[0: i]`字符串(包含下标j), 公共前后缀**最长**的长度`k`

根据该定义，若字符串长度为`l`, `dp[l - 1] = k`

#### 状态转移

```python
        k1            j
A B C D E.... A B C D E
-------       -------
      ^             ^
      k2            k2     
```

`K`分成`k1,k2`便于说明, `k1`是待匹配字符的`E`的下标, `k2`代表`s[0 : j - 1] = "ABCDE...ABCD"`中最长的公共前后缀的长度

如果`s[k] == s[j]`, 则 `dp[j] = dp[j - 1] + 1 = k + 1`

如果不相等, 如下图, 需要找到次长度的公共前后缀来尝试

```python
    s1     =     s2       "ABCD"

A B C D E....A B C D F
-------        -------     dp[k - 1]
-----            -----     dp[k - 2]
---                ---     ...
-                    -
                           0
```

具体迭代过程并不是一次次递减长度，而是根据定义，使用一个更快的迭代技巧。

如下图，假设`^和$`是即将匹配字串, `dp[i - 1] = k`, 由一堆`x`表示。

在选取次长前后缀过程中，前半部`x`分丢掉结尾，后半部`x`分丢掉开头, 很难再次相等，除非`x`本身是拥有公共前后缀的。

因为`x`长度为`k`, 末尾下标为`k - 1`，根据dp定义, 这堆`x`的前后缀最长为`dp[k - 1]` = `l`，下图4个划线部分`l`

我们更关心起始两端的`l`, 根据递推公式，若`^和$`相等`l + 1`, 若不相等，重复此迭代过程，直到`l`最后为`0`

```python
           k                                 k
xxxxxxxxxxxxxxxxxxxxxxxx^........xxxxxxxxxxxxxxxxxxxxxxxx$
------            ------         ------            ------
  l                  l              l                 l
                丢掉末尾->         <-丢掉开头
------            ------         ------            ------
yyyyyy^............................................yyyyyy$

  .                                                  .
  .                                                  .
  .                                                  .
^........................................................$
```

#### 计算方向

从左到右

不相等的时候，`k`长度按dp序列递减

#### 边界条件

k = 0, 由于单个字符没有公共前后缀，从1开始计算

代码如下:

```python
def buildNext(self, text: str) -> list[int]:
    n = len(text)
    next_array = [0] * n
    k = 0
    for i in range(1, n):
        while k > 0 and text[i] != text[k]:
            k = next_array[k - 1]

        if text[i] == text[k]:
            k += 1

        next_array[i] = k
    
    return next_array
```

我们的Next数组计算如下

```python
A B C D A B D

0 0 0 0 1 2 0
```

### KMP匹配优化

字符串搜索是在主串中(Text)寻找目标(Pattern)

```python
Text = "ABCDABABCD"
Pattern = "ABCDABD", 部分匹配表如上述代码结果

----------- i
A B C D A B A B C D        # i处 'A' != 'D' 
A B C D A B D              # 匹配部分最大公共前后缀AB，dp值=2
-----------

>>>>> |
      | A B C D A B D

```

不匹配的时候Pattern需要后移, 只有前后缀相等的部分才有可能匹配, 此时, 我们可以放心的将Pattern开头，移动到后缀匹配的位置。


### 代码实现

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        n, m = len(haystack), len(needle)
        
        if m == 0:
            return 0
        
        next_array = self.buildNext(needle)
        match_length = 0

        for i in range(n):
            while match_length > 0 and haystack[i] != needle[match_length]:
                match_length = next_array[match_length - 1]

            if haystack[i] == needle[match_length]:
                match_length += 1

            if match_length == m:
                return i - m + 1

        return -1

    def buildNext(self, text: str) -> list[int]:
        n = len(text)
        next_array = [0] * n
        k = 0
        for i in range(1, n):
            while k > 0 and text[i] != text[k]:
                k = next_array[k - 1]

            if text[i] == text[k]:
                k += 1

            next_array[i] = k
        
        return next_array
```

### CASE模拟

```python
BBC ABCDAB ABCDABCDABDE
ABCDABD
^
i
```

左对齐，比较后发现match个数等于0，那么不断右移一格，直到首位相等

```python
BBC ABCDAB ABCDABCDABDE
    ABCDABD
          ^
          i = 10, match=6

BBC ABCDAB ABCDABCDABDE
        ABCDABD
          ^
          i = 10, match=2
```

逐个判断相等之后，发现`D`与`空格`不匹配，`dp(ABCDAB) = 2`, 保留2个匹配`AB`已匹配

此时`C`与空格依然不相等，`dp(AB) = 0`, 没有任何匹配，将首字母与空格`对齐`

```python
BBC ABCDAB ABCDABCDABDE
          ABCDABD
          ^
          i = 10, match = 0

BBC ABCDAB ABCDABCDABDE
           ABCDABD
           ^
           i = 11, match = 0
```

重复最开始的match=0的逻辑，右移一格，首字母匹配

```python
BBC ABCDAB ABCDABCDABDE
           ABCDABD
                 ^
                 i = 17, match = 6

BBC ABCDAB ABCDABCDABDE
               ABCDABD
                 ^
                 i = 17, match = 2
```

逐个匹配, 发现最后一个字母`D`与`C`不行，`dp(ABCDAB) = 2`, 保留`AB`已匹配

```python
BBC ABCDAB ABCDABCDABDE
               ABCDABD
                     ^
                 i = 22, match = 7
```

找到了结果，返回`i - match + 1`

--End--
