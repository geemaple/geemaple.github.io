---
layout: post
title: "技术分析 - Stochastic"
categories: DA
tags: Oscillator Python
excerpt: "市场永远是对的"
mathjax: true
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

```
要是市场碰上大利多还不涨，反而下跌的话，你要是做多就要赶快跑！一个意料不到的反向行情，表示这里面必定有某些严重问题 ----《损点：如何克服贪婪和恐惧》
```

## 随机指标

STOCH = Stochastic Oscillator = 随机指标

`Stochastic`源自希腊语，意为`目标，猜测`，在技术分析中，他是一个动量指标，使用支撑位和压力位计算，用来预测价格反转

### 计算

随机指标可以分成`%K`和`%D`两部分, `High`为统计时间最高价格 `Low`为统计时间最低价格，`%K`如下:

$
\%K = 100 \times{\frac{Price - Low_t}{High_t - Low_t}}
$

`%D`去上面的均值，通常使用SMA, 如果波动剧烈可以使用EMA

$
\%D_{t} = SMA(\%K, t)
$

### 意义

任何范围都可以映射到[0, 1]区间，再乘以100，就是随机指标的范围

随机指标是区间类型的指标, 也就是说用户指定一个时间范围，然后指标价格映射到这个区间。第二条线只不过是平滑一点。

最常用使用的时间范围是`%K`使用14, `%D`使用3

使用STOCH最好，了解市场趋势，跟随指标趋势

#### 超买超卖

1. 如果值>80, 代表超买，上升趋势中，出现超买信号变多
2. 如果值<20, 代表超卖，下降趋势中，出现超卖信号变多

![上升趋势]({{site.static}}/images/opengl-stoch-overbought.png)

#### 背离

1. 上涨背离，当价格低于前低，但指标低点高于前高
2. 下跌背离，当价格高于前高，但指标高点低于前低

![下跌背离]({{site.static}}/images/opengl-stoch-divergence.png)

#### 牛熊趋势

与背离类似，但是有个反转
 
1. 当价格低于前高，但指标高于前高时, 之后出现低点再反弹
2. 当价格高于前低，但指标低于前低时, 之后出现高点再回调

![下跌背离]({{site.static}}/images/opengl-stoch-bull-setup.png)

## 绘制

![绘制]({{site.static}}/images/investment-lesson-05.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_analysis/lesson-05-stoch.py)

## 更多

1. [https://www.tradingview.com/support/solutions/43000502332-stochastic-stoch/](https://www.tradingview.com/support/solutions/43000502332-stochastic-stoch/)
2. [https://docs.anychart.com/Stock_Charts/Technical_Indicators/Mathematical_Description#overview](https://docs.anychart.com/Stock_Charts/Technical_Indicators/Mathematical_Description#overview)
