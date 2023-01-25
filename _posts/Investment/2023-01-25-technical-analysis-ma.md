---
layout: post
title: "技术分析-均值MA"
date: 2023-01-22
categories: Investment
tags: Investment
excerpt: "平均也有权重"
mathjax: true
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

## 移动平均线

移动平均线MA是价格在指定时间T的平均价格，常用来确认趋势，阻力位和支撑位

MA是比较滞后的技术指标，能够过滤掉价格波动的噪音。用来解释市场而不是预判市场。

### WMA

加权移动平均线，计算的时候加上权重。最近的时间权重为`n`，最远的权重为`1`, 结果除以总权重

$
WMA_M = \frac{kP_{n} + (k - 1)P_{n - 1} + ... + 2p_{n - (k - 2)} + P_{n - (k - 1)} }{k + (k - 1) + ... + 2 + 1}
$

例如: `n = 5, k = 3, p = [5, 6, 7, 8, 9] w = [0, 0, 1, 2, 3]`

$WMA_3 = \frac{p_3 * w_3 + p_4 * w_4 + p_5 * w_5}{3} = (3 * 9 + 2 * 8 + 7)/(3 + 2 + 1) = 8.34$

```python
weights = np.array([i for i in range(14, 0, -1)])
sum_wights = np.sum(weights)
wma = close_prices.tail(365 + days).rolling(days).apply(lambda x: np.sum(x * weights) / sum_wights)
```

### SMA

简单移动平均线是没有权重的，也就是权重都是`1`，计算也最简单，就是我们常见的`平均值`。

`n`代表计算第`n`的移动均值，`k`计算多少时间间隔

$
SMA_k = \frac{p_{n - (k - 1)} + p_{n - (k - 2)} + ... + p_n}{k} = \frac{1}{k} \sum_{i = n - k + 1}^{n} p_i
$

例如`n = 5, k = 3, p = [5, 6, 7, 8, 9]`

$SMA_3 = \frac{p_3 + p_4 + p_5}{3} = (7 + 8 + 9) / 3 = 8$

```python
days = 14
close_prices = df.tail(365 + days)['close']

# calculate SMA
sma = close_prices.tail(365 + days).rolling(days).mean()
```

```
A B C D
  B C D E
```

由于窗口的特性，`BCD`是重复的，`BCDE`可以通过已有的`ABCD`去掉`A/4`加上`E/4`获得

### EMA

指数移动平均线`EMA`初始值不同，结果不太相同

$
EMA_{today} = price_{today} \times{\frac{Smoothing}{1 + Days}} + EMA_{yesterday}\times({1 - (\frac{Smoothing}{1 + Days})})
$

如果令$\alpha = \frac{Smoothing}{1 + Days}$

$
EMA_{today} = (price_{today} - EMA_{yesterday})\times{\alpha} + EMA_{yesterday}
$

这是一个递归公式，第一个值使用`SMA`来填充。平滑系数`Smoothing`可以根据偏好选择，但通常值为`2`。

展开后

$
EMA_{today} = \frac{p_1 + (1 - \alpha){p_2} + (1 - \alpha)^2p_3 + (1 - \alpha)^3p_4 + ...}{1 + (1 - \alpha) + (1 - \alpha)^2 + (1 - \alpha)^3 + ...}
$

`EMA`也是一种`WMA`

#### DEMA

注意，后面不是平方，而是算EMA的EMA

$Double EMA = 2\times{EMA} - EMA(EMA)$

#### TEMA

注意，后面不是立方，而是算EMA的EMA的EMA
$Triple EMA = (3\times{EMA} – 3\times{EMA(EMA)}) + EMA(EMA(EMA)))$


## 绘制

![MA]({{site.static}}/images/investment_lesson_03.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_analysis/lesson-03-ma.py)

## 更多

1. [https://trader.fandom.com/wiki/Moving_average#Cumulative_moving_average](https://trader.fandom.com/wiki/Moving_average#Cumulative_moving_average)
2. [https://www.tradingview.com/support/solutions/43000502589-moving-average/](https://www.tradingview.com/support/solutions/43000502589-moving-average/)