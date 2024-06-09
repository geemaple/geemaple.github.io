---
layout: post
title: "CentOS7之新建用户与SSH登陆"
date:   2015-10-05
categories: OS
tags: Linux
excerpt: 初次接触阿里云服务器，登陆设置，SWAP创建，磁盘挂在
---

* content
{:toc}

## 介绍

最近Openshift2也不好用了， 而且Openshift2在2017年09月30号就要停止维护了。所以看看阿里云，竟然有3年=800元的优惠价，外面世界那么大，没有梯子怎么行, 所以果断买了美国西部地区[ECS 1核1GB](https://promotion.aliyun.com/ntms/act/ambassador/sharetouser.html?userCode=c2dmplih&utm_source=c2dmplih)。

## 登录云服务器
```sh
# 选择一: 账号密码登录
ssh -q root@公用IP地址
然后输入密码(提示linux密码，没有长度＊＊＊＊提示)

# 选择二：秘钥登录
ssh -i 公用秘钥文件路径 root@公用IP地址
```

## [创建SWAP文件](https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-swap-adding.html):

1GB内存实在是不够大，有些库无法正常安装。

方法一，创建虚拟内存SWAP

方法二，在好的机器上编译好，再上传到与服务器

```sh
#创建2G文件
sudo dd if=/dev/zero of=/swapfile bs=1048576 count=2048

#更改权限
sudo chmod 600 /swapfile

#设置swapfile
sudo mkswap /swapfile

#使生效
sudo swapon /swapfile

#文件/etc/fstab加入以下内容，开机自动挂载：
/swapfile swap swap defaults 0 0
```

## 挂载云硬盘
>刚开始逗比的把云硬盘挂在到/user/上，结果重装系统了，后来挂在到/home

```sh
# 与习惯的图形界面系统不同，硬盘需要挂载到文件结构下，通常新建一个目录/mydata，然后将硬盘挂载到/mydata下面

df -h    # 查看系统磁盘空间使用情况, 用来看挂在点
fdisk -l # 查看当前分区表，用来查看数据盘相关信息

fdisk /dev/vdb # 开始分区
按照界面的提示，依次输入“n”(新建分区)、“p”(新建扩展分区)、“1”(使用第1个主分区)，两次回车(使用默认配置)，输入“w”(保存分区表)，开始分区

mkfs.ext3 /dev/vdb1  # 对新分区进行格式化(系统盘用的就是ext3)
mount /dev/vdb1 /mydata   # 因为此时除了root没有任何其他用户，／home下没有数据

将”/dev/vdb1 /mydata ext3 defaults 0 0“写入/etc/fstab   # 如果希望云服务器在重启或开机时能自动挂载数据盘
```    

## [如何添加和删除用户](https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-a-centos-7-server)

    此时，服务器中只有一个root用户，问题是root用户权限过高，一不小心的错误更改将会影响整个系统，所以我需要一个新的用户，起名叫sirius,密码Sirius123

    adduser sirius           # 添加一个新用户，名字叫Sirius
    passwd sirius            # 设置用户密码
    gpasswd -a sirius wheel  # 给予sudo权限, 当权限不够时，可以用sudo
    lid -g wheel             # 查询所有带sudo权限的用户


    userdel -r sirius        # 删除用户和相应的目录

### [生成public&private key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) 和 [设置用户SSH登录](https://wiki.centos.org/HowTos/Network/SecuringSSH)

```sh
⚠️重新登录切换到sirius用户

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

SSH设置保存在 /etc/ssh/sshd_config

Protocol 2 # 使用2.0协议    
PermitRootLogin no # 阻止root用户登陆
AllowUsers sirius  # 允许制定用户使用SSH登陆
PasswordAuthentication no # 阻止用户密码SSH登陆⚠️⚠️⚠️如果设置no，证书还没配置对，你就登陆不上了，哈哈?‍♂️

添加id_rsa.pub内容到 /home/sirius/.ssh/authorized_keys
⚠️.ssh权限755
⚠️ authorized_keys权限544

service sshd restart  # 重启服务，是配置生效
```

## 彩蛋时间
### ssh配置
⚠️config权限600, 在文件`~/.ssh/config`你个一配置，这样使用ssh的时候方便很多，省去了-i，-P参数

```sh
Host 54.174.51.64
  IdentityFile /Users/felix/Developer/some_rsa
  IdentityFile /Users/felix/Developer/other_rsa
  Port 41414
```

### 翻墙
如果你的服务器能够访问外网，就可以用来翻墙，这里面我们用到的是[ssh port forwarding](https://www.bitvise.com/port-forwarding).

```sh
ssh -NCD 0.0.0.0:10024 用户名@服务器地址
```

这样你就有了一个socket proxy 地址:127.0.0.1 端口:10024

### 消除本地设置警告
```sh
warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory

添加以下内容到/etc/environment

LANG=en_US.utf8
LC_CTYPE=en_US.utf8
```

## 更多
[https://wiki.centos.org/HowTos/Network/SecuringSSH](https://wiki.centos.org/HowTos/Network/SecuringSSH)<br/>
