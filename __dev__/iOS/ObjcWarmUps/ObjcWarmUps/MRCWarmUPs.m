//
//  MRCWarmUPs.m
//  ObjcWarmUps
//
//  Created by dean on 9/11/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/NSDebug.h>

extern void _objc_autoreleasePoolPrint(); //这是个私有API
extern int _objc_rootRetainCount(id); //这是个私有API

@interface MRCWarmUPs : XCTestCase

@end

@implementation MRCWarmUPs

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAutoreleaseException{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSObject *testObject = [NSObject new];
    
    [testObject autorelease];
    
    XCTAssertThrowsSpecificNamed([pool autorelease], NSException, NSInvalidArgumentException);
    
    [pool release];
}
@end
