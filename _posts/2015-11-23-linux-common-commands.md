---
layout: post
title: "CentOS7之常用命令"
date:   2015-11-23
categories: linux
tags: shell
excerpt: Linux服务系常用命令
---

* content
{:toc}

## 介绍

Linux常用命令收集

## 查看Linux信息？
`cat /proc/version`
![Linux_cmd_proc_version]({{site.static}}/images/Linux_cmd_proc_version.png)

`uname -a`
![Linux_cmd_uname]({{site.static}}/images/Linux_cmd_uname.png)

`lsb_release -a`

## 查看CPU信息？
`cat /proc/cpuinfo`
![Linux_cmd_proc_cpuinfo]({{site.static}}/images/Linux_cmd_proc_cpuinfo.png)

`lscpu`
![Linux_cmd_lscpu_0]({{site.static}}/images/Linux_cmd_lscpu_0.png)
![Linux_cmd_lscpu_1]({{site.static}}/images/Linux_cmd_lscpu_1.png)

## 查看内存信息
`free -h`
![Linux_cmd_free]({{site.static}}/images/Linux_cmd_free.png)

## 查看磁盘信息
`df -h`
![Linux_cmd_df]({{site.static}}/images/Linux_cmd_df.png)



## ps输出详解
`ps ax` === `ps -e`

根据不同的习惯常用的有以下两种:
`ps aux`
![Linux_cmd_ps_0]({{site.static}}/images/Linux_cmd_ps_0.png)

`ps -ef`
![Linux_cmd_ps_1]({{site.static}}/images/Linux_cmd_ps_1.png)

`USER` – 用户名
`%cpu` - CPU轮训时间占用比
`%MEM` - 内存利用比
`PID` – 当前进程ID
`PPID` - 父进程ID
`VSZ` - 虚拟内存大小
`RSS` - 物理内存大小
`TTY` - 控制终端
`START` - 开始运行时间
`TIME` - 累计利用CPU时间
`STAT` - 如下列表  
 - D 无法唤醒深眠(通常为IO)
 - R 执行中
 - S 可唤醒睡眠(等待某个信号唤醒)
 - T 被作业控制停止
 - t 被调试暂停
 - X 挂了
 - Z 僵尸

 - < 高优先级执行
 - N 低优先级执行
 - L 已加载内存，并锁定(程序总要加载到内存的嘛，锁定以防止内存被其他进程误用)
 - s 进程组的第一进程
 - l 多线程
 - \+ 前台执行

## ls输出详解
`ls -l`命令输出如下
![Linux_cmd_ls]({{site.static}}/images/Linux_cmd_ls.png)

以第一行为例:

    -rw-r--r--   1 dean  admin   3.1K Apr 21 14:39 CODEOFCONDUCT.md

字符: -
 -表示文件
 d表示目录

字符: rw-r--r--
 rwx分别表示可以读，可以写，可以执行，
 rw- 所有者用读(r)和写(w)的权限,没有执行(-)权限
 r-- 所属组只有(r)的权限
 r-- 其他人只有(r)的权限

字符: 1
 表示当前文件或文件夹拥有的链接数＋文件夹里面的链接(或目录)数
 当前只是一个Markdown文件，链接数位1
 若空文件夹连接数默认2，包含(. ..)两个目录

字符: dean
 表示文件所属人

字符: admin
 表示文件所属的组

字符: 3161(3.1k)
 文件大小

字符: Apr 21 14:39
 最后更新时间

字符: CODEOFCONDUCT.md
 文件或目录名
