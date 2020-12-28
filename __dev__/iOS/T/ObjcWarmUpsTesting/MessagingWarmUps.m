//
//  MessagingWarmUps.m
//  MacUnitTesting
//
//  Created by dean on 9/8/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <objc/objc.h>

NSString * hello(id self, SEL selector, NSString *content){
    return [NSString stringWithFormat:@"%@", content];
}

@interface TestClassAddMethod: NSObject
- (NSString *)hello:(NSString *)content;
@end

@implementation TestClassAddMethod
- (instancetype)init{
    if(self = [super init]){
        class_addMethod([self class], @selector(hello:), (IMP)hello, "@@:@"); //@=id :=sel
    }
    return self;
}
@end

// ------------------------------------------

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

// ------------------------------------------
@interface TestClassResolve: NSObject
- (NSString *)hello:(NSString *)content;
@end

@implementation TestClassResolve
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(hello:)) {
        class_addMethod([self class], sel, (IMP)hello, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
@end

// ------------------------------------------

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

// ------------------------------------------

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


@interface MessagingWarmUps : XCTestCase

@end

@implementation MessagingWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDynamicAddFunctions{
    TestClassAddMethod *instance = [[TestClassAddMethod alloc] init];
    XCTAssertTrue([[instance hello:@"hello self"] isEqualToString:@"hello self"]);
}

- (void)testDynamicFakeResolve{
    TestClassFakeResolve *instance = [[TestClassFakeResolve alloc] init];
    XCTAssertThrowsSpecificNamed([instance doesNotRecognizeSelector:@selector(hello:)], NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed([instance hello:@"hello self"], NSException, NSInvalidArgumentException);
}

- (void)testDynamicResolveFunctions{
    TestClassResolve *instance = [[TestClassResolve alloc] init];
    XCTAssertTrue([[instance hello:@"hello self"] isEqualToString:@"hello self"]);
}

- (void)testDynamicForwardingTarge{
    TestClassForwardTarget *instance = [[TestClassForwardTarget alloc] init];
    XCTAssertTrue([[instance hello:@"hello self"] isEqualToString:@"hello self"]);
}

- (void)testDynamicForwardingInvocation{
    TestClassForwardInvocation *instance = [[TestClassForwardInvocation alloc] init];
    XCTAssertTrue([[instance hello:@"hello self"] isEqualToString:@"hello self"]);
}

@end
