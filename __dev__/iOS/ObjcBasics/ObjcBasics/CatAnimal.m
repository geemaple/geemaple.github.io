//
//  CatAnimal.m
//  ObjcBasicsTesting
//
//  Created by Dean Ji on 12/30/20.
//

#import "CatAnimal.h"

@implementation CatAnimal

@end

@implementation PrisonCat

- (instancetype)init{
    if (self = [super init]) {
        //因为PrisonCat没有覆盖class方法，所以调用self和super结果是一样的
        NSLog(@"cls self = %@", NSStringFromClass([self class]));
        NSLog(@"cls super = %@", NSStringFromClass([super class]));
        NSLog(@"cls %@ super_cls\n", ([self class] == [super class] ? @"==" : @"!="));
    }
    return self;
}

- (void)fullySick{
    printf("nice job\n");
}
+ (void)fullySick{
    printf("fully sick bro\n");
}

@end

@implementation PrisonCat(Mogoal)
- (void)catCrawl{
    printf("crawling x1 x2 x3 jump\n");
}
@end

