//
//  main.m
//  GCD
//
//  Created by dean on 9/13/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.MySerialDispatchQueue", NULL);
        
        dispatch_async(queue, ^{
            dispatch_sync(queue, ^{
                printf("hello world\n");
            });
        });
        
        sleep(20);
    }
    return 0;
}
