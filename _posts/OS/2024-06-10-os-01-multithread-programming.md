---
layout: post
title: "操作系统01 - 多线程编程"
categories: OS
tags: C++ pthreads
excerpt: ""

---

* content
{:toc}

## 基本变量

1. 临界区(critical section)，访问共享资源的一段代码
2. 竞态条件(race condition)，多个执行线程同时进入临界区，试图修改共享资源，导致不确定性
3. 不确定性(indeterminate)，指结果的不确定性。

为了避免不确定性问题，应该使用某种"锁"。这样可以保证只有一个线程进入临界区，从而避免发生竞态，产生确定性的结果

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
该代码在单线程下没有什么问题，除非在interupt handler中也调用了单例，根据模版，第一个版本多线程代码如下:

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

例如，上面代码，编译器可能认为在锁的保护下，里面的内容重排序是安全的，只要保证最终的结果即可(编译器没想到，会在临界区外，还有pInstance被访问)

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

此时，如果在1处中断，另一个线程会拿到未初始化的实例。

> 编译链接器有自己的语言标准，而且是单线程条线下的环境标准。编译链接可能会消除不必要的临时变量，重新排序一些指令来达到优化的目标。C和C++都没有线程。所以不奇怪编译后的代码有时会破坏多线程的逻辑

多线程代码借助系统库(比如pthreads), 这些库对生成的代码施加了限制，确保编译器生成的代码遵循所需的线程语义。这就是为什么线程库的部分功能是用汇编语言编写的，或者发出的系统调用。

> 现代C++（从C++11开始）引入了一个标准化的线程库（thread, mutex, condition_variable等），提供类似于pthread的功能。然而，基本原理仍然是相同的：使用特定于系统的线程库来表达多线程程序所需的执行顺序约束

若没有系统库的支持，上面的代码只使用语言级别的技巧，论文指出临时变量，分模块，volatile，假装初始化有异常等，都是和编译器做无用了拉锯战，无法确保赢得战争

> 论文指出使用`memory barrier`可以解决，不过这个平台相关(可能是汇编语言)，不利于移植，可读性也极差。内存屏障保证屏障之内的内存操作不会相互重排序，但屏障前和屏障后的操作内部依然可能发生重排序

## 案例

### 读写锁

常用于读取较多，写入较少的场景，比如数据库

* 优先读：在优先读的实现中，读者在没有活动的写者和等待的写者时可以获取锁。写者只有在没有活动的读者和写者时才能获取锁。
* 优先写：在优先写的实现中，读者只有在没有活动的写者时才能获取锁。写者在没有活动的读者和写者时可以获取锁。

代码示例读写有同等优先级

```cpp
#include <cassert>

class RWLock{
private:
    // Synchronization variables
    Lock lock;
    CV readGo;
    CV writeGo;
    
    // State variables
    int activeReaders;
    int activeWriters;
    int waitingReaders;
    int waitingWriters;
    
public:
    RWLock();
    ~RWLock() {};
    void startRead();
    void doneRead();
    void startWrite();
    void doneWrite();
    
private:
    bool readShouldWait();
    bool writeShouldWait();
};

// Wait until no active or waiting
// writes, then proceed.
void RWLock::startRead() {
    lock.acquire();
    waitingReaders++;
    while (readShouldWait()) {
        readGo.Wait(&lock);
    }
    waitingReaders--;
    activeReaders++;
    lock.release();
}

// Done reading. If no other active
// reads, a write may proceed.
void RWLock::doneRead() {
    lock.acquire();
    activeReaders--;
    if (activeReaders == 0 && waitingWriters > 0) {
        writeGo.signal();
    }
    lock.release();
}

// Read waits if any active or waiting
// write ("writers preferred").
bool RWLock::readShouldWait() {
    return (activeWriters > 0 || waitingWriters > 0);
}


// Wait until no active read or
// write then proceed.
void RWLock::startWrite() {
    lock.acquire();
    waitingWriters++;
    while (writeShouldWait()) {
        writeGo.Wait(&lock);
    }
    waitingWriters--;
    activeWriters++;
    lock.release();
}

// Done writing. A waiting write or
// read may proceed.
void RWLock::doneWrite() {
    lock.acquire();
    activeWriters--;
    assert(activeWriters == 0);
    if (waitingWriters > 0) {
        writeGo.signal();
    }
    else {
        readGo.broadcast();
    }
    lock.release();
}

// Write waits for active read or write.
bool RWLock::writeShouldWait() {
    return (activeWriters > 0 || activeReaders > 0);
}
```

使用:

```cpp
void read() {
    rwLock->startRead();
    // Read shared data
    rwLock->doneRead();
}

void write() {
    rwLock->startWrite();
    // Read and write shared data
    rwLock->doneWrite();
}
```

