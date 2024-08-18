---
layout: post
title: "语言 - Python"
categories: Algorithm
tags: Python
excerpt: Life is short, I use python
---

* content
{:toc}

## 拷贝

```python
tmp = [1,2,3]
res = []
res.append(tmp)
del tmp[1]
print(res) # 结果 = [1,3]
```

拷贝只对于复合数据结构(数组，类)才有所不同, 虽然不同语言处理细节不同, 但简单原则如下:

### 浅拷贝(assign)

尽可能拷贝的越少越好，无论是否返回​同一个对象，最终的数据源是共享的，一份数据的改变体现在所有的拷贝上

```python
A = [1,2,3]  # C
B = A        # C 
# 如果C改变，那么B的状态也会改变
```

### 深拷贝(Constructor)

拷贝所有细节，返回不同的对象，最终的数据源是隔离的，一份数据的改变不会影响其他拷贝

深拷贝有潜在的诸多问题:

1. 拷贝内容过多, 通常解决的方案，是让开发者自己定义如何拷贝。
2. 循环拷贝, 属于图的遍历范畴，所以记得去重复。

```python
A = [1,2,3] # C0
B = list(A) = A[:] = A.copy() # C1
# 如果C0改变，B的状态C1没有影响
```

## 数据结构

### 元组

与List非常相似，但是Tuple是不可变的数据结构

```python
# 创建, 等号右边可以用括号扩起来
empty = ()
xyz = 12345, 54321, 'hello!'
one = 12345,
## Unpacking
x, y, z = xyz
x, = one
```

Tuple内部是可以有List这样可变的元素的

```python
a = [1,2,3]
b = [4,5,6]
# 创建, 等号右边可以用括号扩起来
t = (a, b) 
# ([1, 2, 3], [4, 5, 6])
a.append(4)
b.append(7)
print(t)
# ([1, 2, 3, 4], [4, 5, 6, 7])
```

**如果Tuple足够满足，那么Tuple由以下两个优势:**

1. 元组由于不可修改天然的线程安全
2. 元组在占用的空间上面都优于列表

```python
import sys
t = tuple(range(2 ** 24))
l = [i for i in range(2 ** 24)]

# 比较内存使用
print(sys.getsizeof(t), sys.getsizeof(l)) 
```

Tuple创建方式

```python
import timeit

# 从Range转换Tuple 这种速度最快，推荐此方法
timeit.timeit('''t = tuple(range(10000))''', number = 10000)

# 从List创建Tuple
timeit.timeit('''t = tuple([i for i in range(10000)])''', number = 10000)

# 从Range创建Tuple
timeit.timeit('''t = tuple(i for i in range(10000))''', number = 10000)

# Unpacking生成器创建Tuple
timeit.timeit('''t = *(i for i in range(10000)),''', number = 10000)
```

### 栈

```python
# 使用List作为栈
stack = [3, 4, 5]

# 入栈
stack.append(6)
# 出栈
val = stack.pop()
# 栈定元素
val = stack[-1]
```

### 队列

队列是FIFO, 但是List对于First Out效率不够高。通常用双端队列Deque来实现队列

Deque的特点是，两端添加和删除都是O(1)的时间复杂度

```python
from collections import deque
queue = deque(["Eric", "John", "Michael"])

# 入队列
queue.append("Terry")
# 出队列
queue.popleft()
```

### 集合

![图片说明]({{site.static}}/images/python-data-structure-set.png)

```python
empty = set()
a = {1, 2, 3, 3, 3, 2}
b = {1, 3, 5, 7, 9}

# 超集和子集
a <= b
a.issubset(b)
b.issuperset(a)

# 交集
intersection = a & b
# 并集
union = a | b
# 差
subtraction = a - b
# 对称差
symmetric_difference = a ^ b
```

### 字典

字典由(Key: Value)对组成，对于Key的要求是不可变类型(String, Number等)，

所以Tuple可以作为Key，但是List却不行。

```python
# {'sape': 4139, 'guido': 4127, 'jack': 4098}
d = dict([('sape', 4139), ('guido', 4127), ('jack', 4098)])

# {2: 4, 4: 16, 6: 36}
d = {x: x**2 for x in (2, 4, 6)}

# {'sape': 4139, 'guido': 4127, 'jack': 4098}
d = dict(sape=4139, guido=4127, jack=4098)
```

默认字典, 可以提供一个默认值，能够减少代码行数

```python
from collections import defaultdict

d = defaultdict(int)  # 默认值是 0
d = defaultdict(list) # 默认值时 []
d = defaultdict(set)  # 默认值 set()
d = defaultdict(lambda: 42) # 默认值42， lambda不常用
```

**但是**如果Tuple内包含可变类型，那么也不能作为Key, 会出现如下错误:

```python
TypeError: unhashable type: 'list'
```

### 堆(小)

优先队列通常用堆来实现，python语言是个小堆，最小元素在堆顶, 大堆的实现通常将数字改成负数

