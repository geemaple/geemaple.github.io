---
layout: post
title: "Rabin–Karp字符串匹配搜索算法"
categories: Algobase
tags: Algobase String RabinKarp
excerpt: "感谢上帝，我还活着"
---

* content
{:toc}

字符串搜索算法，也称字符串匹配算法，是开发中最常用的算法之一。

C++中的```strstr```函数

Java中的```indexOf```函数

Python中的```find```函数等。

## 暴力破解

O(M*N)

暴力破解，也是最常用的实现方式，优点是思路比较简单，不容易出错

```python
ABCDEFG    ->    ABCDEFG    ->    ABCDEFG    ->    ABCDEFG     
DEF               DEF               DEF               DEF
```

逐个比较，如果不匹配，右移动一格

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

```python
ABCDEFG
ABC    --Hash-->   Hash(ABC)
 BCD    --Hash-->   Hash(BCD)
  CDE    --Hash-->   Hash(CDE)
   ...     

DEF    --Hash-->   Hash(DEF)   
```

如果哈希值相等，考虑到哈希冲突，需再次比较每一位字符。用来验证结果。

```python
hash(ABC)        hash(BCD)        hash(CDE)        hash(DEF) 
   !=❌             !=❌            !=❌               ==✅
hash(DEF)        hash(DEF)        hash(DEF)        hash(DEF)
   
ABCDEFG    ->    ABCDEFG    ->    ABCDEFG    ->    ABCDEFG
DEF               DEF               DEF               DEF
```

考虑到Hash的时间复杂度也是O(N), 那么这个过程，并没有优化时间复杂度，仍然是(M - N + 1）次比较, 每次哈希O(N)。

如果设计哈希函数如下, 就不必重复计算，每次去掉最高位，乘以K进制，再加上新的最低位

```python
f(ABC) = A * K^2 + B * K^1 + C * K^0
f(BCD) =           B * K^2 + C * K^1 + D * K^0

# Formula:
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

--End--
