//
//  RuntimeWarmUps.m
//  ObjcWarmUpsTests
//
//  Created by dean on 9/6/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>

struct mogoal_class{
    mogoal_class *isa;
    const char *name;
};

union isa_mogoal
{
    isa_mogoal() { }
    isa_mogoal(uintptr_t value) : bits(value) { }
    
    mogoal_class * cls;
    uintptr_t bits;
    
    //SUPPORT_PACKED_ISA ...
    //SUPPORT_INDEXED_ISA ..
};

struct mogoal_object {
    isa_mogoal isa;
    const char *name;
};

typedef struct mogoal_class *custom_class; //类的定义
typedef struct mogoal_object *custom_id; //对象的定义

@interface RuntimeWarmUps : XCTestCase

@end

@implementation RuntimeWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFakeObjectAndClass{
    
    mogoal_class aClass = mogoal_class({NULL, "myclass"});
    custom_class myClass = &aClass;
    isa_mogoal isa_t = isa_mogoal((uintptr_t)myClass);
    
    mogoal_object aObject = mogoal_object({isa_t, "myobject"});
    custom_id myObject = &aObject;
    
    
    XCTAssertTrue(strcmp(myObject->name, "myobject") == 0);
    XCTAssertTrue(strcmp((myObject->isa.cls->name), "myclass") == 0);
}
@end
