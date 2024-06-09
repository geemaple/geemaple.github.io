---
layout: post
title: "CentOS7之常用服务"
date:   2015-12-17
categories: OS
tags: Linux
excerpt: CentOS7之常用服务收集
---

* content
{:toc}

## 介绍

我是一个前端工程师，对于后端还算是个新手，下面是我手机的一些关于[阿里云](https://promotion.aliyun.com/ntms/act/ambassador/sharetouser.html?userCode=c2dmplih&utm_source=c2dmplih)Centos7使用的一些工具，希望对你有帮助。

## 开发者工具
```sh
# 安装gcc, g++, make, git, svn
yum clean all
yum groups mark install "Development Tools"
yum groups mark convert "Development Tools"
yum groupinstall "Development Tools"

#选择安装(相关库的头文件)
yum install python-devel libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libxslt-devel libxml2-devel libjpeg-turbo-devel
```

## EPEL源
```sh
sudo yum install epel-release
```

## 任务管理器

```sh
#需要EPEL源

sudo yum install ncdu  #磁盘大小查看
sudo yum install htop atop #内存，CPU实用
sudo yum install iotop #磁盘使用IO
sudo yum install iftop #网络
```

## Node.js:
    #需要EPEL源

    sudo yum install nodejs

## Python语言

### [pip](https://pip.pypa.io/en/stable/installing/)

```sh
#安装pip
$ wget https://bootstrap.pypa.io/get-pip.py
$ python ./get-pip.py
```

### [pyenv](https://github.com/yyuu/pyenv-installer)

```sh
# 安装pyenv
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

>然后你需要把以下内容粘贴到[~/.bash_profile]文件中

# pyenv
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

### [pyenv-virtualenvwrapper](https://github.com/pyenv/pyenv-virtualenvwrapper)

```sh
    #安装pyenv-virtualenvwrapper
    git clone https://github.com/yyuu/pyenv-virtualenvwrapper.git ~/.pyenv/plugins/pyenv-virtualenvwrapper

    #安装virtualenvwrapper
    sudo pip install virtualenvwrapper

    >然后你需要把以下内容粘贴到~/.bash_profile文件中

    #pyenv virtualenvwrapper
    pyenv virtualenvwrapper_lazy
```

## 文件传输

语法: scp 用户名@地址:{from} {to}

```sh
scp sirius@54.174.51.64:/home/sirius/articles.csv .
scp ./articles.csv sirius@54.174.51.64:/home/sirius/
```

## [nginx服务](http://nginx.org/en/linux_packages.html#stable)

```sh
# 下载nginx到/tmp
curl -o /tmp/nginx.rpm http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

# 安装rpm, 此rpm包含yum配置信息
rpm -ivh /tmp/nginx.rpm  

# 安装nginx
yum install nginx

# 2选1, 启动nginx服务, 此时访问公有IP, 就能看到欢迎页面了
systemctl start nginx
service nginx start

# 配置文件位置/etc/nginx/nginx.conf
```   

## [mongoDB数据库](https://docs.mongodb.org/v3.0/tutorial/install-mongodb-on-red-hat/)

```sh
# 1. 创建/etc/yum.repos.d/mongodb-org-3.0.repo文件内容如下:
[mongodb-org-3.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=1

# 2.运行
sudo yum install -y mongodb-org
```


## [MySQL](https://www.linode.com/docs/databases/mysql/how-to-install-mysql-on-centos-7)
**安装**

```sh
sudo yum update

wget http://repo.mysql.com//mysql57-community-release-el7-8.noarch.rpm
sudo rpm -ivh mysql57-community-release-el7-8.noarch.rpm
sudo yum update

sudo yum install mysql-server
```

**启动** `sudo systemctl start mysqld`

**临时密码** `sudo grep 'temporary password' /var/log/mysqld.log`

**安全配置** `sudo mysql_secure_installation`

**用户与表权限**

```sh
 create database testdb;
 create user 'testuser'@'localhost' identified by 'password';
 grant all on testdb.* to 'testuser' identified by 'password';
```

**重置密码**

```sh
sudo systemctl stop mysqld
sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"
sudo systemctl start mysqld

mysql -u root

use mysql;
update user SET PASSWORD=PASSWORD("password") WHERE USER='root';
flush privileges;
exit

sudo systemctl stop mysqld
sudo systemctl unset-environment MYSQLD_OPTS
sudo systemctl start mysqld
```

## [Scrapyd](https://github.com/scrapy/scrapyd)

```sh
sudo pip install pyOpenSSL
sudo pip install lxml
sudo pip install scrapyd
```

## [PM2](http://pm2.keymetrics.io/):

```sh
# 正常启动Express项目，也就是
cd <项目目录>
npm start` 或者 `node main.js

# 使用pm2启动
cd <项目目录>
pm2 start npm --name='express' -- start
```

#### [其他语言](http://pm2.keymetrics.io/docs/usage/quick-start/#cheat-sheet):

**python命令:**
```sh
scrapyd --pidfile /var/log/scrapyd/twistd.pid -l /var/log/scrapyd/logs/scrapyd.log
```

**pm2命令:**
```sh
pm2 start scrapyd --interpreter python --name=scrapyd -- --pidfile "/var/log/scrapyd/twistd.pid" -l "/var/log/scrapyd/logs/scrapyd.log"
```

## [docker](https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce)

```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce

# start
sudo systemctl start docker

# test
sudo docker run hello-world
```
