---
layout: post
title: "数据结构-栈Stack"
categories: Algorithm
tags: Stack
excerpt: ""
---

* content
{:toc}

单调栈是一种数据结构，通常用于解决一系列需要维护元素顺序的问题。它们主要应用于以下几类问题：

### 1. 找到数组中每个元素的下一个更大元素/下一个更小元素
单调栈可以有效地解决类似 "Next Greater Element" 或 "Next Smaller Element" 的问题。这些问题通常需要我们在 O(n) 时间复杂度内找到每个元素的下一个更大或更小的元素。

#### 示例：
给定一个数组 `nums`，找到每个元素右边的第一个比它大的元素。如果不存在，则返回 -1。

```python
def nextGreaterElements(nums):
    n = len(nums)
    res = [-1] * n
    stack = []
    
    for i in range(2 * n):
        while stack and nums[stack[-1]] < nums[i % n]:
            res[stack.pop()] = nums[i % n]
        if i < n:
            stack.append(i)
    
    return res
```

### 2. 柱状图中的最大矩形
单调栈可以有效地解决 "Largest Rectangle in Histogram" 的问题。这个问题要求在一个柱状图中找到面积最大的矩形。

#### 示例：
给定一个数组 `heights`，其中每个元素表示柱子的高度，求能在柱状图中找到的最大矩形面积。

```python
def largestRectangleArea(heights):
    stack = []
    max_area = 0
    heights.append(0)
    
    for i in range(len(heights)):
        while stack and heights[i] < heights[stack[-1]]:
            h = heights[stack.pop()]
            w = i if not stack else i - stack[-1] - 1
            max_area = max(max_area, h * w)
        stack.append(i)
    
    heights.pop()
    return max_area
```

### 3. 滑动窗口的最大值
在一个数组中找到每个滑动窗口的最大值。单调栈（或单调队列）可以在 O(n) 时间内解决这个问题。

#### 示例：
给定一个数组 `nums` 和一个滑动窗口的大小 `k`，找到每个滑动窗口中的最大值。

```python
from collections import deque

def maxSlidingWindow(nums, k):
    if not nums:
        return []
    
    deq = deque()
    result = []
    
    for i in range(len(nums)):
        if deq and deq[0] < i - k + 1:
            deq.popleft()
        
        while deq and nums[deq[-1]] < nums[i]:
            deq.pop()
        
        deq.append(i)
        
        if i >= k - 1:
            result.append(nums[deq[0]])
    
    return result
```

### 4. 股票问题
单调栈可以解决某些类型的股票买卖问题，例如找到某天之后的最大涨幅。

### 总结
单调栈在解决需要比较元素顺序和找到特定条件下的相邻元素的问题时非常有效。常见的应用场景包括：

- 找到数组中每个元素的下一个更大/更小元素
- 柱状图中的最大矩形面积
- 滑动窗口的最大值
- 一些股票买卖问题

其关键思想是利用栈的数据结构，通过维护一个单调递增或递减的序列来高效地进行元素比较和查找。

--End--
