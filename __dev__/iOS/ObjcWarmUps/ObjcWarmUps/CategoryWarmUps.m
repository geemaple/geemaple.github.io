//
//  CategoryWarmUps.m
//  ObjcWarmUps
//
//  Created by dean on 9/8/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface TestingClassOne: NSObject{
    BOOL _sick;
}


@end


@implementation TestingClassOne

@end

@interface TestingClassOne(Testing)
@property(nonatomic, assign)BOOL sick;
@property(nonatomic, assign)BOOL rich;
@end

@implementation TestingClassOne(Testing)

@end


@interface CategoryWarmUps : XCTestCase

@end

@implementation CategoryWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCateGoryProperty {
    TestingClassOne *instance = [[TestingClassOne alloc] init];
    
    XCTAssertThrowsSpecificNamed(instance.sick, NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(instance.rich, NSException, NSInvalidArgumentException);
}


@end
