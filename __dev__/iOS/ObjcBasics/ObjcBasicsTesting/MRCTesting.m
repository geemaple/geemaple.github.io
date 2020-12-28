//
//  MRCTesting.m
//  MRCTesting
//
//  Created by dean on 9/11/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/NSDebug.h>

@interface MRCTesting : XCTestCase

@property (nonatomic, retain) NSObject *mrcIvar;

@end

@implementation MRCTesting

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAutoreleaseException {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSObject *testObject = [NSObject new];
    
    [testObject autorelease];
    
    XCTAssertThrowsSpecificNamed([pool autorelease], NSException, NSInvalidArgumentException);
    
    [pool release];
}


- (void)setMrcIvar:(NSObject *)mrcIvar
{
    [mrcIvar retain];
    [_mrcIvar release];
    _mrcIvar = mrcIvar;
}

- (void)testMRCIvarSetting {
    
    NSObject *obj = [NSObject new];
    [self setMrcIvar:obj];
    [self setMrcIvar:obj];
}

@end
