---
layout: post
title: "Mac上python环境配置"
date:   2014-01-23
categories: python
tags: mac python
excerpt: Life is short, I use python
---

> Life is short, I use python

[pyenv][1]用来管理多个版本的python在用户目录的安装和使用, 类似rbenv

###[pyenv与pyenv-virtualenvwrapper][2]:

```sh
brew install pyenv pyenv-virtualenvwrapper

> 然后你需要把以下内容粘贴到~/.bash_profile文件中
# pyenv
PYENV_ROOT="$HOME/.pyenv"
PATH="/usr/local/opt/python/libexec/bin:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

#pyenv virtualenvwrapper
pyenv virtualenvwrapper_lazy

> 最后
source ~/.bash_profile
```

###安装python

```sh
CFLAGS="-I$(brew --prefix openssl)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib" \
pyenv install 3.7.0

pyenv rehash
```

###设置使用python版本

```sh
//这里不推荐使用系统默认版本(即system), 默认版本在用virtualenvwrapper会报错

pyenv global 3.7.0
```

###[pyenv与homebrew冲突解决][3]

```sh
#添加到上述文件中
#pyenv not playing nice with homebrew
alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"
```

##pyenv基本用法
1.安装python
```sh
pyenv install 3.7.0
pyenv rehash
```

2.删除python
```sh
pyenv uninstall 3.7.0
```

3.查看已安装版本
```sh
pyenv versions
```

4.查看当前使用版本
```sh
pyenv version
```

##virtualenvwrapper基本用法
__之前记得重新启动下Terminal, 使上面配置生效__

1.创建一个(虚拟?)开发环境

```sh
mkvirtualenv testing
workon testing
```

2.装一些听都没听过的依赖包(前面的括号里面会显示你现在用哪一个环境的)

```sh
pip install tensorflow
```

3.用的不爽删了就是了
```sh
deactivate #或者切换到其他python虚拟环境中
rmvirtualenv testing
```




  [1]: https://github.com/yyuu/pyenv
  [2]: https://segmentfault.com/a/1190000004162295#articleHeader1
  [3]: https://github.com/yyuu/pyenv/issues/106
