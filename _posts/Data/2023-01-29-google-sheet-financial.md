---
layout: post
title: "工具介绍 - Excel利率计算"
categories: Data
tags: Excel
excerpt: "生产力三件套"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

微软工作三件套是Word, Excel, PowerPoint. 苹果谷歌对应叫法不一样，但是功能都差不多可以相互替代，以网页版Google Sheet为例

## [XIRR函数](https://support.google.com/docs/answer/3093266)

计算投资回报，现金流(必须有正有负)，日期，估计利率(可选)

计算贷快利率，可以理解为银行的投资回报率:

```
XIRR(B1:B37, A1:A37, 4.84) * 100
```

![XIRR]({{site.static}}/images/google-sheet-xirr.png)

[源文件](https://docs.google.com/spreadsheets/d/1DYC3ItZEu9ST8dISp7PJ_-nn9xPGIJBb1DClb96PmRI/edit?usp=sharing)