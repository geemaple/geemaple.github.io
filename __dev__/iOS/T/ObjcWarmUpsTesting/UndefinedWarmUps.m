//
//  UndefinedWarmUps.m
//  ObjcWarmUps
//
//  Created by dean on 9/8/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExistingMultiFileClass.h"

@interface ExistingOneFileClass:NSObject
- (NSString *)sayHi;
@end

@implementation ExistingOneFileClass
- (NSString *)sayHi{ return @"ExistingMultiFileClass sayhi";}
@end

@interface ExistingOneFileClass(TestingOne)
- (NSString *)sayHi;
@end

@implementation ExistingOneFileClass(TestingOne)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wshadow-ivar"
- (NSString *)sayHi{ return @"TestingOne sayhi";}
#pragma clang diagnostic pop
@end


@interface ExistingOneFileClass(TestingTwo)
- (NSString *)sayHi;
@end

@implementation ExistingOneFileClass(TestingTwo)
- (NSString *)sayHi{ return @"TestingTwo sayhi";}
@end

@interface UndefinedWarmUps : XCTestCase

@end

@implementation UndefinedWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCategoryUndefined {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    ExistingOneFileClass *instance = [[ExistingOneFileClass alloc] init];
    NSString *result = [instance sayHi];
    XCTAssertTrue([result isEqualToString:@"TestingTwo sayhi"]);
    
    ExistingMultiFileClass * anotherInstance = [[ExistingMultiFileClass alloc] init];
    result = [anotherInstance sayHi];
    XCTAssertTrue([result isEqualToString:@"TestingOne sayhi"]);
}
@end
