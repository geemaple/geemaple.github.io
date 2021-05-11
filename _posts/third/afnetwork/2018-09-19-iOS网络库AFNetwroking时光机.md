---
layout: post
title: "iOS网络库AFNetwroking时光机"
tags: Architecture
excerpt: "AFNetwroking的版本印记"
---

* content
{:toc}

> 前一阵子，写了一个基于BLE(Bluetooth Low Energy)的外设遥控器。BLE要比HTTP更自由的多，完全基于二进制流。具体问题列举如下：

问题1: 协议如何制定？

问题2: 如何序列化基本数据，比如String，Int到给BLE传输，反过来，如何根据协议反序列化字节数据

问题3: 如果翻译过程缓慢，是否需要引入多线程，采用异步来处理

问题4: BLE传输量有限，是否需要合并多次传输数据？


# 1.3.4版本，NSOperation+NSURLConnection

![AFNetworking1.x](http://geemaple.github.io/sketch/AFNetworking1.x.png)

恐怕最大的亮点就在于Block的使用，使得整个网络框架在使用上要比它的同类要简单得多

AFURLConnectionOperation单独开了一个线程，并增加一个Runloop，因为NSURLConnection要依赖Runloop才能进行代理的回调。通常我们在主线程中使用NSURLConnection，默认使用了主线程的Runloop，所以可能忽略了这个细节。

缺点是AFClient共有1400多行代码，里面包含了Reachability功能，Request Serializer，管理NSOperationQueue队列，HTTP认证， 以及常用的HTTP请求等

详细介绍: [AFNetworking](https://github.com/AFNetworking/AFNetworking/tree/1.3.4#overview)

 
# 2.6.3版本，职责细分，新老过度

//TODO

# 3.x版本，NSURLSession

//TODO

--END--
