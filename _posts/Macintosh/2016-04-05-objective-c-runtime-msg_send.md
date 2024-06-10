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

> 这是之前[《死磕Objective-C runtime运行》](https://segmentfault.com/a/1190000007446208)的重写。还是延续问答的方式，日期复用当时的日期，并加入测试代码

本文涉及测试代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ObjcWarmUps/ObjcWarmUps/MessagingWarmUps.m)

## 问题1: 说一说objc_msgSend方法

**Message**: 消息, 即`objc_msgSend`和`objc_msgSendSuper`

> These functions must be cast to an appropriate function pointer type before being called

> Sends a message with a simple return value to an instance of a class.
When it encounters a method call, the compiler generates a call to one of the functions objc_msgSend, objc_msgSend_stret, objc_msgSendSuper, or objc_msgSendSuper_stret. Messages sent to an object’s superclass (using the super keyword) are sent using objc_msgSendSuper; other messages are sent using objc_msgSend. Methods that have data structures as return values are sent using objc_msgSendSuper_stret and objc_msgSend_stret.

这里复用上一遍文章[代码](https://github.com/geemaple/geemaple.github.io/blob/master/_code/iOS/ClassObject/ClassObject/main.m)

其中主要摘抄如下：
```objc
- (instancetype)init{
    if(self = [super init]){
        //因为PrisonCat没有覆盖class方法，所以调用self和super结果是一样的，如果把下面class注释去掉，cls = super_cls就不一样了
        Class cls = [self class];
        Class super_cls = [super class];
        printf("place holder");
    }
    return self;
}

//- (Class)class{
//    return objc_getClass("NSObject");
//}
```

Clang重写之后：

```cpp
static instancetype _I_PrisonCat_init(PrisonCat * self, SEL _cmd) {
    if(self = ((PrisonCat *(*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("PrisonCat"))}, sel_registerName("init"))){
        Class cls = ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"));
        Class super_cls = ((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("PrisonCat"))}, sel_registerName("class"));
        printf("place holder");
    }
    return self;
}
}
```

从文档和转意代码来看，objective-c消息发送(方括号语法)主要靠objc_msgSend和objc_msgSendSuper来实现。

其中[self class]通过`objc_msgSend `

其中[super class]通过和`class_getSuperclass `和`objc_msgSendSuper`

对于不同构架和返回函数，struct返回值用到`objc_msgSend_stret`， float返回值用到`objc_msgSend_fpret`或`objc_msgSend_fp2ret`

相应的，对于super，struct返回值用到`objc_msgSendSuper`


## 问题2: objc_msgSend失败了会怎么样
1. **Dynamic Method Resolution**： `resolveClassMethod:`和`resolveInstanceMethod`, 若返回YES同时运行时状态有新函数加入，则直接调用实现，完成消息发送
2. **Message Forwarding**: 若不然, `forwardingTargetForSelector:` 若返回不是nil和self，则完成消息发送
3. **Message Forwarding**: 若不然, `methodSignatureForSelector:` 若返回不为空，则发送消息给`forwardInvocation:`由Invocation完成
4. **NSInvalidArgumentException** : 若不然, 调用`doesNotRecognizeSelector:`抛出异常



### class_addMethod测试

class_addMethod最后的参数参考[文档](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100)

```objc
@interface TestClassAddMethod: NSObject
- (NSString *)hello:(NSString *)content;
@end

NSString * hello(id self, SEL selector, NSString *content){
    return [NSString stringWithFormat:@"%@", content];
}

@implementation TestClassAddMethod
- (instancetype)init{
    if(self = [super init]){
        class_addMethod([self class], @selector(hello:), (IMP)hello, "@@:@"); //@=id :=sel
    }
    return self;
}
@end
```

### 假的resolveMethod测试

即使`resolveInstanceMethod`返回YES, 若没有该方法，直接回调用doesNotRecognizeSelector，抛出异常

```objc
@interface TestClassFakeResolve: NSObject
- (NSString *)hello:(NSString *)content;
@end

@implementation TestClassFakeResolve
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(hello:)) {
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
@end
```
![ios_messaging_fake_resolve]({{site.static}}/images/ios_messaging_fake_resolve.jpg)

![ios_messaging_fake_resolve_crash]({{site.static}}/images/ios_messaging_fake_resolve_crash.jpg)

### 正常resolveMethod测试
```objc
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(hello:)) {
        class_addMethod([self class], sel, (IMP)hello, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
```

### forwardingTargetForSelector测试

```objc
@interface TestClassForwardTarget: NSObject{
    TestClassAddMethod *_surrogate;
}
- (NSString *)hello:(NSString *)content;
@end

@implementation TestClassForwardTarget

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSLog(@"resolveInstanceMethod called");
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (!_surrogate) {
        _surrogate = [[TestClassAddMethod alloc] init];
    }
    return _surrogate;
}

@end
```

### forwardInvocation测试
```objc
@interface TestClassForwardInvocation: NSObject{
    TestClassAddMethod *_surrogate;
}
- (NSString *)hello:(NSString *)content;
@end

@implementation TestClassForwardInvocation

- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"forwardingTargetForSelector called");
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{

    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if (!_surrogate) {
            _surrogate = [[TestClassAddMethod alloc] init];
        }

        signature = [_surrogate methodSignatureForSelector:aSelector];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    if ([_surrogate respondsToSelector: [anInvocation selector]]){
        [anInvocation invokeWithTarget:_surrogate];
    }
    else{
        [super forwardInvocation:anInvocation];
    }
}
@end
```

PS: 至于调用顺序，就只能用断点来查看了。

## 问题3: 说一说doesNotRecognizeSelector方法

`doesNotRecognizeSelector`是运行时找不到对应的SEL(方法)最后调用的函数，在NSObject里实现, 虽然注释写着已经改为CF实现，但是不影响我们学习，其内部实现主要是抛出`NSInvalidArgumentException`异常。这也是iOS常见的崩溃原因之一。
```objc
// Replaced by CF (throws an NSException)
- (void)doesNotRecognizeSelector:(SEL)sel {
    _objc_fatal("-[%s %s]: unrecognized selector sent to instance %p",
                object_getClassName(self), sel_getName(sel), self);
}
```

## 更多
[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtDynamicResolution.html](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtDynamicResolution.html)<br/>

[https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW1](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW1)
