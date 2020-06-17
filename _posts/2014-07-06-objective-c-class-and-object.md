---
layout: post
title: "Objective-C Class与Object的关系"
date: 2014-07-06
categories: ios
tags: objc object runtime
excerpt: 用了那么久的面向对象，这回我们看看对象是什么
---

## 介绍

虽然Foundation不是开源的，但苹果其实是[开源社区的主力军之一](https://opensource.apple.com/)，这回我们主要研究Objective-C中的类与对象，其历史源码在[这里](https://opensource.apple.com/tarballs/objc4/), 这里我修改了一个[709版本](https://github.com/geemaple/objc4-709)，你可以拿过去直接运行

## 热身

### Struct And Union

如果把Struct看成高铁座位，那每个乘客, 都有自己的位置，并且有足够舒适的空间(即对齐和补全)

Union可以看成高铁的一个洗手间，可以容纳任意乘客，通常一次只能一个人使用

[更详细的可以参考之前的文章](https://geemaple.github.io/2014/02/18/C-Data-Sizes-Reference/)

## class和object

在Objc源码Public Headers中[runtime.h](https://github.com/geemaple/objc4-709/blob/master/ClassObject/ClassObject.h#L55-L70)和[objc.h](https://github.com/geemaple/objc4-709/blob/master/runtime/objc.h#L36-L47)可以找到class和object的定义

```c++

/* OBJC_ISA_AVAILABILITY: `isa` will be deprecated or unavailable
 * in the future */
#if !defined(OBJC_ISA_AVAILABILITY)
#   if __OBJC2__
#       define OBJC_ISA_AVAILABILITY  __attribute__((deprecated))
#   else
#       define OBJC_ISA_AVAILABILITY  /* still available */
#   endif
#endif

struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;
    const char *name                                         OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;

struct objc_object {
    objc_class *isa  OBJC_ISA_AVAILABILITY;
};

typedef struct objc_class *Class; //类的定义
typedef struct objc_object *id; //对象的定义
```
可以看出凡是带有isa结构的，就是objc中的对象，其中类Class也包含isa，所以类也是一个对象。[block也是对象](https://geemaple.github.io/2014/08/17/objective-c-block-learning/)，运行时可以通过isa指针，查找到该对象是属于什么类

接下来我们看看Project Headers中的相关定义，代码比较长，就只粘贴了部分在这里
[objc-runtime-new.h](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-runtime-new.h#L1064-L1305)和[objc-private.h](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-private.h#L168-L275)

```c++
union isa_t
{
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    uintptr_t bits;
    // ...
}

struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
    //...
}
```

其中`struct objc_object`中多了一个Union isa_t, isa_t中可以传入一个unsigned long类型初始化，同时union可以转成Class cls, 苹果在Objective-C 2.0中试图模糊isa的存在，这样多了一层封装，并且isa也被OBJC_ISA_AVAILABILITY废弃，禁止直接访问了

另外一点是objc_class也是对象，是因为它继承了objc_object

## clang重写

```c++
static void OBJC_CLASS_SETUP_$_CatAnimal(void ) {
	OBJC_METACLASS_$_CatAnimal.isa = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_CatAnimal.superclass = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_CatAnimal.cache = &_objc_empty_cache;
	OBJC_CLASS_$_CatAnimal.isa = &OBJC_METACLASS_$_CatAnimal;
	OBJC_CLASS_$_CatAnimal.superclass = &OBJC_CLASS_$_NSObject;
	OBJC_CLASS_$_CatAnimal.cache = &_objc_empty_cache;
}

static void OBJC_CLASS_SETUP_$_PrisonCat(void ) {
	OBJC_METACLASS_$_PrisonCat.isa = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_PrisonCat.superclass = &OBJC_METACLASS_$_CatAnimal;
	OBJC_METACLASS_$_PrisonCat.cache = &_objc_empty_cache;
	OBJC_CLASS_$_PrisonCat.isa = &OBJC_METACLASS_$_PrisonCat;
	OBJC_CLASS_$_PrisonCat.superclass = &OBJC_CLASS_$_CatAnimal;
	OBJC_CLASS_$_PrisonCat.cache = &_objc_empty_cache;
}

#pragma section(".objc_inithooks$B", long, read, write)
__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CLASS_SETUP[] = {
	(void *)&OBJC_CLASS_SETUP_$_CatAnimal,
	(void *)&OBJC_CLASS_SETUP_$_PrisonCat,
};

```

当`objc_inithooks`启动回调时，程序会组装isa和superclass的关系, 可以看出isa关系:

```c++
isa: PrisonCat -> PrisonCat(meta) -> NSObject(meta)
isa: CatAnimal -> CatAnimal(meta) -> NSObject(meta)
```

通过运行时函数`objc_getMetaClass`，`objc_getClass`，`class_isMetaClass`，`class_getSuperclass`得到如下superclass关系，具体代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ClassObject/ClassObject/main.m)

```C++
superclass: PrisonCat < CatAnimal < NSObject < nil
superclass: PrisonCat[meta] < CatAnimal[meta] < NSObject[meta] < NSObject < nil
```

最后通过如下摘抄源码[objc-runtime-new.h](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-runtime-new.h#L1235-L1240)可以画出一个类的关系图

```c++
    bool isRootClass() {
        return superclass == nil;
    }
    bool isRootMetaclass() {
        return ISA() == (Class)this;
    }
```

![类的关系图]({{site.static}}/images/Objc_object_class_meta_relations.jpg)

## 更多
[https://blog.ibireme.com/2013/11/25/objc-object/](https://blog.ibireme.com/2013/11/25/objc-object/)
