//
//  main.m
//  ObjcWarmUps
//
//  Created by Dean Ji on 12/28/20.
//  Copyright © 2020 dean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/objc.h>

extern uintptr_t _objc_rootRetainCount(id obj); // 这是个私有API，作用是返回obj的引用计数。
extern void _objc_autoreleasePoolPrint(void); //这是个私有API, 作用是打印当前的自动释放池对象。

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

- (void)fullySick{
    printf("nice job\n");
}
+ (void)fullySick{
    printf("fully sick bro\n");
}

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
//        @autoreleasepool {
//            PrisonCat *cat1 = [PrisonCat new];
//            NSLog(@"cat1 = %@", cat1);
//            _objc_autoreleasePoolPrint();
//        }
//    
//        {
//            PrisonCat *cat2 = [PrisonCat new];
//            NSLog(@"cat2 = %@", cat2);
//            _objc_autoreleasePoolPrint();
//        }
//        
//        
//        PrisonCat *cat3 = [PrisonCat new];
//        NSLog(@"cat3 = %@", cat3);
//        _objc_autoreleasePoolPrint();
//        
//        @autoreleasepool {
//            @autoreleasepool {
//                PrisonCat *cat4 = [PrisonCat new];
//                NSLog(@"cat4 = %@", cat4);
//                _objc_autoreleasePoolPrint();
//            }
//        }
        
        id __weak obj0;
        {
            id obj1 = [[NSMutableArray alloc] init];
            obj0 = obj1;
            NSLog(@"%p", obj0);
            NSLog(@"%lu", _objc_rootRetainCount(obj0));
            _objc_autoreleasePoolPrint();
        }
        NSLog(@"obj0-1-%@", obj0);
    }
    return 0;
}
