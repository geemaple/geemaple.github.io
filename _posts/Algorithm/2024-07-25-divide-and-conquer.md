---
layout: post
title: "算法 - 分治算法D&C"
categories: Algorithm
tags: D&C
excerpt: "分而治之"
mathjax: true
---

* content
{:toc}

## 分治算法

分治算法主要为"分"和"治"

通过把原问题分为子问题，再将子问题进行处理合并，从而实现对原问题的求解, 归并排序就是典型的分治问题

## 主定理

为了更好的计算各种情况的时间复杂度，有下面主定理

假设:

分 = 分成a个，1/b的子问题(a > 0, b > 1)

治 = 需要O(N^d)的时间复杂度(d >= 0)


$  T(n) = aT\left(\frac{n}{b}\right) + f(n^d) $

最终的时间复杂度为：

$ if (d > \log_b a): \hspace{1em} T(N) = O(N^d) $

$ if (d = \log_b a): \hspace{1em} T(N) = O(N^d\log N)$

$ if (d < \log_b a): \hspace{1em} T(N) = O(N^{\log_b a})$

### 例1

```python
# 分 = 2个一半的的子问题, 归并排序
# 治 = 花费O(N)的时间
T(N) = 2T(N/2) + O(N)
     = 2(2T(N/4) + O(N/2)) + O(N) = 4T(N/4) + O(N) + O(N) 
     = 8T(N/8) + 3O(N)
     = T(1) + logN * O(N)
     = N * LogN

a = 2, b = 2, d = 1
```
$ k = \log_2 2 = 1, \hspace{1em} d = k, \hspace{1em} T(N) = O(N\log N) $


### 例2

```python
# 分 = 一半的的子问题， 二分法
# 治 = 花费O(1)的时间
T(N) = T(N/2) + O(1)
     = (T(N/4) + O(1)) + O(1)
     = ((T(N/8) + O(1)) + O(1)) + O(1)
     ...
     = T(1) + logN * O(1)
     = O(logN)

a = 1, b = 2, d = 0
```

$ k = \log_2 1 = 0, \hspace{1em} d = k, \hspace{1em} T(N) = O(\log N) $

### 例3

```python
T(N) = 2T(N/2) + O(N^2)
a = 2, b = 2, d = 2
```
$ k = \log_2 2 = 1, \hspace{1em} d > k, \hspace{1em} T(N) = O(N^2) $

### 例4

```python
T(N) = 4T(N/2) + O(N)

a = 4, b = 2, d = 1
```

$ k = \log_2 4 = 2, \hspace{1em} d < k, \hspace{1em} T(N) = O(N^2) $

### 例5

```python
T(N) = 3T(N/2) + O(N)

a = 3, b = 2, d = 1
```

$ k = \log_2 3, \hspace{1em} d < k, \hspace{1em} T(N) = O(N^{\log_2 3}) $

--End--