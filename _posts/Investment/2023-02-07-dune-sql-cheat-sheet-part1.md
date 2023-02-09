---
layout: post
title: "数析-SQL小抄(一)"
date: 2023-02-07
categories: Investment
tags: Investment Web3 SQL
excerpt: "SQL使用"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

PS: 本文环境使用Dune数据分析平台，使用Dune Engine V2(Spark SQL)引擎, 不同引擎语法略有差异

## SQL

### 语法

```sql
select col1, col2, ...
from schema.table
where ...
order by ...
limit ...
```

```sql
select blockchain, contract_address, decimals, symbol
from tokens.erc20
where blockchain = 'ethereum'   -- 返回以太坊区块链的ERC20代币信息
    and symbol like 'E%'    -- 代币符号以字母E开头
order by decimals desc, symbol asc  -- 先按代币支持的小数位数降序排列，再按代币符号升序排列
limit 100
```

### 别名

```sql
select t.contract_address as `代币合约地址`,
    t.decimals as `代币小数位数`,
    t.symbol as `代币符号`
from tokens.erc20 as t
limit 10

-- 定义别名时，as 关键词可以省略
select t.contract_address `代币合约地址`,
    t.decimals `代币小数位数`,
    t.symbol `代币符号`
from tokens.erc20 t
limit 10
```

### 唯一值

```sql
select distinct blockchain
from tokens.erc20
```

## 时间

### 系统时间

```sql
select now(), current_date
```

### 年月日

区块链中的日期时间字段通常是以`年-月-日 时:分:秒`的格式保存的

`Date_Trunc`通常用表数据段`block_time`作为第二个参数，这里用系统事件代替

第一个参数可选`minute, day, week, month`

```sql
select now(), -- 系统事件
    date_trunc('day', now()) as today,  -- 日期
    date_trunc('month', now()) as current_month  -- 月份
```

### 时间段

使用`interval '2 days'`这样的语法，我们可以指定一个时间间隔。支持多种不同的时间间隔表示方式，比如`'12 hours'，'7 days'，'3 months', '1 year'`等

```sql
select now() as current_time, 
    (now() - interval '2 hours') as two_hours_ago, 
    (now() - interval '2 days') as two_days_ago,
    (current_date - interval '1 year') as one_year_ago
```

## 字符串

### 字符串拼接

我们可以使用`concat()`函数将多个字符串连接到一起的到一个新的值。还可以使用连接操作符`||`

```sql
select concat('Hello ', 'world!') as hello_world,
    'Hello' || ' ' || 'world' || '!' as hello_world_again
```

### 大小写转换

可以使用`upper`和`lower`进行大小写转换

```sql
select
    block_time 
    ,from
    ,to
    ,hash
    ,value /power(10,18) as value --通过将value除以/power(10,18)来换算精度，18是以太坊的精度
from ethereum.transactions
where block_time > '2022-01-01'  
and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296') --这里用lower()将字符串里的字母变成小写格式(dune数据库里存的模式是小写，直接从以太坊浏览器粘贴可能大些混着小写)
and value /power(10,18) >1000
order by block_time
```

### 类型转换

SQL查询种的某些操作要求相关的字段的数据类型一致，比如concat()函数就需要参数都是字符串string类型。

使用`cast(25 as string)`将数字25转换为字符串`"25"`
还可以使用`::data_type`操作符方式完成类型转换

```sql
select (cast(25 as string) || ' users') as user_counts,
  25::string || ' users' as user_counts_again
```

## 数值

### 幂次表示

`1e18`等于`power(10, 18)`或者`pow(10, 18)`也行

```sql
select 1.23 * power(10, 18) as raw_amount,
    1230000000000000000 / pow(10, 18) as original_amount,
    7890000 / 1e6 as usd_amount
```

### 类型转换

SQL查询种的某些操作要求相关的字段的数据类型一致，比如`加法`就需要参数都是数字类型。

使用`cast(123 as numeric)`将`123`转换为数字`123`, 还可以使用`::data_type`操作符方式完成类型转换

```sql
select (cast('123'as numeric) + 55) as digital_count,
  ('123'::numeric + 55) as digital_count_again
```

## 分组

分组`group by`需要聚合函数，常用的聚合函数，count()计数，sum()求和，avg()求平均值，min()求最小值，max()求最大值等。

```sql
select blockchain, count(*) as token_count
from tokens.erc20
group by blockchain
order by 2 desc -- 对count(*)做倒序排列
```

## 查询

### 子查询

子查询(Sub Query)是嵌套在一个Query中的Query，子查询会返回一个完整的数据集供外层查询

```sql
select count(*) as blockchain_count,
    sum(token_count) as total_token_count,
    avg(token_count) as average_token_count,
    min(token_count) as min_token_count,
    max(token_count) as max_token_count
from (
    select blockchain, count(*) as token_count
    from tokens.erc20
    group by blockchain
)
```

### With

公共表表达式，即CTE(Common Table Expression)，是一种在SQL语句内执行(且仅执行一次)子查询的好方法。数据库将执行所有的WITH子句，并允许你在整个查询的后续任意位置使用其结果。

通过with as 可以构建一个子查询，把一段SQL的结果变成一个'虚拟表'（可类比为一个视图或者子查询），接下来的SQL中可以直接从这个'虚拟表'中取数据, 也能提高SQL的逻辑的可读性，也可以避免多重嵌套。

