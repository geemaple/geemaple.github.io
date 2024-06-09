---
layout: post
title: "条件变量"
categories: OS
tags: OS
excerpt: "条件变量"
---

* content
{:toc}

## 条件变量

记得**加锁**和**while**判断

```cpp
void cond_singal()
{
    pthread_mutex_lock(&lock);
    // 使自定义条件满足
    pthread_cond_signal(&condition);
    pthread_mutex_unlock(&lock);
}

void cond_wait()
{
    pthread_mutex_lock(&lock);
    while (/*判断自定义条件不满足*/) {
        pthread_cond_wait(&condition, &lock);
    }
    pthread_mutex_unlock(&lock);
}
```

## join实现

条件变量(condition variable)是一个显示队列，当条件不满足时，线程可以把自己加入到队列中，等待该条件

当另一个线程改变条件时，就可以唤醒一个或者多个等待的线程，让他们继续执行

```cpp
#include <pthread/pthread.h>

pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t condition = PTHREAD_COND_INITIALIZER;
int done = 0;

void custom_thread_exist()
{
    pthread_mutex_lock(&lock);
    done = 1;
    pthread_cond_signal(&condition);
    pthread_mutex_unlock(&lock);
}

void custom_thread_join()
{
    pthread_mutex_lock(&lock);
    while (done == 0) {
        pthread_cond_wait(&condition, &lock);
    }
    pthread_mutex_unlock(&lock);
}

void *childThread(void *args)
{
    printf("child start\n");
    custom_thread_exist();
    printf("child end\n");
    
    return NULL;
}

int testEntry()
{
    printf("parent start\n");
    pthread_t p;
    pthread_create(&p, NULL, childThread, NULL);
    custom_thread_join();
    printf("parent end\n");
    
    return 0;
}
```

**pthread_cond_wait**调用又一个参数，它是互斥量。它假定在wait调用的时候，这个互斥量是已上锁状态。

wait的职责是释放锁, 并让调用的线程休眠。当被唤醒时，它必须重新获取锁，在返回给调用者。

这样复杂的步骤也是为了避免在线程陷入休眠时，产生一些竞态条件。

### done变量的必要性

```cpp
void custom_thread_exist()
{
    pthread_mutex_lock(&lock);
    // done = 1;
    pthread_cond_signal(&condition);
    pthread_mutex_unlock(&lock);
}

void custom_thread_join()
{
    pthread_mutex_lock(&lock);
    // while (done == 0) {
        pthread_cond_wait(&condition, &lock);
    // }
    pthread_mutex_unlock(&lock);
}
```

custom_thread_exist 和 custom_thread_join重的done变量还是有必要的，如果子线程先结束，主线程就会不加判断的盲目等待

### 有必要在wait/signal前后加锁么

```cpp
void custom_thread_exist()
{
    done = 1;
    pthread_cond_signal(&condition);
}

void custom_thread_join()
{
    while (done == 0) {
        pthread_cond_wait(&condition, &lock);
    }
}
```

假设父进程在执行join的时候，检查done==0，然后试图睡眠，在调用wait之前，被中断。子线程改变done=1，发出信号。父进程就会永久睡眠了

## 生产者消费者

```cpp
#include <pthread/pthread.h>

#define kBufferSize 2
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t empty = PTHREAD_COND_INITIALIZER;
static pthread_cond_t full = PTHREAD_COND_INITIALIZER;

static int buffer[kBufferSize];
static int count = 0; // 大小为1
static int use = 0;
static int fill = 0;

static void put(int value)
{
    buffer[fill] = value;
    fill = (fill + 1) % kBufferSize;
    count++;
}

static int get()
{
    int tmp = buffer[use];
    use = (use + 1) % kBufferSize;
    count--;
    return tmp;
}


static void *producer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        pthread_mutex_lock(&lock);
        while (count == kBufferSize) {
            pthread_cond_wait(&empty, &lock);
        }
        
        put(i);
        printf("produce %d \n", i);
        pthread_cond_signal(&full);
        pthread_mutex_unlock(&lock);
    }
    
    return NULL;
}

static void *consumer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        pthread_mutex_lock(&lock);
        
        while (count == 0) {
            pthread_cond_wait(&full, &lock);
        }
        int tmp = get();
        printf("consume %d \n", tmp);
        pthread_cond_signal(&empty);
        pthread_mutex_unlock(&lock);
    }
    
    return NULL;
}

static int testEntry()
{    
    printf("parent start\n");
    pthread_t p1, p2, c1, c2;
    pthread_create(&p1, NULL, producer, (void *)10);
    pthread_create(&p2, NULL, producer, (void *)10);
    pthread_create(&c1, NULL, consumer, (void *)10);
    pthread_create(&c2, NULL, consumer, (void *)10);
    printf("parent end\n");
    
    return 0;
}
```

C1需要分配100的内存，C2需要分配10的内存，当一个P1释放free(50)内存时**pthread_cond_signal**，可能C1会被唤醒, C1发现空间不够，继续睡觉，当**pthread_cond_signal**不确定会唤醒哪一个线程，可以使用**pthread_cond_broadcast**唤醒所有线程，代价是唤起了所有线程，性能可能会有消耗

生产者消费者中，由于生产者之间没有区别，消费者之间也没有区别，使用**pthread_cond_signal**足够了

--END--
