---
layout: post
title: "算法 - 数组与链表"
categories: Algorithm
tags: Array LinkedList
excerpt: "一线之间"
---

* content
{:toc}

> CPU L1缓存读写速度高出内存100倍左右, 缓存在加载地址的时候，基于**Locality of reference**也会加载相邻的地址内容。(如果一个地址被访问，那么它相邻的地址也极有可能之后被访问)

## 数组

```python
-----------------  
| 1 | 2 | 3 | 4 |
-----------------
```

数组使用**连续的内存**来存储同类型的数据, 需要指定大小, 由于数组内各个元素类型一致, 很容易计算每个元素的偏移量。

数组的一个最大特点是支持**随机访问/下标访问**, 缓存友好型数据结构, 访问速度很快。

### 动态数组

```python
-----------------
| 1 | 2 | 3 | 4 | 添加5  
----------------- 
  |   |   |   |   |                  
  v   v   v   v   v 
---------------------------------
| 1 | 2 | 3 | 4 | 5 |   |   |   |  开辟新空间
---------------------------------
```

为了克服数组的固定大小的缺点，好多语言提供动态数组，可以根据指定或实际情况动态扩容。例如C++中的vector, Java中的ArrayList

扩容的时候需要开辟新的空间，然后把旧的数组拷贝到新的数组中。扩容可以采用倍增的策略。

扩容比较耗费资源，计算机采用均摊复杂度(Amortized Analysis)来衡量其时间复杂度, 记作O*(N)

### 二维数组

```python
A = [
    [11, 12, 13, 14],
    [21, 22, 23, 24],
    [31, 32, 33, 34],
    [41, 42, 43, 44],
  ]
```

第N行第M列 = A[N-1][M-1]

### 子数组的和

```python
# 前0个数的和
PrefixSum[0] = 0

# 前i个数的和
PrefixSum[i] = A[0] + A[1] + ... A[i - 1]

# 则有
Sum(i~j) = PrefixSum[j + 1] - PrefixSum[i] 
```

### 规避数组缺点

数组最大的缺点是保持连续空间，删除或者插入比较靠前的位置，那么后边的都要做相应的移动。

1. 合并两个排序数组，比如[3, 4]合并到[1, 2, 5, null, null]。 可以从大到小合并, 避免数组移动
2. 删除某个值，可以将目标位置和结尾对调，在进行删除

### 恢复旋转排序数组

```python
[10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9]
|---------------左边-------------||-------右边------｜
```

1. 先翻转左边 
2. 再翻转右边
3. 最后翻转全部

## 字符串

```python
--------------------------     
|'H'|'E'|'L'|'L'|'O'|'\0'|
--------------------------
```

字符串可以看成特殊的unicode字符数组, 以特殊字符'\0'结尾。

### 可变性

Java中的String是**Immutable**的, 拼接两个字符串实际先分配足够的空间，然后依次拷贝。如果有大量字符拼接可以使用StringBuilder。

如果使String可修改，可以使用toCharArray方法

```java
String s = "Hello World";
char[] str = s.toCharArray();
```

## 链表

```python
     p1        p2                ​栈空间
     |         |
     v         v
-------------------------------------
​
   node1  ->  ​node2              堆空间
​
-------------------------------------
​
```

链表也是线性数据结构(也可以看作特殊的树/图)。链表是离散型数据结构，以节点为单位，分散在内存的不同位置。

链表的优点是不需要连续空间，缺点便是无法**随机访问/下标访问**, 只能顺序查找。

所以, 同样是线性结构, 链表要慢许多, 首先访问链表无法有效命中CPU缓存, 其次node->next需要有寻址操作

### 单链表

```python
--------   --------   --------   ---------
| 1 | x--->| 2 | x--->| 3 | x--->| 4 | x--> Null
--------   --------   --------   ---------
```

链表一般考察的是编程的基本功，没有什么相应的算法，只是把操作用代码来实现

### 双向链表

```python
---------   -----------    -----------    -----------
|   | x------> |   | x------> |   | x------> |   | x------> Null
| 1 | <------x | 2 | <------x | 3 | <------x | 4 |
---------   -----------    -----------    -----------
```

双端队列(Deque)算是阉割版本的双向链表，只能从两头添加删除

经典缓存LRU使用的便是双链表+哈希，如果有新访问的便将数据节点放在链表头部

### 头节点

对于链表来说，头节点最特殊，没有前继节点。通常需要特殊处理。

如果给链表头加一个新头节点，那么就消除了特殊Case的情况，生活变得简单不少。

```python
1 -> 2 -> 3 -> 4 -> Null
^
head

new_head -> 1 -> 2 -> 3 -> 4 -> Null

head = new_head.next
```

## 双指针

双指针是线性数据结构经常使用的编程技巧, 比如反转链表

### 同向双指针

1. 按条件左右分割(左边奇数右边偶数，左边小于k右边大于k, 左边满足条件右边不满足等)
2. 寻找两条链表相交的节点(到达末尾，换另一条链)
3. O(1)空间拷贝链表

### 相向双指针

1. 判断数组回文串
2. 反转数组

### 快慢双指针

1. 比如链表是否有环，如果快指针追赶上慢指针，便是有环
2. 移除链表倒数第K个节点
3. 获取链表的中间节点，判断链表是否回文串

> Linked-list劈成两半，记得将中间节点node->next = null

--End--
