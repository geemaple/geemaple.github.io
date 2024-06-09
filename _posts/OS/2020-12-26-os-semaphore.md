---
layout: post
title: "信号量"
categories: OS
tags: OS
excerpt: "万能的信号量"
---

* content
{:toc}

> 信号量是编写并发程序的强大而灵活的原语，有程序员会因为简单实用，只用信号量, 不用锁和条件变量

## 信号量

信号量是一个整数值对象。

```cpp
int sem_wait(sem_t *s) 
{
    // 将信号量减一，如果是负数，就将线程挂起， 
    // 负数的值就是等待唤醒的数量，虽然这个值通常不会暴露给使用者
}

int sem_post(sem_t *s)
{
    // 将信号量加一，如果有1个或多个等待，唤醒一个
}
```

### 互斥锁

```cpp
void semaphoreLock()
{
    /*
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&lock);
    // 临界区
    pthread_mutex_unlock(&lock);
    */

    static sem_t semaphore;
    sem_init(&semaphore, 0, 1);
    
    sem_wait(&semaphore);
    // 临界区
    sem_post(&semaphore);
}
```

### join实现

遗憾的是Mac OS X废弃了**sem_init**, 取而代之的是**sem_open**和**sem_unlink**

```cpp
#include <pthread/pthread.h>
#include <semaphore.h>

static sem_t *semaphore;

static void *childThread(void *args)
{
    printf("child start\n");
    sem_post(semaphore);
    printf("child end\n");
    
    return NULL;
}

static int testEntry()
{
    sem_unlink("semaphore");
    semaphore = sem_open("semaphore", O_CREAT | O_EXCL, S_IRWXU, 0);
    printf("parent start\n");
    pthread_t p;
    pthread_create(&p, NULL, childThread, NULL);
    sem_wait(semaphore);
    printf("parent end\n");
    
    return 0;
}
```

## 生产者消费者

```cpp
#include <pthread/pthread.h>
#include <semaphore.h>

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

--END--
