---
layout: post
title: "Google Sheet金融使用"
date: 2023-01-29
categories: Investment
tags: Sheet Excel
excerpt: "生产力三件套"
---

* content
{:toc}

## [XIRR函数](https://support.google.com/docs/answer/3093266)

计算投资回报，现金流(必须有正有负)，日期，估计利率(可选)

计算贷快利率，可以理解为银行的投资回报率:

```
XIRR(B1:B37, A1:A37, 4.84) * 100
```

![XIRR]({{site.static}}/images/google-sheet-xirr.png)

[源文件](https://docs.google.com/spreadsheets/d/1DYC3ItZEu9ST8dISp7PJ_-nn9xPGIJBb1DClb96PmRI/edit?usp=sharing)