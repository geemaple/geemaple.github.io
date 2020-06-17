//
//  main.m
//  BlockTesting
//
//  Created by dean on 9/4/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <Foundation/Foundation.h>

// global block
void (^global)(void) = ^{
    printf("hello global\n");
};

// stack block
int main(int argc, const char * argv[]) {
    
    void (^hello)(void) = ^{
        printf("hello world\n");
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        hello();
    });
    
    sleep(10);
    
    return 0;
}


//int main(int argc, const char * argv[]) {
//    int constNum = 100;
//    void (^hello)(void) = ^{
//        printf("hello world\n %d", constNum);
//    };
//    hello();
//    return 0;
//}


//int main(int argc, const char * argv[]) {
//    int constNum = 100;
//    __block int varNum = 200;
//    float hi = 1.0;
//    
//    varNum = varNum + 1;
//    
//    void (^theBlock)(int) = ^(int var1){
//        printf("%d, %d %d\n", constNum, varNum, var1);
//        varNum = 2;
//        var1 = 3;
//    };
//    
//    theBlock(404);
//    return 0;
//}


//int global_val = 1;
//static int static_global_val = 2;
//int main() {
//    static int static_val = 3; void (^blk)(void) = ^{
//        global_val *= 1; static_global_val *= 2; static_val *= 3;
//    };
//    return 0;
//}


