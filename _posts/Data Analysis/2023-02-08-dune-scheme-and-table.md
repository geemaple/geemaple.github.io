---
layout: post
title: "平台介绍 - Dune"
categories: Data-Analysis
tags: Web3
excerpt: "数据表"
---

* content
{:toc}

> 本文仅作为学习目的，一切内容均不构成任何投资意见或建议, 投资有风险入市需谨慎

PS: 本文环境使用Dune数据分析平台，使用Dune Engine V2(Spark SQL)引擎, 不同引擎语法略有差异

## 原始数据表

原始数据表(RAW)包括：区块表(Blocks)、交易表(Transactions)、内部合约调用表(Traces)、事件日志表(Logs)以及合约创建跟踪表(creation_traces)
### 区块表

区块(Block)是区块链的基本构建组件。一个区块包含多个交易记录。区块表记录了每一个区块生成的日期时间(block time)、对应的区块编号(block number)、区块哈希值、难度值、燃料消耗等信息。除了需要分析整个区块链的区块生成状况、燃料消耗等场景外，我们一般并不需要关注和使用区块表。其中最重要的是区块生成日期时间和区块编号信息，它们几乎都同时保存到了其他所有数据表中，只是对应的字段名称不同。

### 交易表

交易表(Transactions)保存了区块链上发生的每一个交易的详细信息, 交易表中最常用的字段包括block_time(或block_number)、from、to、value、hash、success等

### 内部合约调用表

内部合约调用表(Traces), 交易(Transactions)可以触发更多的内部调用操作，一个内部调用还可能进一步触发更多的内部调用。这些调用执行的信息会被记录到内部合约调用表。内部合约调用表主要包括`block_time`、`block_number`、`tx_hash`、`success`、`from`、`to`、`value`、`type`等字段

1. 用于跟踪区块链`原生代币`的转账详情或者`燃料消耗`. 

* 用户不直接转账，而是通过智能合约转账。`ethereum.transactions`表的`value`字段并没有保存转账的ETH的金额数据，实际的转账金额只保存在内部合约调用表的`value`值中。`ERC20`代币，则通过ERC20协议的Transfer事件来跟踪转账详情。
* 区块链交易的燃料费用也是用原生代币来支付的，燃料消耗数据同时保存于交易表和内部合约调用表。一个交易可能有多个内部合约调用，调用内部还可以发起新的调用，这就导致每个调用的from，to并不一致，也就意味着具体支付调用燃料费的账户地址不一致。

2. 用于筛选合约地址。以太坊上的地址分为两大类型. `EOA`和`合约地址`。`EOA`地址是指由以太坊用户拥有的地址，而`合约地址`是通过部署智能合约的交易来创建的。当部署新的智能合约时，`thereum.traces`表中对应记录的`type`字段保存的值为`create`。我们可以使用这个特征筛选出智能合约地址。Dune V2里面，Dune团队已经将创建智能合约的内部调用记录整理出来，单独放到了表`ethereum.creation_traces`中。通过直接查询这个表就能确定某个地址是不是合约地址。

当我们需要计算某个地址或者一组地址的原生代币ETH余额时，只有使用thereum.traces表才能计算出准确的余额。

```sql
with eth_transfer_raw as (
    select `from` as address, (-1) * value as amount
    from ethereum.traces
    where call_type = 'call'
        and success = true
        and value::decimal(38,0) > 0
        and `from` is not null
        and `to` is not null
    
    union all
    
    select `to` as address, value as amount
    from ethereum.traces
    where call_type = 'call'
        and success = true
        and value::decimal(38,0) > 0
        and `from` is not null
        and `to` is not null
    
    union all
    
    select `from` as address, (-1) * gas_price * gas_used as amount
    from ethereum.transactions
    where success = true
),

eth_balance as (
    select address,
        sum(amount) as balance_amount
    from eth_transfer_raw
    where address is not null -- exclude the null address data
    group by 1
    order by 2 desc
    limit 500
)

select row_number() over (order by balance_amount desc) as rank_id,
    '<a href=?wallet_address_tdd806=' || address || ' target=_blank>Details</a>' as detail_link,
    '<a href=https://etherscan.io/address/' || address || ' target=_blank>EtherScan</a>' as etherscan_link,
    '<a href=https://dune.com/labels/ethereum/' || address || ' target=_blank>Label</a>' as label_link,
    balance_amount / 1e18 as balance_amount,
    address
from eth_balance
order by balance_amount desc
limit 500
```

