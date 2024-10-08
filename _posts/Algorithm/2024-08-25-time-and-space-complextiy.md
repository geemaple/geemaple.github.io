---
layout: post
title: "算法 - 复杂度分析Complexities"
categories: Algorithm
tags: BigO
excerpt: 复杂度分析
---

* content
{:toc}

## 复杂度

### 增长曲线

<center>

<div>
    <table id="legend" class="table">
    <tbody>
        <tr>
        <td><code style="background-color: #FF8989">Horrible</code></td>
        <td><code style="background-color: #FFC543">Bad</code></td>
        <td><code style="background-color: #FFFF00">Fair</code></td>
        <td><code style="background-color: #C8EA00">Good</code></td>
        <td><code style="background-color: #53D000">Excellent</code></td>
        </tr>
    </tbody>
    </table> 
</div>

<div>
    <svg id="chart" width="100%" height="500" xmlns="http://www.w3.org/2000/svg">
    <!-- horrible region -->
    <path d="M50 450 L 50 0 L 800 0 L 800 450 Z" fill="#FF8989"></path>
    <!-- bad region -->
    <path d="M50 450 L 800 0 L 800 450 Z" fill="#FFC543"></path>
    <!-- fair region -->
    <path d="M50 450 L 800 450 L 800 330 Z" fill="#FFFF00"></path>
    <!-- good region -->
    <path d="M50 450 L 800 450 L 800 410 Z" fill="#C8EA00"></path>
    <!-- excellent region -->
    <path d="M50 450 L 800 450 L 800 440 Z" fill="#53D000"></path>

    <!-- axes -->
    <path d="M50 0 L 50 450 L 800 450" fill="transparent" stroke="black" stroke-width="2"></path>

    <path d="M50 448 L 800 448" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="365" y="445" fill="black">O(logN), O(1)</text>

    <path d="M50 450 L 800 400" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="400" y="415" fill="black">O(N)</text>

    <path d="M50 450 Q 400 350, 800 150" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="385" y="300" fill="black">O(NlogN)</text>

    <path d="M50 450 Q 180 380, 250 0" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="230" y="150" fill="black">O(N^2)</text>

    <path d="M50 450 C 100 430, 120 350, 120 0" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="125" y="80" fill="black">O(2^N)</text>

    <path d="M50 450 C 80 450, 80 350, 80 0" fill="transparent" stroke="black" stroke-width="2"></path>
    <text x="80" y="40" fill="black">O(N!)</text>

    <text x="0" y="0" transform="translate(420 470)" style="dominant-baseline: middle; text-anchor: middle; font-size:20px; color: #555; font-style: italic;" fill="black">Number of items in Collections</text>
    <text x="0" y="0" transform="translate(30 230) rotate(-90)" style="dominant-baseline: middle; text-anchor: middle; font-size:20px; color: #555; font-size:20px; color: #555; font-style: italic;" fill="black">Number of Operations for given Big-O Notiation</text>

    </svg>
</div>
</center>

### 数据结构

1. 平均情况（Average Case）: 通常用 Θ (Theta) 表示。它表示在所有可能的输入情况下，算法的时间复杂度的平均值。
2. 最坏情况（Worst Case）: 通常用 O (Big O) 表示。它表示在所有可能的输入情况下，算法的时间复杂度的最大值，也就是在最不利的情况下算法的表现。

