---
layout: post
title: "计算机数学, 边界与数量级"
categories: Algobase
tags: Algobase Math
excerpt: "边界与数量级"
---

* content
{:toc}

好的程序员应该是对数量级敏感的一类人，因为这直接影响到程序的效率。服务端有常见的10k问题，即当输入数量级达到10k的级别是，会对程序有着相当大的考验，那么回到本文提到的2^64究竟有多大？

# 计算机数字表示
计算机中参与运算的数都是用二进制表示的，也叫位数组[bit-array](1)(也叫bit-map, bit-set, bit-string, bit-vector)

## 正数表示
正数和零的表示法与其二进制写法相同，只是左边要补符号位0

8位二进制表示数字时:

	例如5的二进制是 = 101
	可以表示为 0000 0101
	
解析时：
	
	最左边0表示非负数
	000 0101 = 5
	加上符号位 = +5

## 负数表示(补码)
负数的表示法，首先是将其绝对值**安位取反**，然后+1

8位二进制表示数字时:

	如上，-5的绝对值二进制是 = 0000 0101
	安位取反 = 1111 1010
	+1之后 = 1111 1011
	
解析时：

	最左边1表示负数
	安位取反 = 000 0100
	+1之后 = 000 0101
	加上符号位-5
	
同样的内容，如果当成unsigned int解析 = 251
	

## 数字2147483647
面对这样的数字存在10种人，第一种能像圆周率一样背下来，第二种就是一脸懵逼。那为什么它很重要呢，这个数字是32位有符号int能存储的最大值，即2^32 - 1。 范围是(-2^32 ~ 2^32 - 1), 其中0占据了正数的一个位置，所以正数少一个，负数多一个。 


# 2^64究竟有多大？

大多数程序员都知道2^10 = 1024 ≈ 1k, 因此还有10月24日程序员节。
那么2^64 = (2^10)^6 * 2^4 ≈ 16后面加上18个0

## python计算
16后面18个0 = 16000000000000000000L = 1.6e+19

2的64次方   = 18446744073709551616L ≈ 1.84467e+19

## 棋盘上的谷粒
国际象棋有8x8个格子，传说国际象棋是由一位印度数学家发明的。国王十分感谢这位数学家，于是就请他自己说出想要得到什么奖赏。这位数学家想了一分钟后就提出请求——把1粒米放在棋盘的第1格里，2粒米放在第2格，4粒米放在第3格，8粒米放在第4格，依次类推，每个方格中的米粒数量都是之前方格中的米粒数量的2倍。国王欣然应允，诧异于数学家竟然只想要这么一点的赏赐。

那么实际结果:2^64 - 1, (64位无符号2进制数每一位都是1)

一粒谷子大约:6.4799e-5(kg)

总重量大约：16 * 6.4799 后面加上10个0(吨)

## CPU频次
假设一台现代电脑CPU主频3.1Ghz，那么CPU持续工作一年，大约3 * 10^9 * 86400 * 365 = 9.4608e+16, 要达到2^64，需要大学195台电脑

## N的阶层
20! < 2 ^ 64 < 21!

# 彩蛋

*内存表示是有endian的，所以符号为不一定是最“左边”*

## 复利的力量
如果每天进步%1，那么多少天能够大于2^64呢？

如果每天进步%5，%10呢？

math.log(2 ** 64, 1.01) ≈ 4458

math.log(2 ** 64, 1.05) ≈ 909

math.log(2 ** 64, 1.1) ≈ 465

[1]https://en.wikipedia.org/wiki/Bit_array