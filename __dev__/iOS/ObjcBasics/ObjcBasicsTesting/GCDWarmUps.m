//
//  GCDWarmUps.m
//  ObjcWarmUps
//
//  Created by dean on 9/13/17.
//  Copyright © 2017 dean. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface GCDWarmUps : XCTestCase

@end

@implementation GCDWarmUps

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSerialQueue {
    
    dispatch_queue_t serial = dispatch_queue_create("com.mogoal.serial", DISPATCH_QUEUE_SERIAL);

    int count = 100;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++){
        [result addObject:@(i)];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < count + 1; i++){
        dispatch_async(serial, ^{[array addObject:@(i)];});
        if (i == count) {
            dispatch_async(serial, ^{
                XCTAssertEqual(array, result);
            });
        }
    }
    
}

- (void)testCurrenToSerialSource {
    
    dispatch_queue_t serial = dispatch_queue_create("com.mogoal.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrent = dispatch_queue_create("com.mogoal.concurrent", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_set_target_queue(concurrent, serial);
    
    int count = 100;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++){
        [result addObject:@(i)];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < count + 1; i++){
        dispatch_async(concurrent, ^{[array addObject:@(i)];});
        if (i == count) {
            dispatch_async(concurrent, ^{
                XCTAssertEqual(array, result);
            });
        }
    }
}

- (void)testDispatchGroupNotify{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{NSLog(@"blk0");});
    dispatch_group_async(group, queue, ^{NSLog(@"blk1");});
    dispatch_group_async(group, queue, ^{NSLog(@"blk2");});
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{NSLog(@"done");});
}

- (void)testDispatchGroupWait{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{NSLog(@"blk0");});
    dispatch_group_async(group, queue, ^{NSLog(@"blk1");});
    dispatch_group_async(group, queue, ^{NSLog(@"blk2");});
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"done");
}

- (void)testReadingWritingQuestion{
    
    __block int number = 100;
    
    dispatch_queue_t high_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    

    // 错误演示
    dispatch_suspend(high_queue);
    
    dispatch_async(high_queue, ^{ printf("Wrong case\n"); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{
        sleep(2);
        printf("===high_write");
        number += 1;
        printf("===");
    });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    dispatch_async(high_queue, ^{ printf("===%d", number); });
    
    dispatch_resume(high_queue);
    
    
    //正确演示
    __block int another_num = 200;
    dispatch_queue_t low_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    
    dispatch_suspend(low_queue);
    
    dispatch_async(high_queue, ^{ printf("\nRight case\n"); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_barrier_sync(low_queue, ^{
        sleep(2);
        printf("===low_write");
        another_num += 1;
        printf("===");
    });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    dispatch_async(low_queue, ^{ printf("===%d", another_num); });
    
    dispatch_resume(low_queue);
   
    sleep(5);
}

- (void)testDeadLock{
//    dispatch_queue_t queue = dispatch_queue_create("com.mogoal.serial", NULL);
//
//    dispatch_async(queue, ^{
//        dispatch_sync(queue, ^{
//            printf("hello world\n");
//        });
//    });
}

- (void)testExecuteNTimes{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //数数
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"count %zu", index);
    });
    NSLog(@"done");
    
    //遍历数组
    int count = 100;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++){
        [array addObject:@(i)];
    }
    
    dispatch_apply(count, queue, ^(size_t index) {
        NSLog(@"%@", array[index]);
    });
    
}

- (void)testSemaphore{
    int count = 100;
    dispatch_queue_t concurrent = dispatch_queue_create("com.mogoal.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_semaphore_t flag = dispatch_semaphore_create(1);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < count; i++){
        dispatch_semaphore_wait(flag, DISPATCH_TIME_FOREVER);
        dispatch_async(concurrent, ^{[array addObject:@(i)];});
        NSLog(@"%d", i);
        dispatch_semaphore_signal(flag);
    }
}

- (void)testDispatchAfter{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(001 * NSEC_PER_SEC));
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"dispatch_after");
    });

}

@end