### 同步屏障

Synchronization Barriers: 在并行计算中，多个线程完成任务的各自部分，当所有子任务完成，就可以安全的执行并行计算的下一步，MapReduce是并行结算的一个例子

同步屏障：一种高效的方式来检查是否所有子任务都完成了, 同步屏障会被多个线程并行的调用`checkin`

内存屏障: 只被一个线程调用，用来保证屏障内的操作有确定的结果

虽然创建n个线程，然后main调用thread_join同样正确，但是问题是需要每次需要创建n个线程，重复切割任务。如果使用并行计算，每个线程可以多次对数据进行操作，最大效率利用各自的CPU缓存

可重复使用的`Barrier`代码

```cpp
// A re-usable synch barrier.
class Barrier{
private:
    // Synchronization variables
    Lock lock;
    CV allCheckedIn;
    CV allLeaving;
    
    // State variables
    int numEntered;
    int numLeaving;
    int numThreads;
    
public:
    Barrier(int n);
    ~Barrier();
    void checkin();
};

Barrier::Barrier(int n) {
    numEntered = 0;
    numLeaving = 0;
    numThreads = n;
}

// No one returns until all threads
// have called checkin.
void checkin() {
    lock.acquire();
    numEntered++;
    if (numEntered < numThreads) {
        while (numEntered < numThreads) {
            allCheckedIn.wait(&lock);
        }
    } else {
        // no threads in allLeaving.wait
        numLeaving = 0;
        allCheckedIn.broadcast();
    }
    numLeaving++;
    if (numLeaving < numThreads) {
        while (numLeaving < numThreads) {
            allLeaving.wait(&lock);
        }
    } else {
        // no threads in allCheckedIn.wait
        numEntered = 0;
        allLeaving.broadcast();
    }
    lock.release();
}
```

### 阻塞有界队列

常用于生产者消费者

```cpp
// Thread-safe blocking queue.

const int MAX = 10;

class BBQ{
    // Synchronization variables
    Lock lock;
    CV itemAdded;
    CV itemRemoved;
    
    // State variables
    int items[MAX];
    int front;
    int nextEmpty;
    
public:
    BBQ();
    ~BBQ() {};
    void insert(int item);
    int remove();
};

// Initialize the queue to empty,
// the lock to free, and the
// condition variables to empty.
BBQ::BBQ() {
    front = nextEmpty = 0;
}

// Wait until there is room and
// then insert an item.
void BBQ::insert(int item) {
    lock.acquire();
    while ((nextEmpty - front) == MAX) {
        itemRemoved.wait(&lock);
    }
    items[nextEmpty % MAX] = item;
    nextEmpty++;
    itemAdded.signal();
    lock.release();
}

// Wait until there is an item and
// then remove an item.
int BBQ::remove() {
    int item;
    
    lock.acquire();
    while (front == nextEmpty) {
        itemAdded.wait(&lock);
    }
    item = items[front % MAX];
    front++;
    itemRemoved.signal();
    lock.release();
    return item;
}
```

上面的，可能有些线程会饿死，假设每生产一个，都被其他线程抢走。通常无关紧要，只要队列有持续的生产消费，切不总是空或者满的状态即可

但如果确实需要，可以考虑更精细的唤醒，但注意，这已经偏离了基本的模版代码，需要更多的技能。可以使用FIFO，LIFO，或Priority等各种策略

```cpp
ConditionQueue insertQueue;
ConditionQueue removeQueue;
int numRemoveCalled = 0; // # of times remove has been called
int numInsertCalled = 0; // # of times insert has been called

int FIFOBBQ::remove() {
    int item;
    int myPosition;
    CV *myCV, *nextWaiter;
    
    lock.acquire();
    
    myPosition = numRemoveCalled++;
    mycv = new CV;  // Create a new condition variable to wait on.
    removeQueue.append(myCV);
    
    // Even if I am woken up, wait until it is my turn.
    while (front < myPosition || front == nextEmpty) {
        mycv->Wait(&lock);
    }
    
    delete myCV;    // The condition variable is no longer needed.
    item = items[front % size];
    front++;
    
    // Wake up the next thread waiting in insert, if any.
    nextWaiter = insertQueue.removeFromFront();
    if (nextWaiter != NULL)
        nextWaiter->Signal(&lock);
    lock.release();
    return item;
}
```

* [https://www.aristeia.com/Papers/DDJ_Jul_Aug_2004_revised.pdf](https://www.aristeia.com/Papers/DDJ_Jul_Aug_2004_revised.pdf)
* [http://www.cs.umd.edu/~pugh/java/memoryModel/DoubleCheckedLocking.html](http://www.cs.umd.edu/~pugh/java/memoryModel/DoubleCheckedLocking.html)