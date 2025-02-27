---
layout: post
title: "系统设计02 — 系统估算"
categories: System-Design
excerpt: "系统设计开篇，什么是系统设计，从哪些角度考虑"
---

* content
{:toc}

## 术语

Back-of-the-envelope estimation

20 世纪中期，美国的科学家、数学家和工程师们在讨论问题时，没有草稿纸，就在信封背面计算。因为正面有地址，邮编等信息，不适合做草稿纸。

类似的表达还有 “napkin math”（餐巾纸数学），也表示随手写的粗略估算。

**例子 1：估算 Google 需要多少台服务器**

假设：

- Google 处理 50 亿次搜索/天，每次搜索消耗 0.01 秒 CPU 时间。
- 每台服务器每天可提供 100 万秒 CPU 时间。

估算：

- 总计算需求 = 50 亿 × 0.01 秒 = 5 亿秒
- 每台服务器每天可提供 100 万秒，所以需要的服务器数 ≈ 500,000 台。

**例子 2：估算地球上有多少辆汽车**

假设：

- 全球 80 亿 人口，平均每 5 个人 共享一辆车。

估算：

- 估算全球汽车数 = 80 亿 ÷ 5 = 16 亿辆车。

## 数字

### 2的指数

| Power | Approximate Value | Full Name | Short Name |
|-------|-------------------|-----------|------------|
| 10    | 1 Thousand        | 1 Kilobyte| 1 KB       |
| 20    | 1 Million         | 1 Megabyte| 1 MB       |
| 30    | 1 Billion         | 1 Gigabyte| 1 GB       |
| 40    | 1 Trillion        | 1 Terabyte| 1 TB       |
| 50    | 1 Quadrillion     | 1 Petabyte| 1 PB       |

### [延迟](https://gist.github.com/hellerbarde/2843375)

```cpp
// 随机访问
L1 cache reference ......................... 0.5 ns   // L1缓存访问，最快的存储访问
L2 cache reference ........................... 7 ns   // L2缓存访问，比L1慢约14倍              ~x10
Main memory reference ...................... 100 ns   // 主内存访问，比L1慢200倍               ~x100
SSD random read ........................ 150,000 ns  = 150 µs  // SSD随机读取，比RAM慢1500倍   ~x1k
Disk seek ........................... 10,000,000 ns  =  10 ms  // 磁盘寻道时间，比RAM慢100000倍  ~x10k

// 读取
Read 1 MB sequentially from memory ..... 250,000 ns  = 250 µs  // 从内存顺序读取1MB数据
Read 1 MB sequentially from SSD* ..... 1,000,000 ns  =   1 ms  // 从SSD顺序读取1MB数据，比内存慢4倍   ~x10
Read 1 MB sequentially from disk .... 20,000,000 ns  =  20 ms  // 从磁盘顺序读取1MB数据，比内存慢80倍   ~x100

// 指令 
Branch mispredict ............................ 5 ns   // 分支预测错误
Mutex lock/unlock ........................... 25 ns   // 互斥锁操作

// 网络
Compress 1K bytes with Zippy ............. 3,000 ns  =   3 µs  // 使用Zippy压缩1K数据
Send 2K bytes over 1 Gbps network ....... 20,000 ns  =  20 µs  // 通过1Gbps网络发送2K数据
Round trip within same datacenter ...... 500,000 ns  = 0.5 ms  // 同一数据中心内的往返延迟
Send packet CA->Netherlands->CA .... 150,000,000 ns  = 150 ms  // 从加州到荷兰再返回的网络延迟
```

通过分析数据，我们可以得出以下结论：

- 内存速度快，但磁盘速度慢。
- 尽量避免磁盘寻址。
- 简单的压缩算法速度快。
- 在可能的情况下，先压缩数据再通过互联网发送。
- 数据中心通常位于不同的区域，数据在它们之间传输需要时间。

### 可用性

| Availability % | Downtime per day    | Downtime per year    |
|----------------|---------------------|----------------------|
| 99%            | 14.40 minutes       | 3.65 days            |
| 99.9%          | 1.44 minutes        | 8.77 hours           |
| 99.99%         | 8.64 seconds        | 52.60 minutes        |
| 99.999%        | 864.00 milliseconds | 5.26 minutes         |
| 99.9999%       | 86.40 milliseconds  | 31.56 seconds        |

高可用性是指系统长期稳定运行的能力，通常用百分比表示，100%为无停机时间，服务通常在99%-100%之间。

可用性通常以“9”的数量衡量，9越多可用性越高。

服务级别协议（SLA）是服务提供商与客户之间的协议，明确服务的可用性水平。主要云服务商（如亚马逊、谷歌、微软）设定SLA在99.9%或更高，

## 模拟

**评估Twitter QPS 和 storage**:

Assumptions:

- 300 million monthly active users.
- 50% of users use Twitter daily.
- Users post 2 tweets per day on average.
- 10% of tweets contain media.
- Data is stored for 5 years.

Estimations:

Query per second (QPS) estimate:
- Daily active users (DAU) = 300 million * 50% = 150 million
- Tweets QPS = 150 million * 2 tweets / 24 hour / 3600 seconds = ~3500
- Peek QPS = 2 * QPS = ~7000

We will only estimate media storage here.
Average tweet size:

```py
  tweet:
    id 64 bytes
    text 140 bytes
    media 1 MB
```

- Media storage: 150 million * 2 * 10% * 1 MB = 30 TB per day
- 5-year media storage: 30 TB * 365 * 5 = ~55 PB

系统估算注重过程，而非结果，面试中主要考察问题解决能力。建议：

- 四舍五入与近似：避免复杂计算，如将”99987 / 9.1”简化为“100,000 / 10”。
- 记录假设：明确假设以便后续参考。
- 标明单位：如“5 MB”而非单纯“5”，避免歧义。
- 常见估算类型：包括QPS, peak QPS, storage, cache, number of servers等，提前练习可提升面试表现。
