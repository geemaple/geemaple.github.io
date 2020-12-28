//
//  SizingWarmUps.m
//  ObjcWarmUpsTests
//
//  Created by dean on 9/7/17.
//  https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html#//apple_ref/doc/uid/TP40013501-CH2-SW1
//  Copyright © 2017 dean. All rights reserved.
//


#import <XCTest/XCTest.h>
#include <algorithm>
#include <initializer_list>
#include <iostream>
#include <Kernel/sys/_types.h>

void (*simpleFunctionPtr)(void);

void simpleFunction(){
    printf("hello world");
}

char * functionWithParamAndReturn(char * msg){
    return msg;
}

struct aEmptyStruct{};
union aEmptyUnion{};

struct aEmptyStructWithConstructor{
    aEmptyStructWithConstructor(){}
};

union aEmptyUnionWIthConstructor{
    aEmptyUnionWIthConstructor(){}
};

struct aSimpleStruct{
    char charValue;
    short shortValue;
};

struct aSimplePointerStruct{
    int * pointerValue;
    char charValue;
    short shortValue;
};


union aSimpleUnion{
    char charValue;
    short shortValue;
};

union aSimplePointerUnion{
    int * pointerValue;
    char charValue;
    short shortValue;
};


@interface SizingWarmUps : XCTestCase

@end

@implementation SizingWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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

- (void)testBasicDataSize{
    
    XCTAssertEqual(sizeof(char), 1);
    XCTAssertEqual(sizeof(bool), 1);
    XCTAssertEqual(sizeof(short), 2);
    XCTAssertEqual(sizeof(int), 4);
    XCTAssertEqual(sizeof(float), 4);
    XCTAssertEqual(alignof(float), 4);
    XCTAssertEqual(sizeof(double), 8);
    XCTAssertEqual(alignof(double), 8);
#if __LP64__
    XCTAssertEqual(sizeof(long), 8);
    XCTAssertEqual(sizeof(long long), 8);
    XCTAssertEqual(sizeof(int *), 8);
#else
    XCTAssertEqual(sizeof(long), 4);
    XCTAssertEqual(sizeof(long long), 8);
    XCTAssertEqual(sizeof(int *), 4);
#endif
}

- (void)testFunctionPointerSize{
    // 测试函数指针，与指针大小
    int sizeOfVoidFunction = sizeof(&simpleFunction);
    int sizeofParamAndReturnFunction = sizeof(&functionWithParamAndReturn);
    XCTAssertEqual(sizeOfVoidFunction, sizeOfVoidFunction);
    XCTAssertEqual(sizeOfVoidFunction, sizeofParamAndReturnFunction);
}

- (void)testEmptyStructSizeAndUnion{
    // 测试空Struct和Union大小
    int sizeOfEmptyStruct = sizeof(aEmptyStruct);
    int sizeOfEmptyUnion = sizeof(aEmptyUnion);
    XCTAssertEqual(sizeOfEmptyStruct, 1);
    XCTAssertEqual(sizeOfEmptyUnion, 1);
    
    // 测试Struct Union构造函数对大小没有影响
    XCTAssertEqual(sizeOfEmptyUnion, sizeof(aEmptyUnionWIthConstructor));
    XCTAssertEqual(sizeOfEmptyStruct, sizeof(aEmptyStructWithConstructor));
}

- (void)testStructAlignment{
    // 测试Struct大小 struct = count([size of elements]) * max([align of elements])
    
    int alignOfChar = alignof(char);
    int alignOfShort = alignof(short);
    int alignOfPtr = alignof(int *);
    
    // 2个元素
    XCTAssertEqual(sizeof(aSimpleStruct), 2 * std::max({alignOfChar, alignOfShort}));
    
    // 3个元素
    XCTAssertEqual(sizeof(aSimplePointerStruct), 2 * std::max({alignOfChar, alignOfShort, alignOfPtr}));
    
    aSimplePointerStruct foo[4];
    
    // 单个元素测试
    XCTAssertEqual(sizeof(foo[1]), 2 * std::max({alignOfChar, alignOfShort, alignOfPtr}));
    
    // 4个连续元素测试
    XCTAssertEqual(sizeof(foo), 4 * 2 * std::max({alignOfChar, alignOfShort, alignOfPtr}));
}