```python
iimport heapq

# 创建一个空的优先队列
pq = []

# 插入元素 (优先级, 数据)
heapq.heappush(pq, (1, 'task 1'))
heapq.heappush(pq, (3, 'task 3'))
heapq.heappush(pq, (2, 'task 2'))

# 顶部元素
top = pq[0]

# 获取并删除优先级最高的元素
print(heapq.heappop(pq))  # (1, 'task 1')
```

## 循环

### Range循环

序列数据结构(List, Tuple, Range)的一种, 常与For循环一起使用

```python
# 0 - 9
val = range(10)
val = range(0, 10)
val = range(0, 10, 1)

# [0, 2, 4, 6, 8]
for num in range(0, 10, 2):
  print(num)

# [8, 6, 4, 2, 0]
for num in reversed(range(0, 10, 2)):
  print(num)

# [8, 6, 4, 2, 0]
for num in range(8, -1, -2):
  print(num)
```

### 列表循环

```python
l = ['tic', 'tac', 'toe']

for index in range(len(l))
  print(index, l[index])

for val in l:
  print(val)

for index, val in enumerate(l):
  print(index, val)
```

### 字典循环

```python
d = {'gallahad': 'the pure', 'robin': 'the brave'}

for key in d:
  print(key, d[key])

for key, val in d.items():
  print(key, val)
```

### zip循环

返回Tuple的迭代器, 第i个元素来自于参数中每一个第i个元素, 长度等于最短的那个参数

```python
questions = ['name', 'quest', 'favorite color']
answers = ['lancelot', 'the holy grail', 'blue']
# zip结果 = [('name', 'lancelot'), ('quest', 'the holy grail'), ('favorite color', 'blue')]
for q, a in zip(questions, answers):
  print(q, a)
```

## 比较与排序

### 多元素排序

默认递增排序，如果第一个元素相等，比较第二个，以此类推

```python
data = [
    [1, 4],
    [1, 2],
    [5, 6],
    [4, 7]
]

# 使用 sorted() 和自定义比较函数进行排序
# 默认排序是按升序排序，如果两个列表的第一个元素相同，会继续按第二个元素排序
sorted_data = sorted(data)

# 输出排序后的结果
for elem in sorted_data:
    print(f"[{elem[0]}, {elem[1]}]")
```

### lambda排序

```python
# 按字符串结尾字符倒排
words = ["banana", "pie", "Washington", "book"]
sorted_words = sorted(words, key=lambda x: x[-1], reverse=True)
print(sorted_words)  # 输出: ['Washington', 'book', 'pie', 'banana']
```

### 自定义排序

```python
class Employee:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def __lt__(self, other):
        return self.age < other.age

    def __repr__(self):
        return f'{self.name} ({self.age})'

employees = [Employee("Alice", 30), Employee("Bob", 25), Employee("Charlie", 35)]
sorted_employees = sorted(employees)
print(sorted_employees)  # 输出: [Bob (25), Alice (30), Charlie (35)]
```

### 比较函数(不推荐)

```python
from functools import cmp_to_key

def compare(x, y):
    # 返回负数表示 x < y
    # 返回零表示 x == y
    # 返回正数表示 x > y
    if x[1] < y[1]:
        return -1
    elif x[1] > y[1]:
        return 1
    else:
        return 0

data = [("John", 30), ("Jane", 25), ("Alice", 35), ("Bob", 25)]
sorted_data = sorted(data, key=cmp_to_key(compare))
print(sorted_data)  # 输出: [('Jane', 25), ('Bob', 25), ('John', 30), ('Alice', 35)]
```

## 生成式

生成式(List Comprehensions)提供一种简洁的方式创建列表

```python
# [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
# 创建列表
squares = []
for x in range(10):
  squares.append(x**2)

# 生成式
squares = [x**2 for x in range(10)]
```

### 条件语句

```python
# [(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]
[(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]
```

### 使用函数

```python
# ['3.1', '3.14', '3.142', '3.1416', '3.14159']
from math import pi
[str(round(pi, i)) for i in range(1, 6)]
```

### 生成式嵌套

```python
matrix = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [9, 10, 11, 12],
]

# 行列
matrix = [[row[i] for i in range(len(row))] for row in matrix]

# 列行
transposed = [[row[i] for row in matrix] for i in range(4)]
transposed = list(zip(*matrix))
```

## 生成器

生成器与生成式语法相似，只是生成器是懒加载模式，不会立即生成整个列表

```python
import sys
# 元素已经就绪，耗费较多的内存
l = [i for i in range(2 ** 24)] 
print(sys.getsizeof(l)) 
# 146916504 // 8 = 2 ** 24 

# 创建生成器对象, 不占用额外空间，但是需要数据的时候需要内部运算
l = (i for i in range(2 ** 24)) 
print(sys.getsizeof(l)) 
# 128 
```

除了上面的生成器语法，还有一种就是通过**yield**关键字

```python
def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
        yield a

if __name__ == '__main__':
    for val in fib(20):
        print(val)
```

## 参考

Python常用数据结构: [https://docs.python.org/3/tutorial/datastructures.html](https://docs.python.org/3/tutorial/datastructures.html)

-- End --