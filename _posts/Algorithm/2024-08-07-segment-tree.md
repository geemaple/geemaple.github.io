---
layout: post
title: "数据结构 - 线段树SegmentTree"
categories: Algorithm
tags: Segment-Tree
excerpt: "最小最大与和"
mathjax: true
---

* content
{:toc}

## 概念

线段树是一颗二叉树，left代表左区间，right代表右区间

非叶子结点有左右两颗叶子，叶子不可再分割

### 节点

线段树的每个节点记录了一个区间```[l, r]```的最大值，也可以是最小值或者"和"性质的运算

```
                     ------------
                     |   node   |
                     | [0-3]Max |
                     ------------
                    /            \
                   /              \
         ------------             ------------
         |   node   |             |   node   |
         | [0-1]Max |             | [2-3]Max |
         ------------             ------------
         /         \               /         \
        /           \             /           \
------------   ------------   ------------   ------------
|   node   |   |   node   |   |   node   |   |   node   |
| [0-0]Max |   | [1-1]Max |   | [2-2]Max |   | [3-3]Max |
------------   ------------   ------------   ------------
```

```python
class SegmentTreeNode:
    def __init__(self, start, end, val=None):
        self.start = start
        self.end = end
        self.val = val
        self.left = None
        self.right = None

```

### 创建Build

时间复杂O(N), 最后创建不超过`2N - 1`个节点

1. 自上而下分割区间，参考```build_range```
2. 自下而上回溯更新，参考```build_tree```

```python
class SegmentTree:
    def build_range(self, start, end):
        # write your code here
        if start > end:
            return None

        node = SegmentTreeNode(start, end)
        if start == end:
            return node
        
        mid = (start + end) // 2
        node.left = self.build(start, mid)
        node.right = self.build(mid + 1, end)

        return node

    def build_tree(self, a: list, start: int, end: int) -> SegmentTreeNode:
        if start > end:
            return None

        node = SegmentTreeNode(start, end, a[start])
        if start == end:
            return node

        mid = (start + end) // 2
        node.left = self.helper(a, start, mid)
        node.right = self.helper(a, mid + 1, end)
        node.max = max(node.left.max, node.right.max)

        return node
```

### 更新Update

时间复杂度O(logN)

1. 自上而下递归查找, 根据每个节点的范围，很容易确定单个index在哪里
2. 自下而上回溯更新, 更新叶子到根的所有值

```python
    def modify(self, root: SegmentTreeNode, index: int, value: int):
        # write your code here
        if index == root.start and index == root.end:
            root.max = value
            return
            
        mid = (root.start + root.end) // 2
        if index <= mid:
            self.modify(root.left, index, value)
        else:
            self.modify(root.right, index, value)

        root.max = max(root.left.max, root.right.max)
```

### 查找Query

时间复杂度O(logN)

分以下四种情况:

```
                      |
         |---query---|
                        |---query---|
                |---query---|                          
 |--------------------|--------------------|
start                mid                  end
```


```python
    def query(self, node: SegmentTreeNode, start: int, end: int) -> int:
        if node is None:
            return None

        if start == node.start and end == node.end: # 1.完全重合
            return node.min_val

        mid = (node.start + node.end) // 2
        if end <= mid: # 2. 完全落在左边
            return self.query(node.left, start, end)
        elif start > mid: # 3. 完全落在右边
            return self.query(node.right, start, end)
        else: # 4. 左右都有
            left_val = self.query(node.left, start, mid)
            right_val = self.query(node.right, mid + 1, end)
            return min(left_val, right_val)
```

## 线段树

### 空间大小

通常我们不用节点来表示线段树，而是使用数组，没错，就像堆的实现一样

第一层1个节点，第二层一分为二为2个节点，以此类推得到如下公式: (*注意：$${\lceil\log_2 n\rceil}$$ 代表向上取整*)

$
1 + 2 + 4 + \dots + 2^{\lceil\log_2 n\rceil} \lt 2^{\lceil\log_2 n\rceil + 1} \lt 4n
$

