---
layout: post
title: "Boyer-Moore大多数选择算法"
categories: Algobase
tags: Algobase BoyerMoore
excerpt: "把O(N*logN)优化成O(N)都不容易"
---

* content
{:toc}

> 给一个大小为N的数组，找到大多数的那个元素，大多数元素定义为**该元素出现的次数>N/2**, 你可以假设数组不为空，且该元素一定存在(leetcode-169)

follow-up: 如果要求空间复杂度为O(1)呢？(+空间复杂度为O(N)呢?)

例如：

[3,2,3] 答案为**3**

[2,2,1,1,1,2,2] 答案为**2**

## 字典解题方案：

可以用一个字典，来记录每个元素出现的个数，然后再遍历字典找到满足条件的，即可

两遍for循环，时间复杂度O(N), 空间复杂度O(N)

可是这个不满足follow up问题

## O(1)观察方案：

假如数组是排序的，中间一项就可能是答案，只要再for统计一下中间元素个数，就知道是不是答案

对于排序数组，以[1,1,1,2,2,2]为参考，把数组**一分为二**, 但是此时，没有满足条件的元素

只要一边满足条件[1,1,1,1,2,2] 或者 [1,1,2,2,2,2]，必定迫使另一边不满足条件，也就是说，最多只有一个答案(或者没有答案), 奇数比较容易思考, 结论一致

或者可以想像，多数元素为一个整体滑块，左右移动的时候，中间项必然是答案

## O(1)二分方案：

假如数组是排序的, 用二分法很容易找到head和tail, 计算**tail - head + 1 > N/2**就可以了(leetcode-1150)

## Boyer-Moore
Boyer-Moore多数选择算法来自论文《Boyer-Moore Majority Vote Algorithm》

完美满足题目要求，时间复杂度O(N)，空间复杂度O(1)

该算法需要2遍for循环，实现起来也特别简单，但是需要一点力气去理解

1. 第一遍，我们找到一个**候选元素**， 如果存在，那么该元素就是答案
2. 第二遍，数个数，来排除意外的情况, 即没有这样的元素


### 算法过程

我们需要2个变量, **candidate**和**counter**

首先，遍历数组比较**counter**和**0**，如果**counter等于0**，把当前元素值赋值给**candidate**

接下来，比较**candidate和当前元素**，如果相等，counter++, 如果不相等，counter--

结果**candidate**就可能是答案, 再次for循环数一下就可以验证了

python代码如下：

```python
candidate = 0
counter = 0

for val in arr:
  if counter == 0:
    candidate = val

  if candidate == val:
    counter += 1
  else:
    counter -= 1
```

### 算法解释

我们只考虑，肯定存在答案的情况，如果答案不存在，第二遍for，就可以简单排除

首先，考虑下面的例子，第一个元素不是答案：

```python
[5, 5, 9, 9, 9, 5, 9, 9, 5]
```

当数组下标**i = 0**时:

此时**5**被赋值给**candidate**, **1**赋值给**counter**

因为**5**并不是答案，一定将来某个时刻，能够找到足够多的**9**来抵消**counter**的累加值，使其变为**0**, 也就是**i = 3**时, 此时如下：

数组遍历：

```python
[5, 5, 9, 9, ...]
```
counter值：

```python
[1, 2, 1, 0, ...]
```

当**counter减少到0**时，5和9消耗一样多，这里的5可以替换替换成**答案以外的值**都成立，而且剩余未遍历数组，**9**依然满足条件，是大多数元素

```python
[...9, 5, 9, 9, 5]
```

也就是说，每当**counter=0**时，**candidate**都可以放心的丢弃之前的值，并不影响最终结果。

重复上述步骤，我们最终可以找到一个**candidate**值，**counter > 0**

> 有个好玩的想法，就是数组中每个元素都假设成为一个士兵，值相等的士兵在同一个阵营，不同阵营的士兵相遇就会同时阵亡，吃鸡只有一个阵营可以赢得胜利，假设存在大多数的士兵，那么该阵营的士兵就能存活下来，也就是题目的答案

## 额外延伸

该算法可以分布式计算，详情《Finding the Majority Element in Parallel》，也就是说可以让多个机器协作，来完成一个算法. 

或者说，可以用归并思想来解决。

比如：分开问题，给A+B机器计算，C把A+B结果汇总，再计算

```python
[1, 1, 1, 2, 1, 2, 1, 2, 2]
```

机器A:

```python
[1, 1, 1, 2, 1]
candidate = 1
counter = 3
```

机器B:

```python
[2, 1, 2, 2]
candidate = 2
counter = 2
```

机器C：

```python
[1,1,1,2,2]
candidate = 1
counter = 1
```

所以**1**是最终答案

恭喜你，你看到这里，了不起，不如试试leetcode-229

该算法一个可能的应用，就是容错计算，并行多个计算，选择大多数，作为靠谱的答案输出。

## 参考：

《Majority Voting Algorithm》 https://gregable.com/2013/10/majority-vote-algorithm-find-majority.html

《Boyer-Moore Majority Vote Algorithm》 http://www.cs.rug.nl/~wim/pub/whh348.pdf

《Finding the Majority Element in Parallel》 http://www.crm.umontreal.ca/pub/Rapports/3300-3399/3302.pdf

--End--