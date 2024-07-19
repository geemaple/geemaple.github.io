---
layout: post
title: "操作系统02 - 锁和条件"
categories: OS
tags: C++
excerpt: "原理篇"
---

* content
{:toc}
 
## 内核多线程

锁应该：

1. 提供基本的互斥功能
2. 保证抢夺的公平性
3. 良好的性能

### 单核CPU 

单核CPU可以使用停止中断操作(限制能够出触发context switch的系统调用)

```cpp
Lock::acquire() { disableInterrupts(); }    
Lock::release() { enableInterrupts(); }
```

```cpp
class Lock {
   private:
     int value = FREE;
     Queue waiting;
   public:
     void acquire();
     void release();
 }
 
 Lock::acquire() {
     TCB *chosenTCB;
 
     disableInterrupts();
     if (value == BUSY) {
         waiting.add(runningThread);
         runningThread->state = WAITING;
         chosenTCB = readyList.remove();
         thread_switch(runningThread,
                       chosenTCB);
         runningThread->state = RUNNING;
     } else {
         value = BUSY;
     }
     enableInterrupts();
 }
 
 Lock::release() {
 // next thread to hold lock
     TCB *next;
 
     disableInterrupts();
     if (waiting.notEmpty()) {
     // move one TCB from waiting
     // to ready
         next = waiting.remove();
         next->state = READY;
         readyList.add(next);
     } else {
         value = FREE;
     }
     enableInterrupts();
 }
```

这个方案，是早期单CPU提出的, 缺点比较多:

1. 无法防止恶意程序，直接lock，然后永不unlock，系统会不响应
2. 不支持多处理器，程序可能通过其他CPU进入临界区
3. 中断可能导致系统无法获得一些事件，例如IO读取完毕

基于上述原因，只有有限的条件会采取屏蔽中断的方式，操作系统内部是可以的，不存在信任问题

### 多核CPU 

大多数CPU架构提供多核之间原子的`read-modify-write`指令(可以在User Level执行), 每个内核有自己的cache。 多核架构采用内存一致性机制:

内核缓存拥有状态，`exclusive`或者`read-only`. 如果其他内核有数据拷贝，那么原始数据必须是`read-only`的。
对于`exclusive`缓存，内核需要去获取实时最新的的值

`test-and-set`指令使用exclusive状态缓存(内存的一个拷贝)，同时清除所有其他内核拷贝

#### 自旋锁

`SpinLock`在while循环中，如果锁长时间不释放，这种锁效率是低下的

```cpp
class SpinLock {
private:
    int value = 0; // 0 = FREE; 1 = BUSY
    
public:
    void acquire() {
        while (test_and_set(&value)) // while BUSY
            ; // spin
    }
    
    void release() {
        value = 0;
        memory_barrier();
    }
}

class SpinLock {
private:
    int value = 0; // 0 = FREE; 1 = BUSY

public:
    // (Free) Can access this memory location from user space!
    int mylock = 0; // Interface: acquire(&mylock);
    //                        release(&mylock);

    void acquire(int *thelock) {
        do {
            while (*thelock); // Wait until might be free (quick check/test!) 减少共享内存总线和缓存一致性子系统的负担
        } while (test&set(thelock)); // Atomic grab of lock (exit if succeeded)
    }

    void release(int *thelock) {
        *thelock = 0; // Atomic release of lock
    }
};
```

当中断处理函数访问到临界区变量时，应该使用自旋锁。

`interrupt handlers`并不是线程，所以它必须执行完毕，系统才能够投递下一个中断事件。而且这个锁如果已经被一个线程持有，那么这个线程必须停止中断，确保执行完毕。否则，锁不释放，`interrupt handlers`会一直等待这个锁。

为了避免这个问题，操作系统通常让`interrupt handlers`唤醒一个线程来处理事件。唤醒一个线程需要互斥的访问`ready`队列, 就是在无中断条件下使用的内旋锁保护

#### 队列锁

一种适合各种等待时长的锁. 代码虽然不能够完全消除`SpinLock`的循环等待，但是可以试图减少它。

在`Lock`代码中，为了减少竞争，代码使用`SpinLock`来保护锁的内部状态，如果是Free状态，设置value，释放`SpinLock`。如果是busy状态，那么就要加入Lock的等待队列，使用`Scheduler`停掉当先线程，切换到另一个线程

在`Scheduler`代码中，`ready`队列需要一个`SpinLock`, 如果这个`SpinLock`是busy的状态，那么切换到另一个内核线程也没有用处，以为它也要访问同一个`ready`队列。

为了停止一个线程，需要停止中断，以确保持有`spinlock`后不会被抢占。而且`spinlock`是由新唤醒的线程释放的。如果不这样，可能另一个内核又把刚刚`wait`的线程，重新放回`ready`队列

> 如果Lock先release自旋锁，再调用suspend, release会切换到另一个线程，suspend始终停止当前线程。刚切换的另一个线程，又回变成等待状态，永远唤醒不起来了

