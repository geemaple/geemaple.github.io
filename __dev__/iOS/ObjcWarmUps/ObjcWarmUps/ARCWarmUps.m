//
//  ARCWarmUps.m
//  ObjcWarmUps
//
//  Created by dean on 9/11/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>

extern void _objc_autoreleasePoolPrint(); //这是个私有API
extern int _objc_rootRetainCount(id); //这是个私有API

@interface MRCObject : NSObject
+ (instancetype)object;
@end

@implementation MRCObject

+ (instancetype)object{
    return [[MRCObject alloc] init];
}

- (BOOL)retainWeakReference{
    printf("retainWeakReference");
    return NO;
}

- (void)dealloc{
}

@end

@interface ARCWarmUps : XCTestCase

@end

@implementation ARCWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testBridgeCasting{
    id array = [[NSMutableArray alloc] init]; //strong +1
    CFMutableArrayRef cfArray = (__bridge CFMutableArrayRef)array; //do nothing
    
    CFShow(cfArray);
    XCTAssertEqual(CFGetRetainCount(cfArray), 1);
    XCTAssertEqual(_objc_rootRetainCount(array), 1);
} //array -1

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

- (void)testWeakAutorealse{
    MRCObject __weak *obj = [MRCObject object];
    _objc_autoreleasePoolPrint();
    NSLog(@"%p", obj);
    NSLog(@"1 %@", obj);
    NSLog(@"2 %@", obj);
    NSLog(@"3 %@", obj);
    NSLog(@"4 %@", obj);
    
}
@end
