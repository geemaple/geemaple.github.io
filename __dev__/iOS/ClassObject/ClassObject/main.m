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
#import "CatAnimal.h"

void printSuperClass(Class cls){
    printf("superclass: %s%s", class_getName(cls), class_isMetaClass(cls)?"[meta]": "");
    while (class_getSuperclass(cls)) {
        cls = class_getSuperclass(cls);
        printf(" => %s%s", class_getName(cls), class_isMetaClass(cls)?"[meta]": "");
    }
    printf(" => nil \n");
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