```cpp
class Lock {
private:
    int value = FREE;
    SpinLock spinLock;
    Queue waiting;
public:
    void acquire();
    void release();
}

Lock::acquire() {
    spinLock.acquire();
    if (value != FREE) {
        waiting.add(runningThread);
        scheduler.suspend(&spinLock);
        // scheduler releases spinLock
    } else {
        value = BUSY;
        spinLock.release();
    }
}

void Lock::release() {
    TCB *next;
    
    spinLock.acquire();
    if (waiting.notEmpty()) {
        next = waiting.remove();
        scheduler.makeReady(next);
    } else {
        value = FREE;
    }
    spinLock.release();
}

class Scheduler {
private:
    Queue readyList;
    SpinLock schedulerSpinLock;
public:
    void suspend(SpinLock *lock);
    void makeReady(Thread *thread);
}

void Scheduler::suspend(SpinLock *lock) {
    TCB *chosenTCB;
    
    disableInterrupts();
    schedulerSpinLock.acquire();
    lock->release();
    runningThread->state = WAITING;
    chosenTCB = readyList.getNextThread();
    thread_switch(runningThread,
                  chosenTCB);

    // 另一个线程
    runningThread->state = RUNNING;
    schedulerSpinLock.release();
    enableInterrupts();
}

void Scheduler::makeReady(TCB *thread) {
    disableInterrupts();
    schedulerSpinLock.acquire();
    readyList.add(thread);
    thread->state = READY;
    schedulerSpinLock.release();
    enableInterrupts();
}

```

借助Linux的futex函数，futex是个私有内核API

```cpp
typedef enum { UNLOCKED,LOCKED,CONTESTED } Lock;
Lock mylock = UNLOCKED; // Interface: acquire(&mylock);
                        //            release(&mylock);

acquire(Lock *thelock) {
    // If unlocked, grab lock!
    if (compare&swap(thelock,UNLOCKED,LOCKED))
        return;

    // Keep trying to grab lock, sleep in futex
    while (swap(mylock,CONTESTED) != UNLOCKED)
        // Sleep unless someone releases hear!
        futex(thelock, FUTEX_WAIT, CONTESTED);
}

release(Lock *thelock) {
    // If someone sleeping,
    if (swap(thelock,UNLOCKED) == CONTESTED)
        futex(thelock,FUTEX_WAKE,1);
}
```

### 条件

由于`Condition`是在`Lock`的条件下使用的，所以调用函数已经具有排他性。需要借助`scheduler`的`SpinLock`，再释放`Lock`, 释放之后其他线程获得`Lock`可能`signal`。但在`scheduler`的`SpinLock`的保护下，之前的线程确保放入等待队列中，才能后续释放`signal`

```cpp
class CV {
private:
    Queue waiting;
public:
    void wait(Lock *lock);
    void signal();
    void broadcast();
}

// Monitor lock is held by current thread.
void CV::wait(Lock *lock) {
    assert(lock.isHeld());
    waiting.add(myTCB);
    // Switch to new thread and release lock.
    scheduler.suspend(&lock);
    lock->acquire();
}

// Monitor lock is held by current thread.
void CV::signal() {
    if (waiting.notEmpty()) {
        thread = waiting.remove();
        scheduler.makeReady(thread);
    }
}

void CV::broadcast() {
    while (waiting.notEmpty()) {
        thread = waiting.remove();
        scheduler.makeReady(thread);
    }
}

```

## 用户多线程

使用内核多线程，程序每次使用多线程API，都要借助`System Call`。

更复杂的线程实现，分为快速和慢速分支，Linux内核采用这种

例如，每个锁有两个数据结构，用户空间保存类似计数的简单标记， 内核空间保存`SpinLock`和`Queue`.

* 快速: 一个空闲的锁, 或者释放的的锁等待队列为空，只需要在用户空间操作就可以了，并不需要内核参与

* 慢速：借助内核完成

再有一种，就是完全用户级别的多线程，这样的库需要实现上述的基本多线程功能，唯一的区别是，无法停止中断。但可以借助停止系统的`upcalls`，用户空间`scheduler`使用这些`upcalls`用来实现抢占调用或者其他功能。

早期的Java虚拟机，就是完全用户级别的多线程，这种线程有个缺点如果整个程序在`wait`状态中，那么对应的调度也相应的停止了，还有就是多核看不见这种多线程，无法有效利用现代多核架构

## Linux 内核

x86架构支持更多的`read-modify-write`指令：原子的`++`， `--`， `swap两个值`。 Linux还会对常用路径进行进一步优化，看代码还需要懂一些汇编

```sh
# 官网：https://www.kernel.org/

git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
```

Linux 内核中的锁机制实现非常复杂，涉及多个文件和子系统。不同类型的锁有不同的实现方式，包括自旋锁、自旋锁带锁计数（spinlock with lock count）、读写锁（rwlock）、互斥锁（mutex）、信号量（semaphore）等。下面是一些主要的实现位置：

### 自旋锁（Spinlock）

自旋锁的实现主要在以下文件中：

- `include/linux/spinlock.h`
- `include/asm-generic/spinlock.h`
- `arch/x86/include/asm/spinlock.h`
- `kernel/locking/spinlock.c`

### 互斥锁（Mutex）

互斥锁的实现主要在以下文件中：

- `include/linux/mutex.h`
- `kernel/locking/mutex.c`

### 读写锁（RWLock）

读写锁的实现主要在以下文件中：

- `include/linux/rwlock.h`
- `include/asm-generic/rwlock.h`
- `arch/x86/include/asm/rwlock.h`
- `kernel/locking/lockdep.c`

### 信号量（Semaphore）

信号量的实现主要在以下文件中：

- `include/linux/semaphore.h`
- `kernel/locking/semaphore.c`

### 其他

- `kernel/locking/lockdep.c`：用于锁依赖关系的跟踪和调试。
- `include/linux/lockdep.h`：定义了锁依赖关系调试的接口。


--END--
