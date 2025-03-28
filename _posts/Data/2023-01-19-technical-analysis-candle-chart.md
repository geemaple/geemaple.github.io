---
layout: post
title: "技术分析 - K线图"
categories: Data
tags: Python
excerpt: 时间是最好的朋友
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

## K线图

K线图`Candle Chart`与国际一致，绿色代表上涨，红色代表下跌

![K线图]({{site.static}}/images/investment-kindle-chart.png)

K线图用来显示交易市场的价格信息，其中主体粗的部分是指定时间内`开始`和`结束`价格。主体上下的隐线代表`最高`和`最低`价格。

注意，两种K线开始和结束价格位置相反

## 交易量

K线图下方通常会显示交易量，交易量是交易资产的`数量`，而不是交易资金量。

![交易量]({{site.static}}/images/investment-trading-volume.png)

## 交易所费率

交易所做的事情之一是`撮合交易`, 当买入价格**大于等于**卖出价格时, 交易便可进行

费率是不可忽视的一项花销，尤其是频繁交易者。交易费往往是交易所最主要的收入来源

根据资金量/会员等级，不同的交易所会有不同的规则，费率通常在**千分之几**

交易所为了鼓励大家贡献资金池，通常会对交易者做`maker`和`taker`的区分。

挂单`maker`是为流动池添砖加瓦，即挂单不会立即成交，订单记录在订单簿上，可能会有手续费减免。

吃单`taker`完全依赖流动池，交易会立即成交。

## 订单类型

### 市价单和限价单

1. 市价单`market`订单, 以市场最优的价格买卖，会立即成交。完成交易开始时的价格与结束时的价格差异叫做`滑点`。好的交易所，对手资金流动池庞大，`滑点`相对较低。
2. 限价单`limit`订单, 以指定的价格买卖。

### 限价单选项

1. 现价单不保证会是`maker`, 可以使用`Post Only`选项，如果它不会与对手盘成交，它就挂在盘口成为`maker`，如果会与对手盘成交，它将自动取消。
2. 与上对应的是`taker`的`IOC`(Immediate or Cancel)，它会先吃掉对手盘符合价格条件的订单，如果没有完全成交，未成交部分自动取消。 类似的有`AON`(All or None)必须全部成交否则取消，不允许部分成交。`FOK`(Fill or Kill)必须立即成交，否则取消，不允许部分成交。
3. 冰山`Iceberg`订单，如果大额交易可以使用冰川订单，会将大的订单分割成小部分先挂在订单上，若成交再挂下一部分，从而避免影响对手。
4. `GTC`默认选项，订单要么成交，要么被交易者取消。

### 止损订单

1. `stop-limit`订单，当价格达到触发止损`stop`价格时，交易所立即帮你挂一个现价单。对应的`stop-market`或者`stop`，到达触发价格时，交易所立即帮你挂一个市价单。前者可能卖不出去，后者卖出的价格可能远远偏离预期
2. `trailing-stop`订单, `Activation Price`激活价格，`trailing Delta`价格不利方向容忍百分比。2条件都满足时，则交易所立即帮你挂一个限价单。```条件1 == (买单激活价格>=最低价，卖单激活价格<=最高价), 条件2 == (买单涨幅>=容忍度，卖单跌幅>=容忍度)```

### 其他订单

1. `OCO`订单(One Cancel the Other)，同时挂`stop-limit`订单和`limit`订单对, 如果任意一个订单成交，那么另一个订单自动取消。任意一个订单取消，则整个`OCO`点单取消。

## 绘制

![k线图]({{site.static}}/images/investment-lesson-01.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_analysis/lesson-01-k-chart.py)

## 更多

1. [https://pandas.pydata.org/docs/getting_started/intro_tutorials/01_table_oriented.html](https://pandas.pydata.org/docs/getting_started/intro_tutorials/01_table_oriented.html)
2. [https://nathancarter.github.io/dataframe-animations/](https://nathancarter.github.io/dataframe-animations/)