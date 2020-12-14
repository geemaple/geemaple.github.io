---
layout: post
index: 4
title: "C++算法排序中常用cmp的三种实现"
categories: Algorithm
tags: 亢龙有悔 C++
excerpt: “行走江湖必备，C++三种常用的cmp方式实现”
---

* content
{:toc}

当用C++时，我们经常需要对数据进行排序，比如Sort默认是递增(Ascending)序列，但是我们可能恰好需要一个递减(Desceding)序列。

再比如一些STL容器，例如map，set，priority_queue也是要求内部数据可排序

还有就是，我们可能会自定义一个Struct或者Class，STL根本不知道该怎么排序。

这时候，就需要用到比较函数cmp, 本文主要介绍3中常用的方法

# 如何定义顺序

假设需要比较a,b两个同类型数据，我们应该实现一个函数f(x,y)->bool, 返回一个Bool结果，来决定x是否应该在y前面

除了priority_queue以外, 比较函数要有一下几个特性([严格若顺序](https://en.wikipedia.org/wiki/Weak_ordering))：

1. f(x, x) = false
2. f(x, y) = !f(y, x)
3. 如果 (x < y) and (y < z), 那么 (x < z)
4. 若果 (x 和 y 无法比较) 并且 y 和 z 无法比较, 那么(x 和 z也无法比较)

不过不用担心，如果你定义(小于<) 或者 (大于>)就完全满足

# 重载操作符<

```
struct Triple{
    int height, x, y;
    Triple(int height, int x, int y){
        this->height = height;
        this->x = x;
        this->y = y;
    }
    
    bool operator < (Triple other) const
    {
        return this->height > other.height;
    }
};
```
注意需要用到const，也就是你不能够在比较的同时修改当前this的成员变量

```
struct Triple{
    int height, x, y;
    Triple(int height, int x, int y){
        this->height = height;
        this->x = x;
        this->y = y;
    }
    
    friend bool operator < (Triple a, Triple b)
    {
        return a.height > b.height;
    }
};
```

这个比第一种更清晰一些，friend函数就像一个static函数，这时就无法访问this成员变量, 使用如下：


```
vector<Triple> v;
sort(v.begin(), v.end());

priority_queue<Triple> pq;
set<Triple> s;

```

# 自定义比较函数

有些内部数据类型，我们无法修改其Struct或者Class定义，可以通过比较函数来进行

```
struct Triple{
    int height, x, y;
    Triple(int height, int x, int y){
        this->height = height;
        this->x = x;
        this->y = y;
    }
};

bool cmp(Triple a, Triple b)
{
    return  a.height > b.height;
}
```

使用如下：

```
Triple test[4] = {Triple(2,5,6), Triple(9,3,6), Triple(0,5,6), Triple(12,5,6)};
sort(begin(test), end(test), cmp);
```

# 定义操作符()

```
struct cmp
{
    bool operator()(const Triple& a,const Triple& b)
    {
        return  a.height > b.height;
    }
};

```

C++标准库STL中也有默认的less<T>和greater<T>, 具体使用如下：

```
set<Triple, cmp> s;
priority_queue<Triple, vector<Triple>, cmp> pq;
```

functor也可以在后面加上(),就变成了第二种使用方法，例如

```
sort(data.begin(), data.end(), greater<int>());

Triple test[4] = {Triple(2,5,6), Triple(2,3,6), Triple(0,5,6), Triple(12,5,6)};

sort(begin(test), end(test), cmp());

```


# 结尾彩蛋
##彩蛋1
如果你定义的class非常大，那你最好通过Const和&来进行，好处是通过引用而不是这个对象,例如

```
bool cmp(const Triple& a,const Triple& b)
{
    return  a.height > b.height;
}
```

##彩蛋2
如果数据中有重复元素，如果x == y, 那么cmp(x, y)，cmp(y, x)都返回false，如果你用sort去排序，那么x，y相对顺序是不确定的。此时，你可以使用```stable_sort```, 相同的x, y的顺序会和它们初始时候顺序相同


--END--
