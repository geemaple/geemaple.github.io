---
layout: post
title: "iOS/MacOS多线程编程GCD"
date: 2016-09-12
categories: ios
tags: GCD
excerpt: 主要了解GCD编程，以及如何用GCD完成一些经典多线程问题
---

* content
{:toc}

## 介绍

GCD和Block一起，使得iOS多线程编程变得简单优雅许多。如此优雅简单的多线程API真希望C和C++标准中也会有

> One of the technologies for starting tasks asynchronously is Grand Central Dispatch (GCD). This technology takes the thread management code you would normally write in your own applications and moves that code down to the system level. All you have to do is define the tasks you want to execute and add them to an appropriate dispatch queue. GCD takes care of creating the needed threads and of scheduling your tasks to run on those threads. Because the thread management is now part of the system, GCD provides a holistic approach to task management and execution, providing better efficiency than traditional threads.

本文相关[代码](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/GCDWarmUps.m)

## 远古时代

```objc
- (void) start {
    [self performSelectorInBackground:@selector(doWork) withObject:nil];
}

- (void) doWork {
    @autoreleasepool {
        printf("doing work");
        [self performSelectorOnMainThread:@selector(doneWork) withObject:nil waitUntilDone:NO];
    }
}

- (void) doneWork {
    printf("done work");
}
```

## GCD时代

```objc
- (void) start {
    dispatch_queue_t queue_for_background_threads = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue_for_background_threads, ^{
        printf("doing work");
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("done work");
        });
    });
}
```

## GCD API

### suspend和resume
`dispatch_resume`开始一个对列，苹果貌似喜欢用resume表示开始

`dispatch_suspend`暂停一个队列


### dispatch\_queue\_create

`dispatch_get_main_queue`是一个serial queue

`dispatch_get_global_queue`是一个concurrent queue

```objc
// FIFO 每次只执行一个, 不同的Serial Queue是按照并行执行的
dispatch_queue_t serial = dispatch_queue_create("com.mogoal.serial", DISPATCH_QUEUE_SERIAL);
// FIFO 每次可以执行多个
dispatch_queue_t concurrent = dispatch_queue_create("com.mogoal.concurrent", DISPATCH_QUEUE_CONCURRENT);
```

### dispatch\_set\_target\_queue

`dispatch_set_target_queu`该方法会把代码运行到目标queue上，使用时注意不要出现循环，如果出现循环，就懵逼了。原来的queue会继承target queue的优先级。你可以通过获取`dispatch_get_global_queue`来设置优先级。⚠️注意不要改变`dispatch_get_main_queue`和`dispatch_get_global_queue`的目标queue

如下面的代码，NSMutableArray是非线程安全的，多个线程同时执行addObject，会导致程序崩溃。我们把serial设置为concurrent的目标队列，本来concurrent是允许并行执行的，但是目标serial不允许，所以只能够顺序执行。

```objc
dispatch_queue_t serial = dispatch_queue_create("com.mogoal.serial", DISPATCH_QUEUE_SERIAL);
dispatch_queue_t concurrent = dispatch_queue_create("com.mogoal.concurrent", DISPATCH_QUEUE_CONCURRENT);

dispatch_set_target_queue(concurrent, serial);

NSMutableArray *result = [[NSMutableArray alloc] init];
for(int i = 0; i < count; i++){
    [result addObject:@(i)];
}

NSMutableArray *array = [[NSMutableArray alloc] init];

for(int i = 0; i < count + 1; i++){
    dispatch_async(concurrent, ^{[array addObject:@(i)];});
    if (i == count) {
        dispatch_async(concurrent, ^{
            XCTAssertEqual(array, result);
        });
    }
}
```

### dispatch\_group

`dispatch_group`很像一个守望者，守护着所有的任务都安全的执行完毕后，最后执行`dispatch_group_notify`指定的任务

```objc
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_group_async(group, queue, ^{NSLog(@"blk0");});
dispatch_group_async(group, queue, ^{NSLog(@"blk1");});
dispatch_group_async(group, queue, ^{NSLog(@"blk2");});
dispatch_group_notify(group, dispatch_get_main_queue(), ^{NSLog(@"done");});
```

或者你可以用`dispatch_group_wait`, 返回值==0，则所有任务一执行完毕，若!=0, 说明在指定时间之前，还有未完成任务

