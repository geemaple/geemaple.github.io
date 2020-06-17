---
layout: post
title: "操作系统OS, 进程管理"
date: 2017-10-12
categories: core
tags: os process thread
excerpt: 操作系统II第1部分：进程和线程
---

## C程序内存布局

  区域  | 解释 |
:----: | ---- |
Text | 代码指令区，通常只读，内存地址中通常比Heap和Stack低，以防止堆栈溢出，造成误写操作|
Data | 初始化数据区, 可读写，包含全局和静态变量, 可进一步分为只读区域，和读写区域
bss | “Block started by symbol”, 未出初始化据区
Stack | 栈区，通常在高位内存地址, 向低位增长, LIFO, 自动变量和stack frame(函数调用的register，临时变量，返回地址等)存储地方
Heap | 堆区，相邻栈区，通常在低位内存地址，想高位增长, malloc, realloc, free

![OS_c_program_memory_layout_1]({{site.static}}/images/OS_c_program_memory_layout_1.png)

当然以上只是逻辑上的连续区域，但在实际内存中，每一块可能映射到不同的内存地址上。当内存不不足时，OS可以将部分内容swap到硬盘HD上。

![OS_c_program_memory_layout_2]({{site.static}}/images/OS_c_program_memory_layout_2.png)

你可以通过```size```命令查看Object文件Section大小

![OS_size_command]({{site.static}}/images/OS_size_command.png)

## Process vs. Thread

> “a program in execution. A process is the unit of work in a modern time-sharing system”

进程(Process/Job): 运行中的程序，进程是现代分时系统的工作单元(例如运行中的QQ，浏览器，Xcode，邮件等）。

> “A thread is a basic unit of CPU utilization; it comprises a thread ID, a program counter, a register set, and a stack. It shares with other threads belonging to the same process its code section, data section, and other operating-system resources, such as open files and signals”

线程(Thread): CPU使用的基本单元。包含线程ID，PC，计数器，线程栈。同一个进程中的多线程共享程序执行文件的代码(code section，data section), 系统的其他资源打开文件，sigal也会共享。

> “In Solaris, for example, creating a process is about thirty times slower than is creating a thread, and context switching is about five times slower.”

线程的开销要比进程少，在Solaris，系统中创建线程要比进程快30x，上下文切换要快5x

![OS_single_thread_vs_multithread]({{site.static}}/images/OS_single_thread_vs_multithread.png)

PS：每一个CPU内核，一次只能执行一个进程中的一个线程

## 任务控制(PCB)

PCB主要用于进程切换时保存和恢复所需要的信息，具体设计取决于操作系统，但是，基本上会包含一下基本信息：

PCB|解释|
---|---|
process ID | 进程ID
Pointer | 父进程ID
process state| 进程状态，new，ready, waiting, running, terminated
program counter| 指令指针
CPU registers| 记录进程恢复运行需要的信息
CPU scheduling info| 包括进程优先级，
Memory management info | 内存管理信息，分表或者内存限制等。
Accounting info| 进程资源使用信息，例如CPU使用量
I/O status| 进程使用的I/O设备，例如打开的文件等。

PS：更多见[linux code](https://github.com/torvalds/linux/blob/368f89984bb971b9f8b69eeb85ab19a89f985809/include/linux/sched.h#L518-L1115)

## 算法与调度

目前，操作系统主要使用抢占式调用。因为抢占信号可能随时会发生，而且操作系统不可能拒绝所有中断信号。不然键盘输入可能会被忽略，或者一些数据可能会被覆盖。

尽管CPU调度应该越快越好，但是调度者必须要停止一个进程，保存进程状态。加载执行另一个进程。这中间的时间叫做派遣延迟(dispatch latency)

CPU调度标准主要考虑，CPU利用率，吞吐量(单位时间完成的任务数)，进程结束总耗时，进程等待时间，进程第一次相应时间。(CPU Utilization, Throughput, Turnaround time, Waiting time, Response Time)

调度算法|解释|举例|
------|----|---|
FCFS(Fisrt-Come, First-Served)| 先到先得模式, **非抢占式**，采用FIFO队列就可实现, 优势是容易实现和理解。缺点就是平觉等待市场通常比较长而且波动较大| 例如[24][1][1][1]第一个任务执行24ms之后，后面的才执行。如果最小的任务在前面，那么就可以达到优化，也就是下面的算法。
SJF(Shortest-Job-First) | 接下来最短时间优先模式，**抢占与否均可**，如果是非抢占式，就变成了最短剩余时间优先，优势进程拥有较小的平均等待时间，劣势是如何评估进程下次CPU利用时间，不过可以通过已有的进程执行情况进行预测。| SJF是下面优先级模式的一个特例 |
Priority| 优先级优先模式，**抢占与否均可**，缺点是可能会导致低优先级进程永远无法被执行，可以通过进程提交时间，渐渐递增其优先级 | 传言称，1973年，MIT关闭IBM7094时，发现一个1967年提交的低优先级进程还没有被执行 |
RR(Round-Robin)| 轮询模式，**抢占式**， 转为分时系统设计，与FCFS类似，但是每个任务加上了时间配额, 通常10-100ms。缺点时平均等待时间通常比较长| 该算法的性能严重依赖时间配额大小，时间过大，就变成了FCFS，太小会引入过多的进程切换。通常，%80的CPU时间应该少于时间配额|
Multilevel Queue| 多任务队列模式，每个队列拥有各自的调度模式。多个队列之间可以用高优先级抢占模式(高优先级队列永远最先执行)或者时间额度分配模式(高优先级分配较多的时间配额)| 前台应用%80时间配额，采用RR模式和后台应用%20时间配额，采用FCFS模式
Multilevel Feedback Queue| 多任务队列+反馈模式，和上一个不同，允许进程改变所在队列

## 未完待续


## 更多

[https://www.youtube.com/watch?v=9-KUm9YpPm0&list=PLAF8648427BB68706](https://www.youtube.com/watch?v=9-KUm9YpPm0&list=PLAF8648427BB68706)

[https://www.youtube.com/watch?v=9GDX-IyZ_C8](https://www.youtube.com/watch?v=9GDX-IyZ_C8)

[https://en.wikipedia.org/wiki/Data_segment](https://en.wikipedia.org/wiki/Data_segment)

[http://en.wikipedia.org/wiki/Code_segment](http://en.wikipedia.org/wiki/Code_segment)

[http://en.wikipedia.org/wiki/.bss](http://en.wikipedia.org/wiki/.bss)

[http://www.nongnu.org/avr-libc/user-manual/mem_sections.html](http://www.nongnu.org/avr-libc/user-manual/mem_sections.html)

[http://www.geeksforgeeks.org/memory-layout-of-c-program/](http://www.geeksforgeeks.org/memory-layout-of-c-program/)
