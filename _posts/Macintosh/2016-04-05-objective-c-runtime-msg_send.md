---
layout: post
title: "ObjC - 消息和转发机制"
categories: Macintosh
tags: ObjC
excerpt: Objective-C消息分发，拦截与转发机制。
---

* content
{:toc}

## 介绍

本文介绍[objc](https://github.com/apple-oss-distributions/objc4)公开接口message.h中的所有API, 涉及测试代码在[这里](https://github.com/geemaple/learning/tree/main/learn_objc/unit_test/objc_msgSend)

## 消息发送

### msgSend

1. 汇编实现, 不同CPU架构有对应版本。该组函数拥有不同返回类型，这么多应该是为了优化。

```cpp
// 普通的应该是返回int和指针类型
void objc_msgSend(void /* id self, SEL op, ... */ )
void objc_msgSendSuper(void /* struct objc_super *super, SEL op, ... */ )

/*
 * On some architectures, use objc_msgSend_stret for some struct return types.
 * On some architectures, use objc_msgSend_fpret for some float return types.
 * On some architectures, use objc_msgSend_fp2ret for some float return types.
*/ 
```

### 方法定义

```cpp
// These functions must be cast to an appropriate function pointer type before being called
#if !OBJC_OLD_DISPATCH_PROTOTYPES
typedef void (*IMP)(void /* id, SEL, ... */ ); ✅
#else
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...); 
#endif
```


测试代码如下，`objc_msgSend`参数和返回值只是占位用的，实际要转成对应的方法具体类型

```objc
- (void)testMsgSend {
    Human *instance = [[Human alloc] init];
    NSString *result = ((NSString *(*)(id, SEL, NSString *))objc_msgSend)(instance, @selector(say:), @"Hello");
    XCTAssertTrue([result isEqualToString:@"Hello"]);
}
```

### 动态添加

```objc
@interface HumanAddMethod: NSObject
- (NSString *)say:(NSString *)content;
@end

NSString * say(id self, SEL selector, NSString *msg){
    return [NSString stringWithFormat:@"%@", msg];
}

@implementation HumanAddMethod
- (instancetype)init{
    if(self = [super init]){
        const char *types = [[NSString stringWithFormat:@"%s%s%s%s", @encode(NSString *), @encode(id), @encode(SEL), @encode(NSString *)] UTF8String];
        NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:types];
        NSLog(@"💚 types=%s args= %lu rlength= %s rtype=%lu isOneway=%@", types, (unsigned long)sig.numberOfArguments, sig.methodReturnType, (unsigned long)sig.methodReturnLength, sig.isOneway ? @"YES": @"NO");
        
        for (int i = 0; i < sig.numberOfArguments; i++) {
            NSLog(@"    - %d arg type = %s", i, [sig getArgumentTypeAtIndex:i]);
        }
        
        class_addMethod([self class], @selector(say:), (IMP)say, types);
    }
    return self;
}
@end
```

## 消息转发

```cpp
void _objc_msgForward(void /* id receiver, SEL sel, ... */ )

```


若消息发送失败，这进入消息转发，流程如下

1. **Dynamic Method Resolution**： `resolveClassMethod:`和`resolveInstanceMethod`, 若返回YES同时运行时状态有新函数注册，则直接调用实现，完成消息发送. 否则
2. **Message Forwarding**:  `forwardingTargetForSelector:` 若返回不是nil和self，则完成消息发送，否者
3. **Message Forwarding**:  `methodSignatureForSelector:` 若返回不为空，则发送消息给`forwardInvocation:`由Invocation完成, 否则
4. **抛出异常** : 调用`doesNotRecognizeSelector:`抛出异常

```
💚 1. resolveInstanceMethod called say:
💚 2. forwardingTargetForSelector called say:
💚 3. methodSignatureForSelector called say:
💚 1. resolveInstanceMethod called say:
💚 1. resolveInstanceMethod called _forwardStackInvocation:
💚 3. forwardInvocation called <NSInvocation: 0x6000018bc480>
```

### 动态解析

```objc
- (NSString *)say:(NSString *)content;
@end

@implementation HumanResolve
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(say:)) {
        const char *types = [[NSString stringWithFormat:@"%s%s%s%s", @encode(NSString *), @encode(id), @encode(SEL), @encode(NSString *)] cStringUsingEncoding:NSUTF8StringEncoding];
        class_addMethod([self class], sel, (IMP)say, types);
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
@end
```

### 转发1
```objc
@interface HumanForwardTarget: NSObject{
    Dog *_surrogate;
}
- (NSString *)say:(NSString *)content;
@end

- (instancetype)init {
    if (self) {
        _surrogate = [[Dog alloc] init];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSLog(@"💚 1. resolveInstanceMethod called %@", NSStringFromSelector(sel));
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    return _surrogate;
}
@end
```

### 转发2

```objc
@interface HumanForwardInvocation: NSObject{
    Cat *_surrogate;
}
- (NSString *)say:(NSString *)content;
@end

@implementation HumanForwardInvocation

- (instancetype)init {
    if (self) {
        _surrogate = [[Cat alloc] init];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSLog(@"💚 1. resolveInstanceMethod called %@", NSStringFromSelector(sel));
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"💚 2. forwardingTargetForSelector called %@", NSStringFromSelector(aSelector));
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"💚 3. methodSignatureForSelector called %@", NSStringFromSelector(aSelector));
    if ([_surrogate respondsToSelector:aSelector]) {
        return [_surrogate methodSignatureForSelector:aSelector];
    } else {
        return [super methodSignatureForSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"💚 3. forwardInvocation called %@", [anInvocation description]);
    if ([_surrogate respondsToSelector: [anInvocation selector]]){
        [anInvocation invokeWithTarget:_surrogate];
    }
    else{
        [super forwardInvocation:anInvocation];
    }
}
@end
```

### 抛出异常

`doesNotRecognizeSelector`是运行时找不到对应的SEL(方法)最后调用的函数，在NSObject里实现, 虽然注释写着已经改为CF实现，但是不影响我们学习，其内部实现主要是抛出`NSInvalidArgumentException`异常。这也是iOS常见的崩溃原因之一。
```objc
// Replaced by CF (throws an NSException)
+ (void)doesNotRecognizeSelector:(SEL)sel {
    _objc_fatal("+[%s %s]: unrecognized selector sent to instance %p", 
                class_getName(self), sel_getName(sel), self);
}

// Replaced by CF (throws an NSException)
- (void)doesNotRecognizeSelector:(SEL)sel {
    _objc_fatal("-[%s %s]: unrecognized selector sent to instance %p", 
                object_getClassName(self), sel_getName(sel), self);
}
```

## 方法调用

如果有两个参数object和method. method_invoke可以调用，从搜索来看，主要用在KVO中

```cpp
// Using this function to call the implementation of a method is faster than calling method_getImplementation and method_getName.
void method_invoke(void /* id receiver, Method m, ... */ ) 
```

没测试出来稳定的速度对比，结果都很快百万次0.3秒，姑且相信文档说的`method_invoke`更快吧

```objc
- (void)testMethodInvoke{
    
    Human *instance = [[Human alloc] init];
    Method method = class_getInstanceMethod([instance class], @selector(say:));
    
    uint64_t start = mach_absolute_time();
    
    NSString * result = ((NSString*(*)(id, Method, NSString*))method_invoke)(instance, method, @"Hello");
    NSLog(@"invoke = %llul", mach_absolute_time() - start);
    XCTAssertTrue([result isEqualToString:@"Hello"]);
    
    [self measureBlock:^{
        for (int i = 0; i < self.times; i++) {
            NSString *result __attribute__((unused)) = ((NSString*(*)(id, Method, NSString*))method_invoke)(instance, method, @"Hello");
        }
    }];
}

- (void)testImpAndSel {
    Human *instance = [[Human alloc] init];
    Method method = class_getInstanceMethod([instance class], @selector(say:));
    
    uint64_t start = mach_absolute_time();

    
    NSString *(*function)(id, SEL, NSString *) = (NSString *(*)(id, SEL, NSString *))method_getImplementation(method);
    SEL selecor = method_getName(method);
    NSString * result = function(instance, selecor, @"Hello");
    NSLog(@"iml&sel = %llul", mach_absolute_time() - start);
    
    XCTAssertTrue([result isEqualToString:@"Hello"]);
    [self measureBlock:^{
        for (int i = 0; i < self.times; i++) {
            NSString *(*function)(id, SEL, NSString *) = (NSString *(*)(id, SEL, NSString *))method_getImplementation(method);
            SEL selecor = method_getName(method);
            NSString *result __attribute__((unused)) = function(instance, selecor, @"Hello");
        }
    }];
}
```

## 更多
[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtDynamicResolution.html](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtDynamicResolution.html)<br/>

[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW1](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW1)

[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100)