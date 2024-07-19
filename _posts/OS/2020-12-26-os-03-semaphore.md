---
layout: post
title: "操作系统03 - 信号量"
categories: OS
tags: C++
excerpt: "潘多拉的盒子"
---

* content
{:toc}

## 信号量

1. 信号量包含一个非负值。
2. 可以初始化成任意数字
3. `wait = Semaphore::P()`等待其值大于1，然后原子的减一
4. `sigal = Semaphore::V()`原子加一，如果有1个或多个等待，唤醒一个


```cpp
int sem_wait(sem_t *s) {
    // 等待其值大于1， 将信号量减一
}

int sem_post(sem_t *s) {
    // 将信号量加一，如果有1个或多个等待，唤醒一个
}
```

## 使用

### 互斥锁

```cpp
void semaphoreLock()
{
    static sem_t semaphore;
    sem_init(&semaphore, 0, 1);
    
    sem_wait(&semaphore);
    // 临界区
    sem_post(&semaphore);
}
```

### Join

是Mac OS X废弃了**sem_init**, 取而代之的是**sem_open**和**sem_unlink**

```cpp
#include <pthread/pthread.h>
#include <semaphore.h>

static sem_t *semaphore;

static void *childThread(void *args) {
    printf("child start\n");
    sem_post(semaphore);
    printf("child end\n");
    
    return NULL;
}

static int testEntry() { 
    sem_unlink("semaphore"); // 如果你能确保程序每次运行时信号量都是全新的且不会有命名冲突，或者你不介意使用旧的信号量，那么 sem_unlink 可以省略。
    semaphore = sem_open("semaphore", O_CREAT | O_EXCL, S_IRWXU, 0);
    printf("parent start\n");
    pthread_t p;
    pthread_create(&p, NULL, childThread, NULL);
    sem_wait(semaphore);
    printf("parent end\n");
    
    return 0;
}
```

## 同步原语对比

1. `Condition`会自动原子的释放和持有锁，所以可以安全的访问共享数据。`Semaphore`没有自动释放获取锁的特性，而且通常需要在使用`wait`前释放掉锁。否者，除非线程恢复执行，锁一直是持有状态
2. `Condition`是无内存状态，若没有等待线程`signal`没有任何作用。`Semaphore`有值，`signal`会+1，会导致下一个`wait`直接执行
3. `Semaphore`的`sigal`会释放资源(+1), `wait`会消耗一个资源(-1), 始终伴随着状态改变，要仔细对应到合适的业务场景
4. `Lock`语意明确，检测`lock`和`unlock`是否成对出现更容易. `Semaphore`需要对应整个使用流程
5. 一个无状态的`Condition`和`Lock`，可以适应任意业务逻辑的判断。`Semaphore`只适用简单的递增递减逻辑

`semaphore`的灵活多变，使得有些人不推荐。`monitor`是`lock`和若干`Condition`

## 适用场景

### IO处理

IO处理使用共享内存，里面的数据结构会被`kernel`和`driver`并行的读写，锁无法使用在这种场景，因此`driver`使用特殊设计的原子内存操作

如果`driver`需要被系统关注(可能是网络包已经到达/磁盘操作已经完成)，硬件会更新共享内存，然后通过`interrupt`机制告知系统。`interrupt handler`通常比价简单，它会唤醒对应等待的线程返回。

这种场景使用无锁`Condition`会有问题，假设，操作系统线程检查共享内存，发现无事可做打算`wait`, 此时中断发生，触发`interupt`, 在`interrupt handler`调用`sigal`,因为此时`wait`还未生效，`sigal`没有任何作用

此时，`semaphore`的`sigal`就完美的解决了这个问题

> `interrupt handler`不能使用锁，否者会阻塞，导致接下来事件无法获取

### 实现Condition

此方法由*Andrew Birrell*发明，主要用在Windows上实现`Condition`, 直到Windows官方支持

```cpp
// Put thread on queue of waiting
// threads.
void CV::wait(Lock *lock) {
    semaphore = new Semaphore(0);
    waitQueue.Append(semaphore);
    lock.release();
    semaphore.P();
    lock.acquire();
}

// Wake up one waiter if any.
void CV::signal() {
    if (!waitQueue.isEmpty()) {
        semaphore = queue.Remove();
        semaphore.V();
    }
}
```

--END--
