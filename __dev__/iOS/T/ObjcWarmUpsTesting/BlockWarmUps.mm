//
//  BlockWarmUps.m
//  BlockWarmUps
//
//  Created by dean on 9/6/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <iostream>

//C++
size_t t;

typedef struct circular{
    struct circular *__forwarding;
    int value;
    circular(struct circular *ptr, int v){
        __forwarding = ptr;
        value = v;
    }
} circular;

typedef struct point {
    float x;
    float y;
} points;

void swap(int x, int y)
{
    int tmp = x;
    x = y;
    y = tmp;
}

void swap(int *x, int *y)
{
    int tmp = *x;
    *x = *y;
    *y = tmp;
}

void reverse(point p){
    int tmp = p.x;
    p.x = p.y;
    p.y = tmp;
}

void reverse(point *p){
    int tmp = p->x;
    p->x = p->y;
    p->y = tmp;
}

@interface ObjcWarmUpsTests : XCTestCase

@end

@implementation ObjcWarmUpsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValueSwap {
    // 测试传值, a与b没有交换
    int a = 1, b = 2;
    swap(a, b);
    XCTAssertEqual(a, 1);
    XCTAssertEqual(b, 2);
}

- (void)testPointerSwap {
    // 测试穿指针, a与b可以交换
    int a = 1, b = 2;
    swap(&a, &b);
    XCTAssertEqual(a, 2);
    XCTAssertEqual(b, 1);
}

- (void)testingStructValue{
    // 测试结构体传值，不能改变原数据
    point p = {1, 2};
    reverse(p);
    XCTAssertEqual(p.x, 1);
    XCTAssertEqual(p.y, 2);
}

- (void)testingStructPointer{
    // 测试结构题传引用，可以改变原数据
    point p = {1, 2};
    reverse(&p);
    XCTAssertEqual(p.x, 2);
    XCTAssertEqual(p.y, 1);
}

- (void)testingCircular{
    // 测试无限循环引用
    circular c = {&c, 0};
    circular *p = &c;
    // __forwarding可以任意个
    XCTAssertEqual(p->__forwarding->__forwarding->__forwarding->__forwarding->__forwarding->value, 0);
    c.value += 1;
    XCTAssertEqual(p->__forwarding->value, 1);
    p->__forwarding->__forwarding->__forwarding->value += 1;
    XCTAssertEqual(p->__forwarding->__forwarding->value, 2);
}

- (void)testCompile{
    
//  这段代码无法辩
//    const char text1[] = "hello";
//    
//    void (^blk1)(void) = ^{
//        printf("%c\n", text1[2]);
//    };
    
    const char *text2 = "hello";
    
    void (^blk2)(void) = ^{
        printf("%c\n", text2[2]);
    };
    
    blk2();
}

- (void)testBLockCopy{
    
    // 与书中说的不同，NSArray中的对象，不用在主动调用copy
    NSArray *testing = [[NSArray alloc] initWithObjects:[^{printf("hello world");} copy], ^{printf("hello");}, nil];
    void (^blk)(void) = testing[0];
    blk();
    
    blk = testing[1];
    blk();
}

@end

