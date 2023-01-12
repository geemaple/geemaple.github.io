---
layout: post
title: "OpenGL环境设置"
date: 2023-01-05
categories: Graphics
tags: OpenGL
excerpt: 设置OpenGL环境，显示窗口，处理窗口缩放与键盘事件
---

* content
{:toc}

## OpenGL介绍

发布年份: 1992

OpenGL是图形技术标准，主要用来硬件加速，由[Khronos Group](https://www.khronos.org/)维护。

OpenGL只定义了输入输出，具体实现通常由显卡厂商完成，所以经常更新显卡驱动，会解决一些Bug, 新特性使用Extensions来拓展

根据WIKI百科，OpenGL已经不再活跃更新(主要精力在Vulkan)，目前大概2-3年一个版本。

学习OpenGL的原因是短时间不会消失，跨平台，版本稳定，相对容易学习

### Vulkan

发布年份: 2016

| OpenGL | Vulkan |
| ----------- | ----------- |
| One single global state machine | Object-based with no global state |
| State is tied to a single context | All state concepts are localized to a command buffer |
| Operations can only be executed sequentially | Multi-threaded programming is possible |
| GPU memory and synchronization are usually hidden	| Explicit control over memory management and synchronization |
| Extensive error checking | Vulkan drivers do no error checking at runtime; there is a validation layer for developers |

由表对比，可以看出Vulkan, 去掉了全局状态机，支持多线程、内存与同步控制，无运行错误检测。

英伟达说，因为OpenGL相比Vulkan简单维护成本低，大部分场景性能不错，所以OpenGL仍然是个不错的选择

AMD说，Vulkan支持接近硬件级别的控制，更高的性能，更好的画质。Vulkan在系统兼容，功能，和效率上都数一数二

### [Metal](https://developer.apple.com/videos/play/wwdc2018/604/)

发布年份: 2014

OpenGL出现时最高性能的显卡也是单核的，并没有考虑多核处理，比如全局状态机的使用，不支持多线程操作，异步处理等。

## [GLFW](https://www.glfw.org/)

OpenGL只负责画画，具体的窗口创建不同的操作系统也不大一样，GLFW提供一致的创建窗口和事件响应等功能

### option 1
```
brew install glfw
# 编译安装 brew install -s glfw
```

添加```/opt/homebrew/Cellar/glfw/3.3.8/include```到 ```Build Phase > Header Search Paths```
添加'''libglfw.3.3.dylib''' 到 ```Build Phase->Link Binary with libraries```

### option 2

```
curl https://github.com/glfw/glfw/releases/download/3.3.8/glfw-3.3.8.zip -O
unzip glfw-3.3.8.zip
```

buid with cmake
```
brew install cmake
cd glfw-3.3.8
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_OSX_ARCHITECTURES=arm64 .
make
make install 
# DESTDIR可以用来指定位置 make install DESTDIR=./install
```

## [GLAD](https://github.com/Dav1dde/glad)

```
浏览器访问: https://glad.dav1d.de/
C++
GL Version 3.3
Profile Core
Generate a loader
```

需要把glad.h放在header search里面，glad.c放到工程里面

## 创建窗口

![结果]({{site.static}}/images/opengl-lesson-01-result.png)

工程使用的是静GLFW态库, 支持x86_64和arm架构
```
cmake "-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64" .
```
此外，Framework需要IOKit和Cocoa

PS: 系统升级13.1突然编译不过了，默认的Xcode初始程序也同样错误，重新安装好了，24G的Xcode也不知道抽啥风

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_01_window.cpp)

## 更多

1. [https://learnopengl.com/Introduction](https://learnopengl.com/Introduction)
2. [http://www.opengl-tutorial.org/miscellaneous/building-your-own-c-application/](http://www.opengl-tutorial.org/miscellaneous/building-your-own-c-application/)