| Data Structure                                                                  | Access                                              | Search                                                  | Insertion                                                  | Deletion                                                  | Space       |
|----------------------------------------------------------------------------------|-----------------------------------------------------|-------------------------------------------------------|--------------------------------------------------------|-------------------------------------------------------|------------------------|
| [Array](http://en.wikipedia.org/wiki/Array_data_structure)                       | <code style="background-color:#53D000">Θ(1)</code>  | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Stack](http://en.wikipedia.org/wiki/Stack_(abstract_data_type))                 | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Queue](http://en.wikipedia.org/wiki/Queue_(abstract_data_type))                 | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Singly-Linked List](http://en.wikipedia.org/wiki/Singly_linked_list#Singly_linked_lists) | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Doubly-Linked List](http://en.wikipedia.org/wiki/Doubly_linked_list)           | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#FFFF00">Θ(N)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#53D000">Θ(1)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Skip List](http://en.wikipedia.org/wiki/Skip_list)                             | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#FFC543">O(NlogN)</code> |
| [Hash Table](http://en.wikipedia.org/wiki/Hash_table)                           | <code>N/A</code> | <code style="background-color:#53D000">Θ(1)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#53D000">Θ(1)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#53D000">Θ(1)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Binary Search Tree](http://en.wikipedia.org/wiki/Binary_search_tree)           | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Cartesian Tree](https://en.wikipedia.org/wiki/Cartesian_tree)                  | <code>N/A</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [B-Tree](http://en.wikipedia.org/wiki/B_tree)                                   | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Red-Black Tree](http://en.wikipedia.org/wiki/Red-black_tree)                   | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Splay Tree](https://en.wikipedia.org/wiki/Splay_tree)                         | <code>N/A</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [AVL Tree](http://en.wikipedia.org/wiki/AVL_tree)                               | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [KD Tree](http://en.wikipedia.org/wiki/K-d_tree)                                 | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#C8EA00">Θ(logN)</code> / <code style="background-color:#FFFF00">O(N)</code> | <code style="background-color:#FFFF00">O(N)</code> |

### 数组排序

| Algorithm                                                                 | Best                                 | Average                              | Worst                                 | Space Complexity                       |
|---------------------------------------------------------------------------|--------------------------------------|--------------------------------------|---------------------------------------|----------------------------------------|
| [Quicksort](http://en.wikipedia.org/wiki/Quicksort)                       | <code style="background-color:#FFC543">Ω(NlogN)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#C8EA00">O(logN)</code> |
| [Mergesort](http://en.wikipedia.org/wiki/Merge_sort)                      | <code style="background-color:#FFC543">Ω(NlogN)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color:#FFC543">O(NlogN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Timsort](http://en.wikipedia.org/wiki/Timsort)                           | <code style="background-color:#FFFF00">Ω(N)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color:#FFC543">O(NlogN)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Heapsort](http://en.wikipedia.org/wiki/Heapsort)                         | <code style="background-color:#FFC543">Ω(NlogN)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color:#FFC543">O(NlogN)</code> | <code style="background-color:#53D000">O(1)</code> |
| [Bubble Sort](http://en.wikipedia.org/wiki/Bubble_sort)                   | <code style="background-color:#FFFF00">Ω(N)</code> | <code style="background-color: #FF8989">Θ(N^2)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#53D000">O(1)</code> |
| [Insertion Sort](http://en.wikipedia.org/wiki/Insertion_sort)             | <code style="background-color:#FFFF00">Ω(N)</code> | <code style="background-color: #FF8989">Θ(N^2)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#53D000">O(1)</code> |
| [Selection Sort](http://en.wikipedia.org/wiki/Selection_sort)             | <code style="background-color: #FF8989">Ω(N^2)</code> | <code style="background-color: #FF8989">Θ(N^2)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#53D000">O(1)</code> |
| [Tree Sort](https://en.wikipedia.org/wiki/Tree_sort)                      | <code style="background-color:#FFC543">Ω(NlogN)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Shell Sort](http://en.wikipedia.org/wiki/Shellsort)                      | <code style="background-color:#FFC543">Ω(NlogN)</code> | <code style="background-color: #FF8989">Θ(n(logN)^2)</code> | <code style="background-color: #FF8989">O(n(logN)^2)</code> | <code style="background-color:#53D000">O(1)</code> |
| [Bucket Sort](http://en.wikipedia.org/wiki/Bucket_sort)                   | <code style="background-color:#53D000">Ω(n+k)</code> | <code style="background-color:#53D000">Θ(n+k)</code> | <code style="background-color: #FF8989">O(N^2)</code> | <code style="background-color:#FFFF00">O(N)</code> |
| [Radix Sort](http://en.wikipedia.org/wiki/Radix_sort)                     | <code style="background-color:#53D000">Ω(nk)</code> | <code style="background-color:#53D000">Θ(nk)</code> | <code style="background-color:#53D000">O(nk)</code> | <code style="background-color:#FFFF00">O(n+k)</code> |
| [Counting Sort](https://en.wikipedia.org/wiki/Counting_sort)              | <code style="background-color:#53D000">Ω(n+k)</code> | <code style="background-color:#53D000">Θ(n+k)</code> | <code style="background-color:#53D000">O(n+k)</code> | <code style="background-color:#FFFF00">O(k)</code> |
| [Cubesort](https://en.wikipedia.org/wiki/Cubesort)                        | <code style="background-color:#FFFF00">Ω(N)</code> | <code style="background-color:#FFC543">Θ(NlogN)</code> | <code style="background-color:#FFC543">O(NlogN)</code> | <code style="background-color:#FFFF00">O(N)</code> |

## 复杂度分析

### O(1)

```python
n = 100
total = (n + 1) * n // 2
```

### O(N)

通常和`for`循环有关

```python
n = 100
total = 0
for i in range(n):
    total += n
```

### O(N^2)

双重循环，而且第二重j每次更新到`n-1`, 有回头操作(即又0开始)

```python
for i in range(n):
    for j in range(n):
        print(i, j)
```

### O(logN)

二分查找，或者和平衡二叉树相关的，因为树的高度就是logN

```python
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = left + (right - left) // 2
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1  # Target not found
```

### O(k^N)

常见于暴力搜索

```python
def fibonacci(n):
    if n <= 1:
        return n
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)
```

### O(N!)

暴力搜索中，以及全排列问题

```python
def permute(nums):
    result = []
    backtrack(nums, 0, result)  # 调用外部的 backtrack 函数
    return result

def backtrack(nums, start, result):
    if start == len(nums):
        result.append(list(nums))
        return
    for i in range(start, len(nums)):
        nums[start], nums[i] = nums[i], nums[start]  # 交换
        backtrack(nums, start + 1, result)  # 递归生成后续排列
        nums[start], nums[i] = nums[i], nums[start]  # 还原交换
```

-- END --

1. [https://www.bigocheatsheet.com](https://www.bigocheatsheet.com)