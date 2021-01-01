//
//  CatAnimal.h
//  ObjcBasicsTesting
//
//  Created by Dean Ji on 12/30/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern uintptr_t _objc_rootRetainCount(id obj); // 这是个私有API，作用是返回obj的引用计数。
extern void _objc_autoreleasePoolPrint(void); //这是个私有API, 作用是打印当前的自动释放池对象。

@interface CatAnimal : NSObject

@end

@interface PrisonCat : CatAnimal

@property(nonatomic, copy) NSString *name;
@property(atomic, assign) BOOL isSick;

- (void)fullySick;
+ (void)fullySick;
@end

@interface PrisonCat(Mogoal)
- (void)catCrawl;
@end

NS_ASSUME_NONNULL_END
