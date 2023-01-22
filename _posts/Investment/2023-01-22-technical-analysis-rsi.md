---
layout: post
title: "技术分析-RSI"
date: 2023-01-22
categories: Investment
tags: Investment
excerpt: 相对强弱指数RSI
mathjax: true
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

## RSI

RSI(Relative Strength Index)是一个动量指标，用来衡量股票在一段时间内的价格变动。

RSI主要是衡量价格变化与速度的指标，默认情况下，RSI计算连续14个时间单位(天，4小时，1小时等)，RSI`等于`一段时间内上涨平均值`除以`下跌平均值, 再将结果映射到`[0, 100]`的区间里。

### 计算

以天为单位，首先分别计算每日`上涨`与`下跌`差值, 上涨时`U`和`D`如下:

$U_k = close_k - close_{k-1}$

$D_k = 0$

相反, 下跌时`U`和`D`如下:

$U_k = 0$

$D=close_{k-1} - close_k$

然后，分别计算单位时间内的`上涨`与`下跌`的平均值`SMA`, RS唯一不同是计算平均值的方法不尽相同(SMMA, EWMA), 但最终结果类似。

$
RS = \frac{SMA(U, n)}{SMA(D, n)}
$

最后将结果`RS`转换到`[1, 100]`区间:

$
RSI = 100\times{\frac{SMA(U, n)}{SMA(U, n) + SMA(D, n)}}
= 100 - \frac{100}{1 + RS}
$

### 意义

RSI在指定时间判断价格变动速度，用来查看市场`超买`和`超卖`，对于默认`14天RSI`天来说。
1. `RSI <= 30`时，指标认为出现`超卖`，市场可能见底了
2. `RSI >= 70`时，指标认为出现`超买`，市场可能到顶了

难点是时间跨度不同，结果不同，所以`7天RSI`会更敏感，`21天RSI`敏感度会降低。有些人把`[30, 70]`判断调整到`[20, 80]`.

除了`30/70`规则，有些人也用`RSI`预测`反转`和`支撑位`。

1. 上涨背离，市价格和RSI方向相反，虽然价格低于前低，但是RSI底点高于前低，表明即使价格下跌，购买力增强
![上涨背离]({{site.static}}/images/investment-rsi-bullish-divergence.jpg)

2. 下跌背离, 市价格和RSI方向相反，虽然价格高于前高，但是RSI高点低于前高，表明即使价格上涨，购买力减弱
![下跌背离]({{site.static}}/images/investment-rsi-bearish-divergence.jpg)

## 绘制

```python
# RSI
days = 14
# calculate U and D
change = prices['close'].diff()
change.dropna(inplace=True)

ups = change.copy()
downs = change.copy()

ups[ups < 0] = 0
downs[downs > 0] = 0

# calculate RS
sma_up = ups.rolling(days).mean()
sma_down = downs.rolling(days).mean().abs()

# scale rs to range [1, 100]
rsi = 100 * sma_up / (sma_up + sma_down)
print(rsi)
```

![RSI]({{site.static}}/images/investment_lesson_02.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_analysis/lesson-02-rsi.py)

## 更多

1. [https://en.wikipedia.org/wiki/Relative_strength_index](https://en.wikipedia.org/wiki/Relative_strength_index)
2. [https://matplotlib.org/stable/gallery/style_sheets/style_sheets_reference.html](https://matplotlib.org/stable/gallery/style_sheets/style_sheets_reference.html)