---
layout: post
title: "ObjC - Class与Object的关系"
categories: Macintosh
tags: Objective-C
excerpt: 苹果用尽全力，隐藏ISA
---

* content
{:toc}

## 介绍

虽然Foundation不是开源的，但苹果其实是[开源社区的主力军之一](https://opensource.apple.com/)，这回我们主要研究Objective-C中的类与对象，其历史源码在[这里](https://opensource.apple.com/tarballs/objc4/), 写文章是版本是709版本, 旧版的重写文件还仍有保留

## Class&Object定义

在Objc源码Public Headers中`runtime.h`和`objc.h`可以找到class和object的定义

```cpp
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

苹果在Objective-C 2.0中试图模糊isa的内容，这样多了一层封装，并且isa也被OBJC_ISA_AVAILABILITY废弃，禁止直接访问了

接下来我们看看Project Headers中的相关定义，代码比较长，就只粘贴了部分在这里`objc-runtime-new.h`和`objc-private.h`

```cpp
typedef unsigned long uintptr_t;
typedef struct objc_class *Class;
typedef struct objc_object *id;

union isa_t
{
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    uintptr_t bits;
    // ...
}

struct objc_object {
private:
    isa_t isa;

public:
    ...
}

struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
    //...
}

struct protocol_t : objc_object {
    ...
}

Class object_getClass(id obj) {
    if (obj) return obj->getIsa();
    else return Nil;
}
```

其中**struct objc_object**中多了一个**Union isa_t**, isa_t中有两个构造函数其中**bits**和**cls**只能用其中一个

objc_class, protocol_t都继承了objc_object, 可以看出凡是带有isa结构的，就是objc中的对象. protocl也是对象，运行时可以通过isa指针，查找到该对象是属于什么类

## Clang重写

苹果已经更新到866.9，转写代码大不相同，很多isa信息隐藏的更好，自定义类略有修改，当时[Clang转写C++的代码](https://github.com/geemaple/learning/blob/main/learn_objc/class_object/old_clang_rewrite_main.cpp)

```cpp
// 类定义
struct _class_t {
	struct _class_t *isa;
	struct _class_t *superclass;
	void *cache;
	void *vtable;
	struct _class_ro_t *ro;
};

// 类定义的一部分
struct _class_ro_t {
	unsigned int flags;
	unsigned int instanceStart;
	unsigned int instanceSize;
	unsigned int reserved;
	const unsigned char *ivarLayout;
	const char *name;
	const struct _method_list_t *baseMethods;
	const struct _objc_protocol_list *baseProtocols;
	const struct _ivar_list_t *ivars;
	const unsigned char *weakIvarLayout;
	const struct _prop_list_t *properties;
};

// 实例
typedef struct objc_object PrisonCat;

// 父类
extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;
extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_CatAnimal __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_NSObject,
	0, // &OBJC_METACLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_METACLASS_RO_$_CatAnimal,
};

extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_NSObject;
extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_CatAnimal __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_CatAnimal,
	0, // &OBJC_CLASS_$_NSObject,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_CLASS_RO_$_CatAnimal,
};
static void OBJC_CLASS_SETUP_$_CatAnimal(void ) {
	OBJC_METACLASS_$_CatAnimal.isa = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_CatAnimal.superclass = &OBJC_METACLASS_$_NSObject;
	OBJC_METACLASS_$_CatAnimal.cache = &_objc_empty_cache;
	OBJC_CLASS_$_CatAnimal.isa = &OBJC_METACLASS_$_CatAnimal;
	OBJC_CLASS_$_CatAnimal.superclass = &OBJC_CLASS_$_NSObject;
	OBJC_CLASS_$_CatAnimal.cache = &_objc_empty_cache;
}

// 子类
extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;
extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_PrisonCat __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_NSObject,
	0, // &OBJC_METACLASS_$_CatAnimal,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_METACLASS_RO_$_PrisonCat,
};

extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_CatAnimal;
extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_PrisonCat __attribute__ ((used, section ("__DATA,__objc_data"))) = {
	0, // &OBJC_METACLASS_$_PrisonCat,
	0, // &OBJC_CLASS_$_CatAnimal,
	0, // (void *)&_objc_empty_cache,
	0, // unused, was (void *)&_objc_empty_vtable,
	&_OBJC_CLASS_RO_$_PrisonCat,
};
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

## Root判断源码

最后通过如下摘抄源码`objc-runtime-new.h`可以画出一个类的关系图

```cpp
bool isRootClass() {
		return superclass == nil;
}
bool isRootMetaclass() {
		return ISA() == (Class)this;
}
```

## 代码验证

通过运行时函数(**object_getClass**，**class_isMetaClass**，**class_getSuperclass**得到如下关系

[测试代码](https://github.com/geemaple/learning/blob/main/learn_objc/class_object/main.m)运行如下:

```
isa: Kitty := PrisonCat := PrisonCat[meta] := NSObject[meta] := NSObject[meta] := ...
superclass: PrisonCat => CatAnimal => NSObject => nil 
superclass: PrisonCat[meta] => CatAnimal[meta] => NSObject[meta] => NSObject => nil
```

![类的关系图]({{site.static}}/images/objc-object-class-meta-relations.jpg)

首先，只看绿色的父类箭头，在OC中一切基类都是NSObject, NSObject没有父类

其次, **isRootMetaclass**使用了并查集的根节点判断, 也就是说**meta class**都属于同一个集合. 且**NSObject[meta]**为并查集的跟节点


## 更多
[https://blog.ibireme.com/2013/11/25/objc-object/](https://blog.ibireme.com/2013/11/25/objc-object/)
