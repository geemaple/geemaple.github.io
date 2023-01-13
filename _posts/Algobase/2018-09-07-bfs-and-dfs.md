---
layout: post
title: "深度优先与广度优先搜索"
categories: Algobase
tags: Algobase BFS DFS
excerpt: "图的搜索遍历，深度优先与广度优先"
---

* content
{:toc}

##广度优先搜索

BFS是图的遍历策略，该算法从某一指定节点出发，先搜遍所有的邻居节点，然后再拓展到下一层级，

如下图，以树为例，BFS结果是:

```
[1]
[2, 3, 4]
[5, 6, 7, 8]
[9, 10, 11, 12]
```

![tree-breadth-first-search](http://geemaple.github.io/images/tree-breadth-first-search.png)


##深度优先搜索

DFS图的遍历策略，与BFS策略相反，该算法从某一指定节点出发，先探索尽可能远，然后回溯 

回溯是指，先遍历[1, 2, 3, 4], 然后4没有更深的节点，然后把4丢掉，退回[1, 2, 3],再把5填到结果中得到[1, 2, 3, 5]，以此类推

如下图：DFS结果是:

```
[1, 2, 3, 4] pop 4
[1, 2, 3, 5] pop 5, 3
[1, 2, 6] pop 6, 2
[1, 7] pop 7
[1, 8, 9, 10] pop 10
[1, 8, 9, 11] pop 11, 9
[1, 8, 12]
```

![tree-breadth-first-search](http://geemaple.github.io/images/tree-depth-first-search.png)


## 代码实现

**递归实现:**

DFS

```
def __init__(self):
    val = 0
    children = []

def search(node):
    if node is None:
        return

    print node.val

    for sub in node.children:
        search(sub)
```

**非递归实现:**

DFS

```
nodes_to_visit = [root]

while( len(nodes_to_visit) > 0 ) {

    #从尾部取出
    node = nodes_to_visit.pop()

    print node.val
	
    for sub in node.children:
        nodes_to_visit.append(sub) 
}
```

BFS

```
nodes_to_visit = [root]

while( len(nodes_to_visit) > 0 ) {

    #从头部取出
    node = nodes_to_visit.pop(0)

    print node.val
	
    for sub in node.children:
        nodes_to_visit.append(sub) 
}
```

如果你仔细观察，非递归版本BFS与DFS是非常对称，只是DFS从尾部取出(Stack)，BFS从头部取出(Queue)

PS：图的搜索遍历一定要记得记得去重, 如果你对代码还不太熟，对着代码，多调试几遍吧～

--END--
