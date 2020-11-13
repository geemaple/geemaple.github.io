---
layout: post
title: "KMP字符串匹配搜索算法"
categories: 亢龙有悔
tags: Algorithm String Robin-karp KMP Boyer-Moore Sunday
excerpt: ""
---

* content
{:toc}

KMP是历史上第一个O(N)级别的字符匹配算法，各大教科书必备看家算法。

它的难点在于，如何计算部分匹配表，以及如何使用这个表

## 部分匹配表

先现引入个概念, 部分匹配表(PMT), 指的是字符串前缀和后缀共有元素中的最大长度，解释如下:

⚠️注意, 对于字符串S来讲，S本身既不是它的前缀，也不是它的后缀

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

next数组DP代码实现如下，Amazing ha?
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

//TBD 未完待续


## BM算法

工业级字符串匹配算法，执行效率要比KMP快3-4倍

//TBD 未完待续

--End--