//
//  main.m
//  ClassObject
//
//  Created by dean on 9/9/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/objc.h>


@interface CatAnimal : NSObject

@end

@implementation CatAnimal

@end

@interface PrisonCat : CatAnimal

@property(nonatomic, copy) NSString *name;
@property(atomic, assign) BOOL isSick;

- (void)fullySick;
+ (void)fullySick;
@end

@implementation PrisonCat

- (instancetype)init{
    if(self = [super init]){
        //因为PrisonCat没有覆盖class方法，所以调用self和super结果是一样的
        Class cls = [self class];
        Class super_cls = [super class];
        printf("place holder");
    }
    return self;
}

//- (Class)class{
//    return objc_getClass("NSObject");
//}

- (void)fullySick{
    printf("nice job\n");
}
+ (void)fullySick{
    printf("fully sick bro\n");
}

@end


@interface PrisonCat(Mogoal)
- (void)catCrawl;
@end

@implementation PrisonCat(Mogoal)
- (void)catCrawl{
    printf("crawling x1 x2 x3 jump\n");
}
@end


void printSuperClass(Class cls){
    printf("superclass: %s%s", class_getName(cls), class_isMetaClass(cls)?"[meta]": "");
    while (class_getSuperclass(cls)) {
        cls = class_getSuperclass(cls);
        printf(" < %s%s", class_getName(cls), class_isMetaClass(cls)?"[meta]": "");
    }
    printf(" < nil \n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        PrisonCat *kitty = [[PrisonCat alloc] init];
        
        [kitty fullySick];
        [[kitty class] fullySick];
        
        Class cls = objc_getClass("PrisonCat");
        Class meta_cls = objc_getMetaClass("PrisonCat");
        
        printSuperClass(cls);
        printSuperClass(meta_cls);
    }
    return 0;
}
