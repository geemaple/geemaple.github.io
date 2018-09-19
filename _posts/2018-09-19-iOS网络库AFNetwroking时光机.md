---
layout: post
title: "iOS网络库AFNetwroking时光机"
tags: AFNetwroking, Architecture
excerpt: "AFNetwroking的版本印记"
---

> 前一阵子，写了一个基于BLE(Bluetooth Low Energy)的遥控器。BLE要比HTTP更自由的多，完全基于二进制流。具体问题列举如下：

问题1: 协议如何制定？

问题2: 如何转化应用基本数据，比如String，Int到给BLE传输，反过来，如何根据协议翻译对应的2进制

问题3: 如果翻译过程缓慢，是否需要引入多线程，采用异步来处理

问题4: BLE传输量有限，是否需要合并多次传输数据？


# 1.0版本，NSOperation+NSURLConnection






--END--
