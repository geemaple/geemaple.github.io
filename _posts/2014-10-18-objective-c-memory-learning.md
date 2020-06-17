---
layout: post
title: "Objective-C 内存管理"
date: 2014-10-18
categories: ios
tags: objc memory
excerpt: Objective-C 内存管理MRC和ARC
---

## 介绍

这是一本不错的书籍《Pro Multithreading and Memory Management
 for iOS and OS X》，推荐阅读，已经二刷

## 旧时代MRC(-fno-objc-arc)

Objective-C内存管理叫引用计数(Reference Counting)， 当一个新建实例RC=1, retain操作RC加1， release操作，RC减1。 一旦RC等于0, 实例被销毁，你无法再retain抢救回来

```objc
    NSObject *testObject = [[NSObject alloc] init];
    NSLog(@"%p", &testObject);
    [testObject release];
    [testObject retain];
    NSLog(@"%@", [testObject description]);
    [testObject class];
```
运气好，你能编译执行过，但是强烈不推荐这样做.

MRC经常会出现，错误实例release， 或者release过度的情况，直接导致程序崩溃。

还有就是MRC暴露的NSAutoreleasePool对象，如果调用`[pool autorelease]`, 会产生`NSInvalidArgumentException`

相关测试[代码](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/MRCWarmUPs.m)

## ARC时代(-fobjc-arc)

> By enabling ARC with the new Apple LLVM compiler, you will never need to type retain or release again, dramatically simplifying the development process, while reducing crashes and memory leaks. The compiler has a complete understanding of your objects, and releases each object the instant it is no longer used, so apps run as fast as ever, with predictable, smooth performance.

从Xcode4.2起, ARC作为默认选项。ARC把MRC时代的`reretain, release`交给编译器。并简化了代码，减少潜在出错的可能性。

### 循环引用
{{site.static}}
![Objc_circular_reference]({{site.static}}/images/Objc_circular_reference.png)

在iOS5或者OSX Lion之后，可以用__weak关键字，来打破这样的循环引用，如果之前，可以用__unsafe_unretained

```objc
id __strong obj0 = [[NSObject alloc] init];
id __weak obj1 = obj0;
```

### \_\_weak关键字

2个无文档开放API, runtime调用，如果函数内包含runtime代码可能会死锁。
```objc
//是否允许使用__weak, 如果NO, 在使用__weak时SIGABRT崩溃
- (BOOL)allowsWeakReference UNAVAILABLE_ATTRIBUTE;

//是否允许使用__weak, 如果NO, 对象无法访问
- (BOOL)retainWeakReference UNAVAILABLE_ATTRIBUTE;
```


