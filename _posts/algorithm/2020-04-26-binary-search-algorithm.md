---
layout: post
title: "二分查找算法"
categories: 亢龙有悔
tags: Algorithm Binary-search
excerpt: "锤子，可以用来敲各种钉子"
---

* content
{:toc}

## 二分思想

> Binary Search是在排序"数组"中查找指定(Any/First/Last/Closest/Range)元素的一种快速搜索算法。

### 如下图所示：

查找数字**7**

1. 将数组一分为二，中间的元素14与**7**比较，由于**7** < 14,  目标在**左边的一半**
2. 将剩余部分一分为二，中间元素6与**7**比较，由于6 < **7**,  目标在**右边的一半**
3. 沿着图中箭头，不断的把问题缩小一半，直到找到目标

![binary_search_with_sorted_array](https://geemaple.github.io/images/binary_search_with_sorted_array.png)

## 递归思想

二分算法也是递归思想的一种，但这并不意味着二分一定要用递归来实现。

递归过程：

1. 二分搜索，将原问题分为左右两个子问题，中间值与目标对比，抛弃一半不可能的，将问题规模缩小一半
2. 重复步骤1，直到找到目标(或者未找到目标)

## 时间复杂度分析

二分查找相当于通过O(1)的执行时间(大小比较操作)，把问题缩小一半

```python
# T(N)表示一个问题，所需要的执行时间

T(N) = T(N/2) + O(1)
     = (T(N/4) + O(1)) + O(1)
     = ((T(N/8) + O(1)) + O(1)) + O(1)
     ...
     = T(1) + logN * O(1)
     = O(logN)
```

那通过O(N)的执行时间，把问题缩小一半呢？

## 倍增思想

一个无穷大的排序数组Arr，要求寻找目标T，但是内存只能读一部分，该怎么解决呢？要求时间复杂度O(LogT)

1. 如下,首先分别检测第**2^K**(K>=0)个, 直到找第**2^(k-1)**个 <= **T** <= 第**2^k**个
2. 然后有了上下边界，就可以正常二分了

```python
 第1个    第2个   第4个 
Arr[0], Arr[1], Arr[3], ... Arr[2^(K-1) - 1], Arr[2^K -1]... 

```

### 类似的倍增的思想:

1. 指数退避(Exponential backoff): **爬虫访问**
2. 数组动态扩容策略: **vector(C++)**, **ArrayList(Java)**

## 有哪些痛点

1. 代码死循环，边界条件如何判断
2. 数据溢出，index有溢出的可能
3. 丢掉错误的一半，从而错过正确答案
4. 看不出来，能用二分思想解决

## 标准化

标准化主要解决1-2条痛点，3-4只能多练习来解决

注意，**start=0, end=1. mid=(start + end) // 2**, 这里mid=0，也就是说，这个表达式的结果是***偏左的***

第一种：**left + 1 < right**, 不用考虑mid是+1还是-1，只是结果需要额外判断边界, 最好记

```python
int binarySearch(vector<int>& nums, int target){
    if (nums.size() == 0)
        return -1;

    int left = 0, right = nums.size() - 1;
    while (left + 1 < right){
        // Prevent (left + right) overflow
        int mid = left + (right - left) / 2;
        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid;
        } else {
            right = mid;
        }
    }

    // Post-processing:
    // End Condition: left + 1 == right
    if(nums[left] == target) return left;
    if(nums[right] == target) return right;
    return -1;
}
```

第二种：**left < right**, 终止条件**left==right**, 因为中值偏左, 所以mid = left + 1, 比较简洁

```python
int binarySearch(vector<int>& nums, int target){
  if(nums.size() == 0)
    return -1;

  int left = 0, right = nums.size();
  while(left < right){
    // Prevent (left + right) overflow
    int mid = left + (right - left) / 2;
    if(nums[mid] == target){ return mid; }
    else if(nums[mid] < target) { left = mid + 1; }
    else { right = mid; }
  }

  // Post-processing:
  // End Condition: left == right
  if(left != nums.size() && nums[left] == target) return left;
  return -1;
}
```

第三种：**left <= right**, 终止条件是**left > right**, 结合上一条, right = mid - 1也要让一步, 比较简洁

```python
int binarySearch(vector<int>& nums, int target){
  if(nums.size() == 0)
    return -1;

  int left = 0, right = nums.size() - 1;
  while(left <= right){
    // Prevent (left + right) overflow
    int mid = left + (right - left) / 2;
    if(nums[mid] == target){ return mid; }
    else if(nums[mid] < target) { left = mid + 1; }
    else { right = mid - 1; }
  }

  // End Condition: left > right
  return -1;
}
```


## 额外技巧

1. 拿到一道算法题，除了认真审题，理解要求，要尽快确认属于哪类算法
2. 优化一个暴力破解为O(N)的算法，那基本上就只能和二分相关了
3. 问题答案的个数，是该问题算法复杂度的下限
4. 如果数组中，每个元素都发生了改变，那至少需要O(N)的时间复杂度
5. 如何恢复[4,5,6,1,2,3]到[1,2,3,4,5,6]三步翻转法

-End- 素质三连(在看，评论，转发)