1. 左边为等比数列，额外+1, 2个1=2，2个2=4, 以此类推我们得到 $$2^{\lceil\log_2 n\rceil + 1} - 1$$
2. 中间可以写成 $$ 2 \times 2^{\lceil\log_2 n\rceil} $$, 正常情况下，$$2^{\log_2 n} = n$$, 有了向上取整就会大一些，但再大也不会大于1，所以4n是上限

结论就是，我们需要4n数组空间

### 节点编号

1. 根节点从1开始
2. 左子节点 = ```2 * i```
3. 右子节点 = ```2 * i + 1```
4. 父亲节点 = ```i / 2```

### 区间和

#### 基础版代码
```python
class SegmentTreeNode:
    def __init__(self, start: int, end: int, val: int):
        self.start = start
        self.end = end
        self.val = val
        self.left = None
        self.right = None

class SegmentTree:
    def __init__(self, nums: list):
        self.root = self.build(nums, 0, len(nums) - 1)

    def build(self, nums: list, start: int, end: int):
        node = SegmentTreeNode(start, end, nums[start])
        if start == end:
            return node

        mid = (start + end) // 2
        node.left = self.build(nums, start, mid)
        node.right = self.build(nums, mid + 1, end)
        node.val = node.left.val + node.right.val
        return node

    def update(self, node: SegmentTreeNode, index: int, val: int):
        if index == node.start and index == node.end:
            node.val = val
            return

        mid = (node.start + node.end) // 2
        if index <= mid:
            self.update(node.left, index, val)
        else:
            self.update(node.right, index, val)

        node.val = node.left.val + node.right.val
        
    def query(self, node: SegmentTreeNode, start: int, end: int) -> int:
        if start == node.start and end == node.end:
            return node.val
        
        mid = (node.start + node.end) // 2
        if end <= mid:
            return self.query(node.left, start, end)
        elif start > mid:
            return self.query(node.right, start, end)
        else:
            left_val = self.query(node.left, start, mid)
            right_val = self.query(node.right, mid + 1, end)
            return left_val + right_val

class NumArray:

    def __init__(self, nums: List[int]):
        self.tree = SegmentTree(nums)
 
    def update(self, index: int, val: int) -> None:
        self.tree.update(self.tree.root, index, val)

    def sumRange(self, left: int, right: int) -> int:
        return self.tree.query(self.tree.root, left, right)
```

#### 常用版代码
```python
class segmentTree:
    def __init__(self, a: list):
        n = len(a)
        self.seg = [0 for i in range(4 * n)]
        self.build(a, 1, 0, n - 1)
        print(self.seg)

    def build(self, a: list, v: int, i: int, j: int):
        if i == j:
            self.seg[v] = a[i]
            return

        m = (i + j) // 2
        self.build(a, 2 * v, i, m)
        self.build(a, 2 * v + 1, m + 1, j)
        self.seg[v] = self.seg[2 * v] + self.seg[2 * v + 1]

    def query(self, v: int, i: int, j: int, l: int, r: int) -> int:
        if l > r:
            return 0

        if l == i and r == j:
            return self.seg[v]

        m = (i + j) // 2
        left = self.query(2 * v, i, m, l, min(m, r))
        right = self.query(2 * v + 1, m + 1, j, max(m + 1, l), r)
        return left + right

    def update(self, v: int, i: int, j: int, pos: int, val: int):
        if i == j:
            self.seg[v] = val
            return

        m = (i + j) // 2
        if pos <= m:
            self.update(2 * v, i, m, pos, val)
        else:
            self.update(2 * v + 1, m + 1, j, pos, val)

        self.seg[v] = self.seg[2 * v] + self.seg[2 * v + 1]

class NumArray:

    def __init__(self, nums: List[int]):
        self.n = len(nums)
        self.seg = segmentTree(nums)

    def update(self, index: int, val: int) -> None:
        self.seg.update(1, 0, self.n - 1, index, val)        

    def sumRange(self, left: int, right: int) -> int:
        return self.seg.query(1, 0, self.n - 1, left, right)
```

[https://cp-algorithms.com/data_structures/segment_tree.html](https://cp-algorithms.com/data_structures/segment_tree.html)

-- END --