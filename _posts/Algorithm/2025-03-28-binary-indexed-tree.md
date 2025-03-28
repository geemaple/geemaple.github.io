---
layout: post
title: "数据结构 - 索引树BIT"
categories: Algorithm
tags: Binary-Indexed-Tree ‌Fenwick-Tree
excerpt: "动态前缀和"
---

* content
{:toc}

## Fenwick Tree

线段树`Segment Tree`适合多种区间操作。

相比来说, `Fenwick Tree`要代码要简单很多，适合前缀和，还有高频的元数更新。

`BIT`使用bit位来记录节点之间的关系，如果当前节点`node`数组下标等于i

```python
# i & -1 从右边开始有效bit(即bit=1)的结果

node = i
parent = i - (i & -i) # 打掉最右有效位
child = i + (i & -i) 
```

### 图示

根节点`dummy_root=0`, 只是一个占位，没有实际意义，`BIT`的索引下表从`1`开始。与数组从`0`开始不同

每个节点表示的范围和 = ```(根节点上限, 根节点上限 + (i & -i)]```

![索引树]({{site.static}}/images/algorithm_fenwick_tree.png)

### 代码

```python
class FenwickTree:
    def __init__(self, size):
        self.n = size
        self.tree = [0] * (self.n + 1)
    
    def update(self, i, delta):
        i += 1  # 转为 1-based 索引
        while i <= self.n:  # 更新所有影响区间
            self.tree[i] += delta
            i += i & -i
    
    def query(self, i):
        i += 1  # 转为 1-based 索引
        res = 0
        while i > 0: # 从查询节点沿着根节点
            res += self.tree[i]
            i -= i & -i # 打掉最右有效位，得到父节点
        return res
```

### 复杂度

时间: O(LogN)

空间: O(N)

### 用途

主要用于前缀和，乘积，XOR, OR

-- END --