---
layout: post
title: "Objective-C Category的实现细节"
date: 2016-06-01
categories: Lang
tags: Lang Objective-C
excerpt: Objective-C Category可算是独门利器，不需要继承，就能够为类动态添加方法。
---

* content
{:toc}

## Category简介

Category能够添加额外的方法到已有的类中(甚至你无法访问源码的类，Framework或者第三方SDK)。后加入的方法会被子类继承，并且在运行时Category中的方法和原有类的方法是没有区别的，就仿佛原来就在那一样。

Category通常可以用来：

1. 分割一个复杂类的不同方法在不同的文件中。
2. 声明私有方法

## 热身

### Struct声明与初始化

热身代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/1a80cfb61b3b99ae41d4cf5da5ccabe0a77238d4/_code/iOS/ObjcWarmUps/ObjcWarmUps/SizingWarmUps.mm#L78-L85)

``` objc
- (void)testStrangeInit{
    static struct {
        int intvalue;
        char charValue;
    } testStruct {
        1024,
        'c'
    };

    XCTAssertEqual(testStruct.intvalue, 1024);
    XCTAssertEqual(testStruct.charValue, 'c');
}
```

### class与object的关系

见之前文章[class与object的关系]({{site.static}}/2014/02/18/objective-c-class-and-object/)

