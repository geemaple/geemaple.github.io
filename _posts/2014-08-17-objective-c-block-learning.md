---
layout: post
title: "Objective-C Block的实现细节"
date: 2014-08-17
categories: ios
tags: obj-c block closure
excerpt: 用Clang重写功能，我们来和Block谈一场恋爱
---

## 介绍

> 看源码比较烧脑, 请仔细阅读热身内容再继续

2009年，Mac OS X 10.6雪豹更新了许多好用的底层技术，其中包括GCD和Block。虽然[苹果文档](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html#//apple_ref/doc/uid/TP40011210-CH8-SW1)对于使用来说解释的已经很好。但对于理解Block，文档远远不够，我们需要从另一个角度来入手，抛弃堆和栈，理解什么是匿名函数，闭包，如何捕获变量，__block关键字的作用等等。

以下是苹果文档，重要的关键字已加粗显示：

> Blocks are a **language-level feature** added to C, Objective-C and C++, which allow you to create distinct segments of code that can be passed around to methods or functions as if they were values. Blocks are **Objective-C objects**, which means they can be added to collections like NSArray or NSDictionary. They also have the ability to **capture values** from the enclosing scope, making them **similar to closures or lambdas** in other programming languages.

## 热身

1. Target选择BlockTesting，进行热身单元测试
2. Target选择Block，进行Clang重写

### 本文涉及测试代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/BlockWarmUps.mm)

### 热身1：函数指针 vs. Block语法

> 一起记忆会方便很多

``` objc
//函数指针
int add(int x, int y){
    return x + y;
}

int (*addFun)(int, int) = add;
printf("%d\n", addFun(1, 100));

//block语法
int (^addFun)(int, int) = ^(int x, int y){
        return x + y;
    };
printf("%d\n", addFun(1, 100));
```
### 热身2：传值 vs. 传引用

> 这个对理解__block很有帮助

``` c++
int a = 1, b = 2;

// swap(a, b);
// int x = a, y = b;
void swap(int x, int y)
{
    int tmp = x;
    x = y;
    y = tmp;
}

// swap(&a, &b);
// int *x = &a, *y = &b
void swap(int *x, int *y)
{
    int tmp = *x;
    *x = *y;
    *y = tmp;
}
```

### 热身3：无限循环引用

> 好好玩玩吧，有趣且十分有用的东西

``` c++
typedef struct circular{
    struct circular *__forwarding;
    int value = 0;
} circular;

// 单元测试通过
- (void)testingCircular{
    circular c = {&c, 0};
    XCTAssertEqual(c.__forwarding->__forwarding->__forwarding->__forwarding->__forwarding->__forwarding->value, 0); //这里可以写任意个
    c.value += 1;
    XCTAssertEqual(c.__forwarding->value, 1);
    c.__forwarding->__forwarding->__forwarding->value += 1;
    XCTAssertEqual(c.__forwarding->__forwarding->value, 2);
}

```

### 热身4: One More Thing

注释的代码，目前木筏编译通过。

```objc
//    const char text1[] = "hello";
//    
//    void (^blk1)(void) = ^{
//        printf("%c\n", text1[2]);
//    };

    const char *text2 = "hello";

    void (^blk2)(void) = ^{
        printf("%c\n", text2[2]);
    };
```

## Clang重写

我在Xcode Target=Block里面配置了Build Phases->Run Script:
```sh
clang -rewrite-objc $SRCROOT/Block/main.m -o $SRCROOT/Block/main.cpp
```
如果你用我的代码，只需要用Xcode打开Run(CMD+R)一下就可以了

``` objc
// 源代码，这里用printf，重写后看起来回少些干扰
int main(int argc, const char * argv[]) {
    void (^hello)(void) = ^{
        printf("hello world\n");
    };
    hello();
    return 0;
}
```

打开Xcode中main.cpp, 滑倒最后，这样比较容易看


``` cpp
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
	printf("hello world\n");
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main(int argc, const char * argv[]) {
    void (*hello)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
    ((void (*)(__block_impl *))((__block_impl *)hello)->FuncPtr)((__block_impl *)hello);
    return 0;
}
```

1. 首先, 查看[Runtime源码](https://github.com/geemaple/objc4-709/blob/master/runtime/objc-private.h)第168行，我们发现__block_impl和objc_object具有相同的变量isa，虽然类型不同，但是结合文档说Block也是对象，isa应该具有相类似的结构，必要时可以强制转换。
2. 查看`__main_block_func_0`函数，这是我们Block源码中的具体实现，其中函数名`__main_block_func_0`以序号0开始递增。这里我们注意函数名在没有参数传入时需要调用self，
如果你对面向对象熟悉，那么每一个实例都是有隐藏参数self的
3. 在看`__main_block_impl_0`创建的过程，这里用的是Struct同名[构造函数](https://stackoverflow.com/questions/1127396/struct-constructor-in-c)，其中传入两个参数，第一个即`__main_block_func_0`函数，第二个是Block的描述.
4. 看hello变量的定义可以看出，变量hello是一个无参数函数指针，但其实赋值的时候是一个Objective-C对象，即`__main_block_impl_0`结构体。接下来调用的时候有一个奇怪的地方，为什么少了一步，而不是调用`hello->impl->FuncPtr`呢?
5. 因为Struct的地址实际上就是Struct[第一个元素的地址](https://stackoverflow.com/questions/7312555/in-c-does-a-pointer-to-a-structure-always-point-to-its-first-member), 所以这里hello = hello->impl

## __block关键字

除了 __block关键字，你也可以用全局变量来达到改变原值的效果。

```objc
//源代码
int main(int argc, const char * argv[]) {
    int constNum = 100;
    __block int varNum = 200;

    varNum = varNum + 1;

    void (^theBlock)(int) = ^(int var1){
        printf("%d, %d %d\n", constNum, varNum, var1);
        varNum = 2;
        var1 = 3;
    };

    theBlock(404);
    return 0;
}
```

```c++
struct __Block_byref_varNum_0 {
  void *__isa;
__Block_byref_varNum_0 *__forwarding;
 int __flags;
 int __size;
 int varNum;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int constNum;
  __Block_byref_varNum_0 *varNum; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _constNum, __Block_byref_varNum_0 *_varNum, int flags=0) : constNum(_constNum), varNum(_varNum->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself, int var1) {
  __Block_byref_varNum_0 *varNum = __cself->varNum; // bound by ref
  int constNum = __cself->constNum; // bound by copy

        printf("%d, %d %d\n", constNum, (varNum->__forwarding->varNum), var1);
        (varNum->__forwarding->varNum) = 2;
        var1 = 3;
    }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->varNum, (void*)src->varNum, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->varNum, 8/*BLOCK_FIELD_IS_BYREF*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

int main(int argc, const char * argv[]) {
    int constNum = 100;
    __attribute__((__blocks__(byref))) __Block_byref_varNum_0 varNum = {(void*)0,(__Block_byref_varNum_0 *)&varNum, 0, sizeof(__Block_byref_varNum_0), 200};

    (varNum.__forwarding->varNum) = (varNum.__forwarding->varNum) + 1;

    void (*theBlock)(int) = ((void (*)(int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, constNum, (__Block_byref_varNum_0 *)&varNum, 570425344));

    ((void (*)(__block_impl *, int))((__block_impl *)theBlock)->FuncPtr)((__block_impl *)theBlock, 404);
    return 0;
}
```
1. 与普通变量不同，这里`int varNum`已经是一个__Block_byref_varNum_0对象了，真实的值是最后传递的。既然是对象就可以retain，以防止被释放掉。注意`__main_block_desc_0`中多了copy和dispose操作，
2. Block会自动捕获外部的变量，第一个变量以正常方式传入，第二个变量以指针方式传入，并且以固定数字570425344结尾, 这个数字应该是一个哨兵对象，证明之后没有其他值再拷贝了(参考热身2)。
3. 我们在外部做了一个+1的操作，可以看出，varNum已经不是普通的int了，而是用一个指针，指向对象内部的一个变量值，本来+1的操作可以用`varNum.varNum = varNum.varNum + 1`来进行，猜测是为了保持Block内外的一致性。(参考热身3)
4. 最后来看看，指针是怎么传递的，首先真实的值是在结构体`__Block_byref_varNum_0`最后一个int varNum中，而被__block修饰的varNum已经是一个结构体。真实的值在varNum.__forwarding->varNum中(又或者varNum.varNum中)。接下来在创建`__main_block_func_0`时传入&varNum, 在实现内部`varNum(_varNum->__forwarding)`(即`varNum = _varNum->__forwarding`)。最后在调用真实`__main_block_func_0`函数时`varNum = __cself->varNum`, 然后假装什么都没发生，和外部调用一样使用(参考热身3)。

## 循环引用

 1. 你可以用__weak关键字，来打破循环引用。
 2. 或者可以用__block关键字，然后再合适的时候把处于循环引用中的一个变量=nil

更多内存细节，可以参考另一篇[文章](https://geemaple.github.io/2014/10/18/objective-c-memory-learning/)

## block copy

Block类型 | COPY来源 | 结果
------- | :------: | :------:
\_NSConcreteStackBlock | Stack | 拷贝到Heap
\_NSConcreteGlobalBlock | data区 | 什么都不做
\_NSConcreteMallocBlock | Heap | 引用计数+1

当block作为参数时，通常需要手动拷贝。两种情况例外Cocoa framework和GCD

## lambda和closure

```python
map(lambda x: x * x, [1, 2, 3, 4, 5, 6, 7, 8, 9])
```
lambda是python中的匿名函数，以lambda为关键字，冒号前边表示变量，冒号后只能有一个表达式，并将表达式运算结果作为return结果。代码中map是一个高阶函数，其作用是将数组[1, 2, 3, 4, 5, 6, 7, 8, 9]中的每一个元素, 传入匿名函数中，并返回数组结果[1, 4, 9, 16, 25, 36, 49, 64, 81]


```python
def calc_sum(lst):
    def lazy_sum():
        return sum(lst)
    return lazy_sum
```

闭包(closure): 内层函数引用了外层函数的变量（参数也算变量），然后返回内层函数的情况, 称作闭包。 Objective-C不支持高阶函数(函数嵌套，函数作为另一个函数参数等)，也即是说不支持闭包，但是Block在一定程度上祢补了这种缺陷

## 总结

1. Block是匿名函数，它只封装了相应的函数与上下文环境，而不需要知道其相关函数名称。但如果赋值给一个变量，那该Block多了一个别名
2. Block是一个对象，包含封装函数，和对应的需要拷贝的变量
3. __block改变了普通的变量，使其可以用指针指向，达到改变其值的目的。类的实例变量是对象的地址，地址是```int```类型，也是普通变量
4. 如果Block引用了外部函数的变量，则形成闭包

## 更多

[https://techtalk.intersec.com/2014/11/blocks-rewriting-with-clang/](https://techtalk.intersec.com/2014/11/blocks-rewriting-with-clang/)<br/>

[https://clang.llvm.org/docs/Block-ABI-Apple.html](https://clang.llvm.org/docs/Block-ABI-Apple.html)
