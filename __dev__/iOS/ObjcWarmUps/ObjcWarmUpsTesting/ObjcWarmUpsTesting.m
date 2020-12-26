//
//  ObjcWarmUpsTesting.m
//  ObjcWarmUpsTesting
//
//  Created by Dean Ji on 12/27/20.
//  Copyright © 2020 dean. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <pthread/pthread.h>

typedef struct zemaphore_t {
    int value;
    pthread_cond_t cond;
    pthread_mutex_t lock;
} zemaphore_t;

void z_init(zemaphore_t *s, int value)
{
    s->value = value;
    pthread_cond_init(&s->cond, NULL);
    pthread_mutex_init(&s->lock, NULL);
}

void z_wait(zemaphore_t *s)
{
    pthread_mutex_lock(&s->lock);
    while (s->value <= 0) {
        pthread_cond_wait(&s->cond, &s->lock);
    }
    s->value--;
    pthread_mutex_unlock(&s->lock);
}

void z_post(zemaphore_t *s)
{
    pthread_mutex_lock(&s->lock);
    s->value++;
    pthread_cond_signal(&s->cond);
    pthread_mutex_unlock(&s->lock);
}

@interface ObjcWarmUpsTesting : XCTestCase

@end

@implementation ObjcWarmUpsTesting

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