- (void)testComplexStructSize{
    // 测试复杂Struct大小
    
    struct aStruct {
        int *ptrValue;
        bool boolValue;
        int intValue;
        short shortValue;
        long longValue;
        long long longLongValue;
        float floatValue;
        double doubleValue;
        char charValue;
        void (*function)(void);
        aSimpleStruct innerStruct;
    };
    
    size_t ptr_size = sizeof(int *);
    size_t last_size = sizeof(aSimpleStruct);
    size_t struct_size = sizeof(aStruct);
    
#if __LP64__
    XCTAssertEqual(offsetof(aStruct, ptrValue), 0);
    XCTAssertEqual(offsetof(aStruct, boolValue), 1 * ptr_size); // ptrValue = 8B + 0B  1x
    XCTAssertEqual(offsetof(aStruct, intValue), 1.5 * ptr_size); // boolValue = 1B + 3B 1.5x
    XCTAssertEqual(offsetof(aStruct, shortValue), 2 * ptr_size); // intValue = 4B + 0B  2x
    XCTAssertEqual(offsetof(aStruct, longValue), 3 * ptr_size); // shortValue = 2B + 6B 3x
    XCTAssertEqual(offsetof(aStruct, longLongValue), 4 * ptr_size); // longValue = 8B + 0B 4x
    XCTAssertEqual(offsetof(aStruct, floatValue), 5 * ptr_size); // longLongValue = 8B + 0B 5x
    XCTAssertEqual(offsetof(aStruct, doubleValue), 6 * ptr_size); // floatValue = 4B + 4B 6x
    XCTAssertEqual(offsetof(aStruct, charValue), 7 * ptr_size); // doubleValue = 8B + 0B 7x
    XCTAssertEqual(offsetof(aStruct, function), 8 * ptr_size); // charValue = 1B + 7B 8x
    XCTAssertEqual(offsetof(aStruct, innerStruct), 9 * ptr_size); // function = 8B + 0B 9x
    XCTAssertEqual(struct_size - 9 * ptr_size, last_size + 4); // aSimpleUnion = 1B + 1B, 2B = 4B + 4B 10x
#else
    XCTAssertEqual(offsetof(aStruct, ptrValue), 0);
    XCTAssertEqual(offsetof(aStruct, boolValue), 1 * ptr_size); // ptrValue = 4B + 0B  1x
    XCTAssertEqual(offsetof(aStruct, intValue), 2 * ptr_size); // boolValue = 1B + 3B 2x
    XCTAssertEqual(offsetof(aStruct, shortValue), 3 * ptr_size); // intValue = 4B + 0B  3x
    XCTAssertEqual(offsetof(aStruct, longValue), 4 * ptr_size); // shortValue = 2B + 2B 4x
    XCTAssertEqual(offsetof(aStruct, longLongValue), 5 * ptr_size); // longValue = 4B + 0B 5x
    XCTAssertEqual(offsetof(aStruct, floatValue), 7 * ptr_size); // longLongValue = 8B + 0B 7x
    XCTAssertEqual(offsetof(aStruct, doubleValue), 8 * ptr_size); // floatValue = 4B + 0B 8x
    XCTAssertEqual(offsetof(aStruct, charValue), 10 * ptr_size); // doubleValue = 8B + 0B 10x
    XCTAssertEqual(offsetof(aStruct, function), 11 * ptr_size); // charValue = 1B + 3B 11x
    XCTAssertEqual(offsetof(aStruct, innerStruct), 12 * ptr_size); // function = 4B + 0B 12x
    XCTAssertEqual(struct_size - 12 * ptr_size, last_size + 0); // aSimpleUnion = 1B + 1B, 2B = 4B + 0B 13x
#endif
}

- (void)testStructAndBit{
    struct bitStruct {
        short shortValue;
        char charValue;
        int firstBit:1;
        int fourthBit:4;
        int seventhBit:7;
        char sentinel;
    };
    
    size_t struct_size = sizeof(bitStruct);
    
#if __LP64__
    XCTAssertEqual(offsetof(bitStruct, shortValue), 0);
    XCTAssertEqual(offsetof(bitStruct, charValue), 2); //shortValue = 2B
    // charValue = 1B + 1b + 4b + 7b = 2.5B < 3B
    XCTAssertEqual(offsetof(bitStruct, sentinel), struct_size - 1 - 2);
#else
    XCTAssertEqual(offsetof(bitStruct, shortValue), 0);
    XCTAssertEqual(offsetof(bitStruct, charValue), 2); //shortValue = 2B
    // charValue = 1B + 1b + 4b + 7b = 2.5B < 3B
    XCTAssertEqual(offsetof(bitStruct, sentinel), struct_size - 1 - 2);
#endif
}

- (void)testUnionSize{
    // 测试union大小 union = max([[size of elements]])
    
    int sizeOfChar = sizeof(char);
    int sizeOfShort = sizeof(short);
    int sizeOfPtr = sizeof(int *);
    
    // 2个元素
    XCTAssertEqual(sizeof(aSimpleUnion), std::max({sizeOfChar, sizeOfShort}));
    
    // 3个元素
    XCTAssertEqual(sizeof(aSimplePointerUnion), std::max({sizeOfChar, sizeOfShort, sizeOfPtr}));
    
    aSimplePointerUnion foo[4];
    
    // 单个元素测试
    XCTAssertEqual(sizeof(foo[1]), std::max({sizeOfChar, sizeOfShort, sizeOfPtr}));
    
    // 4个连续元素测试
    XCTAssertEqual(sizeof(foo), 4 * std::max({sizeOfChar, sizeOfShort, sizeOfPtr}));
}

- (void)testComplexUnionSize{
    
    union aComplexUnion {
        int *ptrValue;
        bool boolValue;
        int intValue;
        short shortValue;
        long longValue;
        long long longLongValue;
        float floatValue;
        double doubleValue;
        char charValue;
        void (*function)(void);
        aSimpleStruct innerStruct;
    };
    
    int sizeOfPtr = sizeof(int *);
    int sizeOfBool = sizeof(bool);
    int sizeOfInt = sizeof(int);
    int sizeOfShort = sizeof(short);
    int sizeOfLong = sizeof(long);
    int sizeOfLongLong = sizeof(long long);
    int sizeOfFloat = sizeof(float);
    int sizeOfDouble = sizeof(double);
    int sizeOfChar = sizeof(char); // need alignment
    int sizeOfFunction = sizeof(simpleFunctionPtr);
    int sizeOfInnerStruct = sizeof(aSimpleStruct);
    
    int maxValue = std::max({sizeOfPtr, sizeOfBool, sizeOfInt, sizeOfShort, sizeOfLong, sizeOfLongLong, sizeOfDouble, sizeOfFloat, sizeOfChar, sizeOfFunction, sizeOfInnerStruct});
    int unionSize = sizeof(aComplexUnion);
    XCTAssertEqual(unionSize, maxValue);
}

@end
