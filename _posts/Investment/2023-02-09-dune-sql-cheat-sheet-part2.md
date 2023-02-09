---
layout: post
title: "数析-SQL小抄(二)"
date: 2023-02-09
categories: Investment
tags: Investment Web3 SQL
excerpt: "SQL使用"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

PS: 本文环境使用Dune数据分析平台，使用Dune Engine V2(Spark SQL)引擎, 不同引擎语法略有差异

## 聚合

### 数学统计

```sql
select 
    sum( value /power(10,18) ) as value --对符合要求的数据的value字段求和
    ,max( value /power(10,18) ) as max_value --求最大值
    ,min( value /power(10,18) )  as min_value--求最小值
    ,count( hash ) as tx_count --对符合要求的数据计数，统计有多少条
    ,count( distinct to ) as tx_to_address_count --对符合要求的数据计数，统计有多少条(按照去向地址to去重)
from ethereum.transactions 
where block_time > '2022-01-01'
and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296') --限制孙哥的钱包，这里用lower()将字符串里的字母变成小写格式(dune数据库里存的模式是小写，直接从以太坊浏览器粘贴可能大些混着小写)
and value /power(10,18) > 1000
```

### 时间统计

```sql
-- 把粒度到秒的时间转化为天/小时/分钟(为了方便后续按照天或者小时聚合)
select 
    block_time --transactions发生的时间
    ,date_trunc('hour', block_time) as stat_hour --转化成小时的粒度
    ,date_trunc('day', block_time) as stat_date --转化成天的粒度
    ,date_trunc('week', block_time) as stat_minute--转化成week的粒度
    ,from
    ,to
    ,hash
    ,value /power(10,18) as value --通过将value除以/power(10,18)来换算精度，18是以太坊的精度
from ethereum.transactions 
where block_time > '2021-01-01'
and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296')
and value /power(10,18) >1000
order by block_time
```

### 分组聚合

如果不分组，那默认所有的数据都是同一组; 分组之后，相同字段内容会组成一组

```sql
select date_trunc('day',block_time) as stat_date --用date_trunc函数将block_time转化为只保留日期的格式
    ,sum( value /power(10,18) ) as value --对符合要求的数据的value字段求和
from ethereum.transactions
where block_time > '2022-01-01'
and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296')
and value / power(10,18) > 1000
group by 1 --按照stat_date去分组，stat_date是用 'as'对date_trunc('day',block_time)取别名
order by 1 --按照stat_date去排序
```


## 更多

1. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1)