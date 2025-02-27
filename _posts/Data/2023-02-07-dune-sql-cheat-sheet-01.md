---
layout: post
title: "SQL语言01 - 基本查询"
categories: Data
tags: SQL
excerpt: "SQL使用"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

PS: 本文环境使用Dune数据分析平台，使用Dune Engine V2(Spark SQL)引擎, 不同引擎语法略有差异

## SQL语法

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

## 别名

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

## 唯一值

```sql
select distinct blockchain
from tokens.erc20
```

## 时间

**注意**, Dune的查询编辑器默认只显示到`年-月-日 时:分`

### 年月日

区块链中的日期时间字段通常是以`年-月-日 时:分:秒`的格式保存的, 常用的有`now()`和`current_date()`

`Date_Trunc`通常用表数据段`block_time`作为第二个参数，这里用系统事件代替

第一个参数可选`minute, day, week, month`

```sql
select now(), -- 系统时间
    current_date(), -- 日期
    date_trunc('day', now()) as today,  -- 日期
    date_trunc('month', now()) as current_month  -- 月份
```

### 时间段

使用`interval '2 days'`这样的语法，我们可以指定一个时间间隔。支持多种不同的时间间隔表示方式，比如`'12 hours'，'7 days'， '1 week'， '3 months', '1 year'`等

```sql
select now() as current_time, 
    (now() - interval '2 hours') as two_hours_ago, 
    (now() - interval '2 days') as two_days_ago,
    (current_date - interval '1 year') as one_year_ago
```

```sql
select now() as `now`,
 current_date as `current_date`,  -- 函数也可以省略括号写成current_date， 等于date_trunc('day', now())
 block_time
from ethereum.transactions
where block_time >= '2023-01-01'
limit 10
```

### 日期运算

```sql
select dateadd(MONTH, 2, current_date) -- 当前日期加2个月后的日期
    ,dateadd(HOUR, 12, now()) -- 当前日期时间加12小时
    ,dateadd(DAY, -2, current_date) -- 当前日期减去2天
    ,date_add(current_date, 2) -- 当前日期加上2天
    ,date_sub(current_date, -2) -- 当前日期减去-2天，相当于加上2天
    ,date_add(current_date, -5) -- 当前日期加上-5天，相当于减去5天
    ,date_sub(current_date, 5) -- 当前日期减去5天
    ,datediff('2022-11-22', '2022-11-25') -- 结束日期早于开始日期，返回负值
    ,datediff('2022-11-25', '2022-11-22') -- 结束日期晚于开始日期，返回正值
```

## 字符串

### 字符串拼接

我们可以使用`concat()`函数将多个字符串连接到一起的到一个新的值。还可以使用连接操作符`||`

```sql
select concat('Hello ', 'world!') as hello_world,
    'Hello' || ' ' || 'world' || '!' as hello_world_again
```

### 字符串大小写

可以使用`upper`和`lower`进行大小写转换, Dune V2引擎中，交易哈希值（hash）、用户地址、智能合约地址这些全部以小写字符格式保存

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

### Json与正则

在Dune V2中，我们可以直接使用`:`符号来访问json字符串中的元素的值

```sql
-- 查询Lens协议ENS类型
select vars:to as user_address,
    vars:handle as handle_name,
    replace(vars:handle, '.lens', '') as short_name,
    (case when replace(vars:handle, '.lens', '') rlike '^[0-9]+$' then 'Pure Digits'
        when replace(vars:handle, '.lens', '') rlike '^[a-z]+$' then 'Pure Letters'
        else 'Mixed'
    end) as handle_type,
    call_block_time,
    output_0 as profile_id,
    call_tx_hash
from lens_polygon.LensHub_call_createProfile
where call_success = true
```

### 子字符串

```sql
select substring('hhello-world', 2), --  hello world,  substring(expr, pos [, len])
    substring('hhello-world', 2, 5),  -- hello
    right('hhello-world', 5) -- world
```

### 进制转换

```sql
select date_trunc('day', block_time) as block_date, --截取日期
    concat('0x', right(substring(data, 3 + 64 * 2, 64), 40)) as address, -- 提取data中的第3部分转换为用户地址，从第3个字符开始，每64位为一组
    concat('0x', right(substring(data, 3 + 64 * 3, 64), 40)) as token, -- 提取data中的第4部分转换为用户地址
    substring(data, 3 + 64 * 4, 64) as hex_amount, -- 提取data中的第5部分
    bytea2numeric_v2(substring(data, 3 + 64 * 4, 64)) as amount, -- 提取data中的第5部分，转换为10进制数值
    tx_hash
from ethereum.logs
where contract_address = '0x5427fefa711eff984124bfbb1ab6fbf5e3da1820'   -- Celer Network: cBridge V2 
    and topic1 = '0x89d8051e597ab4178a863a5190407b98abfeff406aa8db90c59af76612e58f01'  -- Send
    and substring(data, 3 + 64 * 5, 64) = '000000000000000000000000000000000000000000000000000000000000a4b1'   -- 42161，直接判断16进制值
    and substring(data, 3 + 64 * 3, 64) = '000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' -- WETH，直接判断16进制值
    and block_time >= now() - interval '7 days'
limit 10
```

### 字符转数字

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

### 数字转字符

SQL查询种的某些操作要求相关的字段的数据类型一致，比如`加法`就需要参数都是数字类型。

使用`cast(123 as numeric)`将`123`转换为数字`123`, 还可以使用`::data_type`操作符方式完成类型转换

```sql
select (cast('123'as numeric) + 55) as digital_count,
  ('123'::numeric + 55) as digital_count_again
```

## 条件

### Case

`Case`中的`else`部分还可以省略，此时返回`NULL`

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

### If

```sql
select if(1 < 2, 'a', 'b') -- 条件评估结果为真，返回第一个表达式
    ,iff('x' > 'z', 'x > z', 'x <= z') -- 跟if()功能相同
    ,if('a' = 'A', 'case-insensitive', 'case-sensitive') -- 字符串值区分大小写
```


### Filter

```sql
select count(*) filter (where fee = 100) as pool_count_100,
    count(*) filter (where fee = 500) as pool_count_500,
    count(*) filter (where fee = 3000) as pool_count_3000,
    count(*) filter (where fee = 10000) as pool_count_10000
from uniswap_v3_ethereum.Factory_evt_PoolCreated
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

## 更多

1. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/02_get_started](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/02_get_started)
2. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1#3.-ri-qi-shi-jian-han-shu-fen-zu-ju-he](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/sql_syntax_1#3.-ri-qi-shi-jian-han-shu-fen-zu-ju-he)
2. [https://docs.dune.com/dune-engine-v2-beta/query-engine#changes-in-how-the-database-works](https://docs.dune.com/dune-engine-v2-beta/query-engine#changes-in-how-the-database-works)