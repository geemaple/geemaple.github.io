---
layout: post
title: "KMP字符串匹配搜索算法"
categories: 亢龙有悔
tags: Algorithm String KMP
excerpt: ""
---

* content
{:toc}

KMP是历史上第一个O(N)级别的字符匹配算法，各大教科书必备看家算法。

它的难点在于，如何计算部分匹配表，其次是如何使用这个表优化搜索

## 部分匹配表

### 前后缀定义

```
A = BS, 对于非空字符S, B是A的前缀
A = SB, 对于非空字符S, B是A的后缀
```

⚠️注意, 对于字符串S来讲，S本身既不是它的前缀，也不是它的后缀

### 部分匹配表详解

部分匹配表(PMT), 指的是字符串所有公共前后缀中最大的长度, 详细解释如下:

例如: ```ABCDABD```

```
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

### 部分匹配表动态代码

O(N)

部分匹配表，本质是一个动态规划

#### 状态定义

```
SSSSSSSSSSSS....SSSS
0          j
```

dp[j]等于s[0: j]字符串(包含下标j), 公共前后缀最长的长度

#### 状态转移

```
    k       j
A B C D A B D
---     ---
  ^       ^
  k       k
```
k代表s[i : j - 1]中最长的公共前后缀, 同时k也是待匹配字符的'C'的下标

如果s[k] == s[j]

dp[j] = dp[j - 1] + 1 = k + 1

```
 s1      s2
ABCD....ABCD
----    ---- k
---      --- k - 1
--        -- k - 2
-          - 1

 s1      s2
ABCD....ABCD
  \      /
   \    /
    \  /
    ABCD
     s1
```

如果不相等, 需要找到```ABCDAB```次长度的公共前后缀来尝试, 比如说k-1, k-2, ...0来尝试

对于上述字符串，次长度前缀一定在s1中，次长度后缀一定在s2中，关键是**s1 == s2**，而且s1/s2是最长的

所以s1....s2字符串，可以用s1/s2其中一个代替，根据从0开始的动规定义，使用s1更简单

s1中最后字符的下标last = k - 1, 途中s1长度为k = 4, 末尾'D'下标 = k - 1 = 3

所以k = dp[k - 1], 再次尝试, 重复判断直到k == 0, 或者遇到匹配

#### 计算方向

从左到右

不相等的时候，k长度递减，公共前后缀始终包含两端

#### 边界条件

无

代码如下:

```python
class Solution:
    def calcuateNextArray(self,  s : str) -> List[str]:

        res = [0 for i in range(len(s))]
        k = 0
        for i in range(1,  len(s)):
            while (k > 0 and s[i] != s[k]):
                k = res[k - 1]

            if s[i] == s[k]:
                k += 1

            res[i] = k
            
        return res
```

我们的Next数组计算如下

```
A B C D A B D

0 0 0 0 1 2 0
```

### KMP匹配优化

字符串搜索是在主串中(Text)寻找目标(Pattern)

```
Text = "ABCDABABCD"
Pattern = "ABCDABD", 部分匹配表如上述代码结果

------i
ABCDABABCD        # 
ABCDABD           #公共前后缀AB
>>>|
   |ABCDABD
```

假设在上述匹配中, **Text[i] != Pattern[i]**, 那么划线部分是已经匹配好的, 划线部分="ABCDAB", 对应部分匹配表的值=2

不匹配的时候Pattern需要后移, 根据Text/Pattern划线部分前后缀**相等**的特性, 依次后移只有前后缀相等的部分才有可能匹配, 此时, 我们可以放心的将Pattern开头，移动到后缀匹配的位置。


### 部分匹配应用

KMP算法，如暴力破解一样，左对齐两个字符串，开始匹配。

引用下阮一峰大神使用的例子🌰, 左对齐，发现第一位不相等，那么不断右移一格，直到首位相等

```
BBC ABCDAB ABCDABCDABDE
ABCDABD
^
```

右移之后，发现D与空格不想等，**如果是暴力破解，就只能右移动一格。KMP利用next数组，可以一次移动更多格数**

此时, 我们已经比较了```ABCDAB```6个字符了，最后一位匹配的是字符```B```, 查表得知对应的数值 = 2

**移动位数 = 已匹配的位数 - 最后一个匹配对应的val**

所以，移动位数 = 6 - 2。 向后移动4格

```
BBC ABCDAB ABCDABCDABDE
    ABCDABD
          ^
```

此时，已经比较了```AB```2个字符，最后一位匹配的是字符```B```, 查表得知对应的数值 = 0, 所以移动 = 2 - 0

```
BBC ABCDAB ABCDABCDABDE
        ABCDABD
          ^
```

此时，首字母, 空格与A不匹配，向后移动一格

```
BBC ABCDAB ABCDABCDABDE
          ABCDABD
          ^
```

此时，我们已经比较了```ABCDAB```6个字符了，最后一位匹配的是字符```B```, 查表得知对应的数值 = 2， 所以移动 = 6 - 2

```
BBC ABCDAB ABCDABCDABDE
           ABCDABD
                 ^
```

逐个匹配, 找到了结果，返回

```
BBC ABCDAB ABCDABCDABDE
               ABCDABD
```

--End--