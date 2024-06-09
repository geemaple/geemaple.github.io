---
layout: post
title: "技术分析 - MACD"
categories: DA
tags: Oscillator Python
excerpt: "指标的指标"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

## MACD

Moving Average Convergence Divergence = 异同移动平均线

MACD是非常流行的技术指标，也非常简单，可以说是策略101(即入门级策略)。

MACD是滞后指标(Lagging Indicator)，即根据过去的价格或数据来衡量市场动向和可能的价格趋势。

### 计算

#### 线

用来决定`上涨`还是`下跌`趋势，主要通过两个`EMA`相减得出, 常用的是12天`EMA`与26天`EMA`

```
MACD Line = 12d EMA - 26d EMA
```

#### 信号线

```
Signal line = 9d EMA(MACD line)
```

对`线`做EMA操作，通常是9日EMA

#### 柱状图

柱状图主要是计算`线`与`信号线`的差值得出, 是一种视觉化的表示两条线的差值

```
MACD histogram = MACD line - signal line
```

### 意义

#### 零线交叉

当`MACD Line`与`零线`交叉时，均值时间越短，响应速度越快。

1. 当`MACD Line`向上交叉时，即价格短期均值`大于`长期均值，为上涨趋势
2. 当`MACD Line`向下交叉时，即价格短期均值`小于`长期均值，为下跌趋势

![MACD Zero Cross]({{site.static}}/images/investment-macd-zero-cross.png)

#### 信号线交叉

信号线是指标的指标。由于信号线是`MACD Line`的均值，所以信号线相比`MACD Line`要滞后一些

1. 当信号线向上形成交叉，为上涨趋势
2. 当信号线向下形成交叉，为下跌趋势

![MACD Signal Cross]({{site.static}}/images/investment-macd-signal-cross.png)

#### 背离

背离时MACD于实际价格趋势不一致的情况

1. 看涨背离，市场价格向下(常用高点比较)，但MACD低点高于前低，即使价格下跌，可能购买强劲。
2. 看跌背离，市场价格向上(常用低点比较)，但MACD高点低于前高，即使价格变高，可能动能不足。

![MACD Divergence]({{site.static}}/images/investment-macd-bearish-divergence.png)

## 绘制

```python
ema_fast = close_prices.tail(365 + window).ewm(span=fast,min_periods=fast,adjust=False,ignore_na=False).mean()
ema_slow = close_prices.tail(365 + window).ewm(span=slow,min_periods=slow,adjust=False,ignore_na=False).mean()
macd_line = ema_fast - ema_slow
macd_signal = macd_line.ewm(span=smooth, min_periods=smooth, adjust=False, ignore_na=False).mean()
macd_histogram = macd_line - macd_signal
```

![MACD]({{site.static}}/images/investment-lesson-04.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_analysis/lesson-04-macd.py)

## 更多

1. [https://www.tradingview.com/support/solutions/43000502344-macd-moving-average-convergence-divergence/](https://www.tradingview.com/support/solutions/43000502344-macd-moving-average-convergence-divergence/)