## Category注意事项
1. 你可以在Category中添加类 或者 成员方法。也可以添加`@Property`，但是Property在Category中是**失效的**，编译器**无法**帮你生成getter和setter，也**无法**添加property对应的成员变量。 可以用`@dynamic`，然后自己处理变量，getter和setter
2. Category本身新加方法可能会和已有类成员函数(父类成员函数)，或者其他Category中添加的方法**命名冲突**, 到底哪个一个函数在运行时生效，是无法确认的，所以用Category增强Framework时，要格外注意.
3. Category中的方法，和已有方法是替代关系，苹果非常不推荐用[Category来复写方法](https://stackoverflow.com/questions/5272451/overriding-methods-using-categories-in-objective-c), 理由一是没法调用被覆盖方法原有super实现，理由二是哪个方法最后生效无法确定。[参考文章]({{site.static}}/2017/09/11/objective-c-undefined/)

## Category定义

我们先看一下Category私有API[定义](https://github.com/geemaple/objc4-709/blob/bc0828f8b8e968ecae93f3c8630b0dab2533c512/runtime/objc-runtime-new.h#L1326-L1342)和开放API[定义](https://github.com/geemaple/objc4-709/blob/bc0828f8b8e968ecae93f3c8630b0dab2533c512/runtime/runtime.h#L1649-L1655)

```c++
struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
};

```

```objc
typedef struct objc_category *Category;

struct objc_category {
    char *category_name                                      OBJC2_UNAVAILABLE;
    char *class_name                                         OBJC2_UNAVAILABLE;
    struct objc_method_list *instance_methods                OBJC2_UNAVAILABLE;
    struct objc_method_list *class_methods                   OBJC2_UNAVAILABLE;
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;
}     

```

主要看出来Category有名字，所属的类，2个方法列表和协议列表

## clang重写

本文涉及代码主要在[这里](https://github.com/geemaple/geemaple.github.io/tree/master/_code/iOS/Category)

### 翻译结果

```c++
// @interface PrisonCat(CatCategory)<Catify>

// @property(nonatomic, assign)BOOL useless;

// - (void)helloThere;
// + (void)helloWorld;

/* @end */


// @implementation PrisonCat(CatCategory)

// @dynamic useless;


static void _I_PrisonCat_CatCategory_helloThere(PrisonCat * self, SEL _cmd) {
    printf("nice there\n");
}


static void _C_PrisonCat_CatCategory_helloWorld(Class self, SEL _cmd) {
    printf("nice world\n");
}


static void _I_PrisonCat_CatCategory_becomeACat(PrisonCat * self, SEL _cmd) {
    printf("pretend to be a cat\n");
}
// @end
```
可以看到@property和@dynamic在Clang重写之后，都被注视掉了

其中`_I_PrisonCat_CatCategory_helloThere`封装成method_list结构体`_OBJC_$_CATEGORY_INSTANCE_METHODS_PrisonCat_$_CatCategory`, 协议<Catify>中的方法同理

相应的`_C_PrisonCat_CatCategory_helloWorld`封装成method_list结构体`_OBJC_$_CATEGORY_CLASS_METHODS_PrisonCat_$_CatCategory`

```c++
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[2];
} _OBJC_$_CATEGORY_INSTANCE_METHODS_PrisonCat_$_CatCategory __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	2,
	{% raw %}{{(struct objc_selector *)"helloThere", "v16@0:8", (void *)_I_PrisonCat_CatCategory_helloThere},
	{(struct objc_selector *)"becomeACat", "v16@0:8", (void *)_I_PrisonCat_CatCategory_becomeACat}}{% endraw %}
};

static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[1];
} _OBJC_$_CATEGORY_CLASS_METHODS_PrisonCat_$_CatCategory __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	1,
	{% raw %}{{(struct objc_selector *)"helloWorld", "v16@0:8", (void *)_C_PrisonCat_CatCategory_helloWorld}}{ % endraw %}
};
```
同理应该能够看懂protocol_list和prop_list

```c++
static struct /*_protocol_list_t*/ {
	long protocol_count;  // Note, this is 32/64 bit
	struct _protocol_t *super_protocols[1];
} _OBJC_CATEGORY_PROTOCOLS_$_PrisonCat_$_CatCategory __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	1,
	&_OBJC_PROTOCOL_Catify
};

static struct /*_prop_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count_of_properties;
	struct _prop_t prop_list[1];
} _OBJC_$_PROP_LIST_PrisonCat_$_CatCategory __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_prop_t),
	1,
	{% raw %}{{"useless","Tc,D,N"}}{% endraw %}
};
```

### 加载组装
接下来我们看看编译器如何准备Category信息

```c++
#pragma section(".objc_inithooks$B", long, read, write)
__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CATEGORY_SETUP[] = {
	(void *)&OBJC_CATEGORY_SETUP_$_PrisonCat_$_CatCategory,
};

static void OBJC_CATEGORY_SETUP_$_PrisonCat_$_CatCategory(void ) {
	_OBJC_$_CATEGORY_PrisonCat_$_CatCategory.cls = &OBJC_CLASS_$_PrisonCat;
}

static struct _category_t _OBJC_$_CATEGORY_PrisonCat_$_CatCategory __attribute__ ((used, section ("__DATA,__objc_const"))) =
{
	"PrisonCat",
	0, // &OBJC_CLASS_$_PrisonCat,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_PrisonCat_$_CatCategory,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_PrisonCat_$_CatCategory,
	(const struct _protocol_list_t *)&_OBJC_CATEGORY_PROTOCOLS_$_PrisonCat_$_CatCategory,
	(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_PrisonCat_$_CatCategory,
};

// 最终如下：
static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
	&_OBJC_$_CATEGORY_PrisonCat_$_CatCategory,
};

```
从上到下，可以看到objc_inithooks启动初始化回调中，会将Category中的cls指向对应的类。然后完成`_OBJC_$_CATEGORY_PrisonCat_$_CatCategory`的组装，最终生成一`L_OBJC_LABEL_CATEGORY_$[1]`, 放在__DATA区域, 作为编译器，就只能帮你到这了。


### Category与Class对比

组装结果对比

class 在`L_OBJC_LABEL_CLASS_$[1]` 变量中，并拥有`__objc_classlist`属性

category 在`L_OBJC_LABEL_CATEGORY_$[1]`, 并拥有`__objc_catlist`属性

```c++
static struct _class_t *L_OBJC_LABEL_CLASS_$ [1] __attribute__((used, section ("__DATA, __objc_classlist,regular,no_dead_strip")))= {
	&OBJC_CLASS_$_PrisonCat,
};
static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
	&_OBJC_$_CATEGORY_PrisonCat_$_CatCategory,
};
```

## 源码解析

![加载断点]({{site.static}}/images/objc-runtime-image-read.jpg)

[第1步](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-os.mm#L826-L846)，libobjc.A.dylib在加载时，首先调用`_objc_init`, 然后调用`map_images, map_images_nolock, _read_images`

```c++
/***********************************************************************
* _objc_init
* Bootstrap initialization. Registers our image notifier with dyld.
* Called by libSystem BEFORE library initialization time
**********************************************************************/

void _objc_init(void)
{
    static bool initialized = false;
    if (initialized) return;
    initialized = true;

    // fixme defer initialization until an objc-using image is found?
    environ_init();
    tls_init();
    static_init();
    lock_init();
    exception_init();

    _dyld_objc_notify_register(&map_images, load_images, unmap_image);
}

```

[第2.0步](https://github.com/geemaple/objc4-709/blob/bc0828f8b8e968ecae93f3c8630b0dab2533c512/runtime/objc-runtime-new.mm#L2510-L2536) `_read_images方法中`调用 [realizeClass](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-runtime-new.mm#L1707-L1830)生成元类与类的信息，

```c++

    // Realize non-lazy classes (for +load methods and static instances)
    for (EACH_HEADER) {
        classref_t *classlist =
            _getObjc2NonlazyClassList(hi, &count);
        for (i = 0; i < count; i++) {
            Class cls = remapClass(classlist[i]);
            if (!cls) continue;

            // hack for class __ARCLite__, which didn't get this above
#if TARGET_OS_SIMULATOR
            if (cls->cache._buckets == (void*)&_objc_empty_cache  &&  
                (cls->cache._mask  ||  cls->cache._occupied))
            {
                cls->cache._mask = 0;
                cls->cache._occupied = 0;
            }
            if (cls->ISA()->cache._buckets == (void*)&_objc_empty_cache  &&  
                (cls->ISA()->cache._mask  ||  cls->ISA()->cache._occupied))
            {
                cls->ISA()->cache._mask = 0;
                cls->ISA()->cache._occupied = 0;
            }
#endif

            realizeClass(cls);
        }
    }
```

[第2.1步](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-runtime-new.mm#L2551-L2612)```_read_images`调用`addUnattachedCategoryForClass`方法，添加Catetory信息和class到一个hashtable(`NXMapTable`)中

```
// Discover categories.
    for (EACH_HEADER) {
        category_t **catlist =
            _getObjc2CategoryList(hi, &count);
        bool hasClassProperties = hi->info()->hasCategoryClassProperties();

        for (i = 0; i < count; i++) {
            category_t *cat = catlist[i];
            Class cls = remapClass(cat->cls);

            if (!cls) {
                // Category's target class is missing (probably weak-linked).
                // Disavow any knowledge of this category.
                catlist[i] = nil;
                if (PrintConnecting) {
                    _objc_inform("CLASS: IGNORING category \?\?\?(%s) %p with "
                                 "missing weak-linked target class",
                                 cat->name, cat);
                }
                continue;
            }

            // Process this category.
            // First, register the category with its target class.
            // Then, rebuild the class's method lists (etc) if
            // the class is realized.
            bool classExists = NO;
            if (cat->instanceMethods ||  cat->protocols  
                ||  cat->instanceProperties)
            {
                addUnattachedCategoryForClass(cat, cls, hi);
                if (cls->isRealized()) {
                    remethodizeClass(cls);
                    classExists = YES;
                }
                if (PrintConnecting) {
                    _objc_inform("CLASS: found category -%s(%s) %s",
                                 cls->nameForLogging(), cat->name,
                                 classExists ? "on existing class" : "");
                }
            }

            if (cat->classMethods  ||  cat->protocols  
                ||  (hasClassProperties && cat->_classProperties))
            {
                addUnattachedCategoryForClass(cat, cls->ISA(), hi);
                if (cls->ISA()->isRealized()) {
                    remethodizeClass(cls->ISA());
                }
                if (PrintConnecting) {
                    _objc_inform("CLASS: found category +%s(%s)",
                                 cls->nameForLogging(), cat->name);
                }
            }
        }
    }

    ts.log("IMAGE TIMES: discover categories");

    // Category discovery MUST BE LAST to avoid potential races
    // when other threads call the new category code before
    // this thread finishes its fixups.
```

[第2.2步](https://github.com/geemaple/objc4-709/blob/bc0828f8b8e968ecae93f3c8630b0dab2533c512/runtime/objc-runtime-new.mm#L375-L399)`remethodizeClass`方法，拿到上述category信息, 并调用`attachCategories`更新类相关信息，刷新方法缓存。

```c++
/***********************************************************************
* remethodizeClass
* Attach outstanding categories to an existing class.
* Fixes up cls's method list, protocol list, and property list.
* Updates method caches for cls and its subclasses.
* Locking: runtimeLock must be held by the caller
**********************************************************************/
static void remethodizeClass(Class cls)
{
    category_list *cats;
    bool isMeta;

    runtimeLock.assertWriting();

    isMeta = cls->isMetaClass();

    // Re-methodizing: check for more categories
    if ((cats = unattachedCategoriesForClass(cls, false/*not realizing*/))) {
        if (PrintConnecting) {
            _objc_inform("CLASS: attaching categories to class '%s' %s",
                         cls->nameForLogging(), isMeta ? "(meta)" : "");
        }

        attachCategories(cls, cats, true /*flush caches*/);        
        free(cats);
    }
}
```

[第3步](https://github.com/geemaple/objc4-709/blob/bc0828f8b8e968ecae93f3c8630b0dab2533c512/runtime/objc-runtime-new.mm#L615-L673)通过`entry.cat->methodsForMeta(isMeta);`来返回实例方法`instanceMethods或classMethods`，properties与上述类似。

最后通过attachLists将methods, properties, protocols更新到对应的类，或者元类的结构体中。

```c++
// Attach method lists and properties and protocols from categories to a class.
// Assumes the categories in cats are all loaded and sorted by load order,
// oldest categories first.
static void
attachCategories(Class cls, category_list *cats, bool flush_caches)
{
    if (!cats) return;
    if (PrintReplacedMethods) printReplacements(cls, cats);

    bool isMeta = cls->isMetaClass();

    // fixme rearrange to remove these intermediate allocations
    method_list_t **mlists = (method_list_t **)
        malloc(cats->count * sizeof(*mlists));
    property_list_t **proplists = (property_list_t **)
        malloc(cats->count * sizeof(*proplists));
    protocol_list_t **protolists = (protocol_list_t **)
        malloc(cats->count * sizeof(*protolists));

    // Count backwards through cats to get newest categories first
    int mcount = 0;
    int propcount = 0;
    int protocount = 0;
    int i = cats->count;
    bool fromBundle = NO;
    while (i--) {
        auto& entry = cats->list[i];

        method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
        if (mlist) {
            mlists[mcount++] = mlist;
            fromBundle |= entry.hi->isBundle();
        }

        property_list_t *proplist =
            entry.cat->propertiesForMeta(isMeta, entry.hi);
        if (proplist) {
            proplists[propcount++] = proplist;
        }

        protocol_list_t *protolist = entry.cat->protocols;
        if (protolist) {
            protolists[protocount++] = protolist;
        }
    }

    auto rw = cls->data();

    prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
    rw->methods.attachLists(mlists, mcount);
    free(mlists);
    if (flush_caches  &&  mcount > 0) flushCaches(cls);

    rw->properties.attachLists(proplists, propcount);
    free(proplists);

    rw->protocols.attachLists(protolists, protocount);
    free(protolists);
}
```

## Category vs. Extension

[Extension](https://github.com/geemaple/geemaple.github.io/blob/f0f34a52663cb5c04817933b821d6fa76259f789/_code/iOS/Category/Category/main.m#L23-L30)看起来和Category差不多，但其实Extension是完全不一样的东西。和Category不同，Extension必须有源码才能够可用，Extension就是类本身, 通常用来改变变量@property从readonly->readwrite, 还可以把不想公开的方法放入Extensions中。

## 总结

Extension编译器处理，组装到Class的定义中，在运行初始化时，生成类与元类。

Category由编译器处理，组装到Category的定义中，在运行初始化时，动态添加到类和元类中

## 更多

[http://blog.leichunfeng.com/blog/2015/05/18/objective-c-category-implementation-principle](http://blog.leichunfeng.com/blog/2015/05/18/objective-c-category-implementation-principle)<br/>

[https://tech.meituan.com/DiveIntoCategory.html](https://tech.meituan.com/DiveIntoCategory.html)<br/>

[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/CustomizingExistingClasses/CustomizingExistingClasses.html)<br/>
