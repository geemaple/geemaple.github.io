---
layout: post
title: "C++数据内存Alignment与Padding"
date: 2014-02-18
categories: Lang
tags: Lang C++
excerpt: 本文主要列举C/C++常用数据类型在32位与64位机器中内存大小，涉及到内存对齐(alignment)与补全(padding), 以及如何优化一个结构体占用内存大小。
---

* content
{:toc}

## 介绍

> 你是想学我的技能吧 ----阿尔伯特

C++是Objective-C底层技术的实现语言，所以夯实基础，有助于源码阅读。再者，如果你从事嵌入式编成工作，内存很小的情况下，如果存在大量(成百上千)结构体，优化结构体存储能够有效减少内存使用。

本文涉及测试代码在[这里](https://github.com/geemaple/geemaple.github.io/blob/master/__dev__/iOS/ObjcWarmUps/ObjcWarmUps/SizingWarmUps.mm), 你可以选择Xcode -> Target -> Building Settings -> Architectures来选择32位还是64位

## 内存对齐
如果把内存看成8-bit一个单元的列车车厢，C语言需要把基本的数据类型整齐的放入车厢中，这样能够有助于CPU通过一个指令读取和存入数据，如果没有对齐的处理，那么一个数据很有可能横跨两个车厢，CPU可能需要2个指令或者更多。

为了确保数据尽可能呆在一个车厢内:

1. 数据大小等于1时(char bool)，不可能横跨车厢，所以对齐设定=1，也就是说放在哪都一样
2. 数据大小等于2时(short)，需要2x地址才能够保证
3. 数据大小等于4时(int，float), 需要4x地址才能够保证
4. 数据大小等于8时(double等), 需要8x地址才能够保证。[这里double比较特殊需要8x地址](https://stackoverflow.com/questions/11108328/double-alignment)


PS: 对于32位机器，当数据大于4时，跨车厢无法避免，通常4x地址就可以。

## 32位 vs. 64位

以下是C／C++基本数据类型在32位平台(ILP32)和64位平台(LP64)内存占用大小, 有无unsigned并不影响其大小, 其中单位B = Byte。

数据类型 | ILP32大小 | ILP32对齐 | LP64大小 | LP64对齐
------- | :------: | :------: | :------: | :------:
char  | 1B | 1B | 1B | 1B
bool  | 1B | 1B | 1B | 1B
short | 2B | 2B | 2B | 2B
int   | 4B | 4B | 4B | 4B
float | 4B | 4B | 4B | 4B
double| 8B | 8B | 8B | 8B
long  | 4B | 4B | 8B | 8B
long long | 8B | 4B | 8B | 8B
pointer | 4B | 4B | 8B | 8B

```c++
time_t = long
size_t = unsigned long
off_t = fpos_t = long long
```

## 内存补齐

我们假设代码变量顺序，就是变量在内存中的顺序(C99提到，补齐并不保证其值为0)

指针对齐非常严格，必须占满4/8个车厢，无论之前内存布局如何

情况1: int
```c++
char *p;      // 4B(ILP32) 或 8B(LP64)
char c;       // 1B 需要3B来补齐
int x;        // 4B
```

情况2: short
```c++
char *p;      // 4B(ILP32) 或 8B(LP64)
char c;       // 1B 需要1B来补齐
short x;      // 2B
```

情况3: long
```c++
char *p;     // 4B(ILP32) 或 8B(LP64)
char c;      // 1B 需要3B(ILP32) 或 7B(LP64)补齐
long x;      // 4B(ILP32) 或 8B(LP64)
```

情况4: char开头
```c++
char c;      // 1B 考虑已有内存情况, 需要0-3(ILP32)或0-7(LP64)补齐
char *p;     // 4B(ILP32) 或 8B(LP64)
int x;       // 4B
```

## Struct

通常，Struct会选择元素中最大对齐，作为自己的对齐选择。而且末尾元素若不占满车厢，也会补全。若struct中包含struct, 以此类推。最大数字也就是8B

具体而言你可以用offsetof来查看每一个元素的偏移量

```c++
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
```

## Struct 和 Bit

offsetof无法用在bit元素上，不过我想可以最小类型char来做个标记查看下

```c++
    struct bitStruct {
        short shortValue;
        char charValue;
        int firstBit:1;
        int fourthBit:4;
        int seventhBit:7;
        char sentinal;
    };

    size_t struct_size = sizeof(bitStruct);

#if __LP64__
    XCTAssertEqual(offsetof(bitStruct, shortValue), 0);
    XCTAssertEqual(offsetof(bitStruct, charValue), 2); //shortValue = 2B
    // charValue = 1B + 1b + 4b + 7b = 2.5B < 3B
    XCTAssertEqual(offsetof(bitStruct, sentinal), struct_size - 1 - 2);
#else
    XCTAssertEqual(offsetof(bitStruct, shortValue), 0);
    XCTAssertEqual(offsetof(bitStruct, charValue), 2); //shortValue = 2B
    // charValue = 1B + 1b + 4b + 7b = 2.5B < 3B
    XCTAssertEqual(offsetof(bitStruct, sentinal), struct_size - 1 - 2);
#endif
```


## 空实例

为了保证每一个变量实例都拥有不同的地址，sizeof(空的Struct，Union, Class)=1


## Struct vs. Union

如果把Struct看成高铁座位，其中每个乘客, 都有自己的位置，并且有足够舒适的空间(即对齐和补全)

Union可以看成高铁的一个洗手间，可以容纳任意指定乘客，通常一次只能一个人使用

```cpp
union foo {
  int a;   // can't use both a and b at once
  char b;
} foo;

struct bar {
  int a;   // can use both a and b simultaneously
  char b;
} bar;


union foo x;
x.a = 3; // OK
x.b = 'c'; // NO! this affects the value of x.a!

struct bar y;
y.a = 3; // OK
y.b = 'c'; // OK
```

## 优化Struct大小

最简单的优化Struct大小的方式是，按照Bytes从大到小一次排序，先是8Byte > 4Byte > 2Byte > 1Byte
这样做的原因是，任意一个较大size的数据类型padding后，接下来的起始地址，总是适合Size比他小的数据类型，

但是，例如下面代码，有时仅靠重新布局是无法节省struct的大小的，这时应该考虑设计上能否有什么改进。
```c++
struct foo12 {
    struct foo12_inner {
        char *p;      /* 8 bytes */
        int x;        /* 4 bytes */
    } inner;
    char c;           /* 1 byte*/
};
```

代码并不是只给机器看的，你可能和其他工程师合作，又或许将来的你可能回溯这段代码。所以合理的安排有相同意义的数据分组，对可读性有很大帮助。作为工程师，这个重要的优化，设计，与可读性问题就留给你了

## 更多
[https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html#//apple_ref/doc/uid/TP40013501-CH2-SW1](https://developer.apple.com/library/content/documentation/General/Conceptual/CocoaTouch64BitGuide/Major64-BitChanges/Major64-BitChanges.html#//apple_ref/doc/uid/TP40013501-CH2-SW1)

[http://www.catb.org/esr/structure-packing/](http://www.catb.org/esr/structure-packing/)

[http://www.stroustrup.com/bs_faq2.html#sizeof-empty](http://www.stroustrup.com/bs_faq2.html#sizeof-empty)
