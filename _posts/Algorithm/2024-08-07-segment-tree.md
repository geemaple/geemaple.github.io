---
layout: post
title: "数据结构 - 线段树SegmentTree"
categories: Algorithm
tags: Segment-Tree
excerpt: "最小最大与和"
---

* content
{:toc}

## 线段树

线段树是一颗二叉树，left代表左区间，right代表右区间

非叶子结点有左右两颗叶子，叶子不可再分割

### 节点

线段树的每个节点记录了一个区间```[l, r]```的最大值，也可以是最小值或着和

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

### 效率考虑

个人思考是通过2叉树的logN高度，利用额外的空间创建了这样的树

类似的数据结构堆，使用空间与目标大小相等，没有使用额外空间

如果使用Array来实现子结点，效率会更高一些：
1. 左子节点 =  ```2 * i + 1```
2. 右子结点 =  ```2 * i + 2```
3. 父亲结点 =  ```(i - 1) // 2```

### 用途

主要用于求区间的最大值，最小值，和，乘积，个数

-- END --