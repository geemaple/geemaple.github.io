---
layout: post
title: "并查集"
categories: Algobase
tags: Algobase DisjointSet
excerpt: "Big Brother"
---

* content
{:toc}

## 并查集

支持集合快速**合并**和**查找**的数据结构

以下图为例Google和YouTube都是字母表的子公司, 当Google收购FitBit的时候, 那么FitBit也是Alphabet这个集合中的一员了

```python
          0
       Alphabet    
       
         ^ ^
       ^     ^
     ^         ^
   ^             ^
                            收购
YouTube         Google  <<<<<<<<<<<<<  FitBit              
   1               2                      3

```

### 数组表示

```python
array[0] = 0
array[1] = 0
array[2] = 0
array[3] = 2
```

### 哈希表示

当然，也可以将字母编号，就可以用数组表示了

```python
dict['Alphabet'] = 'Alphabet'
dict['YouTube'] = 'Alphabet'
dict['Google'] = 'Alphabet'
dict['FitBit'] = 'Google' 
```

### 跟节点

跟节点有两种:

1. 跟节点的父节点指向Null, 和上图中表示一致
2. 跟节点的父节点指向自己, **下面讲解偏好这一种**

### 查找

O(log*N), 即均摊复杂度为O(1)

查询两个对象，是否处在同一个集合中，也就是判断它们的跟节点是不是同一个， 比如YouTube和FitBit就在同一个集合中

如果关系链路特别长，会降低查找效率，这个可以使用路径压缩: 一旦知道跟节点是谁，就可以直接指向

```python
     1

     ^
     ^
                                            1
     2                                   
                                          ^ ^ ^
     ^              =>                  ^   ^   ^
     ^                                ^     ^     ^
     
     3                              2       3       4

     ^
     ^

     4
```

### 合并

O(1)

就是将两个对象，融合成同一个集合, 比如Google收购了FitBit

合并操作，**首先找到跟节点，再将跟节点合并**


### 代码实现

以下是将并查集的代码放入一个Class中, 实际操作可以只用两个函数+变量

```python
class UnionFind:
    def __init__(self, num: int):
        self.ancestor = [i for i in range(num)]
        
    def find(self, node: int) -> int:
        
        path = []
        while self.ancestor[node] != node:
            path.append(node)
            node = self.ancestor[node]
            
        # 路径压缩
        for child in path:
            self.ancestor[child] = node
            
        return node
    
    def union(self, a: int, b: int):
        # 先找到跟节点，在合并
        self.ancestor[self.find(a)] = self.find(b)
```

PS: 代码中用数组实现的，你也可以尝试用Hash来实现

### 参考链接

[https://en.wikipedia.org/wiki/Iterated_logarithm](https://en.wikipedia.org/wiki/Iterated_logarithm)

[并查集时间复杂度][https://en.wikipedia.org/wiki/Disjoint-set_data_structure#Proof_of_O(m_log*_n)_time_complexity_of_Union-Find]

--End--