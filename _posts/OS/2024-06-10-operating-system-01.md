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

`Condition`: 能够使线程高效的等待一个条件的改变。 必须和`Lock`一起使用，等待时释放锁，唤醒时从新持有锁

默认情况下，`Running`线程在CPU中，`Ready`线程在全局调度队列中; 而`Waiting`队列会有对应的`Lock`或者`Condition`变量， 这样当同步变量改变时, 调度更容易找到对应的等待线程

1. 条件变量没有内存，只有`waiting`状态的等待队列
2. `wait`方法原子的释放锁, 使线程进入`waiting`队列(如果非原子, 释放锁的时候会被打断，此时线程还未在`wait`状态，可能会错过信号，错过也可能是一辈子)
3. 当被`sigal`唤醒时，只是从`waiting`队列移动到`ready`队列，具体调度取决于调度策略，其他线程可能抢先修改，使条件不在满足。 

有些系统可能允许假唤醒，加上第3条，条件应该始终在`while`循环中判断. 考虑到设计简单，多个条件地点只使用同一个`condition`来避免条件变量过多。此时`sigal`和`broadcast`只是指一种提示，临界区中的变量改变了，这个改变不一定是当前线程感兴趣的。

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
    assert(testOnSharedState()); // 这个其实永远不会出错，这样写估计是为了防止有人手贱把while改成了if
    
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

## 反例LLCP

这个反例不止出现在单例上

```cpp
class Singleton {
public:
    static Singleton* instance();
    //... private:
    static Singleton* pInstance;
};
// from the implementation file
Singleton* Singleton::pInstance = NULL;
Singleton* Singleton::instance() {
    if (pInstance == nullptr) {
        pInstance = new Singleton;
    }
    return pInstance;
}
```
该代码在单线程下没有什么问题，除非在interupt handler中也调用了单例，根据模版如下

```cpp
Singleton* Singleton::instance() {
    lock.acquire();
    if (pInstance == NULL){
        pInstance = new Instance();
    }
    lock.release();
    return pInstance;
}
```

这种方案开销太多，理论上只需要在初始化的时候锁一次就可，历史上解决方案如下：

```cpp
// DCLP(Double-Checked Locking Pattern)
// BUG!  DON’T DO THIS!
Singleton* Singleton::instance() {
    if (pInstance == NULL) {
        lock.acquire();
        if (pInstance == NULL){
            pInstance = new Instance();
            // 1. 分配内存 2. 初始化 3. pInstance指向新实例
        }
        lock.release();
    }
    return pInstance;
}
```

现代CPU有多个执行单元(多个ALU也比较常见)，编译器会仔细分析和重新排序代码，使得代码可以快速执行(尽可能一次执行更多)。如果步骤2会有异常，pInstance要保持null，通常编译器不会这样翻译。一种情况是，如果编译器通过流程分析发现2没有异常，步骤2，3可能会颠倒。

其他重排序，编译连接可能会使最终代码，更充分利用CPU的Pipeline

即使没有recorder，多核CPU或内存系统可能以不同顺序写入内存，这样另一个CPU从内存上看到的结果就和上面一样了

例如，上面代码，编译器可能认为在锁的保护下，里面的内容重排序是安全的，只要保证最终的结果即可

```cpp
Singleton* Singleton::instance() { 
    if (pInstance == NULL) {
        lock.acquire();
        if (pInstance == NULL) {
            pInstance =                          // 3
            operator new(sizeof(Singleton));     // 1
            new (pInstance) Singleton;           // 2
        }
        lock.release();
    }
    return pInstance;
}
```

此时，如果在1-3处中断，另一个线程会拿到未初始化的实例。

> 编译链接器有自己的语言标准，而且是单线程条线下的环境标准。编译链接可能会消除不必要的临时变量，重新排序一些指令来达到优化的目标。C和C++都没有线程。所以不奇怪编译后的代码有时会破坏多线程的逻辑

多线程代码借助系统库(比如pthreads), 这些库对生成的代码施加了限制，确保编译器生成的代码遵循所需的线程语义。这就是为什么线程库的部分功能是用汇编语言编写的，或者发出的系统调用。

> 现代C++（从C++11开始）引入了一个标准化的线程库（thread, mutex, condition_variable等），提供类似于pthread的功能。然而，基本原理仍然是相同的：使用特定于系统的线程库来表达多线程程序所需的执行顺序约束

若没有系统库的支持，上面的代码只使用语言级别的技巧，论文指出临时变量，分模块，volatile，假装初始化有异常等，都是和编译器做无用了拉锯战，无法确保赢得战争

> 论文指出使用`memory barrier`可以解决，不过这个平台相关(可能是汇编语言)，不利于移植，可读性也极差。而且我压根不知道`memory barrier`是啥玩意

## 案例

今天读到这里，就停止了

### 读写锁

### 同步屏障

### FIFO阻塞有界队列

* [https://www.aristeia.com/Papers/DDJ_Jul_Aug_2004_revised.pdf](https://www.aristeia.com/Papers/DDJ_Jul_Aug_2004_revised.pdf)
* [http://www.cs.umd.edu/~pugh/java/memoryModel/DoubleCheckedLocking.html](http://www.cs.umd.edu/~pugh/java/memoryModel/DoubleCheckedLocking.html)