### 事件日志表

事件日志表存储了智能合约生成的所有事件日志。当我们需要查询分析那些尚未被解码或者无法解码(由于代码非开源等原因)的智能合约，事件日志表非常有用. 建议优先使用已解析的数据表，这样可以提高效率并降低在查询中引入错误的可能性。但是，有时由于时效性(合约还未来得及被解码)或者合约本身不支持被解码的原因，我们就不得不直接访问事件日志表来查询数据进行分析

1. topic1 存贮的是事件对应的方法签名的哈希值。我们可以同时使用contract_address 和topic1筛选条件来找出某个智能合约的某个方法的全部事件日志记录。
2. topic2、topic3、topic4 存贮的是事件日志的可索引参数(主题)，每个事件最多支持3个可索引主题参数。当索引主题参数不足3个时，剩余的字段不保存任何值。
3. data存贮的是事件参数中没有被标记为索引主题类型的其他字段的16进制的组合值，字符串格式，以0x开头，每个参数包括64个字符，实际参数值不足64位则在左侧填充0来补足位数。当我们需要从data里面解析数据时，就要按照上述特征，从第3个字符开始，以每64个字符为一组进行拆分，然后再按其实际存贮的数据类型进行转换处理(转为地址、转为数值或者字符串等)

Transaction:
![Ethereum transaction]({{site.static}}/images/web3-analysis-eth-transaction.png)

Log:
![Ethereum log]({{site.static}}/images/web3-analysis-eth-log.png)

```sql
select date_trunc('minute', block_time) as block_time,
    date_trunc('day', block_time) as block_date,
    concat('0x', right(topic3, 40)) as address,
    '0xb8901acb165ed027e32754e0ffe830802919727f' as token,
    substring(data, 3, 64) as hex_amount,
    bytea2numeric_v2(substring(data, 3, 64)) as original_amount,
    tx_hash
from ethereum.logs l
inner join (
    select hash
    from ethereum.transactions
    where block_time >= now() - interval '20 days'
        and `to` = '0xc30141b657f4216252dc59af2e7cdb9d8792e1b0' -- Socket: Registry
        and data like '%b8901acb165ed027e32754e0ffe830802919727f%'  -- Hop Protocol: Ethereum Bridge
) t on l.tx_hash = t.hash
where  topic1 = '0x0a0607688c86ec1775abcdbab7b33a3a35a6c9cde677c9be880150c231cc6b0b'  -- TransferSentToL2
    and topic2 = '0x000000000000000000000000000000000000000000000000000000000000a4b1'   -- 42161
    and block_time >= now() - interval '20 days'
limit 20
```

## 已解析项目表

已解析项目表是数量最庞大的数据表类型。当智能合约被提交到Dune进行解析时，Dune为其中的每一个方法调用（Call）和事件日志（Event）生成一个对应的专用数据表。

层级如下
```
category -> project -> contract -> function / event
-- Sample
Decoded projects -> uniswap_v3 -> Factory -> PoolCreated
```

一个非常实用的方法是查询`ethereum.contracts`魔法表来确认你关注的智能合约是否已经被解析。这个表存贮了所有已解析的智能合约的记录。如果查询结果显示智能合约已被解析，你就可以用上面介绍的方法在查询编辑器界面快速浏览或搜索定位到对应的智能合约的数据表列表。

