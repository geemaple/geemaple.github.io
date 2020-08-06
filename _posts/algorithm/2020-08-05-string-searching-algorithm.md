---
layout: post
title: "字符串匹配搜索算法"
categories: 亢龙有悔
tags: Algorithm String Robin-karp KMP Boyer-Moore Sunday
excerpt: ""
---

* content
{:toc}

字符串搜索算法，也成字符串匹配算法，是开发中最常用的算法之一。

C++中的```strstr```函数

Java中的```indexOf```函数

Python中的```find```函数等。

## 暴力破解

O(M*N)

暴力破解，也是最常用的实现方式，优点是思路比较简单，不容易出错

```
逐个比较，如果不匹配，右移动一格

ABCDEFG    ->    ABCDEFG    ->    ABCDEFG    ->    ABCDEFG     
DEF               DEF               DEF               DEF
```

该算法，进行(M - N + 1)次比较, 每次比较N个字符

```python
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        
        if len(needle) > len(haystack):
            return -1
        
        index = 0
        for i in range(len(haystack) - len(needle) + 1):
            index = i
            for j in range(len(needle)):
                if needle[j] != haystack[i + j]:
                    index = -1
                    break
            
            if index == i:
                break
            
        return index
```

## Robin-karp算法

O(M + N), 如果哈希函数冲突很小的情况下, 不然就退化成暴力破解了

Robin-karp是对暴力破解的一个优化，将Pattern字符哈希取值。每次匹配只比较同长度字符串的哈希值。

如果哈希值相等，考虑到哈希冲突，需再次比较每一位字符。用来验证结果。

```
ABCDEFG
ABC    --哈希值-->   Hash(ABC)
 BCD    --哈希值-->   Hash(BCD)
  CDE    --哈希值-->   Hash(CDE)
   ...     

DEF    --哈希值-->   Hash(DEF)   
```

比较同长哈希值, 如果相等，逐个比较验证结果

```
hash(ABC)        hash(BCD)        hash(CDE)        hash(DEF) 
   !=               !=               !=               == (需验证结果)
hash(DEF)        hash(DEF)        hash(DEF)        hash(DEF)
   
ABCDEFG    ->    ABCDEFG    ->    ABCDEFG    ->    ABCDEFG
DEF               DEF               DEF               DEF
```

考虑到Hash的时间复杂度也是O(N), 那么这个过程，并没有优化时间复杂度，仍然是(M - N + 1）次比较, 每次哈希O(N)。

如果设计哈希函数如下, 就不必重复计算，每次去掉最高位，乘以K进制，再加上新的最低位

```
f(ABC) = A * K^2 + B * K^1 + C * K^0
f(BCD) =           B * K^2 + C * K^1 + D * K^0

存在递推关系:
f(BCD) = (f(ABC) - A * k^2) * k + D
```

令k=256进制, 代码如下:

```python
k_buckets = 131
k_characters = 256
class Solution:
    def strStr(self, haystack: str, needle: str) -> int:
        
        m = len(haystack)
        n = len(needle)

        if n == 0:
            return 0

        if n > m:
            return -1

        target = 0
        tmp = 0
        high = 1

        for i in range(n - 1): # 最高位 = k ^ (n - 1)
            high = (high * k_characters) % k_buckets

        for i in range(n): # 初始Hash值
            tmp = (tmp * k_characters + ord(haystack[i])) % k_buckets
            target = (target * k_characters + ord(needle[i])) % k_buckets

        for i in range(m - n + 1):
            index = i
            if tmp == target:
                for j in range(n):
                    if haystack[i + j] != needle[j]:
                        index = -1
                        break

                if index == i:
                    return index

            if i < m - n:
                # 减去最高位的值tmp - haystack[i] * (k ^ (N - 1)), 结果乘以256, 再加上新的个位
                # 注意python中%不会出现负数，不需要额外处理
                tmp = ((tmp - ord(haystack[i]) * high) * k_characters  + ord(haystack[i + n])) % k_buckets

        return -1
```

## KMP算法

字符串匹配的经典算法之一，各大教科书必备看家算法。

先现引入个概念，叫next数组。指的是字符串前缀和后缀共有元素的长度，解释如下:

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