```sql
-- CTE的定义方式为with cte_name as ( sub_query )
with blockchain_token_count as (
    select blockchain, count(*) as token_count
    from tokens.erc20
    group by blockchain
)

select count(*) as blockchain_count,
    sum(token_count) as total_token_count,
    avg(token_count) as average_token_count,
    min(token_count) as min_token_count,
    max(token_count) as max_token_count
from blockchain_token_count
```

```sql
-- 按日期查询孙哥eth转账数量与价值
with transactions_info as --通过with as 建立子查询命名为transactions_info
(
    select block_time, transactions_info.stat_minute as stat_minute,
        from, to, hash, eth_amount, price, eth_amount* price as usd_value
    from 
    (
        select block_time, date_trunc('minute',block_time) as stat_minute,
            from, to, hash, value / power(10,18) as eth_amount --通过将value除以/power(10,18)来换算精度，18是以太坊的精度
        from ethereum.transactions
        where block_time > '2022-01-01'
        and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296')
        and value / power(10,18) > 1000
        order by block_time
    ) as transactions_info
    left join
    (
        --prices.usd表里存的是分钟级别的价格数据
        select date_trunc('minute',minute) as stat_minute,
            price
        from prices.usd
        where blockchain = 'ethereum'
        and symbol = 'WETH'
    )price_info
    on  transactions_info.stat_minute = price_info.stat_minute --left join关联的主键为stat_minute
)

select date_trunc('day',block_time) as stat_date,
    sum(eth_amount) as eth_amount,
    sum(usd_value) as usd_value
from transactions_info --从子查询形成的‘虚拟表’transactions_info中取需要的数据
group by 1
order by 1
```

自定义参数

```sql
with contract_address (address, name) as (
values 
('0xb136707642a4ea12fb4bae820f03d2562ebff487', 'The DAO'),
('0xc5424b857f758e906013f3555dad202e4bdb4567', 'seth_swap (curvefi)'),
('0xdc24316b9ae028f1497c275eb9192a3ea0f67022', 'steth_swap (curvefi)')
)
```

## 扩表

### Join

关联是`column`级别合并多个表(也可以是一张表出现多次)

`(inner) join`两个表交集数据
`left join`左表数据+交集数据
`right join`右表数据+交集数据，通常不用因为两个表交换一下，就可以用上面的
`full join`左表数据+交集数据+右表数据

```sql
-- 获取两条链的同名资产
select a.symbol,
    a.decimals,
    a.blockchain as blockchain_a,
    a.contract_address as contract_address_a,
    b.blockchain as blockchain_b,
    b.contract_address as contract_address_b
from tokens.erc20 as a
inner join tokens.erc20 as b on a.symbol = b.symbol
where a.blockchain = 'ethereum'
    and b.blockchain = 'bnb'
```

```sql
-- 查询孙哥eth转账usd市值, 因为prices.usd是分钟级别的，所以用分钟去关联价格
select block_time, transactions_info.stat_minute as stat_minute, 
    from, to, hash, eth_amount, -- ethereum.transactions主要是eth转账信息
    price, eth_amount* price as usd_value --prices.usd表里存的是分钟级别的价格数据
from 
(
    select block_time, date_trunc('minute',block_time) as stat_minute, --把block_time用date_trunc处理成分钟，方便作为主键去关联
        from, to, hash, value /power(10,18) as eth_amount --通过将value除以/power(10,18)来换算精度，18是以太坊的精度
    from ethereum.transactions
    where block_time > '2022-01-01'
    and from = lower('0x3DdfA8eC3052539b6C9549F12cEA2C295cfF5296')
    and value /power(10,18) >1000
    order by block_time
) as transactions_info
left join --讲transactions_info与price_info的数据关联，关联方式为 left join
(
    select date_trunc('minute',minute) as stat_minute, --把minute用date_trunc处理成分钟，方便作为主键去关联
        price
    from prices.usd
    where blockchain = 'ethereum'
    and symbol = 'WETH'
) as price_info
on transactions_info.stat_minute = price_info.stat_minute --left join关联的主键为stat_minute
```


### Union

集合是`row`级别的扩表，`Union`会自动去除合并后的集合里的重复记录，`Union All`则不会做去重处理, 对于包括海量数据的链上数据库表，去重处理有可能相当耗时，所以建议尽可能使用`Union All`以提升查询效率。

```sql
select contract_address, symbol, decimals
from tokens.erc20
where blockchain = 'ethereum'

union all

select contract_address, symbol, decimals
from tokens.erc20
where blockchain = 'bnb'
```

## 条件

### Case

```sql
select (case when decimals >= 10 then 'High precision'
            when decimals >= 5 then 'Middle precision'
            when decimals >= 1 then 'Low precision'
            else 'No precision'
        end) as precision_type,
    count(*) as token_count
from tokens.erc20
group by 1
order by 2 desc
```

### Filter

```sql
select count(*) filter (where fee = 100) as pool_count_100,
    count(*) filter (where fee = 500) as pool_count_500,
    count(*) filter (where fee = 3000) as pool_count_3000,
    count(*) filter (where fee = 10000) as pool_count_10000
from uniswap_v3_ethereum.Factory_evt_PoolCreated
```

## 更多

1. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/02_get_started](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/02_get_started)
2. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1#3.-ri-qi-shi-jian-han-shu-fen-zu-ju-he](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1#3.-ri-qi-shi-jian-han-shu-fen-zu-ju-he)
2. [https://docs.dune.com/dune-engine-v2-beta/query-engine#changes-in-how-the-database-works](https://docs.dune.com/dune-engine-v2-beta/query-engine#changes-in-how-the-database-works)