```objc
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_group_async(group, queue, ^{NSLog(@"blk0");});
dispatch_group_async(group, queue, ^{NSLog(@"blk1");});
dispatch_group_async(group, queue, ^{NSLog(@"blk2");});
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
NSLog(@"done");
```

### dispatch\_barrier\_async

对于并行执行，会产生race condiion. 通常我们会用锁来解决这样的数据不一致问题。 来看看`dispatch_barrier_async`怎么帮助我们解决这个问题。

`dispatch_barrier_async`提交一个block到并行queue中，并立即返回。提交的block到达队列前排处不会立即执行。而是等待当前queue中所有任务执行完毕，才去单独执行。之后的任务只有等待block执行完毕，才会继续并行下去。

`dispatch_barrier_async`很像酒馆装修，在装修任务来时，等待所有客人(任务)离场，然后关门装修更新，更新完后，才能够让其他客人(任务)进来。或者说`dispatch_barrier_async`临时将Concurrent Queue转换Serial Queue, 使任务依次进行

例如下面代码，即使写入需要2s，接下来的读取任务也会等待写入完毕，才再读取。

```objc
__block int another_num = 200;
dispatch_queue_t low_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);

dispatch_suspend(low_queue);

dispatch_async(high_queue, ^{ printf("\nRight case\n"); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_barrier_sync(low_queue, ^{
    sleep(2);
    printf("===low_write");
    another_num += 1;
    printf("===");
});
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });
dispatch_async(low_queue, ^{ printf("===%d", another_num); });

dispatch_resume(low_queue);

sleep(5);
```

### dispatch\_semaphore

前面已经说过，NSMutableArray是非线程安全的，如果再多线程下，程序会崩溃，这里我们通过信号量来控制`addObject`的顺序执行。

`dispatch_semaphore_wait`等待, 如果`semaphore > 0` ,并且消耗semaphore的值-1
`dispatch_semaphore_signal`释放，使得semaphore的值+1

```objc
int count = 100;
dispatch_queue_t concurrent = dispatch_queue_create("com.mogoal.concurrent", DISPATCH_QUEUE_CONCURRENT);
dispatch_semaphore_t flag = dispatch_semaphore_create(1);

NSMutableArray *array = [[NSMutableArray alloc] init];

for(int i = 0; i < count; i++){
    dispatch_semaphore_wait(flag, DISPATCH_TIME_FOREVER);
    dispatch_async(concurrent, ^{[array addObject:@(i)];});
    NSLog(@"%d", i);
    dispatch_semaphore_signal(flag);
}
```

和`dispatch_group_wait`类似，semaphore也有`dispatch_semaphore_wait`函数


### dispatch\_apply

和`dispatch_sync`函数类似，`dispatch_apply`也是一个同步函数。来执行一个N次, 可以用来遍历

```objc
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

//数数
dispatch_apply(10, queue, ^(size_t index) {
    NSLog(@"count %zu", index);
});
NSLog(@"done");

//遍历数组
int count = 100;

NSMutableArray *array = [[NSMutableArray alloc] init];
for(int i = 0; i < count; i++){
    [array addObject:@(i)];
}

dispatch_apply(count, queue, ^(size_t index) {
    NSLog(@"%@", array[index]);
});
```

### dispatch\_once

`dispatch_once`是执行任务，仅仅一次，好处是线程安全。实现单例模式时候使用较多

### dispatch\_after

`dispatch_after`会在一定的时间后，将任务添加到对应的队列。

`dispatch_time`是相对时间，`dispatch_walltime`是绝对时间。

main queue是通过runloop里执行的，如果runloop每秒调用60次，那么`dispatch_after`会有带盖1/60s的延迟。也就是这个API在时间上并不是绝对准确。

```objc
dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(001 * NSEC_PER_SEC));

dispatch_after(time, dispatch_get_main_queue(), ^{
    NSLog(@"dispatch_after");
});
```

### dispatch_sync

⚠️注意以下`dispatch_sync`，在一个队列中, sync执行到当前队列中会死锁

```objc
dispatch_queue_t queue = dispatch_queue_create("com.mogoal.MySerialDispatchQueue", NULL);

dispatch_async(queue, ^{
    dispatch_sync(queue, ^{
        printf("hello world\n");
    });
});
```

## //TBD dispatch io

## 更多
[https://casatwy.com/pthreadde-ge-chong-tong-bu-ji-zhi.html](https://casatwy.com/pthreadde-ge-chong-tong-bu-ji-zhi.html)
