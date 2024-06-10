---
layout: post
title: "操作系统01 - 多线程编程"
categories: OS
tags: Operating System
excerpt: ""

---

* content
{:toc}

## 基本变量

### 锁

`Lock`: 锁是一个同步变量，当一个线程持有锁时，没有任何其他线程可以持有

`Pull`实现 = 使线程周期性的查看锁状态是否改变

1. 浪费CPU资源
2. 事件响应延迟

虽然`sleep`能够提高些效率，但是无法消除浪费的缺点， 同时可能增加更多的延迟

### 条件

`Condition`: 能够使线程高效的等待一个条件的改变， 必须和`Lock`一起使用

默认情况下，`Running`线程在CPU中，`Ready`线程在全局调度队列中; 而`Waiting`队列会有对应的`Lock`或者`Condition`， 这样当同步变量改变时, 调度更容易找到对应的等待线程

1. 条件变量没有内存，只有`waiting`状态的等待队列
2. `wait`方法原子的释放锁, 使线程进入`waiting`队列(如果非原子, 释放锁的时候会被打断，此时线程还未在`wait`状态，可能会错过信号，错过可能是一辈子)
3. 当被`sigal`唤醒时，只是从`waiting`队列移动到`ready`队列，具体调度取决于调度策略，其他线程可能抢先修，改使条件不在满足。 

有些系统可能允许假唤醒，加上第3条，条件应该始终在`while`循环中判断. 考虑到设计简单，多个条件地点只使用同一个`condition`来避免条件变量过多。其实`sigal`和`broadcast`只是指一种提示，临界区中的变量改变了，这个改变不一定是当前线程感兴趣的。

## 标准模版

为了避免多线程出错，程序应该：

1. 有一致的清晰的结构
2. 坚持使用`Lock`和`Condition`, 谨慎使用`Semaphore`
3. `Lock`应该总是在方法最开始`aquire`, 在程序返回前`release`，这样也可以避免`Lock`操作出现在不同的线程中(出现undefined行为)
4. 使用`Condition`时，一定要使用`Lock`
5. `Condition`的`wait`总应该在`while`中使用
6. 避免使用`thread_sleap`和`thread_yield`。除非你知道自己在做什么(可能场景分别是：远程服务器不相应，执行中的低优先级线程让位给其他高优先级线程)

```cpp
SharedObject::someMethodThatWaits() {
    lock.acquire();
    
    // Read and/or write shared state here.
    
    while (!testOnSharedState()) {
        cv.wait(&lock);
    }
    assert(testOnSharedState());
    
    // Read and/or write shared state here.
    
    lock.release();
}

SharedObject::someMethodThatSignals() {
    lock.acquire();
    
    // Read and/or write shared state here.
    
    // If state has changed in a way that
    // could allow another thread to make
    // progress, signal (or broadcast).
    
    cv.signal();
    
    lock.release();
}

```

## 反例


## 案例