\_\_weak关键字在运行时主要调用[objc_initWeak](https://github.com/geemaple/objc4-709/blob/master/runtime/NSObject.mm#L425-L463)和[objc_destroyWeak](https://github.com/geemaple/objc4-709/blob/master/runtime/NSObject.mm#L466-L482), 可以看下两个函数都调用了[storeWeak](https://github.com/geemaple/objc4-709/blob/master/runtime/NSObject.mm#L290-L387), 在weak结束使用时，`objc_destroyWeak`传入nil值，并在StripedMap中将对应地址的指向为nil

```objc

id
objc_initWeak(id *location, id newObj)
{
    if (!newObj) {
        *location = nil;
        return nil;
    }

    return storeWeak<DontHaveOld, DoHaveNew, DoCrashIfDeallocating>
        (location, (objc_object*)newObj);
}

void
objc_destroyWeak(id *location)
{
    (void)storeWeak<DoHaveOld, DontHaveNew, DontCrashIfDeallocating>
        (location, nil);
}
```

通常，\_\_weak关键字除了`objc_initWeak`和`objc_destroyWeak `之外，相当于`__strong`加上`autoreleasepool`。这样能够保证接下来的函数执行后，再释放掉对象。

好的习惯是减少\_\_weak的使用，这样会减少`objc_initWeak, objc_destroyWeak, storeWeak的调用次数`，基本上都是为了解决循环引用问题。\_\_weak声明后通常会再用\_\_strong转变一下。

第一，可以减少对象重复加入autoreleasepool。

第二，也能够保证多线程的时候，在进入执行前，\_\_strong能够阻止中途被释放掉的情况。例如[AFNetworking](https://github.com/AFNetworking/AFNetworking/blob/f51f0b8533e1e5d549ef718eed60f7637f249d41/AFNetworking/AFNetworkReachabilityManager.m#L209-L218)

```objc
id __weak obj1 = obj;
[obj1 description];

id tmp = objc_loadWeakRetained(&obj1);
objc_autorelease(tmp);
```

### \_\_autorelease关键字

ARC下我们无法调用`NSAutoreleasePool, autorelease`，取而代之的是可以用 `@autoreleasepool {}, __autoreleasing`，但实际使用中，甚至`__autoreleasing`也很少用到。编译器会检查函数调用赋值情况，以及函数名是否一个函数带有alloc/new/copy/mutableCopy，如果没有，会自动加入到autoreleasePool中。

另一种情况是__weak指向的变量，会自动加入到autoreleasePool中。

还有一种就是id * (例如NSError **），也会自动加入到autoreleasePool中。

```objc
# 编译出错
NSError *error = nil;
NSError **pError = &error;
```
当赋值pointer的时候，ARC关键字必须一样

```objc
NSError *error0 = nil;
NSError *__strong *pError0 = &error0;

NSError __weak *error1 = nil;
NSError *__weak *pError1 = &error1;

NSError __unsafe_unretained *error2 = nil;
NSError *__unsafe_unretained *pError2 = &error2;

NSError __autoreleasing *error3 = nil;
NSError *__autoreleasing *pError3 = &error3;
```

## C++/C与ARC
如果你要在struct中，使用id，你需要使用\_\_unsafe_unretained安抚编译器。

```objc
struct Data {
	NSMutableArray __unsafe_unretained *array;
};
```

相关测试[代码](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/ARCWarmUps.m)

在ARC中id和void *之间，必须使用到转换, \_\_bridge可以使其转换

```objc
- (void)testBridgeCasting{
    id array = [[NSMutableArray alloc] init]; //strong +1
    CFMutableArrayRef cfArray = (__bridge CFMutableArrayRef)array; //do nothing

    CFShow(cfArray);
    XCTAssertEqual(CFGetRetainCount(cfArray), 1);
    XCTAssertEqual(_objc_rootRetainCount(array), 1);
} //array -1
```

CoreFoundation和Foundation中很多的Object区别非常少，例如一个由Foundation创建的object，可以由CoreFoundation释放，反之亦然。

```c++
NS_INLINE CF_RETURNS_RETAINED CFTypeRef _Nullable CFBridgingRetain(id _Nullable X) {
    return (__bridge_retained CFTypeRef)X;
}

NS_INLINE id _Nullable CFBridgingRelease(CFTypeRef CF_CONSUMED _Nullable X) {
    return (__bridge_transfer id)X;
}
```

\_\_bridge_retained

```objc
- (void)testBridgeRetainCasting{
    id array = [[NSMutableArray alloc] init]; //strong +1

    CFMutableArrayRef cfarry_normal = (__bridge CFMutableArrayRef)array; //do nothing
    XCTAssertEqual(CFGetRetainCount(cfarry_normal), 1);
    XCTAssertEqual(_objc_rootRetainCount(array), 1);

    CFMutableArrayRef cfArray_retain = (__bridge_retained CFMutableArrayRef)array; // retain +1
    XCTAssertEqual(CFGetRetainCount(cfArray_retain), 2);
    XCTAssertEqual(_objc_rootRetainCount(array), 2);

    CFRelease(cfArray_retain);

} //array -1

```

\_\_bridge_transfer

```objc
- (void)testBridgeTransferCasting{

    CFMutableArrayRef cfArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL); // +1
    XCTAssertEqual(CFGetRetainCount(cfArray), 1);

    NSMutableArray *array  = (__bridge NSMutableArray *)cfArray; //strong +1
    XCTAssertEqual(CFGetRetainCount(cfArray), 2);
    XCTAssertEqual(_objc_rootRetainCount(array), 1);
    [array description];

    array = (__bridge_transfer NSMutableArray *)cfArray; // strong 放弃原值 -1 strong 加入新值 +1 transfer -1

    XCTAssertEqual(CFGetRetainCount(cfArray), 1);
    XCTAssertEqual(_objc_rootRetainCount(array), 1);
    [array description];
}// array -1
```

## 测试工具

```objc
extern void _objc_autoreleasePoolPrint(); //这是个私有API
extern int _objc_rootRetainCount(id); //这是个私有API
```