[提交解析](https://dune.com/contracts/new), 可以提交任意的合约地址，但必须是有效的智能合约地址并且是可以被解析的(Dune能自动提取到其ABI代码或者你有它的ABI代码)

## 魔法表

[魔法表集合](https://spellbook-docs.dune.com/#!/overview)

魔法书（Spellbook）是一个由Dune社区共同建设的数据转换层项目。魔法（Spell）可以用来构建高级抽象表格，魔法可以用来查询诸如 NFT 交易表等常用概念数据。魔法书项目可自动构建并维护这些表格，且对其数据质量进行检测。

任何人都可以贡献魔法书中的魔法，参与方式是提交github PR，需要掌握github源代码管理库的基本使用方法。如果你希望参与贡献魔法表，可以访问[文档](https://dune.com/docs/spellbook/)

### 价格信息表

`prices.usd`和`prices.usd_latest` 

```sql
-- 每日平均价格
select date_trunc('day', minute) as block_date, contract_address, decimals, symbol, 
    avg(price) as price
from prices.usd
where blockchain = 'ethereum'
    and symbol in ('USDC', 'WETH', 'WBTC')
    and minute >= '2022-10-01'
group by 1, 2, 3, 4
order by 1
```

```sql
-- 每日最后价格
select block_date, contract_address, decimals, symbol, price
from (
select date_trunc('day', minute) as block_date, contract_address, decimals, symbol, price,
    row_number() over (partition by symbol, date_trunc('day', minute) order by minute desc) as row_num
from prices.usd
where blockchain = 'ethereum'
    and symbol in ('USDC', 'WETH', 'WBTC')
    and minute >= '2022-10-01'
)
where row_num = 1
order by block_date
```

### DeFi交易信息表

1. DeFi交易信息表`dex.trades`提供了主流DEX交易所的交易数据, 主要集合了uniswap、sushiswap、curvefi、airswap、clipper、shibaswap、swapr、defiswap、dfx、pancakeswap_trades、dodo等, 这些项目本身也有其对应的魔法表格，比如Uniswap 有uniswap.trades，CurveFi有curvefi_ethereum.trades等。

2. DEX聚合器交易表`dex_aggregator.trades`保存了来自DeFi聚合器的交易记录。这些聚合器的交易通常最终会提交到某个DEX交易所执行。单独整理到一起可以避免与`dex.trades`记录重复计算

### Tokens表

1. `tokens.erc20`表记录了各区块链上主流ERC20代币的定义信息，包括合约地址、代币符号、代币小数位数等, 由于区块链上数据都是已原始数据格式保存的，金额数值不包括小数位数，我们必须结合tokens.erc20中的小数位数才能正确转换出实际的金额数值

2. `tokens.nft`表记录了各NFT项目的基本信息，这个表的数据源目前还依赖社区用户提交PR来进行更新，可能存在更新延迟、数据不完整等问题。

### ERC代表信息表

`erc20_ethereum.evt_Transfer`和`erc721_ethereum.evt_Transfer`

ERC代币信息表分别记录了ERC20， ERC721（NFT），ERC1155等几种代币类型的批准（Approval）和转账（Transfer）记录。当我们要统计某个地址或者一组地址的ERC代币转账详情、余额等信息是，可以使用这一组魔法表。

### ENS域名信息表

ENS域名信息相关的表`ens.view_registrations`记录了ENS域名注册信息、反向解析记录、域名更新信息等。

### 标签信息表

标签信息表`labels.all`是一组来源各不相同的魔法表，允许我们将钱包地址或者合约地址关联到一个或者一组文字标签。其数据来源包括ENS域名、Safe钱包、NFT项目、已解析的合约地址等多种类型。当我们的查询中希望把地址以更直观更有可读性的方式来显示是，可以通过Dune内置的get_labels()函数来使用地址标签。

### 余额信息表

余额信息表`balances_ethereum.erc20_latest`保存了每个地址每天、每小时、和最新的ERC20， ERC721（NFT），ERC1155几种代币的余额信息。如果我们要计算某组地址的最新余额，或者跟踪这些地址的余额随时间的变化情况，可以使用这一组表。

### NFT交易信息表

NFT交易信息表`nft.trades`记录了各NFT交易平台的NFT交易数据。目前集成了opensea、magiceden、looksrare、x2y2、sudoswap、foundation、archipelago、cryptopunks、element、superrare、zora、blur等相关NFT交易平台的数据。跟DeFi交易数据类似，这些平台也各自有对应的魔法表，比如opensea.trades。当只需分析单个平台时，可以使用它特有的魔法表。

## 社区表

目前Dune上主要有`flashbots`和`reservoir`两个社区来源数据集。[Dune文档](https://dune.com/docs/tables/community/)里面分别对这两个数据集做了简介：

1. [flashbots](https://docs.flashbots.net/)表主要与Arbitrage和MEV相关
2. [reservoir](https://docs.reservoir.tools/docs)主要与NFT市场相关

## 更多

1. [https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/04_data_tables](https://sixdegreelab.gitbook.io/mastering-chain-analytics/ru-men-jiao-cheng/04_data_tables)