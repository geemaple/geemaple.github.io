---
layout: post
title: "Objective-C/C++/C 未定义"
date: 2017-09-10
categories: iOS
tags: objc undefined
excerpt: 本文收集一些Objective-C/C++/C undefined behavior
---

## 介绍

本文收集一些undefined behavior, 加上自己的测试观察。未完待续。。。

因为是undefined behavior，千万不要出现在自己的项目中

## Category命名冲突

Category的函数命名冲突时，原有类会被覆盖，具体哪个Category实现，与编译顺序和文件顺序有关, 运行结果是"TestingTwo sayhi"

### 文件顺序

```objc
@interface ExistingClass:NSObject
- (void)sayHi;
@end

@implementation ExistingClass
- (void)sayHi{ printf("ExistingClass sayhi");}
@end

@interface ExistingClass(TestingOne)
- (void)sayHi;
@end

@implementation ExistingClass(TestingOne)
- (void)sayHi{ printf("TestingOne sayhi");}
@end


@interface ExistingClass(TestingTwo)
- (void)sayHi;
@end

@implementation ExistingClass(TestingTwo)
- (void)sayHi{ printf("TestingTwo sayhi");}
@end

```

### 编译顺序

目录结构如下

```objc
- Category
  - ExistingMultiFileClass.h
  - ExistingMultiFileClass.m
  - ExistingMultiFileClass+TestingOne.h
  - ExistingMultiFileClass+TestingOne.m
  - ExistingMultiFileClass+TestingTwo.h
  - ExistingMultiFileClass+TestingTwo.m
```

文件内容与上面代码一致，但是为了不冲突，改了下类的名字, 这个时候结果是"TestingOne sayhi", 测试代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/UndefinedWarmUps.m),调整一下编译顺序Xcode->Build Phases, 你会发现测试结果会不一样

## Category冲突特例+Load
//TODO
